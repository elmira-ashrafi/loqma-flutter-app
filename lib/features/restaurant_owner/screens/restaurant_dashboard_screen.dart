import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';
import '../models/restaurant_owner_models.dart';
import '../services/restaurant_owner_service.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  final RestaurantOwnerService _service = RestaurantOwnerService();
  RestaurantOwnerDashboardData? _dashboard;
  bool _loading = true;
  bool _updatingStatus = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFriendlyErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _toggleOpen() async {
    if (_updatingStatus) return;
    setState(() => _updatingStatus = true);
    try {
      await _service.toggleStatus();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  Future<void> _updateOrder(RestaurantOwnerOrder order, String status, {String? note}) async {
    try {
      await _service.updateOrderStatus(order.id, status, note: note);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.orderUpdatedToStatus(order.orderNumber, _localizedOrderStatusLabel(l10n, status))),
          backgroundColor: AppColors.success,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.restaurantDashboard)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load, l10n: l10n)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHero(context),
                      const SizedBox(height: 16),
                      ..._buildBody(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurant = _dashboard!.restaurant;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
                      restaurant.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusText(restaurant.status, l10n),
                      style: TextStyle(color: Color(0xFFFED7AA), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: restaurant.isOpen,
                onChanged: _updatingStatus ? null : (_) => _toggleOpen(),
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                activeTrackColor: Colors.green.shade400,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            restaurant.isOpen ? l10n.restaurantOpenAcceptingOrders : l10n.restaurantCurrentlyClosedNotice,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurant = _dashboard!.restaurant;
    if (restaurant.isPending) {
      return [_StatusPanel(message: l10n.restaurantPendingApprovalNotice)];
    }
    if (restaurant.isRejected) {
      return [_StatusPanel(message: l10n.restaurantApplicationRejectedNotice)];
    }

    final stats = _dashboard!.stats;
    return [
      Row(
        children: [
          Expanded(child: _StatCard(label: l10n.todayOrdersLabel, value: '${stats.todayOrders}', color: Colors.blue.shade600)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: l10n.todayRevenueLabel, value: AppCurrency.format(stats.todayRevenue, decimalDigits: 0), color: Colors.green.shade600)),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _StatCard(label: l10n.pendingOrdersLabel, value: '${stats.pendingOrders}', color: Colors.orange.shade600)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: l10n.ratingStatLabel, value: stats.rating.toStringAsFixed(1), color: Colors.amber.shade700)),
        ],
      ),
      const SizedBox(height: 18),
      _OrderSection(
        title: l10n.restaurantNewOrdersSectionTitle,
        emptyText: l10n.restaurantNoPendingOrdersSubtitle,
        orders: _dashboard!.pendingOrders,
        onPrimary: (order) => _updateOrder(order, 'confirmed'),
        onSecondary: (order) => _updateOrder(order, 'cancelled', note: 'Rejected by restaurant'),
        primaryLabel: l10n.acceptOrder,
        secondaryLabel: l10n.rejectOrderAction,
      ),
      const SizedBox(height: 16),
      _OrderSection(
        title: l10n.restaurantActiveOrdersSectionTitle,
        emptyText: l10n.restaurantNoActiveOrdersSubtitle,
        orders: _dashboard!.activeOrders,
        onPrimary: (order) {
          if (order.canStartPreparing) {
            return _updateOrder(order, 'preparing');
          }
          if (order.canMarkReady) {
            return _updateOrder(order, 'ready');
          }
          return Future<void>.value();
        },
        primaryLabelBuilder: (order) {
          if (order.canStartPreparing) return l10n.orderActionStartPreparing;
          if (order.canMarkReady) return l10n.orderActionMarkReady;
          return null;
        },
      ),
      const SizedBox(height: 16),
      _RecentOrdersCard(orders: _dashboard!.recentOrders),
    ];
  }

  String _localizedOrderStatusLabel(AppLocalizations l10n, String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return l10n.paymentStatusPendingGeneric;
      case 'confirmed':
        return l10n.trackStatusConfirmed;
      case 'preparing':
        return l10n.trackStatusPreparing;
      case 'ready':
        return l10n.trackStatusReady;
      case 'cancelled':
        return l10n.ordersFilterCancelled;
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  String _statusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.partnerAccountStatusActive;
      case 'pending':
        return l10n.partnerAccountStatusPending;
      case 'rejected':
        return l10n.partnerAccountStatusRejected;
      default:
        return status;
    }
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({
    required this.title,
    required this.emptyText,
    required this.orders,
    required this.onPrimary,
    this.onSecondary,
    this.primaryLabel,
    this.secondaryLabel,
    this.primaryLabelBuilder,
  });

  final String title;
  final String emptyText;
  final List<RestaurantOwnerOrder> orders;
  final Future<void> Function(RestaurantOwnerOrder order) onPrimary;
  final Future<void> Function(RestaurantOwnerOrder order)? onSecondary;
  final String? primaryLabel;
  final String? secondaryLabel;
  final String? Function(RestaurantOwnerOrder order)? primaryLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(emptyText, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OrderCard(
                  order: order,
                  primaryLabel: primaryLabelBuilder?.call(order) ?? primaryLabel,
                  secondaryLabel: secondaryLabel,
                  onPrimary: () => onPrimary(order),
                  onSecondary: onSecondary == null ? null : () => onSecondary!(order),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });

  final RestaurantOwnerOrder order;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.customerName ?? l10n.summaryCustomerLabel}${order.customerPhone != null ? ' • ${order.customerPhone}' : ''}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            order.items.isEmpty ? l10n.noLineItems : order.items.map((item) => '${item.quantity}x ${item.name}').join(', '),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            AppCurrency.format(order.total, decimalDigits: 0),
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          if ((primaryLabel != null && primaryLabel!.isNotEmpty) || onSecondary != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (primaryLabel != null && primaryLabel!.isNotEmpty)
                  Expanded(
                    child: FilledButton(
                      onPressed: onPrimary,
                      child: Text(primaryLabel!),
                    ),
                  ),
                if (primaryLabel != null && primaryLabel!.isNotEmpty && secondaryLabel != null) const SizedBox(width: 10),
                if (secondaryLabel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      child: Text(secondaryLabel!),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.orders});

  final List<RestaurantOwnerOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recentOrders, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Text(l10n.noRecentOrdersYet, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
          else
            ...orders.take(6).map(
                  (order) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(order.orderNumber),
                    subtitle: Text(order.customerName ?? l10n.summaryCustomerLabel),
                    trailing: Text(
                      AppCurrency.format(order.total, decimalDigits: 0),
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (status) {
      case 'pending':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      case 'confirmed':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;
      case 'preparing':
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade800;
        break;
      case 'ready':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry, required this.l10n});

  final String message;
  final Future<void> Function() onRetry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
