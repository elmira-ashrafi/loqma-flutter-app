import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/screens/cart_screen.dart';
import '../../restaurants/screens/restaurant_list_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Cart tab: shows cart summary or empty state.
///
/// Placing an order happens on [CartScreen] → [CheckoutScreen]; on success,
/// checkout shows the same themed QuickAlert used when adding items to the cart.
class CartTab extends StatelessWidget {
  const CartTab({super.key});

  static double _emptyIconSize(BuildContext context) {
    final bp = context.appBreakpoint;
    final narrow = context.screenWidth < 360;
    return switch (bp) {
      AppBreakpoint.compact => narrow ? 64 : 76,
      AppBreakpoint.medium => 88,
      AppBreakpoint.expanded => 96,
    };
  }

  static double _trailingPriceMaxWidth(BuildContext context) {
    final sw = context.screenWidth;
    return switch (context.appBreakpoint) {
      AppBreakpoint.compact => sw < 360 ? sw * 0.38 : sw * 0.42,
      AppBreakpoint.medium => 200,
      AppBreakpoint.expanded => 260,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ctrl = Get.find<CartController>();
    final bp = context.appBreakpoint;
    final isCompactPhone = bp == AppBreakpoint.compact;
    final narrowPhone = context.screenWidth < 360;
    final hPad = context.pageHorizontalPadding;
    final vPadTop = switch (bp) {
      AppBreakpoint.compact => 16.0,
      AppBreakpoint.medium => 20.0,
      AppBreakpoint.expanded => 24.0,
    };
    final vPadBottom = switch (bp) {
      AppBreakpoint.compact => 24.0,
      AppBreakpoint.medium => 28.0,
      AppBreakpoint.expanded => 32.0,
    };
    final tileDensity = isCompactPhone ? VisualDensity.compact : VisualDensity.standard;
    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.28,
    );

    Widget bodyWithScale(Widget child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            l10n.cart,
            maxLines: 1,
            style: FontHelper.getTextStyle(
              text: l10n.cart,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final isEmpty = ctrl.items.isEmpty;
        if (isEmpty) {
          return bodyWithScale(
            MaxWidthBody(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPadTop),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: context.layoutScale(_emptyIconSize(context)),
                            color: cs.onSurfaceVariant,
                          ),
                          SizedBox(height: isCompactPhone ? 12 : 18),
                          Text(
                            l10n.cartEmpty,
                            style: FontHelper.getTextStyle(
                              text: l10n.cartEmpty,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: isCompactPhone ? 20 : (bp == AppBreakpoint.medium ? 22 : 24),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: context.maxContentWidth.clamp(280, 520)),
                            child: Text(
                              l10n.cartEmptyHint,
                              style: FontHelper.getTextStyle(
                                text: l10n.cartEmptyHint,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: isCompactPhone ? 14 : 15,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SizedBox(height: isCompactPhone ? 28 : 22),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
                              ),
                              icon: Icon(
                                Icons.restaurant_rounded,
                                size: context.layoutScale(isCompactPhone ? 20 : 22),
                              ),
                              label: Text(l10n.browseRestaurants),
                              style: FilledButton.styleFrom(
                                minimumSize: Size.fromHeight(isCompactPhone ? 48 : 52),
                                padding: EdgeInsets.symmetric(
                                  horizontal: narrowPhone ? 16 : 24,
                                  vertical: isCompactPhone ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return bodyWithScale(
          MaxWidthBody(
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, vPadTop, hPad, vPadBottom),
              children: [
                if (ctrl.displayRestaurantName != null && ctrl.displayRestaurantName!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: isCompactPhone ? 8 : 12),
                    child: Text(
                      l10n.cartFromRestaurant(ctrl.displayRestaurantName!),
                      style: FontHelper.getTextStyle(
                        text: l10n.cartFromRestaurant(ctrl.displayRestaurantName!),
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: isCompactPhone ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ...ctrl.items.map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: bp == AppBreakpoint.compact ? 2 : 8),
                    child: bp == AppBreakpoint.compact
                        ? ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: narrowPhone ? 0 : 8,
                              vertical: isCompactPhone ? 2 : 4,
                            ),
                            leading: Icon(
                              Icons.fastfood_rounded,
                              size: context.layoutScale(isCompactPhone ? 22 : 24),
                            ),
                            title: Text(
                              e.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FontHelper.getTextStyle(
                                text: e.displayName,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: isCompactPhone ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              _cartItemSubtitle(l10n, e),
                              style: FontHelper.getTextStyle(
                                text: _cartItemSubtitle(l10n, e),
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: isCompactPhone ? 12 : 13,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            trailing: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: _trailingPriceMaxWidth(context),
                              ),
                              child: Text(
                                AppCurrency.format(e.totalPrice, decimalDigits: 2),
                                style: FontHelper.getTextStyle(
                                  text: AppCurrency.format(e.totalPrice, decimalDigits: 2),
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: isCompactPhone ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            visualDensity: tileDensity,
                          )
                        : Material(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.layoutScale(16).clamp(14.0, 22.0),
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  color: AppColors.primary,
                                  size: context.layoutScale(22).clamp(20.0, 26.0),
                                ),
                              ),
                              title: Text(
                                e.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FontHelper.getTextStyle(
                                  text: e.displayName,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _cartItemSubtitle(l10n, e),
                                style: FontHelper.getTextStyle(
                                  text: _cartItemSubtitle(l10n, e),
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              trailing: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: _trailingPriceMaxWidth(context),
                                ),
                                child: Text(
                                  AppCurrency.format(e.totalPrice, decimalDigits: 2),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: isCompactPhone ? 12 : 18),
                _CartTabSummaryCard(
                  ctrl: ctrl,
                  l10n: l10n,
                  theme: theme,
                  compactLayout: isCompactPhone,
                ),
                SizedBox(height: isCompactPhone ? 14 : 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(isCompactPhone ? 48 : (bp == AppBreakpoint.medium ? 52 : 54)),
                    padding: EdgeInsets.symmetric(
                      horizontal: narrowPhone ? 12 : (bp == AppBreakpoint.expanded ? 28 : 18),
                    ),
                  ),
                  child: Text(
                    l10n.viewCartCheckout,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: FontHelper.getTextStyle(
                      text: l10n.viewCartCheckout,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

String _cartItemSubtitle(AppLocalizations l10n, CartItemResponse e) {
  final qty = l10n.cartQtyLine(e.quantity);
  final variant = e.variantName?.trim();
  if (variant != null && variant.isNotEmpty) {
    return '$qty · ${l10n.sizeLabel}: $variant';
  }
  return qty;
}

class _CartTabSummaryCard extends StatelessWidget {
  const _CartTabSummaryCard({
    required this.ctrl,
    required this.l10n,
    required this.theme,
    required this.compactLayout,
  });

  final CartController ctrl;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool compactLayout;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final bp = context.appBreakpoint;

    Widget row(String label, String value, {bool emphasize = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                label,
                style: FontHelper.getTextStyle(
                  text: label,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: emphasize ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                style: FontHelper.getTextStyle(
                  text: value,
                  fontSize: compactLayout && emphasize ? 18 : 16,
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                  color: emphasize ? AppColors.primary : cs.onSurface,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final deliveryLabel = ctrl.deliveryFee == 0 ? l10n.freeDeliveryLabel : l10n.delivery;
    final deliveryValue = ctrl.deliveryFee == 0
        ? l10n.freeDeliveryLabel
        : AppCurrency.format(ctrl.deliveryFee, decimalDigits: 2);

    if (compactLayout) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orderSummary,
              style: FontHelper.getTextStyle(
                text: l10n.orderSummary,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            row(l10n.subtotal, AppCurrency.format(ctrl.subtotal, decimalDigits: 2)),
            row(deliveryLabel, deliveryValue),
            if (ctrl.tax > 0) row(l10n.tax, AppCurrency.format(ctrl.tax, decimalDigits: 2)),
            if (ctrl.discount > 0) row(l10n.discount, '-${AppCurrency.format(ctrl.discount, decimalDigits: 2)}'),
            const SizedBox(height: 4),
            row(l10n.total, AppCurrency.format(ctrl.total, decimalDigits: 2), emphasize: true),
          ],
        ),
      );
    }

    final pad = switch (bp) {
      AppBreakpoint.medium => 18.0,
      AppBreakpoint.expanded => 22.0,
      AppBreakpoint.compact => 16.0,
    };

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orderSummary,
              style: FontHelper.getTextStyle(
                text: l10n.orderSummary,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            row(l10n.subtotal, AppCurrency.format(ctrl.subtotal, decimalDigits: 2)),
            row(deliveryLabel, deliveryValue),
            if (ctrl.tax > 0) row(l10n.tax, AppCurrency.format(ctrl.tax, decimalDigits: 2)),
            if (ctrl.discount > 0) row(l10n.discount, '-${AppCurrency.format(ctrl.discount, decimalDigits: 2)}'),
            const SizedBox(height: 12),
            row(l10n.total, AppCurrency.format(ctrl.total, decimalDigits: 2), emphasize: true),
          ],
        ),
      ),
    );
  }
}