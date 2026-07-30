import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simple centered loading indicator (theme-aware).
///
/// [fallbackColor] is used in light mode (typically [ColorScheme.primary]); in dark mode the
/// spinner is white for contrast.
/// [borderRadius] is kept for API compatibility with older call sites; it has no visual effect.
class AppLogoLoading extends StatelessWidget {
  const AppLogoLoading({
    super.key,
    this.size = 56,
    this.borderRadius = 12,
    required this.fallbackColor,
  });

  final double size;
  final double borderRadius;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : fallbackColor;
    final stroke = math.max(2.0, size * 0.08);

    return Semantics(
      label: 'Loading',
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: stroke,
          color: color,
        ),
      ),
    );
  }
}
