import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/diaper.dart';
import '../../domain/models/timeline_item.dart';
import '../../core/config/supabase_config.dart';
import '../../core/mixins/data_sync_mixin.dart';
import '../../core/events/data_sync_events.dart';

class DiaperService with DataSyncMixin {
  static DiaperService? _instance;
  static DiaperService get instance => _instance ??= DiaperService._();
  
  DiaperService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키 - 타입별 기본값
  static const String _diaperWetColorKey = 'diaper_wet_default_color';
  static const String _diaperWetConsistencyKey = 'diaper_wet_default_consistency';
  static const String _diaperDirtyColorKey = 'diaper_dirty_default_color';
  static const String _diaperDirtyConsistencyKey = 'diaper_dirty_default_consistency';
  static const String _diaperBothColorKey = 'diaper_both_default_color';
  static const String _diaperBothConsistencyKey = 'diaper_both_default_consistency';
  
  // 호환성을 위한 기존 키 (마이그레이션용)
  static const String _legacyDiaperTypeKey = 'diaper_default_type';
  static const String _legacyDiaperColorKey = 'diaper_default_color';
  static const String _legacyDiaperConsistencyKey = 'diaper_default_consistency';
  
  /// 타입별 기본 기저귀 설정 저장
  Future<void> saveDiaperDefaults({
    String? type,
    String? color,
    String? consistency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (type != null && color != null && consistency != null) {
      switch (type) {
        case 'wet':
          await prefs.setString(_diaperWetColorKey, color);
          await prefs.setString(_diaperWetConsistencyKey, consistency);
          break;
        case 'dirty':
          await prefs.setString(_diaperDirtyColorKey, color);
          await prefs.setString(_diaperDirtyConsistencyKey, consistency);
          break;
        case 'both':
          await prefs.setString(_diaperBothColorKey, color);
          await prefs.setString(_diaperBothConsistencyKey, consistency);
          break;
      }
    }
  }
  
  /// 타입별 기본 기저귀 설정 백업 저장 (새로운 API)
  Future<void> saveDiaperDefaultsForType({
    required String type,
    required String color,
    required String consistency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (type) {
      case 'wet':
        await prefs.setString(_diaperWetColorKey, color);
        await prefs.setString(_diaperWetConsistencyKey, consistency);
        break;
      case 'dirty':
        await prefs.setString(_diaperDirtyColorKey, color);
        await prefs.setString(_diaperDirtyConsistencyKey, consistency);
        break;
      case 'both':
        await prefs.setString(_diaperBothColorKey, color);
        await prefs.setString(_diaperBothConsistencyKey, consistency);
        break;
    }
  }
  
  /// 기본 기저귀 설정 불러오기 (레거시 호환성)
  Future<Map<String, dynamic>> getDiaperDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 레거시 지원: 기존 데이터가 있는 경우 마이그레이션
    final legacyType = prefs.getString(_legacyDiaperTypeKey);
    final legacyColor = prefs.getString(_legacyDiaperColorKey);
    final legacyConsistency = prefs.getString(_legacyDiaperConsistencyKey);
    
    if (legacyType != null && legacyColor != null && legacyConsistency != null) {
      // 레거시 데이터를 새로운 형식으로 마이그레이션
      await saveDiaperDefaultsForType(
        type: legacyType,
        color: legacyColor,
        consistency: legacyConsistency,
      );
      
      // 레거시 키 삭제
      await prefs.remove(_legacyDiaperTypeKey);
      await prefs.remove(_legacyDiaperColorKey);
      await prefs.remove(_legacyDiaperConsistencyKey);
    }
    
    return {
      'wet': {
        'color': prefs.getString(_diaperWetColorKey) ?? '투명',
        'consistency': prefs.getString(_diaperWetConsistencyKey) ?? '액체',
      },
      'dirty': {
        'color': prefs.getString(_diaperDirtyColorKey) ?? '노란색',
        'consistency': prefs.getString(_diaperDirtyConsistencyKey) ?? '보통',
      },
      'both': {
        'color': prefs.getString(_diaperBothColorKey) ?? '노란색',
        'consistency': prefs.getString(_diaperBothConsistencyKey) ?? '보통',
      },
    };
  }
  
  /// 특정 타입의 기본값 가져오기
  Future<Map<String, dynamic>> getDiaperDefaultsForType(String type) async {
    final allDefaults = await getDiaperDefaults();
    return allDefaults[type] ?? allDefaults['wet'];
  }
  
  /// 새로운 기저귀 교체 기록 추가
  Future<Diaper?> addDiaper({
    required String babyId,
    required String userId,
    String? type,
    String? color,
    String? consistency,
    String? notes,
    DateTime? changedAt,
  }) async {
    final diaperChangeTime = changedAt ?? DateTime.now();
    
    return await withDataSyncEvent(
      operation: () async {
        // 기본값이 설정되지 않은 경우 타입에 맞는 기본값 사용
        final diaperType = type ?? 'wet'; // 기본은 소변
        final typeDefaults = await getDiaperDefaultsForType(diaperType);
        
        final diaperData = {
          'id': _uuid.v4(),
          'baby_id': babyId,
          'user_id': userId,
          'type': diaperType,
          'color': color ?? typeDefaults['color'],
          'consistency': consistency ?? typeDefaults['consistency'],
          'notes': notes,
          'changed_at': diaperChangeTime.toUtc().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('diapers')
            .insert(diaperData)
            .select()
            .single();
        
        return Diaper.fromJson(response);
      },
      itemType: TimelineItemType.diaper,
      babyId: babyId,
      timestamp: diaperChangeTime,
      action: DataSyncAction.created,
    );
  }
  
  /// 오늘의 기저귀 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayDiaperSummary(String babyId) async {
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
          .from('diapers')
          .select('changed_at, type, color, consistency')
          .eq('baby_id', babyId)
          .gte('changed_at', todayStartUtc.toIso8601String())
          .lt('changed_at', tomorrowStartUtc.toIso8601String())
          .order('changed_at', ascending: false);
      
      int totalCount = response.length;
      DateTime? lastChangedTime;
      int? lastChangedMinutesAgo;
      
      Map<String, int> typeCount = {
        'wet': 0,
        'dirty': 0,
        'both': 0,
      };
      
      Map<String, int> colorCount = {};
      Map<String, int> consistencyCount = {};
      
      if (response.isNotEmpty) {
        // 타입별, 색상별, 농도별 계산
        for (var diaper in response) {
          final type = diaper['type'] as String;
          if (typeCount.containsKey(type)) {
            typeCount[type] = typeCount[type]! + 1;
          }
          
          final color = diaper['color'] as String?;
          if (color != null) {
            colorCount[color] = (colorCount[color] ?? 0) + 1;
          }
          
          final consistency = diaper['consistency'] as String?;
          if (consistency != null) {
            consistencyCount[consistency] = (consistencyCount[consistency] ?? 0) + 1;
          }
        }
        
        // 최근 교체 시간 계산
        final lastDiaper = response.first;
        lastChangedTime = DateTime.parse(lastDiaper['changed_at']).toLocal();
        lastChangedMinutesAgo = now.difference(lastChangedTime).inMinutes;
      }
      
      return {
        'totalCount': totalCount,
        'wetCount': typeCount['wet']!,
        'dirtyCount': typeCount['dirty']!,
        'bothCount': typeCount['both']!,
        'lastChangedTime': lastChangedTime,
        'lastChangedMinutesAgo': lastChangedMinutesAgo,
        'typeCount': typeCount,
        'colorCount': colorCount,
        'consistencyCount': consistencyCount,
        'averageInterval': totalCount > 1 
            ? (24 * 60 / totalCount).round() // 하루를 교체 횟수로 나눈 평균 간격(분)
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting today diaper summary: $e');
      return {
        'totalCount': 0,
        'wetCount': 0,
        'dirtyCount': 0,
        'bothCount': 0,
        'lastChangedTime': null,
        'lastChangedMinutesAgo': null,
        'typeCount': {
          'wet': 0,
          'dirty': 0,
          'both': 0,
        },
        'colorCount': {},
        'consistencyCount': {},
        'averageInterval': 0,
      };
    }
  }
  
  /// 오늘의 기저귀 교체 기록 목록 가져오기
  Future<List<Diaper>> getTodayDiapers(String babyId) async {
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
          .from('diapers')
          .select('*')
          .eq('baby_id', babyId)
          .gte('changed_at', todayStartUtc.toIso8601String())
          .lt('changed_at', tomorrowStartUtc.toIso8601String())
          .order('changed_at', ascending: false);
      
      return response.map((json) => Diaper.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today diapers: $e');
      return [];
    }
  }

  /// 특정 날짜의 기저귀 교체 기록 목록 가져오기
  Future<List<Diaper>> getDiapersForDate(String babyId, DateTime date) async {
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
          .from('diapers')
          .select('*')
          .eq('baby_id', babyId)
          .gte('changed_at', startOfDayUtc.toIso8601String())
          .lte('changed_at', endOfDayUtc.toIso8601String())
          .order('changed_at', ascending: false);
      
      return response.map((json) => Diaper.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting diapers for date: $e');
      return [];
    }
  }
  
  /// 기저귀 기록 삭제
  Future<bool> deleteDiaper(String diaperId) async {
    try {
      // 삭제 전 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('diapers')
          .select('baby_id, changed_at')
          .eq('id', diaperId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final changedAt = DateTime.parse(existingResponse['changed_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          await _supabase
              .from('diapers')
              .delete()
              .eq('id', diaperId);
          
          return true;
        },
        itemType: TimelineItemType.diaper,
        babyId: babyId,
        timestamp: changedAt,
        action: DataSyncAction.deleted,
        recordId: diaperId,
      );
    } catch (e) {
      debugPrint('Error deleting diaper: $e');
      return false;
    }
  }
  
  /// 기저귀 기록 수정
  Future<Diaper?> updateDiaper({
    required String diaperId,
    String? type,
    String? color,
    String? consistency,
    String? notes,
    DateTime? changedAt,
  }) async {
    try {
      // 기존 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('diapers')
          .select('baby_id, changed_at')
          .eq('id', diaperId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final originalChangedAt = DateTime.parse(existingResponse['changed_at']);
      final updateTimestamp = changedAt ?? originalChangedAt;
      
      return await withDataSyncEvent(
        operation: () async {
          final updateData = <String, dynamic>{
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          if (type != null) updateData['type'] = type;
          if (color != null) updateData['color'] = color;
          if (consistency != null) updateData['consistency'] = consistency;
          if (notes != null) updateData['notes'] = notes;
          if (changedAt != null) updateData['changed_at'] = changedAt.toIso8601String();
          
          final response = await _supabase
              .from('diapers')
              .update(updateData)
              .eq('id', diaperId)
              .select()
              .single();
          
          return Diaper.fromJson(response);
        },
        itemType: TimelineItemType.diaper,
        babyId: babyId,
        timestamp: updateTimestamp,
        action: DataSyncAction.updated,
        recordId: diaperId,
      );
    } catch (e) {
      debugPrint('Error updating diaper: $e');
      return null;
    }
  }
  
  /// 일주일간 기저귀 교체 패턴 분석
  Future<Map<String, dynamic>> getWeeklyDiaperPattern(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: 7));
      
      final response = await _supabase
          .from('diapers')
          .select('changed_at, type')
          .eq('baby_id', babyId)
          .gte('changed_at', startOfWeek.toIso8601String())
          .order('changed_at', ascending: true);
      
      Map<int, int> hourlyPattern = {}; // 시간대별 교체 빈도
      Map<String, int> dailyCount = {}; // 일별 교체 횟수
      
      for (var diaper in response) {
        final changedAt = DateTime.parse(diaper['changed_at']).toLocal();
        final hour = changedAt.hour;
        final day = '${changedAt.month}-${changedAt.day}';
        
        hourlyPattern[hour] = (hourlyPattern[hour] ?? 0) + 1;
        dailyCount[day] = (dailyCount[day] ?? 0) + 1;
      }
      
      return {
        'weeklyTotal': response.length,
        'dailyAverage': response.length / 7,
        'hourlyPattern': hourlyPattern,
        'dailyCount': dailyCount,
        'peakHour': hourlyPattern.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key,
      };
    } catch (e) {
      debugPrint('Error getting weekly diaper pattern: $e');
      return {
        'weeklyTotal': 0,
        'dailyAverage': 0.0,
        'hourlyPattern': {},
        'dailyCount': {},
        'peakHour': 12,
      };
    }
  }
}