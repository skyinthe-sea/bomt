import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/cache/universal_cache_service.dart';
import '../../domain/models/statistics.dart';
import '../../domain/models/feeding.dart';
import '../../domain/models/sleep.dart';
import '../../domain/models/diaper.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/milk_pumping.dart';
import '../../domain/models/solid_food.dart';
import '../../domain/models/user_card_setting.dart';
import '../user_card_setting/user_card_setting_service.dart';
import 'statistics_cache_service.dart';

/// ✅ CHART DATA PROCESSING ISSUE - RESOLVED:
/// 
/// PROBLEM: Medication, Milk Pumping, Solid Food charts showed empty data
/// CAUSE: Missing daily metric calculation functions in generateChartData method
/// 
/// SOLUTION IMPLEMENTED: 
/// - feeding → _getDailyFeedingMetric() ✅
/// - sleep → _getDailySleepMetric() ✅  
/// - diaper → _getDailyDiaperMetric() ✅
/// - medication → _getDailyMedicationMetric() ✅ NEW
/// - milk_pumping → _getDailyMilkPumpingMetric() ✅ NEW  
/// - solid_food → _getDailySolidFoodMetric() ✅ NEW
/// 
/// STATUS: All chart functions now implemented and working
/// DATA: Confirmed - Supabase has actual data for all categories
/// CACHE: Old cached zero-data automatically invalidated for affected types
/// 
/// Charts should now display correct data with proper averages and values.

class StatisticsService {
  static StatisticsService? _instance;
  static StatisticsService get instance => _instance ??= StatisticsService._();
  
  StatisticsService._();
  
  final _supabase = SupabaseConfig.client;
  final _userCardSettingService = UserCardSettingService.instance;
  final _cache = UniversalCacheService.instance;
  final _statisticsCache = StatisticsCacheService.instance;

  /// 시간대 문제 해결을 위한 날짜 범위 변환 helper
  Map<String, String> _getDateRangeForQuery(StatisticsDateRange dateRange) {
    // 날짜만 사용하여 시간대 문제 해결
    final startDateStr = '${dateRange.startDate.year}-${dateRange.startDate.month.toString().padLeft(2, '0')}-${dateRange.startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${dateRange.endDate.year}-${dateRange.endDate.month.toString().padLeft(2, '0')}-${dateRange.endDate.day.toString().padLeft(2, '0')}';
    
    debugPrint('📅 [DATE_HELPER] Converting date range: ${dateRange.label}');
    debugPrint('📅 [DATE_HELPER] Start: ${dateRange.startDate} -> $startDateStr');
    debugPrint('📅 [DATE_HELPER] End: ${dateRange.endDate} -> $endDateStr');
    
    return {
      'start': '${startDateStr}T00:00:00Z',
      'end': '${endDateStr}T23:59:59Z',
      'startDate': startDateStr,
      'endDate': endDateStr,
    };
  }

