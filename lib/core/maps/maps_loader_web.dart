// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Injects the Maps JavaScript API before the Flutter app uses [GoogleMap] on web.
Future<void> ensureGoogleMapsScriptLoaded() async {
  if (_mapsScriptAlreadyPresent()) {
    return;
  }

  var key = const String.fromEnvironment('GOOGLE_MAPS_WEB_KEY', defaultValue: '');
  if (key.isEmpty) {
    key = await _fetchWebKeyFromApi() ?? '';
  }
  if (key.isEmpty) {
    return;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..async = true
    ..defer = true
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$key&loading=async';
  script.onLoad.listen((_) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(StateError('Failed to load Google Maps JavaScript API'));
    }
  });
  html.document.head?.append(script);
  await completer.future.timeout(
    const Duration(seconds: 30),
    onTimeout: () => throw TimeoutException('Google Maps script'),
  );
}

bool _mapsScriptAlreadyPresent() {
  for (final n in html.document.querySelectorAll('script')) {
    if (n is! html.ScriptElement) continue;
    final src = n.src;
    if (src.contains('maps.googleapis.com/maps/api/js')) {
      return true;
    }
  }
  return false;
}

Future<String?> _fetchWebKeyFromApi() async {
  try {
    final r = await Dio().get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.mapsConfig}',
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );
    final map = r.data ?? {};
    final raw = map['data'] ?? map;
    if (raw is Map<String, dynamic>) {
      final k = raw['web_maps_api_key'] as String?;
      if (k != null && k.trim().isNotEmpty) {
        return k.trim();
      }
    }
  } catch (_) {}
  return null;
}
