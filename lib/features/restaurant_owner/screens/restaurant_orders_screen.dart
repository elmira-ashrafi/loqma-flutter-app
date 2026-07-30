import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';
import '../models/restaurant_owner_models.dart';
import '../services/restaurant_owner_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  final RestaurantOwnerService _service = RestaurantOwnerService();
  final List<String> _filters = const ['', 'pending', 'confirmed', 'preparing', 'ready', 'cancelled'];
  List<RestaurantOwnerOrder> _orders = const [];
  String _selectedStatus = '';
  bool _loading = true;
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
      final data = await _service.getOrders(status: _selectedStatus);
      if (!mounted) return;
      setState(() {
        _orders = data;
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

  Future<void> _changeStatus(RestaurantOwnerOrder order, String status) async {
    try {
      await _service.updateOrderStatus(order.id, status);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderUpdatedShort(order.orderNumber)), backgroundColor: AppColors.success),
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
      appBar: AppBar(title: Text(l10n.restaurantOrdersTitle)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final value = _filters[index];
                final selected = value == _selectedStatus;
                return ChoiceChip(
                  label: Text(_chipLabel(l10n, value)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedStatus = value);
                    _load();
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filters.length,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.isEmpty ? 1 : _orders.length,
                          itemBuilder: (context, index) {
                            if (_orders.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Center(child: Text(l10n.noOrdersForFilter)),
                              );
                            }
                            final order = _orders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _RestaurantOrderTile(
                                order: order,
                                l10n: l10n,
                                onStatusSelected: (status) => _changeStatus(order, status),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Localized chip label for `/orders?status=` filter chips.
  String _chipLabel(AppLocalizations l10n, String value) {
    if (value.isEmpty) return l10n.all;
    switch (value) {
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
        return value.replaceAll('_', ' ');
    }
  }
}

class _RestaurantOrderTile extends StatelessWidget {
  const _RestaurantOrderTile({
    required this.order,
    required this.l10n,
    required this.onStatusSelected,
  });

  final RestaurantOwnerOrder order;
  final AppLocalizations l10n;
  final ValueChanged<String> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final dateText = order.createdAt == null
        ? ''
        : DateFormat('MMM d, h:mm a').format(DateTime.tryParse(order.createdAt!) ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    Text(order.orderNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    if (dateText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(dateText, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onStatusSelected,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'confirmed', child: Text(l10n.orderActionConfirm)),
                  PopupMenuItem(value: 'preparing', child: Text(l10n.orderActionStartPreparing)),
                  PopupMenuItem(value: 'ready', child: Text(l10n.orderActionMarkReady)),
                  PopupMenuItem(value: 'cancelled', child: Text(l10n.ticketCancel)),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(order.status.replaceAll('_', ' '), style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.customerName ?? l10n.summaryCustomerLabel}${order.customerPhone != null ? ' • ${order.customerPhone}' : ''}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            order.items.isEmpty ? l10n.noLineItems : order.items.map((item) => '${item.quantity}x ${item.name}').join(', '),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          if (order.driverName != null) ...[
            const SizedBox(height: 8),
            Text(l10n.driverWithName(order.driverName!), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 12),
          Text(
            AppCurrency.format(order.total, decimalDigits: 0),
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
