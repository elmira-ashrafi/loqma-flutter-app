import '../../restaurants/models/restaurant_detail_model.dart';

/// Display model for a menu item card — resolves name/description for [localeCode].
class MenuItemDisplay {
  const MenuItemDisplay.fromModel(
    this.model, {
    this.localeCode,
    this.oldPrice,
    this.discountPercent,
    this.promoCode,
  });

  final MenuItemModel model;
  final String? localeCode;
  final double? oldPrice;
  final int? discountPercent;
  final String? promoCode;

  int get id => model.id;
  String? get image => model.image;
  double get price => model.price;

  String nameFor(String languageCode) => model.displayNameFor(languageCode);

  String? descriptionFor(String languageCode) => model.displayDescriptionFor(languageCode);

  String get name => localeCode == null ? model.displayName : nameFor(localeCode!);

  String? get description =>
      localeCode == null ? model.displayDescription : descriptionFor(localeCode!);

  bool get hasSelectableSizes => model.hasSelectableSizes;

  bool get needsCustomization =>
      hasSelectableSizes || model.addons.isNotEmpty;

  /// Search across all stored language variants.
  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final fields = model.localized;
    for (final value in [
      fields.name,
      fields.nameFa,
      fields.namePs,
      fields.description,
      fields.descriptionFa,
      fields.descriptionPs,
    ]) {
      if (value != null && value.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}
