import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../models/terms_of_service_document.dart';

double _termsExpandedHeight(BuildContext context) {
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

double _termsNavExtent(BuildContext context) {
  if (context.isAppExpanded) return 58;
  if (context.isAppMedium) return 54;
  return 50;
}

double _termsSectionGap(BuildContext context) {
  if (context.isAppExpanded) return 28;
  if (context.isAppMedium) return 22;
  return 16;
}

IconData _navIconFor(String id) {
  return switch (id) {
    'overview' => Icons.info_outline_rounded,
    'accounts' => Icons.person_outline_rounded,
    'acceptable' => Icons.gpp_bad_outlined,
    'orders' => Icons.receipt_long_outlined,
    'delivery' => Icons.delivery_dining_rounded,
    'drivers' => Icons.local_shipping_outlined,
    'restaurants' => Icons.restaurant_outlined,
    'ip' => Icons.policy_outlined,
    'law' => Icons.balance_outlined,
    'disclaimers' => Icons.warning_amber_rounded,
    'changes' => Icons.edit_notifications_outlined,
    _ => Icons.article_outlined,
  };
}

/// Terms JSON may include a [contact] section; omit — use Settings → Contact.
List<TermsSection> _termsSectionsForUi(TermsOfServiceDocument doc) {
  return doc.sections.where((s) => s.id != 'contact').toList();
}

(Color border, Color surfaceTint) _accentColors(String accent, ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  final Color c = switch (accent) {
    'blue' => const Color(0xFF1976D2),
    'green' => const Color(0xFF388E3C),
    'orange' => const Color(0xFFF57C00),
    'red' => const Color(0xFFC62828),
    'yellow' => const Color(0xFFF9A825),
    'primary' => AppColors.primary,
    _ => AppColors.primary,
  };
  final surface = isDark ? theme.colorScheme.surfaceContainerHigh : c.withValues(alpha: 0.09);
  return (c, surface);
}

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late List<GlobalKey> _sectionKeys;
  int _activeNav = 0;
  double _heroScroll = 0;
  double _lastExpandedHeight = 200;
  double _lastNavExtent = 54;
  Timer? _scrollSpyDebounce;
  late final AnimationController _fabPulse;
  double? _layoutWidth;

  TermsOfServiceDocument? _doc;
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
      final doc = await TermsOfServiceDocument.loadFromAsset('assets/terms/$code.json');
      if (!mounted) return;
      setState(() {
        _doc = doc;
        _sectionKeys = List.generate(_termsSectionsForUi(doc).length, (_) => GlobalKey());
        _loading = false;
        _loadError = null;
        _loadedForLocale = locale;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavFromScroll());
    } catch (e) {
      try {
        final doc = await TermsOfServiceDocument.loadFromAsset('assets/terms/en.json');
        if (!mounted) return;
        setState(() {
          _doc = doc;
          _sectionKeys = List.generate(_termsSectionsForUi(doc).length, (_) => GlobalKey());
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
            l10n.termsOfService,
            style: FontHelper.getTextStyle(
              text: l10n.termsOfService,
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

    if (_loading || _doc == null || _sectionKeys.length != _termsSectionsForUi(_doc!).length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.termsOfService,
            style: FontHelper.getTextStyle(
              text: l10n.termsOfService,
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
    final sections = _termsSectionsForUi(doc);
    final expandedH = _termsExpandedHeight(context);
    final navExt = _termsNavExtent(context);
    final gap = _termsSectionGap(context);
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
                    flexibleSpace: _TermsHero(
                      l10n: l10n,
                      theme: theme,
                      hPad: hPad,
                      scrollOffset: _heroScroll,
                      expandedHeight: expandedH,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TermsNavDelegate(
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
                            child: _TermsReveal(
                              index: i,
                              child: _TermsSectionCard(
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

class _TermsReveal extends StatefulWidget {
  const _TermsReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TermsReveal> createState() => _TermsRevealState();
}

class _TermsRevealState extends State<_TermsReveal> with SingleTickerProviderStateMixin {
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
    Future<void>.delayed(Duration(milliseconds: 70 + widget.index * 40), () {
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

class _TermsHero extends StatelessWidget {
  const _TermsHero({
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
                            l10n.termsOfService,
                            style: FontHelper.getTextStyle(
                              text: l10n.termsOfService,
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
                            l10n.termsHeroSubtitle,
                            style: FontHelper.getTextStyle(
                              text: l10n.termsHeroSubtitle,
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
                        l10n.termsOfService,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: l10n.termsOfService,
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

class _TermsNavDelegate extends SliverPersistentHeaderDelegate {
  _TermsNavDelegate({
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
  final List<TermsSection> sections;
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
    final iconSize = bp == AppBreakpoint.expanded ? 21.0 : (bp == AppBreakpoint.medium ? 20.0 : 19.0);
    final chipPad = bp == AppBreakpoint.expanded ? 10.0 : 8.0;
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
                  _TermsNavChip(
                    icon: _navIconFor(sections[i].id),
                    tooltip: sections[i].effectiveNavTitle,
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
  bool shouldRebuild(covariant _TermsNavDelegate oldDelegate) {
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

class _TermsNavChip extends StatelessWidget {
  const _TermsNavChip({
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
    final minSide = math.max(42.0, innerPadding * 2 + iconSize);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
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

class _TermsCalloutView extends StatelessWidget {
  const _TermsCalloutView({required this.callout, required this.theme});

  final TermsCallout callout;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (border, bg) = _accentColors(callout.accent, theme);
    return DecoratedBox(
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
            if (callout.title != null) ...[
              Text(
                callout.title!,
                style: FontHelper.getTextStyle(
                  text: callout.title!,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            for (final p in callout.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  p,
                  style: FontHelper.getTextStyle(
                    text: p,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            for (final b in callout.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: border),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: FontHelper.getTextStyle(
                          text: b,
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
    );
  }
}

class _TermsSectionCard extends StatelessWidget {
  const _TermsSectionCard({
    required this.section,
    required this.theme,
  });

  final TermsSection section;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasMainTitle = section.title != null && section.title!.trim().isNotEmpty;
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
            if (hasMainTitle)
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
                      section.title!,
                      style: FontHelper.getTextStyle(
                        text: section.title!,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            if (hasMainTitle && (section.callout != null || section.lead != null || section.blocks.isNotEmpty || section.prohibited.isNotEmpty)) const SizedBox(height: 16),
            if (section.callout != null) _TermsCalloutView(callout: section.callout!, theme: theme),
            if (section.callout != null && (section.lead != null || section.blocks.isNotEmpty || section.prohibited.isNotEmpty)) const SizedBox(height: 14),
            if (section.lead != null) ...[
              Text(
                section.lead!,
                style: FontHelper.getTextStyle(
                  text: section.lead!,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
            ],
            for (final p in section.prohibited) _prohibitedCard(p),
            if (section.prohibited.isNotEmpty && section.blocks.isNotEmpty) const SizedBox(height: 12),
            for (final b in section.blocks) _buildBlock(b),
            if (section.closingNote != null) ...[
              const SizedBox(height: 14),
              Text(
                section.closingNote!,
                style: FontHelper.getTextStyle(
                  text: section.closingNote!,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _prohibitedCard(TermsProhibitedItem p) {
    final bg = theme.brightness == Brightness.dark
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.25)
        : Colors.red.shade50;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title,
                style: FontHelper.getTextStyle(
                  text: p.title,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.body,
                style: FontHelper.getTextStyle(
                  text: p.body,
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

  Widget _buildBlock(TermsBlock b) {
    final children = <Widget>[];
    if (b.heading != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            b.heading!,
            style: FontHelper.getTextStyle(
              text: b.heading!,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }
    if (b.paragraph != null) {
      children.add(
        Text(
          b.paragraph!,
          style: FontHelper.getTextStyle(
            text: b.paragraph!,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }
    for (final p in b.paragraphs) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            p,
            style: FontHelper.getTextStyle(
              text: p,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }
    for (final line in b.bullets) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
              ),
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
      );
    }
    for (var k = 0; k < b.orderedList.length; k++) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '${k + 1}.',
                  style: FontHelper.getTextStyle(
                    text: '${k + 1}.',
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  b.orderedList[k],
                  style: FontHelper.getTextStyle(
                    text: b.orderedList[k],
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
      );
    }
    if (b.callout != null) {
      children.add(Padding(padding: const EdgeInsets.only(top: 12), child: _TermsCalloutView(callout: b.callout!, theme: theme)));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }
}
