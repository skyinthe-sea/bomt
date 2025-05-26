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

  /// 아기와 사용자에 대해 표시해야 할 알럿이 있는지 확인
  Future<BabyGuide?> checkForPendingAlert(String userId, Baby baby) async {
    try {
      final localeInfo = await _localeService.getLocaleInfo();
      final countryCode = localeInfo['countryCode']!;
      final languageCode = localeInfo['languageCode']!;

      final currentWeek = calculateWeekNumber(baby.birthDate);
      
      // 0주차부터 현재 주차까지 중에서 아직 보지 않은 가장 높은 주차 찾기
      for (int week = currentWeek; week >= 0; week--) {
        final hasSeenAlert = await hasUserSeenAlert(
          userId,
          baby.id,
          week,
          countryCode,
          languageCode,
        );

        if (!hasSeenAlert) {
          final guide = await getGuideForWeek(week, countryCode, languageCode);
          if (guide != null) {
            return guide;
          }
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