import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_constants.dart';
import '../layout/responsive_context.dart';

/// Shared shimmer palette tuned for light/dark surfaces.
class SkeletonColors {
  SkeletonColors._(this.base, this.highlight);

  final Color base;
  final Color highlight;

  factory SkeletonColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SkeletonColors._(
      isDark ? const Color(0xFF2A2F33) : const Color(0xFFE8ECF0),
      isDark ? const Color(0xFF3A4148) : const Color(0xFFF5F7FA),
    );
  }
}

/// Base shimmer block — use for any placeholder shape.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final colors = SkeletonColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      period: Duration(milliseconds: AppConstants.shimmerDurationMs),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.base,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      ),
    );
  }
}

/// Wraps [child] placeholders in a single shimmer pass (avoids nested shimmer flicker).
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = SkeletonColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      period: Duration(milliseconds: AppConstants.shimmerDurationMs),
      child: child,
    );
  }
}

class _SkeletonBone extends StatelessWidget {
  const _SkeletonBone({
    this.width,
    required this.height,
    this.borderRadius = 10,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final base = SkeletonColors.of(context).base;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
      ),
    );
  }
}

/// Horizontal restaurant row — home, search, list screens.
class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({
    super.key,
    this.count = 5,
    this.padding,
    this.wrapShimmer = true,
  });

  final int count;
  final EdgeInsetsGeometry? padding;
  final bool wrapShimmer;

  @override
  Widget build(BuildContext context) {
    final thumb = context.layoutScale(80);
    final gap = context.layoutScale(12);
    final pad = padding ?? EdgeInsets.zero;

    final list = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: pad,
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: context.layoutScale(12)),
        child: Container(
          padding: EdgeInsets.all(context.layoutScale(12)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBone(width: thumb, height: thumb, borderRadius: 14),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBone(height: context.layoutScale(16), width: double.infinity),
                    SizedBox(height: context.layoutScale(8)),
                    _SkeletonBone(height: context.layoutScale(12), width: context.layoutScale(140)),
                    SizedBox(height: context.layoutScale(8)),
                    _SkeletonBone(height: context.layoutScale(12), width: context.layoutScale(90)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!wrapShimmer) return list;
    return SkeletonGroup(child: list);
  }
}

/// Favorites tab — vertical cover cards.
class FavoritesListSkeleton extends StatelessWidget {
  const FavoritesListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isCompact = MediaQuery.sizeOf(context).width < 400;
    final imageHeight = isCompact ? 140.0 : 160.0;
    final hPad = context.pageHorizontalPadding;
    final borderColor =
        isLight ? const Color(0xFFEEEEEE) : theme.colorScheme.outline;

    return SkeletonGroup(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: isCompact ? 14 : 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SkeletonBone(height: imageHeight, width: double.infinity, borderRadius: 0),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBone(height: 18, width: double.infinity),
                      const SizedBox(height: 8),
                      _SkeletonBone(height: 12, width: 160),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SkeletonBone(height: 14, width: 56),
                          const SizedBox(width: 16),
                          _SkeletonBone(height: 14, width: 100),
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
}

/// Restaurant details — hero, info, menu search, chips, items.
class RestaurantDetailsSkeleton extends StatelessWidget {
  const RestaurantDetailsSkeleton({
    super.key,
    required this.heroHeight,
    required this.horizontalPadding,
  });

  final double heroHeight;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 400;

    return SkeletonGroup(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _SkeletonBone(height: heroHeight, width: double.infinity, borderRadius: 0),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBone(width: 56, height: 56, borderRadius: 10),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBone(height: 20, width: double.infinity),
                        const SizedBox(height: 8),
                        _SkeletonBone(height: 14, width: 200),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SkeletonBone(width: 64, height: 28, borderRadius: 20),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  _SkeletonBone(height: 14, width: 48),
                  const SizedBox(width: 20),
                  _SkeletonBone(height: 14, width: 90),
                  const SizedBox(width: 20),
                  Expanded(child: _SkeletonBone(height: 14, width: double.infinity)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 22, horizontalPadding, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBone(height: 14, width: 48),
                  const SizedBox(height: 14),
                  _SkeletonBone(height: 48, width: double.infinity, borderRadius: 999),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, __) => _SkeletonBone(width: 72, height: 36, borderRadius: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MenuItemListSkeleton(
              count: isCompact ? 4 : 5,
              horizontalPadding: horizontalPadding,
              wrapShimmer: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu item rows on restaurant details / search food tab.
class MenuItemListSkeleton extends StatelessWidget {
  const MenuItemListSkeleton({
    super.key,
    this.count = 4,
    this.horizontalPadding = 16,
    this.wrapShimmer = true,
  });

  final int count;
  final double horizontalPadding;
  final bool wrapShimmer;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 400;
    final imageSize = isCompact ? 72.0 : 84.0;

    final list = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: List.generate(count, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: isCompact ? 10 : 12),
            child: Container(
              padding: EdgeInsets.all(isCompact ? 10 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  _SkeletonBone(width: imageSize, height: imageSize, borderRadius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBone(height: 16, width: double.infinity),
                        const SizedBox(height: 6),
                        _SkeletonBone(height: 12, width: 180),
                        const SizedBox(height: 8),
                        _SkeletonBone(height: 14, width: 64),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SkeletonBone(width: 40, height: 40, shape: BoxShape.circle),
                ],
              ),
            ),
          );
        }),
      ),
    );

