import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/milk_pumping.dart';
import '../../domain/models/timeline_item.dart';
import '../../core/config/supabase_config.dart';
import '../../core/mixins/data_sync_mixin.dart';
import '../../core/events/data_sync_events.dart';

class MilkPumpingService with DataSyncMixin {
  static MilkPumpingService? _instance;
  static MilkPumpingService get instance => _instance ??= MilkPumpingService._();
  
  MilkPumpingService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _amountKey = 'milk_pumping_default_amount';
  static const String _durationKey = 'milk_pumping_default_duration';
  static const String _sideKey = 'milk_pumping_default_side';
  static const String _storageLocationKey = 'milk_pumping_default_storage_location';
  
  /// 기본 유축 설정 저장
  Future<void> saveMilkPumpingDefaults({
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (amountMl != null) {
      await prefs.setInt(_amountKey, amountMl);
    }
    if (durationMinutes != null) {
      await prefs.setInt(_durationKey, durationMinutes);
    }
    if (side != null) {
      await prefs.setString(_sideKey, side);
    }
    if (storageLocation != null) {
      await prefs.setString(_storageLocationKey, storageLocation);
    }
  }
  
  /// 기본 유축 설정 불러오기
  Future<Map<String, dynamic>> getMilkPumpingDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'amountMl': prefs.getInt(_amountKey) ?? 100,
      'durationMinutes': prefs.getInt(_durationKey) ?? 20,
      'side': prefs.getString(_sideKey) ?? 'both',
      'storageLocation': prefs.getString(_storageLocationKey) ?? 'refrigerator',
    };
  }
  
  /// 새로운 유축 기록 추가
  Future<MilkPumping?> addMilkPumping({
    required String babyId,
    required String userId,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    final pumpingStartTime = startedAt ?? DateTime.now();
    final isActivePumping = endedAt == null;
    
    return await withDataSyncEvent(
      operation: () async {
        // 기본값이 설정되지 않은 경우 저장된 기본값 사용
        final defaults = await getMilkPumpingDefaults();
        
        final now = DateTime.now();
        
        Map<String, dynamic> pumpingData;
        
        if (isActivePumping) {
          // 진행 중인 유축: amount와 ended_at은 null
          pumpingData = {
            'id': _uuid.v4(),
            'baby_id': babyId,
            'user_id': userId,
            'amount_ml': null,
            'duration_minutes': null,
            'side': side ?? defaults['side'],
            'storage_method': storageLocation ?? defaults['storageLocation'],
            'notes': notes,
            'started_at': pumpingStartTime.toUtc().toIso8601String(),
            'ended_at': null,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };
        } else {
          // 완료된 유축: duration 계산 또는 기본값 사용
          final duration = durationMinutes ?? defaults['durationMinutes'];
          final pumpingEndTime = endedAt ?? pumpingStartTime.add(Duration(minutes: duration));
          final actualDuration = durationMinutes ?? pumpingEndTime.difference(pumpingStartTime).inMinutes;
          
          // 🔧 FIX: endedAt이 현재 시간과 같으면 적절한 시작 시간 계산
          DateTime finalStartTime;
          DateTime finalEndTime;
          int finalDuration;
          
          if (endedAt != null && startedAt == null) {
            // Quick milk pumping case: endedAt만 제공되고 startedAt은 없음
            finalDuration = duration; // 기본 duration 사용 (20분)
            finalEndTime = endedAt;
            finalStartTime = endedAt.subtract(Duration(minutes: finalDuration));
          } else {
            // Normal case
            finalStartTime = pumpingStartTime;
            finalEndTime = pumpingEndTime;
            finalDuration = actualDuration;
          }
          
          pumpingData = {
            'id': _uuid.v4(),
            'baby_id': babyId,
            'user_id': userId,
            'amount_ml': amountMl ?? defaults['amountMl'],
            'duration_minutes': finalDuration,
            'side': side ?? defaults['side'],
            'storage_method': storageLocation ?? defaults['storageLocation'],
            'notes': notes,
            'started_at': finalStartTime.toUtc().toIso8601String(),
            'ended_at': finalEndTime.toUtc().toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };
        }
        
        final response = await _supabase
            .from('milk_pumping')
            .insert(pumpingData)
            .select()
            .single();
        
        final newPumping = MilkPumping.fromJson(response);
        
        // 진행 중인 유축일 경우 ongoing activity started 이벤트 추가 발송
        if (isActivePumping) {
          notifyOngoingStarted(
            itemType: TimelineItemType.milkPumping,
            babyId: babyId,
            timestamp: pumpingStartTime,
            recordId: newPumping.id,
          );
        }
        
        return newPumping;
      },
      itemType: TimelineItemType.milkPumping,
      babyId: babyId,
      timestamp: pumpingStartTime,
      action: DataSyncAction.created,
    );
  }
  
  /// 오늘의 유축 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayMilkPumpingSummary(String babyId) async {
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
          .from('milk_pumping')
          .select('started_at, ended_at, amount_ml, duration_minutes, side, storage_method')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalAmount = 0;
      int totalDuration = 0;
      DateTime? lastPumpingTime;
      int? lastPumpingMinutesAgo;
      Map<String, int> sideCount = {
        'left': 0,
        'right': 0,
        'both': 0,
      };
      Map<String, int> storageCount = {
        'refrigerator': 0,
        'freezer': 0,
        'room_temp': 0,
        'fed_immediately': 0,
      };
      
      if (response.isNotEmpty) {
        // 총 유축량 및 시간, 위치별 계산 (완료된 유축만 포함)
        for (var pumping in response) {
          final amountMl = pumping['amount_ml'] as int?;
          final durationMinutes = pumping['duration_minutes'] as int?;
          
          if (amountMl != null) {
            totalAmount += amountMl;
          }
          if (durationMinutes != null) {
            totalDuration += durationMinutes;
          }
          
          final side = pumping['side'] as String?;
          if (side != null && sideCount.containsKey(side)) {
            sideCount[side] = sideCount[side]! + 1;
          }
          
          final storageMethod = pumping['storage_method'] as String?;
          if (storageMethod != null && storageCount.containsKey(storageMethod)) {
            storageCount[storageMethod] = storageCount[storageMethod]! + 1;
          }
        }
        
        // 최근 유축 시간 계산
        final lastPumping = response.first;
        if (lastPumping['ended_at'] != null) {
          lastPumpingTime = DateTime.parse(lastPumping['ended_at']).toLocal();
          lastPumpingMinutesAgo = now.difference(lastPumpingTime).inMinutes;
        } else if (lastPumping['started_at'] != null) {
          // 진행 중인 유축인 경우 시작 시간 사용
          lastPumpingTime = DateTime.parse(lastPumping['started_at']).toLocal();
          lastPumpingMinutesAgo = now.difference(lastPumpingTime).inMinutes;
        }
      }
      
      return {
        'count': count,
        'totalAmount': totalAmount,
        'totalDuration': totalDuration,
        'lastPumpingTime': lastPumpingTime,
        'lastPumpingMinutesAgo': lastPumpingMinutesAgo,
        'sideCount': sideCount,
        'storageCount': storageCount,
        'averageAmount': count > 0 ? (totalAmount / count).round() : 0,
        'averageDuration': count > 0 ? (totalDuration / count).round() : 0,
      };
    } catch (e) {
      debugPrint('Error getting today milk pumping summary: $e');
      return {
        'count': 0,
        'totalAmount': 0,
        'totalDuration': 0,
        'lastPumpingTime': null,
        'lastPumpingMinutesAgo': null,
        'sideCount': {
          'left': 0,
          'right': 0,
          'both': 0,
        },
        'storageCount': {
          'refrigerator': 0,
          'freezer': 0,
          'room_temp': 0,
          'fed_immediately': 0,
        },
        'averageAmount': 0,
        'averageDuration': 0,
      };
    }
  }
  
  /// 오늘의 유축 기록 목록 가져오기
  Future<List<MilkPumping>> getTodayMilkPumpings(String babyId) async {
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
          .from('milk_pumping')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => MilkPumping.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today milk pumpings: $e');
      return [];
    }
  }

  /// 특정 날짜의 유축 기록 목록 가져오기
  Future<List<MilkPumping>> getMilkPumpingsForDate(String babyId, DateTime date) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final kstOffset = const Duration(hours: 9);
      final dateKst = date.isUtc ? date.add(kstOffset) : date;
      
      // 한국 시간 기준 해당 날짜 범위
      final startOfDayKst = DateTime(dateKst.year, dateKst.month, dateKst.day);
      final endOfDayKst = startOfDayKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final startOfDayUtc = startOfDayKst.subtract(kstOffset);
      final endOfDayUtc = endOfDayKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('milk_pumping')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDayUtc.toIso8601String())
          .lt('started_at', endOfDayUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => MilkPumping.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting milk pumpings for date: $e');
      return [];
    }
  }
  
  /// 유축 기록 삭제
  Future<bool> deleteMilkPumping(String milkPumpingId) async {
    try {
      // 삭제 전 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('milk_pumping')
          .select('baby_id, started_at')
          .eq('id', milkPumpingId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final startedAt = DateTime.parse(existingResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          await _supabase
              .from('milk_pumping')
              .delete()
              .eq('id', milkPumpingId);
          
          return true;
        },
        itemType: TimelineItemType.milkPumping,
        babyId: babyId,
        timestamp: startedAt,
        action: DataSyncAction.deleted,
        recordId: milkPumpingId,
      );
    } catch (e) {
      debugPrint('Error deleting milk pumping: $e');
      return false;
    }
  }
  
  /// 유축 기록 수정
  Future<MilkPumping?> updateMilkPumping({
    required String milkPumpingId,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    try {
      // 기존 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('milk_pumping')
          .select('baby_id, started_at')
          .eq('id', milkPumpingId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final originalStartedAt = DateTime.parse(existingResponse['started_at']);
      final updateTimestamp = startedAt ?? originalStartedAt;
      
      return await withDataSyncEvent(
        operation: () async {
          final updateData = <String, dynamic>{
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          if (amountMl != null) updateData['amount_ml'] = amountMl;
          if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
          if (side != null) updateData['side'] = side;
          if (storageLocation != null) updateData['storage_method'] = storageLocation;
          if (notes != null) updateData['notes'] = notes;
          if (startedAt != null) updateData['started_at'] = startedAt.toIso8601String();
          if (endedAt != null) updateData['ended_at'] = endedAt.toIso8601String();
          
          final response = await _supabase
              .from('milk_pumping')
              .update(updateData)
              .eq('id', milkPumpingId)
              .select()
              .single();
          
          return MilkPumping.fromJson(response);
        },
        itemType: TimelineItemType.milkPumping,
        babyId: babyId,
        timestamp: updateTimestamp,
        action: DataSyncAction.updated,
        recordId: milkPumpingId,
      );
    } catch (e) {
      debugPrint('Error updating milk pumping: $e');
      return null;
    }
  }
  
  /// 현재 진행 중인 유축이 있는지 확인
  Future<MilkPumping?> getCurrentActivePumping(String babyId) async {
    try {
      final response = await _supabase
          .from('milk_pumping')
          .select('*')
          .eq('baby_id', babyId)
          .isFilter('ended_at', null)
          .order('started_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return MilkPumping.fromJson(response.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current active pumping: $e');
      return null;
    }
  }
  
  /// 진행 중인 유축 종료
  Future<MilkPumping?> endCurrentPumping(String pumpingId, {
    DateTime? endTime,
    int? amountMl,
  }) async {
    try {
      final endDateTime = endTime ?? DateTime.now();
      
      // 먼저 현재 유축 기록을 가져와서 시작 시간과 babyId 확인
      final currentPumpingResponse = await _supabase
          .from('milk_pumping')
          .select('baby_id, started_at')
          .eq('id', pumpingId)
          .single();
      
      final babyId = currentPumpingResponse['baby_id'] as String;
      final startedAt = DateTime.parse(currentPumpingResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          // UTC 시간으로 duration 계산
          final startedAtUtc = startedAt.toUtc();
          final endDateTimeUtc = endDateTime.toUtc();
          final calculatedDuration = endDateTimeUtc.difference(startedAtUtc).inMinutes;
          // 최소 1분으로 설정 (너무 짧은 유축 기록 방지)
          final actualDuration = calculatedDuration < 1 ? 1 : calculatedDuration;
          
          final updateData = {
            'ended_at': endDateTime.toUtc().toIso8601String(),
            'duration_minutes': actualDuration,
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          // 유축량이 제공된 경우 추가
          if (amountMl != null) {
            updateData['amount_ml'] = amountMl;
          }
          
          final response = await _supabase
              .from('milk_pumping')
              .update(updateData)
              .eq('id', pumpingId)
              .select()
              .single();
          
          final endedPumping = MilkPumping.fromJson(response);
          
          // 진행 중인 활동 종료 이벤트 추가 발송
          notifyOngoingStopped(
            itemType: TimelineItemType.milkPumping,
            babyId: babyId,
            timestamp: endDateTime,
            recordId: pumpingId,
          );
          
          return endedPumping;
        },
        itemType: TimelineItemType.milkPumping,
        babyId: babyId,
        timestamp: endDateTime,
        action: DataSyncAction.updated,
        recordId: pumpingId,
      );
    } catch (e) {
      debugPrint('Error ending current pumping: $e');
      return null;
    }
  }
  
  /// 유축량 통계 분석 (최근 2주)
  Future<Map<String, dynamic>> getPumpingStatistics(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfTwoWeeks = now.subtract(const Duration(days: 14));
      
      final response = await _supabase
          .from('milk_pumping')
          .select('started_at, amount_ml, duration_minutes, side')
          .eq('baby_id', babyId)
          .gte('started_at', startOfTwoWeeks.toIso8601String())
          .not('ended_at', 'is', null) // 완료된 유축만 포함
          .order('started_at', ascending: true);
      
      if (response.isEmpty) {
        return {
          'totalSessions': 0,
          'totalAmount': 0,
          'totalDuration': 0,
          'averageAmount': 0.0,
          'averageDuration': 0.0,
          'dailyAverage': 0.0,
          'bestDay': null,
          'worstDay': null,
          'efficiency': 0.0, // ml per minute
        };
      }
      
      int totalSessions = response.length;
      int totalAmount = 0;
      int totalDuration = 0;
      Map<String, int> dailyAmounts = {};
      
      for (var pumping in response) {
        final amountMl = pumping['amount_ml'] as int? ?? 0;
        final durationMinutes = pumping['duration_minutes'] as int? ?? 0;
        
        totalAmount += amountMl;
        totalDuration += durationMinutes;
        
        // 일별 유축량 계산
        final pumpingDate = DateTime.parse(pumping['started_at']).toLocal();
        final dayKey = '${pumpingDate.year}-${pumpingDate.month.toString().padLeft(2, '0')}-${pumpingDate.day.toString().padLeft(2, '0')}';
        dailyAmounts[dayKey] = (dailyAmounts[dayKey] ?? 0) + amountMl;
      }
      
      // 최고/최악의 날 찾기
      String? bestDay;
      String? worstDay;
      int maxDailyAmount = 0;
      int minDailyAmount = double.maxFinite.toInt();
      
      dailyAmounts.forEach((day, amount) {
        if (amount > maxDailyAmount) {
          maxDailyAmount = amount;
          bestDay = day;
        }
        if (amount < minDailyAmount) {
          minDailyAmount = amount;
          worstDay = day;
        }
      });
      
      return {
        'totalSessions': totalSessions,
        'totalAmount': totalAmount,
        'totalDuration': totalDuration,
        'averageAmount': totalSessions > 0 ? totalAmount / totalSessions : 0.0,
        'averageDuration': totalSessions > 0 ? totalDuration / totalSessions : 0.0,
        'dailyAverage': dailyAmounts.isNotEmpty ? totalAmount / dailyAmounts.length : 0.0,
        'bestDay': bestDay,
        'worstDay': worstDay,
        'bestDayAmount': maxDailyAmount,
        'worstDayAmount': minDailyAmount == double.maxFinite.toInt() ? 0 : minDailyAmount,
        'efficiency': totalDuration > 0 ? totalAmount / totalDuration : 0.0, // ml per minute
        'dailyAmounts': dailyAmounts,
      };
    } catch (e) {
      debugPrint('Error getting pumping statistics: $e');
      return {
        'totalSessions': 0,
        'totalAmount': 0,
        'totalDuration': 0,
        'averageAmount': 0.0,
        'averageDuration': 0.0,
        'dailyAverage': 0.0,
        'bestDay': null,
        'worstDay': null,
        'bestDayAmount': 0,
        'worstDayAmount': 0,
        'efficiency': 0.0,
        'dailyAmounts': {},
      };
    }
  }
}