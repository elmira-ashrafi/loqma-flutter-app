import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../theme/app_colors.dart';
import '../utils/font_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';

/// Floating success toast — non-blocking, with optional action.
void showAppToastNotice(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  IconData icon = Icons.check_rounded,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;

  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final languageCode = Get.isRegistered<LocaleController>()
      ? Get.find<LocaleController>().locale.languageCode
      : Localizations.localeOf(context).languageCode;
  final isLight = theme.brightness == Brightness.light;
  final bottom = MediaQuery.viewPaddingOf(context).bottom;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Material(
          color: isLight ? Colors.white : cs.surfaceContainerHigh,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLight ? const Color(0xFFE8E8E8) : cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FontHelper.getTextStyle(
                      text: message,
                      languageCode: languageCode,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onAction();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel,
                      style: FontHelper.getTextStyle(
                        text: actionLabel,
                        languageCode: languageCode,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
}

/// Shown when the user tries to add items from a second restaurant.
void showDifferentRestaurantCartNotice(
  BuildContext context, {
  required String restaurantName,
}) {
  final l10n = AppLocalizations.of(context)!;
  showAppToastNotice(
    context,
    message: l10n.cartDifferentRestaurantMessage(restaurantName),
    icon: Icons.storefront_outlined,
    duration: const Duration(seconds: 5),
    actionLabel: l10n.viewCartCheckout,
    onAction: () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CartScreen()),
      );
    },
  );
}

/// Non-blocking “added to cart” feedback.
void showAppAddedToCartNotice(
  BuildContext context, {
  required String message,
  bool showViewCartAction = true,
}) {
  final l10n = AppLocalizations.of(context)!;
  showAppToastNotice(
    context,
    message: message,
    actionLabel: showViewCartAction ? l10n.viewCart : null,
    onAction: showViewCartAction
        ? () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            );
          }
        : null,
  );
}

/// Non-blocking order placed / payment confirmed feedback.
void showAppOrderPlacedNotice(
  BuildContext context, {
  required String message,
  int? orderId,
}) {
  final l10n = AppLocalizations.of(context)!;
  showAppToastNotice(
    context,
    message: message,
    icon: Icons.receipt_long_rounded,
    duration: const Duration(seconds: 4),
    actionLabel: orderId != null ? l10n.trackOrder : null,
    onAction: orderId != null
        ? () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OrderDetailScreen(orderId: orderId),
              ),
            );
          }
        : null,
  );
}

/// Shows order toast on the root shell after checkout navigation unwinds.
void showAppOrderPlacedNoticeAfterCheckout({
  required String message,
  int? orderId,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = Get.context;
    if (ctx != null && ctx.mounted) {
      showAppOrderPlacedNotice(ctx, message: message, orderId: orderId);
    }
  });
}

/// Non-blocking feedback when an address is saved or updated.
void showAppAddressSavedNotice(
  BuildContext context, {
  bool updated = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  showAppToastNotice(
    context,
    message: updated ? l10n.addressUpdatedSuccess : l10n.addressSavedSuccess,
    icon: Icons.location_on_rounded,
    duration: const Duration(seconds: 3),
  );
}

/// Non-blocking feedback when an address is removed.
void showAppAddressRemovedNotice(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showAppToastNotice(
    context,
    message: l10n.addressRemovedSuccess,
    icon: Icons.delete_outline_rounded,
    duration: const Duration(seconds: 3),
  );
}

/// Shows address toast on the parent screen after the wizard/form pops.
void showAppAddressSavedNoticeAfterPop({bool updated = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = Get.context;
    if (ctx != null && ctx.mounted) {
      showAppAddressSavedNotice(ctx, updated: updated);
    }
  });
}
