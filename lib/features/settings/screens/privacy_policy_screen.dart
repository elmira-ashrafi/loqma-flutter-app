import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../models/privacy_policy_document.dart';

double _privacyExpandedHeight(BuildContext context) {
  final mq = MediaQuery.of(context);
  final h = mq.size.height;
  final land = mq.orientation == Orientation.landscape;
  final bp = context.appBreakpoint;
  double base;
  switch (bp) {
    case AppBreakpoint.compact:
      base = context.screenWidth < 360 ? 176 : 196;
      break;
    case AppBreakpoint.medium:
      base = 224;
      break;
    case AppBreakpoint.expanded:
      base = 272;
      break;
  }
  if (land) {
    base = math.min(base, h * 0.4);
  }
  return base.clamp(152.0, 300.0);
}

double _privacyNavExtent(BuildContext context) {
  if (context.isAppExpanded) return 58;
  if (context.isAppMedium) return 54;
  return 50;
}

double _privacySectionGap(BuildContext context) {
  if (context.isAppExpanded) return 28;
  if (context.isAppMedium) return 22;
  return 16;
}

IconData _navIconFor(String id) {
  return switch (id) {
    'intro' => Icons.article_outlined,
    'collect' => Icons.inventory_2_outlined,
    'use' => Icons.tune_rounded,
    'security' => Icons.shield_outlined,
    'retention' => Icons.schedule_rounded,
    'rights' => Icons.verified_user_outlined,
    _ => Icons.circle_outlined,
  };
}

/// Privacy JSON may include a [contact] section; omit here — use Settings → Contact.
List<PrivacySection> _privacySectionsForUi(PrivacyPolicyDocument doc) {
  return doc.sections.where((s) => s.id != 'contact').toList();
}

