import 'package:geocoding/geocoding.dart';

import 'address_text_utils.dart';

/// Fields extracted from a device [Placemark], with Plus Codes removed.
class ParsedPlacemarkAddress {
  const ParsedPlacemarkAddress({
    this.street = '',
    this.area = '',
    this.building,
    this.placeName,
  });

  final String street;
  final String area;
  final String? building;

  /// POI / neighbourhood name when available (e.g. market, district).
  final String? placeName;

  bool get hasMeaningfulStreet => street.trim().isNotEmpty;
  bool get hasMeaningfulArea => area.trim().isNotEmpty;
}

abstract final class AddressPlacemarkParser {
  static ParsedPlacemarkAddress parse(Placemark p) {
    final building = AddressTextUtils.meaningfulLine(p.subThoroughfare);
    final thoroughfare = AddressTextUtils.meaningfulLine(p.thoroughfare);
    final streetField = AddressTextUtils.meaningfulLine(p.street);
    final name = AddressTextUtils.meaningfulLine(p.name);

    String street = '';
    if (streetField != null) {
      street = streetField;
    } else if (thoroughfare != null) {
      street = building != null ? '$building $thoroughfare' : thoroughfare;
    } else if (name != null && !_looksLikeAreaName(name, p)) {
      street = name;
    }

    final area = _areaFromPlacemark(p);
    final placeName = name != null && name != street ? name : null;

    return ParsedPlacemarkAddress(
      street: street,
      area: area,
      building: building != null && street.contains(building) ? null : building,
      placeName: placeName,
    );
  }

  static String _areaFromPlacemark(Placemark p) {
    for (final raw in [
      p.subLocality,
      p.locality,
      p.subAdministrativeArea,
      p.administrativeArea,
    ]) {
      final line = AddressTextUtils.meaningfulLine(raw);
      if (line != null) return line;
    }
    return '';
  }

  static bool _looksLikeAreaName(String name, Placemark p) {
    final n = name.toLowerCase();
    for (final raw in [p.subLocality, p.locality, p.subAdministrativeArea]) {
      final t = raw?.trim().toLowerCase();
      if (t != null && t.isNotEmpty && t == n) return true;
    }
    return false;
  }
}
