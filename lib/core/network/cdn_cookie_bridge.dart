import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads CDN session cookies from the system WebView store (Android WebKit).
class CdnCookieBridge {
  CdnCookieBridge._();

  static const MethodChannel _channel =
      MethodChannel('delivery.loqma/cdn_cookies');

  static Future<String> getCookies(String url) async {
    if (kIsWeb) return '';
    try {
      final cookies = await _channel.invokeMethod<String>(
        'getCookies',
        {'url': url},
      );
      return cookies ?? '';
    } catch (_) {
      return '';
    }
  }
}
