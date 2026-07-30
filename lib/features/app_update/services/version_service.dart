import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/version_model.dart';

/// Fetches version metadata from the API and compares semantic versions.
class VersionService {
  VersionService({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  Dio get dio => _dio ?? ApiClient.dio;

  /// GET /app/version — returns null on failure (caller should not block the app).
  Future<VersionModel?> fetchLatestVersion() async {
    try {
      final timeout = Duration(
        milliseconds: AppConstants.versionCheckTimeoutMs,
      );
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.appVersion,
        options: Options(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      final map = response.data ?? {};
      final raw = map['data'] ?? map;
      if (raw is! Map<String, dynamic>) return null;
      return VersionModel.fromJson(raw);
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// True if [latestVersion] is greater than [currentVersion] (e.g. 1.0.2 > 1.0.0).
  bool isRemoteNewerThanCurrent({
    required String currentVersion,
    required String latestVersion,
  }) {
    return compareVersions(latestVersion, currentVersion) > 0;
  }

  /// Positive if [a] > [b], negative if [a] < [b], zero if equal.
  int compareVersions(String a, String b) {
    final pa = _parseVersionParts(a);
    final pb = _parseVersionParts(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }

  List<int> _parseVersionParts(String v) {
    final core = v.split('+').first.trim();
    return core.split('.').map(_leadingInt).toList();
  }

  int _leadingInt(String segment) {
    final m = RegExp(r'^(\d+)').firstMatch(segment.trim());
    if (m == null) return 0;
    return int.tryParse(m.group(1)!) ?? 0;
  }
}