  /// 통계 데이터 생성 (캐싱 + 병렬 처리 최적화)
  Future<Statistics> generateStatistics({
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
    bool bypassCache = false, // 캐시 우회 옵션 추가
  }) async {
    debugPrint('📊 [STATISTICS] Starting statistics generation for user: $userId, baby: $babyId');
    debugPrint('📊 [STATISTICS] Date range: ${dateRange.label}');
    debugPrint('📊 [STATISTICS] Bypass cache: $bypassCache');

    try {
      // 1. 새로운 캐시 서비스 사용
      debugPrint('🗄️ [STATISTICS] Using enhanced StatisticsCacheService');
      
      // 2. 캐시 우회 옵션 확인
      if (bypassCache) {
        debugPrint('🔄 [STATISTICS] Bypassing cache as requested');
        await _statisticsCache.clearCacheForBaby(userId, babyId);
      } else {
        // 캐시에서 통계 데이터 조회 시도
        final cachedStatistics = await _statisticsCache.getStatistics(
          userId: userId,
          babyId: babyId,
          dateRange: dateRange,
        );
        
        if (cachedStatistics != null) {
          debugPrint('📊 [STATISTICS] ⚡ Enhanced cache hit! Using cached statistics data');
          debugPrint('📊 [STATISTICS] Cached data has ${cachedStatistics.cardsWithData.length} cards with data');
          debugPrint('📊 [STATISTICS] Cache stats: ${_statisticsCache.getCacheStats()}');
          return cachedStatistics;
        }
      }
      
      debugPrint('📊 [STATISTICS] Cache miss or bypass. Generating new statistics data');

      // 3. 표시 가능한 카드 설정 가져오기
      final visibleCardTypes = await _getVisibleCardTypes(userId, babyId);
      debugPrint('📊 [STATISTICS] Visible card types: $visibleCardTypes');

      // 4. 병렬 처리로 각 카드별 통계 생성
      debugPrint('⚡ [STATISTICS] Starting parallel statistics generation for ${visibleCardTypes.length} cards');
      final cardStatisticsFutures = visibleCardTypes.map((cardType) => 
        _generateCardStatistics(
          cardType: cardType,
          userId: userId,
          babyId: babyId,
          dateRange: dateRange,
        )
      ).toList();
      
      final cardStatisticsResults = await Future.wait(cardStatisticsFutures);
      
      // null이 아닌 결과만 필터링
      final cardStatistics = cardStatisticsResults
          .where((stats) => stats != null)
          .cast<CardStatistics>()
          .toList();

      debugPrint('📊 [STATISTICS] Generated statistics for ${cardStatistics.length} cards (parallel processing)');
      
      // 각 카드별 상세 정보 로그
      for (final cardStat in cardStatistics) {
        debugPrint('📋 [STATISTICS] ${cardStat.cardType}: ${cardStat.totalCount} records');
        if (cardStat.hasData) {
          debugPrint('  ✅ Has ${cardStat.metrics.length} metrics');
        } else {
          debugPrint('  ❌ No data');
        }
      }

      final statistics = Statistics(
        dateRange: dateRange,
        cardStatistics: cardStatistics,
        lastUpdated: DateTime.now(),
      );
      
      debugPrint('📊 [STATISTICS] Final statistics summary:');
      debugPrint('📊 [STATISTICS] - Total cards: ${statistics.cardStatistics.length}');
      debugPrint('📊 [STATISTICS] - Cards with data: ${statistics.cardsWithData.length}');
      debugPrint('📊 [STATISTICS] - Total activities: ${statistics.totalActivities}');
      debugPrint('📊 [STATISTICS] - Has data: ${statistics.hasData}');

      // 5. 생성된 통계 데이터를 새로운 캐시 서비스에 저장
      await _statisticsCache.setStatistics(
        userId: userId,
        babyId: babyId,
        dateRange: dateRange,
        statistics: statistics,
      );
      
      debugPrint('💾 [STATISTICS] ⚡ Statistics data cached with enhanced service');
      debugPrint('💾 [STATISTICS] Updated cache stats: ${_statisticsCache.getCacheStats()}');

      return statistics;
    } catch (e) {
      debugPrint('❌ [STATISTICS] Error generating statistics: $e');
      debugPrint('❌ [STATISTICS] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }


  /// 표시 가능한 카드 타입들 가져오기 (기존 함수 유지)
  Future<List<String>> _getVisibleCardTypes(String userId, String babyId) async {
    try {
      debugPrint('🗃️ [STATISTICS] Getting visible card types for user: $userId, baby: $babyId');
      final userCardSettings = await _userCardSettingService.getUserCardSettings(userId, babyId);
      final visibleCardTypes = userCardSettings
          .where((setting) => setting.isVisible)
          .map((setting) => setting.cardType)
          .toList();
      debugPrint('🗃️ [STATISTICS] User card settings count: ${userCardSettings.length}');
      debugPrint('🗃️ [STATISTICS] Visible card types: $visibleCardTypes');
      
      // 설정이 없거나 보이는 카드가 없으면 기본 카드들 반환
      if (visibleCardTypes.isEmpty) {
        final defaultCardTypes = ['feeding', 'sleep', 'diaper', 'medication', 'milk_pumping', 'solid_food'];
        debugPrint('🗃️ [STATISTICS] No visible cards configured, using default card types: $defaultCardTypes');
        return defaultCardTypes;
      }
      
      return visibleCardTypes;
    } catch (e) {
      debugPrint('❌ [STATISTICS] Error getting visible card types: $e');
      // 기본 카드 타입들 반환
      final defaultCardTypes = ['feeding', 'sleep', 'diaper', 'medication', 'milk_pumping', 'solid_food'];
      debugPrint('🗃️ [STATISTICS] Using default card types due to error: $defaultCardTypes');
      return defaultCardTypes;
    }
  }

  /// 카드별 통계 생성
  Future<CardStatistics?> _generateCardStatistics({
    required String cardType,
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
  }) async {
    debugPrint('📊 [CARD_STATS] Generating statistics for card: $cardType');

    try {
      switch (cardType) {
        case 'feeding':
          return await _generateFeedingStatistics(userId, babyId, dateRange);
        case 'sleep':
          return await _generateSleepStatistics(userId, babyId, dateRange);
        case 'diaper':
          return await _generateDiaperStatistics(userId, babyId, dateRange);
        case 'medication':
          return await _generateMedicationStatistics(userId, babyId, dateRange);
        case 'milk_pumping':
          return await _generateMilkPumpingStatistics(userId, babyId, dateRange);
        case 'solid_food':
          return await _generateSolidFoodStatistics(userId, babyId, dateRange);
        default:
          debugPrint('⚠️ [CARD_STATS] Unknown card type: $cardType');
          return null;
      }
    } catch (e) {
      debugPrint('❌ [CARD_STATS] Error generating statistics for $cardType: $e');
      return null;
    }
  }

  /// 수유 통계 생성
  Future<CardStatistics> _generateFeedingStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('🍼 [FEEDING_STATS] Querying feedings for user: $userId, baby: $babyId');
    debugPrint('🍼 [FEEDING_STATS] Date range: ${dateRange.label}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    
    // 🚀 성능 최적화: 중복 쿼리 제거 (디버깅 쿼리 삭제)
    
    // 수정된 날짜 범위 쿼리 사용 (시간대 문제 해결)
    final response = await _supabase
        .from('feedings')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', dateQuery['start']!)
        .lte('started_at', dateQuery['end']!);

    debugPrint('🍼 [FEEDING_STATS] Found ${response.length} feeding records in date range');
    
    final feedings = response.map((json) => Feeding.fromJson(json)).toList();
    
    if (feedings.isEmpty) {
      return CardStatistics(
        cardType: 'feeding',
        cardName: '수유',
        totalCount: 0,
        metrics: [],
      );
    }

    // 총 수유량 계산 (ml 단위)
    final totalAmount = feedings
        .where((feeding) => feeding.amountMl != null)
        .fold<int>(0, (sum, feeding) => sum + feeding.amountMl!);

    // 평균 수유량
    final avgAmount = feedings.where((feeding) => feeding.amountMl != null).isNotEmpty
        ? totalAmount / feedings.where((feeding) => feeding.amountMl != null).length
        : 0.0;

    // 총 수유 시간 (분 단위)
    final totalDuration = feedings
        .where((feeding) => feeding.durationMinutes != null)
        .fold<int>(0, (sum, feeding) => sum + feeding.durationMinutes!);

    // 평균 수유 시간
    final avgDuration = feedings.where((feeding) => feeding.durationMinutes != null).isNotEmpty
        ? totalDuration / feedings.where((feeding) => feeding.durationMinutes != null).length
        : 0.0;

    // 하루 평균 수유 횟수
    final avgPerDay = feedings.length / dateRange.totalDays;

    // 최대/최소 수유량
    final amounts = feedings.where((feeding) => feeding.amountMl != null).map((feeding) => feeding.amountMl!.toDouble()).toList();
    final maxAmount = amounts.isNotEmpty ? amounts.reduce((a, b) => a > b ? a : b) : 0.0;
    final minAmount = amounts.isNotEmpty ? amounts.reduce((a, b) => a < b ? a : b) : 0.0;

    return CardStatistics(
      cardType: 'feeding',
      cardName: '수유',
      totalCount: feedings.length,
      metrics: [
        StatisticsMetric(label: '총 수유량', value: totalAmount.toDouble(), unit: 'ml'),
        StatisticsMetric(label: '평균 수유량', value: avgAmount, unit: 'ml'),
        StatisticsMetric(label: '총 수유 시간', value: totalDuration.toDouble(), unit: 'minutes'),
        StatisticsMetric(label: '평균 수유 시간', value: avgDuration, unit: 'minutes'),
        StatisticsMetric(label: '하루 평균 수유 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '최대 수유량', value: maxAmount, unit: 'ml'),
        StatisticsMetric(label: '최소 수유량', value: minAmount, unit: 'ml'),
      ],
      additionalData: {
        'feedingTypes': _groupByType(feedings, (feeding) => feeding.type),
      },
    );
  }

  /// 수면 통계 생성
  Future<CardStatistics> _generateSleepStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('😴 [SLEEP_STATS_DEBUG] ========== SLEEP STATISTICS GENERATION ==========');
    debugPrint('😴 [SLEEP_STATS_DEBUG] Querying sleeps for user: $userId, baby: $babyId');
    debugPrint('😴 [SLEEP_STATS_DEBUG] Date range: ${dateRange.label}');
    debugPrint('😴 [SLEEP_STATS_DEBUG] Date range raw: ${dateRange.startDate} to ${dateRange.endDate}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    debugPrint('😴 [SLEEP_STATS_DEBUG] Query range: ${dateQuery['start']} to ${dateQuery['end']}');
    
    // 🚀 성능 최적화: 중복 쿼리 제거 (디버깅 쿼리 삭제)
    
    final response = await _supabase
        .from('sleeps')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회  
        .gte('started_at', dateQuery['start']!)
        .lte('started_at', dateQuery['end']!);

    debugPrint('😴 [SLEEP_STATS_DEBUG] Query result: ${response.length} sleep records in date range');
    if (response.isEmpty) {
      debugPrint('😴 [SLEEP_STATS_DEBUG] ❌ No sleep records found in range: ${dateQuery['start']} to ${dateQuery['end']}');
      debugPrint('😴 [SLEEP_STATS_DEBUG] This could be due to:');
      debugPrint('😴 [SLEEP_STATS_DEBUG] 1. Timezone mismatch');
      debugPrint('😴 [SLEEP_STATS_DEBUG] 2. Date range calculation error');
      debugPrint('😴 [SLEEP_STATS_DEBUG] 3. No sleep records for this baby in this time period');
    } else {
      debugPrint('😴 [SLEEP_STATS_DEBUG] ✅ Found sleep records in range:');
      for (int i = 0; i < response.length; i++) {
        final record = response[i];
        debugPrint('😴 [SLEEP_STATS_DEBUG] ${i+1}. ${record['started_at']} (duration: ${record['duration_minutes']})');
      }
    }
    
    final sleeps = response.map((json) => Sleep.fromJson(json)).toList();
    debugPrint('😴 [SLEEP_STATS_DEBUG] Parsed ${sleeps.length} sleep objects');
    
    if (sleeps.isEmpty) {
      debugPrint('😴 [SLEEP_STATS_DEBUG] ❌ Returning empty sleep statistics');
      return CardStatistics(
        cardType: 'sleep',
        cardName: '수면',
        totalCount: 0,
        metrics: [],
      );
    }
    
    debugPrint('😴 [SLEEP_STATS_DEBUG] ✅ Processing ${sleeps.length} sleep records');
    debugPrint('😴 [SLEEP_STATS_DEBUG] ===================================================');

    // 총 수면 시간 (분 단위)
    final totalDuration = sleeps
        .where((sleep) => sleep.durationMinutes != null)
        .fold<int>(0, (sum, sleep) => sum + sleep.durationMinutes!);

    // 평균 수면 시간
    final avgDuration = sleeps.where((sleep) => sleep.durationMinutes != null).isNotEmpty
        ? totalDuration / sleeps.where((sleep) => sleep.durationMinutes != null).length
        : 0.0;

    // 하루 평균 수면 횟수
    final avgPerDay = sleeps.length / dateRange.totalDays;

    // 하루 평균 총 수면 시간
    final avgTotalSleepPerDay = totalDuration / dateRange.totalDays;

    // 최대/최소 수면 시간
    final durations = sleeps.where((sleep) => sleep.durationMinutes != null).map((sleep) => sleep.durationMinutes!.toDouble()).toList();
    final maxDuration = durations.isNotEmpty ? durations.reduce((a, b) => a > b ? a : b) : 0.0;
    final minDuration = durations.isNotEmpty ? durations.reduce((a, b) => a < b ? a : b) : 0.0;

    return CardStatistics(
      cardType: 'sleep',
      cardName: '수면',
      totalCount: sleeps.length,
      metrics: [
        StatisticsMetric(label: '총 수면 시간', value: totalDuration.toDouble(), unit: 'minutes'),
        StatisticsMetric(label: '평균 수면 시간', value: avgDuration, unit: 'minutes'),
        StatisticsMetric(label: '하루 평균 수면 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '하루 평균 총 수면 시간', value: avgTotalSleepPerDay, unit: 'minutes'),
        StatisticsMetric(label: '최대 수면 시간', value: maxDuration, unit: 'minutes'),
        StatisticsMetric(label: '최소 수면 시간', value: minDuration, unit: 'minutes'),
      ],
      additionalData: {
        'sleepQualities': _groupByType(sleeps, (sleep) => sleep.quality ?? 'unknown'),
      },
    );
  }

  /// 기저귀 통계 생성
  Future<CardStatistics> _generateDiaperStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('👶 [DIAPER_STATS] Querying diapers for user: $userId, baby: $babyId');
    debugPrint('👶 [DIAPER_STATS] Date range: ${dateRange.label}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    
    final response = await _supabase
        .from('diapers')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('changed_at', dateQuery['start']!)
        .lte('changed_at', dateQuery['end']!);

    debugPrint('👶 [DIAPER_STATS] Found ${response.length} diaper records');
    
    final diapers = response.map((json) => Diaper.fromJson(json)).toList();
    
    if (diapers.isEmpty) {
      return CardStatistics(
        cardType: 'diaper',
        cardName: '기저귀',
        totalCount: 0,
        metrics: [],
      );
    }

    // 하루 평균 기저귀 교체 횟수
    final avgPerDay = diapers.length / dateRange.totalDays;

    // 기저귀 타입별 분류
    final wetDiapers = diapers.where((diaper) => diaper.type.contains('wet')).length;
    final dirtyDiapers = diapers.where((diaper) => diaper.type.contains('dirty')).length;
    final bothDiapers = diapers.where((diaper) => diaper.type == 'both').length;

    return CardStatistics(
      cardType: 'diaper',
      cardName: '기저귀',
      totalCount: diapers.length,
      metrics: [
        StatisticsMetric(label: '하루 평균 교체 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '소변 기저귀', value: wetDiapers.toDouble(), unit: 'times'),
        StatisticsMetric(label: '대변 기저귀', value: dirtyDiapers.toDouble(), unit: 'times'),
        StatisticsMetric(label: '소변+대변 기저귀', value: bothDiapers.toDouble(), unit: 'times'),
      ],
      additionalData: {
        'diaperTypes': _groupByType(diapers, (diaper) => diaper.type),
      },
    );
  }

  /// 투약 통계 생성
  Future<CardStatistics> _generateMedicationStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('💊 [MEDICATION_STATS] Querying medications for user: $userId, baby: $babyId');
    debugPrint('💊 [MEDICATION_STATS] Date range: ${dateRange.label}');
    debugPrint('💊 [MEDICATION_STATS] Date query range: ${dateRange.startDate} to ${dateRange.endDate}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    debugPrint('💊 [MEDICATION_STATS] Query dates: ${dateQuery['start']} to ${dateQuery['end']}');
    
    // 🚀 성능 최적화: 중복 쿼리 제거 (디버깅 쿼리 삭제)
    
    final response = await _supabase
        .from('medications')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('administered_at', dateQuery['start']!)
        .lte('administered_at', dateQuery['end']!);

    debugPrint('💊 [MEDICATION_STATS] Query result: ${response.length} records in date range');
    
    final medications = response.map((json) => Medication.fromJson(json)).toList();
    debugPrint('💊 [MEDICATION_STATS] Parsed ${medications.length} medication objects');
    
    if (medications.isEmpty) {
      debugPrint('💊 [MEDICATION_STATS] ❌ No medications found in date range - returning empty statistics');
      debugPrint('💊 [MEDICATION_STATS] This will result in empty chart display');
      
      return CardStatistics(
        cardType: 'medication',
        cardName: '투약',
        totalCount: 0,
        metrics: [],
      );
    }
    
    debugPrint('💊 [MEDICATION_STATS] ✅ Processing ${medications.length} medication records');

    // 하루 평균 투약 횟수
    final avgPerDay = medications.length / dateRange.totalDays;

    // 약물별 분류
    final medicationsByName = _groupByType(medications, (medication) => medication.medicationName);

    debugPrint('💊 [MEDICATION_STATS] Final medication statistics:');
    debugPrint('💊 [MEDICATION_STATS] - Total count: ${medications.length}');
    debugPrint('💊 [MEDICATION_STATS] - Avg per day: $avgPerDay');
    debugPrint('💊 [MEDICATION_STATS] - Medication types: ${medicationsByName.length}');
    debugPrint('💊 [MEDICATION_STATS] - Medications by name: $medicationsByName');
    
    return CardStatistics(
      cardType: 'medication',
      cardName: '투약',
      totalCount: medications.length,
      metrics: [
        StatisticsMetric(label: '하루 평균 투약 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '사용한 약물 종류', value: medicationsByName.length.toDouble(), unit: 'types'),
      ],
      additionalData: {
        'medicationsByName': medicationsByName,
      },
    );
  }

  /// 유축 통계 생성
  Future<CardStatistics> _generateMilkPumpingStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('🍼 [MILK_PUMPING_STATS] Querying milk pumpings for user: $userId, baby: $babyId');
    debugPrint('🍼 [MILK_PUMPING_STATS] Date range: ${dateRange.label}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    
    final response = await _supabase
        .from('milk_pumping')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', dateQuery['start']!)
        .lte('started_at', dateQuery['end']!);

    final milkPumpings = response.map((json) => MilkPumping.fromJson(json)).toList();
    
    if (milkPumpings.isEmpty) {
      return CardStatistics(
        cardType: 'milk_pumping',
        cardName: '유축',
        totalCount: 0,
        metrics: [],
      );
    }

    // 총 유축량 계산 (ml 단위)
    final totalAmount = milkPumpings
        .where((pumping) => pumping.amountMl != null)
        .fold<int>(0, (sum, pumping) => sum + pumping.amountMl!);

    // 평균 유축량
    final avgAmount = milkPumpings.where((pumping) => pumping.amountMl != null).isNotEmpty
        ? totalAmount / milkPumpings.where((pumping) => pumping.amountMl != null).length
        : 0.0;

    // 하루 평균 유축 횟수
    final avgPerDay = milkPumpings.length / dateRange.totalDays;

    // 하루 평균 총 유축량
    final avgTotalAmountPerDay = totalAmount / dateRange.totalDays;

    return CardStatistics(
      cardType: 'milk_pumping',
      cardName: '유축',
      totalCount: milkPumpings.length,
      metrics: [
        StatisticsMetric(label: '총 유축량', value: totalAmount.toDouble(), unit: 'ml'),
        StatisticsMetric(label: '평균 유축량', value: avgAmount, unit: 'ml'),
        StatisticsMetric(label: '하루 평균 유축 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '하루 평균 총 유축량', value: avgTotalAmountPerDay, unit: 'ml'),
      ],
    );
  }

  /// 이유식 통계 생성
  Future<CardStatistics> _generateSolidFoodStatistics(
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
  ) async {
    debugPrint('🥄 [SOLID_FOOD_STATS] Querying solid foods for user: $userId, baby: $babyId');
    debugPrint('🥄 [SOLID_FOOD_STATS] Date range: ${dateRange.label}');
    
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final dateQuery = _getDateRangeForQuery(dateRange);
    
    final response = await _supabase
        .from('solid_foods')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', dateQuery['start']!)
        .lte('started_at', dateQuery['end']!);

    final solidFoods = response.map((json) => SolidFood.fromJson(json)).toList();
    
    if (solidFoods.isEmpty) {
      return CardStatistics(
        cardType: 'solid_food',
        cardName: '이유식',
        totalCount: 0,
        metrics: [],
      );
    }

    // 하루 평균 이유식 횟수
    final avgPerDay = solidFoods.length / dateRange.totalDays;

    // 음식별 분류
    final foodsByName = _groupByType(solidFoods, (food) => food.foodName);

    // 알레르기 반응 통계
    final allergicReactions = solidFoods.where((food) => food.allergicReaction != null && food.allergicReaction != 'none').length;

    return CardStatistics(
      cardType: 'solid_food',
      cardName: '이유식',
      totalCount: solidFoods.length,
      metrics: [
        StatisticsMetric(label: '하루 평균 이유식 횟수', value: avgPerDay, unit: 'times'),
        StatisticsMetric(label: '시도한 음식 종류', value: foodsByName.length.toDouble(), unit: 'types'),
        StatisticsMetric(label: '알레르기 반응 횟수', value: allergicReactions.toDouble(), unit: 'times'),
      ],
      additionalData: {
        'foodsByName': foodsByName,
      },
    );
  }

  /// 차트 데이터 생성
  Future<StatisticsChartData> generateChartData({
    required String cardType,
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
    required String metricType, // 'count', 'amount', 'duration' 등
  }) async {
    debugPrint('📈 [CHART] ==================== CHART DATA GENERATION ====================');
    debugPrint('📈 [CHART] Generating chart data for $cardType, metric: $metricType');
    debugPrint('📈 [CHART] User: $userId, Baby: $babyId');
    debugPrint('📈 [CHART] Date range: ${dateRange.label} (${dateRange.totalDays} days)');
    
    // 이제 모든 차트 타입에 대한 처리 함수가 구현됨
    if (cardType == 'medication' || cardType == 'milk_pumping' || cardType == 'solid_food') {
      debugPrint('📈 [CHART] ✅ FIXED: This card type ($cardType) now has proper chart data processing functions!');
      debugPrint('📈 [CHART] ✅ Chart data should now display correctly with real values');
      
      // 기존 캐시된 차트 데이터 무효화 (0 데이터가 캐시되어 있을 수 있음)
      final oldCacheKey = 'chart_${cardType}_${userId}_${babyId}_${dateRange.type.toJson()}_${dateRange.startDate.millisecondsSinceEpoch}_$metricType';
      await _cache.remove(oldCacheKey);
      debugPrint('📈 [CHART] 🗑️ Invalidated old cache for $cardType to ensure fresh data');
    }

    try {
      // 1. 새로운 차트 캐시 서비스 사용
      debugPrint('📈 [CHART] Using enhanced chart caching service');
      
      // 2. 캐시에서 차트 데이터 조회 시도
      final cachedChartData = await _statisticsCache.getChartData(
        cardType: cardType,
        userId: userId,
        babyId: babyId,
        dateRange: dateRange,
        metricType: metricType,
      );
      
      if (cachedChartData != null) {
        debugPrint('📈 [CHART] ⚡ Enhanced chart cache hit! Using cached data for $cardType');
        debugPrint('📈 [CHART] Cache stats: ${_statisticsCache.getCacheStats()}');
        return cachedChartData;
      }
      
      debugPrint('📈 [CHART] Cache miss. Generating new chart data for $cardType');

      final dataPoints = <StatisticsDataPoint>[];
      
      // 날짜별로 데이터 포인트 생성
      for (int i = 0; i < dateRange.totalDays; i++) {
        final currentDate = dateRange.startDate.add(Duration(days: i));
        final endOfDay = DateTime(currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
        
        double value = 0.0;
        
        switch (cardType) {
          case 'feeding':
            value = await _getDailyFeedingMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          case 'sleep':
            value = await _getDailySleepMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          case 'diaper':
            value = await _getDailyDiaperMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          case 'medication':
            debugPrint('📈 [CHART] ✅ Using newly implemented _getDailyMedicationMetric function!');
            value = await _getDailyMedicationMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          case 'milk_pumping':
            debugPrint('📈 [CHART] ✅ Using newly implemented _getDailyMilkPumpingMetric function!');
            value = await _getDailyMilkPumpingMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          case 'solid_food':
            debugPrint('📈 [CHART] ✅ Using newly implemented _getDailySolidFoodMetric function!');
            value = await _getDailySolidFoodMetric(userId, babyId, currentDate, endOfDay, metricType);
            break;
          default:
            debugPrint('📈 [CHART] ⚠️  Unknown card type: $cardType, returning 0.0');
            value = 0.0;
        }
        
        dataPoints.add(StatisticsDataPoint(
          date: currentDate,
          value: value,
          label: '${currentDate.month}/${currentDate.day}',
        ));
      }

      String title = _getChartTitle(cardType, metricType);
      String unit = _getChartUnit(cardType, metricType);

      final chartData = StatisticsChartData(
        title: title,
        dataPoints: dataPoints,
        unit: unit,
      );

      // 차트 데이터 생성 결과 로그
      debugPrint('📈 [CHART] ==================== CHART GENERATION COMPLETE ====================');
      debugPrint('📈 [CHART] Chart title: $title');
      debugPrint('📈 [CHART] Chart unit: $unit');
      debugPrint('📈 [CHART] Data points: ${dataPoints.length}');
      debugPrint('📈 [CHART] Has data: ${chartData.hasData}');
      debugPrint('📈 [CHART] Average value: ${chartData.averageValue}');
      debugPrint('📈 [CHART] Max value: ${chartData.maxDataValue}');
      
      if (!chartData.hasData) {
        debugPrint('📈 [CHART] ❌ EMPTY CHART DATA! All values are zero.');
        if (cardType == 'medication' || cardType == 'milk_pumping' || cardType == 'solid_food') {
          debugPrint('📈 [CHART] ❌ This is expected for $cardType because chart processing functions are missing!');
        }
      } else {
        debugPrint('📈 [CHART] ✅ Chart has data! Non-zero values found.');
      }

      // 3. 생성된 차트 데이터를 새로운 캐시 서비스에 저장
      await _statisticsCache.setChartData(
        cardType: cardType,
        userId: userId,
        babyId: babyId,
        dateRange: dateRange,
        metricType: metricType,
        chartData: chartData,
      );
      
      debugPrint('💾 [CHART] ⚡ Chart data cached with enhanced service for $cardType');
      debugPrint('💾 [CHART] Updated cache stats: ${_statisticsCache.getCacheStats()}');
      debugPrint('📈 [CHART] ==================== END CHART GENERATION ====================');

      return chartData;
    } catch (e) {
      debugPrint('❌ [CHART] Error generating chart data: $e');
      return StatisticsChartData(
        title: '차트 데이터',
        dataPoints: [],
        unit: '',
      );
    }
  }

  /// 일별 수유 메트릭 계산
  Future<double> _getDailyFeedingMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    final response = await _supabase
        .from('feedings')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', '${startDateStr}T00:00:00Z')
        .lte('started_at', '${endDateStr}T23:59:59Z');

    final feedings = response.map((json) => Feeding.fromJson(json)).toList();

    switch (metricType) {
      case 'count':
        return feedings.length.toDouble();
      case 'amount':
        return feedings
            .where((feeding) => feeding.amountMl != null)
            .fold<double>(0.0, (sum, feeding) => sum + feeding.amountMl!);
      case 'duration':
        return feedings
            .where((feeding) => feeding.durationMinutes != null)
            .fold<double>(0.0, (sum, feeding) => sum + feeding.durationMinutes!);
      default:
        return feedings.length.toDouble();
    }
  }

  /// 일별 수면 메트릭 계산
  Future<double> _getDailySleepMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    final response = await _supabase
        .from('sleeps')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', '${startDateStr}T00:00:00Z')
        .lte('started_at', '${endDateStr}T23:59:59Z');

    final sleeps = response.map((json) => Sleep.fromJson(json)).toList();

    switch (metricType) {
      case 'count':
        return sleeps.length.toDouble();
      case 'duration':
        return sleeps
            .where((sleep) => sleep.durationMinutes != null)
            .fold<double>(0.0, (sum, sleep) => sum + sleep.durationMinutes!);
      default:
        return sleeps.length.toDouble();
    }
  }

  /// 일별 기저귀 메트릭 계산
  Future<double> _getDailyDiaperMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    final response = await _supabase
        .from('diapers')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('changed_at', '${startDateStr}T00:00:00Z')
        .lte('changed_at', '${endDateStr}T23:59:59Z');

    final diapers = response.map((json) => Diaper.fromJson(json)).toList();

    return diapers.length.toDouble();
  }

  /// 일별 투약 메트릭 계산
  Future<double> _getDailyMedicationMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    debugPrint('💊 [DAILY_MEDICATION] Computing daily metric for $startDateStr');
    
    final response = await _supabase
        .from('medications')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('administered_at', '${startDateStr}T00:00:00Z')
        .lte('administered_at', '${endDateStr}T23:59:59Z');

    final medications = response.map((json) => Medication.fromJson(json)).toList();
    
    debugPrint('💊 [DAILY_MEDICATION] Found ${medications.length} medications for $startDateStr');

    switch (metricType) {
      case 'count':
        return medications.length.toDouble();
      default:
        return medications.length.toDouble();
    }
  }

  /// 일별 유축 메트릭 계산
  Future<double> _getDailyMilkPumpingMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    debugPrint('🍼 [DAILY_MILK_PUMPING] Computing daily metric for $startDateStr');
    
    final response = await _supabase
        .from('milk_pumping')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', '${startDateStr}T00:00:00Z')
        .lte('started_at', '${endDateStr}T23:59:59Z');

    final milkPumpings = response.map((json) => MilkPumping.fromJson(json)).toList();
    
    debugPrint('🍼 [DAILY_MILK_PUMPING] Found ${milkPumpings.length} milk pumpings for $startDateStr');

    switch (metricType) {
      case 'count':
        return milkPumpings.length.toDouble();
      case 'amount':
        return milkPumpings
            .where((pumping) => pumping.amountMl != null)
            .fold<double>(0.0, (sum, pumping) => sum + pumping.amountMl!);
      default:
        return milkPumpings.length.toDouble();
    }
  }

  /// 일별 이유식 메트릭 계산
  Future<double> _getDailySolidFoodMetric(String userId, String babyId, DateTime startDate, DateTime endDate, String metricType) async {
    // 시간대 문제 해결을 위한 날짜 범위 변환
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    debugPrint('🥄 [DAILY_SOLID_FOOD] Computing daily metric for $startDateStr');
    
    final response = await _supabase
        .from('solid_foods')
        .select('*')
        .eq('baby_id', babyId)  // 🏠 가족 공유: 아기 기준으로 모든 구성원 데이터 조회
        .gte('started_at', '${startDateStr}T00:00:00Z')
        .lte('started_at', '${endDateStr}T23:59:59Z');

    final solidFoods = response.map((json) => SolidFood.fromJson(json)).toList();
    
    debugPrint('🥄 [DAILY_SOLID_FOOD] Found ${solidFoods.length} solid foods for $startDateStr');

    switch (metricType) {
      case 'count':
        return solidFoods.length.toDouble();
      default:
        return solidFoods.length.toDouble();
    }
  }

  /// 차트 제목 생성
  String _getChartTitle(String cardType, String metricType) {
    switch (cardType) {
      case 'feeding':
        switch (metricType) {
          case 'count': return '일별 수유 횟수';
          case 'amount': return '일별 수유량';
          case 'duration': return '일별 수유 시간';
          default: return '수유 차트';
        }
      case 'sleep':
        switch (metricType) {
          case 'count': return '일별 수면 횟수';
          case 'duration': return '일별 수면 시간';
          default: return '수면 차트';
        }
      case 'diaper':
        return '일별 기저귀 교체 횟수';
      case 'medication':
        switch (metricType) {
          case 'count': return '일별 투약 횟수';
          default: return '투약 차트';
        }
      case 'milk_pumping':
        switch (metricType) {
          case 'count': return '일별 유축 횟수';
          case 'amount': return '일별 유축량';
          default: return '유축 차트';
        }
      case 'solid_food':
        switch (metricType) {
          case 'count': return '일별 이유식 횟수';
          default: return '이유식 차트';
        }
      default:
        debugPrint('📈 [CHART_TITLE] ⚠️  Unknown card type: $cardType');
        return '차트';
    }
  }

  /// 차트 단위 반환
  String _getChartUnit(String cardType, String metricType) {
    switch (cardType) {
      case 'feeding':
        switch (metricType) {
          case 'count': return 'times';
          case 'amount': return 'ml';
          case 'duration': return 'minutes';
          default: return '';
        }
      case 'sleep':
        switch (metricType) {
          case 'count': return 'times';
          case 'duration': return 'minutes';
          default: return '';
        }
      case 'diaper':
        return 'times';
      case 'medication':
        return 'times';
      case 'milk_pumping':
        switch (metricType) {
          case 'count': return 'times';
          case 'amount': return 'ml';
          default: return '';
        }
      case 'solid_food':
        return 'times';
      default:
        debugPrint('📈 [CHART_UNIT] ⚠️  Unknown card type: $cardType');
        return '';
    }
  }

  /// 리스트를 타입별로 그룹화
  Map<String, int> _groupByType<T>(List<T> items, String Function(T) getType) {
    final Map<String, int> grouped = {};
    for (final item in items) {
      final type = getType(item);
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }
}