/// Phone shown in UI without `+` (RTL-friendly). Add `+` for E.164 only when calling APIs if needed.
String displayPhoneWithoutPlus(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return raw.trim().replaceAll('+', '');
}

/// Afghan numbers: strip country code **93**, show local style with leading **0**
/// (e.g. `+93778942211` → `0778942211`). Other formats fall back to digits only.
String displayAfghanLocalPhone(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';

  var national = digits;
  if (national.startsWith('93') && national.length > 2) {
    national = national.substring(2);
  }

  if (national.isEmpty) return '';

  if (national.startsWith('0')) {
    return national;
  }
  return '0$national';
}
