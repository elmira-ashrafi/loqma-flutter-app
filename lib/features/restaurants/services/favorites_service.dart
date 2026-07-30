import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/restaurant_model.dart';

class FavoritesService {
  FavoritesService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  /// GET /customer/favorites — returns list of favorited restaurants (auth + customer role).
  Future<List<RestaurantModel>> getFavorites() async {
    final res = await _dio.get(ApiConstants.customerFavorites);
    final raw = res.data;
    if (raw is! Map) return [];
    final success = raw['success'];
    if (success == false) {
      final msg = raw['message']?.toString() ?? 'Failed to load favorites';
      throw Exception(msg);
    }
    final data = raw['data'];
    if (data is! List) return [];
    return data
        .map((e) => RestaurantModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();
  }

  /// Toggle favorite for a restaurant.
  /// Backend: POST /customer/favorites/toggle with { restaurant_id }
  /// Response: { success, message, data: { is_favorite: bool } }
  Future<bool> toggleRestaurantFavorite(int restaurantId) async {
    try {
      final res = await _dio.post(
        ApiConstants.customerFavoritesToggle,
        data: <String, dynamic>{'restaurant_id': restaurantId},
      );

      final raw = res.data;
      if (raw is! Map) {
        throw Exception('Invalid response');
      }
      if (raw['success'] == false) {
        throw Exception(raw['message']?.toString() ?? 'Could not update favorites');
      }

      final data = raw['data'];
      bool? from(dynamic v) {
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.toLowerCase();
          return s == '1' || s == 'true';
        }
        return null;
      }

      if (data is Map) {
        final v = data['is_favorite'] ?? data['isFavorite'] ?? data['favorite'] ?? data['favorited'];
        final parsed = from(v);
        if (parsed != null) return parsed;
      }
      final v = raw['is_favorite'] ?? raw['isFavorite'];
      final parsed = from(v);
      if (parsed != null) return parsed;
      throw Exception(raw['message']?.toString() ?? 'Could not read favorite state');
    } on DioException catch (e) {
      final msg = _messageFromDio(e);
      throw Exception(msg);
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
      final errs = data['errors'];
      if (errs is Map && errs.isNotEmpty) {
        final first = errs.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    if (e.response?.statusCode == 401) {
      return 'Please sign in to use favorites.';
    }
    if (e.response?.statusCode == 403) {
      return 'Favorites are only available for customer accounts.';
    }
    return e.message ?? 'Network error';
  }
}
