import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../locale/locale_service.dart';
import '../../domain/models/baby.dart';
import '../../domain/models/baby_guide.dart';

class BabyGuideService {
  static BabyGuideService? _instance;
  static BabyGuideService get instance => _instance ??= BabyGuideService._();
  BabyGuideService._();

  final _supabase = Supabase.instance.client;
  final _localeService = LocaleService.instance;

  /// 사용자 설정 언어를 우선적으로 사용하여 로케일 정보 가져오기
  Future<Map<String, String>> getUserLocaleInfo() async {
    try {
      // 사용자가 설정한 언어를 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final userLanguage = prefs.getString('selected_language');
      
      debugPrint('🔍 [BabyGuideService] UserLanguage from SharedPreferences: $userLanguage');
      debugPrint('🔍 [BabyGuideService] All SharedPreferences keys: ${prefs.getKeys()}');
      
      if (userLanguage != null) {
        // 언어 코드에 따른 국가 코드 매핑
        String countryCode;
        switch (userLanguage) {
          case 'ko':
            countryCode = 'KR';
            break;
          case 'en':
            countryCode = 'US';
            break;
          case 'ja':
            countryCode = 'JP';
            break;
          case 'de':
            countryCode = 'DE';
            break;
          case 'pt':
            countryCode = 'BR';
            break;
          case 'fr':
            countryCode = 'FR';
            break;
          case 'id':
            countryCode = 'ID';
            break;
          case 'es':
            countryCode = 'MX';
            break;
          case 'tl':
            countryCode = 'PH';
            break;
          case 'ru':
            countryCode = 'RU';
            break;
          case 'th':
            countryCode = 'TH';
            break;
          case 'tr':
            countryCode = 'TR';
            break;
          default:
            countryCode = 'KR';
        }
        
        final result = {
          'countryCode': countryCode,
          'languageCode': userLanguage,
        };
        debugPrint('🎯 [BabyGuideService] Using user locale: $result');
        return result;
      }
    } catch (e) {
      debugPrint('❌ [BabyGuideService] Error getting user locale info: $e');
    }
    
    // 사용자 설정이 없으면 시스템 로케일 사용
    final systemLocale = await _localeService.getLocaleInfo();
    debugPrint('🔄 [BabyGuideService] Using system locale fallback: $systemLocale');
    return systemLocale;
  }

  /// 아기의 현재 주령 계산 (0주차부터 시작)
  int calculateWeekNumber(DateTime birthDate) {
    final now = DateTime.now();
    final daysDifference = now.difference(birthDate).inDays;
    final weekNumber = daysDifference ~/ 7; // 7일 = 1주
    return weekNumber < 0 ? 0 : weekNumber; // 음수 방지
  }

  /// 특정 주차의 가이드 정보 가져오기
  Future<BabyGuide?> getGuideForWeek(
    int weekNumber,
    String countryCode,
    String languageCode,
  ) async {
    try {
      debugPrint('Fetching guide for week $weekNumber, country: $countryCode, language: $languageCode');
      
      final response = await _supabase
          .from('baby_guides')
          .select()
          .eq('week_number', weekNumber)
          .eq('country_code', countryCode)
          .eq('language_code', languageCode)
          .limit(1);

      if (response.isNotEmpty) {
        debugPrint('Found guide for week $weekNumber with $countryCode/$languageCode');
        return BabyGuide.fromJson(response.first);
      }

      // Fallback 로직 개선
      return await _getGuideWithFallback(weekNumber, countryCode, languageCode);
    } catch (e) {
      debugPrint('Error getting guide for week $weekNumber: $e');
      return null;
    }
  }

  /// 개선된 fallback 로직
  Future<BabyGuide?> _getGuideWithFallback(
    int weekNumber,
    String originalCountryCode,
    String originalLanguageCode,
  ) async {
    try {
      // 1. 같은 언어의 다른 국가 시도
      if (originalLanguageCode != 'ko' && originalLanguageCode != 'en') {
        final fallbackCountryCode = _getDefaultCountryForLanguage(originalLanguageCode);
        if (fallbackCountryCode != originalCountryCode) {
          debugPrint('Trying fallback: same language ($originalLanguageCode) with country $fallbackCountryCode');
          final response = await _supabase
              .from('baby_guides')
              .select()
              .eq('week_number', weekNumber)
              .eq('country_code', fallbackCountryCode)
              .eq('language_code', originalLanguageCode)
              .limit(1);
          
          if (response.isNotEmpty) {
            debugPrint('Found guide with fallback country');
            return BabyGuide.fromJson(response.first);
          }
        }
      }

      // 2. 영어로 fallback (US 우선, 없으면 다른 영어권)
      if (originalLanguageCode != 'en') {
        debugPrint('Trying English fallback for week $weekNumber');
        final response = await _supabase
            .from('baby_guides')
            .select()
            .eq('week_number', weekNumber)
            .eq('country_code', 'US')
            .eq('language_code', 'en')
            .limit(1);
        
        if (response.isNotEmpty) {
          debugPrint('Found English guide for week $weekNumber');
          return BabyGuide.fromJson(response.first);
        }
      }

      // 3. 한국어로 최종 fallback
      if (originalCountryCode != 'KR' || originalLanguageCode != 'ko') {
        debugPrint('Trying Korean fallback for week $weekNumber');
        final response = await _supabase
            .from('baby_guides')
            .select()
            .eq('week_number', weekNumber)
            .eq('country_code', 'KR')
            .eq('language_code', 'ko')
            .limit(1);
        
        if (response.isNotEmpty) {
          debugPrint('Found Korean guide for week $weekNumber');
          return BabyGuide.fromJson(response.first);
        }
      }

      debugPrint('No guide found for week $weekNumber with any fallback');
      return null;
    } catch (e) {
      debugPrint('Error in fallback logic: $e');
      return null;
    }
  }

