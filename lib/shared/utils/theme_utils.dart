import 'package:flutter/material.dart';

class ThemeUtils {
  static ThemeMode staticThemeDataFromString(String? mode) {
    switch (mode) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      case 'System':
      default:
        return ThemeMode.system;
    }
  }

  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }
}
