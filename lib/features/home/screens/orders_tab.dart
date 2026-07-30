import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../orders/screens/order_review_screen.dart';
import '../../orders/order_track_shared.dart';
import '../../orders/orders_l10n.dart';
import '../../notifications/controllers/notification_alert_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/widgets/loading_shimmer.dart';

enum _OrderRowKind { banner, section, order, loadMore }

class _OrderRow {
  const _OrderRow._({
    required this.kind,
    this.title,
    this.order,
    this.compactDelivered = false,
    this.showLiveTracking = false,
  });

  const _OrderRow.banner() : this._(kind: _OrderRowKind.banner);

  const _OrderRow.section(String title)
    : this._(kind: _OrderRowKind.section, title: title);

  const _OrderRow.order(
    OrderModel order, {
    bool compactDelivered = false,
    bool showLiveTracking = false,
  }) : this._(
         kind: _OrderRowKind.order,
         order: order,
         compactDelivered: compactDelivered,
         showLiveTracking: showLiveTracking,
       );

  const _OrderRow.loadMore() : this._(kind: _OrderRowKind.loadMore);

  final _OrderRowKind kind;
  final String? title;
  final OrderModel? order;
  final bool compactDelivered;
  final bool showLiveTracking;
}

/// Orders tab colors adapt to [Theme]: surfaces, outlines, and CTAs use [ColorScheme].
abstract final class _OrdersTabDesign {
  static Color titleColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color accentGreen(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Section / card status title strip — app primary at low opacity.
  static Color sectionTitleBackground(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: dark ? 0.2 : 0.1);
  }

  static Color sectionTitleForeground(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? AppColors.primaryDarkTheme : AppColors.primary;
  }

