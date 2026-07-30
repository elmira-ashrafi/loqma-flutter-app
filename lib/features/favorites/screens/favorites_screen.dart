import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../restaurant/models/restaurant_details_args.dart';
import '../../restaurant/screens/restaurant_details_screen.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../controllers/favorites_controller.dart';

abstract final class _Palette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color cardBorder = Color(0xFFEEEEEE);
}

/// Saved restaurants — listens to [FavoritesController] for real-time updates.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesController _favorites;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController(), permanent: true);
    }
    _favorites = Get.find<FavoritesController>();
    if (!_favorites.hasLoaded.value &&
        Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn) {
      _favorites.load();
    }
  }

  String get _languageCode => Get.find<LocaleController>().locale.languageCode;

  Future<void> _removeFavorite(RestaurantModel restaurant) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final stillFavorite = await _favorites.removeFavorite(restaurant);
      if (!mounted) return;
      if (stillFavorite) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.retry)),
        );
        return;
      }
      final theme = Theme.of(context);
      final isLight = theme.brightness == Brightness.light;
      final snackBg =
          isLight ? _Palette.forestGreen : theme.colorScheme.primary;
      final snackFg =
          isLight ? Colors.white : theme.colorScheme.onPrimary;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.favoritesRemovedMessage,
            style: FontHelper.getTextStyle(
              text: l10n.favoritesRemovedMessage,
              languageCode: _languageCode,
              fontWeight: FontWeight.w600,
              color: snackFg,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: snackBg,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e))),
      );
    }
  }

  void _openRestaurant(RestaurantModel restaurant) {
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: restaurant.id,
        args: RestaurantDetailsArgs(
          restaurantId: restaurant.id,
          initialName: restaurant.displayName,
          initialImage: restaurant.image,
          initialLogo: restaurant.logo,
          initialCover: restaurant.cover,
          initialRating: restaurant.rating,
          initialTotalReviews: restaurant.totalReviews,
          initialLocation: restaurant.displayLocation,
          initialCategory: restaurant.displayCategoryNames,
          isOpen: restaurant.isOpen,
          deliveryFee: restaurant.deliveryFee,
          freeDeliveryAbove: restaurant.freeDeliveryAbove,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final pageBg = isLight ? Colors.white : theme.scaffoldBackgroundColor;
    final auth =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final loggedIn = auth?.isLoggedIn ?? false;
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 400;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor:
            isLight ? _Palette.navyTitle : theme.colorScheme.onSurface,
        title: Text(
          l10n.favorites,
          style: FontHelper.getTextStyle(
            text: l10n.favorites,
            languageCode: _languageCode,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isLight ? _Palette.navyTitle : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: MaxWidthBody(
        child: !loggedIn
            ? _buildSignInPrompt(context, l10n, isCompact)
            : Obx(() {
                final loading =
                    _favorites.isLoading.value && _favorites.items.isEmpty;
                final error = _favorites.error.value;
                final items = _favorites.items.toList();
                final removing = _favorites.removingIds.toSet();

                if (loading) {
                  return const FavoritesListSkeleton();
                }

                return RefreshIndicator(
                  color: isLight
                      ? AppColors.primary
                      : theme.colorScheme.primary,
                  onRefresh: _favorites.refreshFavorites,
                  child: error != null && items.isEmpty
                      ? _buildScrollableState(
                          child: _buildError(context, l10n, error),
                        )
                      : items.isEmpty
                          ? _buildScrollableState(
                              child: _buildEmpty(context, l10n, isCompact),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                context.pageHorizontalPadding,
                                8,
                                context.pageHorizontalPadding,
                                24,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final restaurant = items[i];
                                return _FavoriteRestaurantCard(
                                  restaurant: restaurant,
                                  isCompact: isCompact,
                                  isRemoving: removing.contains(restaurant.id),
                                  languageCode: _languageCode,
                                  onTap: () => _openRestaurant(restaurant),
                                  onRemove: () =>
                                      _removeFavorite(restaurant),
                                );
                              },
                            ),
                );
              }),
      ),
    );
  }

  /// Empty/error content inside a scroll view so pull-to-refresh can engage.
  Widget _buildScrollableState({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSignInPrompt(BuildContext context, AppLocalizations l10n, bool isCompact) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final muted = isLight ? _Palette.mutedGray : theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, size: 44, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.signInToContinue,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: l10n.signInToContinue,
                languageCode: _languageCode,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.favoritesHint,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: l10n.favoritesHint,
                languageCode: _languageCode,
                fontSize: 14,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: message,
                languageCode: _languageCode,
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _favorites.load(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                l10n.retry,
                style: FontHelper.getTextStyle(
                  text: l10n.retry,
                  languageCode: _languageCode,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n, bool isCompact) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final accent = isLight ? _Palette.forestGreen : theme.colorScheme.primary;
    final muted = isLight ? _Palette.mutedGray : theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isLight ? 0.08 : 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: accent.withValues(alpha: isLight ? 0.65 : 0.9),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noFavoritesYet,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: l10n.noFavoritesYet,
                languageCode: _languageCode,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.favoritesHint,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: l10n.favoritesHint,
                languageCode: _languageCode,
                fontSize: 14,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteRestaurantCard extends StatelessWidget {
  const _FavoriteRestaurantCard({
    required this.restaurant,
    required this.isCompact,
    required this.isRemoving,
    required this.languageCode,
    required this.onTap,
    required this.onRemove,
  });

  final RestaurantModel restaurant;
  final bool isCompact;
  final bool isRemoving;
  final String languageCode;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight ? _Palette.navyTitle : theme.colorScheme.onSurface;
    final muted = isLight ? _Palette.mutedGray : theme.colorScheme.onSurfaceVariant;
    final accent = isLight ? _Palette.forestGreen : theme.colorScheme.primary;
    final cardColor = isLight ? Colors.white : theme.colorScheme.surfaceContainerHigh;
    final borderColor = isLight ? _Palette.cardBorder : theme.colorScheme.outline;
    final cover = restaurant.cover ?? restaurant.image ?? restaurant.logo;
    final subtitle = restaurant.displaySubtitle ?? restaurant.displayLocation;
    final deliveryLine = restaurant.deliveryFee <= 0
        ? l10n.freeDeliveryLabel
        : l10n.deliveryFeeLabel(AppCurrency.format(restaurant.deliveryFee, decimalDigits: 0));
    final imageHeight = isCompact ? 140.0 : 160.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 14 : 16),
      child: Material(
        color: cardColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cover != null && cover.isNotEmpty)
                        AppNetworkImage(
                          imageUrl: cover,
                          width: MediaQuery.sizeOf(context).width,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imagePlaceholder(context, imageHeight),
                          errorWidget: (_, __, ___) => _imagePlaceholder(context, imageHeight),
                        )
                      else
                        _imagePlaceholder(context, imageHeight),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _FavoriteRemoveButton(
                          isRemoving: isRemoving,
                          tooltip: l10n.favoritesRemoveTooltip,
                          onPressed: onRemove,
                        ),
                      ),
                      if (restaurant.logo != null && restaurant.logo!.isNotEmpty)
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AppNetworkImage(
                              imageUrl: restaurant.logo!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _logoPlaceholder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14, 12, 14, isCompact ? 12 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.displayName,
                        style: FontHelper.getTextStyle(
                          text: restaurant.displayName,
                          languageCode: languageCode,
                          fontSize: isCompact ? 16 : 17,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle.trim(),
                          style: FontHelper.getTextStyle(
                            text: subtitle.trim(),
                            languageCode: languageCode,
                            fontSize: 12,
                            color: muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (restaurant.rating > 0) ...[
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.rating),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: FontHelper.getTextStyle(
                                text: restaurant.rating.toStringAsFixed(1),
                                languageCode: languageCode,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            if (restaurant.totalReviews != null && restaurant.totalReviews! > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${restaurant.totalReviews})',
                                style: FontHelper.getTextStyle(
                                  text: '(${restaurant.totalReviews})',
                                  languageCode: languageCode,
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                          ],
                          Icon(Icons.pedal_bike_rounded, size: 16, color: accent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              deliveryLine,
                              style: FontHelper.getTextStyle(
                                text: deliveryLine,
                                languageCode: languageCode,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context, double height) {
    final theme = Theme.of(context);
    final accent = theme.brightness == Brightness.light
        ? _Palette.forestGreen
        : theme.colorScheme.primary;
    return Container(
      height: height,
      color: accent.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        size: 48,
        color: accent.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      color: Colors.white.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant_rounded, size: 22, color: _Palette.forestGreen),
    );
  }
}

class _FavoriteRemoveButton extends StatelessWidget {
  const _FavoriteRemoveButton({
    required this.isRemoving,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isRemoving;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isRemoving ? null : onPressed,
        customBorder: const CircleBorder(),
        splashColor: Colors.redAccent.withValues(alpha: 0.15),
        highlightColor: Colors.redAccent.withValues(alpha: 0.08),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: isRemoving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                    )
                  : const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
