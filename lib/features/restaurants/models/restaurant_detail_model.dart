import 'package:equatable/equatable.dart';

import '../../../core/l10n/localized_entity_fields.dart';
import '../../../core/utils/json_parse.dart';
import 'restaurant_model.dart';

/// Full restaurant detail with menu categories and items (from /restaurants/{id}).
class RestaurantDetailModel extends Equatable {
  const RestaurantDetailModel({
    required this.restaurant,
    this.menuCategories = const [],
  });

  final RestaurantModel restaurant;
  final List<MenuCategory> menuCategories;

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    // API: { data: { restaurant?: {...}, menu_categories?: [...] } } or { data: { ...restaurant, menu_categories } }
    final data = json.containsKey('data') ? JsonParse.mapFrom(json['data']) : JsonParse.mapFrom(json);
    final rest = data['restaurant'] ?? data;
    final restMap = JsonParse.mapFrom(rest);
    return RestaurantDetailModel(
      restaurant: RestaurantModel.fromJson(restMap),
      menuCategories: JsonParse.listOfMaps(data['menu_categories'] ?? data['menuCategories'])
          .map(MenuCategory.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [restaurant, menuCategories];
}

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.items = const [],
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final List<MenuItemModel> items;

  String get displayName => localized.displayName;

  String displayNameFor(String localeCode) => localized.displayNameFor(localeCode);

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return MenuCategory(
      id: (json['id'] as num).toInt(),
      name: fields.name,
      localized: fields,
      items: JsonParse.listOfMaps(json['items'] ?? json['foods']).map(MenuItemModel.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.image,
    this.price = 0,
    this.variants = const [],
    this.addons = const [],
    this.variantGroupName,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final String? image;
  final double price;
  final List<VariantModel> variants;
  final List<AddonModel> addons;

  /// First variant group label from API (e.g. "Size").
  final String? variantGroupName;

  String get displayName => localized.displayName;
  String? get displayDescription => localized.displayDescription;

  String displayNameFor(String localeCode) => localized.displayNameFor(localeCode);

  String? displayDescriptionFor(String localeCode) => localized.displayDescriptionFor(localeCode);

  /// Localized text for UI (falls back via [LocalizedContent], not raw English only).
  String? get description => displayDescription;

  /// True when the diner must pick among multiple size options.
  bool get hasSelectableSizes => variants.length > 1;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    final sizeVariants = _parseSizeVariants(json);
    return MenuItemModel(
      id: (json['id'] as num).toInt(),
      name: fields.name,
      localized: fields,
      image: JsonParse.stringFrom(json['image']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      variants: sizeVariants,
      addons: _parseAddons(json),
      variantGroupName: _parseVariantGroupName(json),
    );
  }

  /// Prefer an explicit Size group; ignore empty / single leftover size rows.
  static List<VariantModel> _parseSizeVariants(Map<String, dynamic> json) {
    final groups = JsonParse.listOfMaps(json['variant_groups'] ?? json['variantGroups']);
    if (groups.isNotEmpty) {
      Map<String, dynamic>? sizeGroup;
      for (final group in groups) {
        final name = (JsonParse.stringFrom(group['name']) ?? '').toLowerCase().trim();
        if (name == 'size') {
          sizeGroup = group;
          break;
        }
        sizeGroup ??= group;
      }
      if (sizeGroup != null) {
        final fromGroup = JsonParse.listOfMaps(sizeGroup['variants'])
            .map(VariantModel.fromJson)
            .toList();
        if (fromGroup.isNotEmpty) return fromGroup;
      }
    }

    final flat = JsonParse.listOfMaps(json['variants']);
    if (flat.isNotEmpty) {
      return flat.map(VariantModel.fromJson).toList();
    }
    return const [];
  }

  static List<AddonModel> _parseAddons(Map<String, dynamic> json) {
    final flat = JsonParse.listOfMaps(json['addons']);
    if (flat.isNotEmpty) {
      return flat.map(AddonModel.fromJson).toList();
    }
    final groups = JsonParse.listOfMaps(json['addon_groups'] ?? json['addonGroups']);
    final addons = <AddonModel>[];
    for (final group in groups) {
      addons.addAll(
        JsonParse.listOfMaps(group['addons']).map(AddonModel.fromJson),
      );
    }
    return addons;
  }

  static String? _parseVariantGroupName(Map<String, dynamic> json) {
    final groups = JsonParse.listOfMaps(json['variant_groups'] ?? json['variantGroups']);
    if (groups.isEmpty) return null;
    for (final group in groups) {
      final name = JsonParse.stringFrom(group['name']);
      if (name != null && name.toLowerCase().trim() == 'size') return name;
    }
    return JsonParse.stringFrom(groups.first['name']);
  }

  @override
  List<Object?> get props => [id, name];
}

class VariantModel extends Equatable {
  const VariantModel({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.price = 0,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final double price;
  final bool isDefault;

  String get displayName => localized.displayName;

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return VariantModel(
      id: (json['id'] as num).toInt(),
      name: fields.name,
      localized: fields,
      price: (json['price'] as num?)?.toDouble() ??
          (json['price_adjustment'] as num?)?.toDouble() ??
          0,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class AddonModel extends Equatable {
  const AddonModel({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.price = 0,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final double price;

  String get displayName => localized.displayName;

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return AddonModel(
      id: (json['id'] as num).toInt(),
      name: fields.name,
      localized: fields,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