  static Color onAccentFilled(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  /// Large amounts / totals — readable on both themes.
  static Color totalAccent(BuildContext context) {
    final t = Theme.of(context);
    return t.brightness == Brightness.dark
        ? t.colorScheme.primary
        : AppColors.primaryLight;
  }

  static Color cardSurface(BuildContext context) {
    final t = Theme.of(context);
    return t.brightness == Brightness.dark
        ? t.colorScheme.surfaceContainerHigh
        : t.colorScheme.surface;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    final t = Theme.of(context);
    final dark = t.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: t.shadowColor.withValues(alpha: dark ? 0.5 : 0.07),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: t.shadowColor.withValues(alpha: dark ? 0.32 : 0.04),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static Color reviewBannerFill(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return t.brightness == Brightness.dark
        ? cs.tertiaryContainer.withValues(alpha: 0.42)
        : const Color(0xFFFFF8E6);
  }

  static Color reviewBannerBorder(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return t.brightness == Brightness.dark
        ? cs.tertiary.withValues(alpha: 0.55)
        : const Color(0xFFFFB74D);
  }

  static Color reviewBannerIcon(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  static Color reviewBannerText(BuildContext context) {
    final t = Theme.of(context);
    if (t.brightness == Brightness.dark) {
      return t.colorScheme.onTertiaryContainer;
    }
    return const Color(0xFF5D4037);
  }

  static ButtonStyle outlinedSecondary(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 14),
    double radius = 14,
  }) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.styleFrom(
      foregroundColor: cs.onSurfaceVariant,
      side: BorderSide(color: cs.outline.withValues(alpha: 0.85)),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// --- Responsive helpers (orders tab) ---
bool _otCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
bool _otNarrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;
double _otCardPad(BuildContext context) => _otCompact(context) ? 12.0 : 16.0;
double _otCardPadTight(BuildContext context) =>
    _otCompact(context) ? 10.0 : 14.0;
double _otListBottomPad(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + (_otCompact(context) ? 88.0 : 100.0);

/// Default wall-clock window for ETA when [OrderModel.deliveryTime] is missing/unparseable.
const Duration kOrdersTabDeliveryRouteDuration = Duration(minutes: 35);

/// Restaurant prep window for order cards (confirmed minutes, then avg prep, then API string).
String _orderRestaurantPrepCaption(BuildContext context, OrderModel order) {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = order.estimatedPrepTime;
  if (confirmed != null && confirmed > 0) {
    return l10n.minLabel(formatAppInteger(context, confirmed));
  }
  return restaurantPrepTimeCaption(
    context,
    avgPrepMinutes: order.avgPreparationTime,
    rawDeliveryTime: order.deliveryTime,
  );
}

/// Same fallback as [RestaurantDetailsScreen] (`detail?.restaurant.deliveryTime ?? … ?? localized default`).
String _orderDeliveryTimeLabel(BuildContext context, OrderModel order) {
  return _orderRestaurantPrepCaption(context, order);
}

Widget _orderPrepTimeRow(
  BuildContext context,
  OrderModel order, {
  required String languageCode,
  Color? color,
  double fontSize = 12,
}) {
  final line = _orderRestaurantPrepCaption(context, order);
  final tone = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
  return Row(
    children: [
      Icon(Icons.timer_outlined, size: fontSize + 2, color: tone),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          line,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FontHelper.getTextStyle(
            text: line,
            languageCode: languageCode,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: tone,
          ),
        ),
      ),
    ],
  );
}

String _orderRestaurantTitle(AppLocalizations l10n, OrderModel order) {
  final name = order.displayRestaurantName?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return l10n.orderNumberLabel('${order.id}');
}

/// Banner / chips: live ETA from API when present, otherwise countdown or restaurant window.
String _ordersTabBannerDeliveryText(BuildContext context, OrderModel order) {
  return _activeOrderDeliveryChipLabel(context, order);
}

/// Active order header / ETA: localized API estimate, countdown from placed time, or prep window.
String _activeOrderDeliveryChipLabel(BuildContext context, OrderModel order) {
  final l10n = AppLocalizations.of(context)!;
  final est = order.estimatedDeliveryTime;
  if (isUsableEstimatedDeliveryTime(est)) {
    return localizeRawPrepTimeString(context, est!.trim());
  }
  final confirmed = order.estimatedPrepTime;
  if (confirmed != null && confirmed > 0) {
    return l10n.minLabel(formatAppInteger(context, confirmed));
  }
  final placed = order.effectivePlacedAt;
  if (placed != null && placed.isNotEmpty) {
    try {
      final placedDt = DateTime.parse(placed).toLocal();
      final eta = placedDt.add(_deliveryRouteDurationFromOrder(order));
      final remaining = eta.difference(DateTime.now());
      if (!remaining.isNegative && remaining.inMinutes <= 180) {
        final mins = remaining.inMinutes.clamp(1, 999);
        return l10n.orderTrackEtaApprox(formatAppInteger(context, mins));
      }
    } catch (_) {}
  }
  return _orderDeliveryTimeLabel(context, order);
}

Duration _deliveryRouteDurationFromOrder(OrderModel order) {
  final s = order.deliveryTime?.trim() ?? '';
  final range = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(s);
  if (range != null) {
    final a = int.tryParse(range.group(1)!) ?? 35;
    final b = int.tryParse(range.group(2)!) ?? 45;
    final mid = ((a + b) / 2).round();
    return Duration(minutes: mid.clamp(15, 120));
  }
  final one = RegExp(r'(\d+)').firstMatch(s);
  if (one != null) {
    final m = int.tryParse(one.group(1)!) ?? 35;
    return Duration(minutes: m.clamp(15, 120));
  }
  return kOrdersTabDeliveryRouteDuration;
}

/// Filter for orders list (matches web: All, Active, Delivered, Cancelled).
enum _OrderFilter { all, active, delivered, cancelled }

/// Orders tab: lists customer orders with filter tabs and card layout (active vs completed styling).
class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key, this.isActive = true});

  /// When false (e.g. IndexedStack off-tab), timers and live polling pause.
  final bool isActive;

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with WidgetsBindingObserver {
  _OrderFilter _filter = _OrderFilter.all;
  Timer? _relativeTimeTimer;
  Timer? _liveOrdersTimer;
  Worker? _localeWorker;
  bool _resumeRefreshPending = false;
  bool _liveTickInFlight = false;

  /// Orders seen while in-progress; keep showing after delivery so the 4-step card does not vanish mid-session.
  final Set<int> _seenActiveOrderIds = <int>{};
  final Set<int> _stickyDeliveredOrderIds = <int>{};

  static const Duration _livePollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncRelativeTimer();
    _syncLivePolling();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted && widget.isActive) setState(() {});
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isActive) return;
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().loadFullOrderHistory();
      }
      if (Get.isRegistered<NotificationAlertController>()) {
        Get.find<NotificationAlertController>().refreshNow();
      }
      unawaited(_tickLiveOrders());
    });
  }

  @override
  void didUpdateWidget(covariant OrdersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncRelativeTimer();
      _syncLivePolling();
      if (widget.isActive) {
        _refreshOrdersFromServer();
        unawaited(_tickLiveOrders());
        if (Get.isRegistered<NotificationAlertController>()) {
          Get.find<NotificationAlertController>().refreshNow();
        }
      }
    }
  }

  void _syncRelativeTimer() {
    _relativeTimeTimer?.cancel();
    _relativeTimeTimer = null;
    if (!widget.isActive) return;
    _relativeTimeTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted && widget.isActive) setState(() {});
    });
  }

  void _syncLivePolling() {
    _liveOrdersTimer?.cancel();
    _liveOrdersTimer = null;
    if (!widget.isActive) return;
    _liveOrdersTimer = Timer.periodic(_livePollInterval, (_) {
      unawaited(_tickLiveOrders());
    });
  }

  Future<void> _tickLiveOrders() async {
    if (!widget.isActive || _liveTickInFlight) return;
    if (!Get.isRegistered<OrderController>()) return;
    _liveTickInFlight = true;
    try {
      await Get.find<OrderController>().refreshActiveOrdersLive();
    } finally {
      _liveTickInFlight = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _relativeTimeTimer?.cancel();
    _liveOrdersTimer?.cancel();
    _localeWorker?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _refreshOrdersFromServer();
      unawaited(_tickLiveOrders());
      if (Get.isRegistered<NotificationAlertController>()) {
        Get.find<NotificationAlertController>().refreshNow();
      }
    }
  }

  void _refreshOrdersFromServer({bool force = false}) {
    if (!Get.isRegistered<OrderController>()) return;
    if (_resumeRefreshPending) return;
    _resumeRefreshPending = true;
    Get.find<OrderController>()
        .loadFullOrderHistory(force: force)
        .whenComplete(() {
      _resumeRefreshPending = false;
    });
  }

  static bool _isActive(String status) {
    final s = normalizeOrderStatusKey(status);
    return s != 'delivered' && s != 'cancelled' && s != 'refunded';
  }

  void _rememberActiveProgress(Iterable<OrderModel> orders) {
    for (final o in orders) {
      if (_isActive(o.status)) {
        _seenActiveOrderIds.add(o.id);
      } else if (normalizeOrderStatusKey(o.status) == 'delivered' &&
          _seenActiveOrderIds.contains(o.id)) {
        _stickyDeliveredOrderIds.add(o.id);
      }
    }
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, _OrderFilter filter) {
    _rememberActiveProgress(orders);
    final List<OrderModel> filtered;
    switch (filter) {
      case _OrderFilter.all:
        filtered = orders.toList();
        break;
      case _OrderFilter.active:
        filtered = orders.where((o) {
          if (_isActive(o.status)) return true;
          return normalizeOrderStatusKey(o.status) == 'delivered' &&
              _stickyDeliveredOrderIds.contains(o.id);
        }).toList();
        break;
      case _OrderFilter.delivered:
        filtered = orders
            .where((o) => normalizeOrderStatusKey(o.status) == 'delivered')
            .toList();
        break;
      case _OrderFilter.cancelled:
        filtered = orders.where((o) {
          final s = normalizeOrderStatusKey(o.status);
          return s == 'cancelled' || s == 'refunded';
        }).toList();
        break;
    }
    return OrderModel.sortedNewestFirst(filtered);
  }

  int _deliveredCountForBanner(List<OrderModel> orders) {
    return orders
        .where((o) => normalizeOrderStatusKey(o.status) == 'delivered')
        .length;
  }

  String _filterLabel(AppLocalizations l10n, _OrderFilter f) {
    switch (f) {
      case _OrderFilter.all:
        return l10n.ordersTabFilterAll;
      case _OrderFilter.active:
        return l10n.ordersTabFilterActive;
      case _OrderFilter.delivered:
        return l10n.ordersTabFilterCompleted;
      case _OrderFilter.cancelled:
        return l10n.ordersTabFilterCancelled;
    }
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final picked = await showModalBottomSheet<_OrderFilter>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final sheetL10n = AppLocalizations.of(ctx)!;
        final sheetH = ctx.pageHorizontalPadding.clamp(16.0, 24.0);
        return Material(
          color: Theme.of(ctx).colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(sheetH, 8, sheetH, 12),
                    child: Text(
                      sheetL10n.ordersTabShowOrders,
                      style: FontHelper.getTextStyle(
                        text: sheetL10n.ordersTabShowOrders,
                        languageCode: languageCode,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _OrdersTabDesign.titleColor(ctx),
                      ),
                    ),
                  ),
                  for (final f in _OrderFilter.values)
                    ListTile(
                      title: Text(
                        _filterLabel(sheetL10n, f),
                        style: FontHelper.getTextStyle(
                          text: _filterLabel(sheetL10n, f),
                          languageCode: languageCode,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check_rounded,
                        color: _filter == f
                            ? _OrdersTabDesign.accentGreen(ctx)
                            : Colors.transparent,
                      ),
                      onTap: () => Navigator.pop(ctx, f),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _filter = picked);
  }

  List<_OrderRow> _orderRows(OrderController ctrl, AppLocalizations l10n) {
    final filtered = _filterOrders(ctrl.orders, _filter);
    final reviewBannerCount = _deliveredCountForBanner(ctrl.orders);
    final rows = <_OrderRow>[];

    if (_filter == _OrderFilter.all && reviewBannerCount > 0) {
      rows.add(const _OrderRow.banner());
    }

    void addOrders(
      Iterable<OrderModel> orders, {
      required bool compactDelivered,
    }) {
      for (final o in orders) {
        final isActive = _isActive(o.status);
        final showTracking = !compactDelivered && isActive;
        rows.add(
          _OrderRow.order(
            o,
            compactDelivered: compactDelivered,
            showLiveTracking: showTracking,
          ),
        );
      }
    }

    switch (_filter) {
      case _OrderFilter.all:
        // Show every order for this customer — active first, then completed, then cancelled.
        final all = OrderModel.sortedNewestFirst(ctrl.orders.toList());
        final active = <OrderModel>[];
        final delivered = <OrderModel>[];
        final cancelled = <OrderModel>[];
        final other = <OrderModel>[];
        for (final o in all) {
          final s = normalizeOrderStatusKey(o.status);
          if (s == 'delivered') {
            delivered.add(o);
          } else if (s == 'cancelled' || s == 'refunded') {
            cancelled.add(o);
          } else if (_isActive(o.status)) {
            active.add(o);
          } else {
            other.add(o);
          }
        }

        void addSection(
          List<OrderModel> list, {
          required bool compactDelivered,
        }) {
          for (final o in list) {
            rows.add(
              _OrderRow.order(
                o,
                compactDelivered: compactDelivered,
                showLiveTracking: _isActive(o.status) && !compactDelivered,
              ),
            );
          }
        }

        if (active.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionActive));
          addSection(active, compactDelivered: false);
        }
        if (delivered.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionCompleted));
          addSection(delivered, compactDelivered: true);
        }
        if (cancelled.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionCancelled));
          addSection(cancelled, compactDelivered: false);
        }
        if (other.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabFilterAll));
          addSection(other, compactDelivered: false);
        }
        break;
      case _OrderFilter.active:
        if (filtered.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionActive));
          addOrders(filtered, compactDelivered: false);
        }
        break;
      case _OrderFilter.delivered:
        if (filtered.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionCompleted));
          addOrders(filtered, compactDelivered: true);
        }
        break;
      case _OrderFilter.cancelled:
        if (filtered.isNotEmpty) {
          rows.add(_OrderRow.section(l10n.ordersTabSectionCancelled));
          addOrders(filtered, compactDelivered: false);
        }
        break;
    }

    if (ctrl.hasMore.value &&
        (_filter == _OrderFilter.all ||
            _filter == _OrderFilter.delivered ||
            _filter == _OrderFilter.cancelled)) {
      rows.add(const _OrderRow.loadMore());
    }

    return rows;
  }

  Widget _buildOrderRow(
    BuildContext context,
    _OrderRow row,
    OrderController ctrl,
    AppLocalizations l10n,
  ) {
    switch (row.kind) {
      case _OrderRowKind.banner:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: _ReviewPromptBanner(
            count: _deliveredCountForBanner(ctrl.orders),
            l10n: l10n,
          ),
        );
      case _OrderRowKind.section:
        return _SectionHeader(title: row.title!);
      case _OrderRowKind.order:
        return _OrderCard(
          key: ValueKey(row.order!.id),
          order: row.order!,
          l10n: l10n,
          compactDelivered: row.compactDelivered,
          showLiveTracking: row.showLiveTracking,
          isTabActive: widget.isActive,
        );
      case _OrderRowKind.loadMore:
        return _LoadMoreFooter(controller: ctrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController(), permanent: true);
    }
    final ctrl = Get.find<OrderController>();
    final languageCode = Get.find<LocaleController>().locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: _OrdersTabDesign.titleColor(context),
          ),
          onPressed: () => _openFilterSheet(context),
          tooltip: l10n.ordersTabFilterTooltip,
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            l10n.myOrders,
            maxLines: 1,
            style: FontHelper.getTextStyle(
              text: l10n.myOrders,
              languageCode: languageCode,
              fontSize: _otCompact(context) ? 17 : 18,
              fontWeight: FontWeight.w700,
              color: _OrdersTabDesign.titleColor(context),
            ),
          ),
        ),

        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh_rounded, color: _OrdersTabDesign.navyTitle.withValues(alpha: 0.85)),
        //     onPressed: () => ctrl.loadOrders(),
        //     tooltip: l10n.retry,
        //   ),
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: Center(
        //       child: Get.isRegistered<AuthController>()
        //           ? Obx(() {
        //               final user = Get.find<AuthController>().user.value;
        //               final avatarUrl = user?.avatar;
        //               final resolved = avatarUrl != null && avatarUrl.isNotEmpty
        //                   ? (avatarUrl.startsWith('http') ? avatarUrl : _absoluteImageUrl(avatarUrl))
        //                   : null;
        //               return CircleAvatar(
        //                 radius: 18,
        //                 backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        //                 backgroundImage:
        //                     resolved != null ? CachedNetworkImageProvider(resolved) : null,
        //                 child: resolved == null
        //                     ? Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20)
        //                     : null,
        //               );
        //             })
        //           : CircleAvatar(
        //               radius: 18,
        //               backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        //               child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
        //             ),
        //     ),
        //   ),
        // ],
      ),
      body: MaxWidthBody(
        child: Obx(() {
          final _ = Get.find<LocaleController>().localeRx.value;
          // Depend on list length and each status so live track/FCM updates rebuild.
          final orderCount = ctrl.orders.length;
          for (final o in ctrl.orders) {
            // ignore: unnecessary_statements
            o.status;
          }
          if (ctrl.isLoading.value &&
              orderCount == 0 &&
              ctrl.error.value.isEmpty) {
            return OrderCardListSkeleton(
              count: 4,
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                4,
                context.pageHorizontalPadding,
                _otListBottomPad(context),
              ),
            );
          }
          if (ctrl.error.value.isNotEmpty && orderCount == 0) {
            return _buildErrorState(context, ctrl, l10n);
          }
          final rows = _orderRows(ctrl, l10n);
          if (rows.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _stickyDeliveredOrderIds.clear();
              _seenActiveOrderIds.clear();
              await ctrl.loadOrders(refresh: true, force: true);
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                4,
                context.pageHorizontalPadding,
                _otListBottomPad(context),
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: rows.length,
              itemBuilder: (context, i) =>
                  _buildOrderRow(context, rows[i], ctrl, l10n),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    OrderController ctrl,
    AppLocalizations l10n,
  ) {
    final h = context.pageHorizontalPadding;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: h, vertical: 16),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: 1),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - t)),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 760),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.88, end: 1),
                    builder: (context, s, _) => Transform.scale(
                      scale: s,
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: _otNarrow(context)
                            ? 52
                            : (_otCompact(context) ? 58 : 64),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(height: _otCompact(context) ? 12 : 16),
                  Text(
                    l10n.cannotReachServer,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Text(
                      ctrl.error.value,
                      key: ValueKey(ctrl.error.value),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: _otCompact(context) ? 12.5 : null,
                      ),
                    ),
                  ),
                  SizedBox(height: _otCompact(context) ? 20 : 24),
                  FilledButton.icon(
                    onPressed: () => ctrl.loadOrders(),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: _otCompact(context) ? 20 : 24,
                    ),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final h = context.pageHorizontalPadding;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: h, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: _otNarrow(context)
                      ? 52
                      : (_otCompact(context) ? 58 : 64),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: _otCompact(context) ? 12 : 16),
                Text(
                  l10n.noOrdersYet,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.orderHistoryHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: _otCompact(context) ? 12.5 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _otCompact(context) ? 20 : 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderListScreen(),
                    ),
                  ),
                  icon: Icon(
                    Icons.restaurant_rounded,
                    size: _otCompact(context) ? 20 : 24,
                  ),
                  label: Text(l10n.browseRestaurants),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewPromptBanner extends StatelessWidget {
  const _ReviewPromptBanner({required this.count, required this.l10n});

  final int count;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final padH = _otCompact(context) ? 12.0 : 14.0;
    final padV = _otCompact(context) ? 10.0 : 12.0;
    final message = l10n.ordersTabReviewsNeeded(count);
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: _OrdersTabDesign.reviewBannerFill(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _OrdersTabDesign.reviewBannerBorder(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _OrdersTabDesign.reviewBannerBorder(
                context,
              ).withValues(alpha: 0.14),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: _OrdersTabDesign.reviewBannerIcon(context),
              size: _otCompact(context) ? 20 : 22,
            ),
            SizedBox(width: _otCompact(context) ? 8 : 10),
            Expanded(
              child: Text(
                message,
                style: FontHelper.getTextStyle(
                  text: message,
                  languageCode: languageCode,
                  fontWeight: FontWeight.w600,
                  color: _OrdersTabDesign.reviewBannerText(context),
                  fontSize: _otCompact(context) ? 13 : 14,
                ).copyWith(height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    return Padding(
      padding: EdgeInsets.only(bottom: _otCompact(context) ? 8 : 10, top: 4),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: _otCompact(context) ? 10 : 12,
          vertical: _otCompact(context) ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: _OrdersTabDesign.sectionTitleBackground(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FontHelper.getTextStyle(
            text: title,
            languageCode: languageCode,
            fontSize: _otCompact(context) ? 12 : 13,
            fontWeight: FontWeight.w800,
            color: _OrdersTabDesign.sectionTitleForeground(context),
          ).copyWith(letterSpacing: 0.6, height: 1.2),
        ),
      ),
    );
  }
}

/// Fetches next page once when appended (pagination for “all” sections).
class _LoadMoreFooter extends StatefulWidget {
  const _LoadMoreFooter({required this.controller});

  final OrderController controller;

  @override
  State<_LoadMoreFooter> createState() => _LoadMoreFooterState();
}

class _LoadMoreFooterState extends State<_LoadMoreFooter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _kick());
  }

  Future<void> _kick() async {
    final c = widget.controller;
    if (!mounted || !c.hasMore.value || c.isLoading.value) return;
    await c.loadOrders(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = widget.controller;
      if (!c.hasMore.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: c.isLoading.value
              ? const SkeletonLoadMoreIndicator()
              : const SizedBox(height: 24),
        ),
      );
    });
  }
}

