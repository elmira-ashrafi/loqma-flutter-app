import 'dart:async';
import 'package:get/get.dart';
import '../../../core/utils/error_parser.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/services/restaurant_service.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';

class GlobalSearchController extends GetxController {
  GlobalSearchController({
    RestaurantService? restaurantService,
    FoodService? foodService,
  })  : _restaurantService = restaurantService ?? RestaurantService(),
        _foodService = foodService ?? FoodService();

  final RestaurantService _restaurantService;
  final FoodService _foodService;

  final RxString query = ''.obs;
  final RxInt tabIndex = 0.obs; // 0 restaurants, 1 foods

  final RxBool isLoadingRestaurants = false.obs;
  final RxBool isLoadingFoods = false.obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxString error = ''.obs;

  Timer? _debounce;

  void onQueryChanged(String v) {
    query.value = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _runSearch();
    });
  }

  Future<void> _runSearch() async {
    final q = query.value.trim();
    error.value = '';
    if (q.isEmpty) {
      restaurants.clear();
      foods.clear();
      return;
    }
    await Future.wait([
      _searchRestaurants(q),
      _searchFoods(q),
    ]);
  }

  Future<void> _searchRestaurants(String q) async {
    isLoadingRestaurants.value = true;
    try {
      final cityId = Get.isRegistered<DeliveryLocationController>()
          ? Get.find<DeliveryLocationController>().deliveryCityId
          : null;
      final res = await _restaurantService.getRestaurants(
        page: 1,
        perPage: 30,
        searchQuery: q,
        cityId: cityId,
      );
      restaurants.value = res.data;
    } catch (e) {
      restaurants.clear();
      error.value = error.value.isEmpty ? userFriendlyErrorMessage(e) : error.value;
    } finally {
      isLoadingRestaurants.value = false;
    }
  }

  Future<void> _searchFoods(String q) async {
    isLoadingFoods.value = true;
    try {
      final res = await _foodService.getFoods(
        page: 1,
        perPage: 30,
        searchQuery: q,
      );
      foods.value = res.data;
    } catch (_) {
      // If backend doesn't support /foods yet, keep it empty silently.
      foods.clear();
    } finally {
      isLoadingFoods.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

