import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Secure storage for tokens and user data.
class StorageService {
  StorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
  }) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    }
    if (expiresIn != null) {
      await _storage.write(
        key: AppConstants.tokenExpiryKey,
        value: (DateTime.now().millisecondsSinceEpoch + expiresIn * 1000).toString(),
      );
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> saveUser(User user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      return User.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.tokenExpiryKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<bool> hasToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }
}
