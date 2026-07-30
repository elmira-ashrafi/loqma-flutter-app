import '../../../core/l10n/localized_entity_fields.dart';

class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.description,
    this.image,
    this.price,
    this.restaurantId,
    this.restaurantName,
  });

  final int id;
  final String name;
  final LocalizedEntityFields localized;
  final String? description;

  String get displayName => localized.displayName;
  String? get displayDescription => localized.displayDescription;
  final String? image;
  final double? price;
  final int? restaurantId;
  final String? restaurantName;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    final fields = LocalizedEntityFields.fromJson(json);
    return FoodModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: fields.name,
      localized: fields,
      description: fields.displayDescription ?? (json['desc'])?.toString(),
      image: (json['image'] ?? json['photo'] ?? json['thumbnail'])?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      restaurantId: (json['restaurant_id'] as num?)?.toInt() ?? (json['restaurantId'] as num?)?.toInt(),
      restaurantName: (json['restaurant_name'] ?? json['restaurantName'])?.toString(),
    );
  }
}

