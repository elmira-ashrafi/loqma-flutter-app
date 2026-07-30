import 'package:equatable/equatable.dart';

import '../../../core/l10n/localized_city_fields.dart';
import '../../../core/maps/address_text_utils.dart';

class AddressModel extends Equatable {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    this.cityId,
    this.city = const LocalizedCityFields(),
    required this.area,
    required this.street,
    this.building,
    this.floor,
    this.apartment,
    this.deliveryInstructions,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String fullName;
  final String phone;
  final int? cityId;
  final LocalizedCityFields city;
  final String area;

  String? get cityName => city.isEmpty ? null : city.name;

  String? get displayCityName => city.isEmpty ? null : city.displayName;
  final String street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? deliveryInstructions;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? city;
    final cityRaw = json['city'];
    if (cityRaw is Map) {
      city = Map<String, dynamic>.from(cityRaw);
    }
    final idVal = json['id'];
    final idInt = idVal is num ? idVal.toInt() : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    return AddressModel(
      id: idInt,
      label: json['label'] as String? ?? 'home',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      cityId: (json['city_id'] as num?)?.toInt() ??
          (json['cityId'] as num?)?.toInt() ??
          (city != null ? (city['id'] as num?)?.toInt() : null),
      city: city != null
          ? LocalizedCityFields.fromJson(city)
          : LocalizedCityFields(
              name: json['city_name'] as String? ?? '',
            ),
      area: json['area'] as String? ?? '',
      street: json['street'] as String? ?? '',
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String? ?? json['deliveryInstructions'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      isDefault: json['is_default'] as bool? ?? json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'city_id': cityId,
        'area': area,
        'street': street,
        'building': building,
        'floor': floor,
        'apartment': apartment,
        'delivery_instructions': deliveryInstructions,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };

  String get readableStreet {
    final line = AddressTextUtils.meaningfulLine(street) ?? '';
    return line;
  }

  String get geocodeQuery {
    return AddressTextUtils.joinParts([
      building,
      readableStreet,
      area,
      displayCityName,
      'Afghanistan',
    ]);
  }

  String get displayAddress {
    final cityLabel = displayCityName;
    final streetLine = readableStreet.isEmpty
        ? ''
        : (city.isEmpty ? readableStreet : city.embedInLine(readableStreet));
    final areaLine = area.trim().isEmpty
        ? ''
        : (city.isEmpty ? area : city.embedInLine(area));
    final parts = <String>[
      if (streetLine.isNotEmpty) streetLine,
      if (areaLine.isNotEmpty) areaLine,
      if (cityLabel != null &&
          cityLabel.isNotEmpty &&
          !streetLine.contains(cityLabel) &&
          !areaLine.contains(cityLabel))
        cityLabel,
    ];
    if (parts.isEmpty && placeNameHint != null) {
      parts.add(placeNameHint!);
    }
    return parts.where((e) => e.trim().isNotEmpty).join(', ');
  }

  /// Neighbourhood / POI hint when street is a Plus Code or missing.
  String? get placeNameHint {
    if (readableStreet.isNotEmpty) return null;
    final a = area.trim();
    if (a.isNotEmpty && !AddressTextUtils.isPlusCode(a)) return a;
    return null;
  }

  /// Capitalized label for UI (Home, Work, …).
  String get formattedLabel {
    final t = label.trim();
    if (t.isEmpty) return '';
    if (t.length == 1) return t.toUpperCase();
    return '${t[0].toUpperCase()}${t.substring(1).toLowerCase()}';
  }

  /// Compact line for headers: label + meaningful place (not Plus Codes).
  String get appBarSummary {
    final tag = formattedLabel;
    final addr = displayAddress.trim();
    final areaCity = AddressTextUtils.joinParts([area, displayCityName]);
    final detail = addr.isNotEmpty ? addr : areaCity;
    final name = fullName.trim();

    if (tag.isNotEmpty && detail.isNotEmpty) return '$tag · $detail';
    if (tag.isNotEmpty && name.isNotEmpty) return '$tag · $name';
    if (tag.isNotEmpty) return tag;
    if (detail.isNotEmpty && name.isNotEmpty) return '$name · $detail';
    if (detail.isNotEmpty) return detail;
    return name;
  }

  /// Truncates [appBarSummary] while keeping the label prefix when possible.
  String appBarSummaryTruncated(int maxChars) {
    final full = appBarSummary.trim();
    if (full.isEmpty || full.length <= maxChars) return full;

    const sep = ' · ';
    final sepIndex = full.indexOf(sep);
    if (sepIndex > 0) {
      final prefix = full.substring(0, sepIndex + sep.length);
      if (prefix.length < maxChars - 1) {
        final tailBudget = maxChars - prefix.length;
        final tail = full.substring(sepIndex + sep.length);
        if (tail.length <= tailBudget) return full;
        return '${prefix}${tail.substring(0, tailBudget).trimRight()}..';
      }
    }

    return '${full.substring(0, maxChars).trimRight()}..';
  }

  @override
  List<Object?> get props => [id, label];
}

class CityModel extends Equatable {
  const CityModel({
    required this.id,
    required this.localized,
    this.provinceName,
    this.districts = const [],
  });

  final int id;
  final LocalizedCityFields localized;
  final String? provinceName;
  final List<DistrictModel> districts;

  String get name => localized.name;

  String get displayName => localized.displayName;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final province = json['province'] as Map<String, dynamic>?;
    final rawDistricts = json['districts'];
    final districts = <DistrictModel>[];
    if (rawDistricts is List) {
      for (final item in rawDistricts) {
        if (item is Map<String, dynamic>) {
          districts.add(DistrictModel.fromJson(item));
        } else if (item is Map) {
          districts.add(DistrictModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CityModel(
      id: (json['id'] as num).toInt(),
      localized: LocalizedCityFields.fromJson(json),
      provinceName: province?['name'] as String?,
      districts: districts,
    );
  }

  @override
  List<Object?> get props => [id];
}

class DistrictModel extends Equatable {
  const DistrictModel({
    required this.id,
    required this.localized,
  });

  final int id;
  final LocalizedCityFields localized;

  String get name => localized.name;

  String get displayName => localized.displayName;

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: (json['id'] as num).toInt(),
      localized: LocalizedCityFields.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [id];
}
