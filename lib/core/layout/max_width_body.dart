import 'package:flutter/material.dart';

import 'responsive_context.dart';

/// Centers content and limits width on tablet/desktop for readable line length.
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  /// When null, uses [ResponsiveBuildContext.maxContentWidth].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? context.maxContentWidth;
    if (!cap.isFinite || context.screenWidth <= cap) {
      return child;
    }
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
