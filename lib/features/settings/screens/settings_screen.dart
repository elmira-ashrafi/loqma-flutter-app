import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/l10n/language_display_names.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'delete_account_screen.dart';

double _settingsExpandedHeight(BuildContext context) {
  final mq = MediaQuery.of(context);
  final land = mq.orientation == Orientation.landscape;
  final bp = context.appBreakpoint;
  double base = switch (bp) {
    AppBreakpoint.compact => context.screenWidth < 360 ? 152 : 168,
    AppBreakpoint.medium => 196,
    AppBreakpoint.expanded => 228,
  };
  if (land) base = math.min(base, mq.size.height * 0.36);
  return base.clamp(140.0, 260.0);
}

double _settingsNavExtent(BuildContext context) {
  if (context.isAppExpanded) return 56;
  if (context.isAppMedium) return 52;
  return 48;
}

double _settingsSectionGap(BuildContext context) {
  if (context.isAppExpanded) return 22;
  if (context.isAppMedium) return 18;
  return 14;
}

/// Settings: hero header, pinned section nav, staggered groups, and responsive layout.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _keyDisplay = GlobalKey();
  final GlobalKey _keyLanguage = GlobalKey();
  final GlobalKey _keyAbout = GlobalKey();

  int _activeNav = 0;
  double _heroScroll = 0;
  double _lastExpandedHeight = 180;
  double _lastNavExtent = 52;
  Timer? _scrollSpyDebounce;
  late final AnimationController _fabPulse;
  double? _layoutWidth;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavFromScroll());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.sizeOf(context).width;
    if (_layoutWidth != null && ((_layoutWidth! >= 900) != (w >= 900))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavFromScroll());
    }
    _layoutWidth = w;
  }

  @override
  void dispose() {
    _scrollSpyDebounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _fabPulse.dispose();
    super.dispose();
  }

  void _onScroll() {
    final px = _scroll.offset.clamp(0.0, _lastExpandedHeight);
    if ((px - _heroScroll).abs() > 2) {
      setState(() => _heroScroll = px);
    }
    _scrollSpyDebounce?.cancel();
    _scrollSpyDebounce = Timer(const Duration(milliseconds: 48), _updateNavFromScroll);
  }

  void _updateNavFromScroll() {
    if (!mounted) return;
    final topInset = MediaQuery.paddingOf(context).top;
    final threshold = topInset + kToolbarHeight + _lastNavExtent + 10;
    final keys = [_keyDisplay, _keyLanguage, _keyAbout];
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < keys.length; i++) {
      final box = keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final dist = (dy - threshold).abs();
      if (dy <= threshold + 44 && dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    if (best != _activeNav) setState(() => _activeNav = best);
  }

  Future<void> _scrollToNav(int index) async {
    final keys = [_keyDisplay, _keyLanguage, _keyAbout];
    if (index < 0 || index >= keys.length) return;
    final ctx = keys[index].currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignment: context.isAppCompact ? 0.1 : (context.isAppExpanded ? 0.04 : 0.07),
    );
    if (mounted) setState(() => _activeNav = index);
  }

  Future<void> _scrollToTop() async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    if (mounted) setState(() => _activeNav = 0);
  }

  void _showLanguageSheet(BuildContext context, LocaleController localeCtrl) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    l10n.language,
                    style: FontHelper.getTextStyle(
                      text: l10n.language,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Obx(() {
                  final current = localeCtrl.locale;
                  return Column(
                    children: [
                      _LanguagePickTile(
                        label: LanguageDisplayNames.english,
                        selected: current == LocaleController.localeEn,
                        onTap: () {
                          localeCtrl.setLocale(LocaleController.localeEn);
                          Navigator.of(ctx).pop();
                        },
                      ),
                      _LanguagePickTile(
                        label: LanguageDisplayNames.pashto,
                        selected: current == LocaleController.localePs,
                        onTap: () {
                          localeCtrl.setLocale(LocaleController.localePs);
                          Navigator.of(ctx).pop();
                        },
                      ),
                      _LanguagePickTile(
                        label: LanguageDisplayNames.dari,
                        selected: current == LocaleController.localeFa,
                        onTap: () {
                          localeCtrl.setLocale(LocaleController.localeFa);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeCtrl = Get.find<LocaleController>();
    final themeCtrl = Get.find<ThemeController>();
    final hPad = context.pageHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final expandedH = _settingsExpandedHeight(context);
    final navExt = _settingsNavExtent(context);
    final gap = _settingsSectionGap(context);
    final topPad = context.isAppExpanded ? 18.0 : (context.isAppMedium ? 14.0 : 12.0);
    final bottomPad = context.isAppExpanded ? 32.0 : 24.0;
    _lastExpandedHeight = expandedH;
    _lastNavExtent = navExt;

    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.26,
    );

    return Scaffold(
      body: MaxWidthBody(
        child: Stack(
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: CustomScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    stretch: true,
                    pinned: true,
                    expandedHeight: expandedH,
                    elevation: 0,
                    scrolledUnderElevation: 2,
                    automaticallyImplyLeading: false,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    flexibleSpace: _SettingsHero(
                      l10n: l10n,
                      theme: theme,
                      hPad: hPad,
                      scrollOffset: _heroScroll,
                      expandedHeight: expandedH,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SettingsNavDelegate(
                      extent: navExt,
                      horizontalPadding: hPad,
                      activeIndex: _activeNav,
                      theme: theme,
                      l10n: l10n,
                      onSelect: _scrollToNav,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        KeyedSubtree(
                          key: _keyDisplay,
                          child: _SettingsReveal(
                            index: 0,
                            child: _SettingsGroupCard(
                              theme: theme,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Obx(() {
                                    final dark = themeCtrl.isDark;
                                    return _SettingsSwitchTile(
                                      icon: Icons.dark_mode_outlined,
                                      iconColor: const Color(0xFF5C6BC0),
                                      title: l10n.darkMode,
                                      subtitle: l10n.useDarkTheme,
                                      value: dark,
                                      onChanged: (v) {
                                        HapticFeedback.selectionClick();
                                        themeCtrl.toggleDark(v);
                                      },
                                    );
                                  }),
                                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                  _SettingsNavTile(
                                    icon: Icons.notifications_active_outlined,
                                    iconColor: const Color(0xFFFF9800),
                                    title: l10n.notificationsSetting,
                                    subtitle: l10n.pushAndInApp,
                                    showChevron: false,
                                    onTap: () => HapticFeedback.selectionClick(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        KeyedSubtree(
                          key: _keyLanguage,
                          child: _SettingsReveal(
                            index: 1,
                            child: _SettingsGroupCard(
                              theme: theme,
                              child: _SettingsNavTile(
                                icon: Icons.translate_rounded,
                                iconColor: AppColors.primary,
                                title: l10n.language,
                                subtitle: l10n.appLanguage,
                                showChevron: true,
                                onTap: () => _showLanguageSheet(context, localeCtrl),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        KeyedSubtree(
                          key: _keyAbout,
                          child: _SettingsReveal(
                            index: 2,
                            child: _SettingsGroupCard(
                              theme: theme,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SettingsNavTile(
                                    icon: Icons.info_outline_rounded,
                                    iconColor: const Color(0xFF2196F3),
                                    title: l10n.about,
                                    subtitle: l10n.aboutDocumentTitle,
                                    showChevron: true,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                                      );
                                    },
                                  ),
                                  // Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                  // _SettingsNavTile(
                                  //   icon: Icons.mail_outline_rounded,
                                  //   iconColor: const Color(0xFF00897B),
                                  //   title: l10n.contactUs,
                                  //   subtitle: l10n.contactDocumentTitle,
                                  //   showChevron: true,
                                  //   onTap: () {
                                  //     HapticFeedback.lightImpact();
                                  //     Navigator.of(context).push(
                                  //       MaterialPageRoute<void>(builder: (_) => const ContactScreen()),
                                  //     );
                                  //   },
                                  // ),
                               
                                 Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                  _SettingsNavTile(
                                    icon: Icons.privacy_tip_outlined,
                                    iconColor: const Color(0xFF7E57C2),
                                    title: l10n.privacy,
                                    subtitle: l10n.privacyPolicy,
                                    showChevron: true,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
                                      );
                                    },
                                  ),
                                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                  _SettingsNavTile(
                                    icon: Icons.description_outlined,
                                    iconColor: const Color(0xFF795548),
                                    title: l10n.terms,
                                    subtitle: l10n.termsOfService,
                                    showChevron: true,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(builder: (_) => const TermsOfServiceScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        _SettingsReveal(
                          index: 3,
                          child: Material(
                            elevation: 1.5,
                            shadowColor: Colors.black26,
                            borderRadius: BorderRadius.circular(18),
                            color: theme.colorScheme.surface,
                            clipBehavior: Clip.antiAlias,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFECACA).withValues(alpha: isDark ? 0.35 : 0.9),
                                ),
                              ),
                              child: _SettingsNavTile(
                                icon: Icons.person_off_outlined,
                                iconColor: const Color(0xFFB91C1C),
                                title: l10n.deleteAccountTitle,
                                subtitle: l10n.deleteAccountSettingsSubtitle,
                                showChevron: true,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(builder: (_) => const DeleteAccountScreen()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: hPad.clamp(12.0, 24.0),
              bottom: MediaQuery.paddingOf(context).bottom + hPad.clamp(10.0, 18.0),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.05).animate(
                  CurvedAnimation(parent: _fabPulse, curve: Curves.easeInOut),
                ),
                child: Material(
                  elevation: 5,
                  shadowColor: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? theme.colorScheme.primaryContainer : AppColors.primary,
                  child: InkWell(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(context.layoutScale(12).clamp(10.0, 16.0)),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: isDark ? theme.colorScheme.onPrimaryContainer : Colors.white,
                        size: context.layoutScale(26).clamp(22.0, 30.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickTile extends StatelessWidget {
  const _LanguagePickTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Icon(
              Icons.language_rounded,
              color: selected ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              label,
              style: FontHelper.getTextStyle(
                text: label,
                languageCode: LanguageDisplayNames.fontLanguageCode(label),
                fontSize: 16.0,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : theme.colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : theme.colorScheme.outline,
              size: selected ? 26 : 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsReveal extends StatefulWidget {
  const _SettingsReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_SettingsReveal> createState() => _SettingsRevealState();
}

class _SettingsRevealState extends State<_SettingsReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
    Future<void>.delayed(Duration(milliseconds: 60 + widget.index * 50), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  const _SettingsGroupCard({required this.theme, required this.child});

  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.isAppCompact ? 12 : 16, vertical: 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FontHelper.getTextStyle(
                      text: title,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: FontHelper.getTextStyle(
                      text: subtitle,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.showChevron,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.isAppCompact ? 12 : 16, vertical: 14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FontHelper.getTextStyle(
                        text: title,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: FontHelper.getTextStyle(
                        text: subtitle,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.l10n,
    required this.theme,
    required this.hPad,
    required this.scrollOffset,
    required this.expandedHeight,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final double hPad;
  final double scrollOffset;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final t = (scrollOffset / math.max(expandedHeight - kToolbarHeight, 1)).clamp(0.0, 1.0);
    final parallax = scrollOffset * 0.28;

    return LayoutBuilder(
      builder: (context, constraints) {
        final orb = context.layoutScale(96).clamp(72.0, 132.0);
        final bp = context.appBreakpoint;
        final titleStyle = (bp == AppBreakpoint.expanded
                ? theme.textTheme.headlineMedium
                : bp == AppBreakpoint.medium
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.titleLarge)
            ?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.3,
            );
        final subStyle = theme.textTheme.titleSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.92),
          height: 1.35,
          fontWeight: FontWeight.w500,
        );

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(AppColors.primaryLight, AppColors.primaryDark, t * 0.32)!,
                    Color.lerp(AppColors.primary, AppColors.primaryDark, 0.45 + t * 0.26)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -20 + parallax * 0.1,
              top: 14 - parallax * 0.15,
              child: _GlowOrb(diameter: orb, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
              left: -32 - parallax * 0.06,
              bottom: 20 + parallax * 0.08,
              child: _GlowOrb(diameter: orb * 1.1, color: Colors.black.withValues(alpha: 0.06)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, MediaQuery.paddingOf(context).top + 48, hPad, 14),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth - hPad * 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 1 - t * 0.8,
                          child: Text(
                            l10n.settings,
                            style: FontHelper.getTextStyle(
                              text: l10n.settings,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 28.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4 + (1 - t) * 4),
                        Opacity(
                          opacity: (1 - t * 1.1).clamp(0.0, 1.0),
                          child: Text(
                            l10n.settingsHeroSubtitle,
                            style: FontHelper.getTextStyle(
                              text: l10n.settingsHeroSubtitle,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
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
            Positioned(
              top: MediaQuery.paddingOf(context).top + 4,
              left: math.max(4.0, hPad - 8),
              right: hPad,
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: context.layoutScale(18).clamp(16.0, 22.0)),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: (t * 1.1).clamp(0.0, 1.0),
                      child: Text(
                        l10n.settings,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: l10n.settings,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.layoutScale(48).clamp(40.0, 56.0)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SettingsNavDelegate extends SliverPersistentHeaderDelegate {
  _SettingsNavDelegate({
    required this.extent,
    required this.horizontalPadding,
    required this.activeIndex,
    required this.theme,
    required this.l10n,
    required this.onSelect,
  });

  final double extent;
  final double horizontalPadding;
  final int activeIndex;
  final ThemeData theme;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outlineVariant.withValues(alpha: 0.35);
    final bp = context.appBreakpoint;
    final iconSize = bp == AppBreakpoint.expanded ? 23.0 : 21.0;
    final pad = bp == AppBreakpoint.expanded ? 11.0 : 9.0;
    final hScroll = math.max(8.0, horizontalPadding * 0.35);

    final items = <({IconData icon, String tip, int index})>[
      (icon: Icons.tune_rounded, tip: l10n.settingsNavDisplay, index: 0),
      (icon: Icons.translate_rounded, tip: l10n.settingsNavLanguage, index: 1),
      (icon: Icons.menu_book_outlined, tip: l10n.settingsNavAbout, index: 2),
    ];

    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black26,
      color: surface,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
        child: Align(
          alignment: bp == AppBreakpoint.expanded ? Alignment.center : Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hScroll, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in items)
                  _SettingsNavChip(
                    icon: e.icon,
                    tooltip: e.tip,
                    selected: activeIndex == e.index,
                    onTap: () => onSelect(e.index),
                    theme: theme,
                    iconSize: iconSize,
                    innerPadding: pad,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SettingsNavDelegate oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.theme != theme ||
        oldDelegate.extent != extent ||
        oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.l10n != l10n;
  }
}

class _SettingsNavChip extends StatelessWidget {
  const _SettingsNavChip({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.iconSize,
    required this.innerPadding,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final double iconSize;
  final double innerPadding;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final minSide = math.max(44.0, innerPadding * 2 + iconSize);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSide, minHeight: minSide),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? primary.withValues(alpha: 0.14) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? primary.withValues(alpha: 0.55) : Colors.transparent,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                splashColor: primary.withValues(alpha: 0.2),
                child: Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: selected ? primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
