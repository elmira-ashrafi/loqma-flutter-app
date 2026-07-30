import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontHelper {
  static const String pashtoLanguageCode = 'ps';
  static const String dariLanguageCode = 'fa';
  static const String arabicLanguageCode = 'ar';

  static final Map<String, TextStyle> _styleCache = {};
  static const int _maxCacheEntries = 400;

  /// Detects if the text contains Pashto, Dari, or Arabic characters
  static bool containsRTLText(String text) {
    if (text.isEmpty) return false;
    
    // Unicode ranges for Arabic script (includes Pashto, Dari, Arabic)
    for (int i = 0; i < text.length; i++) {
      int codeUnit = text.codeUnitAt(i);
      
      // Arabic script range: U+0600 to U+06FF
      if (codeUnit >= 0x0600 && codeUnit <= 0x06FF) return true;
      
      // Arabic Supplement range: U+0750 to U+077F
      if (codeUnit >= 0x0750 && codeUnit <= 0x077F) return true;
      
      // Arabic Extended-A range: U+08A0 to U+08FF
      if (codeUnit >= 0x08A0 && codeUnit <= 0x08FF) return true;
      
      // Arabic Presentation Forms-A: U+FB50 to U+FDFF
      if (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) return true;
      
      // Arabic Presentation Forms-B: U+FE70 to U+FEFF
      if (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF) return true;
    }
    return false;
  }

  /// Gets the appropriate font family based on language code or text content
  static String getFontFamily(String? languageCode, String text) {
    // Check language code first
    if (languageCode != null) {
      if (languageCode == pashtoLanguageCode || 
          languageCode == dariLanguageCode || 
          languageCode == arabicLanguageCode) {
        return 'Noto Kufi Arabic';
      }
    }
    
    // Fallback to text detection
    if (containsRTLText(text)) {
      return 'Noto Kufi Arabic';
    }
    
    // Default to Poppins for LTR languages
    return 'Poppins';
  }

  /// Gets Google Fonts TextStyle with appropriate font (cached per unique params).
  static TextStyle getTextStyle({
    required String text,
    String? languageCode,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    final cacheKey = '${languageCode ?? ''}|$fontSize|${fontWeight.index}|${color.toARGB32()}';
    final cached = _styleCache[cacheKey];
    if (cached != null) return cached;

    final fontFamily = getFontFamily(languageCode, text);
    final style = fontFamily == 'Noto Kufi Arabic'
        ? GoogleFonts.notoKufiArabic(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          )
        : GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          );

    if (_styleCache.length >= _maxCacheEntries) {
      _styleCache.clear();
    }
    _styleCache[cacheKey] = style;
    return style;
  }

  /// Gets font family based on language code only
  static String getFontFamilyByLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case pashtoLanguageCode:
      case dariLanguageCode:
      case arabicLanguageCode:
        return 'Noto Kufi Arabic';
      default:
        // return 'Poppins';
        return 'Noto Kufi Arabic';
    }
  }
}
