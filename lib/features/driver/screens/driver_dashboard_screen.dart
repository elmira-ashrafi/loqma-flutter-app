import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/driver_controller.dart';
import '../models/driver_models.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.find<DriverController>();
    return Obx(() {
      final isLoading = ctrl.isLoading.value;
      final error = ctrl.error.value;
      final data = ctrl.dashboard.value;

      if (isLoading && data == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      if (error.isNotEmpty && data == null) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: ctrl.loadDashboard,
                    icon: Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final dashboard = data!;
      final driver = dashboard.driver;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: RefreshIndicator(
          onRefresh: ctrl.refreshDashboard,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _Header(driver: driver)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _StatsRow(
                    today: dashboard.todayEarnings,
                    week: dashboard.weekEarnings,
                    pending: dashboard.pendingEarnings,
                    totalDeliveries: driver.totalDeliveries,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _RatingCard(driver: driver),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _ActiveDeliveriesSection(orders: dashboard.activeOrders),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _AvailableOrdersSection(driver: driver, orders: dashboard.availableOrders),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _UpcomingOrdersSection(orders: dashboard.upcomingOrders),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: _RecentDeliveriesSection(orders: dashboard.recentOrders),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.driver});

  final DriverInfo driver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.find<DriverController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(Icons.delivery_dining_rounded, size: 40, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driverDashboardTitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.welcomeBack}, ${driver.name}',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final online = ctrl.isOnline.value;
              return _OnlineToggle(
                online: online,
                onChanged: (_) => ctrl.toggleOnlineStatus(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OnlineToggle extends StatefulWidget {
  const _OnlineToggle({required this.online, required this.onChanged});

  final bool online;
  final ValueChanged<bool> onChanged;

  @override
  State<_OnlineToggle> createState() => _OnlineToggleState();
}

class _OnlineToggleState extends State<_OnlineToggle> with SingleTickerProviderStateMixin {
  late bool _online;
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _online = widget.online;
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: _online ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _OnlineToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.online != widget.online) {
      _online = widget.online;
      _c.animateTo(_online ? 1 : 0, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => widget.onChanged(!_online),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final color = Color.lerp(Colors.grey.shade400, Colors.green.shade500, t);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _online ? l10n.statusOnline : l10n.statusOffline,
                style: TextStyle(
                  color: _online ? Colors.green.shade200 : Colors.grey.shade200,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 52,
                height: 28,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, t)!,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.26),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.today,
    required this.week,
    required this.pending,
    required this.totalDeliveries,
  });

  final double today;
  final double week;
  final double pending;
  final int totalDeliveries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.todaysEarningsLabel,
            value: AppCurrency.format(today),
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.thisWeekLabel,
            value: AppCurrency.format(week),
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.pendingPayoutLabel,
            value: AppCurrency.format(pending),
            color: Colors.orange.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.totalDeliveriesLabel,
            value: '$totalDeliveries',
            color: Colors.purple.shade600,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.driver});

  final DriverInfo driver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9C3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, size: 28, color: Color(0xFFEAB308)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ratingStatLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.rating.toStringAsFixed(1)} (${l10n.reviewsCountLabel('${driver.totalReviews}')})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveriesSection extends StatelessWidget {
  const _ActiveDeliveriesSection({required this.orders});

  final List<DriverOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (orders.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.driverActiveDeliveriesSectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...orders.map((o) => _ActiveOrderCard(order: o)),
      ],
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final DriverOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      order.restaurantName ?? l10n.restaurantDefaultName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              _statusChip(context, order.status),
            ],
          ),
          const SizedBox(height: 8),
          if (order.deliveryAddress != null)
            Text(
              order.deliveryAddress!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                l10n.driverEarningPrefix,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
              Text(
                AppCurrency.format(order.driverEarning),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    final s = status.toLowerCase();
    Color bg = Theme.of(context).colorScheme.outlineVariant;
    Color fg = Theme.of(context).colorScheme.onSurfaceVariant;
    if (s == 'picked_up') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
    } else if (s == 'on_the_way') {
      bg = Colors.purple.shade100;
      fg = Colors.purple.shade800;
    } else if (s == 'delivered') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _AvailableOrdersSection extends StatelessWidget {
  const _AvailableOrdersSection({required this.driver, required this.orders});

  final DriverInfo driver;
  final List<DriverOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!driver.isOnline) {
      return _infoBox(
        context: context,
        title: l10n.driverOfflineTitle,
        description: l10n.driverOfflineBody,
        emoji: '🔔',
        color: Colors.yellow.shade700,
      );
    }
    if (!driver.isAvailable) {
      return _infoBox(
        context: context,
        title: l10n.driverActiveDeliveriesTitle,
        description: l10n.driverBusyDeliveriesBody,
        emoji: '🚴',
        color: Colors.blue.shade700,
      );
    }
    if (orders.isEmpty) {
      return _infoBox(
        context: context,
        title: l10n.driverNoOrdersReadyTitle,
        description: l10n.driverNoOrdersReadyBody,
        emoji: '⏳',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.driverAvailableOrdersSectionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (orders.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${orders.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...orders.map((o) => _AvailableOrderCard(order: o)),
      ],
    );
  }

  Widget _infoBox({
    required BuildContext context,
    required String title,
    required String description,
    required String emoji,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  const _AvailableOrderCard({required this.order});

  final DriverOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.shade300,
          style: BorderStyle.solid,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.restaurantName ?? l10n.restaurantDefaultName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (order.deliveryAddress != null)
            Text(
              order.deliveryAddress!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                AppCurrency.format(order.driverEarning),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade600,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.driverEarningLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Get.find<DriverController>().acceptOrder(order.id),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(l10n.acceptOrder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingOrdersSection extends StatelessWidget {
  const _UpcomingOrdersSection({required this.orders});

  final List<DriverOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (orders.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.driverUpcomingOrdersTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...orders.map(
          (o) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.restaurantName ?? l10n.restaurantDefaultName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (o.deliveryAddress != null)
                        Text(
                          o.deliveryAddress!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Text(
                  AppCurrency.format(o.driverEarning),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.driverUpcomingOrdersHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _RecentDeliveriesSection extends StatelessWidget {
  const _RecentDeliveriesSection({required this.orders});

  final List<DriverOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (orders.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentDeliveriesSectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: orders.take(5).map((o) {
              String date = o.createdAt ?? '';
              try {
                date = DateFormat('MMM d, HH:mm').format(DateTime.parse(o.createdAt!));
              } catch (_) {}
              final delivered = o.status.toLowerCase() == 'delivered';
              return ListTile(
                title: Text(
                  o.restaurantName ?? l10n.restaurantDefaultName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(date),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppCurrency.format(o.driverEarning),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: delivered ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                    ),
                    Text(
                      o.status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: delivered ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

