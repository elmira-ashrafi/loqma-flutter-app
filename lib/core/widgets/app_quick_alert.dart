import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

/// Themed success dialog (animated GIF header + slide-up), matching restaurant “add to cart”.
Future<void> showAppSuccessQuickAlert(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  if (!context.mounted) return;
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final mq = MediaQuery.sizeOf(context);
  final dialogW = (mq.width * 0.88).clamp(280.0, 340.0);

  await QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    animType: QuickAlertAnimType.slideInUp,
    title: title,
    text: message,
    titleAlignment: TextAlign.center,
    textAlignment: TextAlign.center,
    width: dialogW,
    borderRadius: 22,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    backgroundColor: cs.surface,
    headerBackgroundColor: cs.primaryContainer.withValues(alpha: 0.35),
    titleColor: cs.onSurface,
    textColor: cs.onSurfaceVariant,
    confirmBtnText: MaterialLocalizations.of(context).okButtonLabel,
    confirmBtnColor: cs.primary,
    confirmBtnTextStyle: TextStyle(
      color: cs.onPrimary,
      fontWeight: FontWeight.w700,
    ),
    autoCloseDuration: const Duration(milliseconds: 2400),
    onConfirmBtnTap: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
}
