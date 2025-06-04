import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/statistics.dart';
import '../../domain/models/feeding.dart';
import '../../domain/models/sleep.dart';
import '../../domain/models/diaper.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/milk_pumping.dart';
import '../../domain/models/solid_food.dart';
import '../../domain/models/user_card_setting.dart';
import '../user_card_setting/user_card_setting_service.dart';

class StatisticsService {
  static StatisticsService? _instance;
  static StatisticsService get instance => _instance ??= StatisticsService._();
  
  StatisticsService._();
  
  final _supabase = SupabaseConfig.client;
  final _userCardSettingService = UserCardSettingService.instance;

  /// 통계 데이터 생성
  Future<Statistics> generateStatistics({
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
  }) async {
    debugPrint('📊 [STATISTICS] Starting statistics generation for user: $userId, baby: $babyId');
    debugPrint('📊 [STATISTICS] Date range: ${dateRange.label}');

    try {
      // 표시 가능한 카드 설정 가져오기
      final visibleCardTypes = await _getVisibleCardTypes(userId);
      debugPrint('📊 [STATISTICS] Visible card types: $visibleCardTypes');

      // 각 카드별 통계 생성
      final cardStatistics = <CardStatistics>[];
      
      for (final cardType in visibleCardTypes) {
        final stats = await _generateCardStatistics(
          cardType: cardType,
          userId: userId,
          babyId: babyId,
          dateRange: dateRange,
        );
        if (stats != null) {
          cardStatistics.add(stats);
        }
      }

      debugPrint('📊 [STATISTICS] Generated statistics for ${cardStatistics.length} cards');

      return Statistics(
        dateRange: dateRange,
        cardStatistics: cardStatistics,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ [STATISTICS] Error generating statistics: $e');
      debugPrint('❌ [STATISTICS] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// 표시 가능한 카드 타입들 가져오기
  Future<List<String>> _getVisibleCardTypes(String userId) async {
    try {
      debugPrint('🗃️ [STATISTICS] Getting visible card types for user: $userId');
      final userCardSettings = await _userCardSettingService.getUserCardSettings(userId);
      final visibleCardTypes = userCardSettings
          .where((setting) => setting.isVisible)
          .map((setting) => setting.cardType)
          .toList();
      debugPrint('🗃️ [STATISTICS] Visible card types: $visibleCardTypes');
      return visibleCardTypes;
    } catch (e) {
      debugPrint('❌ [STATISTICS] Error getting visible card types: $e');
      // 기본 카드 타입들 반환
      final defaultCardTypes = ['feeding', 'sleep', 'diaper', 'medication', 'milk_pumping', 'solid_food'];
      debugPrint('🗃️ [STATISTICS] Using default card types: $defaultCardTypes');
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
    debugPrint('🍼 [FEEDING_STATS] Date range: ${dateRange.startDate} to ${dateRange.endDate}');
    debugPrint('🍼 [FEEDING_STATS] UTC Date range: ${dateRange.startDate.toUtc()} to ${dateRange.endDate.toUtc()}');
    
    // 먼저 모든 수유 데이터를 가져와서 확인
    final allResponse = await _supabase
        .from('feedings')
        .select('started_at, user_id, baby_id')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .order('started_at', ascending: false)
        .limit(10);
    
    debugPrint('🍼 [FEEDING_STATS] Total feeding records found: ${allResponse.length}');
    debugPrint('🍼 [FEEDING_STATS] Recent feeding dates: ${allResponse.map((r) => r['started_at']).toList()}');
    
    if (allResponse.isEmpty) {
      debugPrint('🍼 [FEEDING_STATS] No feeding records found for user_id: $userId, baby_id: $babyId');
      
      // 사용자 ID와 베이비 ID가 실제로 존재하는지 확인
      final userCheck = await _supabase
          .from('feedings')
          .select('user_id, baby_id, started_at')
          .limit(5);
      debugPrint('🍼 [FEEDING_STATS] Sample feeding records in database: $userCheck');
    }
    
    final response = await _supabase
        .from('feedings')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('started_at', dateRange.endDate.toUtc().toIso8601String());

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
        StatisticsMetric(label: '총 수유 시간', value: totalDuration.toDouble(), unit: '분'),
        StatisticsMetric(label: '평균 수유 시간', value: avgDuration, unit: '분'),
        StatisticsMetric(label: '하루 평균 수유 횟수', value: avgPerDay, unit: '회'),
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
    debugPrint('😴 [SLEEP_STATS] Querying sleeps for user: $userId, baby: $babyId');
    
    final response = await _supabase
        .from('sleeps')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('started_at', dateRange.endDate.toUtc().toIso8601String());

    debugPrint('😴 [SLEEP_STATS] Found ${response.length} sleep records');
    
    final sleeps = response.map((json) => Sleep.fromJson(json)).toList();
    
    if (sleeps.isEmpty) {
      return CardStatistics(
        cardType: 'sleep',
        cardName: '수면',
        totalCount: 0,
        metrics: [],
      );
    }

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
        StatisticsMetric(label: '총 수면 시간', value: totalDuration.toDouble(), unit: '분'),
        StatisticsMetric(label: '평균 수면 시간', value: avgDuration, unit: '분'),
        StatisticsMetric(label: '하루 평균 수면 횟수', value: avgPerDay, unit: '회'),
        StatisticsMetric(label: '하루 평균 총 수면 시간', value: avgTotalSleepPerDay, unit: '분'),
        StatisticsMetric(label: '최대 수면 시간', value: maxDuration, unit: '분'),
        StatisticsMetric(label: '최소 수면 시간', value: minDuration, unit: '분'),
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
    
    final response = await _supabase
        .from('diapers')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('changed_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('changed_at', dateRange.endDate.toUtc().toIso8601String());

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
        StatisticsMetric(label: '하루 평균 교체 횟수', value: avgPerDay, unit: '회'),
        StatisticsMetric(label: '소변 기저귀', value: wetDiapers.toDouble(), unit: '회'),
        StatisticsMetric(label: '대변 기저귀', value: dirtyDiapers.toDouble(), unit: '회'),
        StatisticsMetric(label: '소변+대변 기저귀', value: bothDiapers.toDouble(), unit: '회'),
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
    final response = await _supabase
        .from('medications')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('administered_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('administered_at', dateRange.endDate.toUtc().toIso8601String());

    final medications = response.map((json) => Medication.fromJson(json)).toList();
    
    if (medications.isEmpty) {
      return CardStatistics(
        cardType: 'medication',
        cardName: '투약',
        totalCount: 0,
        metrics: [],
      );
    }

    // 하루 평균 투약 횟수
    final avgPerDay = medications.length / dateRange.totalDays;

    // 약물별 분류
    final medicationsByName = _groupByType(medications, (medication) => medication.medicationName);

    return CardStatistics(
      cardType: 'medication',
      cardName: '투약',
      totalCount: medications.length,
      metrics: [
        StatisticsMetric(label: '하루 평균 투약 횟수', value: avgPerDay, unit: '회'),
        StatisticsMetric(label: '사용한 약물 종류', value: medicationsByName.length.toDouble(), unit: '종'),
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
    final response = await _supabase
        .from('milk_pumpings')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('started_at', dateRange.endDate.toUtc().toIso8601String());

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
        StatisticsMetric(label: '하루 평균 유축 횟수', value: avgPerDay, unit: '회'),
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
    final response = await _supabase
        .from('solid_foods')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', dateRange.startDate.toUtc().toIso8601String())
        .lte('started_at', dateRange.endDate.toUtc().toIso8601String());

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
        StatisticsMetric(label: '하루 평균 이유식 횟수', value: avgPerDay, unit: '회'),
        StatisticsMetric(label: '시도한 음식 종류', value: foodsByName.length.toDouble(), unit: '종'),
        StatisticsMetric(label: '알레르기 반응 횟수', value: allergicReactions.toDouble(), unit: '회'),
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
    debugPrint('📈 [CHART] Generating chart data for $cardType, metric: $metricType');

    try {
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
          default:
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

      return StatisticsChartData(
        title: title,
        dataPoints: dataPoints,
        unit: unit,
      );
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
    final response = await _supabase
        .from('feedings')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', startDate.toUtc().toIso8601String())
        .lte('started_at', endDate.toUtc().toIso8601String());

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
    final response = await _supabase
        .from('sleeps')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('started_at', startDate.toUtc().toIso8601String())
        .lte('started_at', endDate.toUtc().toIso8601String());

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
    final response = await _supabase
        .from('diapers')
        .select('*')
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .gte('changed_at', startDate.toUtc().toIso8601String())
        .lte('changed_at', endDate.toUtc().toIso8601String());

    final diapers = response.map((json) => Diaper.fromJson(json)).toList();

    return diapers.length.toDouble();
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
      default:
        return '차트';
    }
  }

  /// 차트 단위 반환
  String _getChartUnit(String cardType, String metricType) {
    switch (cardType) {
      case 'feeding':
        switch (metricType) {
          case 'count': return '회';
          case 'amount': return 'ml';
          case 'duration': return '분';
          default: return '';
        }
      case 'sleep':
        switch (metricType) {
          case 'count': return '회';
          case 'duration': return '분';
          default: return '';
        }
      case 'diaper':
        return '회';
      default:
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