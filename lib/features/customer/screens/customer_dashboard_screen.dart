import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../../orders/order_track_shared.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../support/screens/support_tickets_screen.dart';
import '../../restaurants/screens/restaurant_list_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Customer dashboard: welcome, stats, quick actions, recent orders (parity with web).
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late List<Animation<double>> _animations;
  Worker? _localeWorker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) setState(() {});
      });
    }
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animations = List.generate(12, (i) {
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          (i * 0.04).clamp(0.0, 0.6),
          (0.15 + i * 0.04).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
    _entranceController.forward();
  }

  @override
  void dispose() {
    _localeWorker?.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  String get _languageCode => Get.find<LocaleController>().locale.languageCode;

  TextStyle _textStyle(
    String text, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return FontHelper.getTextStyle(
      text: text,
      languageCode: _languageCode,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController());
    }
    final orderCtrl = Get.find<OrderController>();
    final hPad = context.pageHorizontalPadding;
    final bottomPad = MediaQuery.paddingOf(context).bottom + (_compact(context) ? 20.0 : 24.0);
    final compact = _compact(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: () => orderCtrl.loadOrders(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, compact ? 10 : 12, hPad, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.chevron_left_rounded, size: compact ? 22 : 24),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
                          ),
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dashboard,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _textStyle(
                                  l10n.dashboard,
                                  fontSize: compact ? 20 : 22,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.customerDashboardSubtitle,
                                style: _textStyle(
                                  l10n.customerDashboardSubtitle,
                                  fontSize: compact ? 12 : 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ).copyWith(height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Obx(() {
                      if (Get.isRegistered<LocaleController>()) {
                        final _ = Get.find<LocaleController>().localeRx.value;
                      }
                      final orders = orderCtrl.orders;
                      final totalOrders = orders.length;
                      final activeOrders = orders
                          .where((o) =>
                              !_isTerminal(o.status))
                          .length;
                      final totalSpent = orders
                          .where((o) =>
                              o.status.toLowerCase() == 'delivered')
                          .fold<double>(0, (s, o) => s + o.total);
                      final openTickets = 0; // TODO: from tickets when available
                      return _buildStats(
                        context,
                        l10n: l10n,
                        totalOrders: totalOrders,
                        activeOrders: activeOrders,
                        totalSpent: totalSpent,
                        openTickets: openTickets,
                        animIndex: 0,
                      );
                    }),
                    SizedBox(height: compact ? 16 : 20),
                    _buildQuickActions(context, l10n),
                    SizedBox(height: compact ? 20 : 24),
                    _buildRecentOrdersHeader(context, l10n),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (Get.isRegistered<LocaleController>()) {
                        final _ = Get.find<LocaleController>().localeRx.value;
                      }
                      return _buildRecentOrders(context, orderCtrl, l10n);
                    }),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTerminal(String status) {
    final s = status.toLowerCase();
    return s == 'delivered' || s == 'cancelled' || s == 'refunded';
  }

  Widget _animated(int index, Widget child) {
    if (index >= _animations.length) return child;
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animations[index].value)),
          child: Opacity(
            opacity: _animations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildStats(
    BuildContext context, {
    required AppLocalizations l10n,
    required int totalOrders,
    required int activeOrders,
    required double totalSpent,
    required int openTickets,
    required int animIndex,
  }) {
    final compact = _compact(context);
    final narrow = _narrow(context);
    final gap = compact ? 10.0 : 12.0;
    final ratio = narrow ? 1.32 : (compact ? 1.4 : 1.5);
    final box = narrow ? 40.0 : (compact ? 44.0 : 48.0);
    final emojiSz = narrow ? 20.0 : (compact ? 22.0 : 24.0);
    final pad = compact ? 12.0 : 16.0;

    final items = [
      (
        _StatItem(
          '📦',
          formatAppInteger(context, totalOrders),
          l10n.customerDashboardTotalOrders,
          AppColors.primary.withValues(alpha: 0.12),
        )
      ),
      (
        _StatItem(
          '🕐',
          formatAppInteger(context, activeOrders),
          l10n.customerDashboardActiveOrders,
          Colors.blue.withValues(alpha: 0.12),
        )
      ),
      (
        _StatItem(
          '💰',
          AppCurrency.formatLocalized(context, totalSpent, decimalDigits: 0),
          l10n.customerDashboardTotalSpent,
          Colors.green.withValues(alpha: 0.12),
        )
      ),
      (
        _StatItem(
          '🎫',
          formatAppInteger(context, openTickets),
          l10n.customerDashboardOpenTickets,
          Colors.red.withValues(alpha: 0.12),
        )
      ),
    ];
    return _animated(
      animIndex,
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: ratio,
        children: items
            .map((e) => Container(
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: box,
                        height: box,
                        decoration: BoxDecoration(
                          color: e.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(e.emoji, style: TextStyle(fontSize: emojiSz)),
                      ),
                      SizedBox(width: compact ? 10 : 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value,
                              style: _textStyle(
                                e.value,
                                fontSize: compact ? 15 : 16,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.label,
                              style: _textStyle(
                                e.label,
                                fontSize: compact ? 11.5 : 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final actions = [
      (_QuickAction(Icons.restaurant_rounded, l10n.customerDashboardOrderFood, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
        );
      })),
      (_QuickAction(Icons.receipt_long_rounded, l10n.myOrders, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderListScreen()),
        );
      })),
      (_QuickAction(Icons.favorite_rounded, l10n.favorites, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        );
      })),
      (_QuickAction(Icons.support_agent_rounded, l10n.support, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SupportTicketsScreen()),
        );
      })),
    ];
    final compact = _compact(context);
    final narrow = _narrow(context);
    final gap = compact ? 10.0 : 12.0;
    final ratio = narrow ? 1.22 : (compact ? 1.3 : 1.4);
    final iconSz = narrow ? 28.0 : (compact ? 30.0 : 32.0);
    final pad = compact ? 12.0 : 16.0;

    return _animated(
      1,
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: ratio,
        children: actions
            .map((a) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: a.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(a.icon, size: iconSz, color: AppColors.primary),
                          SizedBox(height: compact ? 6 : 8),
                          Text(
                            a.label,
                            style: _textStyle(
                              a.label,
                              fontSize: compact ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRecentOrdersHeader(BuildContext context, AppLocalizations l10n) {
    final compact = _compact(context);
    return _animated(
      2,
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l10n.recentOrders,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _textStyle(
                l10n.recentOrders,
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
              visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderListScreen()),
              );
            },
            child: Text(
              l10n.viewAll,
              style: _textStyle(
                l10n.viewAll,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(
    BuildContext context,
    OrderController orderCtrl,
    AppLocalizations l10n,
  ) {
    final orders = orderCtrl.orders.take(5).toList();
    if (orders.isEmpty) {
      final compact = _compact(context);
      final narrow = _narrow(context);
      final iconSz = narrow ? 48.0 : (compact ? 52.0 : 56.0);
      return _animated(
        3,
        Container(
          padding: EdgeInsets.symmetric(vertical: compact ? 28 : 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: iconSz, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.noOrdersYet,
                  textAlign: TextAlign.center,
                  style: _textStyle(
                    l10n.noOrdersYet,
                    fontSize: compact ? 13.5 : 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
                  );
                },
                child: Text(
                  l10n.browseRestaurants,
                  style: _textStyle(
                    l10n.browseRestaurants,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    return _animated(
      3,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              for (var i = 0; i < orders.length; i++) ...[
                _RecentOrderTile(
                  order: orders[i],
                  baseUrl: base,
                  compact: _compact(context),
                  narrow: _narrow(context),
                  onTap: () => _openOrderDetail(context, orders[i]),
                ),
                if (i < orders.length - 1)
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openOrderDetail(BuildContext context, OrderModel order) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a1, __) => OrderDetailScreen(
          orderId: order.id,
          initialOrder: order,
        ),
        transitionsBuilder: (_, a1, __, child) {
          final curve = CurvedAnimation(parent: a1, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(curve),
            child: FadeTransition(opacity: curve, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.emoji, this.value, this.label, this.bgColor);
  final String emoji;
  final String value;
  final String label;
  final Color bgColor;
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({
    required this.order,
    required this.baseUrl,
    required this.onTap,
    this.compact = false,
    this.narrow = false,
  });

  final OrderModel order;
  final String baseUrl;
  final VoidCallback onTap;
  final bool compact;
  final bool narrow;

  static Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'delivered') return AppColors.success;
    if (s == 'cancelled') return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final thumb = narrow ? 44.0 : (compact ? 46.0 : 48.0);
    final logo = order.restaurantImage;
    final imageUrl = logo != null && logo.isNotEmpty
        ? (logo.startsWith('http') ? logo : '$baseUrl$logo')
        : null;
    final placedLine = orderPlacedLine(context, order.placedAt);
    final itemCount = order.effectiveItemCount;
    final itemsLabel = itemCount > 0
        ? l10n.itemsCountInCategory(formatAppInteger(context, itemCount))
        : '';
    final metaLine = placedLine.isEmpty
        ? itemsLabel
        : (itemsLabel.isEmpty ? placedLine : l10n.customerDashboardOrderMeta(placedLine, itemsLabel));
    final restaurantTitle = order.displayRestaurantName ?? l10n.restaurantDefaultName;
    final statusLabel = localizedOrderStatus(context, order.status);
    final totalLabel = AppCurrency.formatLocalized(context, order.total, decimalDigits: 0);
    final trailMax = MediaQuery.sizeOf(context).width * (compact ? 0.34 : 0.3);

    TextStyle tileTextStyle(
      String text, {
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
      Color? color,
    }) {
      return FontHelper.getTextStyle(
        text: text,
        languageCode: languageCode,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 14),
          child: Row(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: thumb,
                    height: thumb,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(thumb),
                    errorWidget: (_, __, ___) => _placeholder(thumb),
                  ),
                )
              else
                _placeholder(thumb),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantTitle,
                      style: tileTextStyle(
                        restaurantTitle,
                        fontSize: compact ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metaLine.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        metaLine,
                        style: tileTextStyle(
                          metaLine,
                          fontSize: compact ? 11.5 : 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: compact ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: trailMax),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalLabel,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tileTextStyle(
                        totalLabel,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tileTextStyle(
                          statusLabel,
                          fontSize: compact ? 10.5 : 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 4 : 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: compact ? 20 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: size * 0.5),
    );
  }
}
