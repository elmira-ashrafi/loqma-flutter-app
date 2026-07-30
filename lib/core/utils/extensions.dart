/// Extensions and helpers for API / JSON parsing.
extension MapX on Map<String, dynamic> {
  String? getString(String key) {
    final v = this[key];
    if (v == null) return null;
    return v.toString();
  }

  int? getInt(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  double? getDouble(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  bool? getBool(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return null;
  }
}
