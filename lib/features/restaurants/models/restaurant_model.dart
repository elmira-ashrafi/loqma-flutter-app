import 'package:equatable/equatable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/l10n/localized_city_fields.dart';
import '../../../../core/l10n/localized_content.dart';

/// Restaurant list item from /restaurants API.
/// Matches: data.items[] with id, name, name_fa, name_ps, slug, description,
/// logo, cover_image, rating, total_reviews, delivery_fee, free_delivery_above,
/// minimum_order, avg_preparation_time, is_featured, accepts_cash,
/// accepts_online_payment, categories[], city{}.
class RestaurantModel extends Equatable {
  const RestaurantModel({
    required this.id,
    required this.name,
    this.nameFa,
    this.namePs,
    this.localizedName,
    this.slug,
    this.description,
    this.descriptionFa,
    this.descriptionPs,
    this.localizedDescription,
    this.image,
    this.logo,
    this.cover,
    this.rating = 0,
    this.totalReviews,
    this.deliveryTime,
    this.deliveryFee = 0,
    this.minimumOrder,
    this.freeDeliveryAbove,
    this.avgPreparationTime,
    this.isFeatured = false,
    this.acceptsCash = true,
    this.acceptsOnlinePayment = false,
    this.isFavorite,
    this.isOpen = true,
    this.address,
    this.cityId,
    this.city = const LocalizedCityFields(),
    this.categoryNames,
    this.categories = const [],
    this.lat,
    this.lng,
  });

  final int id;
  final String name;
  final String? nameFa;
  final String? namePs;
  final String? localizedName;
  final String? slug;
  final String? description;
  final String? descriptionFa;
  final String? descriptionPs;
  final String? localizedDescription;

  String get displayName => LocalizedContent.restaurantDisplayName(
        en: name,
        fa: nameFa,
        ps: namePs,
        localizedFromApi: localizedName,
      );

  String? get displayDescription => LocalizedContent.pickDescriptionNullable(
        en: description,
        fa: descriptionFa,
        ps: descriptionPs,
        localizedFromApi: localizedDescription,
      );

  /// Category line under restaurant name — resolved for the active locale.
  String? get displayCategoryNames =>
      RestaurantCategoryModel.joinedDisplayNames(categories);

  /// Subtitle under restaurant title: localized categories, else localized description.
  String? get displaySubtitle {
    final cats = displayCategoryNames;
    if (cats != null && cats.trim().isNotEmpty) return cats.trim();
    final desc = displayDescription;
    if (desc != null && desc.trim().isNotEmpty) return desc.trim();
    return null;
  }
  final String? image;
  final String? logo;
  final String? cover;
  final double rating;
  final int? totalReviews;
  final String? deliveryTime;
  final double deliveryFee;
  final double? minimumOrder;
  final double? freeDeliveryAbove;
  final int? avgPreparationTime;
  final bool isFeatured;
  final bool acceptsCash;
  final bool acceptsOnlinePayment;
  final bool? isFavorite;
  final bool isOpen;
  final String? address;
  final int? cityId;
  final LocalizedCityFields city;

  String? get cityName => city.isEmpty ? null : city.name;

  String? get displayCityName => city.isEmpty ? null : city.displayName;

  /// Localized city / address line for UI.
  String? get displayLocation {
    final localizedCity = displayCityName;
    final line = address?.trim();
    if (line == null || line.isEmpty) {
      return localizedCity;
    }
    if (city.isEmpty) return line;
    return city.embedInLine(line);
  }

  /// Display string e.g. "Cafes & Sweets • Healthy & Salads"
  final String? categoryNames;
  final List<RestaurantCategoryModel> categories;
  final double? lat;
  final double? lng;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is num ? id.toInt() : (int.tryParse(id?.toString() ?? '0') ?? 0);
    final name = json['name'] as String? ?? json['title'] as String? ?? '';
    final prep = json['avg_preparation_time'] ?? json['avg_prep_time'];
    final avgPrep = prep is num ? prep.toInt() : (prep != null ? int.tryParse(prep.toString()) : null);
    final deliveryTime = json['delivery_time'] as String? ??
        json['deliveryTime'] as String? ??
        (avgPrep != null ? '$avgPrep min' : null);

