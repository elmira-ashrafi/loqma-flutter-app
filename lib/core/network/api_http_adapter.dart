import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Native HTTP adapter for Dio (default TLS — never override [HttpClient.connectionFactory]).
void configureApiHttpAdapter(Dio dio) {
  if (kIsWeb) return;
  dio.httpClientAdapter = IOHttpClientAdapter();
}

/// Standalone Dio for one-off calls (e.g. token refresh).
Dio createNetworkDio() {
  final dio = Dio();
  configureApiHttpAdapter(dio);
  return dio;
}
