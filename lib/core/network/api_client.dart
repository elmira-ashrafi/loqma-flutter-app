import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_fallback_interceptor.dart';
import 'api_http_adapter.dart';
import 'api_security_challenge_interceptor.dart';
import 'auth_interceptor.dart';
import 'cdn_cookie_interceptor.dart';
import 'cdn_warmup_host.dart';
import 'locale_interceptor.dart';

/// Dio HTTP client configured for Laravel REST API.
/// Uses [AuthInterceptor] for JWT and refresh token handling.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// Sync Dio base URL after [ApiConstants.setActiveOrigin].
  static void applyActiveOrigin() {
    _dio?.options.baseUrl = ApiConstants.baseUrl;
  }

  /// Reset client (e.g. after logout) to clear interceptors state.
  static void reset() {
    _dio?.close();
    _dio = null;
  }

  static Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': cdnWebViewUserAgent,
          'X-Requested-With': 'XMLHttpRequest',
          'X-Loqma-Client': 'LoqmaApp/1.0 Flutter',
        },
      ),
    );
    configureApiHttpAdapter(client);
    client.interceptors.addAll([
      CdnCookieInterceptor(),
      LocaleInterceptor(),
      AuthInterceptor(dio: client),
      ApiFallbackInterceptor(client),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
      ApiSecurityChallengeInterceptor(client),
    ]);
    return client;
  }
}
