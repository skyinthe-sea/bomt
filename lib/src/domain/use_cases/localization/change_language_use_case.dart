import 'package:flutter/material.dart';
import '../../repositories/localization_repository.dart';

class ChangeLanguageUseCase {
  final LocalizationRepository _repository;
  
  ChangeLanguageUseCase(this._repository);
  
  Future<void> execute(Locale locale) async {
    await _repository.setLocale(locale);
  }
  
  Future<Locale> getCurrentLocale() async {
    return await _repository.getLocale();
  }
  
  List<Locale> getSupportedLocales() {
    return _repository.getSupportedLocales();
  }
}