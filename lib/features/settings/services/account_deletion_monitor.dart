import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/network/session_guard.dart';
import '../../auth/controllers/auth_controller.dart';
import 'account_deletion_service.dart';

/// Polls deletion request status and forces sign-in when admin approves.
class AccountDeletionMonitor extends GetxService {
  AccountDeletionMonitor({AccountDeletionService? service})
      : _service = service ?? AccountDeletionService();

  final AccountDeletionService _service;
  Timer? _timer;
  bool _checking = false;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
    _tick();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> ensureStarted() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn || auth.role.value != 'customer') return;
    try {
      final request = await _service.getCurrentRequest();
      if (request?.isPending == true || request?.isApproved == true) {
        start();
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await auth.forceLogoutToLogin();
      }
    }
  }

  Future<void> _tick() async {
    if (_checking) return;
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      stop();
      return;
    }

    _checking = true;
    try {
      final request = await _service.getCurrentRequest();
      if (request?.isApproved == true) {
        stop();
        await auth.forceLogoutToLogin(accountDeleted: true);
        return;
      }
      if (request == null || request.isCancelled || request.isRejected) {
        stop();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        stop();
        await auth.forceLogoutToLogin(
          message: SessionGuard.messageFromResponse(e),
        );
      }
    } catch (_) {
    } finally {
      _checking = false;
    }
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
