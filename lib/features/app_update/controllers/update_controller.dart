import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/in_app_update_service.dart';
import '../models/version_model.dart';
import '../services/version_service.dart';
import '../widgets/update_available_dialog.dart';

/// Startup update check: Google Play immediate in-app update (Android), optional API semver prompt.
class UpdateController extends GetxController {
  UpdateController({VersionService? versionService})
    : _versionService = versionService ?? Get.find<VersionService>();

  final VersionService _versionService;

  /// When true, bootstrap must not continue to login/home (forced update UI is active).
  final RxBool blockingNavigation = false.obs;

  final RxBool isOpeningStore = false.obs;
  final RxnString updateError = RxnString();

  /// Called from [AppBootstrapScreen] after the first frame. Android-only Play update first.
  Future<void> runStartupGate() async {
    if (!Platform.isAndroid) return;

    try {
      final playResult = await InAppUpdateService.checkForUpdate();

      // Immediate update UI is full-screen; if Play still owns the flow, stay on bootstrap.
      if (InAppUpdateService.isUpdateFlowActive) {
        blockingNavigation.value = true;
        return;
      }

      switch (playResult) {
        case InAppUpdateStartupResult.success:
          // Play completed the flow. Do not leave the app stuck on bootstrap if
          // the platform returns control instead of restarting the process.
          blockingNavigation.value = false;
          return;
        case InAppUpdateStartupResult.storeRequired:
          await _showPlayStoreFallback();
          return;
        case InAppUpdateStartupResult.skipped:
        case InAppUpdateStartupResult.notAvailable:
        case InAppUpdateStartupResult.userDenied:
        case InAppUpdateStartupResult.failed:
          await _runOptionalBackendVersionPrompt();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('UpdateController.runStartupGate: $e\n$st');
      }
    }
  }

  /// Play knows a newer build exists but cannot start either native update flow.
  Future<void> _showPlayStoreFallback() async {
    final model = VersionModel(
      latestVersion: '',
      forceUpdate: false,
      updateMessage: '',
      downloadUrl: AppConstants.playStoreListingUrl,
    );
    await Get.dialog<void>(
      UpdateAvailableDialog(model: model, forceUpdate: false),
      barrierDismissible: true,
    );
  }

  /// Optional semver prompt from `/app/version` when Play in-app update is unavailable.
  /// Does not run on iOS. Never blocks on API errors.
  Future<void> _runOptionalBackendVersionPrompt() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final remote = await _versionService.fetchLatestVersion();
      if (remote == null) return;
      if (!_versionService.isRemoteNewerThanCurrent(
        currentVersion: packageInfo.version,
        latestVersion: remote.latestVersion,
      )) {
        return;
      }

      if (remote.forceUpdate) {
        blockingNavigation.value = true;
        Get.dialog<void>(
          UpdateAvailableDialog(model: remote, forceUpdate: true),
          barrierDismissible: false,
        );
        return;
      }

      await Get.dialog<void>(
        UpdateAvailableDialog(model: remote, forceUpdate: false),
        barrierDismissible: true,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          'UpdateController._runOptionalBackendVersionPrompt: $e\n$st',
        );
      }
    }
  }

  /// Fallback when Play in-app update is unavailable (e.g. sideloaded build).
  Future<void> openPlayStoreUpdate(VersionModel model) async {
    updateError.value = null;
    if (!Platform.isAndroid) return;

    isOpeningStore.value = true;
    try {
      final marketUri = Uri.parse(
        'market://details?id=${AppConstants.androidPackageId}',
      );
      if (await canLaunchUrl(marketUri)) {
        final launched = await launchUrl(
          marketUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          if (!blockingNavigation.value) Get.back<void>();
          return;
        }
      }

      final webUri = Uri.parse(AppConstants.playStoreListingUrl);
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        updateError.value =
            'Could not open the Play Store. Please update manually.';
        return;
      }
      if (!blockingNavigation.value) Get.back<void>();
    } catch (e) {
      updateError.value =
          'Could not open the Play Store. Please update manually.';
    } finally {
      isOpeningStore.value = false;
    }
  }
}
