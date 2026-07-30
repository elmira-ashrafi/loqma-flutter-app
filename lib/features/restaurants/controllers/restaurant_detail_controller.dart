import 'dart:async';

import 'package:get/get.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../restaurant/models/review_model.dart';
import '../models/restaurant_detail_model.dart';
import '../services/restaurant_service.dart';

class RestaurantDetailController extends GetxController {
  RestaurantDetailController({
    required this.restaurantId,
    RestaurantService? service,
  }) : _service = service ?? RestaurantService();

  final int restaurantId;
  final RestaurantService _service;
  final Rx<RestaurantDetailModel?> detail = Rx<RestaurantDetailModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isTogglingFavorite = false.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool reviewsLoading = false.obs;
  final RxString reviewsError = ''.obs;

  Worker? _localeWorker;
  Worker? _favoritesWorker;
  int _loadGeneration = 0;

  FavoritesController? get _favorites {
    if (Get.isRegistered<FavoritesController>()) {
      return Get.find<FavoritesController>();
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _syncFavoriteFromStore();
    final fav = _favorites;
    if (fav != null) {
      _favoritesWorker = ever(fav.items, (_) => _syncFavoriteFromStore());
    }
    loadDetail();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        // Names resolve client-side; avoid refetching full restaurant on locale switch.
        update();
      });
    }
  }

  @override
  void onClose() {
    _loadGeneration++;
    _localeWorker?.dispose();
    _favoritesWorker?.dispose();
    super.onClose();
  }

  void _syncFavoriteFromStore() {
    final fav = _favorites;
    if (fav == null || !fav.hasLoaded.value) return;
    isFavorite.value = fav.isFavoriteId(restaurantId);
  }

  void _applyFavoriteFromDetail() {
    final store = _favorites;
    if (store != null && store.hasLoaded.value) {
      isFavorite.value = store.isFavoriteId(restaurantId);
      return;
    }
    final fav = detail.value?.restaurant.isFavorite;
    if (fav != null) isFavorite.value = fav;
  }

  Future<void> loadDetail() async {
    final gen = ++_loadGeneration;
    isLoading.value = true;
    error.value = '';
    try {
      // First paint after a single restaurant API call (no translate wait).
      final fetched = await _service.fetchRestaurantDetail(restaurantId.toString());
      if (gen != _loadGeneration) return;
      detail.value = fetched.model;
      _applyFavoriteFromDetail();
      isLoading.value = false;
      unawaited(loadReviews());
      unawaited(_enrichTranslations(fetched.root, gen));
    } catch (e) {
      if (gen != _loadGeneration) return;
      error.value = userFriendlyErrorMessage(e);
      detail.value = null;
      reviews.clear();
      reviewsError.value = '';
      isLoading.value = false;
    }
  }

  Future<void> _enrichTranslations(
    Map<String, dynamic> root,
    int gen,
  ) async {
    final enriched = await _service.enrichRestaurantDetailMap(root);
    if (enriched == null || gen != _loadGeneration || isClosed) return;
    detail.value = enriched;
  }

  /// Pull-to-refresh: keep existing content while reloading.
  Future<void> refreshDetail() async {
    if (detail.value == null) {
      await loadDetail();
      return;
    }
    final gen = ++_loadGeneration;
    error.value = '';
    try {
      final fetched = await _service.fetchRestaurantDetail(restaurantId.toString());
      if (gen != _loadGeneration) return;
      detail.value = fetched.model;
      _applyFavoriteFromDetail();
      unawaited(loadReviews());
      unawaited(_enrichTranslations(fetched.root, gen));
    } catch (e) {
      if (gen != _loadGeneration) return;
      error.value = userFriendlyErrorMessage(e);
    }
  }

  Future<void> loadReviews() async {
    reviewsLoading.value = true;
    reviewsError.value = '';
    try {
      final list = await _service.getRestaurantReviews(restaurantId);
      reviews.assignAll(list);
    } catch (e) {
      reviews.clear();
      reviewsError.value = userFriendlyErrorMessage(e);
    } finally {
      reviewsLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (isTogglingFavorite.value) return;
    final ctx = Get.context;
    final l10n = ctx != null ? AppLocalizations.of(ctx) : null;
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        if (l10n != null) {
          Get.snackbar(
            l10n.signIn,
            l10n.restaurantDetailsSignInForFavorites,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }
    }

    // Ensure shared store exists (e.g. opened restaurant before MainScreen).
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController(), permanent: true);
    }

    isTogglingFavorite.value = true;
    error.value = '';
    final optimistic = !isFavorite.value;
    isFavorite.value = optimistic;
    try {
      final next = await Get.find<FavoritesController>().toggleFavorite(
        restaurantId: restaurantId,
        restaurant: detail.value?.restaurant,
      );
      isFavorite.value = next;
    } catch (e) {
      isFavorite.value = !optimistic;
      final msg = userFriendlyErrorMessage(e);
      error.value = msg;
      if (l10n != null) {
        Get.snackbar(
          l10n.restaurantDetailsFavoritesSnackbarTitle,
          msg,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isTogglingFavorite.value = false;
    }
  }
}
