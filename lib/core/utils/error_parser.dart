import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../network/api_response.dart';
import '../network/edge_security.dart';

/// Parse DioException into a user-friendly message.
String parseDioError(DioException e) {
  final path = e.requestOptions.path.toLowerCase();
  if (e.response != null) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final api = ApiResponse.fromJson(data, null);
      final apiMessage = api.errorMessage;
      if ((e.response?.statusCode ?? 0) >= 500 && path.contains('/auth/send-otp')) {
        return '$apiMessage\n\n'
            'OTP service failed on the server. '
            'If you are testing, deploy the latest backend changes and make sure OTP fake mode or valid Twilio credentials are configured on the host.';
      }
      return api.errorMessage;
    }

    final securityMsg = _edgeSecurityBlockMessage(e.response);
    if (securityMsg != null) return securityMsg;

    final status = e.response?.statusCode;
    if (status == 401) return 'Invalid email or password';
    if (status == 422) return 'Validation error. Check your input.';
    if (status == 500 && path.contains('/auth/send-otp')) {
      return 'OTP service failed on the server.\n\n'
          'Deploy the latest backend changes to the host and ensure either:\n'
          '• OTP_FAKE_DELIVERY=true for testing, or\n'
          '• valid Twilio WhatsApp credentials are configured.';
    }
    if (status != null) return 'Server error ($status)';
  }
  final serverHint = _serverHint();
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Connection timeout. $serverHint';
  }
  if (e.type == DioExceptionType.connectionError) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('no route to host') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable')) {
      return 'Cannot reach server at $serverHint\n\n'
          'Check:\n'
          '• The domain is live and reachable in your browser\n'
          '• SSL is configured correctly for the API\n'
          '• The backend is deployed and serving /api/v1 routes\n'
          '• The app base URL in lib/core/constants/api_constants.dart is correct';
    }
    return 'Cannot reach server. $serverHint';
  }
  return e.message ?? 'Something went wrong';
}

String _serverHint() {
  try {
    return ApiConstants.baseUrlHost;
  } catch (_) {
    return '';
  }
}

/// CDN/WAF (e.g. Cloudflare, Hostinger edge) often returns HTML challenge pages
/// to non-browser clients; Dio then sees 403 + text/html instead of JSON.
String? _edgeSecurityBlockMessage(Response? response) {
  if (response == null) return null;
  final data = response.data;
  final ctype =
      response.headers.value('content-type')?.toLowerCase() ?? '';
  final bodyStr = data is String ? data : null;
  final htmlByHeader = ctype.contains('text/html');
  final htmlBody = bodyStr != null && looksLikeHtmlResponse(bodyStr);
  if (!htmlByHeader && !htmlBody) return null;
  if (bodyStr != null && looksLikeBrowserChallengePage(bodyStr)) {
    final host = _serverHint();
    return 'The server is still running a security check for $host. '
        'Please wait a moment and try again.';
  }
  if (htmlByHeader || (bodyStr != null && looksLikeHtmlResponse(bodyStr))) {
    final host = _serverHint();
    return 'The server returned HTML instead of JSON ($host). '
        'Check that `api_constants.dart` points at the real API and that '
        'CDN/WAF rules allow mobile clients for `/api/v1`.';
  }
  return null;
}

/// Clean, short message for end-users (no raw exception details).
String userFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    switch (error.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server is taking too long to respond. Please try again.';
      default:
        if (status != null && status >= 500) {
          return 'Server is temporarily unavailable. Please try again shortly.';
        }
        if (status == 401 || status == 403) {
          return 'Your session has expired. Please sign in again.';
        }
        if (status == 404) {
          return 'Requested data was not found.';
        }
        return 'Something went wrong. Please try again.';
    }
  }

  final raw = error.toString().replaceFirst('Exception: ', '').toLowerCase();
  if (raw.contains('socket') ||
      raw.contains('network') ||
      raw.contains('no internet') ||
      raw.contains('connection refused') ||
      raw.contains('failed host lookup') ||
      raw.contains('timed out')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (raw.contains('server') || raw.contains('500') || raw.contains('503')) {
    return 'Server is temporarily unavailable. Please try again shortly.';
  }
  return 'Something went wrong. Please try again.';
}
