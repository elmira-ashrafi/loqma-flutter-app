import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../orders_l10n.dart';
import 'order_detail_screen.dart';

/// Reason keys sent to API (labels from [AppLocalizations]).
const List<String> _cancellationReasonKeys = [
  'changed_mind',
  'wrong_order',
  'found_elsewhere',
  'delivery_too_long',
  'price_issue',
  'other',
];

String _reasonLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'changed_mind':
      return l10n.cancelReasonChangedMind;
    case 'wrong_order':
      return l10n.cancelReasonWrongOrder;
    case 'found_elsewhere':
      return l10n.cancelReasonFoundElsewhere;
    case 'delivery_too_long':
      return l10n.cancelReasonDeliveryLong;
    case 'price_issue':
      return l10n.cancelReasonPriceIssue;
    case 'other':
      return l10n.cancelReasonOther;
    default:
      return l10n.cancelReasonOther;
  }
}

class OrderCancelScreen extends StatefulWidget {
  const OrderCancelScreen({
    super.key,
    required this.order,
  });

  final OrderModel order;

  @override
  State<OrderCancelScreen> createState() => _OrderCancelScreenState();
}

class _OrderCancelScreenState extends State<OrderCancelScreen>
    with SingleTickerProviderStateMixin {
  late String _reason;
  final TextEditingController _detailsController = TextEditingController();
  bool _submitting = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    if (!widget.order.canBeCancelledByCustomer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    _reason = _cancellationReasonKeys.first;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitCancel() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    try {
      await ctrl.cancelOrder(
        orderId: widget.order.id,
        reason: _reason,
        reasonDetails: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
      );
      if (!mounted) return;
      ctrl.loadOrders();
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: widget.order.id,
            initialOrder: widget.order.copyWith(status: 'cancelled'),
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.orderCancelledRefundHint,
            style: FontHelper.getTextStyle(
              text: l10n.orderCancelledRefundHint,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToCancelOrder(userFriendlyErrorMessage(e)),
              style: FontHelper.getTextStyle(
                text: l10n.failedToCancelOrder(userFriendlyErrorMessage(e)),
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;
    final itemCount = order.effectiveItemCount;
    final orderMeta = '${l10n.itemsCountInCategory(formatAppInteger(context, itemCount))} · ${AppCurrency.formatLocalized(context, order.total, decimalDigits: 0)}';
    final restaurantTitle = OrdersL10n.restaurantTitle(context, l10n, order);
    final hPad = context.pageHorizontalPadding;
    final compact = _compact(context);
    final narrow = _narrow(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom + (compact ? 20.0 : 24.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.chevron_left_rounded, size: compact ? 22 : 24),
          visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            l10n.cancelOrderTitle,
            maxLines: 1,
            style: FontHelper.getTextStyle(
              text: l10n.cancelOrderTitle,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 17.0 : 19.0,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: MaxWidthBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.orderNumberLabel('${order.orderNumber ?? order.id}'),
                  style: FontHelper.getTextStyle(
                    text: l10n.orderNumberLabel('${order.orderNumber ?? order.id}'),
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: compact ? 13.0 : 14.0,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Container(
                  padding: EdgeInsets.all(compact ? 14 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: narrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 10),
                            Text(
                              l10n.cancelOrderConfirmTitle,
                              style: FontHelper.getTextStyle(
                                text: l10n.cancelOrderConfirmTitle,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: compact ? 14.0 : 16.0,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.cancelOrderConfirmBody,
                              style: FontHelper.getTextStyle(
                                text: l10n.cancelOrderConfirmBody,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: compact ? 12.5 : 14.0,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️', style: TextStyle(fontSize: 28)),
                            SizedBox(width: compact ? 10 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.cancelOrderConfirmTitle,
                                    style: FontHelper.getTextStyle(
                                      text: l10n.cancelOrderConfirmTitle,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.cancelOrderConfirmBody,
                                    style: FontHelper.getTextStyle(
                                      text: l10n.cancelOrderConfirmBody,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Container(
                  padding: EdgeInsets.all(compact ? 14 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: narrow ? 48 : (compact ? 52 : 56),
                        height: narrow ? 48 : (compact ? 52 : 56),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: narrow ? 24 : 28,
                        ),
                      ),
                      SizedBox(width: compact ? 12 : 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurantTitle,
                              style: FontHelper.getTextStyle(
                                text: restaurantTitle,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: compact ? 14.0 : 16.0,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderMeta,
                              style: FontHelper.getTextStyle(
                                text: orderMeta,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: compact ? 12.5 : 14.0,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 20 : 24),
                Text(
                  l10n.cancelReasonSectionTitle,
                  style: FontHelper.getTextStyle(
                    text: l10n.cancelReasonSectionTitle,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: compact ? 16.0 : 18.0,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: compact ? 10 : 12),
                ..._cancellationReasonKeys.map((key) {
                  final selected = _reason == key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _reason = key),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 14 : 16,
                            vertical: compact ? 12 : 14,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: selected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                size: compact ? 20 : 22,
                              ),
                              SizedBox(width: compact ? 10 : 12),
                              Expanded(
                                child: Text(
                                  _reasonLabel(l10n, key),
                                  style: FontHelper.getTextStyle(
                                    text: _reasonLabel(l10n, key),
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: compact ? 14.0 : 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: compact ? 12 : 16),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  style: FontHelper.getTextStyle(
                    text: '',
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: compact ? 14.0 : 16.0,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.cancelAdditionalDetailsLabel,
                    hintText: l10n.cancelReasonHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    isDense: compact,
                  ),
                ),
                SizedBox(height: compact ? 22 : 28),
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: narrow ? 12 : 14),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: Text(
                          l10n.keepOrder,
                          style: FontHelper.getTextStyle(
                            text: l10n.keepOrder,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: _submitting ? null : _submitCancel,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: EdgeInsets.symmetric(vertical: narrow ? 12 : 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                l10n.cancelOrderAction,
                                style: FontHelper.getTextStyle(
                                  text: l10n.cancelOrderAction,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Text(
                            l10n.keepOrder,
                            style: FontHelper.getTextStyle(
                              text: l10n.keepOrder,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting ? null : _submitCancel,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  l10n.cancelOrderAction,
                                  style: FontHelper.getTextStyle(
                                    text: l10n.cancelOrderAction,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
