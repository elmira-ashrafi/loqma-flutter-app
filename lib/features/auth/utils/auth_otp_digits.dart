import 'package:flutter/material.dart';

import '../../../core/utils/localized_number.dart';

const _easternArabicIndicDigits = '۰۱۲۳۴۵۶۷۸۹';

/// Normalizes a single OTP digit from Western or Eastern Arabic input.
String normalizeOtpDigit(String input) {
  if (input.isEmpty) return '';
  final c = input.substring(input.length - 1);
  final easternIndex = _easternArabicIndicDigits.indexOf(c);
  if (easternIndex >= 0) return '$easternIndex';
  if (RegExp(r'^\d$').hasMatch(c)) return c;
  return '';
}

/// Extracts up to [maxLen] Western digits from pasted / SMS text.
String extractWesternOtpDigits(String raw, {int maxLen = 3}) {
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final d = normalizeOtpDigit(raw[i]);
    if (d.isNotEmpty) buffer.write(d);
    if (buffer.length >= maxLen) break;
  }
  return buffer.toString();
}

/// Display digit in the active app locale (Eastern for ps/fa).
String displayOtpDigit(BuildContext context, String westernDigit) {
  if (westernDigit.isEmpty) return '';
  return localizeAppDigitsInString(context, westernDigit);
}

/// OTP boxes always flow left-to-right; digits still localize for ps/fa.
Widget otpDigitFieldsLtr({required Widget child}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}
