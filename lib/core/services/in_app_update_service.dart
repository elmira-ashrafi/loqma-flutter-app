import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

/// Result of a one-time Google Play immediate update check per app launch.
enum InAppUpdateStartupResult {
  /// Not Android / web, or check skipped because it already ran.
  skipped,

  /// Play reports no newer version.
  notAvailable,

  /// Play reports a newer version, but neither native update flow is allowed.
  storeRequired,

  /// User accepted; Play may restart the app before control returns.
  success,

  /// User dismissed the Play update UI.
  userDenied,

  /// Play Services / Play Store unavailable, debug sideload, or other failure.
  failed,
}

/// Google Play in-app updates (Android only).
///
/// Testing notes (see also [checkForUpdate]):
/// - Works only when the app was installed from Google Play (Internal Testing,
///   Closed/Open testing, or production).
/// - A release with a **higher** [versionCode] (the number after `+` in
///   `pubspec.yaml`, e.g. `1.0.4+5` → versionCode `5`) must be published to the
///   same track and available to the signed-in Play account.
/// - Does **not** work with a locally installed debug/release APK (`flutter run`,
///   sideloaded APK) — expect `ERROR_API_NOT_AVAILABLE` or `notAvailable`.
/// - Use **Internal testing** or **Internal app sharing** to validate before release.
class InAppUpdateService {
  InAppUpdateService._();

  static bool _hasChecked = false;
  static bool _updateFlowActive = false;

  /// Whether an immediate update flow is currently in progress.
  static bool get isUpdateFlowActive => _updateFlowActive;

  /// Resets launch guard (tests only).
  @visibleForTesting
  static void resetForTesting() {
    _hasChecked = false;
    _updateFlowActive = false;
  }

  /// Checks Google Play once per process.
  ///
  /// Prefers an immediate update and falls back to a flexible update. This is
  /// important because Play commonly permits flexible updates while disallowing
  /// immediate updates for normal-priority releases.
  ///
  /// Does not open the Play Store listing; download/install/restart are handled by Play.
  /// Safe to call on iOS, web, and desktop — returns [InAppUpdateStartupResult.skipped].
  static Future<InAppUpdateStartupResult> checkForUpdate() async {
    if (kIsWeb || !Platform.isAndroid || _hasChecked || _updateFlowActive) {
      return InAppUpdateStartupResult.skipped;
    }

    _hasChecked = true;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (kDebugMode) {
        debugPrint(
          'InAppUpdate: availability=${updateInfo.updateAvailability}, '
          'immediateAllowed=${updateInfo.immediateUpdateAllowed}, '
          'flexibleAllowed=${updateInfo.flexibleUpdateAllowed}, '
          'availableVersionCode=${updateInfo.availableVersionCode}',
        );
      }

      final updateAvailable =
          updateInfo.updateAvailability == UpdateAvailability.updateAvailable ||
          updateInfo.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;

      if (!updateAvailable) {
        return InAppUpdateStartupResult.notAvailable;
      }

      if (updateInfo.immediateUpdateAllowed) {
        _updateFlowActive = true;
        try {
          final result = await InAppUpdate.performImmediateUpdate();
          if (kDebugMode) {
            debugPrint('InAppUpdate: performImmediateUpdate → $result');
          }
          return _mapResult(result);
        } finally {
          _updateFlowActive = false;
        }
      }

      if (updateInfo.flexibleUpdateAllowed) {
        _updateFlowActive = true;
        try {
          final result = await InAppUpdate.startFlexibleUpdate();
          if (kDebugMode) {
            debugPrint('InAppUpdate: startFlexibleUpdate → $result');
          }
          if (result == AppUpdateResult.success) {
            await InAppUpdate.completeFlexibleUpdate();
          }
          return _mapResult(result);
        } finally {
          _updateFlowActive = false;
        }
      }

      return InAppUpdateStartupResult.storeRequired;
    } on PlatformException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('InAppUpdate platform error: ${error.code} ${error.message}');
        debugPrintStack(stackTrace: stackTrace);
      }
      _updateFlowActive = false;
      return InAppUpdateStartupResult.failed;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('InAppUpdate error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      _updateFlowActive = false;
      return InAppUpdateStartupResult.failed;
    }
  }

  static InAppUpdateStartupResult _mapResult(AppUpdateResult result) {
    return switch (result) {
      AppUpdateResult.success => InAppUpdateStartupResult.success,
      AppUpdateResult.userDeniedUpdate => InAppUpdateStartupResult.userDenied,
      AppUpdateResult.inAppUpdateFailed => InAppUpdateStartupResult.failed,
    };
  }
}
