import 'package:dio/dio.dart';

import '../../../core/utils/error_parser.dart';
import '../../../l10n/app_localizations.dart';

/// Friendly auth error: banner message + optional per-field hints.
class AuthFormError {
  const AuthFormError({
    required this.message,
    this.fieldErrors = const {},
  });

  final String message;
  final Map<String, String> fieldErrors;
}

/// Maps Laravel / Dio failures into clear customer-facing auth copy.
abstract final class AuthErrorMapper {
  AuthErrorMapper._();

  static AuthFormError fromDio(DioException e, AppLocalizations l10n) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final Map<String, dynamic>? map =
        data is Map<String, dynamic> ? data : (data is Map ? Map<String, dynamic>.from(data) : null);

    final apiMessage = (map?['message'] as String?)?.trim() ?? '';
    final fieldErrors = _extractFieldErrors(map?['errors'], l10n);

    if (status == 401 || _looksLikeBadCredentials(apiMessage)) {
      return AuthFormError(
        message: l10n.authInvalidCredentials,
        fieldErrors: {
          'login': l10n.authInvalidCredentials,
          'password': l10n.authCheckPasswordAgain,
          ...fieldErrors,
        },
      );
    }

    if (status == 429) {
      return AuthFormError(
        message: l10n.authTooManyAttempts,
        fieldErrors: fieldErrors,
      );
    }

    if (status == 422 || fieldErrors.isNotEmpty) {
      final summary = fieldErrors.isNotEmpty
          ? (fieldErrors.values.first.isNotEmpty
              ? fieldErrors.values.first
              : l10n.authValidationFixFields)
          : (apiMessage.isNotEmpty ? _localizeApiMessage(apiMessage, l10n) : l10n.authValidationFixFields);
      return AuthFormError(message: summary, fieldErrors: fieldErrors);
    }

    if (status == 403) {
      final localized = _localizeApiMessage(apiMessage, l10n);
      return AuthFormError(
        message: localized.isNotEmpty ? localized : l10n.authSomethingWentWrong,
        fieldErrors: fieldErrors,
      );
    }

    // Cancelled Google / client exceptions wrapped as Dio are rare; handle message.
    if (apiMessage.toLowerCase().contains('cancel')) {
      return AuthFormError(message: l10n.authGoogleCancelled);
    }

    // Prefer readable API message when it exists; otherwise network-friendly copy.
    if (apiMessage.isNotEmpty) {
      return AuthFormError(
        message: _localizeApiMessage(apiMessage, l10n),
        fieldErrors: fieldErrors,
      );
    }

    return AuthFormError(
      message: _networkFallback(e, l10n),
      fieldErrors: fieldErrors,
    );
  }

  static AuthFormError fromAny(Object error, AppLocalizations l10n) {
    if (error is DioException) return fromDio(error, l10n);
    final raw = error.toString().toLowerCase();
    if (raw.contains('cancel')) {
      return AuthFormError(message: l10n.authGoogleCancelled);
    }
    if (raw.contains('id token') || raw.contains('google')) {
      return AuthFormError(message: l10n.authGoogleFailed);
    }
    return AuthFormError(message: l10n.authSomethingWentWrong);
  }

  static Map<String, String> _extractFieldErrors(
    dynamic raw,
    AppLocalizations l10n,
  ) {
    if (raw is! Map) return {};
    final out = <String, String>{};
    raw.forEach((key, value) {
      final field = key.toString();
      String msg;
      if (value is List && value.isNotEmpty) {
        msg = value.first.toString();
      } else {
        msg = value.toString();
      }
      out[field] = _localizeFieldMessage(field, msg, l10n);
    });
    return out;
  }

  static String _localizeFieldMessage(
    String field,
    String apiMsg,
    AppLocalizations l10n,
  ) {
    final lower = apiMsg.toLowerCase();
    final f = field.toLowerCase();

    if (f.contains('email') &&
        (lower.contains('taken') || lower.contains('already'))) {
      return l10n.authEmailAlreadyRegistered;
    }
    if (f.contains('phone') &&
        (lower.contains('taken') || lower.contains('already'))) {
      return l10n.authPhoneAlreadyRegistered;
    }
    if (f.contains('phone') &&
        (lower.contains('invalid') || lower.contains('format'))) {
      return l10n.invalidAfghanPhone;
    }
    if (f.contains('email') && lower.contains('valid')) {
      return l10n.contactFormEmailInvalid;
    }
    if (f.contains('password') &&
        (lower.contains('confirmation') || lower.contains('match'))) {
      return l10n.passwordsDoNotMatch;
    }
    if (f.contains('password') &&
        (lower.contains('at least') || lower.contains('8'))) {
      return l10n.authPasswordMinEight;
    }
    if (f.contains('name')) {
      if (lower.contains('required')) return l10n.pleaseEnterName;
      return l10n.authNameTooShort;
    }
    if (f.contains('address') || f.contains('location')) {
      return l10n.authLocationRequired;
    }

    final localized = _localizeApiMessage(apiMsg, l10n);
    return localized.isNotEmpty ? localized : apiMsg;
  }

  static String _localizeApiMessage(String apiMsg, AppLocalizations l10n) {
    final lower = apiMsg.toLowerCase();
    if (_looksLikeBadCredentials(apiMsg)) return l10n.authInvalidCredentials;
    if (lower.contains('email') &&
        (lower.contains('taken') || lower.contains('already'))) {
      return l10n.authEmailAlreadyRegistered;
    }
    if (lower.contains('phone') &&
        (lower.contains('taken') || lower.contains('already'))) {
      return l10n.authPhoneAlreadyRegistered;
    }
    if (lower.contains('too many') || lower.contains('throttle')) {
      return l10n.authTooManyAttempts;
    }
    if (lower.contains('google')) return l10n.authGoogleFailed;
    // Keep English API message only if it's already customer-friendly length.
    if (apiMsg.length <= 140 && !lower.contains('exception')) {
      return apiMsg;
    }
    return l10n.authSomethingWentWrong;
  }

  static bool _looksLikeBadCredentials(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('credentials') ||
        lower.contains('do not match our records') ||
        lower.contains('invalid login') ||
        lower.contains('unauthorized') ||
        lower.contains('wrong password');
  }

  static String _networkFallback(DioException e, AppLocalizations l10n) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return l10n.authNoInternet;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return l10n.authServerSlow;
      default:
        final status = e.response?.statusCode;
        if (status != null && status >= 500) return l10n.authServerUnavailable;
        return l10n.authSomethingWentWrong;
    }
  }
}

/// Prefer this for auth screens instead of [userFriendlyErrorMessage].
String authFriendlyMessage(Object error, AppLocalizations l10n) =>
    AuthErrorMapper.fromAny(error, l10n).message;
