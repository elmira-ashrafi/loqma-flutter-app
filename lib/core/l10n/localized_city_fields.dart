import 'localized_content.dart';

/// City/locality name fields from API `city` objects (`name`, `name_fa`, `name_ps`).
class LocalizedCityFields {
  const LocalizedCityFields({
    this.name = '',
    this.nameFa,
    this.namePs,
    this.localizedName,
  });

  final String name;
  final String? nameFa;
  final String? namePs;
  final String? localizedName;

  factory LocalizedCityFields.fromJson(dynamic json) {
    if (json is! Map) return const LocalizedCityFields();
    final m = Map<String, dynamic>.from(json);
    return LocalizedCityFields(
      name: m['name'] as String? ?? '',
      nameFa: m['name_fa'] as String?,
      namePs: m['name_ps'] as String?,
      localizedName: m['localized_name'] as String?,
    );
  }

  bool get isEmpty => name.trim().isEmpty;

  String get displayName => LocalizedContent.pick(
        en: name,
        fa: nameFa,
        ps: namePs,
        localizedFromApi: localizedName,
      );

  /// Swaps the English [name] for [displayName] inside a free-text line.
  String embedInLine(String line) {
    final localized = displayName.trim();
    final en = name.trim();
    if (en.isEmpty || localized.isEmpty || localized == en) return line;
    if (line.contains(en)) return line.replaceAll(en, localized);
    return line;
  }
}
