import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

/// Sends app locale to Laravel API (`Accept-Language`, `X-App-Locale`, and `lang` query).
class LocaleInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final code = _currentLanguageCode();
    options.headers['Accept-Language'] = code;
    options.headers['X-App-Locale'] = code;
    options.queryParameters = {
      ...options.queryParameters,
      'lang': code,
    };
    handler.next(options);
  }

  static String _currentLanguageCode() {
    if (Get.isRegistered<LocaleController>()) {
      return Get.find<LocaleController>().locale.languageCode;
    }
    return 'fa';
  }
}
