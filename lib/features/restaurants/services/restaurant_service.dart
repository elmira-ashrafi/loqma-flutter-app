import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/l10n/content_translation_enricher.dart';
import '../../restaurant/models/review_model.dart';
import '../models/restaurant_model.dart';
import '../models/restaurant_detail_model.dart';

/// Fast fetch result: model for immediate UI + raw map for background translation.
class RestaurantDetailFetch {
  const RestaurantDetailFetch({required this.model, required this.root});

  final RestaurantDetailModel model;
  final Map<String, dynamic> root;
}

class RestaurantService {
  RestaurantService({Dio? dio, ContentTranslationEnricher? enricher})
      : _dio = dio ?? ApiClient.dio,
        _enricher = enricher ?? ContentTranslationEnricher();

  final Dio _dio;
  final ContentTranslationEnricher _enricher;

  /// GET /restaurants with optional filters and pagination.
  /// Accepts: { "data": { "items": [...], "pagination": {...} } } or { "data": [...], "meta": {...} }.
  Future<PaginatedResponse<RestaurantModel>> getRestaurants({
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
    String? sortBy,
    bool? openNow,
    int? categoryId,
    String? categorySlug,
    String? searchQuery,
    int? cityId,
  }) async {
    final query = <String, dynamic>{
      AppConstants.pageParam: page,
      AppConstants.perPageParam: perPage,
      if (sortBy != null) 'sort': sortBy,
      if (openNow == true) 'open_now': 1,
      if (categoryId != null) 'category_id': categoryId,
      if (categorySlug != null && categorySlug.isNotEmpty) 'category': categorySlug,
      if (searchQuery != null && searchQuery.trim().isNotEmpty) 'q': searchQuery.trim(),
      if (searchQuery != null && searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
      if (cityId != null) 'city_id': cityId,
    };
    final response = await _dio.get(
      ApiConstants.restaurants,
      queryParameters: query,
    );
    final raw = response.data;
    Map<String, dynamic> data = {};
    // Dio decodes JSON as Map<dynamic, dynamic> — must normalize.
    if (raw is Map) {
      final root = Map<String, dynamic>.from(raw);
      final inner = root['data'];
      // API shape: { success, message, data: { items: [], pagination: {} } }
      if (inner is Map) {
        data = Map<String, dynamic>.from(inner);
      } else {
        data = root;
      }
    } else if (raw is List) {
      data = {'data': raw};
    }
    final items = data['items'];
    if (items is List) {
      await _enricher.enrichRestaurantListMaps(items);
    }
    return PaginatedResponse.fromJson(data, (e) => RestaurantModel.fromJson(e is Map<String, dynamic> ? e : {}));
  }

  /// GET /restaurants/{id} — [idOrSlug] may be numeric id or slug (API accepts both).
  Future<RestaurantDetailModel> getRestaurantById(int id) async {
    final fetched = await fetchRestaurantDetail(id.toString());
    return fetched.model;
  }

  Future<RestaurantDetailModel> getRestaurantByIdOrPath(String idOrSlug) async {
    final fetched = await fetchRestaurantDetail(idOrSlug);
    return fetched.model;
  }

  /// Fetches detail for immediate paint (no translation wait).
  Future<RestaurantDetailFetch> fetchRestaurantDetail(String idOrSlug) async {
    final path = idOrSlug.trim();
    final encoded = Uri.encodeComponent(path);
    final response = await _dio.get('${ApiConstants.restaurants}/$encoded');
    final raw = response.data;
    if (raw is Map) {
      final root = Map<String, dynamic>.from(raw);
      return RestaurantDetailFetch(
        model: RestaurantDetailModel.fromJson(root),
        root: root,
      );
    }
    return RestaurantDetailFetch(
      model: RestaurantDetailModel.fromJson({}),
      root: <String, dynamic>{},
    );
  }

  /// Background fa/ps enrichment; returns a new model when translations land.
  Future<RestaurantDetailModel?> enrichRestaurantDetailMap(
    Map<String, dynamic> root,
  ) async {
    if (root.isEmpty) return null;
    try {
      await _enricher.enrichRestaurantDetailMap(root);
      return RestaurantDetailModel.fromJson(root);
    } catch (_) {
      return null;
    }
  }

  /// GET /restaurants/{id}/reviews — public list (`data.items`, `data.pagination`).
  Future<List<ReviewModel>> getRestaurantReviews(int restaurantId, {int perPage = 20}) async {
    final response = await _dio.get(
      ApiConstants.restaurantReviews(restaurantId.toString()),
      queryParameters: {'per_page': perPage},
    );
    final raw = response.data;
    Map<String, dynamic>? data;
    if (raw is Map) {
      final root = Map<String, dynamic>.from(raw);
      final inner = root['data'];
      if (inner is Map) data = Map<String, dynamic>.from(inner);
    }
    if (data == null) return [];
    final items = data['items'];
    if (items is! List) return [];
    return items
        .map((e) => ReviewModel.fromApiJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
