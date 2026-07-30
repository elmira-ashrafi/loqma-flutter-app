import 'package:get/get.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/complete_profile_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../core/screens/app_bootstrap_screen.dart';
import '../../core/screens/language_selection_screen.dart';
import '../../features/driver/screens/driver_main_screen.dart';
import '../../features/restaurant_owner/screens/restaurant_main_screen.dart';
import '../../features/admin/screens/admin_main_screen.dart';

/// App routes.
abstract class AppRoutes {
  static const bootstrap = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const changePassword = '/change-password';
  static const completeProfile = '/complete-profile';
  static const languageSelection = '/language-selection';
  static const main = '/main';
  static const driverMain = '/driver-main';
  static const restaurantMain = '/restaurant-main';
  static const adminMain = '/admin-main';

  static List<GetPage> get pages => [
    GetPage(name: bootstrap, page: () => const AppBootstrapScreen()),
    GetPage(
      name: languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(email: ''),
    ),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: completeProfile, page: () => const CompleteProfileScreen()),
    GetPage(name: main, page: () => const MainScreen()),
    GetPage(name: driverMain, page: () => const DriverMainScreen()),
    GetPage(name: restaurantMain, page: () => const RestaurantMainScreen()),
    GetPage(name: adminMain, page: () => const AdminMainScreen()),
  ];
}
