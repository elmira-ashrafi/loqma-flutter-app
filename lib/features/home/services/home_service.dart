import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_model.dart';

/// Fetches home screen data from /home and banners from /banners.
class HomeService {
  HomeService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<HomeResponse> getHome({int? cityId}) async {
    final response = await _dio.get(
      ApiConstants.home,
      queryParameters: {
        if (cityId != null) 'city_id': cityId,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return HomeResponse.fromJson(data);
    }
    return const HomeResponse();
  }

  Future<List<BannerItem>> getBanners({int? cityId}) => getHeroBanners(cityId: cityId);

  /// GET /banners/hero — hero carousel (same data as [HomeResponse.heroBanners]).
  Future<List<BannerItem>> getHeroBanners({int? cityId}) async {
    final response = await _dio.get(
      ApiConstants.bannersHero,
      queryParameters: {
        if (cityId != null) 'city_id': cityId,
      },
    );
    return _parseBannerList(response.data);
  }

  List<BannerItem> _parseBannerList(dynamic data) {
    if (data == null) return [];
    dynamic list;
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map && inner['banners'] != null) {
        list = inner['banners'];
      } else if (inner is List) {
        list = inner;
      } else {
        list = data['data'] ?? data['banners'];
      }
    } else {
      list = data;
    }
    if (list is! List) return [];
    final items = <BannerItem>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      try {
        items.add(BannerItem.fromJson(e));
      } catch (_) {}
    }
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  /// GET /categories - list of categories for home tab (like web).
  Future<List<CategoryItem>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    final data = response.data;
    if (data == null) return [];
    dynamic list;
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map && inner['categories'] != null) {
        list = inner['categories'];
      } else if (inner is List) {
        list = inner;
      } else {
        list = data['data'] ?? data;
      }
    } else {
      list = data;
    }
    if (list is! List) return [];
    final items = <CategoryItem>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) items.add(CategoryItem.fromJson(e));
    }
    return items;
  }
}
