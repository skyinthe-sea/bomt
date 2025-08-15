import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/feeding.dart';
import '../../domain/models/timeline_item.dart';
import '../../core/config/supabase_config.dart';
import '../../core/mixins/data_sync_mixin.dart';
import '../../core/events/data_sync_events.dart';
import '../alarm/feeding_alarm_service.dart';
import 'feeding_pattern_analyzer.dart';
import 'feeding_cache_manager.dart';

class FeedingService with DataSyncMixin {
  static FeedingService? _instance;
  static FeedingService get instance => _instance ??= FeedingService._();
  
  FeedingService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _feedingTypeKey = 'feeding_default_type';
  static const String _feedingAmountKey = 'feeding_default_amount';
  static const String _feedingDurationKey = 'feeding_default_duration';
  static const String _feedingSideKey = 'feeding_default_side';
  
  /// 기본 수유 설정 저장
  Future<void> saveFeedingDefaults({
    required String type,
    int? amountMl,
    int? durationMinutes,
    String? side,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_feedingTypeKey, type);
    if (amountMl != null) {
      await prefs.setInt(_feedingAmountKey, amountMl);
    }
    if (durationMinutes != null) {
      await prefs.setInt(_feedingDurationKey, durationMinutes);
    }
    if (side != null) {
      await prefs.setString(_feedingSideKey, side);
    }
  }
  
