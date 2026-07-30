import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../auth/controllers/auth_controller.dart';
import 'controllers/notification_alert_controller.dart';
import 'services/push_messaging_service.dart';

/// Starts in-app notification popups for any logged-in role (customer, driver, restaurant).
void bindNotificationAlerts() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final auth = Get.find<AuthController>();
    if (auth.role.value.isEmpty) {
      await auth.detectRole();
    }
    if (!auth.isLoggedIn) return;
    if (!Get.isRegistered<NotificationAlertController>()) {
      Get.put(NotificationAlertController());
    }
    Get.find<NotificationAlertController>().start();
    if (!kIsWeb) {
      await PushMessagingService.refreshTokenCache();
      await PushMessagingService.syncTokenToBackend();
    }
  });
}

void unbindNotificationAlerts() {
  if (Get.isRegistered<NotificationAlertController>()) {
    Get.find<NotificationAlertController>().stop();
    Get.delete<NotificationAlertController>();
  }
}
