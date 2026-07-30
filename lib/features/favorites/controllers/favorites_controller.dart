import 'package:get/get.dart';

import '../../../core/utils/error_parser.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/services/favorites_service.dart';

/// Shared favorites store so add/remove is reflected instantly on Favorites
/// and restaurant detail (and anywhere else that reads [isFavoriteId]).
class FavoritesController extends GetxController {
  FavoritesController({FavoritesService? service})
      : _service = service ?? FavoritesService();

  final FavoritesService _service;

  final RxList<RestaurantModel> items = <RestaurantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString error = RxnString();
  final RxSet<int> removingIds = <int>{}.obs;
  final RxSet<int> togglingIds = <int>{}.obs;

  /// True after at least one successful load this session (avoids empty flash).
  final RxBool hasLoaded = false.obs;

  bool isFavoriteId(int restaurantId) =>
      items.any((r) => r.id == restaurantId);

  @override
  void onInit() {
    super.onInit();
    if (_isLoggedIn) {
      load();
    }
  }

  bool get _isLoggedIn {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isLoggedIn;
  }

  void clear() {
    items.clear();
    error.value = null;
    isLoading.value = false;
    isRefreshing.value = false;
    removingIds.clear();
    togglingIds.clear();
    hasLoaded.value = false;
  }

  Future<void> load({bool showFullPageLoading = true}) async {
    if (!_isLoggedIn) {
      clear();
      hasLoaded.value = true;
      return;
    }

    if (showFullPageLoading && items.isEmpty) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }
    error.value = null;

    try {
      final list = await _service.getFavorites();
      items.assignAll(list);
      error.value = null;
    } catch (e) {
      error.value = userFriendlyErrorMessage(e);
      if (items.isEmpty) {
        // Keep empty; show error state.
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      hasLoaded.value = true;
    }
  }

  Future<void> refreshFavorites() => load(showFullPageLoading: false);

  /// Toggle favorite. Pass [restaurant] when adding so the Favorites tab
  /// can show the card immediately without waiting for a refetch.
  Future<bool> toggleFavorite({
    required int restaurantId,
    RestaurantModel? restaurant,
  }) async {
    if (!_isLoggedIn) {
      throw Exception('Please sign in to use favorites.');
    }
    if (togglingIds.contains(restaurantId) ||
        removingIds.contains(restaurantId)) {
      return isFavoriteId(restaurantId);
    }

    final wasFavorite = isFavoriteId(restaurantId);
    final optimisticNext = !wasFavorite;
    final previous = List<RestaurantModel>.from(items);

    togglingIds.add(restaurantId);
    if (!optimisticNext) {
      removingIds.add(restaurantId);
    }

    // Optimistic UI update.
    if (optimisticNext) {
      if (restaurant != null && !items.any((r) => r.id == restaurantId)) {
        items.insert(0, restaurant);
      }
    } else {
      items.removeWhere((r) => r.id == restaurantId);
    }

    try {
      final serverNext =
          await _service.toggleRestaurantFavorite(restaurantId);

      if (serverNext) {
        if (!items.any((r) => r.id == restaurantId)) {
          if (restaurant != null) {
            items.insert(0, restaurant);
          } else {
            // Added on server but we had no restaurant snapshot — refetch.
            await refreshFavorites();
          }
        }
      } else {
        items.removeWhere((r) => r.id == restaurantId);
      }

      return serverNext;
    } catch (e) {
      items.assignAll(previous);
      rethrow;
    } finally {
      togglingIds.remove(restaurantId);
      removingIds.remove(restaurantId);
    }
  }

  Future<bool> removeFavorite(RestaurantModel restaurant) async {
    if (!isFavoriteId(restaurant.id)) return false;
    return toggleFavorite(restaurantId: restaurant.id, restaurant: restaurant);
  }
}
