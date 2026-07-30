import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../restaurants/models/restaurant_detail_model.dart';
import '../models/menu_item_display.dart';

abstract final class _Palette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
}

/// Full menu item view with variants, add-ons, quantity, and add-to-cart.
class MenuItemDetailScreen extends StatefulWidget {
  const MenuItemDetailScreen({
    super.key,
    required this.restaurantId,
    required this.item,
  });

  final int restaurantId;
  final MenuItemDisplay item;

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  late int _quantity;
  int? _selectedVariantId;
  final Set<int> _selectedAddonIds = {};

  MenuItemModel get _menuItem => widget.item.model;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    if (_menuItem.hasSelectableSizes) {
      VariantModel? defaultVariant;
      for (final variant in _menuItem.variants) {
        if (variant.isDefault) {
          defaultVariant = variant;
          break;
        }
      }
      _selectedVariantId = defaultVariant?.id ?? _menuItem.variants.first.id;
    }
  }

  String get _languageCode => Get.find<LocaleController>().locale.languageCode;

  double get _unitPrice {
    var price = _menuItem.price;
    if (_selectedVariantId != null) {
      for (final v in _menuItem.variants) {
        if (v.id == _selectedVariantId) {
          price += v.price;
          break;
        }
      }
    }
    for (final a in _menuItem.addons) {
      if (_selectedAddonIds.contains(a.id)) {
        price += a.price;
      }
    }
    return price;
  }

  double get _lineTotal => _unitPrice * _quantity;

  void _addToCart() {
    final cart = Get.find<CartController>();
    final result = cart.addItemWithResult(
      restaurantId: widget.restaurantId,
      item: CartItemRequest(
        foodId: widget.item.id,
        quantity: _quantity,
        variantId: _selectedVariantId,
        addonIds: _selectedAddonIds.toList(),
        imageUrl: widget.item.image,
      ),
    );
    if (!mounted) return;
    if (result == CartAddResult.blockedDifferentRestaurant) {
      final l10n = AppLocalizations.of(context)!;
      final name = cart.displayRestaurantName ??
          cart.restaurantName ??
          l10n.restaurantDefaultName;
      showDifferentRestaurantCartNotice(context, restaurantName: name);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight ? _Palette.navyTitle : theme.colorScheme.onSurface;
    final accentColor = isLight ? _Palette.forestGreen : theme.colorScheme.primary;
    final mutedColor = isLight ? _Palette.mutedGray : theme.colorScheme.onSurfaceVariant;
    final name = widget.item.nameFor(_languageCode);
    final description = widget.item.descriptionFor(_languageCode);
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 400;
    final imageHeight = (media.width * 0.55).clamp(200.0, 320.0);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : theme.scaffoldBackgroundColor,
      body: MaxWidthBody(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: imageHeight,
                    pinned: true,
                    stretch: true,
                    backgroundColor: isLight ? Colors.white : theme.colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    leading: IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: isLight ? _Palette.navyTitle : theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeroImage(imageHeight),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 16 : 20,
                      16,
                      isCompact ? 16 : 20,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          name,
                          style: FontHelper.getTextStyle(
                            text: name,
                            languageCode: _languageCode,
                            fontSize: isCompact ? 22 : 24,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppCurrency.format(_unitPrice, decimalDigits: 0),
                          style: FontHelper.getTextStyle(
                            text: AppCurrency.format(_unitPrice, decimalDigits: 0),
                            languageCode: _languageCode,
                            fontSize: isCompact ? 18 : 20,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                        if (description != null && description.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            description.trim(),
                            style: FontHelper.getTextStyle(
                              text: description.trim(),
                              languageCode: _languageCode,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: mutedColor,
                            ).copyWith(height: 1.45),
                          ),
                        ],
                        if (_menuItem.hasSelectableSizes) ...[
                          const SizedBox(height: 24),
                          _sectionTitle(l10n.sizeLabel, titleColor, isCompact),
                          const SizedBox(height: 10),
                          ..._menuItem.variants.map((variant) {
                            final label = variant.localized.displayNameFor(_languageCode);
                            final selected = _selectedVariantId == variant.id;
                            final sizePrice = _menuItem.price + variant.price;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: selected
                                    ? accentColor.withValues(alpha: isLight ? 0.08 : 0.18)
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => setState(() => _selectedVariantId = variant.id),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          selected
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: selected ? accentColor : mutedColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: FontHelper.getTextStyle(
                                              text: label,
                                              languageCode: _languageCode,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: titleColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          AppCurrency.format(sizePrice, decimalDigits: 0),
                                          style: FontHelper.getTextStyle(
                                            text: AppCurrency.format(sizePrice, decimalDigits: 0),
                                            languageCode: _languageCode,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        if (_menuItem.addons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _sectionTitle(l10n.menuItemAddonsLabel, titleColor, isCompact),
                          const SizedBox(height: 10),
                          ..._menuItem.addons.map((addon) {
                            final label = addon.localized.displayNameFor(_languageCode);
                            final checked = _selectedAddonIds.contains(addon.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: checked
                                    ? accentColor.withValues(alpha: isLight ? 0.08 : 0.18)
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      if (checked) {
                                        _selectedAddonIds.remove(addon.id);
                                      } else {
                                        _selectedAddonIds.add(addon.id);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          checked
                                              ? Icons.check_box_rounded
                                              : Icons.check_box_outline_blank_rounded,
                                          color: checked ? accentColor : mutedColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: FontHelper.getTextStyle(
                                              text: label,
                                              languageCode: _languageCode,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: titleColor,
                                            ),
                                          ),
                                        ),
                                        if (addon.price > 0)
                                          Text(
                                            '+${AppCurrency.format(addon.price, decimalDigits: 0)}',
                                            style: FontHelper.getTextStyle(
                                              text: AppCurrency.format(addon.price, decimalDigits: 0),
                                              languageCode: _languageCode,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: accentColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 20),
                        _sectionTitle(l10n.menuItemQuantityLabel, titleColor, isCompact),
                        const SizedBox(height: 12),
                        _buildQuantityStepper(theme, isCompact, accentColor),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 16 : 20,
                12,
                isCompact ? 16 : 20,
                12 + bottomInset,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.total,
                          style: FontHelper.getTextStyle(
                            text: l10n.total,
                            languageCode: _languageCode,
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          AppCurrency.format(_lineTotal, decimalDigits: 0),
                          style: FontHelper.getTextStyle(
                            text: AppCurrency.format(_lineTotal, decimalDigits: 0),
                            languageCode: _languageCode,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: AppButton(
                      label: l10n.menuItemAddToCart,
                      onPressed: _addToCart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(double height) {
    final image = widget.item.image;
    if (image != null && image.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        width: MediaQuery.sizeOf(context).width,
        height: height,
        placeholder: (_, __) => _imagePlaceholder(height),
        errorWidget: (_, __, ___) => _imagePlaceholder(height),
      );
    }
    return _imagePlaceholder(height);
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Icon(
        Icons.restaurant_rounded,
        size: 72,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color, bool isCompact) {
    return Text(
      text,
      style: FontHelper.getTextStyle(
        text: text,
        languageCode: _languageCode,
        fontSize: isCompact ? 15 : 16,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }

  Widget _buildQuantityStepper(ThemeData theme, bool isCompact, Color accentColor) {
    return Row(
      children: [
        _qtyButton(
          icon: Icons.remove_rounded,
          enabled: _quantity > 1,
          accentColor: accentColor,
          onTap: () => setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$_quantity',
            style: FontHelper.getTextStyle(
              text: '$_quantity',
              languageCode: _languageCode,
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        _qtyButton(
          icon: Icons.add_rounded,
          enabled: _quantity < 99,
          accentColor: accentColor,
          onTap: () => setState(() => _quantity = (_quantity + 1).clamp(1, 99)),
        ),
      ],
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Material(
      color: enabled
          ? accentColor
          : accentColor.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: isLight ? Colors.white : theme.colorScheme.onPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
