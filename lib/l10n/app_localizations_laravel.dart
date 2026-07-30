import 'app_localizations.dart';
import 'laravel_messages_maps.dart';

/// Bridges Flutter [AppLocalizations] with Laravel [UberEat/lang/*/messages.php].
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// final hero = l10n.tLaravel(MessageKeys.hero_title);
/// ```
extension AppLocalizationsLaravel on AppLocalizations {
  /// Resolves a Laravel `messages.php` key to the **same** string the backend uses
  /// for `__('messages.$key')`, using the current app locale (en / fa / ps).
  String tLaravel(String messageKey) {
    final code = localeName.split(RegExp(r'[_-]')).first;
    final map = kLaravelMessagesByLocale[code] ?? kLaravelMessagesByLocale['en']!;
    return map[messageKey] ??
        kLaravelMessagesByLocale['en']![messageKey] ??
        messageKey;
  }
}
