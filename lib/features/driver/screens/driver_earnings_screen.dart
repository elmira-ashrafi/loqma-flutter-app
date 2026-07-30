import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/driver_controller.dart';
import '../services/driver_service.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  final DriverService _service = DriverService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  double _sumAmounts(dynamic rawList) {
    if (rawList is! List) return 0;
    return rawList.fold<double>(0, (sum, item) {
      final map = _asMap(item);
      return sum + _toDouble(map?['amount']);
    });
  }

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
      final res = await _service.getEarnings();
      if (!mounted) return;
      setState(() {
        _data = res;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final driver = Get.find<DriverController>().dashboard.value?.driver;
    final countFmt = NumberFormat('#,###', 'en_US');
    final driverMap = _asMap(_data?['driver']);
    final total = _toDouble(driverMap?['total_earnings']) > 0
        ? _toDouble(driverMap?['total_earnings'])
        : _toDouble(_data?['total_earnings']) > 0
            ? _toDouble(_data?['total_earnings'])
            : _sumAmounts(_data?['items']);
    final pending = _toDouble(_data?['pendingPayout']) > 0
        ? _toDouble(_data?['pendingPayout'])
        : _toDouble(_data?['pending_payout']) > 0
            ? _toDouble(_data?['pending_payout'])
            : (Get.find<DriverController>().dashboard.value?.pendingEarnings ?? 0);
    final totalDeliveries = _toInt(driverMap?['total_deliveries']) > 0
        ? _toInt(driverMap?['total_deliveries'])
        : (driver?.totalDeliveries ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myEarningsTitle)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                label: l10n.totalEarningsLabel,
                                value: AppCurrency.format(total),
                                color: Colors.green.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _summaryCard(
                                label: l10n.pendingPayoutLabel,
                                value: AppCurrency.format(pending),
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                label: l10n.totalDeliveriesLabel,
                                value: countFmt.format(totalDeliveries),
                                color: Colors.blue.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _summaryCard(
                                label: l10n.ratingStatLabel,
                                value: driver != null ? '${driver.rating.toStringAsFixed(1)} ⭐' : '—',
                                color: Colors.yellow.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _payoutSection(context, l10n, pending),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _summaryCard({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutSection(BuildContext context, AppLocalizations l10n, double pending) {
    const minPayout = 500.0;
    if (pending < minPayout) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          l10n.driverMinimumPayoutMessage(AppCurrency.format(minPayout)),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverReadyForPayoutTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.driverPayoutAvailableMessage(AppCurrency.format(pending)),
            style: TextStyle(color: Color(0xFFDCFCE7), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await _service.requestPayout('bank_transfer');
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.payoutRequested),
                    backgroundColor: AppColors.success,
                  ),
                );
                _load();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(l10n.requestPayout),
            ),
          ),
        ],
      ),
    );
  }
}
