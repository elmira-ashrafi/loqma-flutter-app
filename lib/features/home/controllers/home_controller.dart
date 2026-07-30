import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_parser.dart';
import '../models/home_model.dart';
import '../services/home_service.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/services/restaurant_service.dart';

/// Home screen state: /home data, banners, category filter, loading, error.
class HomeController extends GetxController {
  HomeController({
    HomeService? service,
    RestaurantService? restaurantService,
  })  : _service = service ?? HomeService(),
        _restaurantService = restaurantService ?? RestaurantService();

  final HomeService _service;
  final RestaurantService _restaurantService;

  final Rx<HomeResponse?> homeData = Rx<HomeResponse?>(null);
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<CategoryItem> categoriesList = <CategoryItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingBanners = false.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxString error = ''.obs;

  bool _refreshInFlight = false;

  /// When set, home shows restaurants filtered by this category (from /restaurants?category= or category_id=).
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final RxString selectedCategoryName = ''.obs;
  final RxList<RestaurantModel> filteredRestaurants = <RestaurantModel>[].obs;
  final RxBool isLoadingFiltered = false.obs;

  /// Infinite-scroll “all restaurants” list on the home tab.
  final RxList<RestaurantModel> browseRestaurants = <RestaurantModel>[].obs;
  final RxBool isLoadingBrowse = false.obs;
  final RxBool hasMoreBrowse = true.obs;
  int browsePage = 1;
  double homeScrollOffset = 0;

  static const _scrollPrefsKey = 'home_tab_scroll_offset';

  Worker? _deliveryCityWorker;
  int? _boundCityId;

  int? get _deliveryCityId => Get.isRegistered<DeliveryLocationController>()
      ? Get.find<DeliveryLocationController>().deliveryCityId
      : null;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<DeliveryLocationController>()) {
      Get.put(DeliveryLocationController(), permanent: true);
    }
    _deliveryCityWorker = ever(
      Get.find<DeliveryLocationController>().deliveryAddress,
      (_) => _reloadRestaurantsForCity(),
    );
    ensureLoaded();
  }

  @override
  void onClose() {
    _deliveryCityWorker?.dispose();
    super.onClose();
  }

  void _reloadRestaurantsForCity() {
    final cityId = _deliveryCityId;
    if (cityId == _boundCityId) return;
    _boundCityId = cityId;
    browseRestaurants.clear();
    browsePage = 1;
    hasMoreBrowse.value = true;
    banners.clear();
    loadBrowseRestaurants(force: true);
    loadBanners(silent: true);
    final catId = selectedCategoryId.value;
    if (catId != null) {
      _loadFilteredRestaurants(categoryId: catId);
    }
  }

  /// Loads home data when empty or after a failed preload.
  Future<void> ensureLoaded({bool force = false}) async {
    if (!force && homeData.value != null) return;
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      await refreshAll(retries: 1);
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<void> refreshAll({int retries = 0, bool silent = false}) async {
    await loadHome(retries: retries, silent: silent);
    await Future.wait([
      loadBanners(retries: retries, silent: silent),
      loadCategories(retries: retries, silent: silent),
    ]);
  }

  void rememberHomeScrollOffset(double offset) {
    homeScrollOffset = offset;
  }

  Future<void> restoreScrollOffset() async {
    final prefs = await SharedPreferences.getInstance();
    homeScrollOffset = prefs.getDouble(_scrollPrefsKey) ?? homeScrollOffset;
  }

  Future<void> persistScrollOffset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scrollPrefsKey, homeScrollOffset);
  }

  Future<void> loadBrowseRestaurants({
    bool loadMore = false,
    bool force = false,
  }) async {
    if (isLoadingBrowse.value) return;
    if (loadMore && !hasMoreBrowse.value) return;
    if (!loadMore && browseRestaurants.isNotEmpty && !force) return;

    isLoadingBrowse.value = true;
    try {
      final page = loadMore ? browsePage : 1;
      final cityId = _deliveryCityId;
      final res = await _restaurantService.getRestaurants(
        page: page,
        perPage: AppConstants.defaultPageSize,
        sortBy: 'rating',
        cityId: cityId,
      );
      if (!loadMore) {
        _boundCityId = cityId;
      }
      if (loadMore) {
        browseRestaurants.addAll(res.data);
      } else {
        browseRestaurants.assignAll(res.data);
        browsePage = 1;
      }
      hasMoreBrowse.value = res.meta.hasNextPage;
      if (hasMoreBrowse.value) {
        browsePage = res.meta.nextPage;
      }
    } catch (_) {
      if (!loadMore) {
        browseRestaurants.clear();
      }
      hasMoreBrowse.value = false;
    } finally {
      isLoadingBrowse.value = false;
    }
  }

  /// Tap a category: filter restaurants by it (web-style: uses slug when available). Tap again or pass null to clear.
  void setCategoryFilter(int? categoryId, String? categoryName, [String? categorySlug]) {
    if (categoryId == null) {
      selectedCategoryId.value = null;
      selectedCategoryName.value = '';
      filteredRestaurants.clear();
      return;
    }
    if (selectedCategoryId.value == categoryId) {
      setCategoryFilter(null, null, null);
      return;
    }
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName ?? '';
    _loadFilteredRestaurants(categoryId: categoryId, categorySlug: categorySlug);
  }

  Future<void> _loadFilteredRestaurants({int? categoryId, String? categorySlug}) async {
    isLoadingFiltered.value = true;
    filteredRestaurants.clear();
    try {
      final res = await _restaurantService.getRestaurants(
        page: 1,
        perPage: 20,
        sortBy: 'rating',
        categoryId: categoryId,
        categorySlug: categorySlug,
        cityId: _deliveryCityId,
      );
      filteredRestaurants.value = res.data;
    } catch (_) {
      filteredRestaurants.clear();
    } finally {
      isLoadingFiltered.value = false;
    }
  }

  Future<void> loadHome({int retries = 0, bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';
    try {
      for (var attempt = 0; attempt <= retries; attempt++) {
        try {
          homeData.value = await _service.getHome(cityId: _deliveryCityId);
          _applyHeroBannersFromHome(homeData.value);
          return;
        } catch (e) {
          if (attempt < retries) {
            await Future.delayed(const Duration(seconds: 2));
          } else {
            error.value = userFriendlyErrorMessage(e);
          }
        }
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> loadBanners({int retries = 0, bool silent = false}) async {
    if (!silent) isLoadingBanners.value = true;
    try {
      for (var attempt = 0; attempt <= retries; attempt++) {
        try {
          final list = await _service.getHeroBanners(cityId: _deliveryCityId);
          banners.assignAll(list);
          return;
        } catch (_) {
          if (attempt < retries) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    } finally {
      if (!silent) isLoadingBanners.value = false;
    }
  }

  void _applyHeroBannersFromHome(HomeResponse? home) {
    if (home == null) return;
    // Prefer dedicated /banners/hero when already loaded; otherwise apply home payload.
    if (home.heroBanners.isEmpty && banners.isNotEmpty) return;
    banners.assignAll(home.heroBanners);
  }

  Future<void> loadCategories({int retries = 0, bool silent = false}) async {
    if (!silent) isLoadingCategories.value = true;
    try {
      for (var attempt = 0; attempt <= retries; attempt++) {
        try {
          categoriesList.value = await _service.getCategories();
          return;
        } catch (_) {
          if (attempt < retries) {
            await Future.delayed(const Duration(seconds: 2));
          } else {
            categoriesList.clear();
          }
        }
      }
    } finally {
      if (!silent) isLoadingCategories.value = false;
    }
  }
}
