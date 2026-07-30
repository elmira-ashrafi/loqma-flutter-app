import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/special_offer_models.dart';

/// Public special offers (discounted items flagged by restaurants).
class OffersService {
  OffersService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Map<String, dynamic> _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final inner = responseData['data'];
      if (inner is Map<String, dynamic>) return inner;
    }
    if (responseData is Map) {
      final inner = responseData['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
    }
    return <String, dynamic>{};
  }

  Future<OffersListPage> fetchOffers({int page = 1, int perPage = 20}) async {
    final res = await _dio.get(
      ApiConstants.offers,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return OffersListPage.fromJson(_unwrapData(res.data));
  }
}
