import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Controls app theme (light/dark) and persists it.
class ThemeController extends GetxController {
  ThemeController() : _mode = ThemeMode.light.obs;

  final Rx<ThemeMode> _mode;

  ThemeMode get themeMode => _mode.value;
  bool get isDark => _mode.value == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(AppConstants.themeModeKey);
    switch (value) {
      case 'dark':
        _mode.value = ThemeMode.dark;
        break;
      case 'light':
      default:
        _mode.value = ThemeMode.light;
        break;
    }
  }

  Future<void> _persist(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'light',
    };
    await prefs.setString(AppConstants.themeModeKey, value);
  }

  void setThemeMode(ThemeMode mode) {
    _mode.value = mode;
    _persist(mode);
    Get.changeThemeMode(mode);
  }

  void toggleDark(bool enabled) {
    setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;
}

