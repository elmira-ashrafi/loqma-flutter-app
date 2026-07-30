import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/driver_controller.dart';
import '../models/driver_models.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.find<DriverController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderHistoryTitle),
        actions: [
          IconButton(
            tooltip: l10n.refreshTooltip,
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.loadOrders(),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _FilterTabs(controller: ctrl, l10n: l10n),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingOrders.value && ctrl.orders.isEmpty && ctrl.ordersError.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (ctrl.ordersError.isNotEmpty && ctrl.orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(ctrl.ordersError.value, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => ctrl.loadOrders(),
                          icon: Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final orders = ctrl.orders;
              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noOrdersYet,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.orderHistoryHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: orders.length,
                itemBuilder: (context, i) {
                  return _OrderRow(order: orders[i], l10n: AppLocalizations.of(context)!);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.controller, required this.l10n});

  final DriverController controller;
  final AppLocalizations l10n;

  static const _filters = <String?>[null, 'delivered', 'cancelled', 'picked_up', 'on_the_way'];

  List<String> get _labels => [
        l10n.all,
        l10n.trackStatusDelivered,
        l10n.ordersFilterCancelled,
        l10n.trackStatusPickedUp,
        l10n.trackStatusOnTheWay,
      ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.ordersStatusFilter.value;
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: List.generate(_filters.length, (i) {
            final val = _filters[i] ?? '';
            final selected = active == val;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setOrdersStatusFilter(_filters[i]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _labels[i],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.primaryLight : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.l10n});

  final DriverOrder order;
  final AppLocalizations l10n;

  String _format(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy · HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order.status.toLowerCase();
    Color statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (status == 'delivered') statusColor = AppColors.success;
    if (status == 'cancelled') statusColor = AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.restaurantName ?? l10n.restaurantDefaultName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _format(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  AppCurrency.format(order.driverEarning),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.driverEarningLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
