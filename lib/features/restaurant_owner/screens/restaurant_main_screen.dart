import 'package:flutter/material.dart';

import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../notifications/notification_alerts_binding.dart';
import 'restaurant_dashboard_screen.dart';
import 'restaurant_menu_screen.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_settings_screen.dart';
import '../../../l10n/app_localizations.dart';

class RestaurantMainScreen extends StatefulWidget {
  const RestaurantMainScreen({super.key});

  @override
  State<RestaurantMainScreen> createState() => _RestaurantMainScreenState();
}

class _RestaurantMainScreenState extends State<RestaurantMainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    bindNotificationAlerts();
  }

  @override
  void dispose() {
    unbindNotificationAlerts();
    super.dispose();
  }

  static const _pages = [
    RestaurantDashboardScreen(),
    RestaurantOrdersScreen(),
    RestaurantMenuScreen(),
    RestaurantSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final useRail = context.useNavigationRail;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: context.screenWidth >= 900,
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              backgroundColor: theme.colorScheme.surface,
              selectedIconTheme: IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              labelType: context.screenWidth >= 900
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text(l10n.dashboard),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: Text(l10n.orders),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu_rounded),
                  label: Text(l10n.navRestaurantMenu),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text(l10n.settings),
                ),
              ],
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.55),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: l10n.orders,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: l10n.navRestaurantMenu,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
