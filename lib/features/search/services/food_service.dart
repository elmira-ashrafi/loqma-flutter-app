import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/food_model.dart';

class FoodService {
  FoodService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  /// GET /foods (if your backend supports it) with optional search.
  Future<PaginatedResponse<FoodModel>> getFoods({
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
    String? searchQuery,
  }) async {
    final qp = <String, dynamic>{
      AppConstants.pageParam: page,
      AppConstants.perPageParam: perPage,
      if (searchQuery != null && searchQuery.trim().isNotEmpty) 'q': searchQuery.trim(),
      if (searchQuery != null && searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
    };
    final res = await _dio.get(ApiConstants.foods, queryParameters: qp);
    final raw = res.data;
    Map<String, dynamic> data = {};
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) {
        data = inner;
      } else {
        data = raw;
      }
    } else if (raw is List) {
      data = {'data': raw};
    }
    return PaginatedResponse.fromJson(data, (e) => FoodModel.fromJson(e is Map<String, dynamic> ? e : {}));
  }
}

