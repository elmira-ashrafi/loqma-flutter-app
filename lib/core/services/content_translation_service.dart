import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants/api_constants.dart';
import '../controllers/locale_controller.dart';
import '../network/api_client.dart';

/// Calls Laravel Google Translate when descriptions are still English in fa/ps.
class ContentTranslationService {
  ContentTranslationService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;
  final Map<String, String> _cache = {};

  String _localeCode() {
    if (Get.isRegistered<LocaleController>()) {
      return Get.find<LocaleController>().locale.languageCode;
    }
    return 'fa';
  }

  /// Returns translated text, or [source] if translation unavailable.
  Future<String> translateIfNeeded(String source) async {
    final text = source.trim();
    if (text.isEmpty) return source;

    final locale = _localeCode();
    if (locale == 'en') return text;

    final cacheKey = '$locale|$text';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final response = await _dio.post(
        ApiConstants.contentTranslate,
        data: {'text': text},
      );
      final raw = response.data;
      if (raw is Map) {
        final root = Map<String, dynamic>.from(raw);
        final data = root['data'];
        final map = data is Map ? Map<String, dynamic>.from(data) : root;
        final out = map['text'] as String?;
        if (out != null && out.trim().isNotEmpty && out.trim() != text) {
          _cache[cacheKey] = out.trim();
          return out.trim();
        }
      }
    } catch (_) {
      // Keep source on network errors.
    }

    return text;
  }

  void clearCache() => _cache.clear();
}
