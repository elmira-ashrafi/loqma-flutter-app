import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

/// Picks the best localized string for the active app locale.
class LocalizedContent {
  LocalizedContent._();

  static String get currentLocaleCode {
    if (Get.isRegistered<LocaleController>()) {
      return Get.find<LocaleController>().locale.languageCode;
    }
    return 'fa';
  }

  /// Restaurant name/description from admin-entered en/fa/ps fields (never auto-translated).
  static String restaurantDisplayName({
    required String en,
    String? fa,
    String? ps,
    String? localizedFromApi,
    String? localeCode,
  }) =>
      pickRestaurantName(
        en: en,
        fa: fa,
        ps: ps,
        localizedFromApi: localizedFromApi,
        localeCode: localeCode,
      );

  /// Restaurant / brand names: target locale, then other Afghan locale, then API/en.
  static String pickRestaurantName({
    required String en,
    String? fa,
    String? ps,
    String? localizedFromApi,
    String? localeCode,
  }) {
    final english = en.trim();
    final code = localeCode ?? currentLocaleCode;

    if (code == 'en') {
      return english.isNotEmpty
          ? en
          : (localizedFromApi?.trim().isNotEmpty == true ? localizedFromApi!.trim() : en);
    }

    final dari = fa?.trim();
    final pashto = ps?.trim();
    final primary = code == 'fa' ? dari : pashto;
    final alternate = code == 'fa' ? pashto : dari;

    if (primary != null && primary.isNotEmpty && (english.isEmpty || primary != english)) {
      return primary;
    }
    if (alternate != null && alternate.isNotEmpty && (english.isEmpty || alternate != english)) {
      return alternate;
    }

    final localized = localizedFromApi?.trim();
    if (localized != null && localized.isNotEmpty && (english.isEmpty || localized != english)) {
      return localized;
    }

    return english.isNotEmpty ? en : (localized ?? en);
  }

  @Deprecated('Use restaurantDisplayName or model.displayName')
  static String restaurantBrandName(String brandName) => brandName;

  /// Menu items, categories, cities, descriptions, etc.
  static String pick({
    required String en,
    String? fa,
    String? ps,
    String? localizedFromApi,
    String? localeCode,
  }) {
    final code = localeCode ?? currentLocaleCode;
    final english = en.trim();

    // Admin-entered / DB columns always win over API localized_* (may be English on server).
    switch (code) {
      case 'fa':
        final dari = fa?.trim();
        if (dari != null && dari.isNotEmpty) return dari;
        break;
      case 'ps':
        final pashto = ps?.trim();
        if (pashto != null && pashto.isNotEmpty) return pashto;
        break;
      case 'en':
        return english.isNotEmpty ? en : (localizedFromApi?.trim().isNotEmpty == true ? localizedFromApi! : en);
    }

    if (localizedFromApi != null && localizedFromApi.trim().isNotEmpty) {
      final localized = localizedFromApi.trim();
      if (english.isEmpty || localized != english) {
        return localizedFromApi;
      }
    }

    return en;
  }

  static String? pickNullable({
    String? en,
    String? fa,
    String? ps,
    String? localizedFromApi,
    String? localeCode,
  }) {
    final base = en ?? '';
    final hasColumn = (fa?.trim().isNotEmpty ?? false) || (ps?.trim().isNotEmpty ?? false);
    if (base.trim().isEmpty &&
        !hasColumn &&
        (localizedFromApi == null || localizedFromApi.trim().isEmpty)) {
      return null;
    }
    return pick(
      en: base,
      fa: fa,
      ps: ps,
      localizedFromApi: localizedFromApi,
      localeCode: localeCode,
    );
  }

  /// Menu/restaurant descriptions: prefer target locale, then the other Afghan locale, then API/en.
  static String? pickDescriptionNullable({
    String? en,
    String? fa,
    String? ps,
    String? localizedFromApi,
    String? localeCode,
  }) {
    final base = (en ?? '').trim();
    final dari = fa?.trim();
    final pashto = ps?.trim();
    final hasColumn =
        (dari != null && dari.isNotEmpty) || (pashto != null && pashto.isNotEmpty);
    if (base.isEmpty &&
        !hasColumn &&
        (localizedFromApi == null || localizedFromApi.trim().isEmpty)) {
      return null;
    }

    final code = localeCode ?? currentLocaleCode;
    if (code == 'en') {
      return base.isNotEmpty ? en : localizedFromApi;
    }

    final primary = code == 'fa' ? dari : pashto;
    final alternate = code == 'fa' ? pashto : dari;

    if (primary != null && primary.isNotEmpty && (base.isEmpty || primary != base)) {
      return primary;
    }
    if (alternate != null && alternate.isNotEmpty && (base.isEmpty || alternate != base)) {
      return alternate;
    }

    return pickNullable(
      en: en,
      fa: fa,
      ps: ps,
      localizedFromApi: localizedFromApi,
      localeCode: localeCode,
    );
  }

  static Map<String, dynamic> parseLocalizedFields(Map<String, dynamic> json) {
    return {
      'nameFa': json['name_fa'] as String?,
      'namePs': json['name_ps'] as String?,
      'localizedName': json['localized_name'] as String?,
      'descriptionFa': json['description_fa'] as String?,
      'descriptionPs': json['description_ps'] as String?,
      'localizedDescription': json['localized_description'] as String?,
    };
  }
}
