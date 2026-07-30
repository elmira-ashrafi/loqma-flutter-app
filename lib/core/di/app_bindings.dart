import 'package:get/get.dart';
import '../../features/checkout/services/payment_return_service.dart';
import '../../features/app_update/controllers/update_controller.dart';
import '../../features/app_update/services/version_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/services/storage_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/settings/services/account_deletion_monitor.dart';
import '../controllers/locale_controller.dart';
import '../controllers/theme_controller.dart';
import '../constants/api_constants.dart';
import '../network/session_guard.dart';

/// Registers global controllers and dependencies.
Future<void> setupDependencies() async {
  await ApiConstants.initActiveOrigin();
  final storage = StorageService();
  final authService = AuthService(storage: storage);
  Get.put(storage, permanent: true);
  Get.put(authService, permanent: true);
  Get.put(PaymentReturnService(), permanent: true);
  Get.put(VersionService(), permanent: true);
  Get.put(UpdateController(), permanent: true);
  final authController = AuthController(storage: storage, authService: authService);
  Get.put(authController, permanent: true);
  SessionGuard.onSessionExpired = ({message}) => authController.forceLogoutToLogin(message: message);
  Get.put(AccountDeletionMonitor(), permanent: true);
  await authController.restoreCachedSession();
  final localeController = Get.put(LocaleController(), permanent: true);
  await localeController.init();
  final themeController = Get.put(ThemeController(), permanent: true);
  await themeController.init();
}
