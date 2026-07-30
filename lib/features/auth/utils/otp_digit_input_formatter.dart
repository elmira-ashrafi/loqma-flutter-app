import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_otp_digits.dart';

/// Allows Western and Eastern Arabic digits; stores/display one localized digit.
class OtpDigitInputFormatter extends TextInputFormatter {
  OtpDigitInputFormatter(this.context);

  final BuildContext context;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final western = normalizeOtpDigit(newValue.text);
    if (western.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final display = displayOtpDigit(context, western);
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}
