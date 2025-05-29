import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/health_record.dart';
import '../../core/config/supabase_config.dart';

class HealthService {
  static HealthService? _instance;
  static HealthService get instance => _instance ??= HealthService._();
  
  HealthService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _defaultTemperatureKey = 'health_default_temperature';
  static const String _temperatureUnitKey = 'health_temperature_unit';
  static const String _measurementLocationKey = 'health_measurement_location';
  
  /// 기본 건강 설정 저장
  Future<void> saveHealthDefaults({
    double? defaultTemperature,
    String? temperatureUnit,
    String? measurementLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (defaultTemperature != null) {
      await prefs.setDouble(_defaultTemperatureKey, defaultTemperature);
    }
    if (temperatureUnit != null) {
      await prefs.setString(_temperatureUnitKey, temperatureUnit);
    }
    if (measurementLocation != null) {
      await prefs.setString(_measurementLocationKey, measurementLocation);
    }
  }
  
  /// 기본 건강 설정 불러오기
  Future<Map<String, dynamic>> getHealthDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'defaultTemperature': prefs.getDouble(_defaultTemperatureKey) ?? 36.5,
      'temperatureUnit': prefs.getString(_temperatureUnitKey) ?? '°C',
      'measurementLocation': prefs.getString(_measurementLocationKey) ?? '겨드랑이',
    };
  }
  
  /// 새로운 건강 기록 추가
  Future<HealthRecord?> addHealthRecord({
    required String babyId,
    required String userId,
    String? type,
    double? temperature,
    String? medicationName,
    String? medicationDose,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getHealthDefaults();
      
      final healthData = {
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'type': type ?? 'temperature',
        'temperature': temperature ?? defaults['defaultTemperature'],
        'medication_name': medicationName,
        'medication_dose': medicationDose,
        'notes': notes,
        'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('health_records')
          .insert(healthData)
          .select()
          .single();
      
      return HealthRecord.fromJson(response);
    } catch (e) {
      debugPrint('Error adding health record: $e');
      return null;
    }
  }
  
  /// 오늘의 건강 요약 정보 가져오기 (주로 체온)
  Future<Map<String, dynamic>> getTodayHealthSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('health_records')
          .select('recorded_at, type, temperature, medication_name')
          .eq('baby_id', babyId)
          .gte('recorded_at', startOfDay.toIso8601String())
          .order('recorded_at', ascending: false);
      
      int totalCount = response.length;
      int temperatureCount = 0;
      int medicationCount = 0;
      
      double? latestTemperature;
      double? minTemperature;
      double? maxTemperature;
      double avgTemperature = 0.0;
      
      DateTime? lastRecordTime;
      int? lastRecordMinutesAgo;
      
      List<double> temperatures = [];
      Map<String, int> typeCount = {
        'temperature': 0,
        'medication': 0,
        'vaccination': 0,
        'illness': 0,
        'doctor_visit': 0,
        'other': 0,
      };
      
      if (response.isNotEmpty) {
        // 타입별 계산 및 체온 데이터 처리
        for (var record in response) {
          final type = record['type'] as String;
          if (typeCount.containsKey(type)) {
            typeCount[type] = typeCount[type]! + 1;
          }
          
          if (type == 'temperature' && record['temperature'] != null) {
            final temp = _parseDouble(record['temperature']);
            if (temp != null) {
              temperatures.add(temp);
              temperatureCount++;
            }
          }
          
          if (type == 'medication') {
            medicationCount++;
          }
        }
        
        // 체온 통계 계산
        if (temperatures.isNotEmpty) {
          latestTemperature = temperatures.first;
          minTemperature = temperatures.reduce((a, b) => a < b ? a : b);
          maxTemperature = temperatures.reduce((a, b) => a > b ? a : b);
          avgTemperature = temperatures.reduce((a, b) => a + b) / temperatures.length;
        }
        
        // 최근 기록 시간 계산
        final lastRecord = response.first;
        lastRecordTime = DateTime.parse(lastRecord['recorded_at']);
        lastRecordMinutesAgo = now.difference(lastRecordTime).inMinutes;
      }
      
      // 체온 상태 판단
      String? temperatureStatus;
      if (latestTemperature != null) {
        if (latestTemperature < 36.0) {
          temperatureStatus = 'low';
        } else if (latestTemperature <= 37.5) {
          temperatureStatus = 'normal';
        } else if (latestTemperature <= 38.5) {
          temperatureStatus = 'mild_fever';
        } else {
          temperatureStatus = 'high_fever';
        }
      }
      
      return {
        'totalCount': totalCount,
        'temperatureCount': temperatureCount,
        'medicationCount': medicationCount,
        'latestTemperature': latestTemperature,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'avgTemperature': avgTemperature,
        'temperatureStatus': temperatureStatus,
        'lastRecordTime': lastRecordTime,
        'lastRecordMinutesAgo': lastRecordMinutesAgo,
        'typeCount': typeCount,
      };
    } catch (e) {
      debugPrint('Error getting today health summary: $e');
      return {
        'totalCount': 0,
        'temperatureCount': 0,
        'medicationCount': 0,
        'latestTemperature': null,
        'minTemperature': null,
        'maxTemperature': null,
        'avgTemperature': 0.0,
        'temperatureStatus': null,
        'lastRecordTime': null,
        'lastRecordMinutesAgo': null,
        'typeCount': {
          'temperature': 0,
          'medication': 0,
          'vaccination': 0,
          'illness': 0,
          'doctor_visit': 0,
          'other': 0,
        },
      };
    }
  }
  
  /// 오늘의 건강 기록 목록 가져오기
  Future<List<HealthRecord>> getTodayHealthRecords(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('health_records')
          .select('*')
          .eq('baby_id', babyId)
          .gte('recorded_at', startOfDay.toIso8601String())
          .order('recorded_at', ascending: false);
      
      return response.map((json) => HealthRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today health records: $e');
      return [];
    }
  }
  
  /// 건강 기록 삭제
  Future<bool> deleteHealthRecord(String recordId) async {
    try {
      await _supabase
          .from('health_records')
          .delete()
          .eq('id', recordId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting health record: $e');
      return false;
    }
  }
  
  /// 건강 기록 수정
  Future<HealthRecord?> updateHealthRecord({
    required String recordId,
    String? type,
    double? temperature,
    String? medicationName,
    String? medicationDose,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (type != null) updateData['type'] = type;
      if (temperature != null) updateData['temperature'] = temperature;
      if (medicationName != null) updateData['medication_name'] = medicationName;
      if (medicationDose != null) updateData['medication_dose'] = medicationDose;
      if (notes != null) updateData['notes'] = notes;
      if (recordedAt != null) updateData['recorded_at'] = recordedAt.toIso8601String();
      
      final response = await _supabase
          .from('health_records')
          .update(updateData)
          .eq('id', recordId)
          .select()
          .single();
      
      return HealthRecord.fromJson(response);
    } catch (e) {
      debugPrint('Error updating health record: $e');
      return null;
    }
  }
  
  /// 최근 체온 추세 분석
  Future<Map<String, dynamic>> getTemperatureTrend(String babyId, {int days = 7}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      
      final response = await _supabase
          .from('health_records')
          .select('recorded_at, temperature')
          .eq('baby_id', babyId)
          .eq('type', 'temperature')
          .gte('recorded_at', startDate.toIso8601String())
          .not('temperature', 'is', null)
          .order('recorded_at', ascending: true);
      
      List<Map<String, dynamic>> temperatureData = [];
      for (var record in response) {
        final temp = _parseDouble(record['temperature']);
        if (temp != null) {
          temperatureData.add({
            'time': DateTime.parse(record['recorded_at']),
            'temperature': temp,
          });
        }
      }
      
      // 추세 계산 (간단한 선형 회귀)
      String trend = 'stable';
      if (temperatureData.length >= 2) {
        final firstTemp = temperatureData.first['temperature'] as double;
        final lastTemp = temperatureData.last['temperature'] as double;
        final difference = lastTemp - firstTemp;
        
        if (difference > 0.5) {
          trend = 'rising';
        } else if (difference < -0.5) {
          trend = 'falling';
        }
      }
      
      return {
        'trend': trend,
        'data': temperatureData,
        'totalRecords': temperatureData.length,
        'averageTemperature': temperatureData.isNotEmpty
            ? temperatureData.map((e) => e['temperature'] as double).reduce((a, b) => a + b) / temperatureData.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting temperature trend: $e');
      return {
        'trend': 'stable',
        'data': [],
        'totalRecords': 0,
        'averageTemperature': 0.0,
      };
    }
  }
  
  /// 문자열을 double로 안전하게 파싱하는 헬퍼 함수
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('Error parsing double from string: $value');
        return null;
      }
    }
    return null;
  }
}