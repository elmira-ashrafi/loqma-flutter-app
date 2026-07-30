import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'api_client.dart';

/// Retries failed connections against alternate API hosts (CDN / apex / api subdomain).
class ApiFallbackInterceptor extends Interceptor {
  ApiFallbackInterceptor(this._dio);

  final Dio _dio;

  static const String _fallbackExtraKey = 'api_fallback_tried';

  static bool isConnectionFailure(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!isConnectionFailure(err)) {
      return handler.next(err);
    }
    if (err.requestOptions.extra[_fallbackExtraKey] == true) {
      return handler.next(err);
    }

    final failedOrigin = _originFromBaseUrl(err.requestOptions.baseUrl);
    final candidates = ApiConstants.allApiOrigins
        .where((origin) => origin != failedOrigin)
        .toList();

    for (final origin in candidates) {
      try {
        final response = await _dio.fetch<dynamic>(
          err.requestOptions.copyWith(
            baseUrl: '$origin/api/v1',
            extra: {
              ...err.requestOptions.extra,
              _fallbackExtraKey: true,
            },
          ),
        );
        await ApiConstants.setActiveOrigin(origin);
        ApiClient.applyActiveOrigin();
        if (kDebugMode) {
          debugPrint('ApiFallbackInterceptor: using $origin');
        }
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        if (!isConnectionFailure(retryErr)) {
          return handler.next(retryErr);
        }
      } catch (_) {}
    }

    handler.next(err);
  }

  static String? _originFromBaseUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) return null;
    final port = uri.hasPort && uri.port != 80 && uri.port != 443
        ? ':${uri.port}'
        : '';
    return '${uri.scheme}://${uri.host}$port';
  }
}
