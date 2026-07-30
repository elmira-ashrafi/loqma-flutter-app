import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Public contact details + form (mirrors web contact page). Form opens email client
/// with a prefilled message (web POST `/contact` requires CSRF).
abstract final class _ContactLinks {
  static const officePhone = '0202250507';
  static const mobilePhone = '0711042119';
  static const emailInfo = 'info@afghanfood.af';
  static const emailSupport = 'support@afghanfood.af';
}

double _contactExpandedHeight(BuildContext context) {
  final mq = MediaQuery.of(context);
  final h = mq.size.height;
  final land = mq.orientation == Orientation.landscape;
  final bp = context.appBreakpoint;
  double base;
  switch (bp) {
    case AppBreakpoint.compact:
      base = context.screenWidth < 360 ? 188 : 208;
      break;
    case AppBreakpoint.medium:
      base = 236;
      break;
    case AppBreakpoint.expanded:
      base = 288;
      break;
  }
  if (land) {
    base = math.min(base, h * 0.42);
  }
  return base.clamp(160.0, 320.0);
}

double _contactNavExtent(BuildContext context) {
  if (context.isAppExpanded) return 58;
  if (context.isAppMedium) return 54;
  return 50;
}

double _contactSectionVGap(BuildContext context) {
  if (context.isAppExpanded) return 32;
  if (context.isAppMedium) return 24;
  return 18;
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String? _subjectValue;
  bool _submitting = false;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _keyReach = GlobalKey();
  final GlobalKey _keyForm = GlobalKey();
  final GlobalKey _keyFaq = GlobalKey();
  final GlobalKey _keyOverview = GlobalKey();

  int _activeNav = 0;
  double _heroScroll = 0;
  double _lastExpandedHeight = 220;
  double _lastNavExtent = 54;
  Timer? _scrollSpyDebounce;
  late final AnimationController _fabPulse;
  double? _layoutWidth;

  static const _subjectKeys = <String>[
    'general',
    'customer_support',
    'restaurant_inquiry',
    'driver_inquiry',
    'complaint',
    'feedback',
    'other',
  ];

  bool get _isWide => context.screenWidth >= 900;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateNavFromScroll();
      });
    }
    _layoutWidth = w;
  }

  @override
  void dispose() {
    _scrollSpyDebounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _fabPulse.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
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
    final ctx = context;
    final topInset = MediaQuery.paddingOf(ctx).top;
    final threshold = topInset + kToolbarHeight + _lastNavExtent + 12;

    int best = 0;
    if (_isWide) {
      final faqBox = _keyFaq.currentContext?.findRenderObject() as RenderBox?;
      if (faqBox != null && faqBox.attached) {
        final dy = faqBox.localToGlobal(Offset.zero).dy;
        if (dy <= threshold + 52) best = 1;
      }
    } else {
      var bestDist = double.infinity;
      final keys = [_keyReach, _keyForm, _keyFaq];
      for (var i = 0; i < keys.length; i++) {
        final box = keys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.attached) continue;
        final dy = box.localToGlobal(Offset.zero).dy;
        final dist = (dy - threshold).abs();
        if (dy <= threshold + 40 && dist < bestDist) {
          bestDist = dist;
          best = i;
        }
      }
    }
    if (best != _activeNav) {
      setState(() => _activeNav = best);
    }
  }

  Future<void> _scrollToNav(int index) async {
    final wide = _isWide;
    final BuildContext? targetCtx = wide
        ? (index == 0 ? _keyOverview.currentContext : _keyFaq.currentContext)
        : ([_keyReach, _keyForm, _keyFaq][index]).currentContext;
    if (targetCtx == null) return;
    await Scrollable.ensureVisible(
      targetCtx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: context.isAppCompact ? 0.14 : (context.isAppExpanded ? 0.06 : 0.1),
    );
    if (mounted) {
      setState(() => _activeNav = index);
    }
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

  String _subjectLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'general':
        return l10n.contactFormSubjectGeneral;
      case 'customer_support':
        return l10n.contactFormSubjectSupport;
      case 'restaurant_inquiry':
        return l10n.contactFormSubjectPartnership;
      case 'driver_inquiry':
        return l10n.contactFormSubjectDriver;
      case 'complaint':
        return l10n.contactFormSubjectComplaint;
      case 'feedback':
        return l10n.contactFormSubjectFeedback;
      case 'other':
        return l10n.contactFormSubjectOther;
      default:
        return key;
    }
  }

  Future<void> _launchTel(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectValue == null || _subjectValue!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactFormSubjectError)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final subLabel = _subjectLabel(l10n, _subjectValue!);
      final body = '''
${l10n.contactFormName}: ${_nameCtrl.text.trim()}
${l10n.contactFormEmail}: ${_emailCtrl.text.trim()}
${l10n.contactFormPhone}: ${_phoneCtrl.text.trim()}
${l10n.contactFormSubject}: $subLabel (${_subjectValue!})

${_messageCtrl.text.trim()}
''';
      final uri = Uri(
        scheme: 'mailto',
        path: _ContactLinks.emailSupport,
        queryParameters: {
          'subject': '${l10n.contactEmailSubjectPrefix}: $subLabel',
          'body': body,
        },
      );
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactFormSuccessSnackbar)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hPad = context.pageHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final expandedH = _contactExpandedHeight(context);
    final navExt = _contactNavExtent(context);
    final sectionGap = _contactSectionVGap(context);
    final topContentPad = context.isAppExpanded ? 26.0 : (context.isAppMedium ? 20.0 : 14.0);
    final bottomContentPad = context.isAppExpanded ? 40.0 : 28.0;
    _lastExpandedHeight = expandedH;
    _lastNavExtent = navExt;

    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.82,
      maxScaleFactor: 1.28,
    );

    final isWide = _isWide;

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
                    flexibleSpace: _ContactHeroFlexibleSpace(
                      l10n: l10n,
                      theme: theme,
                      hPad: hPad,
                      scrollOffset: _heroScroll,
                      expandedHeight: expandedH,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ContactNavDelegate(
                      extent: navExt,
                      horizontalPadding: hPad,
                      activeIndex: _activeNav,
                      isWide: isWide,
                      theme: theme,
                      l10n: l10n,
                      onSelect: _scrollToNav,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, topContentPad, hPad, bottomContentPad),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (isWide) ...[
                          _KeyedSection(
                            sectionKey: _keyOverview,
                            child: _ContactAnimatedSection(
                              index: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 340,
                                    child: _ContactSidebar(
                                      l10n: l10n,
                                      theme: theme,
                                      onTel: _launchTel,
                                      onMail: _launchMail,
                                    ),
                                  ),
                                  SizedBox(width: context.isAppExpanded ? 28 : 22),
                                  Expanded(
                                    child: _ContactFormCard(
                                      l10n: l10n,
                                      theme: theme,
                                      state: this,
                                      onSubjectChanged: (v) => setState(() => _subjectValue = v),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          _KeyedSection(
                            sectionKey: _keyFaq,
                            child: _ContactAnimatedSection(
                              index: 1,
                              child: _ContactFaqSection(l10n: l10n, theme: theme, baseIndex: 2),
                            ),
                          ),
                        ] else ...[
                          _KeyedSection(
                            sectionKey: _keyReach,
                            child: _ContactAnimatedSection(
                              index: 0,
                              child: _ContactSidebar(
                                l10n: l10n,
                                theme: theme,
                                onTel: _launchTel,
                                onMail: _launchMail,
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          _KeyedSection(
                            sectionKey: _keyForm,
                            child: _ContactAnimatedSection(
                              index: 1,
                              child: _ContactFormCard(
                                l10n: l10n,
                                theme: theme,
                                state: this,
                                onSubjectChanged: (v) => setState(() => _subjectValue = v),
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          _KeyedSection(
                            sectionKey: _keyFaq,
                            child: _ContactAnimatedSection(
                              index: 2,
                              child: _ContactFaqSection(l10n: l10n, theme: theme, baseIndex: 3),
                            ),
                          ),
                        ],
                        SizedBox(height: sectionGap * 0.5),
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

class _KeyedSection extends StatelessWidget {
  const _KeyedSection({required this.sectionKey, required this.child});

  final GlobalKey sectionKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: sectionKey, child: child);
  }
}

/// Fade + slide in once (staggered by [index]).
class _ContactAnimatedSection extends StatefulWidget {
  const _ContactAnimatedSection({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_ContactAnimatedSection> createState() => _ContactAnimatedSectionState();
}

class _ContactAnimatedSectionState extends State<_ContactAnimatedSection> with SingleTickerProviderStateMixin {
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

class _ContactHeroFlexibleSpace extends StatelessWidget {
  const _ContactHeroFlexibleSpace({
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
        final orb1 = context.layoutScale(118).clamp(86.0, 158.0);
        final orb2 = context.layoutScale(156).clamp(108.0, 198.0);
        final bp = context.appBreakpoint;
        final heroStyle = (bp == AppBreakpoint.expanded
                ? theme.textTheme.headlineLarge
                : bp == AppBreakpoint.medium
                    ? theme.textTheme.headlineMedium
                    : theme.textTheme.headlineSmall)
            ?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -0.5,
            );
        final subStyle = (bp == AppBreakpoint.compact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
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
                    Color.lerp(AppColors.primaryLight, AppColors.primaryDark, t * 0.35)!,
                    Color.lerp(AppColors.primary, AppColors.primaryDark, 0.5 + t * 0.25)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -28 + parallax * 0.15,
              top: 18 - parallax * 0.2,
              child: _GlowOrb(diameter: orb1, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Positioned(
              left: -38 - parallax * 0.1,
              bottom: 28 + parallax * 0.12,
              child: _GlowOrb(diameter: orb2, color: Colors.black.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, MediaQuery.paddingOf(context).top + 52, hPad, 18),
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
                              l10n.contactHero,
                              style: heroStyle,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 + (1 - t) * 4),
                        Opacity(
                          opacity: (1 - t * 1.2).clamp(0.0, 1.0),
                          child: Text(
                            l10n.contactSubtitle,
                            style: subStyle,
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
                        l10n.contactDocumentTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
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

class _ContactNavDelegate extends SliverPersistentHeaderDelegate {
  _ContactNavDelegate({
    required this.extent,
    required this.horizontalPadding,
    required this.activeIndex,
    required this.isWide,
    required this.theme,
    required this.l10n,
    required this.onSelect,
  });

  final double extent;
  final double horizontalPadding;
  final int activeIndex;
  final bool isWide;
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

    final entries = isWide
        ? <({IconData icon, String tooltip, int index})>[
            (icon: Icons.maps_home_work_rounded, tooltip: l10n.contactNavOverviewTooltip, index: 0),
            (icon: Icons.quiz_outlined, tooltip: l10n.contactNavFaqTooltip, index: 1),
          ]
        : [
            (icon: Icons.contact_phone_rounded, tooltip: l10n.contactNavReachTooltip, index: 0),
            (icon: Icons.edit_note_rounded, tooltip: l10n.contactNavFormTooltip, index: 1),
            (icon: Icons.help_outline_rounded, tooltip: l10n.contactNavFaqTooltip, index: 2),
          ];

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
                for (final e in entries)
                  _ContactNavChip(
                    icon: e.icon,
                    tooltip: e.tooltip,
                    selected: activeIndex == e.index,
                    onTap: () => onSelect(e.index),
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
  bool shouldRebuild(covariant _ContactNavDelegate oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.theme != theme ||
        oldDelegate.extent != extent ||
        oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.isWide != isWide ||
        oldDelegate.l10n != l10n;
  }
}

class _ContactNavChip extends StatelessWidget {
  const _ContactNavChip({
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

class _ContactSidebar extends StatelessWidget {
  const _ContactSidebar({
    required this.l10n,
    required this.theme,
    required this.onTel,
    required this.onMail,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final Future<void> Function(String) onTel;
  final Future<void> Function(String) onMail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          theme: theme,
          borderColor: AppColors.primary,
          icon: Icons.phone_in_talk_rounded,
          iconColor: AppColors.primary,
          title: l10n.contactCallTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.contactCallOffice, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              _LinkText(text: _ContactLinks.officePhone, onTap: () => onTel(_ContactLinks.officePhone)),
              const SizedBox(height: 12),
              Text(l10n.contactCallMobile, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              _LinkText(text: _ContactLinks.mobilePhone, onTap: () => onTel(_ContactLinks.mobilePhone)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          theme: theme,
          borderColor: const Color(0xFF2196F3),
          icon: Icons.mail_outline_rounded,
          iconColor: const Color(0xFF2196F3),
          title: l10n.contactEmailTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.contactEmailGeneral, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              _LinkText(text: _ContactLinks.emailInfo, onTap: () => onMail(_ContactLinks.emailInfo)),
              const SizedBox(height: 12),
              Text(l10n.contactEmailSupport, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              _LinkText(text: _ContactLinks.emailSupport, onTap: () => onMail(_ContactLinks.emailSupport)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          theme: theme,
          borderColor: const Color(0xFF4CAF50),
          icon: Icons.location_on_outlined,
          iconColor: const Color(0xFF4CAF50),
          title: l10n.contactVisitTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.contactVisitMazarLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(l10n.contactVisitMazarBody, style: theme.textTheme.bodySmall?.copyWith(height: 1.45)),
              Divider(height: 24, color: theme.colorScheme.outlineVariant),
              Text(l10n.contactVisitKabulLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(l10n.contactVisitKabulBody, style: theme.textTheme.bodySmall?.copyWith(height: 1.45)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          theme: theme,
          borderColor: const Color(0xFFFF9800),
          icon: Icons.share_rounded,
          iconColor: const Color(0xFFFF9800),
          title: l10n.contactFollowTitle,
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _SocialChip(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), label: 'Facebook'),
              _SocialChip(icon: Icons.chat_bubble_outline_rounded, color: const Color(0xFF1DA1F2), label: 'X'),
              _SocialChip(icon: Icons.camera_alt_outlined, color: const Color(0xFFE4405F), label: 'Instagram'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _HoursPanel(l10n: l10n, theme: theme),
      ],
    );
  }
}

class _HoursPanel extends StatelessWidget {
  const _HoursPanel({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHigh
                    : const Color(0xFFE3F2FD),
                theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHighest
                    : const Color(0xFFF5F9FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.outlineVariant
                  : const Color(0xFF90CAF9).withValues(alpha: 0.65),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.contactHoursTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(l10n.contactHoursDays, style: theme.textTheme.bodySmall)),
                    Text(l10n.contactHoursTime, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.contactHoursNote,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.theme,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final ThemeData theme;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(16),
        splashColor: borderColor.withValues(alpha: 0.12),
        highlightColor: borderColor.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      child,
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

class _LinkText extends StatelessWidget {
  const _LinkText({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: text,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: color,
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.contactSocialSoon)),
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ContactFormCard extends StatelessWidget {
  const _ContactFormCard({
    required this.l10n,
    required this.theme,
    required this.state,
    required this.onSubjectChanged,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final _ContactScreenState state;
  final ValueChanged<String?> onSubjectChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(context.isAppCompact ? 16 : 24),
        child: Form(
          key: state._formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.draw_rounded, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.contactFormTitle,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: state._nameCtrl,
                decoration: InputDecoration(labelText: l10n.contactFormName, border: const OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.contactFormRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: state._emailCtrl,
                decoration: InputDecoration(labelText: l10n.contactFormEmail, border: const OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.contactFormRequired;
                  if (!v.contains('@')) return l10n.contactFormEmailInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: state._phoneCtrl,
                decoration: InputDecoration(labelText: l10n.contactFormPhone, border: const OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.contactFormRequired : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: state._subjectValue, // ignore: deprecated_member_use
                hint: Text(l10n.contactFormSubjectHint),
                decoration: InputDecoration(labelText: l10n.contactFormSubject, border: const OutlineInputBorder()),
                items: [
                  for (final k in _ContactScreenState._subjectKeys)
                    DropdownMenuItem(value: k, child: Text(state._subjectLabel(l10n, k))),
                ],
                onChanged: onSubjectChanged,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: state._messageCtrl,
                decoration: InputDecoration(
                  labelText: l10n.contactFormMessage,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 6,
                maxLength: 5000,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.contactFormRequired : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: state._submitting ? null : () => state._submit(l10n),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state._submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(l10n.contactFormSubmit),
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

class _ContactFaqSection extends StatelessWidget {
  const _ContactFaqSection({
    required this.l10n,
    required this.theme,
    required this.baseIndex,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  /// Stagger delay index base for each FAQ row.
  final int baseIndex;

  @override
  Widget build(BuildContext context) {
    final items = [
      (l10n.contactFaq1Q, l10n.contactFaq1A),
      (l10n.contactFaq2Q, l10n.contactFaq2A),
      (l10n.contactFaq3Q, l10n.contactFaq3A),
      (l10n.contactFaq4Q, l10n.contactFaq4A),
      (l10n.contactFaq5Q, l10n.contactFaq5A),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactAnimatedSection(
          index: baseIndex,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      l10n.contactFaqTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ContactAnimatedSection(
              index: baseIndex + 1 + i,
              child: Material(
                elevation: 2,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                color: theme.colorScheme.surface,
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    title: Text(
                      items[i].$1,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Text(items[i].$2, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