(Color border, Color surfaceTint) _accentColors(String accent, ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  final Color c = switch (accent) {
    'blue' => const Color(0xFF1976D2),
    'green' => const Color(0xFF388E3C),
    'orange' => const Color(0xFFF57C00),
    'purple' => const Color(0xFF7B1FA2),
    'red' => const Color(0xFFC62828),
    'yellow' => const Color(0xFFF9A825),
    'cyan' => const Color(0xFF00838F),
    'indigo' => const Color(0xFF3949AB),
    _ => AppColors.primary,
  };
  final surface = isDark ? theme.colorScheme.surfaceContainerHigh : c.withValues(alpha: 0.08);
  return (c, surface);
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late List<GlobalKey> _sectionKeys;
  int _activeNav = 0;
  double _heroScroll = 0;
  double _lastExpandedHeight = 200;
  double _lastNavExtent = 54;
  Timer? _scrollSpyDebounce;
  late final AnimationController _fabPulse;
  double? _layoutWidth;

  PrivacyPolicyDocument? _doc;
  Object? _loadError;
  bool _loading = true;
  Locale? _loadedForLocale;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [];
    _scroll.addListener(_onScroll);
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.sizeOf(context).width;
    if (_layoutWidth != null && ((_layoutWidth! >= 900) != (w >= 900))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateNavFromScroll();
      });
    }
    _layoutWidth = w;
    final loc = Localizations.localeOf(context);
    if (_loadedForLocale != loc) {
      _loadForLocale(loc);
    }
  }

  Future<void> _loadForLocale(Locale locale) async {
    final code = locale.languageCode == 'fa' ? 'fa' : (locale.languageCode == 'ps' ? 'ps' : 'en');
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final doc = await PrivacyPolicyDocument.loadFromAsset('assets/privacy/$code.json');
      if (!mounted) return;
      setState(() {
        _doc = doc;
        _sectionKeys = List.generate(_privacySectionsForUi(doc).length, (_) => GlobalKey());
        _loading = false;
        _loadError = null;
        _loadedForLocale = locale;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavFromScroll());
    } catch (e) {
      try {
        final doc = await PrivacyPolicyDocument.loadFromAsset('assets/privacy/en.json');
        if (!mounted) return;
        setState(() {
          _doc = doc;
          _sectionKeys = List.generate(_privacySectionsForUi(doc).length, (_) => GlobalKey());
          _loading = false;
          _loadError = e;
          _loadedForLocale = locale;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavFromScroll());
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _doc = null;
          _loading = false;
          _loadError = e2;
        });
      }
    }
  }

  Future<void> _retryLoad() async {
    _loadedForLocale = null;
    await _loadForLocale(Localizations.localeOf(context));
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
    if (!mounted || _doc == null || _sectionKeys.isEmpty) return;
    final topInset = MediaQuery.paddingOf(context).top;
    final threshold = topInset + kToolbarHeight + _lastNavExtent + 12;

    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final box = _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final dist = (dy - threshold).abs();
      if (dy <= threshold + 48 && dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    if (best != _activeNav) {
      setState(() => _activeNav = best);
    }
  }

  Future<void> _scrollToNav(int index) async {
    if (index < 0 || index >= _sectionKeys.length) return;
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: context.isAppCompact ? 0.12 : (context.isAppExpanded ? 0.05 : 0.08),
    );
    if (mounted) setState(() => _activeNav = index);
  }

  Future<void> _scrollToTop() async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
    if (mounted) setState(() => _activeNav = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hPad = context.pageHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;

    if (_loadError != null && _doc == null && !_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.privacyPolicy,
            style: FontHelper.getTextStyle(
              text: l10n.privacyPolicy,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _retryLoad,
                  child: Text(
                    l10n.retry,
                    style: FontHelper.getTextStyle(
                      text: l10n.retry,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
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

    if (_loading || _doc == null || _sectionKeys.length != _privacySectionsForUi(_doc!).length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.privacyPolicy,
            style: FontHelper.getTextStyle(
              text: l10n.privacyPolicy,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final doc = _doc!;
    final sections = _privacySectionsForUi(doc);
    final expandedH = _privacyExpandedHeight(context);
    final navExt = _privacyNavExtent(context);
    final gap = _privacySectionGap(context);
    final topPad = context.isAppExpanded ? 22.0 : (context.isAppMedium ? 18.0 : 14.0);
    final bottomPad = context.isAppExpanded ? 36.0 : 26.0;
    _lastExpandedHeight = expandedH;
    _lastNavExtent = navExt;

    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.82,
      maxScaleFactor: 1.28,
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
                    flexibleSpace: _PrivacyHero(
                      l10n: l10n,
                      theme: theme,
                      hPad: hPad,
                      scrollOffset: _heroScroll,
                      expandedHeight: expandedH,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PrivacyNavDelegate(
                      extent: navExt,
                      horizontalPadding: hPad,
                      activeIndex: _activeNav,
                      theme: theme,
                      sections: sections,
                      onSelect: _scrollToNav,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) {
                            return SizedBox(height: gap);
                          }
                          final i = index ~/ 2;
                          if (i >= sections.length) return null;
                          return KeyedSubtree(
                            key: _sectionKeys[i],
                            child: _PrivacyReveal(
                              index: i,
                              child: _PrivacySectionCard(
                                section: sections[i],
                                theme: theme,
                              ),
                            ),
                          );
                        },
                        childCount: sections.isEmpty ? 0 : sections.length * 2 - 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: hPad.clamp(12.0, 28.0),
              bottom: MediaQuery.paddingOf(context).bottom + hPad.clamp(12.0, 20.0),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.06).animate(
                  CurvedAnimation(parent: _fabPulse, curve: Curves.easeInOut),
                ),
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? theme.colorScheme.primaryContainer : AppColors.primary,
                  child: InkWell(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(context.layoutScale(14).clamp(12.0, 18.0)),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: isDark ? theme.colorScheme.onPrimaryContainer : Colors.white,
                        size: context.layoutScale(28).clamp(22.0, 34.0),
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

class _PrivacyReveal extends StatefulWidget {
  const _PrivacyReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_PrivacyReveal> createState() => _PrivacyRevealState();
}

class _PrivacyRevealState extends State<_PrivacyReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
    Future<void>.delayed(Duration(milliseconds: 70 + widget.index * 45), () {
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

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero({
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
    final parallax = scrollOffset * 0.32;

    return LayoutBuilder(
      builder: (context, constraints) {
        final orb = context.layoutScale(110).clamp(80.0, 150.0);
        final bp = context.appBreakpoint;
        final titleFontSize = bp == AppBreakpoint.expanded
                ? 32.0
                : bp == AppBreakpoint.medium
                    ? 28.0
                    : 24.0;
        final subtitleFontSize = bp == AppBreakpoint.compact ? 14.0 : 16.0;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(AppColors.primaryLight, AppColors.primaryDark, t * 0.35)!,
                    Color.lerp(AppColors.primary, AppColors.primaryDark, 0.48 + t * 0.28)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -24 + parallax * 0.12,
              top: 16 - parallax * 0.18,
              child: _GlowOrb(diameter: orb, color: Colors.white.withValues(alpha: 0.11)),
            ),
            Positioned(
              left: -36 - parallax * 0.08,
              bottom: 24 + parallax * 0.1,
              child: _GlowOrb(diameter: orb * 1.15, color: Colors.black.withValues(alpha: 0.07)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, MediaQuery.paddingOf(context).top + 50, hPad, 16),
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
                          opacity: 1 - t * 0.82,
                          child: Text(
                            l10n.privacyPolicy,
                            style: FontHelper.getTextStyle(
                              text: l10n.privacyPolicy,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 6 + (1 - t) * 4),
                        Opacity(
                          opacity: (1 - t * 1.15).clamp(0.0, 1.0),
                          child: Text(
                            l10n.privacyPolicyHeroSubtitle,
                            style: FontHelper.getTextStyle(
                              text: l10n.privacyPolicyHeroSubtitle,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                            maxLines: 3,
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
                      opacity: (t * 1.12).clamp(0.0, 1.0),
                      child: Text(
                        l10n.privacyPolicy,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: l10n.privacyPolicy,
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

class _PrivacyNavDelegate extends SliverPersistentHeaderDelegate {
  _PrivacyNavDelegate({
    required this.extent,
    required this.horizontalPadding,
    required this.activeIndex,
    required this.theme,
    required this.sections,
    required this.onSelect,
  });

  final double extent;
  final double horizontalPadding;
  final int activeIndex;
  final ThemeData theme;
  final List<PrivacySection> sections;
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
    final iconSize = bp == AppBreakpoint.expanded ? 22.0 : (bp == AppBreakpoint.medium ? 21.0 : 20.0);
    final chipPad = bp == AppBreakpoint.expanded ? 11.0 : 9.0;
    final hScrollPad = math.max(8.0, horizontalPadding * 0.35);

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
            padding: EdgeInsets.symmetric(horizontal: hScrollPad, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < sections.length; i++)
                  _PrivacyNavChip(
                    icon: _navIconFor(sections[i].id),
                    tooltip: sections[i].title,
                    selected: activeIndex == i,
                    onTap: () => onSelect(i),
                    theme: theme,
                    iconSize: iconSize,
                    innerPadding: chipPad,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PrivacyNavDelegate oldDelegate) {
    final oldIds = oldDelegate.sections.map((e) => e.id).toList();
    final newIds = sections.map((e) => e.id).toList();
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.theme != theme ||
        oldDelegate.extent != extent ||
        oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.sections.length != sections.length ||
        !listEquals(oldIds, newIds);
  }
}

class _PrivacyNavChip extends StatelessWidget {
  const _PrivacyNavChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 3),
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

class _PrivacySectionCard extends StatelessWidget {
  const _PrivacySectionCard({
    required this.section,
    required this.theme,
  });

  final PrivacySection section;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 900;
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(context.isAppCompact ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(_navIconFor(section.id), color: AppColors.primary, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: FontHelper.getTextStyle(
                      text: section.title,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._body(context, isWide),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, bool isWide) {
    final children = <Widget>[];
    for (final p in section.paragraphs) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            p,
            style: FontHelper.getTextStyle(
              text: p,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    for (final sub in section.subsections) {
      final (border, bg) = _accentColors(sub.accent, theme);
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: border.withValues(alpha: 0.35)),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                leading: Icon(Icons.expand_more_rounded, color: border),
                title: Text(
                  sub.title,
                  style: FontHelper.getTextStyle(
                    text: sub.title,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: sub.intro != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          sub.intro!,
                          style: FontHelper.getTextStyle(
                            text: sub.intro!,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      )
                    : null,
                children: [
                  for (final b in sub.bullets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(Icons.circle, size: 8, color: border),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.title,
                                  style: FontHelper.getTextStyle(
                                    text: b.title,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.purpose,
                                  style: FontHelper.getTextStyle(
                                    text: b.purpose,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: theme.colorScheme.onSurface,
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
        ),
      );
    }

    for (final u in section.useCases) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.title,
                      style: FontHelper.getTextStyle(
                        text: u.title,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      u.description,
                      style: FontHelper.getTextStyle(
                        text: u.description,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        color: theme.colorScheme.onSurface,
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

    if (section.securityBullets.isNotEmpty) {
      final (border, bg) = _accentColors('green', theme);
      children.add(
        DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: border, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in section.securityBullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 20, color: border),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            line,
                            style: FontHelper.getTextStyle(
                              text: line,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: theme.colorScheme.onSurface,
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
      );
    }

    if (section.retentionCards.isNotEmpty) {
      children.add(
        LayoutBuilder(
          builder: (context, c) {
            final twoCol = isWide && c.maxWidth > 560;
            if (!twoCol) {
              return Column(
                children: [
                  for (final card in section.retentionCards) _retentionTile(card),
                ],
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in section.retentionCards)
                  SizedBox(width: (c.maxWidth - 12) / 2, child: _retentionTile(card)),
              ],
            );
          },
        ),
      );
    }

    if (section.rightsCards.isNotEmpty) {
      children.add(
        LayoutBuilder(
          builder: (context, c) {
            final twoCol = isWide && c.maxWidth > 560;
            if (!twoCol) {
              return Column(children: [for (final r in section.rightsCards) _rightsTile(r)]);
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final r in section.rightsCards)
                  SizedBox(width: (c.maxWidth - 12) / 2, child: _rightsTile(r)),
              ],
            );
          },
        ),
      );
    }

    if (section.footer != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            section.footer!,
            style: FontHelper.getTextStyle(
              text: section.footer!,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return children;
  }

  Widget _retentionTile(PrivacyTitleBody card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => HapticFeedback.selectionClick(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: FontHelper.getTextStyle(
                    text: card.title,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.body,
                  style: FontHelper.getTextStyle(
                    text: card.body,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rightsTile(PrivacyTitleBody r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.blue.shade50.withValues(alpha: theme.brightness == Brightness.dark ? 0.12 : 1),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.title,
                style: FontHelper.getTextStyle(
                  text: r.title,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                r.body,
                style: FontHelper.getTextStyle(
                  text: r.body,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
