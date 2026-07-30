import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/send_otp_request.dart';
import '../models/verify_otp_request.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/auth_error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../notifications/services/push_messaging_service.dart';
import '../../favorites/controllers/favorites_controller.dart';

/// Global auth state and login/register/logout actions.
class AuthController extends GetxController {
  AuthController({StorageService? storage, AuthService? authService})
    : _storage = storage ?? StorageService(),
      _authService =
          authService ?? AuthService(storage: storage ?? StorageService());

  final StorageService _storage;
  final AuthService _authService;

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  /// Last API field errors for login/register forms (email, phone, password…).
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxString role =
      ''.obs; // 'customer', 'driver', 'restaurant', 'admin', etc.

  User? get currentUser => user.value;
  bool get isLoggedIn => user.value != null;

  bool get needsProfileCompletion {
    final u = user.value;
    if (u == null) return false;
    return !u.isProfileComplete;
  }

  bool get needsPasswordChange {
    final u = user.value;
    if (u == null) return false;
    return u.mustChangePassword;
  }

  Future<void> restoreCachedSession() async {
    final u = await _storage.getUser();
    user.value = u;
    if (u == null || !await _authService.isLoggedIn) {
      role.value = '';
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    role.value = prefs.getString(AppConstants.userRoleKey) ?? '';
    if (role.value.isEmpty) {
      role.value = 'customer';
    }
  }

  Future<void> checkAuth({bool probeRole = false}) async {
    await restoreCachedSession();
    if (!isLoggedIn) return;

    try {
      final fresh = await _authService.getMe();
      user.value = fresh;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await forceLogoutToLogin(accountDeleted: true);
        return;
      }
    } catch (_) {}

    if (probeRole && !needsProfileCompletion) {
      try {
        await detectRole();
      } catch (_) {
        if (role.value.isEmpty) await _persistRole('customer');
      }
    } else if (role.value.isEmpty) {
      await _persistRole('customer');
    }

    unawaited(_syncPushTokens());
  }

  Future<void> _syncPushTokens() async {
    await PushMessagingService.refreshTokenCache();
    await PushMessagingService.syncTokenToBackend();
  }

