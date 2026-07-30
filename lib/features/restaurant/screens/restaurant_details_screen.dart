import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../restaurants/controllers/restaurant_detail_controller.dart';
import '../../restaurants/models/restaurant_detail_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/screens/cart_screen.dart';
import 'menu_item_detail_screen.dart';
import '../models/restaurant_details_args.dart';
import '../models/menu_item_display.dart';
import '../models/similar_restaurant_model.dart';
import '../widgets/menu_category_tabs.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/review_card.dart';
import '../widgets/similar_restaurant_card.dart';
import '../../../l10n/app_localizations.dart';

/// Reference UI: forest green, navy, menu search & chips (see product mock).
abstract final class _DetailsPalette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color closedBg = Color(0xFFFCE4EC);
  static const Color closedFg = Color(0xFFE91E63);
  /// Main canvas — white like target mock (hero still full-bleed).
  static const Color pageBackground = Color(0xFFFFFFFF);
}

/// Restaurant details: edge-to-edge hero, menu search & chips, reviews, similar list.
/// Pass [restaurantId] or [args] with optional initial data for Hero/header.
class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
    this.args,
  });

  final int restaurantId;
  final RestaurantDetailsArgs? args;

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _menuSearchController = TextEditingController();
  final List<GlobalKey> _sectionKeys = [];
  int _selectedCategoryIndex = 0;
  Timer? _searchDebounce;
  String _menuSearchQuery = '';
  late final RestaurantDetailController _ctrl;

  static double _heroHeightForWidth(double w) =>
      (w * 0.52).clamp(w < 360 ? 200.0 : 220.0, 320.0);

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(
      RestaurantDetailController(restaurantId: widget.restaurantId),
      tag: '${widget.restaurantId}',
    );
    _menuSearchController.addListener(_onMenuSearchChanged);
  }

  void _onMenuSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final q = _menuSearchController.text;
      if (q == _menuSearchQuery) return;
      setState(() => _menuSearchQuery = q);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _menuSearchController.removeListener(_onMenuSearchChanged);
    _menuSearchController.dispose();
    _scrollController.dispose();
    Get.delete<RestaurantDetailController>(tag: '${widget.restaurantId}');
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RestaurantDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantId != widget.restaurantId) {
      _selectedCategoryIndex = 0;
    }
  }

  void _ensureSectionKeys(int categoryCount) {
    if (_sectionKeys.length == categoryCount) return;
    _sectionKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(categoryCount, (_) => GlobalKey()));
  }

  List<MenuCategoryTabItem> _getCategories(RestaurantDetailModel? detail) {
    if (detail == null || detail.menuCategories.isEmpty) return [];
    return detail.menuCategories
        .map((c) => MenuCategoryTabItem(id: c.id, name: c.displayName, itemCount: c.items.length))
        .where((c) => c.name.trim().isNotEmpty)
        .toList();
  }

  List<MenuItemDisplay> _getItemsForCategory(RestaurantDetailModel? detail, int categoryIndex) {
    if (detail == null ||
        categoryIndex < 0 ||
        categoryIndex >= detail.menuCategories.length) {
      return [];
    }
    return detail.menuCategories[categoryIndex].items
        .map((m) => MenuItemDisplay.fromModel(m))
        .toList();
  }

  /// Similar restaurants when the API provides them; empty until then (no English placeholders).
  List<SimilarRestaurantModel> _similarRestaurantsForDetail(RestaurantDetailModel? detail) {
    if (detail == null) return const [];
    return const [];
  }

  int _visibleMenuItemCount(
    RestaurantDetailModel? detail,
    List<MenuCategoryTabItem> apiCategories,
    int tabSelectedIndex,
    String searchQ,
  ) {
    var count = 0;
    for (var i = 0; i < apiCategories.length; i++) {
      if (tabSelectedIndex != 0 && tabSelectedIndex != i + 1) continue;
      count += _getItemsForCategory(detail, i)
          .where((m) => _menuItemMatchesSearch(m, searchQ))
          .length;
    }
    return count;
  }

  Widget _buildLoadErrorBody(
    BuildContext context, {
    required AppLocalizations l10n,
    required String languageCode,
    required String message,
    required VoidCallback onRetry,
    required Color pageBg,
    required bool isLight,
    required ThemeData theme,
  }) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            color: isLight ? _DetailsPalette.navyTitle : theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.restaurantDetailsLoadFailed,
                textAlign: TextAlign.center,
                style: FontHelper.getTextStyle(
                  text: l10n.restaurantDetailsLoadFailed,
                  languageCode: languageCode,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: FontHelper.getTextStyle(
                    text: message,
                    languageCode: languageCode,
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  l10n.retry,
                  style: FontHelper.getTextStyle(
                    text: l10n.retry,
                    languageCode: languageCode,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
    if (index == 0) return;
    final sectionIndex = index - 1;
    if (sectionIndex < _sectionKeys.length && _sectionKeys[sectionIndex].currentContext != null) {
      Scrollable.ensureVisible(
        _sectionKeys[sectionIndex].currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  /// Locks layout to LTR so RTL locales don’t mirror hero, meta row, offers, search, chips (matches English mock).
  Widget _structureLtr({required Widget child}) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }

  bool _menuItemMatchesSearch(MenuItemDisplay item, String query) {
    return item.matchesQuery(query);
  }

  Widget _buildCustomerReviewsSection(
    BuildContext context,
    RestaurantDetailController ctrl,
    AppLocalizations l10n, {
    required bool isCompact,
    required double contentWidth,
  }) {
    return Obx(() {
      final loading = ctrl.reviewsLoading.value;
      final list = ctrl.reviews;
      final err = ctrl.reviewsError.value;
      final languageCode = Get.find<LocaleController>().locale.languageCode;

      if (loading && list.isEmpty) {
        return SizedBox(
          height: isCompact ? 100 : 120,
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }

      if (list.isEmpty) {
        final theme = Theme.of(context);
        final msg = err.isNotEmpty ? l10n.reviewsCouldNotLoad : l10n.noCustomerReviewsYet;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 12),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              msg,
              style: FontHelper.getTextStyle(
                text: msg,
                languageCode: languageCode,
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      final cardWidth = isCompact
          ? (contentWidth - 24).clamp(220.0, 300.0)
          : (contentWidth * 0.86).clamp(260.0, 340.0);
      final carouselHeight = isCompact ? 168.0 : 180.0;

      return SizedBox(
        height: carouselHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, i) => ReviewCard(
            review: list[i],
            cardWidth: cardWidth,
          ),
        ),
      );
    });
  }

  Widget _wrapPageSafeArea(Widget child, {bool top = true}) =>
      SafeArea(top: top, child: child);

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final ctrl = _ctrl;
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 400;
    final isNarrow = media.width < 360;
    final hPad = context.pageHorizontalPadding;

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final pageBg = isLight ? _DetailsPalette.pageBackground : theme.scaffoldBackgroundColor;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Icon brightness only — avoid deprecated Window.setStatusBarColor / setNavigationBarColor.
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Obx(() {
        // Rebuild menu text when locale changes (name/description resolve on read).
        if (Get.isRegistered<LocaleController>()) {
          // ignore: unused_local_variable
          final _ = Get.find<LocaleController>().localeRx.value;
        }
        final hasShellArgs = args != null &&
            ((args.initialName != null && args.initialName!.trim().isNotEmpty) ||
                (args.initialCover != null && args.initialCover!.isNotEmpty) ||
                (args.initialImage != null && args.initialImage!.isNotEmpty));
        // Only block with full-page skeleton when we have nothing to show yet.
        if (ctrl.isLoading.value &&
            ctrl.detail.value == null &&
            !hasShellArgs) {
          return _wrapPageSafeArea(Scaffold(
            backgroundColor: pageBg,
            appBar: AppBar(
              backgroundColor: pageBg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  color: isLight ? _DetailsPalette.navyTitle : theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: RestaurantDetailsSkeleton(
              heroHeight: _heroHeightForWidth(MediaQuery.sizeOf(context).width),
              horizontalPadding: context.pageHorizontalPadding,
            ),
          ));
        }
        final detail = ctrl.detail.value;
        final waitingForMenu = ctrl.isLoading.value && detail == null;
        final l10n = AppLocalizations.of(context)!;
        final languageCode = Get.find<LocaleController>().locale.languageCode;
        if (detail == null &&
            ctrl.error.value.isNotEmpty &&
            !hasShellArgs) {
          return _wrapPageSafeArea(_buildLoadErrorBody(
            context,
            l10n: l10n,
            languageCode: languageCode,
            message: ctrl.error.value,
            onRetry: ctrl.loadDetail,
            pageBg: pageBg,
            isLight: isLight,
            theme: theme,
          ));
        }
        final name = detail?.restaurant.displayName ??
            (args?.initialName != null && args!.initialName!.trim().isNotEmpty
                ? args.initialName!.trim()
                : null) ??
            l10n.restaurantDefaultName;
        // Prefer cover/logo from list args for immediate, correct visuals.
        final coverUrl = detail?.restaurant.cover ?? args?.initialCover;
        final logoUrl = detail?.restaurant.logo ?? args?.initialLogo;
        final imageUrl = detail?.restaurant.image ?? args?.initialImage;
        final rating = detail?.restaurant.rating ?? args?.initialRating ?? 0;
        final location = detail?.restaurant.displayLocation ??
            args?.initialLocation ??
            l10n.defaultLocationPlaceholder;
        final category = detail?.restaurant.categoryNames ?? args?.initialCategory ?? l10n.defaultRestaurantCategoryTagline;
        final isOpen = detail?.restaurant.isOpen ?? args?.isOpen ?? true;
        final deliveryFee = detail?.restaurant.deliveryFee ?? args?.deliveryFee ?? 60.0;
        final description = detail?.restaurant.displayDescription;
        final tagline =
            (description != null && description.trim().isNotEmpty) ? description.trim() : category;

        final apiCategories = _getCategories(detail);
        _ensureSectionKeys(apiCategories.length);

        final tabCategories = <MenuCategoryTabItem>[
          MenuCategoryTabItem(id: -1, name: l10n.all),
          ...apiCategories,
        ];

        var tabSelectedIndex = _selectedCategoryIndex;
        if (tabCategories.isEmpty) {
          tabSelectedIndex = 0;
        } else if (tabSelectedIndex < 0 || tabSelectedIndex >= tabCategories.length) {
          tabSelectedIndex = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedCategoryIndex = 0);
          });
        }

        final heroH = _heroHeightForWidth(media.width);
        final searchQ = _menuSearchQuery;
        final visibleMenuCount = _visibleMenuItemCount(detail, apiCategories, tabSelectedIndex, searchQ);
        final menuEmptyMessage = searchQ.trim().isNotEmpty
            ? l10n.restaurantMenuSearchNoResults
            : l10n.restaurantMenuEmpty;

        final reviewContentWidth =
            (media.width < context.maxContentWidth ? media.width : context.maxContentWidth) -
            (hPad * 2);

        return _wrapPageSafeArea(
          Scaffold(
          backgroundColor: pageBg,
          body: MaxWidthBody(
            child: RefreshIndicator(
              color: isLight ? _DetailsPalette.forestGreen : theme.colorScheme.primary,
              onRefresh: ctrl.refreshDetail,
              child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeroHeader(
                    context,
                    ctrl: ctrl,
                    heroHeight: heroH,
                    coverUrl: coverUrl,
                    imageUrl: imageUrl,
                    horizontalPadding: hPad,
                  ),
                ),
            SliverToBoxAdapter(
              child: _buildInfoCard(
                context,
                name: name,
                tagline: tagline,
                rating: rating,
                location: location,
                isOpen: isOpen,
                imageUrl: logoUrl ?? imageUrl,
                freeDelivery: deliveryFee <= 0,
                deliveryFee: deliveryFee,
                isCompact: isCompact,
                isNarrow: isNarrow,
                horizontalPadding: hPad,
              ),
            ),
            SliverToBoxAdapter(
              child: _structureLtr(
                child: _buildMenuSectionHeader(
                  context,
                  l10n: l10n,
                  isCompact: isCompact,
                  horizontalPadding: hPad,
                ),
              ),
            ),
            if (apiCategories.isNotEmpty)
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: pageBg,
                  child: _structureLtr(
                    child: Padding(
                      padding: EdgeInsets.only(top: isCompact ? 12 : 14),
                      child: MenuCategoryTabs(
                        categories: tabCategories,
                        selectedIndex: tabSelectedIndex,
                        onCategorySelected: _onCategorySelected,
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _structureLtr(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (waitingForMenu)
                      Padding(
                        padding: EdgeInsets.only(top: isCompact ? 12 : 16),
                        child: MenuItemListSkeleton(
                          count: 4,
                          horizontalPadding: 0,
                        ),
                      )
                    else if (apiCategories.isEmpty || visibleMenuCount == 0)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: isCompact ? 24 : 32),
                        child: Center(
                          child: Text(
                            menuEmptyMessage,
                            textAlign: TextAlign.center,
                            style: FontHelper.getTextStyle(
                              text: menuEmptyMessage,
                              languageCode: languageCode,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    if (!waitingForMenu)
                      for (var i = 0; i < apiCategories.length; i++) ...[
                      if (tabSelectedIndex == 0 || tabSelectedIndex == i + 1) ...[
                        SizedBox(key: _sectionKeys[i], height: 1),
                        _buildMenuSection(
                          context,
                          categoryName: detail!.menuCategories[i].displayNameFor(languageCode),
                          items: _getItemsForCategory(detail, i)
                              .where((m) => _menuItemMatchesSearch(m, searchQ))
                              .toList(),
                          ctrl: ctrl,
                          isCompact: isCompact,
                          languageCode: languageCode,
                        ),
                      ],
                    ],
                    if (!waitingForMenu) ...[
                    SizedBox(height: isCompact ? 20 : 28),
                    _sectionTitle(context, l10n.customerReviewsSectionTitle, isCompact: isCompact),
                    SizedBox(height: isCompact ? 10 : 14),
                    _buildCustomerReviewsSection(
                      context,
                      ctrl,
                      l10n,
                      isCompact: isCompact,
                      contentWidth: reviewContentWidth,
                    ),
                    SizedBox(height: isCompact ? 20 : 28),
                    if (_similarRestaurantsForDetail(detail).isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: isCompact ? 20 : 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _sectionTitle(
                              context,
                              l10n.similarRestaurantsSectionTitle,
                              isCompact: isCompact,
                            ),
                            SizedBox(height: isCompact ? 10 : 14),
                            SizedBox(
                              height: isCompact ? 200 : 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: isCompact ? 12 : 16),
                                itemCount: _similarRestaurantsForDetail(detail).length,
                                itemBuilder: (context, i) {
                                  final sr = _similarRestaurantsForDetail(detail)[i];
                                  return SimilarRestaurantCard(
                                    restaurant: sr,
                                    onTap: () {
                                      Get.to<void>(
                                        () => RestaurantDetailsScreen(
                                          restaurantId: sr.id,
                                          args: RestaurantDetailsArgs(
                                            restaurantId: sr.id,
                                            initialName: sr.name,
                                            initialImage: sr.image,
                                            initialRating: sr.rating,
                                            initialCategory: sr.category,
                                          ),
                                        ),
                                        preventDuplicates: true,
                                        transition: Transition.cupertino,
                                        duration: const Duration(milliseconds: 220),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 100 + bottomInset),
                  ],
                ),
              ),
            ),
            ),
            ],
            ),
            ),
          ),
          bottomNavigationBar: GetBuilder<CartController>(
            builder: (cart) {
              final total = cart.total;
              if (total <= 0) return const SizedBox.shrink();
              final barPad = context.pageHorizontalPadding;
              final compactBar = isCompact;
              final barTheme = Theme.of(context);
              final priceColor = barTheme.brightness == Brightness.light
                  ? AppColors.primary
                  : barTheme.colorScheme.primary;
              return MaxWidthBody(
                child: Container(
                  padding: EdgeInsets.fromLTRB(barPad, 12, barPad, 8),
                  decoration: BoxDecoration(
                    color: barTheme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: compactBar
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.total,
                                          style: FontHelper.getTextStyle(
                                            text: l10n.total,
                                            languageCode: languageCode,
                                            fontSize: isNarrow ? 12.0 : 14.0,
                                            fontWeight: FontWeight.normal,
                                            color: barTheme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          AppCurrency.format(total, decimalDigits: 0),
                                          style: FontHelper.getTextStyle(
                                            text: AppCurrency.format(total, decimalDigits: 0),
                                            languageCode: languageCode,
                                            fontSize: isNarrow ? 20.0 : 24.0,
                                            fontWeight: FontWeight.w700,
                                            color: priceColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isNarrow ? 8 : 10),
                              AppButton(
                                label: l10n.viewCart,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const CartScreen()),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.total,
                                      style: FontHelper.getTextStyle(
                                        text: l10n.total,
                                        languageCode: languageCode,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        color: barTheme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      AppCurrency.format(total, decimalDigits: 0),
                                      style: FontHelper.getTextStyle(
                                        text: AppCurrency.format(total, decimalDigits: 0),
                                        languageCode: languageCode,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w700,
                                        color: priceColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              AppButton(
                                label: l10n.viewCart,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const CartScreen()),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        );
      }),
    );
  }

  Widget _heroPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.25),
      child: Center(
        child: Icon(Icons.restaurant_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context, {
    required RestaurantDetailController ctrl,
    required double heroHeight,
    required String? coverUrl,
    required String? imageUrl,
    required double horizontalPadding,
  }) {
    final heroSrc = (coverUrl != null && coverUrl.isNotEmpty) ? coverUrl : imageUrl;
    final theme = Theme.of(context);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'restaurant_hero_${widget.restaurantId}',
            child: Material(
              color: Colors.transparent,
              child: heroSrc != null && heroSrc.isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: heroSrc,
                      fit: BoxFit.cover,
                      width: MediaQuery.sizeOf(context).width,
                      height: heroHeight,
                      placeholder: (_, __) => _heroPlaceholder(heroHeight),
                      errorWidget: (_, __, ___) => _heroPlaceholder(heroHeight),
                    )
                  : _heroPlaceholder(heroHeight),
            ),
          ),
          PositionedDirectional(
            top: 8,
            end: horizontalPadding,
            child: Obx(
              () => _glassCircleButton(
                context,
                icon: ctrl.isFavorite.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: ctrl.isFavorite.value ? Colors.redAccent : _DetailsPalette.mutedGray,
                onTap: ctrl.isTogglingFavorite.value ? null : ctrl.toggleFavorite,
                diameter: 36,
                iconSize: 20,
                child: ctrl.isTogglingFavorite.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    Color? iconColor,
    Widget? child,
    double diameter = 44,
    double iconSize = 26,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Center(
            child: child ??
                Icon(
                  icon,
                  color: iconColor ?? _DetailsPalette.navyTitle,
                  size: iconSize,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String name,
    required String tagline,
    required double rating,
    required String location,
    required bool isOpen,
    String? imageUrl,
    required bool freeDelivery,
    required double deliveryFee,
    required bool isCompact,
    required bool isNarrow,
    required double horizontalPadding,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight ? _DetailsPalette.navyTitle : theme.colorScheme.onSurface;
    // Match menu item price accent so green meta stays readable in dark mode.
    final accentColor = isLight ? _DetailsPalette.forestGreen : theme.colorScheme.primary;
    final accentOnColor = isLight ? Colors.white : theme.colorScheme.onPrimary;
    final logoSize = isNarrow ? 48.0 : (isCompact ? 52.0 : 58.0);
    final deliveryLine = freeDelivery
        ? l10n.freeDeliveryLabel
        : l10n.deliveryFeeLabel(AppCurrency.format(deliveryFee, decimalDigits: 0));

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _structureLtr(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppNetworkImage(
                      imageUrl: imageUrl,
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _smallPlaceholder(logoSize, radius: 10),
                    ),
                  )
                else
                  _smallPlaceholder(logoSize, radius: 10),
                SizedBox(width: isCompact ? 12 : 14),
                Expanded(
                  child: Directionality(
                    textDirection: Directionality.of(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: FontHelper.getTextStyle(
                                  text: name,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: isNarrow ? 16.0 : (isCompact ? 17.0 : 19.0),
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: isNarrow ? 6 : 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isNarrow ? 8 : 12,
                                vertical: isNarrow ? 5 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: isOpen ? accentColor : _DetailsPalette.closedBg,
                                borderRadius: BorderRadius.circular(20),
                                border: isOpen
                                    ? null
                                    : Border.all(color: _DetailsPalette.closedFg, width: 1),
                              ),
                              child: Text(
                                isOpen ? l10n.restaurantStatusOpen : l10n.restaurantStatusClosed,
                                style: FontHelper.getTextStyle(
                                  text: isOpen ? l10n.restaurantStatusOpen : l10n.restaurantStatusClosed,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: isNarrow ? 9.0 : 10.0,
                                  fontWeight: FontWeight.w800,
                                  color: isOpen ? accentOnColor : _DetailsPalette.closedFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (tagline.isNotEmpty) ...[
                          SizedBox(height: isCompact ? 6 : 8),
                          Text(
                            tagline,
                            style: FontHelper.getTextStyle(
                              text: tagline,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: isCompact ? 12.0 : 13.0,
                              fontWeight: FontWeight.normal,
                              color: _DetailsPalette.mutedGray,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 16 : 18),
          _structureLtr(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: isNarrow ? 18 : 20,
                        color: AppColors.rating,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          rating > 0 ? rating.toStringAsFixed(1) : '—',
                          style: FontHelper.getTextStyle(
                            text: rating > 0 ? rating.toStringAsFixed(1) : '—',
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: isNarrow ? 13.0 : 14.0,
                            fontWeight: FontWeight.w800,
                            color: isLight ? const Color(0xFF616161) : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _metaDivider(theme),
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.pedal_bike_rounded,
                        size: isNarrow ? 18 : 20,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          deliveryLine,
                          style: FontHelper.getTextStyle(
                            text: deliveryLine,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: isNarrow ? 11.0 : 12.0,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _metaDivider(theme),
                Expanded(
                  flex: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: isNarrow ? 18 : 20,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: FontHelper.getTextStyle(
                            text: location,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: isNarrow ? 11.0 : 12.0,
                            fontWeight: FontWeight.w500,
                            color: _DetailsPalette.mutedGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaDivider(ThemeData theme) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6).copyWith(top: 2),
      height: 22,
      color: theme.dividerColor.withValues(alpha: 0.45),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String text, {
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final languageCode = Get.find<LocaleController>().locale.languageCode;

    return Text(
      text,
      style: FontHelper.getTextStyle(
        text: text,
        languageCode: languageCode,
        fontSize: isCompact ? 17.0 : 19.0,
        fontWeight: FontWeight.w800,
        color: isLight ? _DetailsPalette.navyTitle : theme.colorScheme.onSurface,
      ).copyWith(height: 1.2),
    );
  }

  Widget _buildMenuSectionHeader(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isCompact,
    required double horizontalPadding,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMenuSearchField(context, l10n: l10n, isCompact: isCompact),
          SizedBox(height: isCompact ? 18 : 22),
          _sectionTitle(context, l10n.menuSectionTitle, isCompact: isCompact),
          SizedBox(height: isCompact ? 10 : 12),
          Divider(
            height: 1,
            thickness: 1,
            color: isLight ? const Color(0xFFEEEEEE) : theme.dividerColor.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSearchField(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final accentColor = isLight ? _DetailsPalette.forestGreen : theme.colorScheme.primary;
    final borderRadius = BorderRadius.circular(14);
    final idleBorder = BorderSide(
      color: isLight ? const Color(0xFFE8E8E8) : theme.dividerColor.withValues(alpha: 0.5),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _menuSearchController,
        builder: (context, value, _) {
          final hasQuery = value.text.trim().isNotEmpty;
          return TextField(
            controller: _menuSearchController,
            textInputAction: TextInputAction.search,
            style: FontHelper.getTextStyle(
              text: '',
              languageCode: languageCode,
              fontSize: isCompact ? 14.0 : 15.0,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isLight ? Colors.white : theme.colorScheme.surfaceContainerHighest,
              hintText: l10n.searchMenuItemsHint,
              hintStyle: FontHelper.getTextStyle(
                text: l10n.searchMenuItemsHint,
                languageCode: languageCode,
                fontSize: isCompact ? 14.0 : 15.0,
                fontWeight: FontWeight.normal,
                color: _DetailsPalette.mutedGray,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _DetailsPalette.mutedGray,
                size: 22,
              ),
              suffixIcon: hasQuery
                  ? IconButton(
                      tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                      onPressed: () {
                        _menuSearchController.clear();
                        if (_menuSearchQuery.isNotEmpty) {
                          setState(() => _menuSearchQuery = '');
                        }
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: _DetailsPalette.mutedGray,
                      ),
                    )
                  : null,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isCompact ? 14 : 16,
              ),
              border: OutlineInputBorder(borderRadius: borderRadius, borderSide: idleBorder),
              enabledBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: idleBorder),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _smallPlaceholder(double size, {double radius = 12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: size * 0.5),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String categoryName,
    required List<MenuItemDisplay> items,
    required RestaurantDetailController ctrl,
    required bool isCompact,
    required String languageCode,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isCompact ? 16 : 20),
        Text(
          categoryName,
          style: FontHelper.getTextStyle(
            text: categoryName,
            languageCode: languageCode,
            fontSize: isCompact ? 17.0 : 19.0,
            fontWeight: FontWeight.w800,
            color: isLight ? _DetailsPalette.navyTitle : theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isCompact ? 10 : 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          cacheExtent: 400,
          itemBuilder: (context, index) {
            final item = items[index];
            return MenuItemCard(
              item: item,
              onTap: () async {
                final added = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => MenuItemDetailScreen(
                      restaurantId: widget.restaurantId,
                      item: item,
                    ),
                  ),
                );
                if (!context.mounted || added != true) return;
                final l10n = AppLocalizations.of(context)!;
                showAppAddedToCartNotice(
                  context,
                  message: l10n.itemAddedToCart(item.nameFor(languageCode)),
                );
              },
              onAdd: () async {
                if (item.needsCustomization) {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => MenuItemDetailScreen(
                        restaurantId: widget.restaurantId,
                        item: item,
                      ),
                    ),
                  );
                  if (!context.mounted || added != true) return;
                  final l10n = AppLocalizations.of(context)!;
                  showAppAddedToCartNotice(
                    context,
                    message: l10n.itemAddedToCart(item.nameFor(languageCode)),
                  );
                  return;
                }
                final cart = Get.find<CartController>();
                final result = cart.addItemWithResult(
                  restaurantId: widget.restaurantId,
                  item: CartItemRequest(
                    foodId: item.id,
                    quantity: 1,
                    imageUrl: item.image,
                  ),
                );
                if (!context.mounted) return;
                final l10n = AppLocalizations.of(context)!;
                if (result == CartAddResult.blockedDifferentRestaurant) {
                  final name = cart.displayRestaurantName ??
                      cart.restaurantName ??
                      l10n.restaurantDefaultName;
                  showDifferentRestaurantCartNotice(
                    context,
                    restaurantName: name,
                  );
                  return;
                }
                showAppAddedToCartNotice(
                  context,
                  message: l10n.itemAddedToCart(item.nameFor(languageCode)),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
