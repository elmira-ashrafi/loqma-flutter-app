import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/address_model.dart';

class AddressService {
  AddressService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get(ApiConstants.customerAddresses);
    final raw = response.data;
    if (raw is! Map) return [];
    final root = Map<String, dynamic>.from(raw);
    final inner = root['data'];
    List<dynamic> list;
    if (inner is List) {
      list = inner;
    } else if (inner is Map && inner['items'] is List) {
      list = inner['items'] as List<dynamic>;
    } else if (inner is Map && inner['addresses'] is List) {
      list = inner['addresses'] as List<dynamic>;
    } else {
      list = [];
    }
    return list
        .whereType<Map>()
        .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CityModel>> getCities({bool withDistricts = true}) async {
    final response = await _dio.get(
      ApiConstants.cities,
      queryParameters: withDistricts ? const {'with_districts': 1} : null,
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final list = (data['data'] ?? data['cities'] ?? data) as List<dynamic>? ?? [];
    return list
        .whereType<Map>()
        .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<DistrictModel>> getDistricts(int cityId) async {
    final response = await _dio.get(ApiConstants.cityDistricts(cityId));
    final data = response.data as Map<String, dynamic>? ?? {};
    final list = (data['data'] ?? data['districts'] ?? data) as List<dynamic>? ?? [];
    return list
        .whereType<Map>()
        .map((e) => DistrictModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    final response = await _dio.post(
      ApiConstants.customerAddresses,
      data: address.toJson(),
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return AddressModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    final response = await _dio.put(
      ApiConstants.customerAddressById(address.id),
      data: address.toJson(),
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return AddressModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> deleteAddress(int id) async {
    await _dio.delete(ApiConstants.customerAddressById(id));
  }
}
