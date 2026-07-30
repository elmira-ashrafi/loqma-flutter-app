import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../models/menu_item_display.dart';

/// Reference palette (matches restaurant details / home ref design).
abstract final class _MenuItemPalette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color cardBorder = Color(0xFFEEEEEE);
  static const Color promoOrange = Color(0xFFFF9800);
  static const Color promoOrangeBg = Color(0xFFFFF3E0);
}

class MenuItemCard extends StatefulWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    this.onTap,
  });

  final MenuItemDisplay item;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final itemName = widget.item.nameFor(languageCode);
    final itemDescription = widget.item.descriptionFor(languageCode);
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 400;
    final isNarrow = media.width < 360;
    final imageSize = isCompact ? (isNarrow ? 68.0 : 72.0) : 84.0;
    final hasDiscount = widget.item.oldPrice != null && widget.item.oldPrice! > widget.item.price;
    final promoLabel = widget.item.promoCode ??
        (hasDiscount && widget.item.discountPercent != null ? '${widget.item.discountPercent}%' : null);
    final priceColor = isLight ? _MenuItemPalette.forestGreen : theme.colorScheme.primary;
    final mutedColor = isLight
        ? _MenuItemPalette.mutedGray
        : theme.colorScheme.onSurfaceVariant;
    final borderColor = isLight
        ? _MenuItemPalette.cardBorder
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 10 : 12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.item.image != null && widget.item.image!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: widget.item.image!,
                        width: imageSize,
                        height: imageSize,
                        borderRadius: BorderRadius.circular(10),
                        placeholder: (_, __) => _placeholder(imageSize),
                        errorWidget: (_, __, ___) => _placeholder(imageSize),
                      )
                    : _placeholder(imageSize),
                SizedBox(width: isCompact ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        itemName,
                        style: FontHelper.getTextStyle(
                          text: itemName,
                          languageCode: languageCode,
                          fontWeight: FontWeight.w800,
                          fontSize: isCompact ? 15 : 16,
                          color: isLight
                              ? _MenuItemPalette.navyTitle
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (itemDescription != null && itemDescription.isNotEmpty) ...[
                        SizedBox(height: isCompact ? 3 : 4),
                        Text(
                          itemDescription,
                          style: FontHelper.getTextStyle(
                            text: itemDescription,
                            languageCode: languageCode,
                            color: mutedColor,
                            fontSize: isCompact ? 11 : 12,
                          ).copyWith(height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: isCompact ? 6 : 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            AppCurrency.format(widget.item.price, decimalDigits: 0),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: priceColor,
                              fontWeight: FontWeight.w800,
                              fontSize: isCompact ? 14 : 15,
                            ),
                          ),
                          if (promoLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? _MenuItemPalette.promoOrangeBg
                                    : _MenuItemPalette.promoOrange.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                promoLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isLight
                                      ? _MenuItemPalette.promoOrange
                                      : const Color(0xFFFFB74D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (hasDiscount && widget.item.oldPrice != null)
                            Text(
                              AppCurrency.format(widget.item.oldPrice!, decimalDigits: 0),
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: mutedColor,
                                fontSize: isCompact ? 11 : 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isCompact ? 8 : 10),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Semantics(
                    label: '${l10n.menuItemAddToCart}: $itemName',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTapDown: (_) => _scaleController.forward(),
                        onTapUp: (_) => _scaleController.reverse(),
                        onTapCancel: () => _scaleController.reverse(),
                        onTap: widget.onAdd,
                        customBorder: const CircleBorder(),
                        child: Tooltip(
                          message: l10n.menuItemAddToCart,
                          child: Container(
                            width: isCompact ? 40 : 44,
                            height: isCompact ? 40 : 44,
                            decoration: BoxDecoration(
                              color: isLight
                                  ? _MenuItemPalette.forestGreen
                                  : theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: isLight
                                  ? Colors.white
                                  : theme.colorScheme.onPrimary,
                              size: isCompact ? 22 : 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: size * 0.4),
    );
  }
}
