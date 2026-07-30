import 'cdn_cookie_bridge.dart';

/// In-memory CDN cookies synced from the WebView after the browser check passes.
class CdnSessionCookies {
  CdnSessionCookies._();

  static final Map<String, String> _byOrigin = {};

  static String originFromUri(Uri uri) {
    final port = uri.hasPort && uri.port != 80 && uri.port != 443
        ? ':${uri.port}'
        : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  static String? cookiesForUri(Uri uri) {
    return _byOrigin[originFromUri(uri)];
  }

  static Future<void> syncFromWebView(String url) async {
    final cookies = await CdnCookieBridge.getCookies(url);
    if (cookies.trim().isEmpty) return;
    _byOrigin[originFromUri(Uri.parse(url))] = cookies.trim();
  }

  static void clear() => _byOrigin.clear();
}
