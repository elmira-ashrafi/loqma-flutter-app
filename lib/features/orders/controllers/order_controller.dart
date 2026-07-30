import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/utils/error_parser.dart';
import '../models/order_model.dart';
import '../order_track_shared.dart';
import '../services/order_service.dart';

class OrderController extends GetxController {
  OrderController({OrderService? service}) : _service = service ?? OrderService();

  final OrderService _service;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  /// Bottom-nav badge — updated when the list changes (avoids scanning on every frame).
  final RxBool hasActiveOrders = false.obs;
  Worker? _localeWorker;

  /// Match Laravel default page size; paginate until exhausted.
  static const int _ordersPageSize = 15;
  static const int _maxHistoryPages = 100;

  /// Soft TTL so tab switches don't refetch full history every time.
  static const Duration _historyFreshTtl = Duration(seconds: 45);
  DateTime? _lastSuccessfulHistoryLoad;

  Completer<void>? _refreshLock;

  OrderModel _mergeOrderModels(OrderModel server, OrderModel local) {
    final mergedTimeline =
        server.timeline.isNotEmpty ? server.timeline : local.timeline;
    final mergedStatus = resolveOrderTrackStatus(
      mergeOrderStatus(local.status, server.status),
      mergedTimeline.map((e) => e.status),
    );
    return server.copyWith(
      status: mergedStatus,
      timeline: mergedTimeline,
      items: (server.items != null && server.items!.isNotEmpty) ? server.items : local.items,
      itemsCount: server.effectiveItemCount > 0 ? server.itemsCount : local.itemsCount,
      driver: server.driver ?? local.driver,
      estimatedPrepTime: server.estimatedPrepTime ?? local.estimatedPrepTime,
      estimatedDeliveryTime: server.estimatedDeliveryTime ?? local.estimatedDeliveryTime,
      restaurantImage: server.restaurantImage ?? local.restaurantImage,
      restaurantName: server.restaurantName ?? local.restaurantName,
      restaurantNameFa: server.restaurantNameFa ?? local.restaurantNameFa,
      restaurantNamePs: server.restaurantNamePs ?? local.restaurantNamePs,
      restaurantLocalizedName: server.restaurantLocalizedName ?? local.restaurantLocalizedName,
      placedAt: server.placedAt ?? local.placedAt,
      total: server.total > 0 ? server.total : local.total,
      orderNumber: server.orderNumber ?? local.orderNumber,
      paymentMethod: server.paymentMethod ?? local.paymentMethod,
      paymentStatus: server.paymentStatus ?? local.paymentStatus,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        update();
      });
    }
  }

  @override
  void onClose() {
    _localeWorker?.dispose();
    super.onClose();
  }

  void upsertOrder(OrderModel order) {
    if (order.id <= 0) return;
    final idx = orders.indexWhere((e) => e.id == order.id);
    if (idx >= 0) {
      orders[idx] = _mergeOrderModels(order, orders[idx]);
    } else {
      orders.add(order);
    }
    orders.sort(OrderModel.compareNewestFirst);
    _syncActiveOrdersFlag();
  }

  void _syncActiveOrdersFlag() {
    hasActiveOrders.value = orders.any((o) => !_isTerminal(o.status));
  }

  /// Pulls any orders referenced by notifications that are not in the cached list yet.
  Future<void> hydrateOrdersByIds(Set<int> orderIds) async {
    if (orderIds.isEmpty) return;
    for (final id in orderIds) {
      if (id <= 0) continue;
      if (orders.any((o) => o.id == id)) continue;
      final detail = await getOrderById(id);
      if (detail != null && detail.id > 0) upsertOrder(detail);
    }
  }

  void _publishOrders(Map<int, OrderModel> byId) {
    final list = byId.values.where((o) => o.id > 0).toList()
      ..sort(OrderModel.compareNewestFirst);
    orders.assignAll(list);
    _syncActiveOrdersFlag();
    if (kDebugMode) {
      debugPrint(
        'OrderController: showing ${list.length} orders '
        '(active=${list.where((o) => !_isTerminal(o.status)).length}, '
        'delivered=${list.where((o) => normalizeOrderStatusKey(o.status) == 'delivered').length}, '
        'cancelled=${list.where((o) {
          final s = normalizeOrderStatusKey(o.status);
          return s == 'cancelled' || s == 'refunded';
        }).length})',
      );
    }
  }

  static bool _isTerminal(String status) {
    final s = normalizeOrderStatusKey(status);
    return s == 'delivered' || s == 'cancelled' || s == 'refunded';
  }

  void _mergeIncomingOrders(List<OrderModel> incoming) {
    for (final o in incoming) {
      if (o.id <= 0) continue;
      final idx = orders.indexWhere((e) => e.id == o.id);
      if (idx >= 0) {
        orders[idx] = _mergeOrderModels(o, orders[idx]);
      } else {
        orders.add(o);
      }
    }
    orders.sort(OrderModel.compareNewestFirst);
    _syncActiveOrdersFlag();
  }

  /// Fetches every page for [status] (`all` / null = no status filter).
  Future<List<OrderModel>> _fetchAllPages({String? status}) async {
    final collected = <OrderModel>[];
    var page = 1;
    while (page <= _maxHistoryPages) {
      final res = await _service.getOrders(
        page: page,
        perPage: _ordersPageSize,
        status: status,
      );
      if (res.data.isEmpty) break;
      collected.addAll(res.data.where((o) => o.id > 0));

      final meta = res.meta;
      final bool more;
      if (meta.lastPage > 1) {
        more = page < meta.lastPage;
      } else if (meta.total > 0) {
        more = collected.length < meta.total;
      } else {
        // No reliable meta: keep going while this page was full.
        more = res.data.length >= _ordersPageSize;
      }
      if (!more) break;
      page++;
    }
    if (kDebugMode) {
      debugPrint(
        'OrderController: fetched ${collected.length} orders'
        '${status == null || status == 'all' ? '' : ' status=$status'}',
      );
    }
    return collected;
  }

  bool get _historyIsFresh {
    final last = _lastSuccessfulHistoryLoad;
    if (last == null) return false;
    return DateTime.now().difference(last) < _historyFreshTtl;
  }

  /// Loads the full customer order history (active + completed + cancelled).
  /// Skips network when a recent successful load exists unless [force] is true.
  Future<void> loadFullOrderHistory({bool force = false}) =>
      loadOrders(refresh: true, force: force);

  Future<void> loadOrders({bool refresh = true, bool force = false}) async {
    if (refresh && !force && _historyIsFresh && orders.isNotEmpty) {
      return;
    }
    if (refresh) {
      if (_refreshLock != null) return _refreshLock!.future;
      _refreshLock = Completer<void>();
      currentPage.value = 1;
      hasMore.value = true;
      error.value = '';
    }

    final showSpinner = orders.isEmpty;
    if (showSpinner) isLoading.value = true;

    try {
      if (refresh) {
        final byId = <int, OrderModel>{
          for (final o in orders)
            if (o.id > 0) o.id: o,
        };

        void absorb(List<OrderModel> batch) {
          for (final o in batch) {
            if (o.id <= 0) continue;
            final existing = byId[o.id];
            byId[o.id] = existing == null ? o : _mergeOrderModels(o, existing);
          }
        }

        // Prefer a single `all` history walk. Extra status filters only if empty
        // (legacy API quirk) — avoids 4× full pagination on every refresh.
        try {
          absorb(await _fetchAllPages(status: 'all'));
        } catch (e) {
          if (kDebugMode) debugPrint('OrderController: all-orders fetch failed: $e');
        }

        if (byId.isEmpty) {
          try {
            absorb(await _fetchAllPages(status: 'delivered'));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('OrderController: delivered fetch failed: $e');
            }
          }
          try {
            absorb(await _fetchAllPages(status: 'cancelled'));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('OrderController: cancelled fetch failed: $e');
            }
          }
          try {
            absorb(await _fetchAllPages(status: 'refunded'));
          } catch (_) {}
          if (byId.isEmpty) {
            absorb(await _fetchAllPages());
          }
        }

        // One publish at the end → one list rebuild instead of many mid-fetch.
        _publishOrders(byId);
        _lastSuccessfulHistoryLoad = DateTime.now();

        hasMore.value = false;
        currentPage.value = 1;
      } else {
        final res = await _service.getOrders(
          page: currentPage.value,
          perPage: _ordersPageSize,
          status: 'all',
        );
        _mergeIncomingOrders(res.data);
        hasMore.value = res.meta.hasNextPage;
        currentPage.value = res.meta.nextPage;
      }
    } on DioException catch (e) {
      hasMore.value = false;
      if (orders.isEmpty) error.value = userFriendlyErrorMessage(e);
    } catch (e) {
      hasMore.value = false;
      if (orders.isEmpty) {
        error.value = 'Something went wrong. Please try again.';
      }
      if (kDebugMode) debugPrint('OrderController.loadOrders error: $e');
    } finally {
      if (showSpinner) isLoading.value = false;
      if (refresh) {
        _refreshLock?.complete();
        _refreshLock = null;
      }
    }
  }

  Future<OrderModel?> trackOrder(int id) async {
    try {
      return await _service.trackOrder(id);
    } catch (_) {
      return null;
    }
  }

  bool _liveRefreshInFlight = false;

  /// Lightweight live sync for in-progress orders (status + driver) while Orders is open.
  Future<void> refreshActiveOrdersLive() async {
    if (_liveRefreshInFlight) return;
    final activeIds = orders
        .where((o) => o.id > 0 && !_isTerminal(o.status))
        .map((o) => o.id)
        .toList(growable: false);
    if (activeIds.isEmpty) return;

    _liveRefreshInFlight = true;
    try {
      await Future.wait(
        activeIds.map((id) async {
          final tracked = await trackOrder(id);
          if (tracked == null || tracked.id <= 0) return;
          upsertOrder(tracked);
        }),
      );
    } finally {
      _liveRefreshInFlight = false;
    }
  }

  /// Applies a push / notification status onto a cached order immediately.
  Future<void> applyRemoteStatus({required int orderId, required String status}) async {
    if (orderId <= 0) return;
    final idx = orders.indexWhere((e) => e.id == orderId);
    if (idx >= 0) {
      final current = orders[idx];
      final mergedStatus = resolveOrderTrackStatus(
        mergeOrderStatus(current.status, status),
        current.timeline.map((e) => e.status),
      );
      if (normalizeOrderStatusKey(mergedStatus) !=
          normalizeOrderStatusKey(current.status)) {
        upsertOrder(current.copyWith(status: mergedStatus));
      }
      // Pull track payload so driver/timeline catch up without waiting for the next poll.
      unawaited(() async {
        final tracked = await trackOrder(orderId);
        if (tracked != null) upsertOrder(tracked);
      }());
      return;
    }

    final detail = await getOrderById(orderId);
    if (detail != null) {
      upsertOrder(
        detail.copyWith(
          status: resolveOrderTrackStatus(detail.status, [status]),
        ),
      );
      unawaited(() async {
        final tracked = await trackOrder(orderId);
        if (tracked != null) upsertOrder(tracked);
      }());
      return;
    }

    await loadOrders(refresh: true, force: true);
  }

  Future<OrderModel?> getOrderById(int id) async {
    try {
      return await _service.getOrderById(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> submitReview({
    required int orderId,
    required int restaurantRating,
    required int foodRating,
    String? restaurantReview,
    int? deliveryRating,
    String? deliveryReview,
    List<String>? photoPaths,
  }) async {
    await _service.submitReview(
      orderId: orderId,
      restaurantRating: restaurantRating,
      foodRating: foodRating,
      restaurantReview: restaurantReview,
      deliveryRating: deliveryRating,
      deliveryReview: deliveryReview,
      photoPaths: photoPaths,
    );
  }

  Future<void> cancelOrder({
    required int orderId,
    required String reason,
    String? reasonDetails,
  }) async {
    await _service.cancelOrder(
      orderId: orderId,
      reason: reason,
      reasonDetails: reasonDetails,
    );
  }
}
