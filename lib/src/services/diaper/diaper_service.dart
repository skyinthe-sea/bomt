import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/diaper.dart';
import '../../core/config/supabase_config.dart';

class DiaperService {
  static DiaperService? _instance;
  static DiaperService get instance => _instance ??= DiaperService._();
  
  DiaperService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _diaperTypeKey = 'diaper_default_type';
  static const String _diaperColorKey = 'diaper_default_color';
  static const String _diaperConsistencyKey = 'diaper_default_consistency';
  
  /// 기본 기저귀 설정 저장
  Future<void> saveDiaperDefaults({
    String? type,
    String? color,
    String? consistency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (type != null) {
      await prefs.setString(_diaperTypeKey, type);
    }
    if (color != null) {
      await prefs.setString(_diaperColorKey, color);
    }
    if (consistency != null) {
      await prefs.setString(_diaperConsistencyKey, consistency);
    }
  }
  
  /// 기본 기저귀 설정 불러오기
  Future<Map<String, dynamic>> getDiaperDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'type': prefs.getString(_diaperTypeKey) ?? 'wet',
      'color': prefs.getString(_diaperColorKey) ?? '노란색',
      'consistency': prefs.getString(_diaperConsistencyKey) ?? '보통',
    };
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
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getDiaperDefaults();
      
      final diaperData = {
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'type': type ?? defaults['type'],
        'color': color ?? defaults['color'],
        'consistency': consistency ?? defaults['consistency'],
        'notes': notes,
        'changed_at': (changedAt ?? DateTime.now()).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('diapers')
          .insert(diaperData)
          .select()
          .single();
      
      return Diaper.fromJson(response);
    } catch (e) {
      debugPrint('Error adding diaper: $e');
      return null;
    }
  }
  
  /// 오늘의 기저귀 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayDiaperSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('diapers')
          .select('changed_at, type, color, consistency')
          .eq('baby_id', babyId)
          .gte('changed_at', startOfDay.toIso8601String())
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
        lastChangedTime = DateTime.parse(lastDiaper['changed_at']);
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
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('diapers')
          .select('*')
          .eq('baby_id', babyId)
          .gte('changed_at', startOfDay.toIso8601String())
          .order('changed_at', ascending: false);
      
      return response.map((json) => Diaper.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today diapers: $e');
      return [];
    }
  }
  
  /// 기저귀 기록 삭제
  Future<bool> deleteDiaper(String diaperId) async {
    try {
      await _supabase
          .from('diapers')
          .delete()
          .eq('id', diaperId);
      
      return true;
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
        final changedAt = DateTime.parse(diaper['changed_at']);
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