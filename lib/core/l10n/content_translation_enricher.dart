import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../services/content_translation_service.dart';
import '../utils/json_parse.dart';

/// Fills missing localized_description / description_fa|ps on raw API maps via Google Translate.
class ContentTranslationEnricher {
  ContentTranslationEnricher({ContentTranslationService? service})
      : _service = service ?? ContentTranslationService();

  final ContentTranslationService _service;

  String _localeCode() {
    if (Get.isRegistered<LocaleController>()) {
      return Get.find<LocaleController>().locale.languageCode;
    }
    return 'fa';
  }

  Future<void> enrichRestaurantDetailMap(Map<String, dynamic> root) async {
    final locale = _localeCode();
    if (locale == 'en') return;

    final data = _unwrapData(root);
    await _enrichEntityMap(data, locale);

    final menu = data['menu_categories'] ?? data['menuCategories'];
    if (menu is! List) return;

    final futures = <Future<void>>[];
    for (var ci = 0; ci < menu.length; ci++) {
      final cat = menu[ci];
      if (cat is! Map) continue;

      final catMap = _ensureMutableMap(cat);
      if (!identical(catMap, cat)) {
        menu[ci] = catMap;
      }
      futures.add(_enrichEntityMap(catMap, locale));

      final items = catMap['items'];
      if (items is List) {
        for (var ii = 0; ii < items.length; ii++) {
          final item = items[ii];
          if (item is! Map) continue;
          final itemMap = _ensureMutableMap(item);
          if (!identical(itemMap, item)) {
            items[ii] = itemMap;
          }
          futures.add(_enrichEntityMap(itemMap, locale));
        }
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> enrichRestaurantListMaps(List<dynamic> items) async {
    final locale = _localeCode();
    if (locale == 'en') return;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is! Map) continue;
      final map = _ensureMutableMap(item);
      if (!identical(map, item)) {
        items[i] = map;
      }
      await _enrichEntityMap(map, locale);
      await _enrichNameFields(
        map,
        enKey: 'name',
        faKey: 'name_fa',
        psKey: 'name_ps',
        localizedKey: 'localized_name',
        locale: locale,
      );
    }
  }

  /// Fills missing restaurant name translations on customer order list payloads.
  Future<void> enrichOrderListMaps(List<dynamic> orders) async {
    final locale = _localeCode();
    if (locale == 'en') return;
    for (var i = 0; i < orders.length; i++) {
      final item = orders[i];
      if (item is! Map) continue;
      final map = _ensureMutableMap(item);
      if (!identical(map, item)) {
        orders[i] = map;
      }
      await _enrichOrderMap(map, locale);
    }
  }

  Future<void> _enrichOrderMap(Map<String, dynamic> order, String locale) async {
    final restaurant = order['restaurant'];
    if (restaurant is Map) {
      final restaurantMap = _ensureMutableMap(restaurant);
      if (!identical(restaurantMap, restaurant)) {
        order['restaurant'] = restaurantMap;
      }
      await _enrichNameFields(
        restaurantMap,
        enKey: 'name',
        faKey: 'name_fa',
        psKey: 'name_ps',
        localizedKey: 'localized_name',
        locale: locale,
      );
      order['restaurant_name_fa'] ??= restaurantMap['name_fa'];
      order['restaurant_name_ps'] ??= restaurantMap['name_ps'];
      order['restaurant_localized_name'] ??= restaurantMap['localized_name'];
    }

    order['restaurant_name'] ??= (order['restaurant'] is Map
        ? JsonParse.stringFrom((order['restaurant'] as Map)['name'])
        : null);
    await _enrichNameFields(
      order,
      enKey: 'restaurant_name',
      faKey: 'restaurant_name_fa',
      psKey: 'restaurant_name_ps',
      localizedKey: 'restaurant_localized_name',
      locale: locale,
    );

    final rawItems = order['order_items'] ?? order['items'];
    if (rawItems is! List) return;

    final itemFutures = <Future<void>>[];
    for (var ii = 0; ii < rawItems.length; ii++) {
      final item = rawItems[ii];
      if (item is! Map) continue;
      final itemMap = _ensureMutableMap(item);
      if (!identical(itemMap, item)) {
        rawItems[ii] = itemMap;
      }

      for (final nestedKey in ['food', 'product', 'menu_item', 'food_item']) {
        final nested = itemMap[nestedKey];
        if (nested is! Map) continue;
        final nestedMap = _ensureMutableMap(nested);
        if (!identical(nestedMap, nested)) {
          itemMap[nestedKey] = nestedMap;
        }
        itemFutures.add(_enrichNameFields(
          nestedMap,
          enKey: 'name',
          faKey: 'name_fa',
          psKey: 'name_ps',
          localizedKey: 'localized_name',
          locale: locale,
        ));
        itemFutures.add(_enrichEntityMap(nestedMap, locale));
        for (final key in ['name_fa', 'name_ps', 'localized_name', 'description_fa', 'description_ps', 'localized_description']) {
          itemMap.putIfAbsent(key, () => nestedMap[key]);
        }
      }

      itemFutures.add(_enrichNameFields(
        itemMap,
        enKey: 'name',
        faKey: 'name_fa',
        psKey: 'name_ps',
        localizedKey: 'localized_name',
        locale: locale,
      ));
      itemFutures.add(_enrichEntityMap(itemMap, locale));
    }

    if (itemFutures.isNotEmpty) {
      await Future.wait(itemFutures);
    }
  }

  /// Returns the mutable `data` object inside [root] so enrichments survive until [fromJson].
  Map<String, dynamic> _unwrapData(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      final mutable = Map<String, dynamic>.from(data);
      root['data'] = mutable;
      return mutable;
    }
    return root;
  }

