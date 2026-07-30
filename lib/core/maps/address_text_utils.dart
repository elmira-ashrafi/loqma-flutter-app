/// Helpers for human-readable address lines (filters Plus Codes, etc.).
abstract final class AddressTextUtils {
  static final RegExp _plusCodeOnly = RegExp(
    r'^([23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3})(?:\s+.*)?$',
    caseSensitive: false,
  );

  static final RegExp _plusCodeFragment = RegExp(
    r'[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3}',
    caseSensitive: false,
  );

  /// Google Open Location Code strings (e.g. `G5J9+JP6`) are not user-facing addresses.
  static bool isPlusCode(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return false;
    if (_plusCodeOnly.hasMatch(t)) return true;
    if (t.length <= 12 && _plusCodeFragment.hasMatch(t) && !t.contains(',')) {
      return _plusCodeFragment.firstMatch(t)?.group(0) == t;
    }
    return false;
  }

  static String? meaningfulLine(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty || isPlusCode(t)) return null;
    return t;
  }

  static String joinParts(Iterable<String?> parts, {String separator = ', '}) {
    return parts
        .map((e) => e?.trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty && !isPlusCode(e))
        .join(separator);
  }
}