Future<void> _launchRiderPhone(String? raw) async {
  if (raw == null || raw.isEmpty) return;
  final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: digits);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _openOrderDetail(BuildContext context, OrderModel order) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OrderDetailScreen(orderId: order.id, initialOrder: order),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final curved = CurvedAnimation(parent: animation, curve: curve);
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(curved);
        final fade = Tween<double>(begin: 0, end: 1).animate(curved);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    ),
  );
}

String? _absoluteImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

class _ActiveStatusStyle {
  const _ActiveStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

_ActiveStatusStyle _activeStatusStyle(
  BuildContext context,
  AppLocalizations l10n,
  String status,
) {
  final s = normalizeOrderStatusKey(status);
  final background = _OrdersTabDesign.sectionTitleBackground(context);
  final foreground = _OrdersTabDesign.sectionTitleForeground(context);
  if (s == 'picked_up' || s == 'on_the_way') {
    return _ActiveStatusStyle(
      label: l10n.trackStatusOnTheWay,
      background: background,
      foreground: foreground,
      icon: Icons.pedal_bike_rounded,
    );
  }
  if (s == 'confirmed') {
    return _ActiveStatusStyle(
      label: l10n.trackStatusPreparing,
      background: background,
      foreground: foreground,
      icon: Icons.local_fire_department_rounded,
    );
  }
  if (s == 'preparing' || s == 'ready' || s == 'pending') {
    return _ActiveStatusStyle(
      label: s == 'pending'
          ? l10n.trackStatusPending
          : l10n.trackStatusPreparing,
      background: background,
      foreground: foreground,
      icon: s == 'pending'
          ? Icons.schedule_rounded
          : Icons.local_fire_department_rounded,
    );
  }
  return _ActiveStatusStyle(
    label: l10n.active,
    background: background,
    foreground: foreground,
    icon: Icons.schedule_rounded,
  );
}

String _itemsSummary(AppLocalizations l10n, OrderModel order) {
  final items = order.items;
  if (items != null && items.isNotEmpty) {
    return items.take(3).map((e) => e.displayName).join(' · ');
  }
  final count = order.effectiveItemCount;
  if (count > 0) {
    return l10n.itemsCountInCategory('$count');
  }
  return l10n.tapViewDetailsForItems;
}

String _resolvedOrderTrackStatus(OrderModel order) {
  final timeline = order.timeline.map((e) => e.status);
  return resolveOrderTrackStatus(order.status, timeline);
}

/// Track poll returns a summary without line items — keep richer fields from the list/detail payload.
OrderModel _mergeOrderTrackingData(OrderModel base, OrderModel update) {
  final mergedItems = (update.items != null && update.items!.isNotEmpty)
      ? update.items
      : base.items;
  final count = update.effectiveItemCount > 0
      ? update.itemsCount
      : base.itemsCount;
  final mergedTimeline = update.timeline.isNotEmpty
      ? update.timeline
      : base.timeline;
  final mergedStatus = normalizeOrderStatusKey(
    resolveOrderTrackStatus(
      mergeOrderStatus(base.status, update.status),
      mergedTimeline.map((e) => e.status),
    ),
  );

  return update.copyWith(
    status: mergedStatus,
    items: mergedItems,
    itemsCount: count ?? mergedItems?.length,
    placedAt: update.effectivePlacedAt ?? base.effectivePlacedAt,
    timeline: mergedTimeline,
    restaurantImage: update.restaurantImage ?? base.restaurantImage,
    restaurantName: update.restaurantName ?? base.restaurantName,
    restaurantNameFa: update.restaurantNameFa ?? base.restaurantNameFa,
    restaurantNamePs: update.restaurantNamePs ?? base.restaurantNamePs,
    restaurantLocalizedName:
        update.restaurantLocalizedName ?? base.restaurantLocalizedName,
    avgPreparationTime: update.avgPreparationTime ?? base.avgPreparationTime,
    estimatedPrepTime: update.estimatedPrepTime ?? base.estimatedPrepTime,
    deliveryTime: update.deliveryTime ?? base.deliveryTime,
    estimatedDeliveryTime: isUsableEstimatedDeliveryTime(update.estimatedDeliveryTime)
        ? update.estimatedDeliveryTime
        : (isUsableEstimatedDeliveryTime(base.estimatedDeliveryTime)
            ? base.estimatedDeliveryTime
            : null),
    subtotal: update.subtotal ?? base.subtotal,
    deliveryFee: update.deliveryFee ?? base.deliveryFee,
    paymentMethod: update.paymentMethod ?? base.paymentMethod,
    paymentStatus: _mergedPaymentStatus(base, update),
    driver: update.driver ?? base.driver,
  );
}

String? _mergedPaymentStatus(OrderModel base, OrderModel update) {
  final method = update.paymentMethod ?? base.paymentMethod;
  final status = update.status;
  final paymentStatus = update.paymentStatus ?? base.paymentStatus;
  final merged = update.copyWith(
    paymentMethod: method,
    paymentStatus: paymentStatus,
    status: status,
  );
  if (OrdersL10n.isCashOnDelivery(method)) {
    return OrdersL10n.effectivePaymentStatus(merged);
  }
  return paymentStatus;
}

bool _isRiderEnRoutePhase(String status) {
  final seven = orderTrackStepIndexFromStatus(status);
  return seven >= kOrderTrackPickedUpStepIndex && seven < 6;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    super.key,
    required this.order,
    required this.l10n,
    this.compactDelivered = false,
    this.showLiveTracking = false,
    this.isTabActive = true,
  });

  final OrderModel order;
  final AppLocalizations l10n;
  final bool compactDelivered;
  final bool showLiveTracking;
  final bool isTabActive;

  bool get _isDelivered => normalizeOrderStatusKey(order.status) == 'delivered';
  bool get _isCancelled {
    final s = normalizeOrderStatusKey(order.status);
    return s == 'cancelled' || s == 'refunded';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCancelled) {
      return _buildSimpleCard(
        context,
        chipLabel: l10n.orderStatusCancelled,
        chipColor: _OrdersTabDesign.sectionTitleBackground(context),
        chipLabelColor: _OrdersTabDesign.sectionTitleForeground(context),
        illustration: const _OrderCancelledIllustration(),
      );
    }
    if (_isDelivered) {
      return _buildDeliveredCard(context);
    }
    return _buildActiveCard(context);
  }

  Widget _buildDeliveredCard(BuildContext context) {
    final logo = _absoluteImageUrl(order.restaurantImage);
    final thumb = context.layoutScale(56);
    final surface = _OrdersTabDesign.cardSurface(context);
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final restaurantTitle = _orderRestaurantTitle(l10n, order);
    final placedLine = orderPlacedLine(context, order.effectivePlacedAt);
    final itemsLine = _itemsSummary(l10n, order);
    final pad = compactDelivered
        ? _otCardPadTight(context)
        : _otCardPad(context);
    final stackActions = _otCompact(context);

    return Padding(
      padding: EdgeInsets.only(bottom: _otCompact(context) ? 12 : 16),
      child: Material(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openOrderDetail(context, order),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _OrdersTabDesign.cardShadow(context),
              color: surface,
            ),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderTrackingIllustration(status: order.status, animate: false),
                SizedBox(height: _otCompact(context) ? 10 : 12),
                _FourStepDeliveryProgress(status: order.status, l10n: l10n),
                SizedBox(height: _otCompact(context) ? 12 : 14),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _otCompact(context) ? 8 : 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _OrdersTabDesign.sectionTitleBackground(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: _otCompact(context) ? 15 : 16,
                              color: _OrdersTabDesign.sectionTitleForeground(
                                context,
                              ),
                            ),
                            SizedBox(width: _otCompact(context) ? 4 : 6),
                            Flexible(
                              child: Text(
                                l10n.trackStatusDelivered,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontHelper.getTextStyle(
                                  text: l10n.trackStatusDelivered,
                                  languageCode: languageCode,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _OrdersTabDesign.sectionTitleForeground(
                                        context,
                                      ),
                                  fontSize: _otCompact(context) ? 12.5 : 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppCurrency.format(order.total, decimalDigits: 2),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: _otCompact(context) ? 15 : 17,
                          color: _OrdersTabDesign.totalAccent(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _otCompact(context) ? 10 : 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logo != null
                          ? AppNetworkImage(
                              imageUrl: logo,
                              width: thumb,
                              height: thumb,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  _imagePlaceholder(context, thumb),
                              errorWidget: (_, __, ___) =>
                                  _imagePlaceholder(context, thumb),
                            )
                          : _imagePlaceholder(context, thumb),
                    ),
                    SizedBox(width: _otCompact(context) ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantTitle,
                            style: FontHelper.getTextStyle(
                              text: restaurantTitle,
                              languageCode: languageCode,
                              fontWeight: FontWeight.w700,
                              fontSize: _otCompact(context) ? 15 : 16,
                              color: _OrdersTabDesign.titleColor(context),
                            ),
                          ),
                          if (placedLine.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              placedLine,
                              style: FontHelper.getTextStyle(
                                text: placedLine,
                                languageCode: languageCode,
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            itemsLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: itemsLine,
                              languageCode: languageCode,
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (OrdersL10n.isCashOnDelivery(order.paymentMethod)) ...[
                  SizedBox(height: _otCompact(context) ? 8 : 10),
                  Text(
                    '${l10n.paymentStatusDetail}: ${OrdersL10n.paymentStatusLabel(l10n, OrdersL10n.effectivePaymentStatus(order))}',
                    style: FontHelper.getTextStyle(
                      text: OrdersL10n.paymentStatusLabel(
                        l10n,
                        OrdersL10n.effectivePaymentStatus(order),
                      ),
                      languageCode: languageCode,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                SizedBox(height: _otCompact(context) ? 12 : 16),
                if (stackActions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderReviewScreen(
                                orderId: order.id,
                                order: order,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: _OrdersTabDesign.onAccentFilled(
                            context,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: _otCompact(context) ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          Icons.star_rounded,
                          size: _otCompact(context) ? 18 : 20,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.leaveReview,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => _openOrderDetail(context, order),
                        style: _OrdersTabDesign.outlinedSecondary(
                          context,
                          padding: EdgeInsets.symmetric(
                            vertical: _otCompact(context) ? 12 : 14,
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.viewDetails),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderReviewScreen(
                                  orderId: order.id,
                                  order: order,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: _OrdersTabDesign.onAccentFilled(
                              context,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.star_rounded, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.leaveReview,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openOrderDetail(context, order),
                          style: _OrdersTabDesign.outlinedSecondary(context),
                          child: Text(
                            AppLocalizations.of(context)!.viewDetails,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleCard(
    BuildContext context, {
    required String chipLabel,
    required Color chipColor,
    Color? chipLabelColor,
    Widget? illustration,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.only(bottom: _otCompact(context) ? 12 : 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(_otCardPad(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (illustration != null) ...[
              illustration,
              SizedBox(height: _otCompact(context) ? 10 : 12),
            ],
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      chipLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: chipLabelColor ?? cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppCurrency.format(order.total, decimalDigits: 2),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: _otCompact(context) ? 15 : null,
                      color: _OrdersTabDesign.totalAccent(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _orderRestaurantTitle(l10n, order),
              style: FontHelper.getTextStyle(
                text: _orderRestaurantTitle(l10n, order),
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            _orderPrepTimeRow(
              context,
              order,
              languageCode: Get.find<LocaleController>().locale.languageCode,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openOrderDetail(context, order),
                style: _OrdersTabDesign.outlinedSecondary(context),
                child: Text(AppLocalizations.of(context)!.viewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context) {
    final style = _activeStatusStyle(context, l10n, order.status);
    final logo = _absoluteImageUrl(order.restaurantImage);
    final thumb = context.layoutScale(56);
    final surface = _OrdersTabDesign.cardSurface(context);
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final restaurantTitle = _orderRestaurantTitle(l10n, order);
    final placedLine = orderPlacedLine(context, order.effectivePlacedAt);
    final deliveryLabel = _activeOrderDeliveryChipLabel(context, order);

    final headerPadH = _otCardPad(context);
    final headerPadV = _otCompact(context) ? 10.0 : 12.0;
    final compactHeader = _otCompact(context);

    return Padding(
      padding: EdgeInsets.only(bottom: _otCompact(context) ? 12 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _OrdersTabDesign.cardShadow(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: headerPadH,
                vertical: headerPadV,
              ),
              color: style.background,
              child: compactHeader
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(style.icon, size: 20, color: style.foreground),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                style.label,
                                style: FontHelper.getTextStyle(
                                  text: style.label,
                                  languageCode: languageCode,
                                  fontWeight: FontWeight.w800,
                                  color: style.foreground,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 17,
                              color: style.foreground.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                deliveryLabel,
                                style: FontHelper.getTextStyle(
                                  text: deliveryLabel,
                                  languageCode: languageCode,
                                  fontWeight: FontWeight.w700,
                                  color: style.foreground,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(style.icon, size: 22, color: style.foreground),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            style.label,
                            style: FontHelper.getTextStyle(
                              text: style.label,
                              languageCode: languageCode,
                              fontWeight: FontWeight.w800,
                              color: style.foreground,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: style.foreground.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            deliveryLabel,
                            textAlign: TextAlign.end,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: deliveryLabel,
                              languageCode: languageCode,
                              fontWeight: FontWeight.w700,
                              color: style.foreground,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(_otCardPad(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: logo != null
                            ? AppNetworkImage(
                                imageUrl: logo,
                                width: thumb,
                                height: thumb,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    _imagePlaceholder(context, thumb),
                                errorWidget: (_, __, ___) =>
                                    _imagePlaceholder(context, thumb),
                              )
                            : _imagePlaceholder(context, thumb),
                      ),
                      SizedBox(width: _otCompact(context) ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurantTitle,
                              style: FontHelper.getTextStyle(
                                text: restaurantTitle,
                                languageCode: languageCode,
                                fontWeight: FontWeight.w800,
                                fontSize: _otCompact(context) ? 16 : 17,
                                color: _OrdersTabDesign.titleColor(context),
                              ),
                            ),
                            if (placedLine.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                placedLine,
                                style: FontHelper.getTextStyle(
                                  text: placedLine,
                                  languageCode: languageCode,
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            _orderPrepTimeRow(
                              context,
                              order,
                              languageCode: languageCode,
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.sizeOf(context).width *
                              (_otCompact(context) ? 0.32 : 0.28),
                        ),
                        child: Text(
                          AppCurrency.format(order.total, decimalDigits: 2),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: _otCompact(context) ? 15 : 17,
                            color: _OrdersTabDesign.totalAccent(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _otCompact(context) ? 8 : 10),
                  Text(
                    _itemsSummary(l10n, order),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontHelper.getTextStyle(
                      text: _itemsSummary(l10n, order),
                      languageCode: languageCode,
                      fontSize: _otCompact(context) ? 12.5 : 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ).copyWith(height: 1.35),
                  ),
                  if (showLiveTracking) ...[
                    SizedBox(height: _otCompact(context) ? 12 : 14),
                    _ActiveOrderTrackingPanel(
                      initialOrder: order,
                      l10n: l10n,
                      isActive: isTabActive,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context, double size) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded, color: cs.onSurfaceVariant),
    );
  }
}

/// Illustration + 4-step progress + driver + actions; refreshes via [OrderController.trackOrder] like the full track screen.
class _ActiveOrderTrackingPanel extends StatefulWidget {
  const _ActiveOrderTrackingPanel({
    required this.initialOrder,
    required this.l10n,
    this.isActive = true,
  });

  final OrderModel initialOrder;
  final AppLocalizations l10n;
  final bool isActive;

  @override
  State<_ActiveOrderTrackingPanel> createState() =>
      _ActiveOrderTrackingPanelState();
}

class _ActiveOrderTrackingPanelState extends State<_ActiveOrderTrackingPanel> {
  late OrderModel _tracked;
  Timer? _pollTimer;
  Worker? _ordersWorker;

  String get _trackStatus => _resolvedOrderTrackStatus(_tracked);

  @override
  void initState() {
    super.initState();
    _tracked = widget.initialOrder;
    if (Get.isRegistered<OrderController>()) {
      _ordersWorker = ever(
        Get.find<OrderController>().orders,
        (_) => _syncFromOrderList(),
      );
    }
    if (widget.isActive) {
      _loadDetails();
      // Live status/driver updates come from OrdersTab → refreshActiveOrdersLive.
      // Keep a slower fallback poll in case the tab timer is paused.
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!widget.isActive) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _syncFromOrderList() {
    if (!mounted || !Get.isRegistered<OrderController>()) return;
    final latest = Get.find<OrderController>().orders.firstWhereOrNull(
      (e) => e.id == widget.initialOrder.id,
    );
    if (latest == null) return;
    final merged = _mergeOrderTrackingData(_tracked, latest);
    if (!_trackingSnapshotChanged(_tracked, merged)) return;
    setState(() => _tracked = merged);
  }

  @override
  void dispose() {
    _stopPolling();
    _ordersWorker?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ActiveOrderTrackingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialOrder.id != widget.initialOrder.id) {
      setState(() => _tracked = widget.initialOrder);
      if (widget.isActive) {
        _loadDetails();
        _startPolling();
      }
      return;
    }
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _loadDetails();
        _startPolling();
      } else {
        _stopPolling();
      }
    }
    final merged = _mergeOrderTrackingData(_tracked, widget.initialOrder);
    if (!_trackingSnapshotChanged(_tracked, merged)) return;
    setState(() => _tracked = merged);
  }

  Future<void> _loadDetails() async {
    if (!Get.isRegistered<OrderController>()) return;
    final ctrl = Get.find<OrderController>();
    final detail = await ctrl.getOrderById(widget.initialOrder.id);
    if (!mounted || detail == null) return;
    _applyTrackedUpdate(ctrl, detail);
  }

  Future<void> _poll() async {
    if (!widget.isActive) return;
    if (!Get.isRegistered<OrderController>()) return;
    final ctrl = Get.find<OrderController>();

    // Track endpoint covers status + live driver; avoid double fetch every poll.
    final tracked = await ctrl.trackOrder(widget.initialOrder.id);
    if (!mounted || tracked == null) return;

    final justDelivered =
        normalizeOrderStatusKey(_tracked.status) != 'delivered' &&
        normalizeOrderStatusKey(tracked.status) == 'delivered';
    if (justDelivered) {
      _pollTimer?.cancel();
    }

    _applyTrackedUpdate(ctrl, tracked);
  }

  void _applyTrackedUpdate(OrderController ctrl, OrderModel incoming) {
    final merged = _mergeOrderTrackingData(_tracked, incoming);
    if (!_trackingSnapshotChanged(_tracked, merged)) return;

    final statusOrTimelineChanged =
        normalizeOrderStatusKey(merged.status) !=
            normalizeOrderStatusKey(_tracked.status) ||
        merged.timeline.length != _tracked.timeline.length ||
        merged.estimatedPrepTime != _tracked.estimatedPrepTime ||
        merged.estimatedDeliveryTime != _tracked.estimatedDeliveryTime ||
        merged.driver?.phone != _tracked.driver?.phone;

    setState(() => _tracked = merged);

    // Skip list-wide rebuilds on GPS-only ticks (panel keeps local state).
    if (!statusOrTimelineChanged) return;

    final existing = ctrl.orders.firstWhereOrNull((e) => e.id == merged.id);
    ctrl.upsertOrder(
      existing == null ? merged : _mergeOrderTrackingData(existing, merged),
    );
  }

  bool _trackingSnapshotChanged(OrderModel previous, OrderModel next) {
    return normalizeOrderStatusKey(next.status) !=
            normalizeOrderStatusKey(previous.status) ||
        next.timeline.length != previous.timeline.length ||
        next.driver?.latitude != previous.driver?.latitude ||
        next.driver?.longitude != previous.driver?.longitude ||
        next.driver?.phone != previous.driver?.phone ||
        next.estimatedPrepTime != previous.estimatedPrepTime ||
        next.estimatedDeliveryTime != previous.estimatedDeliveryTime ||
        next.deliveryTime != previous.deliveryTime ||
        next.avgPreparationTime != previous.avgPreparationTime;
  }

  @override
  Widget build(BuildContext context) {
    final gap = _otCompact(context) ? 12.0 : 14.0;
    final actionGap = _otCompact(context) ? 12.0 : 16.0;
    final stackRiderActions = _otCompact(context);
    final btnV = _otCompact(context) ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _OrderTrackingVisualSection(
          status: _trackStatus,
          l10n: widget.l10n,
          animate: widget.isActive,
        ),
        if (isUsableEstimatedDeliveryTime(_tracked.estimatedDeliveryTime) ||
            _tracked.deliveryTime?.trim().isNotEmpty == true ||
            (_tracked.estimatedPrepTime != null &&
                _tracked.estimatedPrepTime! > 0)) ...[
          SizedBox(height: gap),
          _OrdersTabEtaBanner(order: _tracked, l10n: widget.l10n),
        ],
        if (orderTrackStepIndexFromStatus(_trackStatus) >=
            kOrderTrackPickedUpStepIndex) ...[
          SizedBox(height: gap),
          _OrdersTabDriverCard(order: _tracked, l10n: widget.l10n),
        ],
        if (_isRiderEnRoutePhase(_trackStatus) &&
            _tracked.driver?.phone != null &&
            _tracked.driver!.phone!.trim().isNotEmpty) ...[
          SizedBox(height: actionGap),
          if (stackRiderActions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => _launchRiderPhone(_tracked.driver!.phone),
                  icon: Icon(
                    Icons.phone_rounded,
                    size: 20,
                    color: _OrdersTabDesign.onAccentFilled(context),
                  ),
                  label: Text(
                    widget.l10n.callDriver,
                    style: FontHelper.getTextStyle(
                      text: widget.l10n.callDriver,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontWeight: FontWeight.w700,
                      color: _OrdersTabDesign.onAccentFilled(context),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: btnV),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _openOrderDetail(context, _tracked),
                  style: _OrdersTabDesign.outlinedSecondary(
                    context,
                    padding: EdgeInsets.symmetric(vertical: btnV),
                  ),
                  child: Text(
                    widget.l10n.viewDetails,
                    style: FontHelper.getTextStyle(
                      text: widget.l10n.viewDetails,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _launchRiderPhone(_tracked.driver!.phone),
                    icon: Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: _OrdersTabDesign.onAccentFilled(context),
                    ),
                    label: Text(
                      widget.l10n.callDriver,
                      style: FontHelper.getTextStyle(
                        text: widget.l10n.callDriver,
                        languageCode:
                            Get.find<LocaleController>().locale.languageCode,
                        fontWeight: FontWeight.w700,
                        color: _OrdersTabDesign.onAccentFilled(context),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openOrderDetail(context, _tracked),
                    style: _OrdersTabDesign.outlinedSecondary(context),
                    child: Text(
                      widget.l10n.viewDetails,
                      style: FontHelper.getTextStyle(
                        text: widget.l10n.viewDetails,
                        languageCode:
                            Get.find<LocaleController>().locale.languageCode,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ] else ...[
          SizedBox(height: actionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openOrderDetail(context, _tracked),
              style: _OrdersTabDesign.outlinedSecondary(
                context,
                padding: EdgeInsets.symmetric(vertical: btnV),
              ),
              child: Text(
                widget.l10n.viewDetails,
                style: FontHelper.getTextStyle(
                  text: widget.l10n.viewDetails,
                  languageCode:
                      Get.find<LocaleController>().locale.languageCode,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrdersTabEtaBanner extends StatelessWidget {
  const _OrdersTabEtaBanner({required this.order, required this.l10n});

  final OrderModel order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final p = _otCompact(context) ? 12.0 : 14.0;
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final dark = t.brightness == Brightness.dark;
    final fill = dark
        ? cs.primaryContainer.withValues(alpha: 0.45)
        : AppColors.primaryLight.withValues(alpha: 0.12);
    final fg = dark ? cs.onPrimaryContainer : AppColors.primaryLight;
    return Container(
      padding: EdgeInsets.all(p),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: dark ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.estimatedDeliveryTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg.withValues(alpha: 0.9),
              fontSize: _otCompact(context) ? 11.5 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _ordersTabBannerDeliveryText(context, order),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: _ordersTabBannerDeliveryText(context, order),
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: _otCompact(context) ? 15 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// GIF + 4-step bar; isolated so illustration decode issues never hide the steps.
class _OrderTrackingVisualSection extends StatelessWidget {
  const _OrderTrackingVisualSection({
    required this.status,
    required this.l10n,
    this.animate = true,
  });

  final String status;
  final AppLocalizations l10n;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final gap = _otCompact(context) ? 12.0 : 14.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: _OrderTrackingIllustration(status: status, animate: animate),
        ),
        SizedBox(height: gap),
        _FourStepDeliveryProgress(status: status, l10n: l10n),
      ],
    );
  }
}

/// Four milestones matching the reference UI (placed → preparing → on the way → delivered).
class _FourStepDeliveryProgress extends StatelessWidget {
  const _FourStepDeliveryProgress({required this.status, required this.l10n});

  final String status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final st = status;
    final labels = [
      l10n.trackStatusPending,
      l10n.trackStatusPreparing,
      l10n.trackStatusOnTheWay,
      l10n.trackStatusDelivered,
    ];
    final current = fourStepIndexFromOrderStatus(st);

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var step = 0; step < 4; step++) ...[
            if (step > 0)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: current >= step
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.topCenter,
                child: _FourStepNode(
                  step: step,
                  label: labels[step],
                  status: st,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FourStepNode extends StatelessWidget {
  const _FourStepNode({
    required this.step,
    required this.label,
    required this.status,
  });

  final int step;
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final delivered = normalizeOrderStatusKey(status) == 'delivered';
    final done = fourStepNodeDone(step, status);
    final current = fourStepNodeCurrent(step, status);
    final past = delivered || (done && !current);
    final highlight = current || past;

    final double size = current ? 34.0 : 28.0;
    final cs = Theme.of(context).colorScheme;
    final bg = past || current ? cs.primary : cs.outlineVariant;
    final onCircle = past || current ? cs.onPrimary : cs.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: current
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: past
                ? Icon(
                    Icons.check_rounded,
                    color: onCircle,
                    size: current ? 20 : 16,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: onCircle,
                      fontWeight: FontWeight.w800,
                      fontSize: current ? 14 : 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight ? cs.onSurface : cs.onSurfaceVariant,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

const String _orderCancelledIllustrationAsset =
    'assets/gif/Application Cancel Illutoration-01.png';

({String gif, String png}) _orderTrackingAssets(int fourStepIndex) {
  switch (fourStepIndex.clamp(0, 3)) {
    case 1:
      return (gif: 'assets/gif/sine-2-1.gif', png: 'assets/gif/sine-2-1.png');
    case 2:
      return (gif: 'assets/gif/sine-3.gif', png: 'assets/gif/sine-3.png');
    case 3:
      return (gif: 'assets/gif/sine-4.gif', png: 'assets/gif/sine-4.png');
    case 0:
    default:
      return (gif: 'assets/gif/sine-1.gif', png: 'assets/gif/sine-1.png');
  }
}

IconData _orderTrackingStepIcon(int fourStepIndex) {
  switch (fourStepIndex.clamp(0, 3)) {
    case 1:
      return Icons.restaurant_rounded;
    case 2:
      return Icons.delivery_dining_rounded;
    case 3:
      return Icons.home_rounded;
    case 0:
    default:
      return Icons.receipt_long_rounded;
  }
}

/// Cancelled-order illustration shown above the order summary card.
class _OrderCancelledIllustration extends StatelessWidget {
  const _OrderCancelledIllustration();

  @override
  Widget build(BuildContext context) {
    final height = _otCompact(context) ? 140.0 : 168.0;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outline.withValues(alpha: dark ? 0.65 : 0.55),
          width: 1.5,
        ),
        color: dark ? cs.surfaceContainerLow : const Color(0xFFF7F8FA),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.5),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Image.asset(
            _orderCancelledIllustrationAsset,
            width: double.infinity,
            height: height,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: dark ? cs.surfaceContainerLow : const Color(0xFFF7F8FA),
              child: Icon(
                Icons.cancel_outlined,
                color: cs.onSurfaceVariant,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Per-step GIF above the 4-step bar. Uses [Gif] with PNG fallback so all steps stay visible on mobile.
class _OrderTrackingIllustration extends StatefulWidget {
  const _OrderTrackingIllustration({
    required this.status,
    this.animate = true,
  });

  final String status;
  final bool animate;

  @override
  State<_OrderTrackingIllustration> createState() =>
      _OrderTrackingIllustrationState();
}

class _OrderTrackingIllustrationState
    extends State<_OrderTrackingIllustration> {
  @override
  Widget build(BuildContext context) {
    final height = _otCompact(context) ? 148.0 : 172.0;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final step = fourStepIndexFromOrderStatus(widget.status);
    final assets = _orderTrackingAssets(step);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (MediaQuery.sizeOf(context).width * dpr * 0.85)
        .round()
        .clamp(200, 480);
    final cacheH = (height * dpr * 0.85).round().clamp(140, 360);

    Widget pngFallback({bool showIcon = false}) => Image.asset(
      assets.png,
      width: double.infinity,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      cacheWidth: cacheW,
      cacheHeight: cacheH,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: dark ? cs.surfaceContainerLow : const Color(0xFFF7F8FA),
        child: Center(
          child: Icon(
            showIcon
                ? _orderTrackingStepIcon(step)
                : Icons.image_not_supported_outlined,
            size: _otCompact(context) ? 52 : 60,
            color: cs.primary,
          ),
        ),
      ),
    );

    Widget illustrationBody() {
      final delivered = normalizeOrderStatusKey(widget.status) == 'delivered';
      // Prefer static PNG when off-tab / completed — avoids continuous GIF decode.
      if (!widget.animate || delivered) {
        return pngFallback();
      }
      return Gif(
        key: ValueKey(assets.gif),
        image: AssetImage(assets.gif),
        autostart: Autostart.loop,
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        useCache: true,
        placeholder: (context) => pngFallback(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outline.withValues(alpha: dark ? 0.65 : 0.55),
          width: 1.5,
        ),
        color: dark ? cs.surfaceContainerLow : const Color(0xFFF7F8FA),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.5),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: illustrationBody(),
        ),
      ),
    );
  }
}

/// Driver block aligned with [OrderTrackScreen] `_buildDriverCard`.
class _OrdersTabDriverCard extends StatelessWidget {
  const _OrdersTabDriverCard({required this.order, required this.l10n});

  final OrderModel order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final driver = order.driver;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    final avatarSize = context.layoutScale(52);

    final pad = _otCardPadTight(context);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.yourDriver,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: _otCompact(context) ? 16 : null,
                  ),
                ),
              ),
              if (driver != null &&
                  driver.latitude != null &&
                  driver.longitude != null)
                Builder(
                  builder: (context) {
                    final cs = Theme.of(context).colorScheme;
                    final live = cs.primary;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: live.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: live,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.trackDriverLive,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: live,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (driver != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  child:
                      driver.avatarUrl != null && driver.avatarUrl!.isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: driver.avatarUrl!.startsWith('http')
                              ? driver.avatarUrl!
                              : '$base${driver.avatarUrl}',
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _tabDriverPlaceholder(
                            context,
                            driver.name,
                            avatarSize,
                          ),
                          errorWidget: (_, __, ___) => _tabDriverPlaceholder(
                            context,
                            driver.name,
                            avatarSize,
                          ),
                        )
                      : _tabDriverPlaceholder(context, driver.name, avatarSize),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (driver.phone != null && driver.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SelectableText(
                          driver.phone!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                        ),
                      ],
                      if (driver.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                driver.rating!.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (driver.vehicleType != null ||
                          driver.vehiclePlate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${driver.vehicleType ?? l10n.vehicleDefault} ${driver.vehiclePlate ?? ''}'
                              .trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: context.layoutScale(56),
                      height: context.layoutScale(56),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_search_rounded,
                        size: context.layoutScale(28),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.lookingForDriver,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _tabDriverPlaceholder(BuildContext context, String name, double size) {
  final cs = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: cs.primaryContainer.withValues(alpha: dark ? 0.45 : 0.85),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: cs.onPrimaryContainer,
        ),
      ),
    ),
  );
}
