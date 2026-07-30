import 'package:flutter/material.dart';

import 'app_logo_loading.dart';

/// Centered loading indicator for full-screen / sliver loading (theme-aware).
class AppPageLoading extends StatelessWidget {
  const AppPageLoading({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLogoLoading(
        size: size,
        borderRadius: size * 0.214,
        fallbackColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
