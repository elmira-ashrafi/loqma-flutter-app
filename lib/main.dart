import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/di/app_bindings.dart';
import 'core/maps/maps_loader.dart';
import 'core/network/cdn_warmup_host.dart';
import 'core/routes/app_pages.dart';
import 'core/controllers/locale_controller.dart';
import 'core/controllers/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_source.dart';
import 'features/notifications/fcm/fcm_background_handler.dart';
import 'features/notifications/services/push_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15+: edge-to-edge by default; enable on older versions too.
  // Avoid setting status/nav bar colors (deprecated Window color APIs).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Do not set status/nav bar colors — those map to deprecated Window APIs on Android 15+.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  // Cap decoded image RAM so list scrolling stays smooth on mid-range devices.
  PaintingBinding.instance.imageCache.maximumSize = 120;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 80 << 20; // 80 MB
  // Firebase must initialize before bootstrap refreshes FCM token via [AuthController.checkAuth].
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushMessagingService.start();
  }
  await setupDependencies();

  if (kIsWeb) {
    try {
      await ensureGoogleMapsScriptLoaded();
    } catch (e, st) {
      debugPrint('Google Maps web bootstrap failed: $e\n$st');
    }
  }

  runApp(const OverfoodApp());

  // Defer FCM sync so home/API requests are not competing on slow networks.
  if (!kIsWeb) {
    Future<void>.delayed(const Duration(seconds: 4), () {
      unawaited(PushMessagingService.refreshTokenCache());
      unawaited(PushMessagingService.syncTokenToBackend());
    });
  }
}

class OverfoodApp extends StatelessWidget {
  const OverfoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();
    final themeCtrl = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لقمه',
      theme: themeCtrl.lightTheme,
      darkTheme: themeCtrl.darkTheme,
      themeMode: themeCtrl.themeMode,
      locale: localeCtrl.locale,
      fallbackLocale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: LocaleCodes.supportedLocales,
      builder: (context, child) {
        return Obx(() {
          final textDirection = localeCtrl.textDirection;
          final themeData = themeCtrl.themeMode == ThemeMode.dark
              ? themeCtrl.darkTheme
              : themeCtrl.lightTheme;
          final mq = MediaQuery.of(context);
          return Theme(
            data: themeData,
            child: Directionality(
              textDirection: textDirection,
              child: MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.35,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child ?? const SizedBox.shrink(),
                    CdnWarmupHost(),
                  ],
                ),
              ),
            ),
          );
        });
      },
      initialRoute: AppRoutes.bootstrap,
      getPages: AppRoutes.pages,
    );
  }
}
