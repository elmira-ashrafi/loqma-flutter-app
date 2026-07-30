import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'localized_number.dart';

/// Afghan Afghani (AFN) — the only currency used in the app.
/// Symbol before amount (matches backend `format_currency` + web `AppConfig.currency`).
abstract final class AppCurrency {
  static const String code = 'AFN';
  static const String symbol = '؋';

  /// e.g. `؋ 1,234` or `؋ 1,234.50`
  static String format(num amount, {int decimalDigits = 0}) {
    final pattern = decimalDigits > 0 ? '#,##0.${'0' * decimalDigits}' : '#,##0';
    final n = NumberFormat(pattern, 'en_US');
    return '$symbol ${n.format(amount)}';
  }

  /// Same as [format] but with locale-appropriate digits (Eastern for `fa`/`ps`).
  static String formatLocalized(BuildContext context, num amount, {int decimalDigits = 0}) {
    return localizeAppDigitsInString(context, format(amount, decimalDigits: decimalDigits));
  }
}
