import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'fcm_notification_display.dart';

/// Handles FCM when the app is in the background or terminated.
///
/// **Data-only** messages trigger this handler; the OS does not show a notification by itself,
/// so we display one with [showFcmNotification].
///
/// Messages that include a `notification` payload are usually shown by the system when the app
/// is not in the foreground (Android / iOS with APNs configured).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) return;
  await Firebase.initializeApp();
  // When a `notification` payload is present, Android/iOS usually show the tray UI themselves.
  // Only data-only messages need a local notification here.
  if (message.notification != null) return;
  await showFcmNotification(message);
}
