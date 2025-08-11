import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/sleep.dart';
import '../../domain/models/timeline_item.dart';
import '../../core/config/supabase_config.dart';
import '../../core/mixins/data_sync_mixin.dart';
import '../../core/events/data_sync_events.dart';

class SleepService with DataSyncMixin {
  static SleepService? _instance;
  static SleepService get instance => _instance ??= SleepService._();
  
  SleepService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _sleepDurationKey = 'sleep_default_duration';
  static const String _sleepQualityKey = 'sleep_default_quality';
  static const String _sleepLocationKey = 'sleep_default_location';
  
  /// 기본 수면 설정 저장
  Future<void> saveSleepDefaults({
    int? durationMinutes,
    String? quality,
    String? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (durationMinutes != null) {
      await prefs.setInt(_sleepDurationKey, durationMinutes);
    }
    if (quality != null) {
      await prefs.setString(_sleepQualityKey, quality);
    }
    if (location != null) {
      await prefs.setString(_sleepLocationKey, location);
    }
  }
  
  /// 기본 수면 설정 불러오기
  Future<Map<String, dynamic>> getSleepDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'durationMinutes': prefs.getInt(_sleepDurationKey) ?? 120, // 2시간
      'quality': prefs.getString(_sleepQualityKey) ?? 'good',
      'location': prefs.getString(_sleepLocationKey) ?? '침실',
    };
  }
  
  /// 새로운 수면 기록 추가
  Future<Sleep?> addSleep({
    required String babyId,
    required String userId,
    int? durationMinutes,
    String? quality,
    String? location,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    final sleepStartTime = startedAt ?? DateTime.now();
    final isActiveSleep = endedAt == null;
    
    debugPrint('=== SLEEP START TIME PROCESSING ===');
    debugPrint('startedAt parameter: $startedAt');
    debugPrint('Calculated sleepStartTime: $sleepStartTime (isUtc: ${sleepStartTime.isUtc})');
    debugPrint('sleepStartTime as ISO: ${sleepStartTime.toIso8601String()}');
    debugPrint('Is active sleep: $isActiveSleep');
    debugPrint('===================================');
    
    return await withDataSyncEvent(
      operation: () async {
        // 기본값이 설정되지 않은 경우 저장된 기본값 사용
        final defaults = await getSleepDefaults();
        
        final now = DateTime.now();
        debugPrint('Current time for metadata: $now (isUtc: ${now.isUtc})');
        debugPrint('Current time as ISO: ${now.toIso8601String()}');
        
        Map<String, dynamic> sleepData;
        
        if (isActiveSleep) {
          // 진행 중인 수면: duration과 ended_at은 null
          sleepData = {
            'id': _uuid.v4(),
            'baby_id': babyId,
            'user_id': userId,
            'duration_minutes': null,
            'quality': quality ?? defaults['quality'],
            'location': location ?? defaults['location'],
            'notes': notes,
            'started_at': sleepStartTime.toUtc().toIso8601String(),
            'ended_at': null,
            'created_at': now.toUtc().toIso8601String(),
            'updated_at': now.toUtc().toIso8601String(),
          };
        } else {
          // 완료된 수면: duration 계산 또는 기본값 사용
          final duration = durationMinutes ?? defaults['durationMinutes'];
          final sleepEndTime = endedAt ?? sleepStartTime.add(Duration(minutes: duration));
          final actualDuration = durationMinutes ?? sleepEndTime.difference(sleepStartTime).inMinutes;
          
          sleepData = {
            'id': _uuid.v4(),
            'baby_id': babyId,
            'user_id': userId,
            'duration_minutes': actualDuration,
            'quality': quality ?? defaults['quality'],
            'location': location ?? defaults['location'],
            'notes': notes,
            'started_at': sleepStartTime.toUtc().toIso8601String(),
            'ended_at': sleepEndTime.toUtc().toIso8601String(),
            'created_at': now.toUtc().toIso8601String(),
            'updated_at': now.toUtc().toIso8601String(),
          };
        }
        
        final response = await _supabase
            .from('sleeps')
            .insert(sleepData)
            .select()
            .single();
        
        final newSleep = Sleep.fromJson(response);
        
        // 진행 중인 수면일 경우 ongoing activity started 이벤트 추가 발송
        if (isActiveSleep) {
          notifyOngoingStarted(
            itemType: TimelineItemType.sleep,
            babyId: babyId,
            timestamp: sleepStartTime,
            recordId: newSleep.id,
          );
        }
        
        return newSleep;
      },
      itemType: TimelineItemType.sleep,
      babyId: babyId,
      timestamp: sleepStartTime,
      action: DataSyncAction.created,
    );
  }
  
  /// 오늘의 수면 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodaySleepSummary(String babyId) async {
    try {
      final now = DateTime.now();
      
      // 한국 시간대 (UTC+9) 명시적 처리
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      debugPrint('=== DETAILED TIME ANALYSIS ===');
      debugPrint('Sleep summary query for baby_id: $babyId');
      debugPrint('Raw DateTime.now(): $now (isUtc: ${now.isUtc})');
      debugPrint('System timezone offset: ${now.timeZoneOffset}');
      debugPrint('Current UTC time: ${DateTime.now().toUtc()}');
      debugPrint('Calculated KST time: $nowKst');
      debugPrint('');
      debugPrint('Range calculation:');
      debugPrint('  KST today start: $todayStartKst');
      debugPrint('  KST tomorrow start: $tomorrowStartKst');
      debugPrint('  UTC today start: $todayStartUtc');
      debugPrint('  UTC tomorrow start: $tomorrowStartUtc');
      debugPrint('  Query range: ${todayStartUtc.toIso8601String()} to ${tomorrowStartUtc.toIso8601String()}');
      debugPrint('===============================');
      
      // Check current user authentication
      final user = _supabase.auth.currentUser;
      debugPrint('Current authenticated user: ${user?.id}');
      
      // Check if user has access to this baby
      if (user != null) {
        try {
          final babyUserCheck = await _supabase
              .from('baby_users')
              .select('role')
              .eq('baby_id', babyId)
              .eq('user_id', user.id)
              .limit(1);
          debugPrint('Baby access check: ${babyUserCheck.length > 0 ? "ALLOWED" : "DENIED"}');
          if (babyUserCheck.isNotEmpty) {
            debugPrint('User role: ${babyUserCheck.first['role']}');
          }
        } catch (e) {
          debugPrint('Baby access check error: $e');
        }
      }
      
      // 먼저 모든 데이터를 조회해서 비교해보자
      final allDataResponse = await _supabase
          .from('sleeps')
          .select('started_at, ended_at, duration_minutes, quality')
          .eq('baby_id', babyId)
          .order('started_at', ascending: false)
          .limit(10);
      
      debugPrint('=== ALL RECENT SLEEP DATA (last 10) ===');
      for (int i = 0; i < allDataResponse.length; i++) {
        final record = allDataResponse[i];
        final startedAtStr = record['started_at'] as String;
        final startedAtUtc = DateTime.parse(startedAtStr);
        final startedAtKst = startedAtUtc.add(kstOffset);
        debugPrint('[$i] UTC: $startedAtUtc | KST: $startedAtKst | Raw: $startedAtStr');
      }
      debugPrint('========================================');

      final response = await _supabase
          .from('sleeps')
          .select('started_at, ended_at, duration_minutes, quality')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      debugPrint('Sleep records found in range: ${response.length}');
      debugPrint('=== FILTERED SLEEP DATA ===');
      for (int i = 0; i < response.length; i++) {
        final record = response[i];
        final startedAtStr = record['started_at'] as String;
        final startedAtUtc = DateTime.parse(startedAtStr);
        final startedAtKst = startedAtUtc.add(kstOffset);
        debugPrint('[$i] UTC: $startedAtUtc | KST: $startedAtKst');
      }
      debugPrint('============================');
      
      int count = 0; // 완료된 수면의 개수
      int totalMinutes = 0;
      DateTime? lastSleepTime;
      int? lastSleepMinutesAgo;
      Map<String, int> qualityCount = {
        'good': 0,
        'fair': 0,
        'poor': 0,
      };
      
      if (response.isNotEmpty) {
        debugPrint('Processing ${response.length} sleep records:');
        // 총 수면 시간 및 품질별 계산 (완료된 수면만 포함)
        for (var sleep in response) {
          // 완료된 수면만 총 시간에 포함 (ended_at이 있는 경우)
          final startedAtStr = sleep['started_at'] as String?;
          final endedAtStr = sleep['ended_at'] as String?;
          
          debugPrint('Sleep record: started_at=$startedAtStr, ended_at=$endedAtStr');
          
          if (startedAtStr != null && endedAtStr != null) {
            // 완료된 수면이므로 카운트 증가
            count++;
            debugPrint('Completed sleep found. Count is now: $count');
            
            try {
              final startedAt = DateTime.parse(startedAtStr);
              final endedAt = DateTime.parse(endedAtStr);
              
              // 초 단위로 계산한 후 분으로 변환 (더 정확한 계산)
              final durationSeconds = endedAt.difference(startedAt).inSeconds;
              final actualDurationMinutes = (durationSeconds / 60.0).round();
              
              debugPrint('Sleep duration: ${actualDurationMinutes} minutes');
              
              // 실제 수면 시간이 0분 이상인 경우만 포함
              if (actualDurationMinutes > 0) {
                totalMinutes += actualDurationMinutes;
              }
            } catch (e) {
              debugPrint('Error parsing sleep times: $e');
            }
          } else if (startedAtStr != null && endedAtStr == null) {
            debugPrint('Active sleep found (not counted in completed sleeps)');
          }
          
          // 품질별 카운트는 완료된 수면만 포함 (ended_at이 있는 경우만)
          if (endedAtStr != null) {
            final quality = sleep['quality'] as String?;
            if (quality != null && qualityCount.containsKey(quality)) {
              qualityCount[quality] = qualityCount[quality]! + 1;
            }
          }
        }
        
        // 최근 수면 시간 계산
        final lastSleep = response.first;
        if (lastSleep['ended_at'] != null) {
          lastSleepTime = DateTime.parse(lastSleep['ended_at']).toLocal();
          lastSleepMinutesAgo = now.difference(lastSleepTime).inMinutes;
        }
      }
      
      final result = {
        'count': count,
        'totalMinutes': totalMinutes,
        'totalHours': totalMinutes ~/ 60,
        'remainingMinutes': totalMinutes % 60,
        'lastSleepTime': lastSleepTime,
        'lastSleepMinutesAgo': lastSleepMinutesAgo,
        'qualityCount': qualityCount,
        'averageDuration': count > 0 ? (totalMinutes / count).round() : 0,
      };
      
      debugPrint('Final sleep summary: $result');
      return result;
    } catch (e) {
      debugPrint('Error getting today sleep summary: $e');
      return {
        'count': 0,
        'totalMinutes': 0,
        'totalHours': 0,
        'remainingMinutes': 0,
        'lastSleepTime': null,
        'lastSleepMinutesAgo': null,
        'qualityCount': {
          'good': 0,
          'fair': 0,
          'poor': 0,
        },
        'averageDuration': 0,
      };
    }
  }
  
  /// 오늘의 수면 기록 목록 가져오기
  Future<List<Sleep>> getTodaySleeps(String babyId) async {
    try {
      final now = DateTime.now();
      
      // 한국 시간대 (UTC+9) 명시적 처리
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      debugPrint('Sleep list query range: ${todayStartUtc.toIso8601String()} to ${tomorrowStartUtc.toIso8601String()}');
      
      final response = await _supabase
          .from('sleeps')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => Sleep.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today sleeps: $e');
      return [];
    }
  }

  /// 특정 날짜의 수면 기록 목록 가져오기
  Future<List<Sleep>> getSleepsForDate(String babyId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final response = await _supabase
          .from('sleeps')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDay.toUtc().toIso8601String())
          .lt('started_at', endOfDay.toUtc().toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => Sleep.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting sleeps for date: $e');
      return [];
    }
  }
  
  /// 수면 기록 삭제
  Future<bool> deleteSleep(String sleepId) async {
    try {
      // 삭제 전 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('sleeps')
          .select('baby_id, started_at')
          .eq('id', sleepId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final startedAt = DateTime.parse(existingResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          await _supabase
              .from('sleeps')
              .delete()
              .eq('id', sleepId);
          
          return true;
        },
        itemType: TimelineItemType.sleep,
        babyId: babyId,
        timestamp: startedAt,
        action: DataSyncAction.deleted,
        recordId: sleepId,
      );
    } catch (e) {
      debugPrint('Error deleting sleep: $e');
      return false;
    }
  }
  
  /// 수면 기록 수정
  Future<Sleep?> updateSleep({
    required String sleepId,
    int? durationMinutes,
    String? quality,
    String? location,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    try {
      // 기존 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('sleeps')
          .select('baby_id, started_at')
          .eq('id', sleepId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final originalStartedAt = DateTime.parse(existingResponse['started_at']);
      final updateTimestamp = startedAt ?? originalStartedAt;
      
      return await withDataSyncEvent(
        operation: () async {
          final updateData = <String, dynamic>{
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
          if (quality != null) updateData['quality'] = quality;
          if (location != null) updateData['location'] = location;
          if (notes != null) updateData['notes'] = notes;
          if (startedAt != null) updateData['started_at'] = startedAt.toIso8601String();
          if (endedAt != null) updateData['ended_at'] = endedAt.toIso8601String();
          
          final response = await _supabase
              .from('sleeps')
              .update(updateData)
              .eq('id', sleepId)
              .select()
              .single();
          
          return Sleep.fromJson(response);
        },
        itemType: TimelineItemType.sleep,
        babyId: babyId,
        timestamp: updateTimestamp,
        action: DataSyncAction.updated,
        recordId: sleepId,
      );
    } catch (e) {
      debugPrint('Error updating sleep: $e');
      return null;
    }
  }
  
  /// 현재 진행 중인 수면이 있는지 확인
  Future<Sleep?> getCurrentActiveSleep(String babyId) async {
    try {
      final response = await _supabase
          .from('sleeps')
          .select('*')
          .eq('baby_id', babyId)
          .isFilter('ended_at', null)
          .order('started_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        final sleepData = Map<String, dynamic>.from(response.first);
        // 활성 수면의 경우 duration_minutes는 항상 null로 설정 (실시간 계산을 위해)
        sleepData['duration_minutes'] = null;
        return Sleep.fromJson(sleepData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current active sleep: $e');
      return null;
    }
  }
  
  /// 진행 중인 수면 종료
  Future<Sleep?> endCurrentSleep(String sleepId, DateTime? endTime) async {
    try {
      final endDateTime = endTime ?? DateTime.now();
      
      // 먼저 현재 수면 기록을 가져와서 시작 시간과 babyId 확인
      final currentSleepResponse = await _supabase
          .from('sleeps')
          .select('baby_id, started_at')
          .eq('id', sleepId)
          .single();
      
      final babyId = currentSleepResponse['baby_id'] as String;
      final startedAt = DateTime.parse(currentSleepResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          // UTC 시간으로 duration 계산
          final startedAtUtc = startedAt.toUtc();
          final endDateTimeUtc = endDateTime.toUtc();
          final calculatedDuration = endDateTimeUtc.difference(startedAtUtc).inMinutes;
          
          debugPrint('Sleep duration calculation:');
          debugPrint('  Started at: $startedAtUtc');
          debugPrint('  Ended at: $endDateTimeUtc');
          debugPrint('  Calculated duration (minutes): $calculatedDuration');
          
          // 최소 1분으로 설정 (너무 짧은 수면 기록 방지)
          final actualDuration = calculatedDuration < 1 ? 1 : calculatedDuration;
          
          debugPrint('  Actual duration saved: $actualDuration');
          
          debugPrint('=== SLEEP END TIME PROCESSING ===');
          debugPrint('End time parameter: $endDateTime (isUtc: ${endDateTime.isUtc})');
          debugPrint('End time as ISO: ${endDateTime.toIso8601String()}');
          debugPrint('Current time: ${DateTime.now()} (isUtc: ${DateTime.now().isUtc})');
          debugPrint('Current time as ISO: ${DateTime.now().toIso8601String()}');
          debugPrint('==================================');
          
          final response = await _supabase
              .from('sleeps')
              .update({
                'ended_at': endDateTime.toUtc().toIso8601String(),
                'duration_minutes': actualDuration,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', sleepId)
              .select()
              .single();
          
          final endedSleep = Sleep.fromJson(response);
          
          // 진행 중인 활동 종료 이벤트 추가 발송
          notifyOngoingStopped(
            itemType: TimelineItemType.sleep,
            babyId: babyId,
            timestamp: endDateTime,
            recordId: sleepId,
          );
          
          return endedSleep;
        },
        itemType: TimelineItemType.sleep,
        babyId: babyId,
        timestamp: endDateTime,
        action: DataSyncAction.updated,
        recordId: sleepId,
      );
    } catch (e) {
      debugPrint('Error ending current sleep: $e');
      return null;
    }
  }
}