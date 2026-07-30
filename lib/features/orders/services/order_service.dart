import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/content_translation_enricher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService({Dio? dio, ContentTranslationEnricher? enricher})
      : _dio = dio ?? ApiClient.dio,
        _enricher = enricher ?? ContentTranslationEnricher();

  final Dio _dio;
  final ContentTranslationEnricher _enricher;

  static List<dynamic> _extractOrderList(dynamic data, Map<String, dynamic> raw) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['items', 'orders', 'data', 'results']) {
        final v = map[key];
        if (v is List) return v;
      }
    }
    for (final key in ['items', 'orders']) {
      final v = raw[key];
      if (v is List) return v;
    }
    return const [];
  }

  static Map<String, dynamic> _extractMeta(dynamic data, Map<String, dynamic> raw) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['pagination'] ?? map['meta'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }
    final top = raw['pagination'] ?? raw['meta'];
    if (top is Map) return Map<String, dynamic>.from(top);
    return {};
  }

  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    int? perPage,
    String? status,
  }) async {
    final pageSize = perPage ?? AppConstants.defaultPageSize;
    final query = <String, dynamic>{
      AppConstants.pageParam: page,
      AppConstants.perPageParam: pageSize,
    };
    // Only send status when filtering; omit for a true unfiltered list.
    if (status != null && status.isNotEmpty && status != 'all') {
      query['status'] = status;
    }

    final response = await _dio.get(
      ApiConstants.customerOrders,
      queryParameters: query,
    );
    final raw = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final data = raw['data'];
    final list = _extractOrderList(data, raw);
    final metaJson = _extractMeta(data, raw);

    // Enrich may mutate list entries in place; keep maps mutable.
    final mutable = <dynamic>[
      for (final e in list)
        if (e is Map) Map<String, dynamic>.from(e) else e,
    ];
    await _enricher.enrichOrderListMaps(mutable);

    final parsed = <OrderModel>[];
    for (final e in mutable) {
      if (e is! Map) continue;
      try {
        final order = OrderModel.fromJson(Map<String, dynamic>.from(e));
        if (order.id > 0) parsed.add(order);
      } catch (err, st) {
        if (kDebugMode) {
          debugPrint('OrderService: skip bad order row: $err\n$st');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        'OrderService.getOrders page=$page status=${status ?? 'all'} '
        'raw=${list.length} parsed=${parsed.length} '
        'meta=$metaJson',
      );
    }

    return PaginatedResponse<OrderModel>(
      data: parsed,
      meta: PaginationMeta.fromJson(metaJson).copyWith(
        fetchedCount: parsed.length,
        requestedPerPage: pageSize,
      ),
    );
  }

  Future<OrderModel> getOrderById(int id) async {
    final response = await _dio.get(ApiConstants.customerOrderById(id));
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    await _enricher.enrichOrderListMaps([map]);
    return OrderModel.fromJson(map);
  }

  Future<OrderModel> trackOrder(int id) async {
    final response = await _dio.get(ApiConstants.customerOrderTrack(id));
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final orderJson = map['order'] is Map
        ? Map<String, dynamic>.from(map['order'] as Map)
        : map;
    final orderMap = Map<String, dynamic>.from(orderJson);
    if (map['driver'] != null) orderMap['driver'] = map['driver'];
    final history = map['status_history'] as List<dynamic>?;
    if (history != null && history.isNotEmpty) {
      orderMap['timeline'] = history.map((e) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          return {
            'status': m['status'],
            'label': m['note'] ?? m['label'],
            'completed_at': m['created_at'] ?? m['completed_at'],
          };
        }
        return <String, dynamic>{};
      }).toList();
    }
    await _enricher.enrichOrderListMaps([orderMap]);
    return OrderModel.fromJson(orderMap);
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
    final formData = FormData.fromMap({
      'restaurant_rating': restaurantRating,
      'food_rating': foodRating,
      if (restaurantReview != null && restaurantReview.isNotEmpty) 'restaurant_review': restaurantReview,
      if (deliveryRating != null) 'delivery_rating': deliveryRating,
      if (deliveryReview != null && deliveryReview.isNotEmpty) 'delivery_review': deliveryReview,
    });
    if (photoPaths != null && photoPaths.isNotEmpty) {
      formData.files.addAll(
        photoPaths.map((path) => MapEntry('photos[]', MultipartFile.fromFileSync(path))),
      );
    }
    await _dio.post(ApiConstants.customerOrderReview(orderId), data: formData);
  }

  Future<void> cancelOrder({
    required int orderId,
    required String reason,
    String? reasonDetails,
  }) async {
    await _dio.post(
      ApiConstants.customerOrderCancel(orderId),
      data: {
        'reason': reason,
        if (reasonDetails != null && reasonDetails.isNotEmpty) 'reason_details': reasonDetails,
      },
    );
  }
}
