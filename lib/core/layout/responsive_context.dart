import 'package:flutter/material.dart';

/// Material-aligned width windows for layout decisions.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  /// Phone / narrow: one column, tight gutters.
  static const double compactMax = 600;

  /// Tablet: two columns, medium gutters.
  static const double mediumMax = 900;

  /// Design baseline width (typical phone) for mild scaling of fixed UI tokens.
  static const double refWidth = 390;
}

enum AppBreakpoint { compact, medium, expanded }

AppBreakpoint breakpointForWidth(double width) {
  if (width < AppBreakpoints.compactMax) return AppBreakpoint.compact;
  if (width < AppBreakpoints.mediumMax) return AppBreakpoint.medium;
  return AppBreakpoint.expanded;
}

/// Feed / home density (moved from [HomeTab] for reuse and consistency).
@immutable
class HomeLayout {
  const HomeLayout._(this.size);

  final Size size;

  factory HomeLayout.of(BuildContext context) => HomeLayout._(MediaQuery.sizeOf(context));

  double get width => size.width;
  double get height => size.height;

  bool get isCompact => width < 400;
  bool get isPhone => width < AppBreakpoints.compactMax;
  bool get isTablet => width >= AppBreakpoints.compactMax && width < AppBreakpoints.mediumMax;
  bool get isDesktop => width >= AppBreakpoints.mediumMax;

  double get horizontalPadding {
    if (isDesktop) return (width - AppBreakpoints.mediumMax).clamp(0, 200) * 0.5 + 24;
    if (isTablet) return 20;
    return isCompact ? 12 : 16;
  }

  double get promoHeight => isCompact ? 150 : (isTablet ? 200 : (isDesktop ? 220 : 170));
  double get bannerHeight => isCompact ? 140 : (isTablet ? 200 : 180);
  double get categoryChipHeight => isCompact ? 52 : (isTablet ? 64 : 58);
  double get categoryChipWidth => isCompact ? 56 : (isTablet ? 72 : 62);
  double get categoryIconSize => isCompact ? 18 : (isTablet ? 24 : 20);
  int get featuredCount => isPhone ? 3 : (isTablet ? 4 : 6);
  int get nearbyCount => isPhone ? 5 : (isTablet ? 6 : 10);
  int get restaurantColumns => isPhone ? 1 : (isTablet ? 2 : 3);
}

extension ResponsiveBuildContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  AppBreakpoint get appBreakpoint => breakpointForWidth(screenWidth);

  bool get isAppCompact => appBreakpoint == AppBreakpoint.compact;

  bool get isAppMedium => appBreakpoint == AppBreakpoint.medium;

  bool get isAppExpanded => appBreakpoint == AppBreakpoint.expanded;

  /// Readable horizontal gutter for scrollable / form screens.
  double get pageHorizontalPadding {
    switch (appBreakpoint) {
      case AppBreakpoint.compact:
        return screenWidth < 360 ? 12 : 16;
      case AppBreakpoint.medium:
        return 24;
      case AppBreakpoint.expanded:
        return 32;
    }
  }

  /// Cap line length on large displays; use with [MaxWidthBody].
  double get maxContentWidth {
    switch (appBreakpoint) {
      case AppBreakpoint.compact:
        return double.infinity;
      case AppBreakpoint.medium:
        return 720;
      case AppBreakpoint.expanded:
        return 1040;
    }
  }

  /// Scale fixed design pixels from [AppBreakpoints.refWidth]; clamped for very small/large devices.
  double layoutScale(double designPx) {
    final ratio = screenWidth / AppBreakpoints.refWidth;
    final s = ratio.clamp(0.88, 1.2);
    return designPx * s;
  }

  int gridCrossAxisCount({int compact = 2, int medium = 3, int expanded = 4}) {
    switch (appBreakpoint) {
      case AppBreakpoint.compact:
        return compact;
      case AppBreakpoint.medium:
        return medium;
      case AppBreakpoint.expanded:
        return expanded;
    }
  }

  EdgeInsets pageInsets({double top = 0, double bottom = 0}) {
    final h = pageHorizontalPadding;
    return EdgeInsets.fromLTRB(h, top, h, bottom);
  }

  /// Side navigation threshold (Material “medium” window).
  bool get useNavigationRail => screenWidth >= 720;
}
