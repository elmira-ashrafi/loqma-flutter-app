import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../offers/screens/offers_deals_screen.dart';
import '../../orders/controllers/order_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/screens/cart_screen.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../../../l10n/app_localizations.dart';
import 'home_tab.dart';
import 'orders_tab.dart';
import '../../notifications/notification_alerts_binding.dart';
import '../../../core/layout/responsive_context.dart';

/// Main shell: Home, Offers, Cart (FAB), Favorites, Orders. Profile opens from Home.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(CartController());
    if (!Get.isRegistered<OrderController>()) {
      // The main shell uses an IndexedStack. Keep the customer order cache alive
      // across tab changes so active and previous orders are never discarded.
      Get.put(OrderController(), permanent: true);
    }
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController(), permanent: true);
    }
    if (!Get.isRegistered<DeliveryLocationController>()) {
      Get.put(DeliveryLocationController(), permanent: true);
    }
    bindNotificationAlerts();
  }

  @override
  void dispose() {
    unbindNotificationAlerts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(isActive: _currentIndex == 0),
          const OffersDealsScreen(),
          const CartScreen(),
          const FavoritesScreen(),
          OrdersTab(isActive: _currentIndex == 4),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        final l10n = AppLocalizations.of(context)!;
        final ctrl = Get.find<CartController>();
        final count = ctrl.itemCount;
        return _CenterCartFab(
          isActive: _currentIndex == 2,
          itemCount: count,
          label: count > 0 ? l10n.cartFabWithCount(count) : l10n.cart,
          tooltip: l10n.cart,
          onTap: () => _onTap(2),
        );
      }),
      bottomNavigationBar: _BottomDock(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
    // Orders tab refreshes itself via TTL when it becomes active.
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dockH = context.layoutScale(72).clamp(64.0, 88.0);
    final fabSlot = context.layoutScale(72).clamp(64.0, 88.0);
    final notch = context.layoutScale(10).clamp(8.0, 14.0);
    return SafeArea(
      top: false,
      bottom: true,
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, -3),
              ),
            ],
            border: Border(
              top: BorderSide(color: scheme.outlineVariant, width: 0.5),
            ),
          ),
          child: BottomAppBar(
            color: scheme.surface,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            notchMargin: notch,
            height: dockH,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.layoutScale(8).clamp(6.0, 12.0),
                vertical: context.layoutScale(6).clamp(4.0, 10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DockItem(
                      icon: Icons.home_outlined,
                      label: l10n.home,
                      semanticsLabel: l10n.mainNavHome,
                      index: 0,
                      currentIndex: currentIndex,
                      onTap: onTap,
                      activeColor: scheme.primary,
                      inactiveColor: scheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.local_offer_outlined,
                      label: l10n.navOffers,
                      semanticsLabel: l10n.mainNavOffers,
                      index: 1,
                      currentIndex: currentIndex,
                      onTap: onTap,
                      activeColor: scheme.primary,
                      inactiveColor: scheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: fabSlot),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.favorite_border,
                      label: l10n.navFavs,
                      semanticsLabel: l10n.mainNavFavorites,
                      index: 3,
                      currentIndex: currentIndex,
                      onTap: onTap,
                      activeColor: scheme.primary,
                      inactiveColor: scheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      final dot = Get.isRegistered<OrderController>()
                          ? Get.find<OrderController>().hasActiveOrders.value
                          : false;
                      return _DockItem(
                        icon: Icons.delivery_dining_rounded,
                        label: l10n.orders,
                        semanticsLabel: l10n.mainNavOrders,
                        index: 4,
                        currentIndex: currentIndex,
                        onTap: onTap,
                        activeColor: scheme.primary,
                        inactiveColor: scheme.onSurfaceVariant,
                        showNotificationDot: dot,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    this.showNotificationDot = false,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final Color inactiveColor;
  final bool showNotificationDot;

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final iconPx = context.layoutScale(24).clamp(22.0, 28.0);
    final labelPx = context.layoutScale(11).clamp(10.0, 13.0);
    final languageCode = Get.find<LocaleController>().locale.languageCode;

    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: isActive,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: activeColor.withValues(alpha: 0.12),
          highlightColor: activeColor.withValues(alpha: 0.06),
          child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(end: isActive ? 1.0 : 0.0),
          builder: (context, t, _) {
            final color = Color.lerp(inactiveColor, activeColor, t)!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    tween: Tween<double>(end: isActive ? 1.08 : 1.0),
                    builder: (context, scale, __) {
                      return Transform.scale(
                        scale: scale,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Icon(icon, size: iconPx, color: color),
                            if (showNotificationDot)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFA726),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.surface,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: FontHelper.getTextStyle(
                      text: label,
                      languageCode: languageCode,
                      fontSize: labelPx,
                      fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ).copyWith(letterSpacing: 0.15, height: 1.1),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
    );

    
  }
}

class _CenterCartFab extends StatelessWidget {
  const _CenterCartFab({
    required this.isActive,
    required this.onTap,
    required this.label,
    required this.tooltip,
    this.itemCount = 0,
  });

  final bool isActive;
  final VoidCallback onTap;
  final String label;
  final String tooltip;
  final int itemCount;

  static const double _ring = 3.5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showBadge = itemCount > 0;
    final diameter = context.layoutScale(52).clamp(48.0, 60.0);
    final outer = diameter + _ring * 2;
    final cartIcon = context.layoutScale(26).clamp(24.0, 30.0);

    final badgeText = itemCount > 99 ? '99+' : '$itemCount';

    return AnimatedScale(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      scale: isActive ? 1.04 : 1.0,
      child: Semantics(
        label: label,
        button: true,
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              child: SizedBox(
            width: outer,
            height: outer,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: outer,
                  height: outer,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surface),
                  alignment: Alignment.center,
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: scheme.onPrimary,
                      size: cartIcon,
                    ),
                  ),
                ),
                if (showBadge)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      alignment: Alignment.center,
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}
