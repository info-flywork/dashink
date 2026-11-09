import 'package:flutter/material.dart';

/// Desteklenen diller (kod → yerel ad). Sıra dil seçicisinde kullanılır.
abstract final class AppLanguages {
  static const List<(String code, String nativeName)> all = [
    ('en', 'English'),
    ('tr', 'Türkçe'),
    ('de', 'Deutsch'),
    ('fr', 'Français'),
    ('es', 'Español'),
    ('it', 'Italiano'),
    ('pt', 'Português'),
    ('nl', 'Nederlands'),
    ('pl', 'Polski'),
    ('ru', 'Русский'),
    ('uk', 'Українська'),
    ('cs', 'Čeština'),
    ('sk', 'Slovenčina'),
    ('hu', 'Magyar'),
    ('ro', 'Română'),
    ('bg', 'Български'),
    ('hr', 'Hrvatski'),
    ('sr', 'Srpski'),
    ('el', 'Ελληνικά'),
    ('sv', 'Svenska'),
    ('da', 'Dansk'),
    ('nb', 'Norsk'),
    ('fi', 'Suomi'),
    ('ja', '日本語'),
    ('ko', '한국어'),
    ('zh', '中文'),
    ('hi', 'हिन्दी'),
    ('bn', 'বাংলা'),
    ('ar', 'العربية'),
    ('fa', 'فارسی'),
    ('he', 'עברית'),
    ('th', 'ไทย'),
    ('vi', 'Tiếng Việt'),
    ('id', 'Bahasa Indonesia'),
    ('ms', 'Bahasa Melayu'),
    ('tl', 'Filipino'),
  ];

  static List<Locale> get locales => [
    for (final (code, _) in all) Locale(code),
  ];

  static String nativeName(String languageCode) {
    for (final (code, name) in all) {
      if (code == languageCode) return name;
    }
    return languageCode;
  }

  static bool isRtl(String languageCode) =>
      languageCode == 'ar' || languageCode == 'fa' || languageCode == 'he';
}
