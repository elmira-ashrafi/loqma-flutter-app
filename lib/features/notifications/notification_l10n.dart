import 'package:firebase_messaging/firebase_messaging.dart';

import '../../l10n/app_localizations.dart';
import '../orders/order_track_shared.dart';
import 'models/app_notification_model.dart';

/// Localized notification titles and bodies for tray alerts, dialogs, and list rows.
abstract final class NotificationL10n {
  static bool isOrderStatusNotification(AppNotificationModel notification) {
    final type = notification.data['type']?.toString().trim() ?? '';
    if (type == 'order_status') return true;
    final status = notification.data['status']?.toString().trim() ?? '';
    if (status.isEmpty) return false;
    return notification.orderId != null ||
        (notification.data['order_number']?.toString().trim().isNotEmpty ?? false);
  }

  static bool isOrderStatusPayload(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim() ?? '';
    if (type == 'order_status') return true;
    final status = data['status']?.toString().trim() ?? '';
    if (status.isEmpty) return false;
    return data['order_id'] != null || (data['order_number']?.toString().trim().isNotEmpty ?? false);
  }

  static String localizedTitle(AppLocalizations l10n, AppNotificationModel notification) {
    if (!isOrderStatusNotification(notification)) {
      final raw = notification.displayTitle;
      if (raw.isNotEmpty && raw != 'Notification') return raw;
      return l10n.notificationFallbackTitle;
    }
    return _orderTitle(l10n, _statusFromData(notification.data));
  }

  static String localizedMessage(AppLocalizations l10n, AppNotificationModel notification) {
    if (!isOrderStatusNotification(notification)) {
      return notification.displayMessage;
    }
    return _orderMessage(l10n, notification.data);
  }

  static ({String title, String body}) localizedFcmTexts(
    AppLocalizations l10n,
    RemoteMessage message,
  ) {
    final data = Map<String, dynamic>.from(message.data);
    if (isOrderStatusPayload(data)) {
      final status = _statusFromData(data);
      return (
        title: _orderTitle(l10n, status),
        body: _orderMessage(l10n, data),
      );
    }

    final n = message.notification;
    var title = (n?.title ?? data['title']?.toString() ?? '').trim();
    var body = (n?.body ?? data['body']?.toString() ?? data['message']?.toString() ?? '').trim();
    if (title.isEmpty) title = l10n.notificationDefaultTitle;
    if (body.isEmpty) body = ' ';
    return (title: title, body: body);
  }

  static String _statusFromData(Map<String, dynamic> data) {
    final raw = data['status']?.toString().trim() ?? '';
    if (raw.isEmpty) return 'pending';
    return normalizeOrderStatusKey(raw);
  }

  static String _orderNumber(Map<String, dynamic> data) {
    return data['order_number']?.toString().trim() ?? '';
  }

  static String _restaurantName(Map<String, dynamic> data) {
    return data['restaurant_name']?.toString().trim() ?? '';
  }

  static String _driverName(Map<String, dynamic> data) {
    return data['driver_name']?.toString().trim() ?? '';
  }

  static String _orderTitle(AppLocalizations l10n, String status) {
    switch (status) {
      case 'confirmed':
        return l10n.notificationOrderConfirmedTitle;
      case 'preparing':
        return l10n.notificationOrderPreparingTitle;
      case 'ready':
        return l10n.notificationOrderReadyTitle;
      case 'picked_up':
        return l10n.notificationOrderPickedUpTitle;
      case 'on_the_way':
        return l10n.notificationOrderOnTheWayTitle;
      case 'delivered':
        return l10n.notificationOrderDeliveredTitle;
      case 'cancelled':
        return l10n.notificationOrderCancelledTitle;
      default:
        return l10n.notificationOrderUpdateTitle;
    }
  }

  static String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'pending':
        return l10n.trackStatusPending;
      case 'confirmed':
        return l10n.trackStatusConfirmed;
      case 'preparing':
        return l10n.trackStatusPreparing;
      case 'ready':
        return l10n.trackStatusReady;
      case 'picked_up':
        return l10n.trackStatusPickedUp;
      case 'on_the_way':
        return l10n.trackStatusOnTheWay;
      case 'delivered':
        return l10n.trackStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      case 'refunded':
        return l10n.orderStatusRefunded;
      default:
        return status.replaceAll('_', ' ');
    }
  }

  static String _orderMessage(AppLocalizations l10n, Map<String, dynamic> data) {
    final status = _statusFromData(data);
    final orderNumber = _orderNumber(data);
    final restaurant = _restaurantName(data);
    final driver = _driverName(data);
    final statusLabel = _statusLabel(l10n, status);

    switch (status) {
      case 'confirmed':
        return l10n.notificationOrderConfirmedMessage(orderNumber, restaurant);
      case 'preparing':
        return l10n.notificationOrderPreparingMessage(orderNumber, restaurant);
      case 'ready':
        return l10n.notificationOrderReadyMessage(orderNumber);
      case 'picked_up':
        return l10n.notificationOrderPickedUpMessage(orderNumber, driver);
      case 'on_the_way':
        return l10n.notificationOrderOnTheWayMessage(orderNumber, driver);
      case 'delivered':
        return l10n.notificationOrderDeliveredMessage(orderNumber);
      case 'cancelled':
        return l10n.notificationOrderCancelledMessage(orderNumber);
      default:
        return l10n.notificationOrderUpdateMessage(orderNumber, statusLabel);
    }
  }
}
