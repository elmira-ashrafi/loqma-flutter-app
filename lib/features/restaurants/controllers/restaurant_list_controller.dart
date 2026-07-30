import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';

class RestaurantListController extends GetxController {
  RestaurantListController({
    RestaurantService? service,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.searchQuery,
    this.freeDeliveryOnly = false,
    this.cityId,
  }) : _service = service ?? RestaurantService();

  final RestaurantService _service;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? searchQuery;
  final bool freeDeliveryOnly;
  final int? cityId;

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt page = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString sortBy = 'rating'.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
  }

  void setSort(String value) {
    sortBy.value = value;
    // Keep list visible while re-sorting when we already have rows; otherwise show loader.
    loadRestaurants(showFullScreenLoader: restaurants.isEmpty);
  }

  Future<void> loadRestaurants({bool showFullScreenLoader = true}) async {
    page.value = 1;
    hasMore.value = true;
    if (showFullScreenLoader) {
      isLoading.value = true;
    }
    try {
      final res = await _service.getRestaurants(
        page: 1,
        perPage: AppConstants.defaultPageSize,
        sortBy: sortBy.value,
        categoryId: categoryId,
        categorySlug: categorySlug,
        searchQuery: searchQuery,
        cityId: cityId,
      );
      restaurants.value = freeDeliveryOnly
          ? res.data.where((r) => r.deliveryFee == 0).toList()
          : res.data;
      hasMore.value = res.meta.hasNextPage;
    } catch (_) {
      restaurants.clear();
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (!hasMore.value || isLoading.value) return;
    page.value++;
    _service.getRestaurants(
      page: page.value,
      perPage: AppConstants.defaultPageSize,
      sortBy: sortBy.value,
      categoryId: categoryId,
      categorySlug: categorySlug,
      searchQuery: searchQuery,
      cityId: cityId,
    ).then((res) {
      final next = freeDeliveryOnly
          ? res.data.where((r) => r.deliveryFee == 0).toList()
          : res.data;
      restaurants.addAll(next);
      hasMore.value = res.meta.hasNextPage;
    });
  }
}
