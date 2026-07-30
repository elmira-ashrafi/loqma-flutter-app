import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/localized_content.dart';
import '../../core/utils/app_currency.dart';
import '../../core/utils/localized_number.dart';
import '../../core/utils/relative_time_l10n.dart';
import '../../l10n/app_localizations.dart';
import 'models/order_model.dart';
import 'order_track_shared.dart';

/// Shared localization helpers for order screens.
abstract final class OrdersL10n {
  static String formatOrderDateTime(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) {
      return AppLocalizations.of(context)!.emptyValueDash;
    }
    try {
      final dt = DateTime.parse(iso).toLocal();
      final localeTag = Localizations.localeOf(context).toString();
      final raw = DateFormat('MMM d, yyyy - hh:mm a', localeTag).format(dt);
      return localizeAppDigitsInString(context, raw);
    } catch (_) {
      return iso;
    }
  }

  static String formatOrderDate(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final localeTag = Localizations.localeOf(context).toString();
      final raw = DateFormat.yMMMd(localeTag).format(dt);
      return localizeAppDigitsInString(context, raw);
    } catch (_) {
      return iso;
    }
  }

  static String formatOrderTime(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final localeTag = Localizations.localeOf(context).toString();
      final raw = DateFormat.Hm(localeTag).format(dt);
      return localizeAppDigitsInString(context, raw);
    } catch (_) {
      return iso;
    }
  }

  static String listSubtitle(BuildContext context, AppLocalizations l10n, OrderModel order) {
    final status = localizedOrderStatus(context, order.status);
    final localeTag = Localizations.localeOf(context).toString();
    final time = RelativeTimeL10n.formatIsoForOrderPlaced(l10n, localeTag, order.placedAt);
    if (time == null || time.isEmpty) return status;
    return l10n.orderStatusTimeSeparator(status, time);
  }

  static String restaurantTitle(BuildContext context, AppLocalizations l10n, OrderModel order) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final en = order.restaurantName?.trim() ?? '';
    final name = LocalizedContent.restaurantDisplayName(
      en: en,
      fa: order.restaurantNameFa,
      ps: order.restaurantNamePs,
      localizedFromApi: order.restaurantLocalizedName,
      localeCode: localeCode,
    );
    if (name.trim().isNotEmpty) return name;
    return l10n.restaurantDefaultName;
  }

  static String itemDisplayName(BuildContext context, OrderItemModel item) {
    return item.localized.displayNameFor(Localizations.localeOf(context).languageCode);
  }

  static String? itemDisplayDescription(BuildContext context, OrderItemModel item) {
    return item.localized.displayDescriptionFor(Localizations.localeOf(context).languageCode);
  }

  static String orderNumberLabel(BuildContext context, AppLocalizations l10n, OrderModel order) {
    final raw = order.orderNumber ?? '${order.id}';
    return l10n.orderNumberLabel(localizeAppDigitsInString(context, raw));
  }

  static String orderNumberLabelForId(BuildContext context, AppLocalizations l10n, int orderId, {String? orderNumber}) {
    final raw = orderNumber ?? '$orderId';
    return l10n.orderNumberLabel(localizeAppDigitsInString(context, raw));
  }

  static String? timelineStepLabel(BuildContext context, String status, String? rawLabel) {
    final label = rawLabel?.trim();
    if (label == null || label.isEmpty) return null;
    final statusText = timelineStatusLabel(context, status);
    final localizedLabel = timelineStatusLabel(context, label);
    if (localizedLabel == statusText) return null;
    return localizedLabel;
  }

  static bool isCashOnDelivery(String? raw) {
    final s = (raw ?? '').trim().toLowerCase();
    return s == 'cod' || s == 'cash';
  }

  static bool isHesabPay(String? raw) {
    final s = (raw ?? '').trim().toLowerCase();
    return s.contains('hesab');
  }

  /// COD is collected at the door — only then show as paid. Online methods use API status only.
  static String? effectivePaymentStatus(OrderModel order) {
    if (!isCashOnDelivery(order.paymentMethod)) {
      return order.paymentStatus;
    }
    if (order.status.toLowerCase() == 'delivered') {
      return 'paid';
    }
    return order.paymentStatus ?? 'pending';
  }

  static String paymentMethodLabel(AppLocalizations l10n, String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return l10n.cashOnDelivery;
    final s = value.toLowerCase();
    if (s.contains('cash') || s == 'cod') return l10n.cashOnDelivery;
    if (s.contains('hesab')) return l10n.hesabPayTitle;
    if (s.contains('online') || s.contains('card') || s.contains('digital')) {
      return l10n.paymentMethodOnline;
    }
    return value;
  }

  static String paymentStatusLabel(AppLocalizations l10n, String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return l10n.paymentStatusPendingGeneric;
    final s = value.toLowerCase();
    if (s.contains('paid') || s.contains('success') || s == 'completed') {
      return l10n.paymentStatusPaid;
    }
    if (s.contains('fail') || s.contains('cancel')) return l10n.paymentStatusFailed;
    if (s.contains('pending')) return l10n.paymentStatusPendingGeneric;
    return value;
  }

  static String itemQtyPriceLine(
    BuildContext context,
    AppLocalizations l10n,
    int qty,
    double unitPrice,
  ) {
    return l10n.orderItemQtyTimesPrice(
      formatAppInteger(context, qty),
      AppCurrency.formatLocalized(context, unitPrice, decimalDigits: 0),
    );
  }

  static String timelineStatusLabel(BuildContext context, String status) {
    return localizedOrderStatus(context, status);
  }

  static String deliveryTimeCaption(BuildContext context, OrderModel order) {
    final est = order.estimatedDeliveryTime;
    if (isUsableEstimatedDeliveryTime(est)) {
      return localizeRawPrepTimeString(context, est!.trim());
    }
    final confirmed = order.estimatedPrepTime;
    if (confirmed != null && confirmed > 0) {
      return AppLocalizations.of(context)!
          .minLabel(formatAppInteger(context, confirmed));
    }
    return restaurantPrepTimeCaption(
      context,
      avgPrepMinutes: order.avgPreparationTime,
      rawDeliveryTime: order.deliveryTime,
    );
  }
}
