import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'reverse_geocode_result.dart';

/// Uses Laravel geocoding endpoints (Google Geocoding on the server).
class MapsGeocodeService {
  MapsGeocodeService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<({double lat, double lng})?> geocode(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConstants.baseUrl}${ApiConstants.mapsGeocode}',
        data: {'address': trimmed},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final map = response.data ?? {};
      final raw = map['data'] ?? map;
      if (raw is! Map<String, dynamic>) return null;
      final lat = raw['latitude'];
      final lng = raw['longitude'];
      if (lat is num && lng is num) {
        return (lat: lat.toDouble(), lng: lng.toDouble());
      }
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<ReverseGeocodeResult?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConstants.baseUrl}${ApiConstants.mapsReverseGeocode}',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final map = response.data ?? {};
      final raw = map['data'] ?? map;
      if (raw is! Map<String, dynamic>) return null;
      return ReverseGeocodeResult.fromJson(raw);
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
