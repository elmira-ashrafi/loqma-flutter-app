import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../restaurant/models/restaurant_details_args.dart';
import '../../restaurant/screens/restaurant_details_screen.dart';
import '../models/special_offer_models.dart';
import '../services/offers_service.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../l10n/app_localizations.dart';

abstract final class _OffersPalette {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color cardBorder = Color(0xFFEEEEEE);
  static const Color dealRibbon = Color(0xFFE65100);
}

bool _offersCardRtlLocale(String languageCode) =>
    languageCode == 'fa' || languageCode == 'ps';

/// Lists discounted items flagged as special offers by restaurants (GET /api/v1/offers).
class OffersDealsScreen extends StatefulWidget {
  const OffersDealsScreen({super.key});

  @override
  State<OffersDealsScreen> createState() => _OffersDealsScreenState();
}

class _OffersDealsScreenState extends State<OffersDealsScreen> {
  final OffersService _service = OffersService();
  final ScrollController _scroll = ScrollController();

  List<SpecialOfferRow> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _page >= _lastPage) return;
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels > pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    try {
      final result = await _service.fetchOffers(page: 1, perPage: 20);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _page = result.currentPage;
        _lastPage = result.lastPage;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = userFriendlyErrorMessage(e);
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _lastPage) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final result = await _service.fetchOffers(page: next, perPage: 20);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...result.items];
        _page = result.currentPage;
        _lastPage = result.lastPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _openRestaurant(SpecialOfferRow row) {
    final r = row.restaurant;
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: r.id,
        args: RestaurantDetailsArgs(
          restaurantId: r.id,
          initialName: r.displayName,
          initialLogo: r.logo,
          initialRating: r.rating,
          deliveryFee: r.deliveryFee,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final layout = HomeLayout.of(context);
    final isLight = theme.brightness == Brightness.light;
    final pageBg = isLight ? _OffersPalette.pageBackground : theme.scaffoldBackgroundColor;
    final hPad = context.pageHorizontalPadding.clamp(12.0, 24.0);
    final languageCode = Get.find<LocaleController>().locale.languageCode;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        bottom: false,
        child: MaxWidthBody(
          child: RefreshIndicator(
            color: cs.primary,
            onRefresh: () => _load(reset: true),
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: _OffersScreenHeader(
                    title: l10n.offersDealsTitle,
                    subtitle: l10n.specialDeals,
                    dealCount: _loading || _error != null ? null : _items.length,
                    showSubtitle: _loading || _error != null,
                    languageCode: languageCode,
                    isLight: isLight,
                    horizontalPadding: hPad,
                  ),
                ),
                if (_loading)
                  SliverToBoxAdapter(
                    child: OfferDealListSkeleton(
                      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                    ),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _OffersErrorState(
                      title: l10n.offersLoadFailed,
                      message: _error!,
                      retryLabel: l10n.retry,
                      languageCode: languageCode,
                      onRetry: () => _load(reset: true),
                    ),
                  )
                else if (_items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _OffersEmptyState(
                      title: l10n.offersNoDealsNow,
                      hint: l10n.offersDealsEmptyHint,
                      languageCode: languageCode,
                      isLight: isLight,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(hPad, 4, hPad, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: SkeletonLoadMoreIndicator(),
                            );
                          }
                          final row = _items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OfferDealCard(
                              index: index,
                              row: row,
                              layout: layout,
                              languageCode: languageCode,
                              onTap: () => _openRestaurant(row),
                            ),
                          );
                        },
                        childCount: _items.length + (_loadingMore ? 1 : 0),
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
}

class _OffersScreenHeader extends StatelessWidget {
  const _OffersScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dealCount,
    required this.showSubtitle,
    required this.languageCode,
    required this.isLight,
    required this.horizontalPadding,
  });

  final String title;
  final String subtitle;
  final int? dealCount;
  final bool showSubtitle;
  final String languageCode;
  final bool isLight;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = isLight ? _OffersPalette.navyTitle : theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(horizontalPadding, 12, horizontalPadding, 8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.left,
              style: FontHelper.getTextStyle(
                text: title,
                languageCode: languageCode,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ).copyWith(letterSpacing: -0.4, height: 1.15),
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.left,
                style: FontHelper.getTextStyle(
                  text: subtitle,
                  languageCode: languageCode,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLight ? _OffersPalette.mutedGray : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (dealCount != null && dealCount! > 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _OffersPalette.forestGreen,
                      _OffersPalette.forestGreen.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _OffersPalette.forestGreen.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: FontHelper.getTextStyle(
                          text: subtitle,
                          languageCode: languageCode,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        formatAppInteger(context, dealCount!),
                        style: FontHelper.getTextStyle(
                          text: formatAppInteger(context, dealCount!),
                          languageCode: languageCode,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _OffersPalette.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferDealCard extends StatelessWidget {
  const _OfferDealCard({
    required this.index,
    required this.row,
    required this.layout,
    required this.languageCode,
    required this.onTap,
  });

  final int index;
  final SpecialOfferRow row;
  final HomeLayout layout;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;
    final item = row.foodItem;
    final rest = row.restaurant;
    final pct = item.discountPercent;
    final imageUrl = (item.imageUrl != null && item.imageUrl!.isNotEmpty) ? item.imageUrl : rest.logo;
    final titleColor = isLight ? _OffersPalette.navyTitle : cs.onSurface;
    final imageSize = layout.isCompact ? 88.0 : (layout.isTablet ? 108.0 : 96.0);
    final salePrice = AppCurrency.format(item.discountedPrice, decimalDigits: 0);
    final originalPrice = AppCurrency.format(item.price, decimalDigits: 0);
    final offerLabel = item.offerLabel?.trim();
    final showOfferLabel = offerLabel != null &&
        offerLabel.isNotEmpty &&
        offerLabel.toLowerCase() != item.displayName.toLowerCase() &&
        offerLabel.toLowerCase() != rest.displayName.toLowerCase();
    final rtlLayout = _offersCardRtlLocale(languageCode);
    final textDirection = rtlLayout ? TextDirection.rtl : TextDirection.ltr;
    final gap = SizedBox(width: layout.isCompact ? 10 : 12);
    final image = _OfferImage(
      imageUrl: imageUrl,
      size: imageSize,
      discountPercent: pct,
    );
    final textContent = Directionality(
      textDirection: textDirection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _OfferText(
            text: item.displayName,
            languageCode: languageCode,
            maxLines: 2,
            style: FontHelper.getTextStyle(
              text: item.displayName,
              languageCode: languageCode,
              fontSize: layout.isCompact ? 15 : 16,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ).copyWith(height: 1.25),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: rtlLayout ? WrapAlignment.end : WrapAlignment.start,
            children: [
              if (rest.rating > 0)
                _MetaChip(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.rating,
                  label: rest.rating.toStringAsFixed(1),
                  background: isLight
                      ? const Color(0xFFFFF8E1)
                      : cs.surfaceContainerHighest,
                  foreground: titleColor,
                  languageCode: languageCode,
                ),
              if (rest.deliveryFee == 0)
                _MetaChip(
                  icon: Icons.pedal_bike_rounded,
                  iconColor: _OffersPalette.forestGreen,
                  label: l10n.freeDeliveryLabel,
                  background: const Color(0xFFE8F5E9),
                  foreground: _OffersPalette.forestGreen,
                  languageCode: languageCode,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 14,
                color: isLight ? _OffersPalette.mutedGray : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _OfferText(
                  text: rest.displayName,
                  languageCode: languageCode,
                  maxLines: 1,
                  style: FontHelper.getTextStyle(
                    text: rest.displayName,
                    languageCode: languageCode,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLight ? _OffersPalette.mutedGray : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (showOfferLabel) ...[
            const SizedBox(height: 6),
            _OfferText(
              text: offerLabel,
              languageCode: languageCode,
              maxLines: 1,
              style: FontHelper.getTextStyle(
                text: offerLabel,
                languageCode: languageCode,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _OffersPalette.dealRibbon,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                salePrice,
                style: FontHelper.getTextStyle(
                  text: salePrice,
                  languageCode: languageCode,
                  fontSize: layout.isCompact ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                originalPrice,
                style: FontHelper.getTextStyle(
                  text: originalPrice,
                  languageCode: languageCode,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index.clamp(0, 8) * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        final t = v.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
        );
      },
      child: Material(
        color: cs.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: isLight ? Border.all(color: _OffersPalette.cardBorder) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(layout.isCompact ? 10 : 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: rtlLayout
                      ? [image, gap, Expanded(child: textContent)]
                      : [Expanded(child: textContent), gap, image],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Locale-aware text: left in English, right in Dari/Pashto.
class _OfferText extends StatelessWidget {
  const _OfferText({
    required this.text,
    required this.languageCode,
    required this.style,
    this.maxLines = 1,
  });

  final String text;
  final String languageCode;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final rtl = _offersCardRtlLocale(languageCode);
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: rtl ? TextAlign.right : TextAlign.left,
      style: style,
    );
  }
}

class _OfferImage extends StatelessWidget {
  const _OfferImage({
    required this.imageUrl,
    required this.size,
    this.discountPercent,
  });

  final String? imageUrl;
  final double size;
  final int? discountPercent;

  @override
  Widget build(BuildContext context) {
    final radius = 14.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(size, radius),
                    errorWidget: (_, __, ___) => _placeholder(size, radius),
                  )
                : _placeholder(size, radius),
          ),
          if (discountPercent != null && discountPercent! > 0)
            PositionedDirectional(
              top: -4,
              start: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _OffersPalette.dealRibbon,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _OffersPalette.dealRibbon.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '-$discountPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: size * 0.38),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.languageCode,
    this.icon,
    this.iconColor,
  });

  final String label;
  final Color background;
  final Color foreground;
  final String languageCode;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: iconColor ?? foreground),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontHelper.getTextStyle(
                text: label,
                languageCode: languageCode,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OffersEmptyState extends StatelessWidget {
  const _OffersEmptyState({
    required this.title,
    required this.hint,
    required this.languageCode,
    required this.isLight,
  });

  final String title;
  final String hint;
  final String languageCode;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined, size: 42, color: cs.primary.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: title,
              languageCode: languageCode,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isLight ? _OffersPalette.navyTitle : cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: hint,
              languageCode: languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OffersErrorState extends StatelessWidget {
  const _OffersErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.languageCode,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final String languageCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, size: 40, color: cs.error),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: title,
              languageCode: languageCode,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: message,
              languageCode: languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              retryLabel,
              style: FontHelper.getTextStyle(
                text: retryLabel,
                languageCode: languageCode,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
