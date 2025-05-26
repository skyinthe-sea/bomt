import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart';

class LocaleService {
  static LocaleService? _instance;
  static LocaleService get instance => _instance ??= LocaleService._();
  LocaleService._();

  String? _countryCode;
  String? _languageCode;

  /// 국가 코드 초기화 및 가져오기
  Future<String> getCountryCode() async {
    if (_countryCode != null) return _countryCode!;

    try {
      // 플랫폼 로케일에서 국가 코드 가져오기
      final locale = ui.PlatformDispatcher.instance.locale;
      _countryCode = locale.countryCode?.toUpperCase();
      
      // 국가 코드가 없으면 플랫폼별 추가 시도
      if (_countryCode == null || _countryCode!.isEmpty) {
        if (Platform.isAndroid || Platform.isIOS) {
          // 모바일 플랫폼에서는 언어 코드를 기반으로 추정
          final languageCode = locale.languageCode.toLowerCase();
          switch (languageCode) {
            case 'ko':
              _countryCode = 'KR';
              break;
            case 'ja':
              _countryCode = 'JP';
              break;
            case 'zh':
              _countryCode = 'CN';
              break;
            case 'en':
              _countryCode = 'US';
              break;
            default:
              _countryCode = 'KR'; // 기본값
          }
        } else {
          _countryCode = 'KR'; // 기본값
        }
      }
    } catch (e) {
      debugPrint('Error getting country code: $e');
      _countryCode = 'KR'; // 기본값으로 한국 설정
    }

    return _countryCode!;
  }

  /// 언어 코드 가져오기
  String getLanguageCode() {
    if (_languageCode != null) return _languageCode!;

    try {
      // 시스템 로케일에서 언어 코드 가져오기
      final locale = ui.PlatformDispatcher.instance.locale;
      _languageCode = locale.languageCode.toLowerCase();
      
      // 지원하지 않는 언어는 한국어로 기본 설정
      if (!['ko', 'en', 'ja', 'zh'].contains(_languageCode)) {
        _languageCode = 'ko';
      }
    } catch (e) {
      debugPrint('Error getting language code: $e');
      _languageCode = 'ko';
    }

    return _languageCode!;
  }

  /// 국가별 권장 사항이 다를 수 있으므로 국가 + 언어 조합 반환
  Future<Map<String, String>> getLocaleInfo() async {
    final countryCode = await getCountryCode();
    final languageCode = getLanguageCode();
    
    return {
      'countryCode': countryCode,
      'languageCode': languageCode,
    };
  }

  /// 캐시 초기화 (테스트 용도)
  void reset() {
    _countryCode = null;
    _languageCode = null;
  }
}