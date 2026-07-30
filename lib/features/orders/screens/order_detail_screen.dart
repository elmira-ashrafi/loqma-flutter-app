import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_review_screen.dart';
import 'order_cancel_screen.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/phone_display.dart';
import '../../../core/controllers/locale_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../order_track_shared.dart';
import '../orders_l10n.dart';
import '../../../core/widgets/app_page_loading.dart';
import '../../../l10n/app_localizations.dart';

abstract final class _DetailPalette {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color sectionLabel = Color(0xFF1A237E);
  static const Color muted = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFEEEEEE);

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.18),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }
}

/// Beautiful, animated Order Details screen — responsive two-column layout for web.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  final int orderId;
  final OrderModel? initialOrder;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  OrderModel? _order;
  bool _loading = true;
  bool _loadingDetails = false;
  bool _loadFailed = false;
  bool _fetchedFull = false;
  Worker? _localeWorker;
  Timer? _statusPollTimer;

  late final AnimationController _entranceController;
  late final List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) _loadOrder(force: true);
      });
    }
    _order = widget.initialOrder;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceController.forward();
    _cardAnimations = List.generate(8, (i) {
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          (i * 0.08).clamp(0.0, 0.85),
          (0.3 + i * 0.08).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
    _loadOrder();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _pollOrderStatus());
  }

  Future<void> _pollOrderStatus() async {
    if (_order != null && _isDelivered(_order!.status)) {
      _statusPollTimer?.cancel();
      return;
    }
    await _loadOrder(force: true);
    if (_order != null && _isDelivered(_order!.status)) {
      _statusPollTimer?.cancel();
    }
  }

  Future<void> _loadOrder({bool force = false}) async {
    if (!force &&
        _fetchedFull &&
        _order != null &&
        _order!.items != null &&
        _order!.items!.isNotEmpty) {
      setState(() {
        _loading = false;
        _loadingDetails = false;
      });
      return;
    }

    final previous = _order ?? widget.initialOrder;
    final hasPartial = previous != null;
    setState(() {
      // Keep existing content visible on refresh; only show full-screen loader
      // when we have nothing to display yet.
      _loading = !hasPartial;
      _loadingDetails = hasPartial;
      if (!hasPartial) _loadFailed = false;
    });

    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    final order = await ctrl.getOrderById(widget.orderId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingDetails = false;
      if (order != null) {
        _order = order;
        _fetchedFull = true;
        _loadFailed = false;
      } else if (previous != null) {
        // Network/API blip: keep what we already showed instead of error flash.
        _order = previous;
        _loadFailed = false;
      } else {
        _order = null;
        _loadFailed = true;
      }
    });
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _localeWorker?.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String _displayOrderNumber(BuildContext context, AppLocalizations l10n) {
    if (_order != null) {
      return OrdersL10n.orderNumberLabel(context, l10n, _order!);
    }
    return OrdersL10n.orderNumberLabelForId(context, l10n, widget.orderId);
  }

  String _displayOrderName(BuildContext context, AppLocalizations l10n) {
    if (_order != null) {
      return OrdersL10n.restaurantTitle(context, l10n, _order!);
    }
    return l10n.orders;
  }

  static bool _isDelivered(String status) => status.toLowerCase() == 'delivered';

  bool _compactW(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  bool _narrowW(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  double _cardGap(BuildContext context) => _compactW(context) ? 6.0 : 8.0;
  double _cardInnerPad(BuildContext context) => _compactW(context) ? 10.0 : 12.0;
  double _cardRadius(BuildContext context) => _compactW(context) ? 12.0 : 14.0;
  double _thumbSize(BuildContext context) => _narrowW(context) ? 40.0 : (_compactW(context) ? 44.0 : 48.0);


  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(_cardRadius(context)),
      border: Border.all(
        color: _DetailPalette.border.withValues(
          alpha: Theme.of(context).brightness == Brightness.light ? 0.85 : 0.35,
        ),
      ),
      boxShadow: _DetailPalette.cardShadow(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final _ = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>().localeRx.value
        : null;
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 800;
    final hPad = isWide ? 48.0 : context.pageHorizontalPadding;
    final compact = _compactW(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final pageBg = isLight ? _DetailPalette.pageBackground : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: pageBg,
      body: MaxWidthBody(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildAppBar(context),
            if (_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: AppPageLoading(
                    size: compact ? 36 : 44,
                  ),
                ),
              )
            else if (_loadFailed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: _narrowW(context) ? 52 : (compact ? 58 : 64),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        l10n.orderDetailLoadError,
                        textAlign: TextAlign.center,
                        style: FontHelper.getTextStyle(
                          text: l10n.orderDetailLoadError,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: compact ? 15.0 : 16.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      TextButton.icon(
                        onPressed: _loadOrder,
                        icon: Icon(Icons.refresh_rounded, size: compact ? 20 : 24),
                        label: Text(
                          l10n.retry,
                          style: FontHelper.getTextStyle(
                            text: l10n.retry,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  compact ? 6 : 10,
                  hPad,
                  (compact ? 12 : 16) + bottomInset,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    if (isWide) {
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTwoColumnLayout(context),
                        ]),
                      );
                    }
                    return _buildSingleColumnLayout(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = _compactW(context);
    final hPad = context.pageHorizontalPadding;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final orderName = _displayOrderName(context, l10n);
    final orderNumber = _displayOrderNumber(context, l10n);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? _DetailPalette.pageBackground
          : Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: compact ? 58 : 64,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Row(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: compact ? 36 : 40,
                  height: compact ? 36 : 40,
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: compact ? 22 : 24,
                    color: _DetailPalette.sectionLabel,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    orderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: FontHelper.getTextStyle(
                      text: orderName,
                      languageCode: languageCode,
                      fontSize: compact ? 14.5 : 15.5,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    orderNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: FontHelper.getTextStyle(
                      text: orderNumber,
                      languageCode: languageCode,
                      fontSize: compact ? 11.5 : 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 36 : 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOrderHeaderCard(context, 0),
                  SizedBox(height: _cardGap(context)),
                  _buildRestaurantCard(context, 1),
                  SizedBox(height: _cardGap(context)),
                  _buildOrderItemsCard(context, 2),
                  SizedBox(height: _cardGap(context)),
                  _buildTimelineCard(context, 3),
                ],
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDeliveryCard(context, 4),
                  SizedBox(height: _cardGap(context)),
                  _buildPaymentCard(context, 5),
                  if (_order != null) ...[
                    SizedBox(height: _cardGap(context)),
                    _buildOrderActionsCard(context, 6),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildOrderHeaderCard(context, 0),
        SizedBox(height: _cardGap(context)),
        _buildRestaurantCard(context, 1),
        SizedBox(height: _cardGap(context)),
        _buildOrderItemsCard(context, 2),
        SizedBox(height: _cardGap(context)),
        _buildTimelineCard(context, 3),
        SizedBox(height: _cardGap(context)),
        _buildDeliveryCard(context, 4),
        SizedBox(height: _cardGap(context)),
        _buildPaymentCard(context, 5),
        if (_order != null) ...[
          SizedBox(height: _cardGap(context)),
          _buildOrderActionsCard(context, 6),
        ],
        const SizedBox(height: 4),
      ]),
    );
  }

  Widget _buildOrderActionsCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final delivered = _isDelivered(order.status);
    final canCancel = order.canBeCancelledByCustomer;
    if (!delivered && !canCancel) return const SizedBox.shrink();
    return _animatedCard(
      animIndex,
      Container(
        decoration: _cardDecoration(context),
        padding: EdgeInsets.all(_cardInnerPad(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              if (delivered) ...[
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderReviewScreen(
                          orderId: order.id,
                          order: order,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.star_rounded, size: _compactW(context) ? 16 : 18),
                  label: Text(
                    l10n.leaveAReview,
                    style: FontHelper.getTextStyle(
                      text: l10n.leaveAReview,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    padding: EdgeInsets.symmetric(vertical: _compactW(context) ? 10 : 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.browseToReorderFromRestaurant,
                          style: FontHelper.getTextStyle(
                            text: l10n.browseToReorderFromRestaurant,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.replay_rounded, size: _compactW(context) ? 16 : 18),
                  label: Text(
                    l10n.reorder,
                    style: FontHelper.getTextStyle(
                      text: l10n.reorder,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: _compactW(context) ? 10 : 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
              if (canCancel) ...[
                if (delivered) const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderCancelScreen(order: order),
                      ),
                    );
                  },
                  icon: Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                  label: Text(
                    l10n.cancelOrderAction,
                    style: FontHelper.getTextStyle(
                      text: l10n.cancelOrderAction,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
    );
  }

  Widget _animatedCard(int index, Widget child) {
    if (index >= _cardAnimations.length) return child;
    final anim = _cardAnimations[index];
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - anim.value)),
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildOrderHeaderCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final compact = _compactW(context);
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final orderName = _displayOrderName(context, l10n);
    final orderNumber = _displayOrderNumber(context, l10n);
    final placedAt = OrdersL10n.formatOrderDateTime(context, order.placedAt);

    return _animatedCard(
      animIndex,
      Container(
        decoration: _cardDecoration(context),
        padding: EdgeInsets.all(_cardInnerPad(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placedAt,
                        style: FontHelper.getTextStyle(
                          text: placedAt,
                          languageCode: languageCode,
                          fontSize: compact ? 11.5 : 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Hero(
                        tag: 'order_${order.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            orderName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: orderName,
                              languageCode: languageCode,
                              fontSize: compact ? 16 : 17,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: orderNumber,
                          languageCode: languageCode,
                          fontSize: compact ? 12.5 : 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: order.status, compact: compact),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final logo = order.restaurantImage;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    final thumb = _thumbSize(context);

    return _animatedCard(
      animIndex,
      _SectionCard(
        title: l10n.restaurantSectionTitle,
        compact: _compactW(context),
        radius: _cardRadius(context),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: logo != null && logo.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: logo.startsWith('http') ? logo : '$base$logo',
                        width: thumb,
                        height: thumb,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholderBox(thumb),
                        errorWidget: (_, __, ___) => _placeholderBox(thumb),
                      )
                    : _placeholderBox(thumb),
              ),
              SizedBox(width: _compactW(context) ? 8 : 10),
              Expanded(
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OrdersL10n.restaurantTitle(context, l10n, order),
                        style: FontHelper.getTextStyle(
                          text: OrdersL10n.restaurantTitle(context, l10n, order),
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: _compactW(context) ? 14.0 : 15.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (order.restaurantPhone != null && order.restaurantPhone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            displayAfghanLocalPhone(order.restaurantPhone),
                            style: FontHelper.getTextStyle(
                              text: displayAfghanLocalPhone(order.restaurantPhone),
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 11.0,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox(double size) {
    return Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Icon(Icons.restaurant_rounded, size: size * 0.42, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final items = order.items ?? [];

    final thumb = _thumbSize(context);
    final w = MediaQuery.sizeOf(context).width;

    return _animatedCard(
      animIndex,
      _SectionCard(
        title: l10n.orderItemsTitle,
        compact: _compactW(context),
        radius: _cardRadius(context),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _loadingDetails
                    ? Center(
                        child: SizedBox(
                          width: _compactW(context) ? 28 : 32,
                          height: _compactW(context) ? 28 : 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Text(
                        l10n.noItemsInOrder,
                        style: FontHelper.getTextStyle(
                          text: l10n.noItemsInOrder,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final itemName = OrdersL10n.itemDisplayName(context, item);
                  final itemDesc = OrdersL10n.itemDisplayDescription(context, item);
                  final img = OrderModel.resolveMediaUrl(item.imageUrl);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: _compactW(context) ? 5 : 6),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: img != null && img.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: img,
                                  width: thumb,
                                  height: thumb,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => _placeholderBox(thumb),
                                  errorWidget: (_, __, ___) => _placeholderBox(thumb),
                                )
                              : _placeholderBox(thumb),
                        ),
                        SizedBox(width: _compactW(context) ? 8 : 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: FontHelper.getTextStyle(
                                  text: itemName,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: _compactW(context) ? 13.0 : 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (itemDesc != null && itemDesc.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  itemDesc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontHelper.getTextStyle(
                                    text: itemDesc,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: _compactW(context) ? 11.0 : 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                OrdersL10n.itemQtyPriceLine(context, l10n, item.quantity, item.unitPrice),
                                style: FontHelper.getTextStyle(
                                  text: OrdersL10n.itemQtyPriceLine(context, l10n, item.quantity, item.unitPrice),
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: _compactW(context) ? 11.0 : 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: w * (_compactW(context) ? 0.3 : 0.26),
                          ),
                          child: Text(
                            AppCurrency.formatLocalized(context, item.lineTotal, decimalDigits: 0),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: AppCurrency.formatLocalized(context, item.lineTotal, decimalDigits: 0),
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: _compactW(context) ? 12.0 : 13.0,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final compact = _compactW(context);
    final steps = order.timeline.isNotEmpty
        ? order.timeline
        : [
            OrderStatusStep(
              status: order.status,
              label: OrdersL10n.timelineStatusLabel(context, order.status),
              completedAt: order.placedAt,
              isCompleted: false,
            ),
          ];

    return _animatedCard(
      animIndex,
      _SectionCard(
        title: l10n.orderTimelineTitle,
        compact: _compactW(context),
        radius: _cardRadius(context),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Builder(
                builder: (context) {
                  final step = steps[i];
                  final stepStatus = OrdersL10n.timelineStatusLabel(context, step.status);
                  final stepNote = OrdersL10n.timelineStepLabel(context, step.status, step.label);
                  final isDone = step.isCompleted;
                  final isLast = i == steps.length - 1;
                  final dotColor = isDone
                      ? AppColors.success
                      : (isLast ? AppColors.primaryLight : Theme.of(context).colorScheme.outlineVariant);
                  return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: isDone ? 12 : 10,
                        height: isDone ? 12 : 10,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: isDone
                              ? null
                              : Border.all(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Container(
                          width: 2,
                          height: compact ? 16 : 20,
                          color: isDone
                              ? AppColors.success.withValues(alpha: 0.35)
                              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < steps.length - 1 ? (compact ? 6 : 8) : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stepStatus,
                            style: FontHelper.getTextStyle(
                              text: stepStatus,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: compact ? 13.0 : 14.0,
                              fontWeight: isDone || isLast ? FontWeight.w700 : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (stepNote != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              stepNote,
                              style: FontHelper.getTextStyle(
                                text: stepNote,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (step.completedAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              OrdersL10n.formatOrderDateTime(context, step.completedAt),
                              style: FontHelper.getTextStyle(
                                text: OrdersL10n.formatOrderDateTime(context, step.completedAt),
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: 11.5,
                                fontWeight: FontWeight.normal,
                                color: _DetailPalette.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;

    return _animatedCard(
      animIndex,
      _SectionCard(
        title: l10n.deliveryDetailsTitle,
        compact: _compactW(context),
        radius: _cardRadius(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: l10n.name, value: order.deliveryName ?? l10n.emptyValueDash),
            _DetailRow(
              label: l10n.phone,
              value: (order.deliveryPhone != null && order.deliveryPhone!.trim().isNotEmpty)
                  ? displayAfghanLocalPhone(order.deliveryPhone)
                  : l10n.emptyValueDash,
              forceLtrValue: order.deliveryPhone != null && order.deliveryPhone!.trim().isNotEmpty,
            ),
            _DetailRow(label: l10n.detailRowAddress, value: order.deliveryAddress ?? l10n.emptyValueDash),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, int animIndex) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final subtotal = order.subtotal ?? order.total;
    final deliveryFee = order.deliveryFee ?? 0;

    return _animatedCard(
      animIndex,
      _SectionCard(
        title: l10n.paymentSummaryDetailTitle,
        compact: _compactW(context),
        radius: _cardRadius(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PaymentRow(label: l10n.subtotal, value: subtotal),
            const SizedBox(height: 2),
            _PaymentRow(label: l10n.deliveryFeeShort, value: deliveryFee),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _compactW(context) ? 10 : 12,
                vertical: _compactW(context) ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _PaymentRow(
                label: l10n.total,
                value: order.total,
                bold: true,
              ),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.paymentMethod,
              value: OrdersL10n.paymentMethodLabel(l10n, order.paymentMethod),
            ),
            _DetailRow(
              label: l10n.paymentStatusDetail,
              value: OrdersL10n.paymentStatusLabel(
                l10n,
                OrdersL10n.effectivePaymentStatus(order),
              ),
              valueColor: AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.compact = false,
    this.radius = 12,
  });

  final String title;
  final Widget child;
  final bool compact;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 10.0 : 12.0;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _DetailPalette.border.withValues(alpha: isLight ? 0.85 : 0.35),
        ),
        boxShadow: _DetailPalette.cardShadow(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isLight ? 0.08 : 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: FontHelper.getTextStyle(
                  text: title,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: compact ? 11.5 : 12.5,
                  fontWeight: FontWeight.w800,
                  color: isLight ? _DetailPalette.sectionLabel : theme.colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.forceLtrValue = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool forceLtrValue;

  @override
  Widget build(BuildContext context) {
    final valueStyle = FontHelper.getTextStyle(
      text: value,
      languageCode: Get.find<LocaleController>().locale.languageCode,
      fontSize: 13.0,
      fontWeight: FontWeight.w500,
      color: valueColor ?? Theme.of(context).colorScheme.onSurface,
    );
    final valueText = Text(value, style: valueStyle);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FontHelper.getTextStyle(
              text: label,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: _DetailPalette.muted,
            ),
          ),
          const SizedBox(height: 3),
          if (forceLtrValue)
            // Keep digits LTR, but align to the parent's start (right in RTL).
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: valueText,
              ),
            )
          else
            valueText,
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final valueText = AppCurrency.formatLocalized(context, value, decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontHelper.getTextStyle(
                text: label,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 13.0,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valueText,
            textAlign: TextAlign.end,
            style: FontHelper.getTextStyle(
              text: valueText,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: bold ? 15.0 : 13.0,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? AppColors.primaryLight : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.compact = false});

  final String status;
  final bool compact;

  Color get _bgColor {
    final s = status.toLowerCase();
    if (s == 'delivered') return AppColors.success.withValues(alpha: 0.2);
    if (s == 'cancelled') return AppColors.error.withValues(alpha: 0.2);
    return AppColors.warning.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        localizedOrderStatus(context, status),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: FontHelper.getTextStyle(
          text: localizedOrderStatus(context, status),
          languageCode: Get.find<LocaleController>().locale.languageCode,
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
