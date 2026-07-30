import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/localized_content.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final Dio _dio = ApiClient.dio;
  bool _loading = true;
  String? _error;
  List<_AdminHesabPayPayment> _payments = const [];

  @override
  void initState() {
    super.initState();
    _loadHesabPayPayments();
  }

  Future<void> _loadHesabPayPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _dio.get(
        ApiConstants.adminOrders,
        queryParameters: {
          'payment_method': 'hesabpay',
        },
      );

      final raw = response.data;
      final orders = _extractOrders(raw);
      final payments = orders.map(_AdminHesabPayPayment.fromJson).toList();

      if (!mounted) return;
      setState(() {
        _payments = payments;
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

  List<Map<String, dynamic>> _extractOrders(dynamic raw) {
    dynamic cursor = raw;
    if (cursor is Map<String, dynamic>) {
      cursor = cursor['data'] ?? cursor['orders'] ?? cursor['items'] ?? cursor;
      if (cursor is Map<String, dynamic>) {
        cursor = cursor['orders'] ?? cursor['items'] ?? cursor['data'] ?? cursor;
      }
    }

    if (cursor is List) {
      return cursor
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where(
            (e) => (e['payment_method']?.toString().toLowerCase() == 'hesabpay') ||
                (e['paymentMethod']?.toString().toLowerCase() == 'hesabpay'),
          )
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSuperPaymentsTitle),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadHesabPayPayments,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.adminRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHesabPayPayments,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.adminCouldNotLoadPayments,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_error!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadHesabPayPayments,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      );
    }
    if (_payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.receipt_long_rounded, size: 56),
          const SizedBox(height: 12),
          Text(
            l10n.adminNoHesabPayPayments,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _PaymentCard(payment: _payments[index]),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final _AdminHesabPayPayment payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createdAtText = payment.createdAt ?? '—';
    final orderLabel = payment.orderNumber?.isNotEmpty == true ? '#${payment.orderNumber}' : '#${payment.orderId}';
    final detailsJson = const JsonEncoder.withIndent('  ').convert(payment.raw);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payment.restaurantImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: payment.restaurantImageUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(context, 44),
                      errorWidget: (_, __, ___) => _imagePlaceholder(context, 44),
                    ),
                  )
                else
                  _imagePlaceholder(context, 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.adminHesabPayPaymentOrder(orderLabel),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  payment.paymentStatus ?? 'pending',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 8,
              spacing: 18,
              children: [
                _kv(l10n.adminRestaurant, payment.restaurantName ?? '—'),
                _kv(l10n.adminOrderId, payment.restaurantId?.toString() ?? '—'),
                _kv(l10n.adminAmount, AppCurrency.format(payment.total)),
                _kv(l10n.adminPaymentStatus, payment.paymentMethod ?? 'hesabpay'),
                _kv(l10n.adminCustomer, payment.customerName ?? '—'),
                _kv(l10n.adminCreatedAt, createdAtText),
              ],
            ),
            if (payment.transactionRef != null && payment.transactionRef!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _kv('Transaction Ref', payment.transactionRef!),
            ],
            if (payment.paymentImageUrl != null) ...[
              const SizedBox(height: 10),
              Text(
                'Payment Image',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: payment.paymentImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: double.infinity,
                    height: 160,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 160,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_rounded),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 6),
              title: Text(l10n.adminViewPaymentDetails),
              subtitle: Text(l10n.adminPaymentDetails),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    detailsJson,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }

  Widget _imagePlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_rounded, size: 20),
    );
  }
}

class _AdminHesabPayPayment {
  const _AdminHesabPayPayment({
    required this.raw,
    required this.orderId,
    required this.total,
    this.orderNumber,
    this.paymentMethod,
    this.paymentStatus,
    this.restaurantId,
    this.restaurantName,
    this.customerName,
    this.createdAt,
    this.transactionRef,
    this.restaurantImageUrl,
    this.paymentImageUrl,
  });

  final Map<String, dynamic> raw;
  final int orderId;
  final String? orderNumber;
  final double total;
  final String? paymentMethod;
  final String? paymentStatus;
  final int? restaurantId;
  final String? restaurantName;
  final String? customerName;
  final String? createdAt;
  final String? transactionRef;
  final String? restaurantImageUrl;
  final String? paymentImageUrl;

  factory _AdminHesabPayPayment.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'];
    final customer = json['customer'];

    return _AdminHesabPayPayment(
      raw: json,
      orderId: _asInt(json['id']) ?? 0,
      orderNumber: _asString(json['order_number']) ?? _asString(json['orderNumber']),
      total: _asDouble(json['total']) ?? 0,
      paymentMethod: _asString(json['payment_method']) ?? _asString(json['paymentMethod']),
      paymentStatus: _asString(json['payment_status']) ?? _asString(json['paymentStatus']) ?? _asString(json['status']),
      restaurantId: restaurant is Map ? _asInt(restaurant['id']) : _asInt(json['restaurant_id']),
      restaurantName: restaurant is Map
          ? LocalizedContent.restaurantBrandName(_asString(restaurant['name']) ?? '')
          : _asString(json['restaurant_name']),
      customerName: customer is Map ? _asString(customer['name']) : _asString(json['customer_name']),
      createdAt: _asString(json['created_at']) ?? _asString(json['createdAt']),
      transactionRef: _asString(json['transaction_reference']) ??
          _asString(json['transaction_id']) ??
          _asString(json['hesabpay_transaction_id']),
      restaurantImageUrl: _toAbsoluteMediaUrl(
        restaurant is Map
            ? (_asString(restaurant['logo']) ??
                _asString(restaurant['image']) ??
                _asString(restaurant['cover_image']))
            : (_asString(json['restaurant_logo']) ?? _asString(json['restaurant_image'])),
      ),
      paymentImageUrl: _toAbsoluteMediaUrl(
        _asString(json['payment_image']) ??
            _asString(json['payment_screenshot']) ??
            _asString(json['receipt_image']) ??
            _asString(json['proof_image']),
      ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString();
  }

  static String? _toAbsoluteMediaUrl(String? path) {
    if (path == null) return null;
    final p = path.trim();
    if (p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;

    final origin = ApiConstants.apiOrigin;
    if (p.startsWith('/storage/')) return '$origin$p';
    if (p.startsWith('storage/')) return '$origin/$p';
    if (p.startsWith('/')) return '$origin$p';
    return '$origin/storage/$p';
  }
}
