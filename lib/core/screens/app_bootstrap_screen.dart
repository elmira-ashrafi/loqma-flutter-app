import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../network/cdn_browser_warmup.dart';
import '../../features/app_update/controllers/update_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/settings/services/account_deletion_monitor.dart';
import '../routes/app_pages.dart';

/// Runs startup update check and routes to login or the correct home.
class AppBootstrapScreen extends StatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  State<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<AppBootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch =
        !(prefs.getBool(AppConstants.firstDataLoadDoneKey) ?? false);

    final splashMin = isFirstLaunch
        ? Future<void>.delayed(
            const Duration(milliseconds: AppConstants.bootstrapFirstLoadMs),
          )
        : Future<void>.value();

    final updateController = Get.find<UpdateController>();
    await splashMin;
    await CdnBrowserWarmup.warmupActiveOrigin();
    await updateController.runStartupGate();

    if (!mounted) return;
    if (updateController.blockingNavigation.value) return;

    if (isFirstLaunch) {
      await prefs.setBool(AppConstants.firstDataLoadDoneKey, true);
    }

    final languageDone =
        prefs.getBool(AppConstants.languageSelectionDoneKey) ?? false;
    if (!languageDone) {
      Get.offAllNamed(AppRoutes.languageSelection);
      return;
    }

    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      unawaited(_refreshSessionAfterLaunch(auth));
      Get.offAllNamed(auth.resolveBootstrapRoute());
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _refreshSessionAfterLaunch(AuthController auth) async {
    await auth.checkAuth(probeRole: true);
    if (!auth.isLoggedIn) return;
    final route = auth.resolveBootstrapRoute();
    if (Get.currentRoute != route) {
      Get.offAllNamed(route);
    }
    if (auth.needsProfileCompletion) return;
    if (!Get.isRegistered<AccountDeletionMonitor>()) return;
    if (auth.role.value == 'customer') {
      await Get.find<AccountDeletionMonitor>().ensureStarted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/loqma_logo_light.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => Icon(
                Icons.restaurant_rounded,
                size: 72,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
