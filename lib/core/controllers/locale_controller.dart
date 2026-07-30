import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../constants/afghanistan_region.dart';
import '../../l10n/locale_source.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../services/content_translation_service.dart';
import '../services/locale_sync_service.dart';

/// Persists and exposes app locale. RTL for Pashto (ps) and Dari (fa), LTR for English (en).
/// First launch defaults to [AfghanistanRegion.defaultLocale] (Dari for Afghanistan).
class LocaleController extends GetxController {
  LocaleController() : _locale = AfghanistanRegion.defaultLocale.obs;

  final Rx<Locale> _locale;

  Locale get locale => _locale.value;

  /// Observable for [ever] / [Obx] when locale changes.
  Rx<Locale> get localeRx => _locale;
  set locale(Locale value) {
    _locale.value = value;
    _persist(value);
  }

  /// RTL for ps and fa; LTR for en.
  TextDirection get textDirection {
    final code = _locale.value.languageCode;
    if (code == 'ps' || code == 'fa') return TextDirection.rtl;
    return TextDirection.ltr;
  }

  static const Locale localeEn = Locale('en');
  static const Locale localePs = Locale('ps');
  static const Locale localeFa = Locale('fa');

  /// Same order and codes as [LocaleCodes.supportedLocales] / Laravel `lang/{en,fa,ps}`.
  static List<Locale> get supported => LocaleCodes.supportedLocales;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.localeKey);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      _locale.value = Locale(code);
      return;
    }
    _locale.value = AfghanistanRegion.defaultLocale;
    await prefs.setString(AppConstants.localeKey, AfghanistanRegion.defaultLocale.languageCode);
  }

  Future<void> _persist(Locale value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.localeKey, value.languageCode);
  }

  void setLocale(Locale value) {
    locale = value;
    Get.updateLocale(value);
    ContentTranslationService().clearCache();
    LocaleSyncService.syncLanguageToBackend(value.languageCode);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshAll();
    }
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().recalculate();
    }
  }
}
