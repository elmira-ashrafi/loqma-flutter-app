import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

double _aboutExpandedHeight(BuildContext context) {
  final mq = MediaQuery.of(context);
  final h = mq.size.height;
  final land = mq.orientation == Orientation.landscape;
  final bp = context.appBreakpoint;
  double base;
  switch (bp) {
    case AppBreakpoint.compact:
      base = context.screenWidth < 360 ? 196 : 216;
      break;
    case AppBreakpoint.medium:
      base = 248;
      break;
    case AppBreakpoint.expanded:
      base = 300;
      break;
  }
  if (land) {
    base = math.min(base, h * 0.44);
  }
  return base.clamp(168.0, 340.0);
}

double _aboutNavExtent(BuildContext context) {
  if (context.isAppExpanded) return 60;
  if (context.isAppMedium) return 56;
  return 52;
}

double _aboutSectionVGap(BuildContext context) {
  if (context.isAppExpanded) return 36;
  if (context.isAppMedium) return 28;
  return 20;
}

/// About page: collapsible hero, pinned section nav, scroll-linked highlights,
/// staggered reveals, and interactive surfaces.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());

  int _activeSection = 0;
  double _heroScroll = 0;
  /// Last built values — used by scroll listener between frames.
  double _lastExpandedHeight = 232;
  double _lastNavExtent = 56;
  Timer? _scrollSpyDebounce;

  late final AnimationController _fabPulse;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActiveSection());
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
    _scrollSpyDebounce = Timer(const Duration(milliseconds: 48), _updateActiveSection);
  }

  void _updateActiveSection() {
    if (!mounted) return;
    final ctx = context;
    final topInset = MediaQuery.paddingOf(ctx).top;
    final threshold = topInset + kToolbarHeight + _lastNavExtent + 12;

    int best = 0;
    double bestDist = double.infinity;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final box = _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final dist = (dy - threshold).abs();
      if (dy <= threshold + 40 && dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    if (best != _activeSection) {
      setState(() => _activeSection = best);
    }
  }

  Future<void> _scrollToSection(int index) async {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: context.isAppCompact ? 0.16 : (context.isAppExpanded ? 0.08 : 0.12),
    );
    if (mounted) {
      setState(() => _activeSection = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hPad = context.pageHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final expandedH = _aboutExpandedHeight(context);
    final navExt = _aboutNavExtent(context);
    final sectionGap = _aboutSectionVGap(context);
    final topContentPad = context.isAppExpanded ? 28.0 : (context.isAppMedium ? 22.0 : 16.0);
    final bottomContentPad = context.isAppExpanded ? 40.0 : 28.0;
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
                    iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                    flexibleSpace: _HeroFlexibleSpace(
                      l10n: l10n,
                      theme: theme,
                      hPad: hPad,
                      scrollOffset: _heroScroll,
                      expandedHeight: expandedH,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SectionNavDelegate(
                      extent: navExt,
                      horizontalPadding: hPad,
                      activeIndex: _activeSection,
                      theme: theme,
                      l10n: l10n,
                      onSelect: _scrollToSection,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, topContentPad, hPad, bottomContentPad),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _KeyedSection(
                          sectionKey: _sectionKeys[0],
                          child: _AnimatedSection(
                            index: 0,
                            child: _StorySection(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _KeyedSection(
                          sectionKey: _sectionKeys[1],
                          child: _AnimatedSection(
                            index: 1,
                            child: _MissionVisionRow(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _KeyedSection(
                          sectionKey: _sectionKeys[2],
                          child: _AnimatedSection(
                            index: 2,
                            child: _ValuesSection(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _KeyedSection(
                          sectionKey: _sectionKeys[3],
                          child: _AnimatedSection(
                            index: 3,
                            child: _WhySection(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _KeyedSection(
                          sectionKey: _sectionKeys[4],
                          child: _AnimatedSection(
                            index: 4,
                            child: _StatsSection(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _KeyedSection(
                          sectionKey: _sectionKeys[5],
                          child: _AnimatedSection(
                            index: 5,
                            child: _CoverageSection(l10n: l10n, theme: theme),
                          ),
                        ),
                        SizedBox(height: sectionGap * 0.75),
                      ]),
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
                    onTap: () => _scrollToSection(0),
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

class _KeyedSection extends StatelessWidget {
  const _KeyedSection({required this.sectionKey, required this.child});

  final GlobalKey sectionKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: sectionKey, child: child);
  }
}

/// Collapsing hero with parallax orbs and title.
class _HeroFlexibleSpace extends StatelessWidget {
  const _HeroFlexibleSpace({
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
    final parallax = scrollOffset * 0.35;

    return LayoutBuilder(
      builder: (context, constraints) {
        final orb1 = context.layoutScale(120).clamp(88.0, 160.0);
        final orb2 = context.layoutScale(160).clamp(110.0, 200.0);
        final bp = context.appBreakpoint;
        final heroFontSize = bp == AppBreakpoint.expanded
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
                    Color.lerp(AppColors.primary, AppColors.primaryDark, 0.5 + t * 0.25)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -30 + parallax * 0.15,
              top: 20 - parallax * 0.2,
              child: _GlowOrb(diameter: orb1, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Positioned(
              left: -40 - parallax * 0.1,
              bottom: 30 + parallax * 0.12,
              child: _GlowOrb(diameter: orb2, color: Colors.black.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, MediaQuery.paddingOf(context).top + 52, hPad, 20),
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
                        Transform.translate(
                          offset: Offset(0, t * 8),
                          child: Opacity(
                            opacity: 1 - t * 0.85,
                            child: Text(
                              l10n.aboutHero,
                              style: FontHelper.getTextStyle(
                                text: l10n.aboutHero,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: heroFontSize,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 + (1 - t) * 4),
                        Opacity(
                          opacity: (1 - t * 1.2).clamp(0.0, 1.0),
                          child: Text(
                            l10n.aboutHeroSubtitle,
                            style: FontHelper.getTextStyle(
                              text: l10n.aboutHeroSubtitle,
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
                      opacity: (t * 1.15).clamp(0.0, 1.0),
                      child: Text(
                        l10n.aboutDocumentTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: l10n.aboutDocumentTitle,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 16,
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _SectionNavDelegate extends SliverPersistentHeaderDelegate {
  _SectionNavDelegate({
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
    final iconSize = bp == AppBreakpoint.expanded ? 24.0 : (bp == AppBreakpoint.medium ? 23.0 : 21.0);
    final chipPad = bp == AppBreakpoint.expanded ? 12.0 : 10.0;
    final hScrollPad = math.max(8.0, horizontalPadding * 0.35);
    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black26,
      color: surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: Align(
          alignment: bp == AppBreakpoint.expanded ? Alignment.center : Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hScrollPad, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavChip(
                  icon: Icons.auto_stories_rounded,
                  tooltip: l10n.aboutStoryTitle,
                  selected: activeIndex == 0,
                  onTap: () => onSelect(0),
                  theme: theme,
                  iconSize: iconSize,
                  innerPadding: chipPad,
                ),
                _NavChip(
                  icon: Icons.flag_rounded,
                  tooltip: '${l10n.aboutMissionTitle} · ${l10n.aboutVisionTitle}',
                  selected: activeIndex == 1,
                  onTap: () => onSelect(1),
                  theme: theme,
                  iconSize: iconSize,
                  innerPadding: chipPad,
                ),
                _NavChip(
                  icon: Icons.workspace_premium_rounded,
                  tooltip: l10n.aboutValuesTitle,
                  selected: activeIndex == 2,
                  onTap: () => onSelect(2),
                  theme: theme,
                  iconSize: iconSize,
                  innerPadding: chipPad,
                ),
                _NavChip(
                  icon: Icons.fact_check_rounded,
                  tooltip: l10n.aboutWhyTitle,
                  selected: activeIndex == 3,
                  onTap: () => onSelect(3),
                  theme: theme,
                  iconSize: iconSize,
                  innerPadding: chipPad,
                ),
                _NavChip(
                  icon: Icons.insights_rounded,
                  tooltip: l10n.aboutStatsTitle,
                  selected: activeIndex == 4,
                  onTap: () => onSelect(4),
                  theme: theme,
                  iconSize: iconSize,
                  innerPadding: chipPad,
                ),
                _NavChip(
                  icon: Icons.map_outlined,
                  tooltip: l10n.aboutCoverageTitle,
                  selected: activeIndex == 5,
                  onTap: () => onSelect(5),
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
  bool shouldRebuild(covariant _SectionNavDelegate oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.theme != theme ||
        oldDelegate.extent != extent ||
        oldDelegate.horizontalPadding != horizontalPadding;
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? primary.withValues(alpha: 0.14) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                highlightColor: primary.withValues(alpha: 0.08),
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

/// Fade + slide in once (staggered by [index]).
class _AnimatedSection extends StatefulWidget {
  const _AnimatedSection({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
    final delay = Duration(milliseconds: 90 + widget.index * 55);
    Future<void>.delayed(delay, () {
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

class _StorySection extends StatelessWidget {
  const _StorySection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isWide = context.useNavigationRail;
    final visualH = context.layoutScale(200).clamp(160.0, 280.0);
    final emojiSize = context.layoutScale(64).clamp(48.0, 88.0);
    final story = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.restaurant_menu_rounded, text: l10n.aboutStoryTitle, theme: theme),
        const SizedBox(height: 12),
        Text(
          l10n.aboutStoryDesc,
          style: FontHelper.getTextStyle(
            text: l10n.aboutStoryDesc,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final visual = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHigh
            : AppColors.primaryContainerLight,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          child: SizedBox(
            height: visualH,
            width: double.infinity,
            child: Center(
              child: Text(
                '🍽️',
                style: FontHelper.getTextStyle(
                  text: '🍽️',
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: emojiSize,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: context.isAppExpanded ? 5 : 4, child: story),
          SizedBox(width: context.isAppCompact ? 16 : 24),
          Expanded(flex: 4, child: visual),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        story,
        SizedBox(height: context.isAppCompact ? 16 : 20),
        visual,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final iconSz = context.layoutScale(22).clamp(18.0, 28.0);
    final titleFontSize = context.isAppExpanded
            ? 24.0
            : context.isAppMedium
                ? 20.0
                : 18.0;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.layoutScale(8).clamp(6.0, 12.0)),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: iconSz, color: theme.colorScheme.primary),
        ),
        SizedBox(width: context.isAppCompact ? 10 : 12),
        Expanded(
          child: Text(
            text,
            style: FontHelper.getTextStyle(
              text: text,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MissionVisionRow extends StatelessWidget {
  const _MissionVisionRow({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isWide = !context.isAppCompact;
    final isDark = theme.brightness == Brightness.dark;
    final mission = _AccentCard(
      theme: theme,
      borderColor: const Color(0xFF2196F3),
      background: isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFE3F2FD),
      icon: Icons.rocket_launch_rounded,
      title: l10n.aboutMissionTitle,
      body: l10n.aboutMissionDesc,
    );
    final vision = _AccentCard(
      theme: theme,
      borderColor: const Color(0xFF4CAF50),
      background: isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFE8F5E9),
      icon: Icons.visibility_rounded,
      title: l10n.aboutVisionTitle,
      body: l10n.aboutVisionDesc,
    );
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: mission),
          SizedBox(width: context.isAppCompact ? 12 : 20),
          Expanded(child: vision),
        ],
      );
    }
    return Column(
      children: [
        mission,
        SizedBox(height: context.isAppCompact ? 12 : 16),
        vision,
      ],
    );
  }
}

class _AccentCard extends StatefulWidget {
  const _AccentCard({
    required this.theme,
    required this.borderColor,
    required this.background,
    required this.icon,
    required this.title,
    required this.body,
  });

  final ThemeData theme;
  final Color borderColor;
  final Color background;
  final IconData icon;
  final String title;
  final String body;

  @override
  State<_AccentCard> createState() => _AccentCardState();
}

class _AccentCardState extends State<_AccentCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final pad = context.isAppExpanded ? 24.0 : (context.isAppMedium ? 22.0 : 16.0);
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: widget.background,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () {},
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(18),
          splashColor: widget.borderColor.withValues(alpha: 0.15),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border(left: BorderSide(color: widget.borderColor, width: 4)),
            ),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, color: widget.borderColor, size: 26),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: FontHelper.getTextStyle(
                      text: widget.title,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.body,
                    style: FontHelper.getTextStyle(
                      text: widget.body,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: widget.theme.colorScheme.onSurfaceVariant,
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
}

class _ValuesSection extends StatelessWidget {
  const _ValuesSection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cross = context.gridCrossAxisCount(compact: 1, medium: 2, expanded: 4);
    final spacing = context.isAppCompact ? 12.0 : 16.0;
    final minTile = context.isAppCompact ? 128.0 : 156.0;
    final items = [
      ('🎯', AppColors.primary, l10n.aboutValue1Title, l10n.aboutValue1Desc),
      ('⭐', const Color(0xFF2196F3), l10n.aboutValue2Title, l10n.aboutValue2Desc),
      ('🤝', const Color(0xFF4CAF50), l10n.aboutValue3Title, l10n.aboutValue3Desc),
      ('🚀', const Color(0xFFFF9800), l10n.aboutValue4Title, l10n.aboutValue4Desc),
    ];

    return Column(
      children: [
        _SectionTitle(icon: Icons.diamond_rounded, text: l10n.aboutValuesTitle, theme: theme),
        SizedBox(height: context.isAppCompact ? 16 : 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final raw = (constraints.maxWidth - spacing * (cross - 1)) / math.max(cross, 1);
            final tileW = cross <= 1 ? constraints.maxWidth : raw.clamp(minTile, 520.0);
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                    width: tileW,
                    child: _ValueTile(
                      theme: theme,
                      index: i,
                      emoji: items[i].$1,
                      topColor: items[i].$2,
                      title: items[i].$3,
                      desc: items[i].$4,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ValueTile extends StatefulWidget {
  const _ValueTile({
    required this.theme,
    required this.index,
    required this.emoji,
    required this.topColor,
    required this.title,
    required this.desc,
  });

  final ThemeData theme;
  final int index;
  final String emoji;
  final Color topColor;
  final String title;
  final String desc;

  @override
  State<_ValueTile> createState() => _ValueTileState();
}

class _ValueTileState extends State<_ValueTile> with SingleTickerProviderStateMixin {
  late final AnimationController _hover;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: AnimatedBuilder(
        animation: _hover,
        builder: (context, child) {
            final v = _hover.value;
            final y = -2.0 * v;
            final scale = 1 + 0.012 * v;
            return Transform.translate(
              offset: Offset(0, y),
              child: Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 2 + 4 * v,
                  shadowColor: widget.topColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  color: widget.theme.colorScheme.surface,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    splashColor: widget.topColor.withValues(alpha: 0.12),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.layoutScale(18).clamp(14.0, 22.0)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border(top: BorderSide(color: widget.topColor, width: 4)),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.emoji,
              style: FontHelper.getTextStyle(
                text: widget.emoji,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 34.0,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: FontHelper.getTextStyle(
                text: widget.title,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.desc,
              style: FontHelper.getTextStyle(
                text: widget.desc,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhySection extends StatelessWidget {
  const _WhySection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final points = [
      l10n.aboutWhy1,
      l10n.aboutWhy2,
      l10n.aboutWhy3,
      l10n.aboutWhy4,
      l10n.aboutWhy5,
      l10n.aboutWhy6,
    ];
    final isWide = !context.isAppCompact;

    return Column(
      children: [
        _SectionTitle(icon: Icons.fact_check_rounded, text: l10n.aboutWhyTitle, theme: theme),
        SizedBox(height: context.isAppCompact ? 16 : 20),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      _WhyRow(theme: theme, text: points[i], delayMs: i * 60),
                  ],
                ),
              ),
              SizedBox(width: context.isAppMedium ? 20 : 16),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 3; i < 6; i++)
                      _WhyRow(theme: theme, text: points[i], delayMs: i * 60),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < points.length; i++)
                _WhyRow(theme: theme, text: points[i], delayMs: i * 50),
            ],
          ),
      ],
    );
  }
}

class _WhyRow extends StatefulWidget {
  const _WhyRow({required this.theme, required this.text, required this.delayMs});

  final ThemeData theme;
  final String text;
  final int delayMs;

  @override
  State<_WhyRow> createState() => _WhyRowState();
}

class _WhyRowState extends State<_WhyRow> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
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
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.04, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: context.isAppCompact ? 8 : 10),
          child: Material(
            color: widget.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.layoutScale(14).clamp(12.0, 20.0),
                  vertical: context.isAppCompact ? 10 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: context.layoutScale(22).clamp(20.0, 26.0),
                      color: AppColors.primary,
                    ),
                    SizedBox(width: context.isAppCompact ? 10 : 12),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: FontHelper.getTextStyle(
                          text: widget.text,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.colorScheme.onSurface,
                        ),
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

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (l10n.aboutStat1Num, l10n.aboutStat1Label, AppColors.primary),
      (l10n.aboutStat2Num, l10n.aboutStat2Label, const Color(0xFF1976D2)),
      (l10n.aboutStat3Num, l10n.aboutStat3Label, const Color(0xFF388E3C)),
      (l10n.aboutStat4Num, l10n.aboutStat4Label, const Color(0xFFF57C00)),
    ];
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        _SectionTitle(icon: Icons.insights_rounded, text: l10n.aboutStatsTitle, theme: theme),
        SizedBox(height: context.isAppCompact ? 12 : 16),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHigh,
                      theme.colorScheme.surfaceContainerHighest,
                    ]
                  : [
                      AppColors.primaryContainerLight,
                      const Color(0xFFE3F2FD),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.isAppExpanded ? 32 : (context.isAppMedium ? 28 : 22),
              horizontal: context.isAppCompact ? 8 : 12,
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                final use4 = c.maxWidth >= 520 && !context.isAppCompact;
                if (use4) {
                  return Row(
                    children: [
                      for (var i = 0; i < stats.length; i++)
                        Expanded(
                          child: _StatCell(
                            numText: stats[i].$1,
                            label: stats[i].$2,
                            color: stats[i].$3,
                            theme: theme,
                            index: i,
                          ),
                        ),
                    ],
                  );
                }
                final gap = context.isAppCompact ? 10.0 : 12.0;
                return Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: gap,
                  runSpacing: context.isAppCompact ? 16 : 20,
                  children: [
                    for (var i = 0; i < stats.length; i++)
                      SizedBox(
                        width: (c.maxWidth - gap) / 2,
                        child: _StatCell(
                          numText: stats[i].$1,
                          label: stats[i].$2,
                          color: stats[i].$3,
                          theme: theme,
                          index: i,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatefulWidget {
  const _StatCell({
    required this.numText,
    required this.label,
    required this.color,
    required this.theme,
    required this.index,
  });

  final String numText;
  final String label;
  final Color color;
  final ThemeData theme;
  final int index;

  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future<void>.delayed(Duration(milliseconds: 120 + widget.index * 100), () {
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
    final t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    final numSize = context.layoutScale(36).clamp(26.0, 44.0);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.86 + 0.14 * t.value,
          child: Opacity(opacity: t.value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Column(
        children: [
          Text(
            widget.numText,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: widget.numText,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: numSize,
              fontWeight: FontWeight.w900,
              color: widget.color,
            ),
          ),
          SizedBox(height: context.isAppCompact ? 4 : 6),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: widget.label,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: context.isAppCompact ? 12.5 : 14.0,
              fontWeight: FontWeight.w600,
              color: widget.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageSection extends StatelessWidget {
  const _CoverageSection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(icon: Icons.public_rounded, text: l10n.aboutCoverageTitle, theme: theme),
        const SizedBox(height: 16),
        Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(18),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: theme.colorScheme.primary,
                    size: context.layoutScale(28).clamp(24.0, 34.0),
                  ),
                  SizedBox(width: context.isAppCompact ? 12 : 14),
                  Expanded(
                    child: Text(
                      l10n.aboutCoverageDesc,
                      style: FontHelper.getTextStyle(
                        text: l10n.aboutCoverageDesc,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
