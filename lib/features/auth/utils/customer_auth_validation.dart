import '../../../core/constants/afghanistan_region.dart';
import '../../../l10n/app_localizations.dart';

/// Client-side validation for customer auth flows — returns a localized
/// error message, or `null` when valid.
abstract final class CustomerAuthValidation {
  CustomerAuthValidation._();

  static const int nameMinRunes = 2;
  static const int nameMaxRunes = 80;

  static String? validateDisplayName(String raw, AppLocalizations l10n) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final runes = name.runes.length;
    if (name.isEmpty) {
      return l10n.pleaseEnterName;
    }
    if (runes < nameMinRunes) {
      return l10n.authNameTooShort;
    }
    if (runes > nameMaxRunes) {
      return l10n.authNameTooLong;
    }
    if (AfghanistanRegion.normalizeCustomerPhoneToApi(name) != null) {
      return l10n.authNameLooksLikePhoneNumber;
    }
    if (!_hasLetterRune(name)) {
      return l10n.authNameMustContainLetters;
    }
    return null;
  }

  static String? validatePhoneField(String raw, AppLocalizations l10n) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return l10n.pleaseEnterPhoneNumber;
    }
    if (AfghanistanRegion.normalizeCustomerPhoneToApi(trimmed) == null) {
      return l10n.invalidAfghanPhone;
    }
    return null;
  }

  static String? validatePassword(String raw, AppLocalizations l10n) {
    if (raw.isEmpty) {
      return l10n.authPleaseEnterPassword;
    }
    if (raw.length < 8) {
      return l10n.authPasswordMinEight;
    }
    return null;
  }

  /// Login only: non-empty (server enforces credentials).
  static String? validateLoginPassword(String raw, AppLocalizations l10n) {
    if (raw.isEmpty) {
      return l10n.authPleaseEnterPassword;
    }
    return null;
  }

  static String? validatePasswordConfirmation(
    String password,
    String confirmation,
    AppLocalizations l10n,
  ) {
    if (confirmation.isEmpty) {
      return l10n.authPleaseEnterPassword;
    }
    if (password != confirmation) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  static String? validateEmail(String raw, AppLocalizations l10n) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return l10n.pleaseEnterEmail;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trimmed)) {
      return l10n.contactFormEmailInvalid;
    }
    return null;
  }

  static String? validateLoginIdentifier(String raw, AppLocalizations l10n) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return l10n.authEnterEmailOrPhone;
    }
    if (trimmed.contains('@')) {
      return validateEmail(trimmed, l10n);
    }
    return validatePhoneField(trimmed, l10n);
  }

  static String? validateSixDigitOtp(String raw, AppLocalizations l10n) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) {
      return l10n.authEnterSixDigitCode;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(digits.substring(0, 6))) {
      return l10n.authInvalidSixDigitCode;
    }
    return null;
  }

  static String? validateAddress(String raw, AppLocalizations l10n) {
    if (raw.trim().length < 5) {
      return l10n.authLocationRequired;
    }
    return null;
  }

  static String? validateThreeDigitOtp(String raw, AppLocalizations l10n) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3) {
      return l10n.otpIncompleteCode;
    }
    if (!RegExp(r'^\d{3}$').hasMatch(digits.substring(0, 3))) {
      return l10n.otpInvalidCode;
    }
    return null;
  }

  static bool _hasLetterRune(String s) {
    for (final r in s.runes) {
      if (_isLetterRune(r)) {
        return true;
      }
    }
    return false;
  }

  /// Latin + Arabic scripts (Dari / Pashto / English names).
  static bool _isLetterRune(int r) {
    if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) {
      return true;
    }
    if (r >= 0x0600 && r <= 0x06FF) {
      return true;
    }
    if (r >= 0x0750 && r <= 0x077F) {
      return true;
    }
    if (r >= 0x08A0 && r <= 0x08FF) {
      return true;
    }
    if (r >= 0xFB50 && r <= 0xFDFF) {
      return true;
    }
    if (r >= 0xFE70 && r <= 0xFEFF) {
      return true;
    }
    return false;
  }
}
