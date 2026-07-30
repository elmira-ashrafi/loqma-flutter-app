import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../fcm/fcm_notification_display.dart';

/// Firebase Cloud Messaging: permissions, tokens, foreground display, and open callbacks.
///
/// **Android:** Add `android/app/google-services.json` from the Firebase console, then apply the
/// Google Services Gradle plugin (`com.google.gms.google-services`) so FCM can initialize.
/// **iOS:** Add `GoogleService-Info.plist`, enable Push capability, and upload APNs key in Firebase.
class PushMessagingService {
  PushMessagingService._();

  static bool _started = false;
  static const int _minLikelyFcmTokenLen = 80;

  /// Call after [WidgetsFlutterBinding.ensureInitialized] and after
  /// [FirebaseMessaging.onBackgroundMessage] is registered.
  static Future<void> start() async {
    if (kIsWeb || _started) return;
    _started = true;

    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      debugPrint('PushMessagingService: Firebase.initializeApp failed (add Firebase config): $e\n$st');
      _started = false;
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('PushMessagingService: FCM permission ${settings.authorizationStatus}');
      }

      await ensureFcmLocalNotificationsReady();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await showFcmNotification(message);
        _applyOrderStatusFromPush(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('PushMessagingService: opened from notification ${message.messageId}');
        }
        _applyOrderStatusFromPush(message);
      });

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null && kDebugMode) {
        debugPrint('PushMessagingService: cold start from notification ${initial.messageId}');
      }

      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      await _persistToken(await FirebaseMessaging.instance.getToken());
      // Token sync runs after login / bootstrap — avoid competing with home API.

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _persistToken(newToken);
        await syncTokenToBackend();
      });
    } catch (e, st) {
      debugPrint('PushMessagingService: start failed: $e\n$st');
    }
  }

  static Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.fcmTokenKey, token);
    if (kDebugMode) {
      debugPrint('PushMessagingService: FCM token stored (${token.length} chars)');
    }
  }

  /// Re-reads the token (e.g. after login).
  static Future<void> refreshTokenCache() async {
    if (kIsWeb) return;
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      await _persistToken(await FirebaseMessaging.instance.getToken());
    } catch (_) {}
  }

  /// Sends the stored FCM token to Laravel so order-status pushes reach this device when the app is closed.
  static Future<void> syncTokenToBackend() async {
    if (kIsWeb) return;
    if (!Get.isRegistered<AuthController>()) return;
    if (!Get.find<AuthController>().isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(AppConstants.fcmTokenKey);
    // Repair bad cached tokens (e.g. placeholders) without user intervention.
    if (token == null || token.length < _minLikelyFcmTokenLen) {
      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        token = await FirebaseMessaging.instance.getToken();
        await _persistToken(token);
      } catch (_) {}
    }
    if (token == null || token.isEmpty) return;
    if (token.length < _minLikelyFcmTokenLen) return;

    try {
      await ApiClient.dio.post<void>(
        ApiConstants.customerFcmToken,
        data: {'fcm_token': token},
      );
      if (kDebugMode) {
        debugPrint('PushMessagingService: FCM token registered with API');
      }
    } on DioException catch (e) {
      debugPrint(
        'PushMessagingService: FCM token API failed ${e.response?.statusCode} — ${e.response?.data}',
      );
    } catch (e, st) {
      debugPrint('PushMessagingService: FCM token API error $e\n$st');
    }
  }

  static void _applyOrderStatusFromPush(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString();
    if (type != 'order_status') return;

    final orderId = int.tryParse((data['order_id'] ?? '').toString());
    final status = (data['status'] ?? '').toString().trim();
    if (orderId == null || status.isEmpty) return;
    if (!Get.isRegistered<OrderController>()) return;

    try {
      unawaited(Get.find<OrderController>().applyRemoteStatus(orderId: orderId, status: status));
    } catch (e, st) {
      debugPrint('PushMessagingService: apply order status failed: $e\n$st');
    }
  }
}
