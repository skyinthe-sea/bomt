import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/sleep.dart';
import '../../core/config/supabase_config.dart';

class SleepService {
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
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getSleepDefaults();
      
      final now = DateTime.now();
      final sleepStartTime = startedAt ?? now;
      final duration = durationMinutes ?? defaults['durationMinutes'];
      final sleepEndTime = endedAt ?? sleepStartTime.add(Duration(minutes: duration));
      
      final sleepData = {
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'duration_minutes': duration,
        'quality': quality ?? defaults['quality'],
        'location': location ?? defaults['location'],
        'notes': notes,
        'started_at': sleepStartTime.toIso8601String(),
        'ended_at': sleepEndTime.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      final response = await _supabase
          .from('sleeps')
          .insert(sleepData)
          .select()
          .single();
      
      return Sleep.fromJson(response);
    } catch (e) {
      debugPrint('Error adding sleep: $e');
      return null;
    }
  }
  
  /// 오늘의 수면 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodaySleepSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('sleeps')
          .select('started_at, ended_at, duration_minutes, quality')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDay.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalMinutes = 0;
      DateTime? lastSleepTime;
      int? lastSleepMinutesAgo;
      Map<String, int> qualityCount = {
        'good': 0,
        'fair': 0,
        'poor': 0,
      };
      
      if (response.isNotEmpty) {
        // 총 수면 시간 및 품질별 계산
        for (var sleep in response) {
          if (sleep['duration_minutes'] != null) {
            totalMinutes += sleep['duration_minutes'] as int;
          }
          
          final quality = sleep['quality'] as String?;
          if (quality != null && qualityCount.containsKey(quality)) {
            qualityCount[quality] = qualityCount[quality]! + 1;
          }
        }
        
        // 최근 수면 시간 계산
        final lastSleep = response.first;
        if (lastSleep['ended_at'] != null) {
          lastSleepTime = DateTime.parse(lastSleep['ended_at']);
          lastSleepMinutesAgo = now.difference(lastSleepTime).inMinutes;
        }
      }
      
      return {
        'count': count,
        'totalMinutes': totalMinutes,
        'totalHours': totalMinutes ~/ 60,
        'remainingMinutes': totalMinutes % 60,
        'lastSleepTime': lastSleepTime,
        'lastSleepMinutesAgo': lastSleepMinutesAgo,
        'qualityCount': qualityCount,
        'averageDuration': count > 0 ? (totalMinutes / count).round() : 0,
      };
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
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('sleeps')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDay.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => Sleep.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today sleeps: $e');
      return [];
    }
  }
  
  /// 수면 기록 삭제
  Future<bool> deleteSleep(String sleepId) async {
    try {
      await _supabase
          .from('sleeps')
          .delete()
          .eq('id', sleepId);
      
      return true;
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
        return Sleep.fromJson(response.first);
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
      
      final response = await _supabase
          .from('sleeps')
          .update({
            'ended_at': endDateTime.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sleepId)
          .select()
          .single();
      
      // 실제 수면 시간으로 duration_minutes 업데이트
      final sleep = Sleep.fromJson(response);
      final actualDuration = endDateTime.difference(sleep.startedAt).inMinutes;
      
      final updatedResponse = await _supabase
          .from('sleeps')
          .update({
            'duration_minutes': actualDuration,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sleepId)
          .select()
          .single();
      
      return Sleep.fromJson(updatedResponse);
    } catch (e) {
      debugPrint('Error ending current sleep: $e');
      return null;
    }
  }
}