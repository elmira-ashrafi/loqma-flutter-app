/// Picks the best localized string for [languageCode] (`en`, `fa`, `ps`).
///
/// Admin/API content should provide `name`, `name_fa`, `name_ps` (or `title_*`,
/// `subtitle_*`, `description_*`). When a locale field is empty, falls back to
/// the primary [primary] (usually English `name`).
String pickLocalizedText({
  required String languageCode,
  required String primary,
  String? fa,
  String? ps,
}) {
  final base = primary.trim();
  switch (languageCode) {
    case 'fa':
      final v = fa?.trim();
      if (v != null && v.isNotEmpty) return v;
      return base.isNotEmpty ? base : (fa ?? ps ?? '');
    case 'ps':
      final v = ps?.trim();
      if (v != null && v.isNotEmpty) return v;
      return base.isNotEmpty ? base : (ps ?? fa ?? '');
    default:
      return base.isNotEmpty ? base : (fa ?? ps ?? '');
  }
}

/// Reads `key`, `key_fa`, `key_ps` from a JSON map (Laravel/admin payloads).
String localizedFromJsonMap(
  Map<String, dynamic> json,
  String key,
  String languageCode, {
  String? fallbackKey,
}) {
  final primary = (json[key] ?? json[fallbackKey ?? ''])?.toString() ?? '';
  final fa = json['${key}_fa']?.toString();
  final ps = json['${key}_ps']?.toString();
  return pickLocalizedText(
    languageCode: languageCode,
    primary: primary,
    fa: fa,
    ps: ps,
  );
}
