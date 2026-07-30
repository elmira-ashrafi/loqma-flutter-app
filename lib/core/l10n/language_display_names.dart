/// Native language names shown in pickers (same in every UI locale).
abstract final class LanguageDisplayNames {
  static const String english = 'English';
  static const String pashto = 'پښتو';
  static const String dari = 'دری';

  /// FontHelper language code for each fixed label.
  static String fontLanguageCode(String label) {
    if (label == english) return 'en';
    if (label == pashto) return 'ps';
    if (label == dari) return 'fa';
    return 'en';
  }
}
