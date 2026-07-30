import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../notifications/notification_alerts_binding.dart';
import '../controllers/driver_controller.dart';
import 'driver_dashboard_screen.dart';
import 'driver_orders_screen.dart';
import 'driver_earnings_screen.dart';
import 'driver_profile_screen.dart';
import '../../../l10n/app_localizations.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<DriverController>()) {
      Get.put(DriverController());
    }
    bindNotificationAlerts();
  }

  @override
  void dispose() {
    unbindNotificationAlerts();
    super.dispose();
  }

  static const _pages = [
    DriverDashboardScreen(),
    DriverOrdersScreen(),
    DriverEarningsScreen(),
    DriverProfileScreen(),
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
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: theme.colorScheme.surface,
              selectedIconTheme: IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
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
                  icon: Icon(Icons.attach_money_outlined),
                  selectedIcon: Icon(Icons.attach_money_rounded),
                  label: Text(l10n.navEarnings),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outlined),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text(l10n.profile),
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
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
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
            icon: Icon(Icons.attach_money_rounded),
            label: l10n.navEarnings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
