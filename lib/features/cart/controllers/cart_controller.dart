import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

/// Result of attempting to add an item to the cart.
enum CartAddResult {
  added,
  /// Cart already has items from another restaurant.
  blockedDifferentRestaurant,
}

/// In-memory cart state; syncs with /cart/calculate for totals.
class CartController extends GetxController {
  CartController({CartService? service}) : _service = service ?? CartService();

  final CartService _service;
  final RxList<CartItemRequest> _requests = <CartItemRequest>[].obs;
  int? _restaurantId;
  final Rx<CartCalculateResponse?> calculation = Rx<CartCalculateResponse?>(null);

  List<CartItemResponse> get items => calculation.value?.items ?? [];

  /// Same payloads as [/cart/calculate]. Use at checkout so server totals match the app (variants, addons, free delivery).
  List<CartItemRequest> get itemRequests => List.unmodifiable(_requests);

  /// Total number of items in the cart (sum of quantities). Use for badge.
  int get itemCount => items.fold(0, (sum, e) => sum + e.quantity);
  double get total => calculation.value?.total ?? 0;
  double get subtotal => calculation.value?.subtotal ?? 0;
  double get deliveryFee => calculation.value?.deliveryFee ?? 0;
  double get tax => calculation.value?.tax ?? 0;
  double get discount => calculation.value?.discount ?? 0;
  int? get restaurantId => _restaurantId;
  String? get restaurantName => calculation.value?.restaurantName;
  String? get displayRestaurantName => calculation.value?.displayRestaurantName;
  double? get freeDeliveryAbove => calculation.value?.freeDeliveryAbove;

  @override
  void onInit() {
    super.onInit();
    recalculate();
  }

  CartAddResult addItemWithResult({
    required int restaurantId,
    required CartItemRequest item,
  }) {
    if (_restaurantId != null &&
        _restaurantId != restaurantId &&
        _requests.isNotEmpty) {
      return CartAddResult.blockedDifferentRestaurant;
    }

    _restaurantId = restaurantId;
    final existing = _requests.indexWhere((e) => e.foodId == item.foodId && e.variantId == item.variantId);
    if (existing >= 0) {
      final prev = _requests[existing];
      _requests[existing] = CartItemRequest(
        foodId: prev.foodId,
        quantity: prev.quantity + item.quantity,
        variantId: prev.variantId,
        addonIds: prev.addonIds.isNotEmpty ? prev.addonIds : item.addonIds,
        notes: prev.notes ?? item.notes,
        imageUrl: prev.imageUrl ?? item.imageUrl,
      );
    } else {
      _requests.add(item);
    }
    recalculate();
    update();
    return CartAddResult.added;
  }

  void addItem({
    required int restaurantId,
    required CartItemRequest item,
  }) {
    addItemWithResult(restaurantId: restaurantId, item: item);
  }

  bool canAddFromRestaurant(int restaurantId) {
    if (_requests.isEmpty) {
      return true;
    }
    return _restaurantId == null || _restaurantId == restaurantId;
  }

  void removeItem(int foodId, {int? variantId}) {
    _requests.removeWhere((e) => e.foodId == foodId && e.variantId == variantId);
    if (_requests.isEmpty) {
      _restaurantId = null;
    }
    recalculate();
    update();
  }

  void updateQuantity(int foodId, int quantity, {int? variantId}) {
    if (quantity <= 0) {
      removeItem(foodId, variantId: variantId);
      return;
    }
    final i = _requests.indexWhere((e) => e.foodId == foodId && e.variantId == variantId);
    if (i >= 0) {
      _requests[i] = CartItemRequest(
        foodId: _requests[i].foodId,
        quantity: quantity,
        variantId: _requests[i].variantId,
        addonIds: _requests[i].addonIds,
        notes: _requests[i].notes,
        imageUrl: _requests[i].imageUrl,
      );
      recalculate();
    }
  }

  Future<void> recalculate() async {
    if (_requests.isEmpty) {
      _restaurantId = null;
      calculation.value = const CartCalculateResponse();
      update();
      return;
    }
    if (_restaurantId == null) {
      calculation.value = const CartCalculateResponse();
      update();
      return;
    }
    try {
      final result = await _service.calculate(
        CartCalculateRequest(
          restaurantId: _restaurantId!,
          items: _requests,
        ),
      );
      calculation.value = _withLocalImages(result);
    } catch (_) {
      calculation.value = null;
    }
    update();
  }

  void clear() {
    _requests.clear();
    _restaurantId = null;
    calculation.value = null;
    update();
  }

  /// Prefer API images; fall back to the image captured when the item was added.
  CartCalculateResponse _withLocalImages(CartCalculateResponse result) {
    if (result.items.isEmpty) return result;
    final byFoodId = <int, String?>{
      for (final r in _requests)
        if (r.imageUrl != null && r.imageUrl!.isNotEmpty) r.foodId: r.imageUrl,
    };
    if (byFoodId.isEmpty) return result;
    final merged = result.items.map((item) {
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) return item;
      final local = byFoodId[item.foodId];
      if (local == null || local.isEmpty) return item;
      return item.copyWith(imageUrl: local);
    }).toList();
    return CartCalculateResponse(
      subtotal: result.subtotal,
      deliveryFee: result.deliveryFee,
      tax: result.tax,
      discount: result.discount,
      total: result.total,
      items: merged,
      restaurantName: result.restaurantName,
      restaurantLocalized: result.restaurantLocalized,
      freeDeliveryAbove: result.freeDeliveryAbove,
    );
  }
}
