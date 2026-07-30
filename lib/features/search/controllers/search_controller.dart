import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../models/food_model.dart';
import '../services/search_service.dart';

enum SearchTab { all, restaurants, foods }

class GlobalSearchController extends GetxController {
  GlobalSearchController({SearchService? service}) : _service = service ?? SearchService();

  final SearchService _service;

  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final Rx<SearchTab> tab = SearchTab.all.obs;

  Timer? _debounce;

  void setQuery(String v) {
    query.value = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 260), () {
      _runSearch(v);
    });
  }

  void setTab(SearchTab v) {
    tab.value = v;
    final q = query.value.trim();
    if (q.isEmpty) return;
    if (v == SearchTab.restaurants && restaurants.isEmpty) {
      _runSearch(q);
    }
    if (v == SearchTab.foods && foods.isEmpty) {
      _runSearch(q);
    }
  }

  Future<void> _runSearch(String raw) async {
    final q = raw.trim();
    if (q.isEmpty) {
      restaurants.clear();
      foods.clear();
      return;
    }
    isLoading.value = true;
    try {
      // Parallel search gives the "global" feel.
      final results = await Future.wait([
        _service.searchRestaurants(q),
        _service.searchFoods(q),
      ]);
      restaurants.assignAll(results[0] as List<RestaurantModel>);
      foods.assignAll(results[1] as List<FoodModel>);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  TextDirection get textDirection => Directionality.of(Get.context!);
}

