import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'cdn_browser_warmup.dart';
import 'edge_security.dart';

/// Handles Hostinger hCDN "Checking your browser" pages for the mobile API.
class ApiSecurityChallengeInterceptor extends Interceptor {
  ApiSecurityChallengeInterceptor(this._dio);

  final Dio _dio;

  bool _alreadyHandled(RequestOptions options) =>
      options.extra[AppConstants.cdnChallengeHandledExtraKey] == true;

  RequestOptions _markHandled(RequestOptions options) => options.copyWith(
        extra: {
          ...options.extra,
          AppConstants.cdnChallengeHandledExtraKey: true,
        },
      );

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!isBrowserChallengeResponse(response) || _alreadyHandled(response.requestOptions)) {
      return handler.next(response);
    }
    try {
      final resolved = await _recoverFromChallenge(response.requestOptions);
      return handler.resolve(resolved);
    } on DioException catch (err) {
      return handler.reject(err);
    } catch (error) {
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response == null ||
        !isBrowserChallengeResponse(response) ||
        _alreadyHandled(err.requestOptions)) {
      return handler.next(err);
    }
    try {
      final resolved = await _recoverFromChallenge(err.requestOptions);
      return handler.resolve(resolved);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } catch (error) {
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  Future<Response<dynamic>> _recoverFromChallenge(
    RequestOptions options,
  ) async {
    final marked = _markHandled(options);

    if (kDebugMode) {
      debugPrint(
        'ApiSecurityChallengeInterceptor: WebView tunnel for '
        '${marked.method} ${marked.uri}',
      );
    }

    try {
      return await CdnBrowserWarmup.fetchResponse(marked);
    } catch (webviewError) {
      if (kDebugMode) {
        debugPrint(
          'ApiSecurityChallengeInterceptor: WebView failed, cookie retry: $webviewError',
        );
      }
    }

    return CdnBrowserWarmup.retryWithCookies(_dio, marked);
  }
}