  /// 언어 코드에 따른 기본 국가 코드 반환
  String _getDefaultCountryForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ko': return 'KR';
      case 'en': return 'US';
      case 'ja': return 'JP';
      case 'de': return 'DE';
      case 'pt': return 'BR';
      case 'fr': return 'FR';
      case 'id': return 'ID';
      case 'es': return 'MX';
      case 'tl': return 'PH';
      case 'ru': return 'RU';
      case 'th': return 'TH';
      case 'tr': return 'TR';
      case 'hi': return 'IN';
      default: return 'KR';
    }
  }

  /// 사용자가 특정 주차 알럿을 이미 봤는지 확인
  Future<bool> hasUserSeenAlert(
    String userId,
    String babyId,
    int weekNumber,
    String countryCode,
    String languageCode,
  ) async {
    try {
      final response = await _supabase
          .from('user_guide_alerts')
          .select('id')
          .eq('user_id', userId)
          .eq('baby_id', babyId)
          .eq('week_number', weekNumber)
          .eq('country_code', countryCode)
          .eq('language_code', languageCode)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking alert status: $e');
      return true; // 에러 시 이미 본 것으로 처리
    }
  }

  /// 알럿을 본 것으로 기록
  Future<void> markAlertAsSeen(
    String userId,
    String babyId,
    int weekNumber,
    String countryCode,
    String languageCode,
  ) async {
    try {
      await _supabase.from('user_guide_alerts').insert({
        'user_id': userId,
        'baby_id': babyId,
        'week_number': weekNumber,
        'country_code': countryCode,
        'language_code': languageCode,
      });
    } catch (e) {
      debugPrint('Error marking alert as seen: $e');
    }
  }

  /// 사용자가 특정 아기에 대해 어떤 알럿이라도 본 적이 있는지 확인
  Future<bool> _hasSeenAnyAlert(
    String userId,
    String babyId,
    String countryCode,
    String languageCode,
  ) async {
    try {
      final response = await _supabase
          .from('user_guide_alerts')
          .select('id')
          .eq('user_id', userId)
          .eq('baby_id', babyId)
          .eq('country_code', countryCode)
          .eq('language_code', languageCode)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user has seen any alert: $e');
      return false; // 에러 시 새로운 사용자로 처리
    }
  }

  /// 아기와 사용자에 대해 표시해야 할 알럿이 있는지 확인
  Future<BabyGuide?> checkForPendingAlert(String userId, Baby baby) async {
    try {
      final localeInfo = await getUserLocaleInfo();
      final countryCode = localeInfo['countryCode']!;
      final languageCode = localeInfo['languageCode']!;

      final currentWeek = calculateWeekNumber(baby.birthDate);
      
      // 새로 등록한 아기인지 확인 (한 번도 알럿을 본 적이 없는지 체크)
      final hasSeenAnyAlert = await _hasSeenAnyAlert(userId, baby.id, countryCode, languageCode);
      
      if (!hasSeenAnyAlert) {
        // 새로 등록한 아기의 경우 현재 주차만 표시
        final hasSeenCurrentWeek = await hasUserSeenAlert(
          userId,
          baby.id,
          currentWeek,
          countryCode,
          languageCode,
        );
        
        if (!hasSeenCurrentWeek) {
          final guide = await getGuideForWeek(currentWeek, countryCode, languageCode);
          if (guide != null) {
            return guide;
          }
        }
        return null;
      }
      
      // 기존 사용자의 경우 다음 주차 알럿 표시 (기존 로직)
      // 현재 주차부터 확인하여 아직 보지 않은 다음 주차 찾기
      final hasSeenCurrentWeek = await hasUserSeenAlert(
        userId,
        baby.id,
        currentWeek,
        countryCode,
        languageCode,
      );
      
      if (!hasSeenCurrentWeek) {
        final guide = await getGuideForWeek(currentWeek, countryCode, languageCode);
        if (guide != null) {
          return guide;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error checking for pending alert: $e');
      return null;
    }
  }

  /// 알럿 표시 후 처리
  Future<void> handleAlertShown(String userId, Baby baby, BabyGuide guide) async {
    try {
      final localeInfo = await getUserLocaleInfo();
      await markAlertAsSeen(
        userId,
        baby.id,
        guide.weekNumber,
        localeInfo['countryCode']!,
        localeInfo['languageCode']!,
      );
    } catch (e) {
      debugPrint('Error handling alert shown: $e');
    }
  }
}