  /// 기본 수유 설정 불러오기
  Future<Map<String, dynamic>> getFeedingDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'type': prefs.getString(_feedingTypeKey) ?? 'bottle',
      'amountMl': prefs.getInt(_feedingAmountKey) ?? 120,
      'durationMinutes': prefs.getInt(_feedingDurationKey) ?? 15,
      'side': prefs.getString(_feedingSideKey) ?? 'both',
    };
  }
  
  /// 새로운 수유 기록 추가
  Future<Feeding?> addFeeding({
    required String babyId,
    required String userId,
    String? type,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    // 현재 로컬 시간 사용 (시스템이 한국시간대로 설정되어 있음)
    final feedingStartTime = startedAt ?? DateTime.now();
    
    debugPrint('=== FEEDING TIME PROCESSING ===');
    debugPrint('Local time: $feedingStartTime (isUtc: ${feedingStartTime.isUtc})');
    debugPrint('Will save to DB as UTC: ${feedingStartTime.toUtc().toIso8601String()}');
    debugPrint('===============================');
    
    return await withDataSyncEvent(
      operation: () async {
        // 기본값이 설정되지 않은 경우 저장된 기본값 사용
        final defaults = await getFeedingDefaults();
        
        final feedingData = {
          'id': _uuid.v4(),
          'baby_id': babyId,
          'user_id': userId,
          'type': type ?? defaults['type'],
          'amount_ml': amountMl ?? defaults['amountMl'],
          'duration_minutes': durationMinutes ?? defaults['durationMinutes'],
          'side': side ?? defaults['side'],
          'notes': notes,
          'started_at': feedingStartTime.toUtc().toIso8601String(),
          'ended_at': endedAt?.toUtc().toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        
        final response = await _supabase
            .from('feedings')
            .insert(feedingData)
            .select()
            .single();
        
        final newFeeding = Feeding.fromJson(response);
        
        // 새로운 수유 기록 추가 후 다음 수유 알람 설정
        try {
          final alarmService = FeedingAlarmService.instance;
          await alarmService.scheduleNextFeedingAlarm(newFeeding.startedAt);
          debugPrint('새로운 수유 기록 추가 후 알람 설정 완료');
        } catch (e) {
          debugPrint('수유 알람 설정 중 오류: $e');
        }
        
        // 패턴 캐시 백그라운드 업데이트
        await _updatePatternCacheAfterFeeding(babyId);
        
        return newFeeding;
      },
      itemType: TimelineItemType.feeding,
      babyId: babyId,
      timestamp: feedingStartTime,
      action: DataSyncAction.created,
    );
  }
  
  /// 오늘의 수유 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayFeedingSummary(String babyId) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final now = DateTime.now();
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      debugPrint('=== FEEDING SUMMARY TIME ANALYSIS ===');
      debugPrint('Feeding summary query for baby_id: $babyId');
      debugPrint('Query range: ${todayStartUtc.toIso8601String()} to ${tomorrowStartUtc.toIso8601String()}');
      debugPrint('=====================================');
      
      final response = await _supabase
          .from('feedings')
          .select('started_at, amount_ml, type')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalAmount = 0;
      DateTime? lastFeedingTime;
      int? lastFeedingMinutesAgo;
      Map<String, int> typeCount = {
        'breast': 0,
        'bottle': 0,
        'formula': 0,
        'solid': 0,
      };
      
      if (response.isNotEmpty) {
        // 총 수유량 및 타입별 계산
        for (var feeding in response) {
          if (feeding['amount_ml'] != null) {
            totalAmount += feeding['amount_ml'] as int;
          }
          
          final type = feeding['type'] as String;
          if (typeCount.containsKey(type)) {
            typeCount[type] = typeCount[type]! + 1;
          }
        }
        
        // 최근 수유 시간 계산 (오늘 수유가 있는 경우)
        final lastFeeding = response.first;
        // UTC 데이터를 로컬 시간으로 변환
        final parsedTime = DateTime.parse(lastFeeding['started_at']);
        lastFeedingTime = parsedTime.isUtc ? parsedTime.toLocal() : parsedTime;
        lastFeedingMinutesAgo = now.difference(lastFeedingTime).inMinutes;
        
        debugPrint('=== 오늘 수유 시간 계산 디버그 ===');
        debugPrint('현재 시간: $now');
        debugPrint('DB 수유 시간: ${lastFeeding['started_at']}');
        debugPrint('파싱된 시간: $parsedTime');
        debugPrint('9시간 보정 후: $lastFeedingTime');
        debugPrint('시간 차이 (분): $lastFeedingMinutesAgo');
        debugPrint('시간 차이 (시:분): ${lastFeedingMinutesAgo ~/ 60}시간 ${lastFeedingMinutesAgo % 60}분');
        debugPrint('===============================');
      } else {
        // 오늘 수유가 없는 경우, 전체 기간에서 가장 최근 수유 찾기
        debugPrint('오늘 수유 없음. 전체 기간에서 최근 수유 검색...');
        final allFeedingsResponse = await _supabase
            .from('feedings')
            .select('started_at')
            .eq('baby_id', babyId)
            .order('started_at', ascending: false)
            .limit(1);
        
        debugPrint('전체 수유 검색 결과: ${allFeedingsResponse.length}개');
        if (allFeedingsResponse.isNotEmpty) {
          final lastFeeding = allFeedingsResponse.first;
          final dbTime = lastFeeding['started_at'] as String;
          // UTC 데이터를 로컬 시간으로 변환
          final parsedTime = DateTime.parse(dbTime);
          lastFeedingTime = parsedTime.isUtc ? parsedTime.toLocal() : parsedTime;
          lastFeedingMinutesAgo = now.difference(lastFeedingTime).inMinutes;
          
          debugPrint('=== 과거 수유 시간 계산 디버그 ===');
          debugPrint('현재 시간: $now');
          debugPrint('DB 수유 시간: $dbTime');
          debugPrint('파싱된 시간: $parsedTime');
          debugPrint('9시간 보정 후: $lastFeedingTime');
          debugPrint('시간 차이 (분): $lastFeedingMinutesAgo');
          debugPrint('시간 차이 (시:분): ${lastFeedingMinutesAgo ~/ 60}시간 ${lastFeedingMinutesAgo % 60}분');
          debugPrint('================================');
          
          debugPrint('현재 시간: $now');
          debugPrint('DB 시간 (원본): $dbTime');
          debugPrint('보정된 시간: $lastFeedingTime');
          debugPrint('분 차이: $lastFeedingMinutesAgo');
        }
      }
      
      // 다음 수유까지 남은 시간 계산 (패턴 기반)
      int? minutesUntilNextFeeding;
      DateTime? nextFeedingTime;
      String? nextFeedingMessage;
      bool isPatternBased = false;
      
      try {
        final patternResult = await getPatternBasedNextFeeding(babyId);
        
        if (patternResult['status'] == 'scheduled') {
          minutesUntilNextFeeding = patternResult['totalMinutesUntilNext'] as int;
          nextFeedingTime = patternResult['nextFeedingTime'] as DateTime;
          nextFeedingMessage = patternResult['message'] as String;
          isPatternBased = true;
          debugPrint('패턴 기반 다음 수유 시간 사용: ${patternResult['hoursUntilNext']}시간 ${patternResult['minutesUntilNext']}분');
        } else if (patternResult['status'] == 'insufficient_data') {
          nextFeedingMessage = 'insufficient_feeding_records';
          debugPrint('수유 기록 부족: ${patternResult['reason']}');
        } else if (patternResult['status'] == 'overdue') {
          nextFeedingMessage = 'feeding_overdue';
          debugPrint('수유 시간 지남');
        } else {
          // 패턴 분석 실패 시 기존 알람 시스템 사용
          final alarmService = FeedingAlarmService.instance;
          minutesUntilNextFeeding = await alarmService.getMinutesUntilNextFeeding();
          nextFeedingTime = await alarmService.getNextFeedingTime();
          debugPrint('알람 기반 다음 수유 시간 사용 (패턴 분석 실패)');
        }
      } catch (e) {
        debugPrint('다음 수유 시간 확인 중 오류: $e');
        // 오류 시 기존 알람 시스템 사용
        try {
          final alarmService = FeedingAlarmService.instance;
          minutesUntilNextFeeding = await alarmService.getMinutesUntilNextFeeding();
          nextFeedingTime = await alarmService.getNextFeedingTime();
        } catch (alarmError) {
          debugPrint('알람 기반 다음 수유 시간도 실패: $alarmError');
        }
      }
      
      return {
        'count': count,
        'totalAmount': totalAmount,
        'lastFeedingTime': lastFeedingTime,
        'lastFeedingMinutesAgo': lastFeedingMinutesAgo,
        'typeCount': typeCount,
        'averageAmount': count > 0 ? (totalAmount / count).round() : 0,
        'minutesUntilNextFeeding': minutesUntilNextFeeding,
        'nextFeedingTime': nextFeedingTime,
        'nextFeedingMessage': nextFeedingMessage,
        'isPatternBased': isPatternBased,
      };
    } catch (e) {
      debugPrint('Error getting today feeding summary: $e');
      return {
        'count': 0,
        'totalAmount': 0,
        'lastFeedingTime': null,
        'lastFeedingMinutesAgo': null,
        'typeCount': {
          'breast': 0,
          'bottle': 0,
          'formula': 0,
          'solid': 0,
        },
        'averageAmount': 0,
        'minutesUntilNextFeeding': null,
        'nextFeedingTime': null,
        'nextFeedingMessage': null,
        'isPatternBased': false,
      };
    }
  }
  
  /// 오늘의 수유 기록 목록 가져오기
  Future<List<Feeding>> getTodayFeedings(String babyId) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final now = DateTime.now();
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('feedings')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => Feeding.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today feedings: $e');
      return [];
    }
  }

  /// 특정 날짜의 수유 기록 목록 가져오기
  Future<List<Feeding>> getFeedingsForDate(String babyId, DateTime date) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final kstOffset = const Duration(hours: 9);
      final dateKst = date.isUtc ? date.add(kstOffset) : date;
      
      // 한국 시간 기준 해당 날짜 범위
      final startOfDayKst = DateTime(dateKst.year, dateKst.month, dateKst.day);
      final endOfDayKst = DateTime(dateKst.year, dateKst.month, dateKst.day, 23, 59, 59);
      
      // UTC로 변환
      final startOfDayUtc = startOfDayKst.subtract(kstOffset);
      final endOfDayUtc = endOfDayKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('feedings')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDayUtc.toIso8601String())
          .lte('started_at', endOfDayUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => Feeding.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting feedings for date: $e');
      return [];
    }
  }
  
  /// 수유 기록 삭제
  Future<bool> deleteFeeding(String feedingId) async {
    try {
      // 삭제 전 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('feedings')
          .select('baby_id, started_at')
          .eq('id', feedingId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final startedAt = DateTime.parse(existingResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          await _supabase
              .from('feedings')
              .delete()
              .eq('id', feedingId);
          
          return true;
        },
        itemType: TimelineItemType.feeding,
        babyId: babyId,
        timestamp: startedAt,
        action: DataSyncAction.deleted,
        recordId: feedingId,
      );
    } catch (e) {
      debugPrint('Error deleting feeding: $e');
      return false;
    }
  }
  
  /// 수유 기록 수정
  Future<Feeding?> updateFeeding({
    required String feedingId,
    String? type,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    try {
      // 기존 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('feedings')
          .select('baby_id, started_at')
          .eq('id', feedingId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final originalStartedAt = DateTime.parse(existingResponse['started_at']);
      final updateTimestamp = startedAt ?? originalStartedAt;
      
      final result = await withDataSyncEvent(
        operation: () async {
          final updateData = <String, dynamic>{
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          if (type != null) updateData['type'] = type;
          if (amountMl != null) updateData['amount_ml'] = amountMl;
          if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
          if (side != null) updateData['side'] = side;
          if (notes != null) updateData['notes'] = notes;
          if (startedAt != null) updateData['started_at'] = startedAt.toIso8601String();
          if (endedAt != null) updateData['ended_at'] = endedAt.toIso8601String();
          
          final response = await _supabase
              .from('feedings')
              .update(updateData)
              .eq('id', feedingId)
              .select()
              .single();
          
          return Feeding.fromJson(response);
        },
        itemType: TimelineItemType.feeding,
        babyId: babyId,
        timestamp: updateTimestamp,
        action: DataSyncAction.updated,
        recordId: feedingId,
      );
      
      // 수유 기록 수정 후 캐시 무효화 (패턴이 변경될 수 있음)
      if (result != null) {
        await FeedingCacheManager.instance.invalidateCache(babyId);
      }
      
      return result;
    } catch (e) {
      debugPrint('Error updating feeding: $e');
      return null;
    }
  }

  /// 패턴 분석용 최근 수유 기록 가져오기
  Future<List<Feeding>> getRecentFeedingsForPattern(String babyId, {int limit = 15}) async {
    try {
      final response = await _supabase
          .from('feedings')
          .select('*')
          .eq('baby_id', babyId)
          .order('started_at', ascending: false)
          .limit(limit);
      
      final feedings = response.map((json) => Feeding.fromJson(json)).toList();
      debugPrint('패턴 분석용 수유 기록 조회: ${feedings.length}건');
      
      return feedings;
    } catch (e) {
      debugPrint('Error getting recent feedings for pattern: $e');
      return [];
    }
  }

  /// 패턴 기반 다음 수유 예측 정보
  Future<Map<String, dynamic>> getPatternBasedNextFeeding(String babyId) async {
    try {
      final cacheManager = FeedingCacheManager.instance;
      
      // 현재 수유 기록 수 확인
      final countResponse = await _supabase
          .from('feedings')
          .select('id')
          .eq('baby_id', babyId);
      
      final currentFeedingCount = countResponse.length;
      
      // 캐시 확인 및 재계산 필요성 판단
      final shouldRecalc = await cacheManager.shouldRecalculate(babyId, currentFeedingCount);
      FeedingPatternCache? cachedPattern;
      
      if (!shouldRecalc) {
        cachedPattern = await cacheManager.getCachedPattern(babyId);
      }
      
      FeedingPatternAnalysisResult analysis;
      
      if (cachedPattern != null) {
        // 캐시된 결과 사용
        analysis = cachedPattern.result;
        debugPrint('캐시된 패턴 분석 결과 사용: $babyId');
      } else {
        // 새로 패턴 분석
        debugPrint('새로운 패턴 분석 시작: $babyId');
        final recentFeedings = await getRecentFeedingsForPattern(babyId);
        analysis = FeedingPatternAnalyzer.analyzePattern(recentFeedings);
        
        // 결과 캐싱
        final lastFeedingId = recentFeedings.isNotEmpty ? recentFeedings.first.id : null;
        await cacheManager.cachePattern(
          babyId: babyId,
          result: analysis,
          currentFeedingCount: currentFeedingCount,
          lastFeedingId: lastFeedingId,
        );
        
        debugPrint('패턴 분석 완료 및 캐싱: $babyId');
      }
      
      // 다음 수유 시간 계산
      if (!analysis.isDataSufficient) {
        return {
          'status': 'insufficient_data',
          'reason': analysis.insufficientDataReason,
          'message': 'insufficient_feeding_records',
          'analysis': analysis,
        };
      }
      
      if (analysis.lastFeedingTime == null) {
        return {
          'status': 'no_recent_feeding',
          'message': 'no_recent_feeding',
          'analysis': analysis,
        };
      }
      
      final now = DateTime.now();
      final nextFeedingTime = analysis.lastFeedingTime!.add(
        Duration(minutes: (analysis.averageIntervalHours * 60).round())
      );
      
      if (nextFeedingTime.isBefore(now)) {
        return {
          'status': 'overdue',
          'message': 'feeding_overdue',
          'minutesOverdue': now.difference(nextFeedingTime).inMinutes,
          'analysis': analysis,
        };
      }
      
      final timeUntilNext = nextFeedingTime.difference(now);
      final hoursUntil = timeUntilNext.inHours;
      final minutesUntil = timeUntilNext.inMinutes % 60;
      
      return {
        'status': 'scheduled',
        'message': hoursUntil > 0 ? 'hours_minutes_until_feeding' : 'minutes_until_feeding',
        'hoursUntilNext': hoursUntil,
        'minutesUntilNext': minutesUntil,
        'totalMinutesUntilNext': timeUntilNext.inMinutes,
        'nextFeedingTime': nextFeedingTime,
        'analysis': analysis,
      };
      
    } catch (e) {
      debugPrint('Error getting pattern-based next feeding: $e');
      return {
        'status': 'error',
        'message': 'calculation_error',
        'analysis': null,
      };
    }
  }

  /// 수유 기록 추가 시 패턴 캐시 업데이트
  Future<void> _updatePatternCacheAfterFeeding(String babyId) async {
    try {
      final cacheManager = FeedingCacheManager.instance;
      
      // 백그라운드에서 패턴 업데이트 (비동기)
      Future.microtask(() async {
        try {
          final countResponse = await _supabase
              .from('feedings')
              .select('id')
              .eq('baby_id', babyId);
          
          final currentCount = countResponse.length;
          final shouldRecalc = await cacheManager.shouldRecalculate(babyId, currentCount);
          
          if (shouldRecalc) {
            debugPrint('백그라운드 패턴 업데이트 시작: $babyId');
            final recentFeedings = await getRecentFeedingsForPattern(babyId);
            final analysis = FeedingPatternAnalyzer.analyzePattern(recentFeedings);
            
            final lastFeedingId = recentFeedings.isNotEmpty ? recentFeedings.first.id : null;
            await cacheManager.cachePattern(
              babyId: babyId,
              result: analysis,
              currentFeedingCount: currentCount,
              lastFeedingId: lastFeedingId,
            );
            
            debugPrint('백그라운드 패턴 업데이트 완료: $babyId');
          }
        } catch (e) {
          debugPrint('백그라운드 패턴 업데이트 오류: $e');
        }
      });
    } catch (e) {
      debugPrint('패턴 캐시 업데이트 오류: $e');
    }
  }
}