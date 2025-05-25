import 'package:flutter/material.dart';
import '../../domain/use_cases/localization/change_language_use_case.dart';

class LocalizationProvider extends ChangeNotifier {
  final ChangeLanguageUseCase _changeLanguageUseCase;
  
  Locale _currentLocale = const Locale('ko');
  
  LocalizationProvider(this._changeLanguageUseCase) {
    _loadCurrentLocale();
  }
  
  Locale get currentLocale => _currentLocale;
  
  List<Locale> get supportedLocales => _changeLanguageUseCase.getSupportedLocales();
  
  Future<void> _loadCurrentLocale() async {
    _currentLocale = await _changeLanguageUseCase.getCurrentLocale();
    notifyListeners();
  }
  
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale.languageCode != locale.languageCode) {
      await _changeLanguageUseCase.execute(locale);
      _currentLocale = locale;
      notifyListeners();
    }
  }
  
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'hi':
        return 'हिन्दी';
      default:
        return languageCode;
    }
  }
}