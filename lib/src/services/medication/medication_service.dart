import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/medication.dart';
import '../../core/config/supabase_config.dart';

class MedicationService {
  static MedicationService? _instance;
  static MedicationService get instance => _instance ??= MedicationService._();
  
  MedicationService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _medicationNameKey = 'medication_default_name';
  static const String _dosageKey = 'medication_default_dosage';
  static const String _unitKey = 'medication_default_unit';
  static const String _routeKey = 'medication_default_route';
  
  /// 기본 약물 투여 설정 저장
  Future<void> saveMedicationDefaults({
    String? medicationName,
    String? dosage,
    String? unit,
    String? route,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (medicationName != null) {
      await prefs.setString(_medicationNameKey, medicationName);
    }
    if (dosage != null) {
      await prefs.setString(_dosageKey, dosage);
    }
    if (unit != null) {
      await prefs.setString(_unitKey, unit);
    }
    if (route != null) {
      await prefs.setString(_routeKey, route);
    }
  }
  
  /// 기본 약물 투여 설정 불러오기
  Future<Map<String, dynamic>> getMedicationDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'medicationName': prefs.getString(_medicationNameKey) ?? '해열제',
      'dosage': prefs.getString(_dosageKey) ?? '5',
      'unit': prefs.getString(_unitKey) ?? 'ml',
      'route': prefs.getString(_routeKey) ?? 'oral',
    };
  }
  
  /// 새로운 약물 투여 기록 추가
  Future<Medication?> addMedication({
    required String babyId,
    required String userId,
    String? medicationName,
    String? dosage,
    String? unit,
    String? route,
    String? notes,
    DateTime? administeredAt,
  }) async {
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getMedicationDefaults();
      
      final medicationData = {
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'medication_name': medicationName ?? defaults['medicationName'],
        'dosage': dosage ?? defaults['dosage'],
        'unit': unit ?? defaults['unit'],
        'route': route ?? defaults['route'],
        'notes': notes,
        'administered_at': (administeredAt ?? DateTime.now()).toUtc().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('medications')
          .insert(medicationData)
          .select()
          .single();
      
      return Medication.fromJson(response);
    } catch (e) {
      debugPrint('Error adding medication: $e');
      return null;
    }
  }
  
  /// 오늘의 약물 투여 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodayMedicationSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('medications')
          .select('administered_at, medication_name, dose, unit, medication_type')
          .eq('baby_id', babyId)
          .gte('administered_at', startOfDay.toIso8601String())
          .order('administered_at', ascending: false);
      
      int count = response.length;
      DateTime? lastAdministeredTime;
      int? lastAdministeredMinutesAgo;
      Map<String, int> medicationCount = {};
      Map<String, int> routeCount = {
        'oral': 0,
        'topical': 0,
        'inhaled': 0,
      };
      Map<String, double> dosageSum = {}; // 약물별 총 투여량
      
      if (response.isNotEmpty) {
        // 약물별, 투여방법별 계산
        for (var medication in response) {
          final medicationName = medication['medication_name'] as String;
          medicationCount[medicationName] = (medicationCount[medicationName] ?? 0) + 1;
          
          final route = medication['medication_type'] as String?;
          if (route != null && routeCount.containsKey(route)) {
            routeCount[route] = routeCount[route]! + 1;
          }
          
          // 총 투여량 계산 (숫자로 변환 가능한 경우)
          final dosage = medication['dose'] as String?;
          if (dosage != null) {
            final dosageValue = double.tryParse(dosage);
            if (dosageValue != null) {
              dosageSum[medicationName] = (dosageSum[medicationName] ?? 0) + dosageValue;
            }
          }
        }
        
        // 최근 투여 시간 계산
        final lastMedication = response.first;
        lastAdministeredTime = DateTime.parse(lastMedication['administered_at']).toLocal();
        lastAdministeredMinutesAgo = now.difference(lastAdministeredTime).inMinutes;
      }
      
      return {
        'count': count,
        'lastAdministeredTime': lastAdministeredTime,
        'lastAdministeredMinutesAgo': lastAdministeredMinutesAgo,
        'medicationCount': medicationCount,
        'routeCount': routeCount,
        'dosageSum': dosageSum,
        'uniqueMedications': medicationCount.keys.length,
      };
    } catch (e) {
      debugPrint('Error getting today medication summary: $e');
      return {
        'count': 0,
        'lastAdministeredTime': null,
        'lastAdministeredMinutesAgo': null,
        'medicationCount': {},
        'routeCount': {
          'oral': 0,
          'topical': 0,
          'inhaled': 0,
        },
        'dosageSum': {},
        'uniqueMedications': 0,
      };
    }
  }
  
  /// 오늘의 약물 투여 기록 목록 가져오기
  Future<List<Medication>> getTodayMedications(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final response = await _supabase
          .from('medications')
          .select('*')
          .eq('baby_id', babyId)
          .gte('administered_at', startOfDay.toIso8601String())
          .order('administered_at', ascending: false);
      
      return response.map((json) => Medication.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today medications: $e');
      return [];
    }
  }
  
  /// 약물 투여 기록 삭제
  Future<bool> deleteMedication(String medicationId) async {
    try {
      await _supabase
          .from('medications')
          .delete()
          .eq('id', medicationId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      return false;
    }
  }
  
  /// 약물 투여 기록 수정
  Future<Medication?> updateMedication({
    required String medicationId,
    String? medicationName,
    String? dosage,
    String? unit,
    String? route,
    String? notes,
    DateTime? administeredAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (medicationName != null) updateData['medication_name'] = medicationName;
      if (dosage != null) updateData['dosage'] = dosage;
      if (unit != null) updateData['unit'] = unit;
      if (route != null) updateData['route'] = route;
      if (notes != null) updateData['notes'] = notes;
      if (administeredAt != null) updateData['administered_at'] = administeredAt.toIso8601String();
      
      final response = await _supabase
          .from('medications')
          .update(updateData)
          .eq('id', medicationId)
          .select()
          .single();
      
      return Medication.fromJson(response);
    } catch (e) {
      debugPrint('Error updating medication: $e');
      return null;
    }
  }
  
  /// 특정 약물의 투여 기록 조회 (최근 7일)
  Future<List<Medication>> getMedicationHistory(String babyId, String medicationName) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(const Duration(days: 7));
      
      final response = await _supabase
          .from('medications')
          .select('*')
          .eq('baby_id', babyId)
          .eq('medication_name', medicationName)
          .gte('administered_at', startOfWeek.toIso8601String())
          .order('administered_at', ascending: false);
      
      return response.map((json) => Medication.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting medication history: $e');
      return [];
    }
  }
  
  /// 약물별 투여 패턴 분석 (최근 2주)
  Future<Map<String, dynamic>> getMedicationPattern(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfTwoWeeks = now.subtract(const Duration(days: 14));
      
      final response = await _supabase
          .from('medications')
          .select('medication_name, administered_at, dosage')
          .eq('baby_id', babyId)
          .gte('administered_at', startOfTwoWeeks.toIso8601String())
          .order('administered_at', ascending: true);
      
      Map<String, List<DateTime>> medicationDates = {};
      Map<String, int> medicationFrequency = {};
      
      for (var medication in response) {
        final medicationName = medication['medication_name'] as String;
        final administeredAt = DateTime.parse(medication['administered_at']).toLocal();
        
        if (!medicationDates.containsKey(medicationName)) {
          medicationDates[medicationName] = [];
        }
        medicationDates[medicationName]!.add(administeredAt);
        medicationFrequency[medicationName] = (medicationFrequency[medicationName] ?? 0) + 1;
      }
      
      // 가장 자주 사용하는 약물
      String? mostUsedMedication;
      int maxFrequency = 0;
      medicationFrequency.forEach((medication, frequency) {
        if (frequency > maxFrequency) {
          maxFrequency = frequency;
          mostUsedMedication = medication;
        }
      });
      
      // 최근 투여된 약물
      String? recentMedication;
      DateTime? recentDate;
      if (response.isNotEmpty) {
        final recent = response.last;
        recentMedication = recent['medication_name'];
        recentDate = DateTime.parse(recent['administered_at']).toLocal();
      }
      
      return {
        'totalRecords': response.length,
        'medicationFrequency': medicationFrequency,
        'medicationDates': medicationDates.map((key, value) => 
            MapEntry(key, value.map((d) => d.toIso8601String()).toList())),
        'mostUsedMedication': mostUsedMedication,
        'mostUsedFrequency': maxFrequency,
        'recentMedication': recentMedication,
        'recentDate': recentDate?.toIso8601String(),
        'uniqueMedications': medicationFrequency.keys.length,
      };
    } catch (e) {
      debugPrint('Error getting medication pattern: $e');
      return {
        'totalRecords': 0,
        'medicationFrequency': {},
        'medicationDates': {},
        'mostUsedMedication': null,
        'mostUsedFrequency': 0,
        'recentMedication': null,
        'recentDate': null,
        'uniqueMedications': 0,
      };
    }
  }
}