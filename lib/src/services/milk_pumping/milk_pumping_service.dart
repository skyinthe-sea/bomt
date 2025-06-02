import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/milk_pumping.dart';
import '../../core/config/supabase_config.dart';

class MilkPumpingService {
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
      'storageLocation': prefs.getString(_storageLocationKey) ?? 'fridge',
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
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getMilkPumpingDefaults();
      
      final now = DateTime.now();
      final pumpingStartTime = startedAt ?? now;
      
      // 진행 중인 유축인지 완료된 유축인지 구분
      final isActivePumping = endedAt == null;
      
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
          'storage_location': storageLocation ?? defaults['storageLocation'],
          'notes': notes,
          'started_at': pumpingStartTime.toIso8601String(),
          'ended_at': null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
      } else {
        // 완료된 유축: duration 계산 또는 기본값 사용
        final duration = durationMinutes ?? defaults['durationMinutes'];
        final pumpingEndTime = endedAt ?? pumpingStartTime.add(Duration(minutes: duration));
        final actualDuration = durationMinutes ?? pumpingEndTime.difference(pumpingStartTime).inMinutes;
        
        pumpingData = {
          'id': _uuid.v4(),
          'baby_id': babyId,
          'user_id': userId,
          'amount_ml': amountMl ?? defaults['amountMl'],
          'duration_minutes': actualDuration,
          'side': side ?? defaults['side'],
          'storage_location': storageLocation ?? defaults['storageLocation'],
          'notes': notes,
          'started_at': pumpingStartTime.toIso8601String(),
          'ended_at': pumpingEndTime.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
      }
      
      final response = await _supabase
          .from('milk_pumping')
          .insert(pumpingData)
          .select()
          .single();
      
      return MilkPumping.fromJson(response);
    } catch (e) {
      debugPrint('Error adding milk pumping: $e');
      return null;
    }
  }
  
  /// 오늘의 유축 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayMilkPumpingSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final response = await _supabase
          .from('milk_pumping')
          .select('started_at, ended_at, amount_ml, duration_minutes, side, storage_method')
          .eq('baby_id', babyId)
          .gte('started_at', today.toUtc().toIso8601String())
          .lt('started_at', tomorrow.toUtc().toIso8601String())
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
          'fridge': 0,
          'freezer': 0,
          'immediate_use': 0,
        },
        'averageAmount': 0,
        'averageDuration': 0,
      };
    }
  }
  
  /// 오늘의 유축 기록 목록 가져오기
  Future<List<MilkPumping>> getTodayMilkPumpings(String babyId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final response = await _supabase
          .from('milk_pumping')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', today.toUtc().toIso8601String())
          .lt('started_at', tomorrow.toUtc().toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => MilkPumping.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today milk pumpings: $e');
      return [];
    }
  }
  
  /// 유축 기록 삭제
  Future<bool> deleteMilkPumping(String milkPumpingId) async {
    try {
      await _supabase
          .from('milk_pumping')
          .delete()
          .eq('id', milkPumpingId);
      
      return true;
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
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (amountMl != null) updateData['amount_ml'] = amountMl;
      if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
      if (side != null) updateData['side'] = side;
      if (storageLocation != null) updateData['storage_location'] = storageLocation;
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
      
      // 먼저 현재 유축 기록을 가져와서 시작 시간을 확인
      final currentPumpingResponse = await _supabase
          .from('milk_pumping')
          .select('started_at')
          .eq('id', pumpingId)
          .single();
      
      // UTC 시간으로 duration 계산
      final startedAtUtc = DateTime.parse(currentPumpingResponse['started_at']).toUtc();
      final endDateTimeUtc = endDateTime.toUtc();
      final calculatedDuration = endDateTimeUtc.difference(startedAtUtc).inMinutes;
      // 최소 1분으로 설정 (너무 짧은 유축 기록 방지)
      final actualDuration = calculatedDuration < 1 ? 1 : calculatedDuration;
      
      final updateData = {
        'ended_at': endDateTime.toIso8601String(),
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
      
      return MilkPumping.fromJson(response);
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