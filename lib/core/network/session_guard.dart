import 'package:dio/dio.dart';

/// Global handler invoked when the API session is no longer valid (401).
class SessionGuard {
  SessionGuard._();

  static Future<void> Function({String? message})? onSessionExpired;

  static bool _handling = false;

  static bool shouldIgnorePath(String path) {
    final p = path.toLowerCase();
    return p.contains('/auth/send-otp') ||
        p.contains('/auth/verify-otp') ||
        p.contains('/login') ||
        p.contains('/register') ||
        p.contains('/app/version') ||
        p.contains('/maps/');
  }

  static String? messageFromResponse(DioException err) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    return null;
  }

  static Future<void> handleSessionExpired({String? message}) async {
    if (_handling || onSessionExpired == null) return;
    _handling = true;
    try {
      await onSessionExpired!(message: message);
    } finally {
      _handling = false;
    }
  }
}
