import 'package:dio/dio.dart';

/// Detect CDN/WAF browser challenge pages returned instead of JSON API data.
bool isBrowserChallengeResponse(Response<dynamic> response) {
  final status = response.statusCode ?? 0;
  final server = response.headers.value('server')?.toLowerCase() ?? '';
  final data = response.data;
  final contentType =
      response.headers.value('content-type')?.toLowerCase() ?? '';
  final body = data is String ? data : null;

  if (body != null && looksLikeBrowserChallengePage(body)) return true;

  final htmlResponse =
      contentType.contains('text/html') || (body != null && looksLikeHtmlResponse(body));
  if (!htmlResponse) return false;

  if (body != null &&
      (body.toLowerCase().contains('jschallenge') ||
          body.toLowerCase().contains('hcdn-cgi'))) {
    return true;
  }

  // Hostinger hCDN often returns 403 + HTML challenge for mobile/API clients.
  if (status == 403 && server.contains('hcdn')) return true;

  return htmlResponse &&
      (body?.toLowerCase().contains('jschallenge') == true ||
          body?.toLowerCase().contains('hcdn-cgi') == true);
}

bool looksLikeHtmlResponse(String value) {
  final lower = value.trimLeft().toLowerCase();
  return lower.startsWith('<') ||
      lower.contains('<html') ||
      lower.contains('<!doctype');
}

bool looksLikeBrowserChallengePage(String value) {
  final lower = value.toLowerCase();
  return lower.contains('checking your browser') ||
      lower.contains('hcdn-cgi/jschallenge') ||
      (lower.contains('just a moment') &&
          (lower.contains('cloudflare') ||
              lower.contains('cdn') ||
              lower.contains('hcdn')));
}
