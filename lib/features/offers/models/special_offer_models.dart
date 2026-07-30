import 'package:equatable/equatable.dart';

import '../../../core/l10n/localized_content.dart';
import '../../../core/l10n/localized_entity_fields.dart';

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int? _asIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Restaurant summary bundled with a special-offer item (public /offers).
class SpecialOfferRestaurantBrief extends Equatable {
  const SpecialOfferRestaurantBrief({
    required this.id,
    required this.name,
    this.nameFa,
    this.namePs,
    this.localizedName,
    this.slug,
    this.logo,
    this.rating = 0,
    this.deliveryFee = 0,
  });

  final int id;
  final String name;
  final String? nameFa;
  final String? namePs;
  final String? localizedName;
  final String? slug;

  String get displayName => LocalizedContent.restaurantDisplayName(
        en: name,
        fa: nameFa,
        ps: namePs,
        localizedFromApi: localizedName,
      );
  final String? logo;
  final double rating;
  final double deliveryFee;

  factory SpecialOfferRestaurantBrief.fromJson(Map<String, dynamic> json) {
    return SpecialOfferRestaurantBrief(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      localizedName: json['localized_name'] as String?,
      slug: json['slug'] as String?,
      logo: json['logo'] as String?,
      rating: _asDouble(json['rating']),
      deliveryFee: _asDouble(json['delivery_fee']),
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

/// Menu item row from GET /offers.
class SpecialOfferFoodItem extends Equatable {
  const SpecialOfferFoodItem({
    required this.id,
    required this.foodCategoryId,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.description,
    required this.price,
    required this.discountedPrice,
    this.discountStart,
    this.discountEnd,
    this.offerLabel,
    this.imageUrl,
    this.isAvailable = true,
    this.discountPercent,
  });

  final int id;
  final int foodCategoryId;
  final String name;
  final LocalizedEntityFields localized;
  final String? description;
  final double price;
  final double discountedPrice;
  final String? discountStart;
  final String? discountEnd;
  final String? offerLabel;
  final String? imageUrl;
  final bool isAvailable;
  final int? discountPercent;

  String get displayName => localized.displayName;
  String? get displayDescription => localized.displayDescription;

  factory SpecialOfferFoodItem.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return SpecialOfferFoodItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      foodCategoryId: (json['food_category_id'] as num?)?.toInt() ?? 0,
      name: fields.name,
      localized: fields,
      description: fields.displayDescription,
      price: _asDouble(json['price']),
      discountedPrice: _asDouble(json['discounted_price']),
      discountStart: json['discount_start'] as String?,
      discountEnd: json['discount_end'] as String?,
      offerLabel: json['offer_label'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] == false ? false : true,
      discountPercent: _asIntNullable(json['discount_percent']),
    );
  }

  @override
  List<Object?> get props => [id, foodCategoryId, name, discountedPrice];
}

class SpecialOfferRow extends Equatable {
  const SpecialOfferRow({
    required this.foodItem,
    required this.restaurant,
  });

  final SpecialOfferFoodItem foodItem;
  final SpecialOfferRestaurantBrief restaurant;

  factory SpecialOfferRow.fromJson(Map<String, dynamic> json) {
    final fi = json['food_item'];
    final r = json['restaurant'];
    return SpecialOfferRow(
      foodItem: fi is Map<String, dynamic>
          ? SpecialOfferFoodItem.fromJson(fi)
          : const SpecialOfferFoodItem(id: 0, foodCategoryId: 0, name: '', price: 0, discountedPrice: 0),
      restaurant: r is Map<String, dynamic>
          ? SpecialOfferRestaurantBrief.fromJson(r)
          : const SpecialOfferRestaurantBrief(id: 0, name: ''),
    );
  }

  @override
  List<Object?> get props => [foodItem, restaurant];
}

class OffersListPage extends Equatable {
  const OffersListPage({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
  });

  final List<SpecialOfferRow> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory OffersListPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List? ?? const [];
    final p = json['pagination'];
    final pm = p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{};
    int pageInt(String k, int d) {
      final v = pm[k];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? d;
      return d;
    }

    return OffersListPage(
      items: raw
          .whereType<Map>()
          .map((e) => SpecialOfferRow.fromJson(Map<String, dynamic>.from(e)))
          .where((row) => row.foodItem.id > 0 && row.restaurant.id > 0)
          .toList(),
      currentPage: pageInt('current_page', 1),
      lastPage: pageInt('last_page', 1),
      perPage: pageInt('per_page', 20),
      total: pageInt('total', 0),
    );
  }

  @override
  List<Object?> get props => [items, currentPage, lastPage];
}