  Map<String, dynamic> _ensureMutableMap(Map map) {
    return map is Map<String, dynamic> ? map : Map<String, dynamic>.from(map);
  }

  bool _hasUsableTranslation(String? value, String en) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isNotEmpty && trimmed != en;
  }

  Future<void> _enrichNameFields(
    Map<String, dynamic> json,
    {
    required String enKey,
    required String faKey,
    required String psKey,
    required String localizedKey,
    required String locale,
  }) async {
    final en = JsonParse.stringFrom(json[enKey])?.trim() ?? '';
    if (en.isEmpty) return;

    final fa = JsonParse.stringFrom(json[faKey])?.trim();
    final ps = JsonParse.stringFrom(json[psKey])?.trim();
    final localized = JsonParse.stringFrom(json[localizedKey])?.trim();
    final targetColumn = locale == 'fa' ? fa : ps;
    final alternateColumn = locale == 'fa' ? ps : fa;

    if (_hasUsableTranslation(targetColumn, en)) {
      json[localizedKey] = targetColumn;
      return;
    }

    if (_hasUsableTranslation(alternateColumn, en)) {
      json[localizedKey] = alternateColumn;
      if (locale == 'fa') {
        json[faKey] ??= alternateColumn;
      } else if (locale == 'ps') {
        json[psKey] ??= alternateColumn;
      }
      return;
    }

    if (_hasUsableTranslation(localized, en)) {
      return;
    }

    final translated = await _service.translateIfNeeded(en);
    if (!_hasUsableTranslation(translated, en)) return;

    json[localizedKey] = translated;
    if (locale == 'fa') {
      json[faKey] = translated;
    } else if (locale == 'ps') {
      json[psKey] = translated;
    }
  }

  Future<void> _enrichEntityMap(Map<String, dynamic> json, String locale) async {
    final en = JsonParse.stringFrom(json['description'])?.trim() ?? '';
    if (en.isEmpty) return;

    final fa = JsonParse.stringFrom(json['description_fa'])?.trim();
    final ps = JsonParse.stringFrom(json['description_ps'])?.trim();
    final localized = JsonParse.stringFrom(json['localized_description'])?.trim();
    final targetColumn = locale == 'fa' ? fa : ps;
    final alternateColumn = locale == 'fa' ? ps : fa;

    if (_hasUsableTranslation(targetColumn, en)) {
      json['localized_description'] = targetColumn;
      return;
    }

    // Many items only have description_fa in DB; use it for Pashto before auto-translate.
    if (_hasUsableTranslation(alternateColumn, en)) {
      json['localized_description'] = alternateColumn;
      if (locale == 'fa') {
        json['description_fa'] ??= alternateColumn;
      } else if (locale == 'ps') {
        json['description_ps'] ??= alternateColumn;
      }
      return;
    }

    if (_hasUsableTranslation(localized, en)) {
      return;
    }

    final translated = await _service.translateIfNeeded(en);
    if (!_hasUsableTranslation(translated, en)) return;

    json['localized_description'] = translated;
    if (locale == 'fa') {
      json['description_fa'] = translated;
    } else if (locale == 'ps') {
      json['description_ps'] = translated;
    }
  }
}
