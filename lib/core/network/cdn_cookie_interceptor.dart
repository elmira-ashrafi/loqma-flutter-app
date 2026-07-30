import 'package:dio/dio.dart';

import 'cdn_session_cookies.dart';
import 'loqma_api_hosts.dart';

/// Attaches WebView CDN session cookies to API requests for Loqma hosts.
class CdnCookieInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isLoqmaApiHost(options.uri.host)) {
      final cookies = CdnSessionCookies.cookiesForUri(options.uri);
      if (cookies != null && cookies.isNotEmpty) {
        options.headers['Cookie'] = cookies;
      }
    }
    handler.next(options);
  }
}
