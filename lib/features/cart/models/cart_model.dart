import 'package:equatable/equatable.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/localized_entity_fields.dart';

/// Cart calculation request/response from /cart/calculate.
class CartCalculateRequest extends Equatable {
  const CartCalculateRequest({
    required this.restaurantId,
    this.items = const [],
  });

  /// Backend expects a single [restaurant_id] per calculation.
  final int restaurantId;
  final List<CartItemRequest> items;

  Map<String, dynamic> toJson() => {
        'restaurant_id': restaurantId,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [items];
}

class CartItemRequest extends Equatable {
  const CartItemRequest({
    required this.foodId,
    required this.quantity,
    this.variantId,
    this.addonIds = const [],
    this.notes,
    this.imageUrl,
  });

  final int foodId;
  final int quantity;
  final int? variantId;
  final List<int> addonIds;
  final String? notes;

  /// Client-only: shown in cart UI; not sent to /cart/calculate.
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        // Backend expects food_item_id.
        'food_item_id': foodId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
        if (addonIds.isNotEmpty) 'addon_ids': addonIds,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  @override
  List<Object?> get props => [foodId, quantity, variantId, addonIds, imageUrl];
}

class CartCalculateResponse extends Equatable {
  const CartCalculateResponse({
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.tax = 0,
    this.total = 0,
    this.items = const [],
    this.restaurantName,
    this.restaurantLocalized,
    this.freeDeliveryAbove,
    this.discount = 0,
  });

  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final List<CartItemResponse> items;
  final String? restaurantName;
  final LocalizedEntityFields? restaurantLocalized;

  String? get displayRestaurantName =>
      restaurantLocalized?.displayName ?? restaurantName;
  /// When set, restaurant offers free delivery for orders above this amount.
  final double? freeDeliveryAbove;

  factory CartCalculateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final rest = data['restaurant'];
    String? restaurantName;
    LocalizedEntityFields? restaurantLocalized;
    double? freeDeliveryAbove;
    if (rest is Map) {
      final restMap = Map<String, dynamic>.from(rest);
      if (rest['name'] != null) restaurantName = rest['name'] as String?;
      restaurantLocalized = LocalizedEntityFields.fromJson(
        restMap,
        isRestaurantBrand: true,
      );
      final fda = rest['free_delivery_above'] ?? rest['freeDeliveryAbove'];
      if (fda != null) freeDeliveryAbove = (fda is num) ? fda.toDouble() : double.tryParse(fda.toString());
    }
    if (freeDeliveryAbove == null) {
      final fda = data['free_delivery_above'] ?? data['freeDeliveryAbove'];
      if (fda != null) freeDeliveryAbove = (fda is num) ? fda.toDouble() : double.tryParse(fda.toString());
    }
    return CartCalculateResponse(
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      items: (data['line_items'] as List<dynamic>? ?? data['items'] as List<dynamic>?)
              ?.map((e) => CartItemResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      restaurantName: restaurantName,
      restaurantLocalized: restaurantLocalized,
      freeDeliveryAbove: freeDeliveryAbove,
    );
  }

  @override
  List<Object?> get props => [subtotal, deliveryFee, tax, total, items, restaurantName, restaurantLocalized, freeDeliveryAbove];
}

class CartItemResponse extends Equatable {
  const CartItemResponse({
    required this.foodId,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.quantity = 1,
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.variantName,
    this.variantId,
    this.addons = const [],
    this.imageUrl,
  });

  final int foodId;
  final String name;
  final LocalizedEntityFields localized;
  final int quantity;

  String get displayName => localized.displayName;
  final double unitPrice;
  final double totalPrice;
  final String? variantName;
  final int? variantId;
  final List<String> addons;
  final String? imageUrl;

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    final image = json['image'] ?? json['image_url'] ?? json['imageUrl'];
    String? imageUrl;
    if (image is String) {
      imageUrl = _resolveImageUrl(image);
    } else if (image is Map && image['url'] != null) {
      imageUrl = _resolveImageUrl(image['url'].toString());
    }
    final vid = json['variant_id'] ?? json['variantId'];
    final variantId = vid is num ? vid.toInt() : (vid != null ? int.tryParse(vid.toString()) : null);
    final fields = LocalizedEntityFields.fromJson(json);
    return CartItemResponse(
      foodId: (json['food_item_id'] as num?)?.toInt() ??
          (json['food_id'] as num?)?.toInt() ??
          (json['foodId'] as num?)?.toInt() ??
          0,
      name: fields.name,
      localized: fields,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? (json['unitPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['line_total'] as num?)?.toDouble() ??
          (json['total_price'] as num?)?.toDouble() ??
          (json['totalPrice'] as num?)?.toDouble() ??
          0,
      variantName: json['variant_name'] as String? ?? json['variantName'] as String?,
      variantId: variantId,
      addons: (json['addons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      imageUrl: imageUrl,
    );
  }

  CartItemResponse copyWith({String? imageUrl}) {
    return CartItemResponse(
      foodId: foodId,
      name: name,
      localized: localized,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      variantName: variantName,
      variantId: variantId,
      addons: addons,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static String? _resolveImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    return trimmed.startsWith('/') ? '$base$trimmed' : '$base/$trimmed';
  }

  @override
  List<Object?> get props => [foodId, name, quantity, totalPrice, imageUrl, variantId];
}
