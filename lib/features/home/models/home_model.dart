import 'package:equatable/equatable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/l10n/localized_banner_fields.dart';
import '../../../../core/l10n/localized_city_fields.dart';
import '../../../../core/l10n/localized_content.dart';
import '../../../../core/l10n/localized_entity_fields.dart';
import '../../restaurants/models/restaurant_model.dart';

/// Home API response: featured restaurants, popular foods, promotions, etc.
class HomeResponse extends Equatable {
  const HomeResponse({
    this.featuredRestaurants = const [],
    this.popularRestaurants = const [],
    this.popularFoods = const [],
    this.nearbyRestaurants = const [],
    this.promotions = const [],
    this.categories = const [],
    this.heroBanners = const [],
    this.promoBanners = const [],
  });

  final List<RestaurantItem> featuredRestaurants;
  final List<RestaurantItem> popularRestaurants;
  final List<FoodItem> popularFoods;
  final List<RestaurantItem> nearbyRestaurants;
  final List<PromotionItem> promotions;
  final List<CategoryItem> categories;
  final List<BannerItem> heroBanners;
  final List<BannerItem> promoBanners;

  /// Featured first; falls back to popular when none are marked featured.
  List<RestaurantItem> get topRestaurants =>
      featuredRestaurants.isNotEmpty ? featuredRestaurants : popularRestaurants;

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return HomeResponse(
      featuredRestaurants: _listFromJson(
        data['featured_restaurants'] ?? data['featuredRestaurants'],
        RestaurantItem.fromJson,
      ),
      popularRestaurants: _listFromJson(
        data['popular_restaurants'] ?? data['popularRestaurants'],
        RestaurantItem.fromJson,
      ),
      popularFoods: _listFromJson(
        data['popular_foods'] ?? data['popularFoods'],
        FoodItem.fromJson,
      ),
      nearbyRestaurants: _listFromJson(
        data['nearby_restaurants'] ?? data['nearbyRestaurants'],
        RestaurantItem.fromJson,
      ),
      promotions: _listFromJson(
        data['promotions'] ?? data['promotions'],
        PromotionItem.fromJson,
      ),
      categories: _listFromJson(
        data['categories'] ?? data['categories'],
        CategoryItem.fromJson,
      ),
      heroBanners: _listFromJson(
        data['hero_banners'] ?? data['heroBanners'],
        BannerItem.fromJson,
      ),
      promoBanners: _listFromJson(
        data['promo_banners'] ?? data['promoBanners'],
        BannerItem.fromJson,
      ),
    );
  }

  static List<T> _listFromJson<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null || raw is! List) return [];
    final items = <T>[];
    for (final e in raw) {
      if (e is! Map<String, dynamic>) continue;
      try {
        items.add(fromJson(e));
      } catch (_) {}
    }
    return items;
  }

  @override
  List<Object?> get props => [
        featuredRestaurants,
        popularRestaurants,
        popularFoods,
        nearbyRestaurants,
        promotions,
        categories,
        heroBanners,
        promoBanners,
      ];
}

