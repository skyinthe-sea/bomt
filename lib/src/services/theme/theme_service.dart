import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  final SharedPreferences _prefs;
  
  ThemeService(this._prefs);
  
  ThemeMode getThemeMode() {
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeKey, mode.index);
  }
  
  bool isDarkMode() {
    return getThemeMode() == ThemeMode.dark;
  }
}