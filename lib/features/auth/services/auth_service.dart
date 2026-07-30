import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/google_auth_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/send_otp_request.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';
import 'storage_service.dart';

/// Handles auth API calls and token/user persistence.
class AuthService {
  AuthService({required this.storage, Dio? dio, GoogleSignIn? googleSignIn})
      : _dio = dio,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              // Required on Android to receive a real ID token for the backend.
              serverClientId: GoogleAuthConfig.hasWebClientId
                  ? GoogleAuthConfig.webClientId
                  : null,
            );

  final StorageService storage;
  final Dio? _dio;
  final GoogleSignIn _googleSignIn;

  Dio get dio => _dio ?? ApiClient.dio;

  Future<AuthResponse> loginWithPassword(LoginRequest request) async {
    final response = await dio.post(ApiConstants.login, data: request.toJson());
    return _persistAuth(_parseAuthResponse(response.data));
  }

  Future<AuthResponse> registerWithPassword(RegisterRequest request) async {
    final body = request.toJson();
    try {
      return await _registerAt(ApiConstants.register, body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return await _registerAt(ApiConstants.registerAlt, body);
      }
      rethrow;
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    if (!GoogleAuthConfig.hasWebClientId) {
      throw Exception('GOOGLE_NOT_CONFIGURED');
    }

    try {
      // Clear sticky failed sessions so SHA-1 / client-id fixes take effect.
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('GOOGLE_CANCELLED');
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('GOOGLE_NO_ID_TOKEN');
      }

      final response = await dio.post(
        ApiConstants.authGoogle,
        data: {
          'id_token': idToken,
          'name': account.displayName,
          'email': account.email,
          'avatar': account.photoUrl,
        },
      );

      return _persistAuth(_parseAuthResponse(response.data));
    } on PlatformException catch (e) {
      final code = (e.code).toLowerCase();
      final message = (e.message ?? '').toLowerCase();
      if (code.contains('sign_in_canceled') || message.contains('cancel')) {
        throw Exception('GOOGLE_CANCELLED');
      }
      if (code.contains('10') ||
          message.contains('developer_error') ||
          message.contains('api_not_connected')) {
        throw Exception('GOOGLE_NOT_CONFIGURED');
      }
      throw Exception('GOOGLE_FAILED');
    }
  }

  Future<ForgotPasswordResult> forgotPassword(ForgotPasswordRequest request) async {
    final response = await dio.post(
      ApiConstants.authForgotPassword,
      data: request.toJson(),
    );
    final map = _unwrapResponseMap(response.data);
    return ForgotPasswordResult.fromJson(map);
  }

  Future<AdminPasswordResetResult> requestAdminPasswordReset(
    AdminPasswordResetRequest request,
  ) async {
    final response = await dio.post(
      ApiConstants.authPasswordResetRequest,
      data: request.toJson(),
    );
    final map = _unwrapResponseMap(response.data);
    final message = response.data is Map
        ? (response.data as Map)['message'] as String?
        : null;
    return AdminPasswordResetResult(
      requestId: (map['request_id'] as num?)?.toInt(),
      status: map['status'] as String? ?? 'pending',
      message: message,
    );
  }

  Future<TemporaryPasswordStatus> getTemporaryPasswordStatus(String phone) async {
    final response = await dio.post(
      ApiConstants.authPasswordResetStatus,
      data: {'phone': phone.trim()},
    );
    final map = _unwrapResponseMap(response.data);
    return TemporaryPasswordStatus.fromJson(map);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await dio.put(
      ApiConstants.customerSettingsPassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    await dio.post(ApiConstants.authResetPassword, data: request.toJson());
  }

  Future<User> completeProfile(CompleteProfileRequest request) async {
    final response = await dio.put(
      ApiConstants.authCompleteProfile,
      data: request.toJson(),
    );
    final map = _unwrapResponseMap(response.data);
    final user = User.fromJson(map);
    await storage.saveUser(user);
    return user;
  }

  /// Legacy phone OTP (not used by primary customer auth UI).
  Future<void> sendOtp(SendOtpRequest request) async {
    await dio.post(ApiConstants.authSendOtp, data: request.toJson());
  }

  Future<AuthResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await dio.post(
      ApiConstants.authVerifyOtp,
      data: request.toJson(),
    );
    return _persistAuth(_parseAuthResponse(response.data));
  }

  Future<AuthResponse> _registerAt(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await dio.post(path, data: body);
    return _persistAuth(_parseAuthResponse(response.data));
  }

  Future<AuthResponse> _persistAuth(AuthResponse auth) async {
    await storage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      expiresIn: auth.expiresIn,
    );
    if (auth.user != null) {
      await storage.saveUser(auth.user!);
    }
    return auth;
  }

  AuthResponse _parseAuthResponse(dynamic data) {
    final map = _toMap(data);
    if (map == null) {
      final token = _extractTokenString(data);
      if (token != null) {
        return AuthResponse(accessToken: token, user: null);
      }
      if (data is String && _looksLikeHtml(data)) {
        throw Exception(
          'Server returned HTML instead of JSON. '
          'Check that the deployed API URL is correct in api_constants.dart '
          'and that the backend is serving JSON at ${ApiConstants.baseUrl}.',
        );
      }
      throw Exception(
        'Invalid auth response: expected JSON object or token string. '
        'Got ${data?.runtimeType ?? 'null'}. Check your API response format.',
      );
    }
    final unwrapped = _unwrapResponse(map);
    try {
      return AuthResponse.fromJson(unwrapped);
    } on Exception catch (e) {
      if (e.toString().contains('missing token')) {
        return AuthResponse.fromJson(map);
      }
      rethrow;
    }
  }

  static String? _extractTokenString(dynamic data) {
    if (data is String) {
      final s = data.trim();
      if (s.isEmpty) return null;
      if (_looksLikeHtml(s)) return null;
      if (!_isValidTokenValue(s)) return null;
      try {
        final decoded = jsonDecode(data);
        return _extractTokenString(decoded);
      } catch (_) {
        return s;
      }
    }
    return null;
  }

  static bool _looksLikeHtml(String s) {
    final lower = s.toLowerCase();
    return lower.startsWith('<') ||
        lower.contains('<html') ||
        lower.contains('<!doctype') ||
        lower.contains('<script');
  }

  static bool _isValidTokenValue(String s) {
    if (s.length > 8000) return false;
    return !s.contains('\n') && !s.contains('\r') && !s.contains('<');
  }

  static Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _toMap(decoded);
      } catch (_) {}
    }
    return null;
  }

  static Map<String, dynamic> _unwrapResponse(Map<String, dynamic> data) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return inner;
    return data;
  }

  static Map<String, dynamic> _unwrapResponseMap(dynamic data) {
    final map = _toMap(data);
    if (map == null) return {};
    return _unwrapResponse(map);
  }

  Future<User> getMe({
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    final response = await dio.get(
      ApiConstants.me,
      options: connectTimeout != null || receiveTimeout != null
          ? Options(
              connectTimeout: connectTimeout,
              receiveTimeout: receiveTimeout,
              sendTimeout: receiveTimeout,
            )
          : null,
    );
    final data = response.data;
    User user;
    if (data is Map<String, dynamic> && data['data'] != null) {
      user = User.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      user = User.fromJson(data as Map<String, dynamic>);
    }
    await storage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } catch (_) {}
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await storage.clearAll();
  }

  Future<bool> get isLoggedIn => storage.hasToken();
}