class RestaurantItem extends Equatable {
  const RestaurantItem({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.description,
    this.image,
    this.rating = 0,
    this.deliveryTime,
    this.distance,
    this.isOpen = true,
    this.totalReviews,
    this.avgPreparationTime,
    this.isFeatured = false,
    this.categoryNames,
    this.categories = const [],
    this.cityId,
    this.city = const LocalizedCityFields(),
    this.deliveryFee,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final String? description;
  final String? image;
  final double rating;

  String get displayName => localized.displayName;
  String? get displayDescription => localized.displayDescription;

  String? get displayCategoryNames =>
      RestaurantCategoryModel.joinedDisplayNames(categories);

  String? get displaySubtitle {
    final cats = displayCategoryNames;
    if (cats != null && cats.trim().isNotEmpty) return cats.trim();
    final desc = displayDescription;
    if (desc != null && desc.trim().isNotEmpty) return desc.trim();
    return null;
  }

  final LocalizedCityFields city;
  final int? cityId;

  String? get displayLocation => city.isEmpty ? null : city.displayName;

  final String? deliveryTime;
  final String? distance;
  final bool isOpen;
  final int? totalReviews;
  final int? avgPreparationTime;
  final bool isFeatured;
  /// e.g. "Afghan Cuisine, Grills & Kebabs"
  final String? categoryNames;
  final List<RestaurantCategoryModel> categories;
  final double? deliveryFee;

  factory RestaurantItem.fromJson(Map<String, dynamic> json) {
    final prep = json['avg_preparation_time'] ?? json['avg_prep_time'];
    final avgPrep = prep is num ? prep.toInt() : (prep != null ? int.tryParse(prep.toString()) : null);
    final fields = LocalizedEntityFields.fromJson(json, isRestaurantBrand: true);
    int? cityId;
    final cityRaw = json['city'];
    if (cityRaw is Map) {
      final cid = cityRaw['id'];
      cityId = cid is num ? cid.toInt() : int.tryParse(cid?.toString() ?? '');
    }
    return RestaurantItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: fields.name,
      localized: fields,
      image: _resolveImageUrl(
        json['image'] ??
            json['logo'] ??
            json['cover_image'] ??
            json['cover'],
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      deliveryTime: json['delivery_time'] as String? ?? json['deliveryTime'] as String?,
      distance: json['distance'] as String?,
      isOpen: json['is_open'] as bool? ?? json['isOpen'] as bool? ?? true,
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
      avgPreparationTime: avgPrep,
      isFeatured: json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      categoryNames: _categoryNamesFromJson(json['categories']),
      categories: RestaurantCategoryModel.listFromJson(json['categories']),
      cityId: cityId,
      city: LocalizedCityFields.fromJson(json['city']),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
    );
  }

  static String? _resolveImageUrl(dynamic v) {
    if (v == null) return null;
    if (v is String) return _toAbsoluteUrl(v);
    if (v is Map && v['url'] != null) return _toAbsoluteUrl(v['url'] as String);
    return null;
  }

  /// Resolve relative image paths to full URL using API base. Use from same library.
  static String _toAbsoluteUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    return url.startsWith('/') ? '$base$url' : '$base/$url';
  }

  @override
  List<Object?> get props => [id, name];
}

String? _categoryNamesFromJson(dynamic v) =>
    RestaurantCategoryModel.joinedDisplayNames(
      RestaurantCategoryModel.listFromJson(v),
    );

class FoodItem extends Equatable {
  const FoodItem({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.description,
    this.image,
    this.price = 0,
    this.restaurantId,
    this.restaurantName,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final String? description;
  final String? image;
  final double price;
  final int? restaurantId;
  final String? restaurantName;

  String get displayName => localized.displayName;
  String? get displayDescription => localized.displayDescription;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return FoodItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: fields.name,
      localized: fields,
      description: fields.displayDescription,
      image: _resolveImageUrl(json['image']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      restaurantId: (json['restaurant_id'] as num?)?.toInt() ?? (json['restaurantId'] as num?)?.toInt(),
      restaurantName: json['restaurant_name'] as String? ?? json['restaurantName'] as String?,
    );
  }

  static String? _resolveImageUrl(dynamic v) {
    if (v == null) return null;
    if (v is String) return RestaurantItem._toAbsoluteUrl(v);
    if (v is Map && v['url'] != null) return RestaurantItem._toAbsoluteUrl(v['url'] as String);
    return null;
  }

  @override
  List<Object?> get props => [id, name];
}

class PromotionItem extends Equatable {
  const PromotionItem({
    required this.id,
    this.title,
    this.subtitle,
    this.image,
    this.badge,
    this.colorHex,
  });

  final int id;
  final String? title;
  final String? subtitle;
  final String? image;
  final String? badge;
  final String? colorHex;

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    final v = json['image'];
    String? imageUrl;
    if (v is String) imageUrl = RestaurantItem._toAbsoluteUrl(v);
    else if (v is Map && v['url'] != null) imageUrl = RestaurantItem._toAbsoluteUrl(v['url'] as String);
    return PromotionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      image: imageUrl,
      badge: json['badge'] as String?,
      colorHex: json['color'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}

class CategoryItem extends Equatable {
  const CategoryItem({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.slug,
    this.icon,
    this.image,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final String? slug;
  final String? icon;
  final String? image;

  String get displayName => localized.displayName;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    final v = json['image'] ?? json['icon'];
    String? imageUrl;
    if (v is String) imageUrl = RestaurantItem._toAbsoluteUrl(v);
    else if (v is Map && v['url'] != null) imageUrl = RestaurantItem._toAbsoluteUrl(v['url'] as String);
    final fields = LocalizedEntityFields.fromJson(json);
    return CategoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: fields.name,
      localized: fields,
      slug: json['slug'] as String?,
      icon: json['icon'] is String ? json['icon'] as String? : null,
      image: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Banner item from /banners API.
class BannerItem extends Equatable {
  const BannerItem({
    required this.id,
    this.image,
    this.localized = const LocalizedBannerFields(),
    this.link,
    this.linkType,
    this.cityId,
    this.order = 0,
  });

  final int id;
  final String? image;
  final LocalizedBannerFields localized;
  final String? link;
  final String? linkType;
  final int? cityId;
  final int order;

  String? get displayTitle => localized.displayTitle;
  String? get displaySubtitle => localized.displaySubtitle;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    // Prefer image_mobile for mobile app when present
    final v = json['image_mobile'] ?? json['image'];
    String? imageUrl;
    if (v == null) {
      imageUrl = null;
    } else if (v is String) {
      imageUrl = v.startsWith('http') ? v : RestaurantItem._toAbsoluteUrl(v);
    } else if (v is Map && v['url'] != null) {
      imageUrl = RestaurantItem._toAbsoluteUrl(v['url'] as String);
    }
    final rawCity = json['city_id'] ?? json['cityId'];
    int? cityId;
    if (rawCity is num) {
      cityId = rawCity.toInt();
    } else if (rawCity is String) {
      cityId = int.tryParse(rawCity);
    }
    return BannerItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      image: imageUrl,
      localized: LocalizedBannerFields.fromJson(json),
      link: json['link_value'] as String? ??
          json['link'] as String? ??
          (json['action'] is Map ? (json['action'] as Map)['deep_link'] as String? : null),
      linkType: json['link_type'] as String? ??
          (json['action'] is Map ? (json['action'] as Map)['type'] as String? : null),
      cityId: cityId,
      order: (json['order'] as num?)?.toInt() ?? (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, cityId];
}