  Future<void> _persistRole(String value) async {
    role.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userRoleKey, value);
  }

  Future<bool> loginWithPassword(LoginRequest request) async {
    return _runAuthAction(() async {
      final res = await _authService.loginWithPassword(request);
      await _applyAuthResponse(res);
      return true;
    }, showSnackbar: false);
  }

  Future<bool> registerWithPassword(RegisterRequest request) async {
    return _runAuthAction(() async {
      final res = await _authService.registerWithPassword(request);
      await _applyAuthResponse(res);
      return true;
    }, showSnackbar: false);
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      final res = await _authService.signInWithGoogle();
      await _applyAuthResponse(res);
      return true;
    }, showSnackbar: false);
  }

  Future<ForgotPasswordResult?> forgotPassword(ForgotPasswordRequest request) async {
    isLoading.value = true;
    error.value = '';
    fieldErrors.clear();
    try {
      return await _authService.forgotPassword(request);
    } on DioException catch (e) {
      _applyAuthError(e, showSnackbar: false);
      return null;
    } on Exception catch (e) {
      _applyAuthError(e, showSnackbar: false);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminPasswordResetResult?> requestAdminPasswordReset(
    AdminPasswordResetRequest request,
  ) async {
    isLoading.value = true;
    error.value = '';
    fieldErrors.clear();
    try {
      return await _authService.requestAdminPasswordReset(request);
    } on DioException catch (e) {
      _applyAuthError(e, showSnackbar: false);
      return null;
    } on Exception catch (e) {
      _applyAuthError(e, showSnackbar: false);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<TemporaryPasswordStatus?> fetchTemporaryPasswordStatus(String phone) async {
    try {
      return await _authService.getTemporaryPasswordStatus(phone);
    } catch (_) {
      return null;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _runAuthAction(() async {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final u = user.value;
      if (u != null) {
        final updated = u.copyWith(mustChangePassword: false);
        user.value = updated;
        await _storage.saveUser(updated);
      }
      return true;
    }, syncPush: false, showSnackbar: false);
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    return _runAuthAction(() async {
      await _authService.resetPassword(request);
      return true;
    }, syncPush: false, showSnackbar: false);
  }

  Future<bool> completeProfile(CompleteProfileRequest request) async {
    return _runAuthAction(() async {
      final updated = await _authService.completeProfile(request);
      user.value = updated;
      await detectRole();
      await PushMessagingService.refreshTokenCache();
      await PushMessagingService.syncTokenToBackend();
      return true;
    }, syncPush: false, showSnackbar: false);
  }

  /// Legacy phone OTP helpers (unused by password/Google customer UI).
  Future<bool> sendCustomerOtp(SendOtpRequest request) async {
    return _runAuthAction(() async {
      await _authService.sendOtp(request);
      return true;
    }, syncPush: false);
  }

  Future<bool> verifyCustomerOtp(VerifyOtpRequest request) async {
    return _runAuthAction(() async {
      final res = await _authService.verifyOtp(request);
      await _applyAuthResponse(res);
      return true;
    });
  }

  Future<bool> _runAuthAction(
    Future<bool> Function() action, {
    bool syncPush = true,
    bool showSnackbar = true,
  }) async {
    isLoading.value = true;
    error.value = '';
    fieldErrors.clear();
    try {
      final ok = await action();
      if (ok && syncPush) {
        await PushMessagingService.refreshTokenCache();
        await PushMessagingService.syncTokenToBackend();
      }
      return ok;
    } on DioException catch (e) {
      _applyAuthError(e, showSnackbar: showSnackbar);
      return false;
    } on Exception catch (e) {
      _applyAuthError(e, showSnackbar: showSnackbar);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _applyAuthError(Object e, {required bool showSnackbar}) {
    final locale = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>().locale
        : const Locale('en');
    final l10n = lookupAppLocalizations(locale);
    final mapped = AuthErrorMapper.fromAny(e, l10n);
    error.value = mapped.message;
    fieldErrors
      ..clear()
      ..addAll(mapped.fieldErrors);
    if (showSnackbar) {
      _showErrorSnackbar(mapped.message);
    }
  }

  Future<void> _applyAuthResponse(AuthResponse res) async {
    if (res.user != null) {
      user.value = res.user;
    } else {
      try {
        user.value = await _authService.getMe();
      } catch (_) {
        user.value = null;
      }
    }
    if (!needsProfileCompletion) {
      await detectRole();
    }
    if (isLoggedIn && Get.isRegistered<FavoritesController>()) {
      unawaited(Get.find<FavoritesController>().load());
    }
  }

  Future<void> navigateAfterAuth() async {
    if (needsPasswordChange) {
      if (Get.currentRoute != AppRoutes.changePassword) {
        Get.offAllNamed(AppRoutes.changePassword);
      }
      return;
    }
    if (needsProfileCompletion) {
      if (Get.currentRoute != AppRoutes.completeProfile) {
        Get.offAllNamed(AppRoutes.completeProfile);
      }
      return;
    }
    Get.offAllNamed(resolveLandingRoute());
  }

  String resolveBootstrapRoute() {
    if (!isLoggedIn) return AppRoutes.login;
    if (needsPasswordChange) return AppRoutes.changePassword;
    if (needsProfileCompletion) return AppRoutes.completeProfile;
    return resolveLandingRoute();
  }

  bool _forceLogoutInProgress = false;

  Future<void> logout() async {
    await _authService.logout();
    ApiClient.reset();
    user.value = null;
    role.value = '';
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().clear();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userRoleKey);
  }

  Future<void> forceLogoutToLogin({String? message, bool accountDeleted = false}) async {
    if (_forceLogoutInProgress) return;
    _forceLogoutInProgress = true;
    try {
      await logout();
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
      final locale = Get.isRegistered<LocaleController>()
          ? Get.find<LocaleController>().locale
          : const Locale('en');
      final l10n = lookupAppLocalizations(locale);
      final text = message ??
          (accountDeleted
              ? l10n.deleteAccountSessionEnded
              : l10n.deleteAccountSessionEnded);
      if (text.isNotEmpty) {
        _showInfoSnackbar(l10n.signInRequired, text);
      }
    } finally {
      _forceLogoutInProgress = false;
    }
  }

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1F2937),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
    );
  }

  void clearError() {
    error.value = '';
    fieldErrors.clear();
  }

  void _showErrorSnackbar(String message) {
    if (message.isEmpty) return;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  String resolveLandingRoute() {
    switch (role.value) {
      case 'driver':
        return AppRoutes.driverMain;
      case 'restaurant_owner':
        return AppRoutes.restaurantMain;
      case 'admin':
      case 'super_admin':
        return AppRoutes.adminMain;
      case 'customer':
      default:
        return AppRoutes.main;
    }
  }

  Future<String> detectRole() async {
    try {
      final dio = ApiClient.dio;
      final probeTimeout = Duration(
        milliseconds: AppConstants.startupNetworkTimeoutMs,
      );
      final detected =
          await _probeRole(
            dio,
            ApiConstants.driverDashboard,
            'driver',
            probeTimeout,
          ) ??
          await _probeRole(
            dio,
            ApiConstants.restaurantDashboard,
            'restaurant_owner',
            probeTimeout,
          ) ??
          await _probeRole(
            dio,
            ApiConstants.adminDashboard,
            'admin',
            probeTimeout,
          );

      if (detected != null) {
        await _persistRole(detected);
        return detected;
      }
    } catch (_) {}

    await _persistRole('customer');
    return role.value;
  }

  Future<String?> _probeRole(
    Dio dio,
    String path,
    String resolvedRole,
    Duration timeout,
  ) async {
    try {
      await dio.get(
        path,
        options: Options(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      return resolvedRole;
    } on DioException catch (_) {
      return null;
    }
  }
}