    final cityRaw = json['city'];
    int? cityId;
    var cityFields = const LocalizedCityFields();
    if (cityRaw is Map) {
      final cityMap = Map<String, dynamic>.from(cityRaw);
      final cid = cityMap['id'];
      cityId = cid is num ? cid.toInt() : int.tryParse(cid?.toString() ?? '');
      cityFields = LocalizedCityFields.fromJson(cityMap);
    }

    return RestaurantModel(
      id: idInt,
      name: name,
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      localizedName: json['localized_name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      descriptionFa: json['description_fa'] as String?,
      descriptionPs: json['description_ps'] as String?,
      localizedDescription: json['localized_description'] as String?,
      image: _imageFromJson(json),
      logo: _urlFromJson(json['logo']),
      cover: _urlFromJson(json['cover_image'] ?? json['cover']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? (json['totalReviews'] as num?)?.toInt(),
      deliveryTime: deliveryTime,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minimumOrder: (json['minimum_order'] as num?)?.toDouble() ?? (json['minimumOrder'] as num?)?.toDouble(),
      freeDeliveryAbove: (json['free_delivery_above'] as num?)?.toDouble() ?? (json['freeDeliveryAbove'] as num?)?.toDouble(),
      avgPreparationTime: avgPrep,
      isFeatured: json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      acceptsCash: json['accepts_cash'] as bool? ?? json['acceptsCash'] as bool? ?? true,
      acceptsOnlinePayment: json['accepts_online_payment'] as bool? ?? json['acceptsOnlinePayment'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? json['isFavorite'] as bool?,
      isOpen: json['is_open'] as bool? ?? json['isOpen'] as bool? ?? true,
      address: _addressFromJson(json),
      cityId: cityId,
      city: cityFields,
      categoryNames: _categoryNamesFromJson(json['categories']),
      categories: _categoriesFromJson(json['categories']),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  static String? _categoryNamesFromJson(dynamic v) =>
      RestaurantCategoryModel.joinedDisplayNames(
        RestaurantCategoryModel.listFromJson(v),
        separator: ' • ',
      );

  static List<RestaurantCategoryModel> _categoriesFromJson(dynamic v) =>
      RestaurantCategoryModel.listFromJson(v);

  static String? _addressFromJson(Map<String, dynamic> json) {
    final street = json['address'] as String?;
    if (street != null && street.trim().isNotEmpty) return street.trim();
    final city = json['city'];
    if (city is Map && city['name'] != null) return city['name'] as String?;
    return null;
  }

  static String? _imageFromJson(Map<String, dynamic> json) {
    final v = json['image'] ?? json['logo'] ?? json['cover'] ?? json['cover_image'];
    if (v is String) return _resolveImageUrl(v);
    if (v is Map && v['url'] != null) return _resolveImageUrl(v['url'] as String);
    return null;
  }

  static String? _urlFromJson(dynamic v) {
    if (v == null) return null;
    if (v is String) return _resolveImageUrl(v);
    if (v is Map && v['url'] != null) return _resolveImageUrl(v['url'] as String);
    return null;
  }

  static String _resolveImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    return url.startsWith('/') ? '$base$url' : '$base/$url';
  }

  @override
  List<Object?> get props => [id, name];
}

/// Category from API categories[]: { id, name, slug }.
class RestaurantCategoryModel extends Equatable {
  const RestaurantCategoryModel({
    required this.id,
    required this.name,
    this.nameFa,
    this.namePs,
    this.localizedName,
    this.slug,
  });

  final int id;
  final String name;
  final String? nameFa;
  final String? namePs;
  final String? localizedName;
  final String? slug;

  String get displayName => LocalizedContent.pick(
        en: name,
        fa: nameFa,
        ps: namePs,
        localizedFromApi: localizedName,
      );

  static List<RestaurantCategoryModel> listFromJson(dynamic v) {
    if (v == null || v is! List) return const [];
    return v
        .whereType<Map>()
        .map((e) => RestaurantCategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static String? joinedDisplayNames(
    List<RestaurantCategoryModel> categories, {
    int max = 2,
    String separator = ', ',
  }) {
    final names = categories
        .map((c) => c.displayName.trim())
        .where((s) => s.isNotEmpty)
        .take(max)
        .toList();
    if (names.isEmpty) return null;
    return names.join(separator);
  }

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is num ? id.toInt() : (int.tryParse(id?.toString() ?? '0') ?? 0);
    return RestaurantCategoryModel(
      id: idInt,
      name: json['name'] as String? ?? '',
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      localizedName: json['localized_name'] as String?,
      slug: json['slug'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}