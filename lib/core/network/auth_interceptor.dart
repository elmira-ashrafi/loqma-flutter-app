import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_http_adapter.dart';
import 'session_guard.dart';

/// Interceptor that:
/// - Adds Bearer token to requests
/// - On 401: tries refresh token, then redirects to login if needed
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Dio dio}) : _dio = dio, _storage = const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty && _isValidHeaderToken(token)) {
      options.headers['Authorization'] = 'Bearer $token';
    } else if (token != null && !_isValidHeaderToken(token)) {
      await _clearTokens();
    }
    handler.next(options);
  }

  /// Token must be safe for HTTP header (no newlines, no HTML).
  static bool _isValidHeaderToken(String s) {
    if (s.length > 8000) return false;
    return !s.contains('\n') && !s.contains('\r') && !s.contains('<');
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final refreshed = await _refreshToken();
      _isRefreshing = false;
      if (refreshed) {
        final opts = err.requestOptions;
        final token = await _storage.read(key: AppConstants.accessTokenKey);
        if (token != null && AuthInterceptor._isValidHeaderToken(token)) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      }
    } catch (_) {
      _isRefreshing = false;
    }

    await _clearTokens();

    if (!SessionGuard.shouldIgnorePath(err.requestOptions.path)) {
      final message = SessionGuard.messageFromResponse(err);
      await SessionGuard.handleSessionExpired(message: message);
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.badResponse,
        response: err.response,
        error: 'Unauthorized',
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refresh = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await createNetworkDio().post(
        '${ApiConstants.baseUrlHost}/api/v1${ApiConstants.refreshToken}',
        data: {'refresh_token': refresh},
        options: Options(
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );
      final data = response.data as Map<String, dynamic>?;
      final newToken = data?['access_token'] ?? data?['token'] as String?;
      if (newToken != null) {
        await _storage.write(key: AppConstants.accessTokenKey, value: newToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.tokenExpiryKey);
  }
}
