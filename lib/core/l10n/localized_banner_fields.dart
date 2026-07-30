import 'localized_content.dart';

/// Localized banner title/subtitle from API JSON.
class LocalizedBannerFields {
  const LocalizedBannerFields({
    this.title,
    this.titleFa,
    this.titlePs,
    this.localizedTitle,
    this.subtitle,
    this.subtitleFa,
    this.subtitlePs,
    this.localizedSubtitle,
  });

  final String? title;
  final String? titleFa;
  final String? titlePs;
  final String? localizedTitle;
  final String? subtitle;
  final String? subtitleFa;
  final String? subtitlePs;
  final String? localizedSubtitle;

  factory LocalizedBannerFields.fromJson(Map<String, dynamic> json) {
    return LocalizedBannerFields(
      title: json['title'] as String?,
      titleFa: json['title_fa'] as String?,
      titlePs: json['title_ps'] as String?,
      localizedTitle: json['localized_title'] as String?,
      subtitle: json['subtitle'] as String?,
      subtitleFa: json['subtitle_fa'] as String?,
      subtitlePs: json['subtitle_ps'] as String?,
      localizedSubtitle: json['localized_subtitle'] as String?,
    );
  }

  String? get displayTitle {
    final en = title ?? '';
    if (en.trim().isEmpty && (localizedTitle == null || localizedTitle!.trim().isEmpty)) {
      return null;
    }
    return LocalizedContent.pick(
      en: en,
      fa: titleFa,
      ps: titlePs,
      localizedFromApi: localizedTitle,
    );
  }

  String? get displaySubtitle {
    final en = subtitle ?? '';
    if (en.trim().isEmpty && (localizedSubtitle == null || localizedSubtitle!.trim().isEmpty)) {
      return null;
    }
    return LocalizedContent.pickNullable(
      en: en,
      fa: subtitleFa,
      ps: subtitlePs,
      localizedFromApi: localizedSubtitle,
    );
  }
}
