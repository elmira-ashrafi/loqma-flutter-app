import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/utils/phone_display.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../controllers/home_controller.dart';
import '../models/home_model.dart';
import '../../restaurant/screens/restaurant_details_screen.dart';
import '../../restaurant/models/restaurant_details_args.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/screens/restaurant_list_screen.dart';
import '../../restaurants/services/restaurant_service.dart';
import '../../restaurants/widgets/restaurant_list_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../addresses/controllers/delivery_location_controller.dart';
import '../../addresses/models/address_model.dart';
import '../../addresses/screens/addresses_screen.dart';
import '../../addresses/screens/address_wizard_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../support/screens/support_tickets_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../customer/screens/customer_dashboard_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../../core/layout/responsive_context.dart';

/// Reference home UI: forest green, navy titles, soft grays (light mode).
abstract final class _HomeRefDesign {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color mutedGray = Color(0xFF9E9E9E);
  static const Color openBg = Color(0xFFE8F5E9);
  static const Color openFg = Color(0xFF4CAF50);
  static const Color closedBg = Color(0xFFFCE4EC);
  static const Color closedFg = Color(0xFFE91E63);
  static const Color searchFill = Color(0xFFF5F5F5);
  static const Color menuFill = Color(0xFFF5F5F5);
}

/// Soft radar-style pulse for the delivery pin until a location is added.
class _DeliveryLocationIcon extends StatefulWidget {
  const _DeliveryLocationIcon({
    required this.size,
    required this.color,
    required this.pulse,
  });

  final double size;
  final Color color;
  final bool pulse;

  @override
  State<_DeliveryLocationIcon> createState() => _DeliveryLocationIconState();
}

class _DeliveryLocationIconState extends State<_DeliveryLocationIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _DeliveryLocationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _syncPulse();
  }

  void _syncPulse() {
    if (widget.pulse) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.location_on_rounded,
      size: widget.size,
      color: widget.color,
    );
    if (!widget.pulse) return icon;

    final ringSize = widget.size + 14;
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (final delay in const [0.0, 0.35])
                _PulseRing(
                  progress: ((t + delay) % 1.0),
                  color: widget.color,
                  size: ringSize,
                ),
              Transform.translate(
                offset: Offset(0, -0.6 * math.sin(t * math.pi * 2)),
                child: child,
              ),
            ],
          );
        },
        child: icon,
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.progress,
    required this.color,
    required this.size,
  });

  final double progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.35;
    final scale = 0.55 + (progress * 0.75);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 1.5,
          ),
          color: color.withValues(alpha: opacity * 0.18),
        ),
      ),
    );
  }
}

