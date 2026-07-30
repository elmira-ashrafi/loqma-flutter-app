import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/order_track_shared.dart';
import '../models/app_notification_model.dart';
import '../notification_l10n.dart';
import '../services/notification_service.dart';

/// While the customer app is open, polls for new server-side notifications and
/// shows a dialog with the title and message (e.g. order preparing).
class NotificationAlertController extends GetxController with WidgetsBindingObserver {
  NotificationAlertController({NotificationService? service}) : _service = service ?? NotificationService();

  final NotificationService _service;
  Timer? _timer;
  final Set<String> _seenIds = {};
  bool _baselineDone = false;
  bool _pollInFlight = false;

  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _poll();
    }
  }

  /// Call when the customer main shell is shown and the user is logged in.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
    scheduleMicrotask(_poll);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _seenIds.clear();
    _baselineDone = false;
    _pollInFlight = false;
  }

  /// Force an immediate notifications fetch (e.g. when user opens Orders tab).
  void refreshNow() => _poll();

  Future<void> _poll() async {
    if (_pollInFlight) return;
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;

    _pollInFlight = true;
    try {
      final result = await _service.fetchNotifications(limit: 50);
      if (!_baselineDone) {
        for (final n in result.items) {
          _seenIds.add(n.id);
        }
        // Apply latest known status per order without spamming old alerts.
        _syncLatestOrderStatuses(result.items);
        _baselineDone = true;
        return;
      }

      final newcomers = <AppNotificationModel>[];
      for (final n in result.items) {
        if (!_seenIds.contains(n.id)) {
          _seenIds.add(n.id);
          newcomers.add(n);
        }
      }
      if (newcomers.isEmpty) return;

      newcomers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _syncLatestOrderStatuses(newcomers);
      // Show only the newest popup so status updates are not blocked by a queue.
      unawaited(_showOneAlert(newcomers.last));
    } catch (_) {
      // Ignore network errors; next poll will retry.
    } finally {
      _pollInFlight = false;
    }
  }

  void _syncLatestOrderStatuses(List<AppNotificationModel> items) {
    if (!Get.isRegistered<OrderController>()) return;
    final sorted = items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final syncedOrderIds = <int>{};
    final allOrderIds = <int>{};
    final ctrl = Get.find<OrderController>();

    for (final n in sorted) {
      final orderId = n.orderId;
      final status = n.data['status']?.toString().trim() ?? '';
      if (orderId != null) allOrderIds.add(orderId);
      if (orderId == null || status.isEmpty) continue;
      if (!isKnownOrderProgressStatus(status)) continue;
      if (syncedOrderIds.contains(orderId)) continue;
      syncedOrderIds.add(orderId);
      unawaited(ctrl.applyRemoteStatus(orderId: orderId, status: status));
    }

    unawaited(ctrl.hydrateOrdersByIds(allOrderIds));
  }

  Future<void> _showOneAlert(AppNotificationModel n) async {
    final ctx = Get.context;
    if (ctx == null || !ctx.mounted) return;

    final l10n = AppLocalizations.of(ctx)!;
    final titleBanner = l10n.newNotificationReceived;
    final localizedTitle = NotificationL10n.localizedTitle(l10n, n);
    final localizedMessage = NotificationL10n.localizedMessage(l10n, n);

    await HapticFeedback.lightImpact();
    if (!ctx.mounted) return;

    await showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(titleBanner),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.iconEmoji ?? '🔔', style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localizedTitle,
                        style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                if (localizedMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    localizedMessage,
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.gotIt),
            ),
          ],
        );
      },
    );
  }
}
