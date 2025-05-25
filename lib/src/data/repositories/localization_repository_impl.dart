import 'package:flutter/material.dart';
import '../../domain/repositories/localization_repository.dart';
import '../../services/localization/localization_service.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationService _localizationService;
  
  LocalizationRepositoryImpl(this._localizationService);
  
  @override
  Future<Locale> getLocale() async {
    return await _localizationService.getLocale();
  }
  
  @override
  Future<void> setLocale(Locale locale) async {
    await _localizationService.setLocale(locale);
  }
  
  @override
  Future<String> getCurrentLanguageCode() async {
    return await _localizationService.getCurrentLanguageCode();
  }
  
  @override
  List<Locale> getSupportedLocales() {
    return _localizationService.getSupportedLocales();
  }
}