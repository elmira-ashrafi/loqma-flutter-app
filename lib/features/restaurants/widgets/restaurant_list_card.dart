import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../l10n/app_localizations.dart';

abstract final class _CardPalette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color openBg = Color(0xFFE8F5E9);
  static const Color openFg = Color(0xFF4CAF50);
  static const Color closedBg = Color(0xFFFCE4EC);
  static const Color closedFg = Color(0xFFE91E63);
}

/// All-restaurants row card — shared by home feed and offers/deals list.
class RestaurantListCard extends StatelessWidget {
  const RestaurantListCard({
    super.key,
    required this.name,
    required this.description,
    this.image,
    this.rating = 0,
    this.deliveryTime,
    this.prepMinutes,
    this.isOpen,
    this.deliveryFee,
    this.discountPercent,
    this.showOpenStatus = true,
    this.compact = false,
    this.restaurantId,
    this.responsive,
    this.footer,
    this.showChevron = true,
    required this.onTap,
  });

  final String name;
  final String description;
  final String? image;
  final double rating;
  final String? deliveryTime;
  final int? prepMinutes;
  final bool? isOpen;
  final double? deliveryFee;
  final int? discountPercent;
  final bool showOpenStatus;
  final bool compact;
  final int? restaurantId;
  final HomeLayout? responsive;
  final Widget? footer;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = responsive ?? HomeLayout.of(context);
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight ? _CardPalette.navyTitle : theme.colorScheme.onSurface;
    final open = isOpen ?? true;
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = open ? l10n.restaurantStatusOpen : l10n.restaurantStatusClosed;
    final localeDirection = Directionality.of(context);
    final languageCode = Get.find<LocaleController>().locale.languageCode;

    final padding = r.isCompact ? 10.0 : (r.isTablet ? 14.0 : 12.0);
    final imageSize = compact
        ? (r.isCompact ? 72.0 : (r.isTablet ? 96.0 : 80.0))
        : (r.isCompact ? 88.0 : (r.isTablet ? 120.0 : 104.0));
    final borderRadius = r.isTablet ? 20.0 : 16.0;
    final innerRadius = r.isTablet ? 14.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isLight ? Border.all(color: const Color(0xFFEEEEEE)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _wrapHero(
                ClipRRect(
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: image != null && image!.isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: image!,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholderBox(imageSize, innerRadius),
                          errorWidget: (_, __, ___) => _placeholderBox(imageSize, innerRadius),
                        )
                      : _placeholderBox(imageSize, innerRadius),
                ),
                imageSize,
              ),
              SizedBox(width: r.isCompact ? 10.0 : 12.0),
              Expanded(
                child: Directionality(
                  textDirection: localeDirection,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: r.isCompact ? 15 : (r.isTablet ? 17 : 16),
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      SizedBox(height: r.isCompact ? 6 : 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (showOpenStatus)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: open ? _CardPalette.openBg : _CardPalette.closedBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: FontHelper.getTextStyle(
                                  text: statusLabel,
                                  languageCode: languageCode,
                                  fontSize: r.isCompact ? 10 : 11,
                                  fontWeight: FontWeight.w800,
                                  color: open ? _CardPalette.openFg : _CardPalette.closedFg,
                                ).copyWith(letterSpacing: 0.5),
                              ),
                            ),
                          if (discountPercent != null && discountPercent! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '-$discountPercent%',
                                style: FontHelper.getTextStyle(
                                  text: '-$discountPercent%',
                                  languageCode: languageCode,
                                  fontSize: r.isCompact ? 10 : 11,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          if (rating > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: r.isCompact ? 15 : 16, color: AppColors.rating),
                                SizedBox(width: r.isCompact ? 2 : 3),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: FontHelper.getTextStyle(
                                    text: rating.toStringAsFixed(1),
                                    languageCode: languageCode,
                                    fontSize: r.isCompact ? 12 : 13,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            ),
                          if (deliveryFee != null && deliveryFee == 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pedal_bike_rounded,
                                  size: r.isCompact ? 15 : 16,
                                  color: _CardPalette.forestGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.freeDeliveryLabel,
                                  style: FontHelper.getTextStyle(
                                    text: l10n.freeDeliveryLabel,
                                    languageCode: languageCode,
                                    fontSize: r.isCompact ? 11 : 12,
                                    fontWeight: FontWeight.w700,
                                    color: _CardPalette.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: r.isCompact ? 4 : 6),
                        Text(
                          description,
                          style: FontHelper.getTextStyle(
                            text: description,
                            languageCode: languageCode,
                            fontSize: r.isCompact ? 11 : (r.isTablet ? 13 : 12),
                            fontWeight: FontWeight.normal,
                            color: _CardPalette.mutedGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                      if ((prepMinutes != null && prepMinutes! > 0) ||
                          (deliveryTime != null && deliveryTime!.trim().isNotEmpty)) ...[
                        SizedBox(height: r.isCompact ? 2 : 4),
                        Text(
                          restaurantPrepTimeCaption(
                            context,
                            avgPrepMinutes: prepMinutes,
                            rawDeliveryTime: deliveryTime,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _CardPalette.mutedGray,
                            fontSize: r.isCompact ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (footer != null) ...[
                        SizedBox(height: r.isCompact ? 4 : 6),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 4),
                Container(
                  width: r.isCompact ? 32 : 36,
                  height: r.isCompact ? 32 : 36,
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF0F0F0) : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isLight ? _CardPalette.mutedGray : theme.colorScheme.onSurfaceVariant,
                    size: r.isCompact ? 22 : 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox(double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: size * 0.4),
    );
  }

  Widget _wrapHero(Widget child, double size) {
    if (restaurantId == null) return child;
    return Hero(
      tag: 'restaurant_hero_small_$restaurantId',
      child: child,
    );
  }
}
