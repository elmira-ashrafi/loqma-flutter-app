import 'user_model.dart';

/// Auth response: token(s) + user.
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int? expiresIn;
  final User? user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = _extractToken(json);
    if (token == null || token.isEmpty) {
      throw Exception('Invalid auth response: missing token');
    }
    User? user;
    try {
      final userData = json['user'];
      if (userData is Map<String, dynamic>) {
        user = User.fromJson(userData);
      }
    } catch (_) {
      user = null;
    }
    return AuthResponse(
      accessToken: token,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      user: user,
    );
  }

  /// Try common keys used by Laravel Sanctum, Passport, and custom APIs.
  static String? _extractToken(Map<String, dynamic> json) {
    final keys = ['access_token', 'token', 'accessToken', 'auth_token', 'bearer_token'];
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }
}
