import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/restaurant_owner_models.dart';

class RestaurantOwnerService {
  RestaurantOwnerService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Future<RestaurantOwnerDashboardData> getDashboard() async {
    final res = await _dio.get(ApiConstants.restaurantDashboard);
    return RestaurantOwnerDashboardData.fromJson(_unwrap(res.data));
  }

  Future<bool> toggleStatus() async {
    final res = await _dio.post(ApiConstants.restaurantToggleStatus);
    final data = _unwrap(res.data);
    return data['is_open'] as bool? ?? false;
  }

  Future<List<RestaurantOwnerOrder>> getOrders({
    String? status,
    String? date,
  }) async {
    final res = await _dio.get(
      ApiConstants.restaurantOrders,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
    final data = _unwrap(res.data);
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((e) => RestaurantOwnerOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RestaurantOwnerOrder> updateOrderStatus(
    int orderId,
    String status, {
    String? note,
  }) async {
    final res = await _dio.post(
      ApiConstants.restaurantOrderStatus(orderId),
      data: {
        'status': status,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return RestaurantOwnerOrder.fromJson(_unwrap(res.data));
  }

  Future<RestaurantOwnerSettingsData> getSettings() async {
    final res = await _dio.get(ApiConstants.restaurantSettings);
    return RestaurantOwnerSettingsData.fromJson(_unwrap(res.data));
  }

  Future<RestaurantOwnerInfo> updateSettings(Map<String, dynamic> body) async {
    final res = await _dio.put(ApiConstants.restaurantSettings, data: body);
    return RestaurantOwnerInfo.fromJson(_unwrap(res.data));
  }

  Future<List<RestaurantMenuCategory>> getMenu() async {
    final res = await _dio.get(ApiConstants.restaurantMenu);
    final data = _unwrap(res.data);
    final categories = data['categories'] as List? ?? const [];
    return categories
        .whereType<Map>()
        .map((e) => RestaurantMenuCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RestaurantMenuCategory> createCategory(Map<String, dynamic> body) async {
    final res = await _dio.post(
      '${ApiConstants.restaurantMenu}/categories',
      data: body,
    );
    return RestaurantMenuCategory.fromJson(_unwrap(res.data));
  }

  Future<RestaurantMenuCategory> updateCategory(int id, Map<String, dynamic> body) async {
    final res = await _dio.put(
      '${ApiConstants.restaurantMenu}/categories/$id',
      data: body,
    );
    return RestaurantMenuCategory.fromJson(_unwrap(res.data));
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('${ApiConstants.restaurantMenu}/categories/$id');
  }

  Future<RestaurantMenuItem> createItem(Map<String, dynamic> body) async {
    final res = await _dio.post(
      '${ApiConstants.restaurantMenu}/items',
      data: body,
    );
    return RestaurantMenuItem.fromJson(_unwrap(res.data));
  }

  Future<RestaurantMenuItem> updateItem(int id, Map<String, dynamic> body) async {
    final res = await _dio.put(
      '${ApiConstants.restaurantMenu}/items/$id',
      data: body,
    );
    return RestaurantMenuItem.fromJson(_unwrap(res.data));
  }

  /// PUT /restaurant/menu/items/{id}/special-offer — enable/disable deal listing + discount fields.
  Future<RestaurantMenuItem> updateItemSpecialOffer(int itemId, Map<String, dynamic> body) async {
    final res = await _dio.put(
      ApiConstants.restaurantMenuItemSpecialOffer(itemId),
      data: body,
    );
    return RestaurantMenuItem.fromJson(_unwrap(res.data));
  }

  Future<void> deleteItem(int id) async {
    await _dio.delete('${ApiConstants.restaurantMenu}/items/$id');
  }

  Future<void> deleteVariantGroup(int groupId) async {
    await _dio.delete('${ApiConstants.restaurantMenu}/variant-groups/$groupId');
  }

  Future<int> _createVariantGroup(int itemId) async {
    final res = await _dio.post(
      '${ApiConstants.restaurantMenu}/items/$itemId/variant-groups',
      data: const {
        'name': 'Size',
        'name_fa': 'اندازه',
        'is_required': true,
      },
    );
    final data = _unwrap(res.data);
    return (data['id'] as num?)?.toInt() ?? 0;
  }

  Future<void> _createVariant(
    int groupId, {
    required String name,
    required double priceAdjustment,
    bool isDefault = false,
  }) async {
    await _dio.post(
      '${ApiConstants.restaurantMenu}/variant-groups/$groupId/variants',
      data: {
        'name': name,
        'price_adjustment': priceAdjustment,
        'is_default': isDefault,
        'is_available': true,
      },
    );
  }

  Future<void> _updateVariant(
    int variantId, {
    required String name,
    required double priceAdjustment,
    bool isDefault = false,
  }) async {
    await _dio.put(
      '${ApiConstants.restaurantMenu}/variants/$variantId',
      data: {
        'name': name,
        'price_adjustment': priceAdjustment,
        'is_default': isDefault,
        'is_available': true,
      },
    );
  }

  Future<void> _deleteVariant(int variantId) async {
    await _dio.delete('${ApiConstants.restaurantMenu}/variants/$variantId');
  }

  /// Creates or updates size options. Only sizes with an explicit price are kept.
  /// No size is selected/defaulted automatically.
  Future<void> syncItemSizes({
    required int itemId,
    required bool hasSizes,
    required double basePrice,
    double? kidsPrice,
    double? smallPrice,
    double? mediumPrice,
    double? largePrice,
    double? familyPrice,
    int? existingGroupId,
    List<MenuItemSizeVariant> existingVariants = const [],
  }) async {
    if (!hasSizes) {
      if (existingGroupId != null && existingGroupId > 0) {
        await deleteVariantGroup(existingGroupId);
      }
      return;
    }

    final specs = <({String name, double adjustment})>[];
    if (kidsPrice != null) {
      specs.add((name: 'Kids', adjustment: kidsPrice - basePrice));
    }
    if (smallPrice != null) {
      specs.add((name: 'Small', adjustment: smallPrice - basePrice));
    }
    if (mediumPrice != null) {
      specs.add((name: 'Medium', adjustment: mediumPrice - basePrice));
    }
    if (largePrice != null) {
      specs.add((name: 'Large', adjustment: largePrice - basePrice));
    }
    if (familyPrice != null) {
      specs.add((name: 'Family Size', adjustment: familyPrice - basePrice));
    }

    if (specs.isEmpty) {
      if (existingGroupId != null && existingGroupId > 0) {
        await deleteVariantGroup(existingGroupId);
      }
      return;
    }

    var groupId = existingGroupId ?? 0;
    if (groupId <= 0) {
      groupId = await _createVariantGroup(itemId);
      if (groupId <= 0) return;
    }

    bool matchesSize(String existingName, String target) {
      final a = existingName.toLowerCase();
      final b = target.toLowerCase();
      return a == b ||
          (b == 'family size' && (a == 'family' || a == 'family size'));
    }

    final wantedNames = specs.map((s) => s.name).toList();

    for (final variant in existingVariants) {
      final stillWanted = wantedNames.any((name) => matchesSize(variant.name, name));
      if (!stillWanted) {
        await _deleteVariant(variant.id);
      }
    }

    for (final spec in specs) {
      MenuItemSizeVariant? existing;
      for (final variant in existingVariants) {
        if (matchesSize(variant.name, spec.name)) {
          existing = variant;
          break;
        }
      }
      if (existing != null) {
        await _updateVariant(
          existing.id,
          name: spec.name,
          priceAdjustment: spec.adjustment,
          isDefault: false,
        );
      } else {
        await _createVariant(
          groupId,
          name: spec.name,
          priceAdjustment: spec.adjustment,
          isDefault: false,
        );
      }
    }
  }

  Future<bool> toggleItemAvailability(int id) async {
    final res = await _dio.post('${ApiConstants.restaurantMenu}/items/$id/toggle');
    final data = _unwrap(res.data);
    return data['is_available'] as bool? ?? false;
  }
}