/// Prompt card shown on home until the customer saves a delivery address.
class _DeliveryLocationPromptCard extends StatelessWidget {
  const _DeliveryLocationPromptCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    required this.compact,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? theme.colorScheme.primary : _HomeRefDesign.forestGreen;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final radius = compact ? 18.0 : 20.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: isDark ? 0.24 : 0.11),
                accent.withValues(alpha: isDark ? 0.10 : 0.03),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: isDark ? 0.34 : 0.18)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
                blurRadius: compact ? 12 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 14 : 16,
              compact ? 14 : 16,
              compact ? 12 : 14,
              compact ? 14 : 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 44 : 48,
                  height: compact ? 44 : 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.28 : 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: accent,
                    size: compact ? 24 : 26,
                  ),
                ),
                SizedBox(width: compact ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FontHelper.getTextStyle(
                          text: title,
                          languageCode: languageCode,
                          fontSize: compact ? 15 : 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        subtitle,
                        style: FontHelper.getTextStyle(
                          text: subtitle,
                          languageCode: languageCode,
                          fontSize: compact ? 12.5 : 13.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ).copyWith(height: 1.35),
                      ),
                      SizedBox(height: compact ? 12 : 14),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FilledButton.icon(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize: Size(0, compact ? 40 : 42),
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 14 : 16,
                              vertical: compact ? 8 : 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.add_location_alt_rounded, size: compact ? 18 : 20),
                          label: Text(
                            actionLabel,
                            style: FontHelper.getTextStyle(
                              text: actionLabel,
                              languageCode: languageCode,
                              fontSize: compact ? 13 : 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

/// Drawer rows use a fixed LTR layout (icon left, chevron right) in every locale.
Widget _drawerLtrRow(Widget child) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

/// Home tab: promotions, categories, featured & nearby restaurants from /home.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.isActive = true});

  /// When false (off-tab in IndexedStack), pause banners / unnecessary work.
  final bool isActive;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _homeScrollController = ScrollController();
  late final HomeController _homeCtrl;

  AddressModel? get _deliveryAddress =>
      Get.isRegistered<DeliveryLocationController>()
      ? Get.find<DeliveryLocationController>().deliveryAddress.value
      : null;

  bool get _addressLoading =>
      Get.isRegistered<DeliveryLocationController>() &&
      Get.find<DeliveryLocationController>().isLoading.value;

  Worker? _localeWorker;

  @override
  void dispose() {
    _localeWorker?.dispose();
    _homeScrollController.removeListener(_onHomeScroll);
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onHomeScroll() {
    if (!mounted ||
        _homeCtrl.isLoadingBrowse.value ||
        !_homeCtrl.hasMoreBrowse.value)
      return;
    if (_homeCtrl.selectedCategoryId.value != null) return;
    if (!_homeScrollController.hasClients) return;
    _homeCtrl.rememberHomeScrollOffset(_homeScrollController.offset);
    final pos = _homeScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 480) {
      _homeCtrl.loadBrowseRestaurants(loadMore: true);
    }
  }

  Future<void> _bootstrapHomeTab() async {
    await _homeCtrl.restoreScrollOffset();
    // Address already loads in DeliveryLocationController.onInit — only
    // refresh if still empty (avoids duplicate network on every home mount).
    if (Get.isRegistered<DeliveryLocationController>()) {
      final loc = Get.find<DeliveryLocationController>();
      if (loc.deliveryAddress.value == null && !loc.isLoading.value) {
        await loc.loadDefaultAddress();
      }
    }
    // Reuse cached browse list when warm; pull-to-refresh still forces reload.
    await _homeCtrl.loadBrowseRestaurants(force: false);
    _restoreHomeScrollOffset();
  }

  void _restoreHomeScrollOffset() {
    final offset = _homeCtrl.homeScrollOffset;
    if (offset <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_homeScrollController.hasClients) return;
      final max = _homeScrollController.position.maxScrollExtent;
      _homeScrollController.jumpTo(offset.clamp(0.0, max));
    });
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HomeController>()) {
      _homeCtrl = Get.find<HomeController>();
    } else {
      _homeCtrl = Get.put(HomeController(), permanent: true);
    }
    _homeScrollController.addListener(_onHomeScroll);
    unawaited(_bootstrapHomeTab());
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _refreshDeliveryAddress() async {
    if (Get.isRegistered<DeliveryLocationController>()) {
      await Get.find<DeliveryLocationController>().loadDefaultAddress();
    }
  }

  String _deliveryAddressLabel(BuildContext context, {int? maxChars}) {
    final l10n = AppLocalizations.of(context)!;
    if (_addressLoading) return '…';
    if (!Get.isRegistered<AuthController>() ||
        !Get.find<AuthController>().isLoggedIn) {
      return l10n.signInToContinue;
    }
    if (_deliveryAddress == null) return l10n.selectOrAddAddress;
    final line = _deliveryAddress!.appBarSummary.trim();
    if (line.isEmpty) return l10n.selectOrAddAddress;
    if (maxChars != null)
      return _deliveryAddress!.appBarSummaryTruncated(maxChars);
    return line;
  }

  Future<void> _onDeliveryAddressTap(BuildContext context) async {
    if (!Get.isRegistered<AuthController>()) return;
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      await Get.toNamed(AppRoutes.login);
      if (mounted) await _refreshDeliveryAddress();
      return;
    }
    if (_deliveryAddress == null && !_addressLoading) {
      final user = auth.currentUser;
      final added = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => AddressWizardScreen(
            initialName: user?.name,
            initialPhone: user?.phone,
          ),
        ),
      );
      if (mounted) await _refreshDeliveryAddress();
      if (added == true && mounted) return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AddressesScreen()),
    );
    if (mounted) await _refreshDeliveryAddress();
  }

  @override
  Widget build(BuildContext context) {
    final r = HomeLayout.of(context);
    final ctrl = _homeCtrl;
    return Scaffold(
      // Use a single drawer on the "start" side; Flutter will place it
      // on left or right automatically based on text direction.
      drawer: const _HomeSideMenuDrawer(),
      body: Builder(
        builder: (scaffoldContext) {
          return RefreshIndicator(
            color: _HomeRefDesign.forestGreen,
            displacement: 48,
            onRefresh: () async {
              await ctrl.refreshAll();
              await ctrl.loadBrowseRestaurants(force: true);
              await _refreshDeliveryAddress();
            },
            child: SafeArea(
              top: true,
              bottom: true,
              left: true,
              right: true,
              child: CustomScrollView(
                controller: _homeScrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildPinnedAppBar(scaffoldContext, r),
                  SliverToBoxAdapter(
                    child: _buildHeroAndSearch(scaffoldContext, ctrl, r),
                  ),
                  SliverToBoxAdapter(
                    child: _buildBody(scaffoldContext, ctrl, r),
                  ),
                  Obx(() {
                    if (ctrl.selectedCategoryId.value != null) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return _buildAllRestaurantsSliver(scaffoldContext, r);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildPinnedAppBar(BuildContext context, HomeLayout r) {
    final theme = Theme.of(context);
    final padding = r.horizontalPadding;
    final addressMaxChars = r.isCompact ? 22 : 28;
    final sideButtonSize = r.isCompact ? 46.0 : 48.0;
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: r.isCompact ? 64 : 72,
      titleSpacing: 0,
      title: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
          child: Row(
            children: [
              SizedBox(
                width: sideButtonSize,
                height: sideButtonSize,
                child: Material(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceContainerHighest
                      : _HomeRefDesign.menuFill,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      final s = Scaffold.maybeOf(context);
                      if (s == null) return;
                      s.openDrawer();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.menu_rounded,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : _HomeRefDesign.navyTitle,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (Get.isRegistered<DeliveryLocationController>()) {
                    // ignore: unused_local_variable
                    final _ = Get.find<DeliveryLocationController>()
                        .deliveryAddress
                        .value;
                    // ignore: unused_local_variable
                    final __ =
                        Get.find<DeliveryLocationController>().isLoading.value;
                  }
                  final addressLabel = _deliveryAddressLabel(
                    context,
                    maxChars: addressMaxChars,
                  );
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onDeliveryAddressTap(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.deliveryTo.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: FontHelper.getTextStyle(
                                text: AppLocalizations.of(
                                  context,
                                )!.deliveryTo.toUpperCase(),
                                languageCode: Get.find<LocaleController>()
                                    .locale
                                    .languageCode,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.onSurfaceVariant
                                    : _HomeRefDesign.navyTitle,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _DeliveryLocationIcon(
                                  size: r.isCompact ? 17 : 19,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.primary
                                      : _HomeRefDesign.forestGreen,
                                  pulse:
                                      widget.isActive &&
                                      Get.isRegistered<AuthController>() &&
                                      Get.find<AuthController>().isLoggedIn &&
                                      !_addressLoading &&
                                      _deliveryAddress == null,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    addressLabel,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: FontHelper.getTextStyle(
                                      text: addressLabel,
                                      languageCode: Get.find<LocaleController>()
                                          .locale
                                          .languageCode,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: theme.brightness == Brightness.dark
                                          ? theme.colorScheme.onSurface
                                          : _HomeRefDesign.navyTitle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Obx(() {
                final themeCtrl = Get.find<ThemeController>();
                final isDark = themeCtrl.isDark;
                const sunColor = Color(0xFFF59E0B);
                const moonColor = Color(0xFF93C5FD);
                return SizedBox(
                  width: sideButtonSize,
                  height: sideButtonSize,
                  child: Material(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        themeCtrl.toggleDark(!isDark);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.bedtime_rounded,
                        color: isDark ? sunColor : moonColor,
                        size: r.isCompact ? 23 : 25,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroAndSearch(
    BuildContext context,
    HomeController ctrl,
    HomeLayout r,
  ) {
    final padding = r.horizontalPadding;
    final heroHeight = r.bannerHeight;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, r.isCompact ? 10 : 12),
      child: Column(
        children: [
          Obx(() {
            if (Get.isRegistered<LocaleController>()) {
              // ignore: unused_local_variable
              final _ = Get.find<LocaleController>().localeRx.value;
            }
            if (Get.isRegistered<DeliveryLocationController>()) {
              // ignore: unused_local_variable
              final _ = Get.find<DeliveryLocationController>().deliveryAddress.value;
              // ignore: unused_local_variable
              final __ = Get.find<DeliveryLocationController>().isLoading.value;
            }
            final showPrompt = Get.isRegistered<AuthController>() &&
                Get.find<AuthController>().isLoggedIn &&
                !_addressLoading &&
                _deliveryAddress == null;
            if (!showPrompt) return const SizedBox.shrink();
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: EdgeInsets.only(bottom: r.isCompact ? 10 : 12),
              child: _DeliveryLocationPromptCard(
                title: l10n.deliveryLocationPromptTitle,
                subtitle: l10n.deliveryLocationPromptSubtitle,
                actionLabel: l10n.deliveryLocationPromptAction,
                onTap: () => _onDeliveryAddressTap(context),
                compact: r.isCompact,
              ),
            );
          }),
          Obx(() {
            final cityId = Get.isRegistered<DeliveryLocationController>()
                ? Get.find<DeliveryLocationController>().deliveryCityId
                : null;
            final scoped = cityId == null
                ? ctrl.banners.toList()
                : ctrl.banners.where((b) => b.cityId == cityId).toList();
            if (scoped.isEmpty && !ctrl.isLoadingBanners.value) {
              return const SizedBox.shrink();
            }
            if (ctrl.isLoadingBanners.value && scoped.isEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LoadingShimmer(
                  height: heroHeight,
                  width: double.infinity,
                  borderRadius: 16,
                ),
              );
            }
            if (scoped.isEmpty) return const SizedBox.shrink();
            return _BannerCarousel(
              banners: scoped,
              responsive: r,
              isActive: widget.isActive,
            );
          }),
          SizedBox(height: r.isCompact ? 10 : 12),
          _SearchPill(
            hintText: AppLocalizations.of(context)!.searchAllHint,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, a1, __) =>
                      FadeTransition(opacity: a1, child: const SearchScreen()),
                  transitionDuration: const Duration(milliseconds: 260),
                  reverseTransitionDuration: const Duration(milliseconds: 220),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeController ctrl, HomeLayout r) {
    final padding = r.horizontalPadding;
    return Obx(() {
      if (Get.isRegistered<LocaleController>()) {
        // ignore: unused_local_variable
        final _ = Get.find<LocaleController>().localeRx.value;
      }
      if (Get.isRegistered<ThemeController>()) {
        // ignore: unused_local_variable
        final _ = Get.find<ThemeController>().themeMode;
      }
      if (Get.isRegistered<DeliveryLocationController>()) {
        // ignore: unused_local_variable
        final _ = Get.find<DeliveryLocationController>().deliveryAddress.value;
      }
      final data = ctrl.homeData.value;
      if (ctrl.isLoading.value && data == null) {
        return Padding(
          padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [RestaurantCardShimmer(count: 4)],
          ),
        );
      }
      if (data == null && ctrl.error.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.all(padding * 1.5),
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: 1),
              builder: (context, t, child) {
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - t)),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 760),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.88, end: 1),
                    builder: (context, s, _) => Transform.scale(
                      scale: s,
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 52,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Text(
                      ctrl.error.value,
                      key: ValueKey(ctrl.error.value),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: ctrl.refreshAll,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      AppLocalizations.of(context)!.retry,
                      style: FontHelper.getTextStyle(
                        text: AppLocalizations.of(context)!.retry,
                        languageCode:
                            Get.find<LocaleController>().locale.languageCode,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final categories = ctrl.categoriesList.isNotEmpty
          ? ctrl.categoriesList.toList()
          : (data?.categories ?? []);
      final cityId = Get.isRegistered<DeliveryLocationController>()
          ? Get.find<DeliveryLocationController>().deliveryCityId
          : null;
      final topRestaurants = (data?.topRestaurants ?? const <RestaurantItem>[])
          .where((r) => cityId == null || r.cityId == cityId)
          .toList();

      return Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: AppLocalizations.of(context)!.categories,
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RestaurantListScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: _HomeRefDesign.forestGreen,
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: FontHelper.getTextStyle(
                    text: AppLocalizations.of(context)!.viewAll,
                    languageCode:
                        Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _HomeRefDesign.forestGreen,
                  ),
                ),
              ),
            ),
            SizedBox(height: r.isCompact ? 8 : 10),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _CategoryPill(
                    label: AppLocalizations.of(context)!.all,
                    selected: ctrl.selectedCategoryId.value == null,
                    icon: Icons.restaurant_menu_rounded,
                    onTap: () => ctrl.setCategoryFilter(null, null),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(categories.length, (i) {
                    final c = categories[i];
                    final selected = ctrl.selectedCategoryId.value == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryPill(
                        label: c.displayName,
                        selected: selected,
                        icon: _iconForCategory(c, i),
                        onTap: () =>
                            ctrl.setCategoryFilter(c.id, c.displayName, c.slug),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: r.isCompact ? 14 : 18),
            if (ctrl.selectedCategoryId.value != null) ...[
              _SectionHeader(
                title: AppLocalizations.of(context)!.restaurants,
                trailing: TextButton(
                  onPressed: () => ctrl.setCategoryFilter(null, null),
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeRefDesign.forestGreen,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.clear,
                    style: FontHelper.getTextStyle(
                      text: AppLocalizations.of(context)!.clear,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _HomeRefDesign.forestGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (ctrl.isLoadingFiltered.value)
                const RestaurantCardShimmer(count: 4)
              else
                _RestaurantGrid(
                  responsive: r,
                  count: ctrl.filteredRestaurants.length,
                  itemBuilder: (context, i) {
                    final m = ctrl.filteredRestaurants[i];
                    return _RestaurantImageCard(
                      index: i,
                      name: m.displayName,
                      image: m.image,
                      rating: m.rating,
                      isFeatured: m.isFeatured,
                      subtitle: m.displaySubtitle,
                      totalReviews: m.totalReviews,
                      prepMinutes: m.avgPreparationTime,
                      deliveryFee: m.deliveryFee,
                      isOpen: m.isOpen,
                      deliveryTime: m.deliveryTime,
                      onTap: () => _openRestaurantWithModel(context, m),
                      restaurantId: m.id,
                    );
                  },
                ),
            ] else ...[
              _SectionHeader(
                title: AppLocalizations.of(context)!.topRestaurants,
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RestaurantListScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeRefDesign.forestGreen,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: FontHelper.getTextStyle(
                      text: AppLocalizations.of(context)!.seeAll,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _HomeRefDesign.forestGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: r.isCompact ? 210 : 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: math.min(6, topRestaurants.length),
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final item = topRestaurants[i];
                    final width = MediaQuery.sizeOf(context).width;
                    final cardWidth = (width * 0.72).clamp(248.0, 340.0);
                    return SizedBox(
                      width: cardWidth,
                      child: _RestaurantImageCard(
                        index: i,
                        name: item.displayName,
                        image: item.image,
                        rating: item.rating,
                        isFeatured: item.isFeatured,
                        subtitle: item.displaySubtitle,
                        totalReviews: item.totalReviews,
                        prepMinutes: item.avgPreparationTime,
                        deliveryFee: item.deliveryFee,
                        isOpen: item.isOpen,
                        deliveryTime: item.deliveryTime,
                        onTap: () => _openRestaurant(context, item),
                        restaurantId: item.id,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: r.isCompact ? 22 : 28),
              _SectionHeader(
                title: AppLocalizations.of(context)!.allRestaurants,
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RestaurantListScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeRefDesign.forestGreen,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: FontHelper.getTextStyle(
                      text: AppLocalizations.of(context)!.seeAll,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _HomeRefDesign.forestGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAllRestaurantsSliver(BuildContext context, HomeLayout r) {
    final padding = r.horizontalPadding;
    return Obx(() {
      final restaurants = _homeCtrl.browseRestaurants;
      final loading = _homeCtrl.isLoadingBrowse.value;
      final hasMore = _homeCtrl.hasMoreBrowse.value;

      if (loading && restaurants.isEmpty) {
        return SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(padding, 4, padding, 24),
          sliver: const SliverToBoxAdapter(
            child: RestaurantCardShimmer(count: 4),
          ),
        );
      }
      if (restaurants.isEmpty) {
        return SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(padding, 4, padding, 24),
          sliver: SliverToBoxAdapter(
            child: Text(
              AppLocalizations.of(context)!.noResults,
              style: FontHelper.getTextStyle(
                text: AppLocalizations.of(context)!.noResults,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsetsDirectional.fromSTEB(padding, 4, padding, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
            if (i >= restaurants.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SkeletonLoadMoreIndicator(),
              );
            }
            final rModel = restaurants[i];
            return Padding(
              key: ValueKey(rModel.id),
              padding: const EdgeInsets.only(bottom: 10),
              child: RestaurantListCard(
                name: rModel.displayName,
                description:
                    rModel.displaySubtitle ?? rModel.displayLocation ?? '',
                image: rModel.image,
                rating: rModel.rating,
                deliveryTime: rModel.deliveryTime,
                prepMinutes: rModel.avgPreparationTime,
                isOpen: rModel.isOpen,
                deliveryFee: rModel.deliveryFee,
                compact: true,
                restaurantId: rModel.id,
                responsive: r,
                onTap: () => _openRestaurantWithModel(context, rModel),
              ),
            );
          }, childCount: restaurants.length + (hasMore ? 1 : 0)),
        ),
      );
    });
  }

  void _openRestaurant(BuildContext context, RestaurantItem r) {
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: r.id,
        args: RestaurantDetailsArgs(
          restaurantId: r.id,
          initialName: r.displayName,
          initialImage: r.image,
          initialRating: r.rating,
          initialDeliveryTime: r.deliveryTime,
          initialLocation: r.displayLocation ?? r.distance,
          isOpen: r.isOpen,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }

  void _openRestaurantWithModel(BuildContext context, RestaurantModel r) {
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

class _HomeHeroData {
  const _HomeHeroData({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });
  final String title;
  final String subtitle;
  final String? imageUrl;
}

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner({required this.data, required this.height});

  final _HomeHeroData data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - v)),
            child: child,
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (data.imageUrl != null && data.imageUrl!.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AppNetworkImage(
                      imageUrl: data.imageUrl!,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                    );
                  },
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.secondary.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: data.title,
                              languageCode: Get.find<LocaleController>()
                                  .locale
                                  .languageCode,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              data.subtitle,
                              style: FontHelper.getTextStyle(
                                text: data.subtitle,
                                languageCode: Get.find<LocaleController>()
                                    .locale
                                    .languageCode,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
        ),
      ),
    );
  }
}

IconData _iconForCategory(CategoryItem c, int index) {
  final slug = (c.slug ?? '').toLowerCase();
  final name = c.displayName.toLowerCase();
  if (slug.contains('pizza') || name.contains('pizza'))
    return Icons.local_pizza_rounded;
  if (slug.contains('burger') || name.contains('burger'))
    return Icons.lunch_dining_rounded;
  if (slug.contains('sushi') || name.contains('sushi'))
    return Icons.ramen_dining_rounded;
  if (slug.contains('dessert') ||
      name.contains('dessert') ||
      name.contains('sweet')) {
    return Icons.cake_rounded;
  }
  if (slug.contains('coffee') || name.contains('coffee'))
    return Icons.local_cafe_rounded;
  const fallbacks = [
    Icons.restaurant_rounded,
    Icons.fastfood_rounded,
    Icons.local_dining_rounded,
    Icons.set_meal_rounded,
  ];
  return fallbacks[index % fallbacks.length];
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.hintText, required this.onTap});
  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Material(
      color: isLight
          ? _HomeRefDesign.searchFill
          : theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight
                  ? const Color(0xFFEEEEEE)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isLight
                    ? _HomeRefDesign.mutedGray
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontHelper.getTextStyle(
                    text: hintText,
                    languageCode:
                        Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? _HomeRefDesign.mutedGray
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: isLight
                    ? _HomeRefDesign.mutedGray
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isFilled = selected;
    final bg = isFilled
        ? _HomeRefDesign.forestGreen
        : (isLight ? Colors.white : theme.colorScheme.surfaceContainerHigh);
    final fg = isFilled
        ? Colors.white
        : (isLight ? _HomeRefDesign.forestGreen : theme.colorScheme.primary);
    final border = isFilled
        ? Colors.transparent
        : (isLight
              ? const Color(0xFFE0E0E0)
              : theme.colorScheme.outlineVariant);
    final iconBg = isFilled
        ? Colors.white.withValues(alpha: 0.15)
        : _HomeRefDesign.forestGreen.withValues(alpha: 0.12);
    final iconColor = isFilled
        ? Colors.white
        : (isLight ? _HomeRefDesign.forestGreen : theme.colorScheme.primary);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(10 * (1 - v), 0),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _HomeRefDesign.forestGreen.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontHelper.getTextStyle(
                      text: label,
                      languageCode:
                          Get.find<LocaleController>().locale.languageCode,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fg,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isLight = theme.brightness == Brightness.light;
    final displayTitle = isRtl ? title : title.toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: displayTitle,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isLight
                  ? _HomeRefDesign.navyTitle
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RestaurantGrid extends StatelessWidget {
  const _RestaurantGrid({
    required this.responsive,
    required this.count,
    required this.itemBuilder,
  });

  final HomeLayout responsive;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final columns = w < 360 ? 1 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 1.55 : 0.83,
      ),
      itemCount: count,
      itemBuilder: itemBuilder,
    );
  }
}

class _RestaurantImageCard extends StatelessWidget {
  const _RestaurantImageCard({
    required this.index,
    required this.name,
    required this.image,
    required this.rating,
    this.isFeatured = false,
    this.subtitle,
    this.totalReviews,
    this.prepMinutes,
    this.deliveryFee,
    this.isOpen,
    this.deliveryTime,
    required this.onTap,
    this.restaurantId,
  });

  final int index;
  final String name;
  final String? image;
  final double rating;
  final bool isFeatured;
  final String? subtitle;
  final int? totalReviews;
  final int? prepMinutes;
  final double? deliveryFee;
  final bool? isOpen;
  final String? deliveryTime;
  final VoidCallback onTap;
  final int? restaurantId;

  String _timeCaption(BuildContext context) {
    return restaurantPrepTimeCaption(
      context,
      avgPrepMinutes: prepMinutes,
      rawDeliveryTime: deliveryTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight
        ? _HomeRefDesign.navyTitle
        : theme.colorScheme.onSurface;
    final open = isOpen ?? true;
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = open
        ? l10n.restaurantStatusOpen
        : l10n.restaurantStatusClosed;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        final delay = (index.clamp(0, 8) * 0.06);
        final t = ((v - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.07 : 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _wrapHero(
                        image != null && image!.isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: image!,
                                width: 220,
                                height: 140,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: AppColors.primary.withOpacity(0.08),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.primary.withOpacity(0.08),
                                ),
                              )
                            : Container(
                                color: AppColors.primary.withOpacity(0.08),
                              ),
                      ),
                      if (rating > 0)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.rating,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: FontHelper.getTextStyle(
                                    text: rating.toStringAsFixed(1),
                                    languageCode: Get.find<LocaleController>()
                                        .locale
                                        .languageCode,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isFeatured)
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!.featured,
                                  style: FontHelper.getTextStyle(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.featured,
                                    languageCode: Get.find<LocaleController>()
                                        .locale
                                        .languageCode,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontHelper.getTextStyle(
                            text: subtitle!,
                            languageCode: Get.find<LocaleController>()
                                .locale
                                .languageCode,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isLight
                                ? _HomeRefDesign.mutedGray
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: open
                                  ? _HomeRefDesign.openBg
                                  : _HomeRefDesign.closedBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: FontHelper.getTextStyle(
                                text: statusLabel,
                                languageCode: Get.find<LocaleController>()
                                    .locale
                                    .languageCode,
                                fontSize:
                                    theme.textTheme.labelSmall?.fontSize ?? 11,
                                fontWeight: FontWeight.w800,
                                color: open
                                    ? _HomeRefDesign.openFg
                                    : _HomeRefDesign.closedFg,
                              ).copyWith(letterSpacing: 0.6),
                            ),
                          ),
                          if (deliveryFee != null && deliveryFee == 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.pedal_bike_rounded,
                              size: 15,
                              color: _HomeRefDesign.forestGreen,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _timeCaption(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: FontHelper.getTextStyle(
                              text: _timeCaption(context),
                              languageCode: Get.find<LocaleController>()
                                  .locale
                                  .languageCode,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isLight
                                  ? _HomeRefDesign.mutedGray
                                  : theme.colorScheme.onSurfaceVariant,
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

  Widget _wrapHero(Widget child) {
    if (restaurantId == null) return child;
    return Hero(tag: 'restaurant_hero_$restaurantId', child: child);
  }
}

class _HomeSideMenuDrawer extends StatefulWidget {
  const _HomeSideMenuDrawer();

  @override
  State<_HomeSideMenuDrawer> createState() => _HomeSideMenuDrawerState();
}

class _HomeSideMenuDrawerState extends State<_HomeSideMenuDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final user = auth.currentUser;
    final theme = Theme.of(context);
    final name = user?.name ?? l10n.profile;
    final phoneShown = displayAfghanLocalPhone(user?.phone);

    return Drawer(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 6),
                  child: _drawerLtrRow(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: FontHelper.getTextStyle(
                                  text: name,
                                  languageCode: Get.find<LocaleController>()
                                      .locale
                                      .languageCode,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      theme.textTheme.titleSmall?.color ??
                                      Colors.black,
                                ),
                              ),
                              if (phoneShown.isNotEmpty)
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    phoneShown,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: FontHelper.getTextStyle(
                                      text: phoneShown,
                                      languageCode: Get.find<LocaleController>()
                                          .locale
                                          .languageCode,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    children: [
                      _DrawerItem(
                        index: 0,
                        icon: Icons.dashboard_rounded,
                        label: l10n.dashboard,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, a1, __) => FadeTransition(
                                opacity: a1,
                                child: const CustomerDashboardScreen(),
                              ),
                              transitionDuration: const Duration(
                                milliseconds: 240,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        index: 1,
                        icon: Icons.location_on_rounded,
                        label: l10n.addresses,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddressesScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        index: 2,
                        icon: Icons.notifications_rounded,
                        label: l10n.notifications,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        index: 3,
                        icon: Icons.support_agent_rounded,
                        label: l10n.supportTicket,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SupportTicketsScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        index: 4,
                        icon: Icons.settings_rounded,
                        label: l10n.settings,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 12,
                    end: 12,
                    bottom: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _drawerLtrRow(
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          foregroundColor: AppColors.error,
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await auth.logout();
                          Get.offAllNamed('/login');
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(
                          l10n.logout,
                          textAlign: TextAlign.left,
                          style: FontHelper.getTextStyle(
                            text: l10n.logout,
                            languageCode: Get.find<LocaleController>()
                                .locale
                                .languageCode,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
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
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        final t = v.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              child: _drawerLtrRow(
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: FontHelper.getTextStyle(
                          text: label,
                          languageCode: languageCode,
                          fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.textTheme.bodyMedium?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.color,
    required this.responsive,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final Color color;
  final HomeLayout responsive;

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final padding = r.isCompact ? 16.0 : (r.isTablet ? 24.0 : 20.0);
    final titleSize = r.isCompact ? 18.0 : (r.isTablet ? 26.0 : 22.0);
    final subtitleSize = r.isCompact ? 12.0 : 14.0;
    final badgeSize = r.isCompact ? 10.0 : 12.0;
    return Container(
      margin: EdgeInsets.only(right: r.isCompact ? 8.0 : 12.0),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.isTablet ? 24.0 : 20.0),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: badgeSize + 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(
                  height: badge != null ? (r.isCompact ? 8.0 : 12.0) : 0,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: subtitleSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({
    required this.banners,
    required this.responsive,
    this.isActive = true,
  });

  final List<BannerItem> banners;
  final HomeLayout responsive;
  final bool isActive;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entranceController;
  Timer? _autoPlayTimer;

  /// Gap between banner cards so slides don't look joined while swiping.
  static const double _cardGap = 10;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!widget.isActive) return;
    if (widget.banners.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !widget.isActive || widget.banners.isEmpty) return;
      if (!_pageController.hasClients) return;
      final next = (_pageController.page?.round() ?? 0) + 1;
      final index = next % widget.banners.length;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length ||
        oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _startAutoPlay();
      } else {
        _autoPlayTimer?.cancel();
        _autoPlayTimer = null;
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final height = r.bannerHeight;
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Opacity(
          opacity: Curves.easeOutCubic.transform(_entranceController.value),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _entranceController.value)),
            child: child,
          ),
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.banners.length,
                physics: const BouncingScrollPhysics(),
                padEnds: false,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      var page = index.toDouble();
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        page = _pageController.page ?? page;
                      }
                      final distance = (page - index).abs().clamp(0.0, 1.0);
                      // Slightly shrink neighbors so the active banner reads as separate.
                      final scale = 1.0 - (distance * 0.035);
                      return Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _cardGap / 2),
                      child: _BannerCard(
                        banner: widget.banners[index],
                        height: height,
                        responsive: r,
                      ),
                    ),
                  );
                },
              ),
              if (widget.banners.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: r.isCompact ? 12 : 14,
                  child: Center(
                    child: _BannerDots(
                      count: widget.banners.length,
                      pageController: _pageController,
                      responsive: r,
                      overlayOnPhoto: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerDots extends StatelessWidget {
  const _BannerDots({
    required this.count,
    required this.pageController,
    required this.responsive,
    this.overlayOnPhoto = false,
  });

  static const int _maxDots = 3;

  final int count;
  final PageController pageController;
  final HomeLayout responsive;
  final bool overlayOnPhoto;

  /// At most [_maxDots] dots; maps slide index to highlighted dot when `count` > [_maxDots].
  static int _highlightDotIndex(int slideIndex, int slideCount, int dotCount) {
    if (slideCount <= 1 || dotCount <= 1) return 0;
    if (slideCount <= dotCount) return slideIndex.clamp(0, dotCount - 1);
    final rel = slideIndex / (slideCount - 1);
    return (rel * (dotCount - 1)).round().clamp(0, dotCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = pageController.hasClients
            ? (pageController.page ?? 0)
            : 0.0;
        final current = page.round().clamp(0, count - 1);
        final dotCount = count.clamp(2, _maxDots);
        final highlight = _highlightDotIndex(current, count, dotCount);
        final dots = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dotCount, (i) {
            final isActive = i == highlight;
            if (overlayOnPhoto) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 8 : 6,
                height: isActive ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              );
            }
            final double width = isActive
                ? (responsive.isCompact ? 20.0 : 24.0)
                : (responsive.isCompact ? 6.0 : 8.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: width,
                height: responsive.isCompact ? 6.0 : 6.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.9)
                      : AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
            );
          }),
        );
        return Directionality(textDirection: TextDirection.ltr, child: dots);
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.height,
    required this.responsive,
  });

  final BannerItem banner;
  final double height;
  final HomeLayout responsive;

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final radius = r.isTablet ? 24.0 : 20.0;
    final l10n = AppLocalizations.of(context)!;
    final orderNowLabel = l10n.orderNow;
    return GestureDetector(
      onTap: () => _handleBannerTap(context, banner),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.image != null && banner.image!.isNotEmpty)
                  Positioned.fill(
                    child: AppNetworkImage(
                      imageUrl: banner.image!,
                      width: MediaQuery.sizeOf(context).width,
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.expand(),
                      errorWidget: (_, __, ___) => const SizedBox.expand(),
                    ),
                  )
                else
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.6),
                            AppColors.secondary.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: height * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                if ((banner.displayTitle ?? banner.displaySubtitle) != null)
                  Positioned(
                    left: r.isCompact ? 14 : 20,
                    right: r.isCompact ? 14 : 20,
                    bottom: r.isCompact ? 14 : 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (banner.displayTitle != null &&
                            banner.displayTitle!.isNotEmpty)
                          Text(
                            banner.displayTitle!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: r.isCompact
                                  ? 16
                                  : (r.isTablet ? 22 : 18),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (banner.displaySubtitle != null &&
                            banner.displaySubtitle!.isNotEmpty) ...[
                          SizedBox(height: r.isCompact ? 4 : 6),
                          Text(
                            banner.displaySubtitle!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: r.isCompact ? 12 : 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: r.isCompact ? 10 : 12),
                        Material(
                          color: _HomeRefDesign.forestGreen,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _handleBannerTap(context, banner),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.isCompact ? 18 : 20,
                                vertical: r.isCompact ? 9 : 10,
                              ),
                              child: Text(
                                orderNowLabel,
                                style: FontHelper.getTextStyle(
                                  text: orderNowLabel,
                                  languageCode: Get.find<LocaleController>()
                                      .locale
                                      .languageCode,
                                  fontSize: r.isCompact ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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

Future<void> _handleBannerTap(BuildContext context, BannerItem banner) async {
  final type = (banner.linkType ?? 'url').toLowerCase();
  final value = banner.link?.trim() ?? '';
  if (value.isEmpty) return;

  switch (type) {
    case 'url':
      // Common case: take user to all restaurants.
      if (value == '/restaurants' || value == 'restaurants') {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        return;
      }
      // Same in-app list for full URLs to /restaurants (e.g. web admin paste).
      if (value.startsWith('http://') || value.startsWith('https://')) {
        final uri = Uri.tryParse(value);
        if (uri != null) {
          final path = uri.path;
          final restaurantSlug = _restaurantSlugFromPath(path);
          if (restaurantSlug != null) {
            await _openBannerRestaurant(context, restaurantSlug);
            return;
          }
          final isRestaurantsPath =
              path == '/restaurants' || path.endsWith('/restaurants');
          if (isRestaurantsPath) {
            final cat = uri.queryParameters['category']?.trim();
            if (cat != null && cat.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RestaurantListScreen(
                    categorySlug: cat,
                    categoryName: cat.replaceAll('-', ' '),
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
              );
            }
            return;
          }
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      }
      // Relative path: restaurants list in-app when possible.
      {
        final path = value.startsWith('/') ? value : '/$value';
        final uri = Uri.tryParse('https://placeholder.local$path');
        if (uri != null) {
          final p = uri.path;
          final restaurantSlug = _restaurantSlugFromPath(p);
          if (restaurantSlug != null) {
            await _openBannerRestaurant(context, restaurantSlug);
            return;
          }
          if (p == '/restaurants' || p.endsWith('/restaurants')) {
            final cat = uri.queryParameters['category']?.trim();
            if (cat != null && cat.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RestaurantListScreen(
                    categorySlug: cat,
                    categoryName: cat.replaceAll('-', ' '),
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
              );
            }
            return;
          }
        }
        final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
        final full = Uri.parse(
          '$base${value.startsWith('/') ? value : '/$value'}',
        );
        await launchUrl(full, mode: LaunchMode.externalApplication);
      }
      break;

    case 'category':
      // value is category slug, e.g. "afghan-cuisine".
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RestaurantListScreen(
            categorySlug: value,
            categoryName: value.replaceAll('-', ' '),
          ),
        ),
      );
      break;

    case 'restaurant':
      await _openBannerRestaurant(context, value);
      break;

    default:
      // Fallback: behave like URL.
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
      final full = Uri.parse(
        '$base${value.startsWith('/') ? value : '/$value'}',
      );
      await launchUrl(full, mode: LaunchMode.externalApplication);
  }
}

String? _restaurantSlugFromPath(String path) {
  final segments = Uri(
    path: path,
  ).pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != 2 || segments.first != 'restaurants') return null;
  return segments.last;
}

Future<void> _openBannerRestaurant(
  BuildContext context,
  String idOrSlug,
) async {
  final directId = int.tryParse(idOrSlug);
  // Numeric id: open immediately — detail loads inside the screen.
  if (directId != null && directId > 0) {
    if (!context.mounted) return;
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: directId,
        args: RestaurantDetailsArgs(restaurantId: directId),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
    return;
  }

  try {
    final restaurant = await RestaurantService().getRestaurantByIdOrPath(
      idOrSlug,
    );
    final resolvedId = restaurant.restaurant.id;
    if (!context.mounted || resolvedId <= 0) return;
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: resolvedId,
        args: RestaurantDetailsArgs(
          restaurantId: resolvedId,
          initialName: restaurant.restaurant.displayName,
          initialImage: restaurant.restaurant.image,
          initialLogo: restaurant.restaurant.logo,
          initialCover: restaurant.restaurant.cover,
          initialRating: restaurant.restaurant.rating,
          isOpen: restaurant.restaurant.isOpen,
          deliveryFee: restaurant.restaurant.deliveryFee,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  } catch (_) {}
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.category,
    required this.color,
    required this.fallbackIcon,
    required this.responsive,
    required this.index,
    this.isSelected = false,
    this.onTap,
  });

  final CategoryItem category;
  final Color color;
  final IconData fallbackIcon;
  final HomeLayout responsive;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 320),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _entranceOffset =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
          ),
        );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: 25 * widget.index.clamp(0, 12)), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final hasImage =
        widget.category.image != null && widget.category.image!.isNotEmpty;
    final iconSize = r.categoryIconSize;
    final radius = r.isTablet ? 16.0 : 14.0;
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _scaleController]),
      builder: (context, child) {
        return Opacity(
          opacity: _entranceOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _entranceOffset.value.dy * r.categoryChipHeight),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          width: r.categoryChipWidth,
          margin: EdgeInsets.only(right: r.isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(radius),
            border: widget.isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: r.isCompact ? 4 : 6,
                horizontal: r.isCompact ? 4 : 6,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: iconSize + 6,
                      height: iconSize + 6,
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AppNetworkImage(
                                imageUrl: widget.category.image!,
                                width: iconSize + 6,
                                height: iconSize + 6,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Icon(
                                  widget.fallbackIcon,
                                  size: iconSize,
                                  color: AppColors.primary,
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  widget.fallbackIcon,
                                  size: iconSize,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Icon(
                              widget.fallbackIcon,
                              size: iconSize,
                              color: AppColors.primary,
                            ),
                    ),
                    SizedBox(height: r.isCompact ? 2 : 3),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: r.categoryChipWidth - 12,
                      ),
                      child: Text(
                        widget.category.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: r.isCompact ? 9 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
