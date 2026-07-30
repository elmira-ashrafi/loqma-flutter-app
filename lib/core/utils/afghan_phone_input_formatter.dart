import 'package:flutter/services.dart';

/// Live input rules for Afghan mobiles:
/// - Starts with `+937` or `07` (also allows typing toward those prefixes)
/// - Next digit is an operator code: `0–4` or `6–9` (not `5`)
/// - Then up to 7 more digits
class AfghanPhoneInputFormatter extends TextInputFormatter {
  static final RegExp _allowedChars = RegExp(r'^[\d\s+\-]*$');
  static final RegExp _operatorDigit = RegExp(r'^[0-46-9]$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!_allowedChars.hasMatch(text)) {
      return oldValue;
    }

    final compact = text.replaceAll(RegExp(r'[\s\-]'), '');
    if (!_isValidPartial(compact)) {
      return oldValue;
    }

    return newValue;
  }

  static bool _isOperator(String digit) => _operatorDigit.hasMatch(digit);

  /// [compact] has spaces/dashes removed; may still include `+`.
  static bool _isValidPartial(String compact) {
    if (compact.isEmpty) {
      return true;
    }

    if (compact.startsWith('+')) {
      if (compact == '+' || compact == '+9' || compact == '+93') {
        return true;
      }
      if (!compact.startsWith('+937')) {
        return '+937'.startsWith(compact);
      }
      final rest = compact.substring(4);
      if (rest.isEmpty) {
        return true;
      }
      if (!_isOperator(rest[0])) {
        return false;
      }
      if (rest.length > 8) {
        return false;
      }
      return RegExp(r'^\d+$').hasMatch(rest);
    }

    if (!RegExp(r'^\d+$').hasMatch(compact)) {
      return false;
    }

    // Local: 07 + operator + 7 digits (10 total)
    if (compact.startsWith('0')) {
      if (compact == '0') {
        return true;
      }
      if (compact[1] != '7') {
        return false;
      }
      if (compact.length == 2) {
        return true;
      }
      if (!_isOperator(compact[2])) {
        return false;
      }
      return compact.length <= 10;
    }

    // Without leading 0: 7 + operator + 7 digits (9 total)
    if (compact.startsWith('7')) {
      if (compact.length == 1) {
        return true;
      }
      if (!_isOperator(compact[1])) {
        return false;
      }
      return compact.length <= 9;
    }

    // Country code without plus: 937 + operator + 7 digits
    if (compact.startsWith('9')) {
      if (compact == '9' || compact == '93') {
        return true;
      }
      if (!compact.startsWith('937')) {
        return '937'.startsWith(compact);
      }
      final rest = compact.substring(3);
      if (rest.isEmpty) {
        return true;
      }
      if (!_isOperator(rest[0])) {
        return false;
      }
      if (rest.length > 8) {
        return false;
      }
      return true;
    }

    return false;
  }
}
