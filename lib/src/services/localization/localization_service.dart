import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  
  final SharedPreferences _prefs;
  
  LocalizationService(this._prefs);
  
  Future<Locale> getLocale() async {
    final languageCode = _prefs.getString(_languageKey) ?? 'ko';
    return Locale(languageCode);
  }
  
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_languageKey, locale.languageCode);
  }
  
  Future<String> getCurrentLanguageCode() async {
    return _prefs.getString(_languageKey) ?? 'ko';
  }
  
  List<Locale> getSupportedLocales() {
    return const [
      Locale('ko'),
      Locale('en'),
      Locale('zh'),
      Locale('ja'),
      Locale('hi'),
    ];
  }
}