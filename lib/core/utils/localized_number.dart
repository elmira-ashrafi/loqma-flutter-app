import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/orders/models/order_model.dart';
import '../../l10n/app_localizations.dart';

const _easternArabicIndicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Resolves app language: English, Dari (`fa`), or Pashto (`ps`).
String appLanguageCode(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'ps' || code == 'fa') return code;
  return 'en';
}

String localizeAppDigitsInString(BuildContext context, String source) {
  if (appLanguageCode(context) == 'en') return source;
  return source.split('').map((c) {
    final d = int.tryParse(c);
    if (d == null || d < 0 || d > 9) return c;
    return _easternArabicIndicDigits[d];
  }).join();
}

String _localizeDigitChars(BuildContext context, String source) =>
    localizeAppDigitsInString(context, source);

/// Integer digits for the active app locale (Western for `en`, Eastern for `ps`/`fa`).
String formatAppInteger(BuildContext context, int value) {
  if (value < 0) return formatAppInteger(context, 0);
  return _localizeDigitChars(context, value.toString());
}

/// Decimal rating-style numbers (e.g. 4.5 → ۴.۵ in RTL locales).
String formatAppDecimal(BuildContext context, double value, {int fractionDigits = 1}) {
  final raw = value.toStringAsFixed(fractionDigits);
  return _localizeDigitChars(context, raw);
}

/// Delivery prep window, e.g. "35–45 min" with locale digits and ARB wording.
String deliveryMinutesRangeCaption(BuildContext context, int low, int high) {
  final l10n = AppLocalizations.of(context)!;
  return l10n.minRangeLabel(
    formatAppInteger(context, low),
    formatAppInteger(context, high),
  );
}

/// Localizes API English strings like `"40 min"` / `"35-45 min"` for the active locale.
String localizeRawPrepTimeString(BuildContext context, String raw) {
  final l10n = AppLocalizations.of(context)!;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return l10n.prepTimeDefault;

  final range = RegExp(r'(\d+)\s*[-–]\s*(\d+)\s*min', caseSensitive: false).firstMatch(trimmed);
  if (range != null) {
    final lo = int.tryParse(range.group(1)!) ?? 35;
    final hi = int.tryParse(range.group(2)!) ?? 45;
    return deliveryMinutesRangeCaption(context, lo, hi);
  }

  final single = RegExp(r'(\d+)\s*min', caseSensitive: false).firstMatch(trimmed);
  if (single != null) {
    final minutes = int.tryParse(single.group(1)!) ?? 0;
    if (minutes <= 0) return l10n.prepTimeDefault;
    return l10n.minLabel(formatAppInteger(context, minutes));
  }

  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
    final minutes = int.parse(trimmed);
    if (minutes <= 0) return l10n.prepTimeDefault;
    return l10n.minLabel(formatAppInteger(context, minutes));
  }

  return trimmed;
}

/// Prep/delivery window for restaurant cards and order banners.
String restaurantPrepTimeCaption(
  BuildContext context, {
  int? avgPrepMinutes,
  String? rawDeliveryTime,
}) {
  final l10n = AppLocalizations.of(context)!;
  if (avgPrepMinutes != null && avgPrepMinutes > 0) {
    final lo = avgPrepMinutes.clamp(5, 120);
    final hi = (lo + 10).clamp(lo + 1, 180);
    return deliveryMinutesRangeCaption(context, lo, hi);
  }

  final raw = rawDeliveryTime?.trim();
  if (raw != null && raw.isNotEmpty) {
    return localizeRawPrepTimeString(context, raw);
  }

  return l10n.prepTimeDefault;
}

/// OPEN / CLOSED (or localized short badges from ARB).
String restaurantStatusBadge(BuildContext context, bool open) {
  final l10n = AppLocalizations.of(context)!;
  return open ? l10n.restaurantOpenBadge : l10n.restaurantClosedBadge;
}

/// Relative time fragment for order cards (not including "Placed" prefix).
String relativeOrderPlacedTime(BuildContext context, String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final l10n = AppLocalizations.of(context)!;
  final dt = OrderModel.parseOrderDateTime(iso);
  if (dt == null) return '';
  try {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inSeconds < 60) return l10n.orderRelativeJustNow;
    if (diff.inMinutes < 60) {
      return l10n.orderRelativeMinutesAgo(formatAppInteger(context, diff.inMinutes));
    }
    if (diff.inHours < 24) {
      return l10n.orderRelativeHoursAgo(formatAppInteger(context, diff.inHours));
    }
    if (diff.inDays < 7) {
      return l10n.orderRelativeDaysAgo(formatAppInteger(context, diff.inDays));
    }
    final locale = Localizations.localeOf(context).toString();
    return _localizeDigitChars(context, DateFormat.MMMd(locale).format(local));
  } catch (_) {
    return '';
  }
}

/// Full "Placed …" line for order list cards.
String orderPlacedLine(BuildContext context, String? iso) {
  final when = relativeOrderPlacedTime(context, iso);
  if (when.isEmpty) return '';
  return AppLocalizations.of(context)!.orderPlacedAt(when);
}

/// Cart FAB badge: localized max label from ARB, otherwise locale-aware count digits.
String cartFabBadgeLabel(BuildContext context, int itemCount) {
  if (itemCount <= 0) return '';
  final l10n = AppLocalizations.of(context)!;
  if (itemCount > 99) return l10n.cartBadgeMax;
  return formatAppInteger(context, itemCount);
}

/// Quantity line for cart lists: "Qty: 2" with localized digits.
String qtyWithLocalizedCount(BuildContext context, String qtyLabel, int count) {
  return AppLocalizations.of(context)!.qtyWithCount(qtyLabel, formatAppInteger(context, count));
}
