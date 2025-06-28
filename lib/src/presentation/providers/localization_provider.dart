import 'package:flutter/foundation.dart';
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
    debugPrint('🌍 [LocalizationProvider] Language change requested: ${_currentLocale.languageCode} → ${locale.languageCode}');
    if (_currentLocale.languageCode != locale.languageCode) {
      debugPrint('🌍 [LocalizationProvider] Executing language change...');
      await _changeLanguageUseCase.execute(locale);
      _currentLocale = locale;
      debugPrint('🌍 [LocalizationProvider] Language changed, notifying listeners');
      notifyListeners();
    } else {
      debugPrint('🌍 [LocalizationProvider] Same language, no change needed');
    }
  }
  
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'hi':
        return 'हिन्दी';
      case 'de':
        return 'Deutsch';
      case 'pt':
        return 'Português';
      case 'fr':
        return 'Français';
      case 'id':
        return 'Bahasa Indonesia';
      case 'es':
        return 'Español';
      case 'tl':
        return 'Filipino';
      case 'ru':
        return 'Русский';
      case 'th':
        return 'ไทย';
      case 'tr':
        return 'Türkçe';
      default:
        return languageCode;
    }
  }
}