import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_fallback_interceptor.dart';
import 'api_origin_sync.dart';
import 'cdn_session_cookies.dart';
import 'cdn_warmup_host.dart';
import 'edge_security.dart';

/// Completes Hostinger/hCDN JavaScript challenges via a hidden WebView.
class CdnBrowserWarmup {
  CdnBrowserWarmup._();

  static final Map<String, Completer<void>> _originWarmups = {};
  static final Set<String> _clearedOrigins = {};
  static Future<void> _webviewLock = Future<void>.value();
  static Future<void>? _bootstrapWarmup;

  static Future<T> _withWebViewLock<T>(Future<T> Function() action) {
    final run = _webviewLock.then((_) => action());
    _webviewLock = run.then((_) {}, onError: (_) {});
    return run;
  }

  static bool isOriginCleared(String origin) => _clearedOrigins.contains(origin);

  static Future<void> waitForHostReady() => CdnWarmupHost.ready.future;

  static Future<void> warmupActiveOrigin() {
    _bootstrapWarmup ??= _runBootstrapWarmup();
    return _bootstrapWarmup!;
  }

  static Future<void> _runBootstrapWarmup() async {
    if (kIsWeb) return;
    await waitForHostReady();
    for (var i = 0; i < 20; i++) {
      if (CdnWarmupHost.controller != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (CdnWarmupHost.controller == null) {
      if (kDebugMode) debugPrint('CdnBrowserWarmup: WebView host missing');
      return;
    }

    for (final origin in ApiConstants.allApiOrigins) {
      if (isOriginCleared(origin)) continue;
      try {
        await _warmOrigin(origin, null);
        await setActiveApiOrigin(origin);
        if (kDebugMode) {
          debugPrint('CdnBrowserWarmup: bootstrap cleared $origin');
        }
        return;
      } catch (error) {
        if (kDebugMode) {
          debugPrint('CdnBrowserWarmup: bootstrap failed for $origin: $error');
        }
      }
    }
  }

  static Future<void> clearOrigin(String origin) async {
    _clearedOrigins.add(origin);
    for (final alt in ApiConstants.allApiOrigins) {
      _clearedOrigins.add(alt);
    }
    final pending = _originWarmups.remove(origin);
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  static String originFromUri(Uri uri) =>
      CdnSessionCookies.originFromUri(uri);

  static Future<void> _syncCookies(String origin) async {
    await CdnSessionCookies.syncFromWebView(origin);
    await CdnSessionCookies.syncFromWebView('$origin/api/v1/home');
  }

  static Future<Response<dynamic>> fetchGetResponse(
    RequestOptions options,
  ) =>
      fetchResponse(options);

  /// WebView tunnel for any HTTP method (used when hCDN blocks native Dio).
  static Future<Response<dynamic>> fetchResponse(
    RequestOptions options,
  ) async {
    await warmupActiveOrigin();
    return _withWebViewLock(() async {
      final origin = originFromUri(options.uri);
      if (!isOriginCleared(origin)) {
        await _warmOrigin(origin, options);
      }
      return fetchViaWebView(options);
    });
  }

  /// WebView tunnel for any HTTP method (used when hCDN blocks native Dio).
  static Future<Response<dynamic>> fetchViaWebView(
    RequestOptions options,
  ) async {
    final host = CdnWarmupHost.controller;
    if (host == null) {
      throw StateError('CDN WebView host is not mounted');
    }
    final origin = originFromUri(options.uri);
    final body = options.data;
    final bodyStr = body == null
        ? null
        : body is String
            ? body
            : (body is Map || body is List)
                ? jsonEncode(body)
                : body.toString();
    final raw = await host.fetchApi(
      options.uri,
      method: options.method,
      body: bodyStr,
      headers: _webviewHeaders(options),
      timeout: Duration(milliseconds: AppConstants.cdnChallengeTimeoutMs),
    );
    final data = _parseWebViewPayload(raw);
    if (data is String && looksLikeBrowserChallengePage(data)) {
      throw StateError('CDN browser check still active for $origin');
    }
    await _syncCookies(origin);
    await clearOrigin(origin);
    return Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
      data: data,
    );
  }

  static dynamic _parseWebViewPayload(dynamic raw) {
    if (raw is Map && raw['error'] != null) {
      throw StateError(raw['error'].toString());
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return raw;
      if (looksLikeBrowserChallengePage(trimmed)) return trimmed;
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        return jsonDecode(trimmed);
      }
    }
    return raw;
  }

  static Future<void> _warmOrigin(
    String origin,
    RequestOptions? template,
  ) async {
    final existing = _originWarmups[origin];
    if (existing != null) {
      await existing.future;
      return;
    }

    final completer = Completer<void>();
    _originWarmups[origin] = completer;

    try {
      if (kDebugMode) {
        debugPrint('CdnBrowserWarmup: passing JS challenge for $origin');
      }

      await _withWebViewLock(() async {
        final host = CdnWarmupHost.controller;
        if (host == null) {
          throw StateError('CDN WebView host is not mounted');
        }

        await host.fetchJson(
          _probeUri(origin, template),
          headers: template != null
              ? _webviewHeaders(template)
              : const {'Accept': 'application/json'},
          timeout: Duration(
            milliseconds: AppConstants.cdnChallengeTimeoutMs,
          ),
        );
      });

      await _syncCookies(origin);
      await clearOrigin(origin);

      if (kDebugMode) {
        debugPrint('CdnBrowserWarmup: cleared $origin');
      }
    } catch (error) {
      _originWarmups.remove(origin);
      rethrow;
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  static Uri _probeUri(String origin, RequestOptions? template) {
    final lang = template?.uri.queryParameters['lang'];
    final query = lang != null ? {'lang': lang} : null;
    return Uri.parse('$origin/api/v1/home').replace(queryParameters: query);
  }

  static Map<String, String> _webviewHeaders(RequestOptions options) {
    final headers = <String, String>{'Accept': 'application/json'};
    for (final entry in options.headers.entries) {
      final value = entry.value;
      if (value == null) continue;
      final key = entry.key.toString();
      if (key.toLowerCase() == 'user-agent') continue;
      headers[key] = value.toString();
    }
    return headers;
  }

  static Future<Response<dynamic>> fetchGetViaWebView(
    RequestOptions options,
  ) =>
      fetchViaWebView(options);

  static Future<Response<dynamic>> retryWithCookies(
    Dio dio,
    RequestOptions options,
  ) async {
    await warmupActiveOrigin();
    final origin = originFromUri(options.uri);
    if (!isOriginCleared(origin)) {
      await _warmOrigin(origin, options);
    }
    return dio.fetch<dynamic>(
      options.copyWith(
        extra: {
          ...options.extra,
          AppConstants.cdnSessionClearedExtraKey: true,
          AppConstants.cdnChallengeHandledExtraKey: true,
        },
      ),
    );
  }

  static Future<Response<dynamic>?> tryAlternateOrigins(
    Dio dio,
    RequestOptions options,
  ) async {
    if (options.extra[AppConstants.cdnChallengeHandledExtraKey] == true) {
      return null;
    }
    final failedOrigin = originFromUri(options.uri);
    for (final origin in ApiConstants.allApiOrigins) {
      if (origin == failedOrigin) continue;
      try {
        final response = await dio.fetch<dynamic>(
          options.copyWith(
            baseUrl: '$origin/api/v1',
            extra: {
              ...options.extra,
              AppConstants.cdnOriginProbeExtraKey: true,
              AppConstants.cdnChallengeHandledExtraKey: true,
            },
          ),
        );
        if (isBrowserChallengeResponse(response)) continue;
        await setActiveApiOrigin(origin);
        return response;
      } on DioException catch (err) {
        final body = err.response;
        if (body != null && isBrowserChallengeResponse(body)) continue;
        if (ApiFallbackInterceptor.isConnectionFailure(err)) continue;
        rethrow;
      }
    }
    return null;
  }
}
