import 'package:flutter/material.dart';

/// Single source of truth for operating the app in Afghanistan (maps, geocoding, locale defaults).
abstract final class AfghanistanRegion {
  AfghanistanRegion._();

  static const String isoCountryCode = 'AF';

  /// Default UI language for first launch (Dari / Persian, widely used across Afghanistan).
  static const Locale defaultLocale = Locale('fa', 'AF');

  /// Typical line appended when geocoding incomplete addresses.
  static const String geocodingCityLine = 'Kabul, Afghanistan';

  /// Kabul — used when the API does not provide coordinates.
  static const double defaultMapLatitude = 34.5553;
  static const double defaultMapLongitude = 69.2075;

  /// ITU E.164 country calling code (Afghanistan).
  static const String phoneDialCode = '+93';

  /// Local mobile hint (no country prefix; spaces for readability). Backend uses [normalizeCustomerPhoneToApi].
  static const String phoneNumberHint = '072 123 4567';

  /// Operator digit after `07` / `+937` (Afghan mobiles; `5` is not used).
  static const String mobileOperatorDigitClass = r'[0-46-9]';

  /// API format expected by Laravel: `+937` + operator + 7 digits (e.g. `+93782838831`).
  static final RegExp _apiPhonePattern =
      RegExp('^\\+937$mobileOperatorDigitClass\\d{7}\$');

  /// Local 10-digit mobile starting with `07`, or 9 digits starting with `7`.
  static final RegExp _localPhone10 =
      RegExp('^07$mobileOperatorDigitClass\\d{7}\$');
  static final RegExp _localPhone9 =
      RegExp('^7$mobileOperatorDigitClass\\d{7}\$');
  static final RegExp _digitsWithCountry =
      RegExp('^937$mobileOperatorDigitClass\\d{7}\$');

  /// Converts local Afghan mobile (e.g. `0782838831`) or existing `+937…` to API form.
  ///
  /// Accepts `+937` / `07` / `7` / `937` prefixes; the digit after `7` must be
  /// `0–4` or `6–9`. Returns `null` if the number cannot be normalized.
  static String? normalizeCustomerPhoneToApi(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (trimmed.isEmpty) {
      return null;
    }
    if (_apiPhonePattern.hasMatch(trimmed)) {
      return trimmed;
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (_localPhone10.hasMatch(digits)) {
      final afterZero = digits.substring(1);
      if (afterZero.length != 9) {
        return null;
      }
      return '+937${afterZero.substring(1)}';
    }
    if (_localPhone9.hasMatch(digits)) {
      return '+937${digits.substring(1)}';
    }
    if (_digitsWithCountry.hasMatch(digits)) {
      return '+$digits';
    }
    return null;
  }

  /// Pretty display for OTP screen: `+93782838831` → `0782838831`.
  static String formatApiPhoneForDisplay(String apiPhone) {
    final m = RegExp(
      '^\\+937($mobileOperatorDigitClass\\d{7})\$',
    ).firstMatch(apiPhone);
    if (m == null || m.groupCount < 1) {
      return apiPhone;
    }
    return '07${m.group(1)}';
  }

  /// Formats local `07XXXXXXXX` as `07X XXX XXXX` for UI (non-digits stripped first).
  static String formatLocalPhoneSpaced(String localOrDigits) {
    final d = localOrDigits.replaceAll(RegExp(r'\D'), '');
    if (!_localPhone10.hasMatch(d)) {
      return localOrDigits;
    }
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }
}
