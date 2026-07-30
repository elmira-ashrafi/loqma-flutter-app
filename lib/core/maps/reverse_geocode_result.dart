/// Structured address from server reverse geocoding.
class ReverseGeocodeResult {
  const ReverseGeocodeResult({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.street,
    this.area,
    this.city,
    this.building,
  });

  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? street;
  final String? area;
  final String? city;
  final String? building;

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    return ReverseGeocodeResult(
      latitude: parseCoord(json['latitude']) ?? 0,
      longitude: parseCoord(json['longitude']) ?? 0,
      formattedAddress: json['formatted_address'] as String?,
      street: json['street'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      building: json['building'] as String?,
    );
  }
}
