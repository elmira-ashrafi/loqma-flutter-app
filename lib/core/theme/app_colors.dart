import 'package:flutter/material.dart';

/// Design system: brand green (#006241), white surfaces, slate body text (#2C3E50).
/// Dark mode uses deep green-tinted surfaces and a lighter primary for contrast.
class AppColors {
  AppColors._();

  // Brand (light mode — buttons, links, selected states)
  static const Color primary = Color(0xFF006241);
  static const Color primaryLight = Color(0xFF008056);
  static const Color primaryDark = Color(0xFF004A30);

  /// Primary on dark backgrounds (readable, still on-brand).
  static const Color primaryDarkTheme = Color(0xFF4DB896);
  static const Color onPrimaryDarkTheme = Color(0xFF002116);
  static const Color primaryContainerDark = Color(0xFF1A3B2F);
  static const Color onPrimaryContainerDark = Color(0xFFB8E8D4);

  static const Color primaryContainerLight = Color(0xFFD4EDE3);
  static const Color onPrimaryContainerLight = Color(0xFF003822);

  // Secondary (accent, less prominent than primary)
  static const Color secondary = Color(0xFF0A7C5C);
  static const Color secondaryLight = Color(0xFF0E9B72);
  static const Color secondaryDarkTheme = Color(0xFF6BC4A6);
  static const Color onSecondaryDarkTheme = Color(0xFF002116);

  // Neutrals — light
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF4F7F6);
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF5D6D7E);
  static const Color textHintLight = Color(0xFF8A9BA8);
  static const Color dividerLight = Color(0xFFE8ECEF);

  // Neutrals — dark (green-tinted charcoal)
  static const Color backgroundDark = Color(0xFF0B0F0D);
  static const Color surfaceDark = Color(0xFF121916);
  static const Color surfaceContainerDark = Color(0xFF1A2320);
  static const Color surfaceContainerHighDark = Color(0xFF222D29);
  static const Color surfaceContainerHighestDark = Color(0xFF2A3632);
  static const Color textPrimaryDark = Color(0xFFEEF2F0);
  static const Color textSecondaryDark = Color(0xFF9EB0A8);
  static const Color textHintDark = Color(0xFF6F827A);
  static const Color dividerDark = Color(0xFF2E3834);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color rating = Color(0xFFFFC022);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
