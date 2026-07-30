import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/cart_model.dart';

/// Cart API: calculate totals from items.
class CartService {
  CartService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<CartCalculateResponse> calculate(CartCalculateRequest request) async {
    final response = await _dio.post(
      ApiConstants.cartCalculate,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    return CartCalculateResponse.fromJson(data);
  }
}
