import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/order_controller.dart';
import 'hesab_pay_status_poller.dart';

/// Listens for `loqma://payment-success` / `loqma://payment-fail` after external HesabPay browser flow.
class PaymentReturnService extends GetxService with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _handling = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _sub = _appLinks.uriLinkStream.listen(_onUri, onError: (_) {});
    unawaited(_consumeInitialLink());
  }

  Future<void> _consumeInitialLink() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _onUri(initial);
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel() ?? Future<void>.value());
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_retryPendingFromPrefs());
    }
  }

  Future<bool> _isInAppWebViewFlow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.hesabPayInAppFlowKey) ?? false;
  }

  Future<void> _retryPendingFromPrefs() async {
    if (_handling) return;
    if (await _isInAppWebViewFlow()) return;
    final prefs = await SharedPreferences.getInstance();
    final oid = prefs.getInt(AppConstants.pendingHesabPayOrderIdKey);
    if (oid == null) return;
    await _pollAndFinish(oid);
  }

  Future<void> _onUri(Uri uri) async {
    if (uri.scheme != 'loqma') return;
    if (uri.host != 'payment-success' && uri.host != 'payment-fail') return;
    if (await _isInAppWebViewFlow()) return;
    final prefs = await SharedPreferences.getInstance();
    final oid = prefs.getInt(AppConstants.pendingHesabPayOrderIdKey);
    if (oid == null) return;
    await _pollAndFinish(oid);
  }

  Future<void> _pollAndFinish(int orderId) async {
    if (_handling) return;
    _handling = true;
    try {
      final outcome = await HesabPayStatusPoller.poll(orderId: orderId);

      final prefs = await SharedPreferences.getInstance();
      final stillPending = prefs.getInt(AppConstants.pendingHesabPayOrderIdKey) == orderId;
      if (!stillPending) {
        return;
      }
      await prefs.remove(AppConstants.pendingHesabPayOrderIdKey);

      if (outcome == HesabPayPaymentOutcome.paid) {
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().clear();
        }
        if (Get.isRegistered<OrderController>()) {
          await Get.find<OrderController>().loadOrders();
        }
        final ctx = Get.context;
        if (ctx != null && ctx.mounted) {
          final l10n = AppLocalizations.of(ctx);
          showAppOrderPlacedNoticeAfterCheckout(
            message: l10n?.paymentSuccessfulConfirmed ??
                'Payment successful. Your order is confirmed.',
            orderId: orderId,
          );
        }
        _popToRoot();
      } else if (outcome == HesabPayPaymentOutcome.pending) {
        Get.snackbar(
          'Payment',
          'Payment is still processing. Check your orders for status.',
          snackPosition: SnackPosition.BOTTOM,
        );
        _popToRoot();
      } else if (outcome == HesabPayPaymentOutcome.failed) {
        Get.snackbar(
          'Payment',
          'Payment failed or was cancelled.',
          snackPosition: SnackPosition.BOTTOM,
        );
        _popToRoot();
      }
    } finally {
      _handling = false;
    }
  }

  void _popToRoot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Get.key.currentState;
      if (nav != null) {
        nav.popUntil((route) => route.isFirst);
      }
    });
  }
}
