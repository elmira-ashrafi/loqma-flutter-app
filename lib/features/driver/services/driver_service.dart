import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/driver_models.dart';

class DriverService {
  DriverService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<DriverDashboardData> getDashboard() async {
    final res = await _dio.get(ApiConstants.driverDashboard);
    final data = res.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return DriverDashboardData.fromJson(raw as Map<String, dynamic>);
  }

  Future<bool> toggleOnline(bool online) async {
    final res = await _dio.post(
      ApiConstants.driverToggleOnline,
      data: {'online': online},
    );
    final data = res.data as Map<String, dynamic>? ?? {};
    return data['online'] as bool? ?? online;
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _dio.post(
      ApiConstants.driverUpdateLocation,
      data: {
        'latitude': lat,
        'longitude': lng,
      },
    );
  }

  Future<void> acceptOrder(int orderId) async {
    await _dio.post(ApiConstants.driverAcceptOrder(orderId));
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _dio.post(
      ApiConstants.driverOrderStatus(orderId),
      data: {'status': status},
    );
  }

  Future<List<DriverOrder>> getOrders({String? status}) async {
    final res = await _dio.get(
      ApiConstants.driverOrders,
      queryParameters: status != null && status.isNotEmpty ? {'status': status} : null,
    );
    final data = res.data as Map<String, dynamic>? ?? {};
    final rawList = data['data'] ?? data['orders'] ?? data;
    final list = rawList is List ? rawList : <dynamic>[];
    return list.whereType<Map<String, dynamic>>().map(DriverOrder.fromJson).toList();
  }

  Future<DriverOrder> getOrderById(int id) async {
    final res = await _dio.get(ApiConstants.driverOrderById(id));
    final data = res.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return DriverOrder.fromJson(raw as Map<String, dynamic>);
  }

  /// Earnings summary from /driver/earnings.
  Future<Map<String, dynamic>> getEarnings() async {
    final res = await _dio.get(ApiConstants.driverEarnings);
    final data = res.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return data;
  }

  Future<void> requestPayout(String method) async {
    await _dio.post(
      ApiConstants.driverPayoutRequest,
      data: {'payment_method': method},
    );
  }

  Future<DriverInfo> getProfile() async {
    final res = await _dio.get(ApiConstants.driverProfile);
    final data = res.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return DriverInfo.fromJson(raw as Map<String, dynamic>);
  }

  Future<DriverInfo> updateProfile(Map<String, dynamic> body) async {
    final res = await _dio.put(ApiConstants.driverProfileUpdate, data: body);
    final data = res.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return DriverInfo.fromJson(raw as Map<String, dynamic>);
  }
}

