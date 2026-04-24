import 'package:flutter/material.dart';

class LocaleUtils {
  static Locale stringToLocale(String langCode) {
    return Locale(langCode);
  }

  static String localeToString(Locale locale) {
    return locale.languageCode;
  }
}
