import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../controllers/restaurant_list_controller.dart';
import '../models/restaurant_model.dart';
import '../../restaurant/screens/restaurant_details_screen.dart';
import '../../restaurant/models/restaurant_details_args.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';

/// Aligns with restaurant details reference (page gray, navy titles, forest accents).
abstract final class _RestaurantListPalette {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color chipBorder = Color(0xFFE0E0E0);
  static const Color cardBorder = Color(0xFFEEEEEE);
}

/// All restaurants screen: beautiful, animated list with sort and pagination.
/// Pass [categoryId] and [categoryName] to filter by category (e.g. from home tab category chip).
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.searchQuery,
    this.freeDeliveryOnly = false,
  });

  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? searchQuery;
  final bool freeDeliveryOnly;

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> with TickerProviderStateMixin {
  static const _sortOptions = [
    ('rating', 'Rating', Icons.star_rounded),
    ('distance', 'Distance', Icons.near_me_rounded),
    ('delivery_time', 'Delivery time', Icons.schedule_rounded),
  ];

  late final RestaurantListController _ctrl;

  @override
  void initState() {
    super.initState();
    // Get.put in build() reused a stale global controller (wrong filters, skip onInit).
    if (Get.isRegistered<RestaurantListController>()) {
      Get.delete<RestaurantListController>(force: true);
    }
    final cityId = Get.isRegistered<DeliveryLocationController>()
        ? Get.find<DeliveryLocationController>().deliveryCityId
        : null;
    _ctrl = Get.put(
      RestaurantListController(
        categoryId: widget.categoryId,
        categoryName: widget.categoryName,
        categorySlug: widget.categorySlug,
        searchQuery: widget.searchQuery,
        freeDeliveryOnly: widget.freeDeliveryOnly,
        cityId: cityId,
      ),
      permanent: false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<RestaurantListController>()) {
      Get.delete<RestaurantListController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final pageBg = isLight ? _RestaurantListPalette.pageBackground : theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        top: true,
        bottom: true,
        child: MaxWidthBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildAppBar(context),
            Obx(() => _buildSortChips(context, _ctrl)),
            Expanded(
              child: Obx(() {
                final loading = _ctrl.isLoading.value && _ctrl.restaurants.isEmpty;
                final empty = _ctrl.restaurants.isEmpty && !loading;
                if (loading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
                    child: const RestaurantCardShimmer(count: 6),
                  );
                }
                if (empty) {
                  return _buildEmptyState(context, _ctrl);
                }
                final list = _ctrl.restaurants.toList();
                final hasMore = _ctrl.hasMore.value;
                return RefreshIndicator(
                  onRefresh: _ctrl.loadRestaurants,
                  color: _RestaurantListPalette.forestGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      8,
                      context.pageHorizontalPadding,
                      24 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: list.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= list.length) {
                        _ctrl.loadMore();
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final restaurant = list[i];
                      return _AnimatedRestaurantCard(
                        index: i,
                        restaurant: restaurant,
                        onTap: () => _openDetail(context, restaurant),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final ctrl = _ctrl;
    final l10n = AppLocalizations.of(context)!;
    final title = ctrl.categoryName != null && ctrl.categoryName!.isNotEmpty
        ? ctrl.categoryName!
        : l10n.allRestaurants;
    final subtitle =
        ctrl.categoryId != null ? l10n.restaurantsInThisCategory : l10n.discoverOrderBestSubtitle;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final narrow = MediaQuery.sizeOf(context).width < 360;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 6 : 8, 4, narrow ? 8 : 12, 16),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.95),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.chevron_left_rounded, size: 26, color: _RestaurantListPalette.navyTitle),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isLight ? _RestaurantListPalette.navyTitle : null,
                        ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChips(BuildContext context, RestaurantListController ctrl) {
    // Must read .value here inside Obx parent so selection updates immediately on tap.
    final selected = ctrl.sortBy.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _sortOptions.map((opt) {
            final (value, label, icon) = opt;
            final isSelected = selected == value;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _SortChip(
                label: label,
                icon: icon,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (ctrl.sortBy.value == value) return;
                  ctrl.setSort(value);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, RestaurantListController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.restaurant_rounded, size: 64, color: AppColors.primary.withOpacity(0.6)),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'No restaurants found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.pullToRefreshOrRetry,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: ctrl.loadRestaurants,
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, RestaurantModel r) {
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: r.id,
        args: RestaurantDetailsArgs(
          restaurantId: r.id,
          initialName: r.displayName,
          initialImage: r.image,
          initialLogo: r.logo,
          initialCover: r.cover,
          initialRating: r.rating,
          initialTotalReviews: r.totalReviews,
          initialDeliveryTime: r.deliveryTime,
          initialLocation: r.displayLocation,
          initialCategory: r.displayCategoryNames,
          isOpen: r.isOpen,
          deliveryFee: r.deliveryFee,
          minOrder: r.minimumOrder,
          freeDeliveryAbove: r.freeDeliveryAbove,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }
}

class _SortChip extends StatefulWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SortChip> createState() => _SortChipState();
}

class _SortChipState extends State<_SortChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _RestaurantListPalette.forestGreen
                : (Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isSelected ? _RestaurantListPalette.forestGreen : _RestaurantListPalette.chipBorder,
              width: 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _RestaurantListPalette.forestGreen.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.light
                        ? _RestaurantListPalette.navyTitle
                        : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.light
                              ? _RestaurantListPalette.navyTitle
                              : Theme.of(context).colorScheme.onSurface),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedRestaurantCard extends StatefulWidget {
  const _AnimatedRestaurantCard({
    required this.index,
    required this.restaurant,
    required this.onTap,
  });

  final int index;
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  @override
  State<_AnimatedRestaurantCard> createState() => _AnimatedRestaurantCardState();
}

class _AnimatedRestaurantCardState extends State<_AnimatedRestaurantCard> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceOpacity;
  late Animation<Offset> _entranceOffset;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0, 0.6, curve: Curves.easeOutCubic)),
    );
    _entranceOffset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 1, curve: Curves.easeOutCubic)),
    );
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: 40 * widget.index.clamp(0, 20)), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _scaleController]),
      builder: (context, child) {
        return Opacity(
          opacity: _entranceOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _entranceOffset.value.dy * 120),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.light ? _RestaurantListPalette.cardBorder : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: theme.brightness == Brightness.light ? Colors.white : theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: (r.image != null && r.image!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: r.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _cardImagePlaceholder(context),
                                errorWidget: (_, __, ___) => _cardImagePlaceholder(context),
                              )
                            : _cardImagePlaceholder(context),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                            ),
                          ),
                        ),
                      ),
                      if (!r.isOpen)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.restaurantStatusClosed,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      if (r.rating > 0)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.rating.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  r.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: theme.brightness == Brightness.light ? _RestaurantListPalette.navyTitle : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (r.displayDescription != null && r.displayDescription!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            r.displayDescription!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF9E9E9E),
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (r.deliveryTime != null || (r.avgPreparationTime != null && r.avgPreparationTime! > 0)) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: _RestaurantListPalette.forestGreen),
                              const SizedBox(width: 6),
                              Text(
                                restaurantPrepTimeCaption(
                                  context,
                                  avgPrepMinutes: r.avgPreparationTime,
                                  rawDeliveryTime: r.deliveryTime,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _RestaurantListPalette.forestGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
