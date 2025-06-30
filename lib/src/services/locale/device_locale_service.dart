import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DeviceLocaleService {
  static DeviceLocaleService? _instance;
  static DeviceLocaleService get instance => _instance ??= DeviceLocaleService._();
  
  DeviceLocaleService._();

  /// 현재 기기의 로케일 정보 가져오기
  Locale get deviceLocale {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  /// 현재 기기의 국가 코드 가져오기 (예: KR, US, JP)
  String get countryCode {
    return deviceLocale.countryCode ?? 'Unknown';
  }

  /// 현재 기기의 언어 코드 가져오기 (예: ko, en, ja)
  String get languageCode {
    return deviceLocale.languageCode;
  }

  /// 플랫폼 정보와 함께 상세 정보 가져오기
  Map<String, dynamic> getDeviceInfo() {
    final locale = deviceLocale;
    
    return {
      'countryCode': locale.countryCode ?? 'Unknown',
      'languageCode': locale.languageCode,
      'scriptCode': locale.scriptCode,
      'fullLocale': locale.toString(),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
    };
  }

  /// 특정 국가인지 확인
  bool isCountry(String targetCountryCode) {
    return countryCode.toUpperCase() == targetCountryCode.toUpperCase();
  }

  /// 한국인지 확인
  bool get isKorea {
    return isCountry('KR');
  }

  /// 미국인지 확인
  bool get isUSA {
    return isCountry('US');
  }

  /// 일본인지 확인
  bool get isJapan {
    return isCountry('JP');
  }

  /// 중국인지 확인
  bool get isChina {
    return isCountry('CN');
  }

  /// 아시아 지역인지 확인 (간단한 예시)
  bool get isAsia {
    const asianCountries = ['KR', 'JP', 'CN', 'TH', 'VN', 'PH', 'ID', 'MY', 'SG', 'TW', 'HK', 'IN'];
    return asianCountries.contains(countryCode.toUpperCase());
  }

  /// 유럽 지역인지 확인 (간단한 예시)
  bool get isEurope {
    const europeanCountries = ['DE', 'FR', 'ES', 'IT', 'GB', 'NL', 'BE', 'AT', 'CH', 'SE', 'NO', 'DK', 'FI'];
    return europeanCountries.contains(countryCode.toUpperCase());
  }

  /// 아메리카 지역인지 확인 (간단한 예시)
  bool get isAmerica {
    const americanCountries = ['US', 'CA', 'MX', 'BR', 'AR', 'CL', 'CO', 'PE', 'VE'];
    return americanCountries.contains(countryCode.toUpperCase());
  }

  /// 지역별 기본 통화 가져오기
  String getDefaultCurrency() {
    switch (countryCode.toUpperCase()) {
      case 'KR':
        return 'KRW';
      case 'US':
        return 'USD';
      case 'JP':
        return 'JPY';
      case 'CN':
        return 'CNY';
      case 'GB':
        return 'GBP';
      case 'DE':
      case 'FR':
      case 'ES':
      case 'IT':
      case 'NL':
      case 'BE':
      case 'AT':
        return 'EUR';
      default:
        return 'USD'; // 기본값
    }
  }

  /// 지역별 기본 시간대 가져오기
  String getDefaultTimezone() {
    switch (countryCode.toUpperCase()) {
      case 'KR':
        return 'Asia/Seoul';
      case 'US':
        return 'America/New_York'; // 동부 시간 기준
      case 'JP':
        return 'Asia/Tokyo';
      case 'CN':
        return 'Asia/Shanghai';
      case 'GB':
        return 'Europe/London';
      case 'DE':
        return 'Europe/Berlin';
      case 'FR':
        return 'Europe/Paris';
      default:
        return 'UTC';
    }
  }

  /// 개발/디버그용 정보 로깅
  void logDeviceInfo() {
    if (kDebugMode) {
      final info = getDeviceInfo();
      debugPrint('=== Device Locale Info ===');
      debugPrint('Country Code: ${info['countryCode']}');
      debugPrint('Language Code: ${info['languageCode']}');
      debugPrint('Full Locale: ${info['fullLocale']}');
      debugPrint('Platform: ${info['platform']}');
      debugPrint('Platform Version: ${info['platformVersion']}');
      debugPrint('Is Korea: $isKorea');
      debugPrint('Is Asia: $isAsia');
      debugPrint('Default Currency: ${getDefaultCurrency()}');
      debugPrint('Default Timezone: ${getDefaultTimezone()}');
      debugPrint('========================');
    }
  }
}