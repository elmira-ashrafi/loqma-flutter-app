import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import 'app_logo_loading.dart';

/// [RefreshIndicator] replacement: spinner while refreshing; drag uses determinate ring.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40,
    this.strokeWidth = 2.5,
    this.edgeOffset = 0,
    this.notificationPredicate = CustomRefreshIndicator.defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;
  final double edgeOffset;
  final ScrollNotificationPredicate notificationPredicate;
  final String? semanticsLabel;
  final String? semanticsValue;
  final RefreshIndicatorTriggerMode triggerMode;

  static Widget _logoOrRing(
    BuildContext context,
    IndicatorController controller,
    Color primary,
    double strokeWidth, {
    String? semanticsLabel,
    String? semanticsValue,
  }) {
    if (controller.isLoading) {
      return AppLogoLoading(
        size: 56,
        borderRadius: 12,
        fallbackColor: primary,
      );
    }
    final showValue = controller.isDragging || controller.isArmed || controller.isSettling;
    return CircularProgressIndicator(
      value: showValue ? controller.value.clamp(0.0, 1.0) : null,
      strokeWidth: strokeWidth,
      color: primary,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).colorScheme.primary;
    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate: notificationPredicate,
      triggerMode: switch (triggerMode) {
        RefreshIndicatorTriggerMode.onEdge => IndicatorTriggerMode.onEdge,
        RefreshIndicatorTriggerMode.anywhere => IndicatorTriggerMode.anywhere,
      },
      indicatorBuilder: (ctx, controller) => _logoOrRing(
        ctx,
        controller,
        primary,
        strokeWidth,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
      indicatorSize: const Size(56, 56),
      child: child,
    );
  }
}
