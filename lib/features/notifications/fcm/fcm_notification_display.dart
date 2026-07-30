import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../notification_l10n.dart';

/// Channel used for FCM-backed local notifications (foreground + data-only background).
const String kFcmAndroidChannelId = 'overfood_push';

final FlutterLocalNotificationsPlugin _fcmLocalNotifications = FlutterLocalNotificationsPlugin();
bool _fcmLocalNotificationsReady = false;
String _cachedChannelName = 'Orders & alerts';
String _cachedChannelDescription = 'Delivery and account notifications';

Future<AppLocalizations> _resolveLocalizations() async {
  try {
    if (Get.isRegistered<LocaleController>()) {
      return lookupAppLocalizations(Get.find<LocaleController>().locale);
    }
  } catch (_) {}

  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(AppConstants.localeKey) ?? 'fa';
  final locale = switch (code) {
    'en' => const Locale('en'),
    'ps' => const Locale('ps'),
    _ => const Locale('fa'),
  };
  return lookupAppLocalizations(locale);
}

/// Ensures the plugin and Android channel exist (safe to call from main isolate or FCM background isolate).
Future<void> ensureFcmLocalNotificationsReady() async {
  if (kIsWeb) return;
  if (_fcmLocalNotificationsReady) return;

  final l10n = await _resolveLocalizations();
  _cachedChannelName = l10n.fcmChannelName;
  _cachedChannelDescription = l10n.fcmChannelDescription;

  await _fcmLocalNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    ),
  );

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final android = _fcmLocalNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        kFcmAndroidChannelId,
        _cachedChannelName,
        description: _cachedChannelDescription,
        importance: Importance.high,
      ),
    );
  }

  _fcmLocalNotificationsReady = true;
}

int _notificationIdFor(RemoteMessage message) {
  final mid = message.messageId;
  if (mid != null && mid.isNotEmpty) {
    return mid.hashCode & 0x7fffffff;
  }
  return DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
}

/// Shows a system notification from an FCM [RemoteMessage].
///
/// Used when the app is in the **foreground** (FCM does not show a tray icon on Android)
/// and in the **background isolate** for **data-only** messages (no `notification` payload).
Future<void> showFcmNotification(RemoteMessage message) async {
  if (kIsWeb) return;
  await ensureFcmLocalNotificationsReady();

  final l10n = await _resolveLocalizations();
  final localized = NotificationL10n.localizedFcmTexts(l10n, message);

  await _fcmLocalNotifications.show(
    id: _notificationIdFor(message),
    title: localized.title,
    body: localized.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        kFcmAndroidChannelId,
        _cachedChannelName,
        channelDescription: _cachedChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}
