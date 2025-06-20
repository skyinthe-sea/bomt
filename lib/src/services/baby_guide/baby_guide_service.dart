import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../locale/locale_service.dart';
import '../../domain/models/baby.dart';
import '../../domain/models/baby_guide.dart';

class BabyGuideService {
  static BabyGuideService? _instance;
  static BabyGuideService get instance => _instance ??= BabyGuideService._();
  BabyGuideService._();

  final _supabase = Supabase.instance.client;
  final _localeService = LocaleService.instance;

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
      final response = await _supabase
          .from('baby_guides')
          .select()
          .eq('week_number', weekNumber)
          .eq('country_code', countryCode)
          .eq('language_code', languageCode)
          .limit(1);

      if (response.isEmpty) {
        // 해당 언어가 없으면 영어로 fallback
        if (languageCode != 'en') {
          return await getGuideForWeek(weekNumber, countryCode, 'en');
        }
        // 영어도 없으면 한국어로 fallback
        if (countryCode != 'KR' || languageCode != 'ko') {
          return await getGuideForWeek(weekNumber, 'KR', 'ko');
        }
        return null;
      }

      return BabyGuide.fromJson(response.first);
    } catch (e) {
      debugPrint('Error getting guide for week $weekNumber: $e');
      return null;
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
      final localeInfo = await _localeService.getLocaleInfo();
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
      final localeInfo = await _localeService.getLocaleInfo();
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