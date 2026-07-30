/// Normalizes JSON values from Dio / `jsonDecode` (often `Map<dynamic, dynamic>`).
abstract final class JsonParse {
  static Map<String, dynamic> mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String? stringFrom(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static List<Map<String, dynamic>> listOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(mapFrom)
        .toList();
  }
}
