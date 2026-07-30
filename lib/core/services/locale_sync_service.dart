import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// Persists app locale to the authenticated user's `language` column on the API.
class LocaleSyncService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> syncLanguageToBackend(String languageCode) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) return;

    try {
      await ApiClient.dio.patch(
        ApiConstants.customerSettingsLanguage,
        data: {'language': languageCode},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return;
      debugPrint('LocaleSyncService: failed to sync language: $e');
    } catch (e) {
      debugPrint('LocaleSyncService: $e');
    }
  }
}
