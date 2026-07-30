import '../utils/json_parse.dart';
import 'localized_content.dart';

/// Shared localized name/description fields parsed from API JSON.
class LocalizedEntityFields {
  const LocalizedEntityFields({
    required this.name,
    this.nameFa,
    this.namePs,
    this.localizedName,
    this.description,
    this.descriptionFa,
    this.descriptionPs,
    this.localizedDescription,
    this.isRestaurantBrand = false,
  });

  final String name;
  final String? nameFa;
  final String? namePs;
  final String? localizedName;
  final String? description;
  final String? descriptionFa;
  final String? descriptionPs;
  final String? localizedDescription;
  final bool isRestaurantBrand;

  factory LocalizedEntityFields.fromJson(
    Map<String, dynamic> json, {
    bool isRestaurantBrand = false,
  }) {
    return LocalizedEntityFields(
      name: JsonParse.stringFrom(json['name']) ?? '',
      nameFa: JsonParse.stringFrom(json['name_fa']),
      namePs: JsonParse.stringFrom(json['name_ps']),
      localizedName: JsonParse.stringFrom(json['localized_name']),
      description: JsonParse.stringFrom(json['description']),
      descriptionFa: JsonParse.stringFrom(json['description_fa']),
      descriptionPs: JsonParse.stringFrom(json['description_ps']),
      localizedDescription: JsonParse.stringFrom(json['localized_description']),
      isRestaurantBrand: isRestaurantBrand,
    );
  }

  String displayNameFor(String localeCode) => isRestaurantBrand
      ? LocalizedContent.restaurantDisplayName(
          en: name,
          fa: nameFa,
          ps: namePs,
          localizedFromApi: localizedName,
          localeCode: localeCode,
        )
      : LocalizedContent.pick(
          en: name,
          fa: nameFa,
          ps: namePs,
          localizedFromApi: localizedName,
          localeCode: localeCode,
        );

  String? displayDescriptionFor(String localeCode) => LocalizedContent.pickDescriptionNullable(
        en: description,
        fa: descriptionFa,
        ps: descriptionPs,
        localizedFromApi: localizedDescription,
        localeCode: localeCode,
      );

  String get displayName => displayNameFor(LocalizedContent.currentLocaleCode);

  String? get displayDescription => displayDescriptionFor(LocalizedContent.currentLocaleCode);
}
