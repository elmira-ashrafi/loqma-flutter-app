import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/services/restaurant_service.dart';
import '../models/food_model.dart';

class SearchService {
  SearchService({Dio? dio})
      : _dio = dio ?? ApiClient.dio,
        _restaurantService = RestaurantService(dio: dio);

  final Dio _dio;
  final RestaurantService _restaurantService;

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final cityId = Get.isRegistered<DeliveryLocationController>()
        ? Get.find<DeliveryLocationController>().deliveryCityId
        : null;
    final res = await _restaurantService.getRestaurants(
      page: 1,
      perPage: 30,
      sortBy: null,
      searchQuery: query,
      cityId: cityId,
    );
    return res.data;
  }

  /// Optional: requires backend endpoint `GET /foods?q=...` or `GET /foods?search=...`.
  /// If endpoint doesn't exist, it returns empty list.
  Future<List<FoodModel>> searchFoods(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.foods,
        queryParameters: {
          'q': query,
          'search': query,
          'per_page': 30,
        },
      );
      final raw = response.data;
      dynamic list;
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is Map && inner['items'] != null) {
          list = inner['items'];
        } else if (inner is List) {
          list = inner;
        } else {
          list = raw['data'] ?? raw['items'] ?? raw['foods'];
        }
      } else {
        list = raw;
      }
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((e) => FoodModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

