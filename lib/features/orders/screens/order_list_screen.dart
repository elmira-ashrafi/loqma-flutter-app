import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../orders_l10n.dart';
import 'order_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// List of customer orders from /customer/orders with pagination.
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  static bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  static bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  static double _listBottomPad(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + (_compact(context) ? 88.0 : 100.0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    final hPad = context.pageHorizontalPadding;
    final compact = _compact(context);
    final narrow = _narrow(context);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            l10n.myOrders,
            maxLines: 1,
            style: FontHelper.getTextStyle(
              text: l10n.myOrders,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 17.0 : 19.0,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final _ = Get.find<LocaleController>().localeRx.value;
        if (ctrl.isLoading.value && ctrl.orders.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (ctrl.error.value.isNotEmpty) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: narrow ? 52 : (compact ? 58 : 64),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        ctrl.error.value,
                        textAlign: TextAlign.center,
                        style: FontHelper.getTextStyle(
                          text: ctrl.error.value,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: compact ? 13.5 : 14.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      TextButton.icon(
                        onPressed: () => ctrl.loadOrders(),
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
              ),
            ],
          );
        }
        if (ctrl.orders.isEmpty) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: narrow ? 52 : (compact ? 58 : 64),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        l10n.noOrdersYet,
                        textAlign: TextAlign.center,
                        style: FontHelper.getTextStyle(
                          text: l10n.noOrdersYet,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: compact ? 16.0 : 18.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 12),
                      TextButton(
                        onPressed: () => ctrl.loadOrders(),
                        child: Text(
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
              ),
            ],
          );
        }
        return MaxWidthBody(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctrl.loadOrders(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, _listBottomPad(context)),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: ctrl.orders.length,
              itemBuilder: (context, i) {
                final order = ctrl.orders[i];
                return _OrderCard(
                  order: order,
                  compact: compact,
                  narrow: narrow,
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.compact,
    required this.narrow,
  });

  final OrderModel order;
  final bool compact;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final w = MediaQuery.sizeOf(context).width;
    final tileDensity = compact ? VisualDensity.compact : VisualDensity.standard;
    final thumb = narrow ? 48.0 : (compact ? 52.0 : 56.0);
    final titleFallback = OrdersL10n.orderNumberLabel(context, l10n, order);
    final restaurantTitle = OrdersL10n.restaurantTitle(context, l10n, order);
    final subtitle = OrdersL10n.listSubtitle(context, l10n, order);
    final totalText = AppCurrency.formatLocalized(context, order.total, decimalDigits: 2);

    return Card(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 12,
        ),
        visualDensity: tileDensity,
        leading: Container(
          width: thumb,
          height: thumb,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.restaurant_rounded,
            color: AppColors.primary,
            size: thumb * 0.45,
          ),
        ),
        title: Text(
          restaurantTitle != l10n.restaurantDefaultName ? restaurantTitle : titleFallback,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FontHelper.getTextStyle(
            text: restaurantTitle != l10n.restaurantDefaultName ? restaurantTitle : titleFallback,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: compact ? 14.5 : 16.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: subtitle,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 12.0 : 14.0,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: w * (compact ? 0.34 : 0.3),
          ),
          child: Text(
            totalText,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: totalText,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 13.5 : 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(
                orderId: order.id,
                initialOrder: order,
              ),
            ),
          );
        },
      ),
    );
  }
}