    if (!wrapShimmer) return list;
    return SkeletonGroup(child: list);
  }
}

/// Orders tab cards.
class OrderCardListSkeleton extends StatelessWidget {
  const OrderCardListSkeleton({
    super.key,
    this.count = 4,
    this.padding,
  });

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final thumb = context.layoutScale(56);
    final pad = padding ?? EdgeInsets.zero;

    return SkeletonGroup(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBone(width: thumb, height: thumb, borderRadius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBone(height: 16, width: double.infinity),
                          const SizedBox(height: 6),
                          _SkeletonBone(height: 12, width: 120),
                        ],
                      ),
                    ),
                    _SkeletonBone(width: 72, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 14),
                _SkeletonBone(height: 10, width: double.infinity),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SkeletonBone(height: 14, width: 80),
                    _SkeletonBone(height: 18, width: 64),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Offers / deals list.
class OfferDealListSkeleton extends StatelessWidget {
  const OfferDealListSkeleton({super.key, this.count = 5, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final thumb = context.layoutScale(80);
    final pad = padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 24);

    // Nested under SliverToBoxAdapter — must shrink-wrap (no unbounded ListView height).
    return SkeletonGroup(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBone(width: thumb, height: thumb, borderRadius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBone(height: 12, width: 100),
                      const SizedBox(height: 6),
                      _SkeletonBone(height: 16, width: double.infinity),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _SkeletonBone(height: 14, width: 56),
                          const SizedBox(width: 8),
                          _SkeletonBone(height: 14, width: 48),
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
}

/// Notification list tiles.
class NotificationListSkeleton extends StatelessWidget {
  const NotificationListSkeleton({super.key, this.count = 6, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 24);

    return SkeletonGroup(
      child: ListView.builder(
        padding: pad,
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBone(width: 44, height: 44, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBone(height: 15, width: double.infinity),
                      const SizedBox(height: 6),
                      _SkeletonBone(height: 12, width: double.infinity),
                      const SizedBox(height: 6),
                      _SkeletonBone(height: 10, width: 72),
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
}

/// Saved addresses cards.
class AddressListSkeleton extends StatelessWidget {
  const AddressListSkeleton({super.key, this.count = 3, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 24);

    return SkeletonGroup(
      child: ListView.builder(
        padding: pad,
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBone(width: 40, height: 40, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBone(height: 16, width: 100),
                      const SizedBox(height: 8),
                      _SkeletonBone(height: 12, width: double.infinity),
                      const SizedBox(height: 6),
                      _SkeletonBone(height: 12, width: 200),
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
}

/// Search results — restaurants + foods sections.
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = context.pageHorizontalPadding;
    final thumb = context.layoutScale(80);

    return SkeletonGroup(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBone(height: 14, width: 110),
            const SizedBox(height: 12),
            ...List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _SkeletonBone(width: thumb, height: thumb, borderRadius: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBone(height: 16, width: double.infinity),
                          const SizedBox(height: 8),
                          _SkeletonBone(height: 12, width: 140),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            _SkeletonBone(height: 14, width: 80),
            const SizedBox(height: 12),
            const MenuItemListSkeleton(count: 3, horizontalPadding: 0, wrapShimmer: false),
          ],
        ),
      ),
    );
  }
}

/// Small inline loader for pagination footers.
class SkeletonLoadMoreIndicator extends StatelessWidget {
  const SkeletonLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: LoadingShimmer(
          width: 120,
          height: 8,
          borderRadius: 4,
        ),
      ),
    );
  }
}

/// Full-screen centered skeleton with optional message (bootstrap / rare cases).
class SkeletonPageLoader extends StatelessWidget {
  const SkeletonPageLoader({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
