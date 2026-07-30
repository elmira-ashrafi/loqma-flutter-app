import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../orders/services/order_service.dart';

/// Outcome of [poll] after user returns from HesabPay.
enum HesabPayPaymentOutcome { paid, failed, pending }

class HesabPayStatusPoller {
  HesabPayStatusPoller._();

  static Future<HesabPayPaymentOutcome> poll({
    required int orderId,
    int maxAttempts = 30,
    Duration delayBetweenAttempts = const Duration(milliseconds: 1000),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(delayBetweenAttempts);
      }

      final fromStatus = await _fetchPaymentStatus(orderId);
      if (fromStatus == HesabPayPaymentOutcome.paid ||
          fromStatus == HesabPayPaymentOutcome.failed) {
        return fromStatus!;
      }
    }

    final fromOrder = await _fetchOrderPaymentStatus(orderId);
    if (fromOrder == HesabPayPaymentOutcome.paid ||
        fromOrder == HesabPayPaymentOutcome.failed) {
      return fromOrder!;
    }

    return HesabPayPaymentOutcome.pending;
  }

  /// After HesabPay WebView reports success, poll until the server marks the order paid.
  static Future<HesabPayPaymentOutcome> confirmAfterGatewaySuccess({
    required int orderId,
    int maxAttempts = 20,
    Duration delayBetweenAttempts = const Duration(milliseconds: 1500),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(delayBetweenAttempts);
      }
      final fromStatus = await _fetchPaymentStatus(orderId);
      if (fromStatus == HesabPayPaymentOutcome.paid ||
          fromStatus == HesabPayPaymentOutcome.failed) {
        return fromStatus!;
      }
      final fromOrder = await _fetchOrderPaymentStatus(orderId);
      if (fromOrder == HesabPayPaymentOutcome.paid ||
          fromOrder == HesabPayPaymentOutcome.failed) {
        return fromOrder!;
      }
    }
    return HesabPayPaymentOutcome.pending;
  }

  static Future<HesabPayPaymentOutcome?> _fetchPaymentStatus(int orderId) async {
    try {
      final res = await ApiClient.dio.get<dynamic>(
        ApiConstants.paymentStatusAbsoluteUrl(orderId),
      );
      return _parseStatusMap(_unwrap(res.data));
    } on DioException catch (_) {
      return null;
    }
  }

  static Future<HesabPayPaymentOutcome?> _fetchOrderPaymentStatus(int orderId) async {
    try {
      final order = await OrderService().getOrderById(orderId);
      return _parsePaymentStatusValue(order.paymentStatus);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return const {};
  }

  static HesabPayPaymentOutcome? _parseStatusMap(Map<String, dynamic> map) {
    final status = map['status']?.toString();
    final paymentStatus = map['payment_status']?.toString();
    return _parsePaymentStatusValue(paymentStatus ?? status);
  }

  static HesabPayPaymentOutcome? _parsePaymentStatusValue(String? raw) {
    final s = raw?.toLowerCase().trim();
    if (s == null || s.isEmpty) return null;
    if (s == 'paid' || s == 'success' || s == 'completed') {
      return HesabPayPaymentOutcome.paid;
    }
    if (s == 'failed' || s == 'cancelled' || s == 'canceled') {
      return HesabPayPaymentOutcome.failed;
    }
    if (s == 'pending') {
      return HesabPayPaymentOutcome.pending;
    }
    return null;
  }
}
