import 'package:flutter/material.dart';

/// Locale layout matches the Laravel app [UberEat/lang]:
/// - `lang/en/messages.php` — English
/// - `lang/fa/messages.php` — Dari
/// - `lang/ps/messages.php` — Pashto
///
/// Flutter UI strings live in [app_en.arb] / [app_fa.arb] / [app_ps.arb] (gen-l10n).
/// Strings that must stay **identical** to Laravel `__('messages.*')` are in
/// [kLaravelMessagesByLocale] and resolved via [AppLocalizations.tLaravel].
abstract final class LocaleCodes {
  LocaleCodes._();

  /// Same codes as Laravel `config/app.php` locale folders used by this app.
  static const List<String> languageCodes = ['en', 'fa', 'ps'];

  /// Use this for [MaterialApp.supportedLocales] / GetX so order matches [languageCodes].
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fa'),
    Locale('ps'),
  ];
}
