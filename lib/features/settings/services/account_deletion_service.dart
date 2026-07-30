import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/account_deletion_request_model.dart';

class AccountDeletionService {
  AccountDeletionService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<AccountDeletionRequestModel?> getCurrentRequest() async {
    final response = await _dio.get(ApiConstants.customerAccountDeletion);
    final data = response.data as Map<String, dynamic>? ?? {};
    final root = data['data'] ?? data;
    if (root is! Map<String, dynamic>) return null;
    final request = root['request'];
    if (request is! Map<String, dynamic>) return null;
    return AccountDeletionRequestModel.fromJson(request);
  }

  Future<AccountDeletionRequestModel> submitRequest({String? reason}) async {
    final response = await _dio.post(
      ApiConstants.customerAccountDeletion,
      data: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()},
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final root = data['data'] ?? data;
    final request = (root is Map<String, dynamic> ? root['request'] : null) as Map<String, dynamic>?;
    if (request == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid account deletion response',
      );
    }
    return AccountDeletionRequestModel.fromJson(request);
  }

  Future<void> cancelRequest() async {
    await _dio.delete(ApiConstants.customerAccountDeletion);
  }
}
