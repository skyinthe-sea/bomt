import 'package:flutter/material.dart';
import '../../services/theme/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;
  late ThemeMode _themeMode;
  
  ThemeProvider(this._themeService) {
    _themeMode = _themeService.getThemeMode();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _themeService.setThemeMode(mode);
    notifyListeners();
  }
}