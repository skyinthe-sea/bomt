import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/growth_record.dart';
import '../../core/config/supabase_config.dart';

class GrowthService {
  static GrowthService? _instance;
  static GrowthService get instance => _instance ??= GrowthService._();
  
  GrowthService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  /// 새로운 성장 기록 추가 (분리된 메모 지원)
  Future<GrowthRecord?> addGrowthRecord({
    required String babyId,
    required String userId,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? notes, // 호환성을 위해 유지
    String? weightNotes, // 체중 전용 메모
    String? heightNotes, // 키 전용 메모
    DateTime? recordedAt,
  }) async {
    try {
      final recordData = {
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'head_circumference_cm': headCircumferenceCm,
        'notes': notes,
        'weight_notes': weightNotes,
        'height_notes': heightNotes,
        'recorded_at': (recordedAt ?? DateTime.now()).toUtc().toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      
      debugPrint('저장될 데이터: 체중=${weightKg}, 키=${heightCm}, 머리둘레=${headCircumferenceCm}');
      
      final response = await _supabase
          .from('growth_records')
          .insert(recordData)
          .select()
          .single();
      
      return GrowthRecord.fromJson(response);
    } catch (e) {
      debugPrint('Error adding growth record: $e');
      return null;
    }
  }
  
  /// 시간 차이를 한국어 형식으로 변환하는 헬퍼 함수
  String _formatTimePeriod(DateTime from, DateTime to) {
    final difference = to.difference(from);
    final days = difference.inDays;
    
    if (days == 0) {
      final hours = difference.inHours;
      if (hours == 0) {
        final minutes = difference.inMinutes;
        return '($minutes분)';
      }
      return '($hours시간)';
    } else if (days < 7) {
      return '($days일)';
    } else if (days < 30) {
      final weeks = (days / 7).round();
      return '($weeks주)';
    } else if (days < 365) {
      final months = (days / 30).round();
      return '($months개월)';
    } else {
      final years = (days / 365).round();
      return '($years년)';
    }
  }

  /// 성장 기록 요약 정보 가져오기 (최근 기록들로 변화량 계산)
  Future<Map<String, dynamic>> getGrowthSummary(String babyId) async {
    try {
      final response = await _supabase
          .from('growth_records')
          .select('*')
          .eq('baby_id', babyId)
          .order('recorded_at', ascending: false);
      
      if (response.isEmpty) {
        return {
          'hasData': false,
          'latestWeight': null,
          'latestHeight': null,
          'latestHeadCircumference': null,
          'weightChange': 0.0,
          'heightChange': 0.0,
          'headCircumferenceChange': 0.0,
          'weightTimePeriod': null,
          'heightTimePeriod': null,
          'headCircumferenceTimePeriod': null,
          'lastRecordedAt': null,
        };
      }
      
      final latest = response.first;
      final latestWeight = (latest['weight_kg'] as num?)?.toDouble();
      final latestHeight = (latest['height_cm'] as num?)?.toDouble();
      final latestHeadCircumference = (latest['head_circumference_cm'] as num?)?.toDouble();
      final latestRecordedAt = DateTime.parse(latest['recorded_at'] as String);
      
      double weightChange = 0.0;
      double heightChange = 0.0;
      double headCircumferenceChange = 0.0;
      String? weightTimePeriod;
      String? heightTimePeriod;
      String? headCircumferenceTimePeriod;
      
      // 체중 변화량 계산 (유효한 이전 기록 찾기)
      if (latestWeight != null) {
        for (int i = 1; i < response.length; i++) {
          final previousWeight = (response[i]['weight_kg'] as num?)?.toDouble();
          if (previousWeight != null) {
            weightChange = latestWeight - previousWeight;
            final previousRecordedAt = DateTime.parse(response[i]['recorded_at'] as String);
            weightTimePeriod = _formatTimePeriod(previousRecordedAt, latestRecordedAt);
            break;
          }
        }
      }
      
      // 키 변화량 계산 (유효한 이전 기록 찾기)
      if (latestHeight != null) {
        for (int i = 1; i < response.length; i++) {
          final previousHeight = (response[i]['height_cm'] as num?)?.toDouble();
          if (previousHeight != null) {
            heightChange = latestHeight - previousHeight;
            final previousRecordedAt = DateTime.parse(response[i]['recorded_at'] as String);
            heightTimePeriod = _formatTimePeriod(previousRecordedAt, latestRecordedAt);
            break;
          }
        }
      }
      
      // 머리둘레 변화량 계산 (유효한 이전 기록 찾기)
      if (latestHeadCircumference != null) {
        for (int i = 1; i < response.length; i++) {
          final previousHeadCircumference = (response[i]['head_circumference_cm'] as num?)?.toDouble();
          if (previousHeadCircumference != null) {
            headCircumferenceChange = latestHeadCircumference - previousHeadCircumference;
            final previousRecordedAt = DateTime.parse(response[i]['recorded_at'] as String);
            headCircumferenceTimePeriod = _formatTimePeriod(previousRecordedAt, latestRecordedAt);
            break;
          }
        }
      }
      
      return {
        'hasData': true,
        'latestWeight': latestWeight,
        'latestHeight': latestHeight,
        'latestHeadCircumference': latestHeadCircumference,
        'weightChange': weightChange,
        'heightChange': heightChange,
        'headCircumferenceChange': headCircumferenceChange,
        'weightTimePeriod': weightTimePeriod,
        'heightTimePeriod': heightTimePeriod,
        'headCircumferenceTimePeriod': headCircumferenceTimePeriod,
        'lastRecordedAt': latest['recorded_at'],
      };
    } catch (e) {
      debugPrint('Error getting growth summary: $e');
      return {
        'hasData': false,
        'latestWeight': null,
        'latestHeight': null,
        'latestHeadCircumference': null,
        'weightChange': 0.0,
        'heightChange': 0.0,
        'headCircumferenceChange': 0.0,
        'weightTimePeriod': null,
        'heightTimePeriod': null,
        'headCircumferenceTimePeriod': null,
        'lastRecordedAt': null,
      };
    }
  }
  
  /// 모든 성장 기록 가져오기
  Future<List<GrowthRecord>> getAllGrowthRecords(String babyId) async {
    try {
      final response = await _supabase
          .from('growth_records')
          .select('*')
          .eq('baby_id', babyId)
          .order('recorded_at', ascending: false);
      
      return response.map((json) => GrowthRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting growth records: $e');
      return [];
    }
  }
  
  /// 성장 기록 삭제
  Future<bool> deleteGrowthRecord(String recordId) async {
    try {
      await _supabase
          .from('growth_records')
          .delete()
          .eq('id', recordId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting growth record: $e');
      return false;
    }
  }
  
  /// 성장 기록 수정
  Future<GrowthRecord?> updateGrowthRecord({
    required String recordId,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? notes,
    String? weightNotes,
    String? heightNotes,
    DateTime? recordedAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      
      if (weightKg != null) updateData['weight_kg'] = weightKg;
      if (heightCm != null) updateData['height_cm'] = heightCm;
      if (headCircumferenceCm != null) updateData['head_circumference_cm'] = headCircumferenceCm;
      if (notes != null) updateData['notes'] = notes;
      if (weightNotes != null) updateData['weight_notes'] = weightNotes;
      if (heightNotes != null) updateData['height_notes'] = heightNotes;
      if (recordedAt != null) updateData['recorded_at'] = recordedAt.toUtc().toIso8601String();
      
      final response = await _supabase
          .from('growth_records')
          .update(updateData)
          .eq('id', recordId)
          .select()
          .single();
      
      return GrowthRecord.fromJson(response);
    } catch (e) {
      debugPrint('Error updating growth record: $e');
      return null;
    }
  }
  
  /// 체중과 키를 동시에 저장하는 메서드
  Future<GrowthRecord?> addMultipleMeasurements({
    required String babyId,
    required String userId,
    required Map<String, double> measurements, // {'weight': value, 'height': value}
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      double? weightKg;
      double? heightCm;
      
      // measurements 맵에서 값 추출
      if (measurements.containsKey('weight')) {
        weightKg = measurements['weight'];
      }
      if (measurements.containsKey('height')) {
        heightCm = measurements['height'];
      }
      
      debugPrint('동시 저장: 체중=$weightKg, 키=$heightCm');
      
      // 하나의 레코드로 저장
      return addGrowthRecord(
        babyId: babyId,
        userId: userId,
        weightKg: weightKg,
        heightCm: heightCm,
        notes: notes, // 호환성을 위해 유지
        weightNotes: weightKg != null ? notes : null, // 체중이 있을 때만 체중 메모
        heightNotes: heightCm != null ? notes : null, // 키가 있을 때만 키 메모
        recordedAt: recordedAt,
      );
    } catch (e) {
      debugPrint('Error adding multiple measurements: $e');
      return null;
    }
  }

  /// 특정 타입(체중 또는 키)의 성장 기록만 추가하는 편의 메서드
  Future<GrowthRecord?> addSingleMeasurement({
    required String babyId,
    required String userId,
    required String type, // 'weight' 또는 'height'
    required double value,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      // 최신 성장 기록 가져오기 (기존 값 유지를 위해)
      final latestRecords = await _supabase
          .from('growth_records')
          .select('*')
          .eq('baby_id', babyId)
          .order('recorded_at', ascending: false)
          .limit(1);
      
      double? existingWeight;
      double? existingHeight;
      double? existingHeadCircumference;
      
      // 기존 기록이 있으면 값들을 가져옴
      if (latestRecords.isNotEmpty) {
        final latest = latestRecords.first;
        existingWeight = (latest['weight_kg'] as num?)?.toDouble();
        existingHeight = (latest['height_cm'] as num?)?.toDouble();
        existingHeadCircumference = (latest['head_circumference_cm'] as num?)?.toDouble();
        
        debugPrint('기존 기록 - 체중: $existingWeight, 키: $existingHeight, 머리둘레: $existingHeadCircumference');
      } else {
        debugPrint('기존 기록 없음 - 첫 번째 기록');
      }
      
      // 입력한 타입에 따라 해당 값만 업데이트하고 나머지는 기존 값 유지 (null이면 null 유지)
      switch (type) {
        case 'weight':
          debugPrint('체중 입력: $value, 기존 키 유지: $existingHeight');
          return addGrowthRecord(
            babyId: babyId,
            userId: userId,
            weightKg: value,
            heightCm: existingHeight, // 기존 키 값 유지 (null이면 null)
            headCircumferenceCm: existingHeadCircumference, // 기존 머리둘레 값 유지 (null이면 null)
            notes: notes, // 호환성을 위해 유지
            weightNotes: notes, // 🎯 체중 메모를 별도 필드에 저장
            recordedAt: recordedAt,
          );
        case 'height':
          debugPrint('키 입력: $value, 기존 체중 유지: $existingWeight');
          return addGrowthRecord(
            babyId: babyId,
            userId: userId,
            weightKg: existingWeight, // 기존 체중 값 유지 (null이면 null)
            heightCm: value,
            headCircumferenceCm: existingHeadCircumference, // 기존 머리둘레 값 유지 (null이면 null)
            notes: notes, // 호환성을 위해 유지
            heightNotes: notes, // 🎯 키 메모를 별도 필드에 저장
            recordedAt: recordedAt,
          );
        default:
          throw ArgumentError('Invalid measurement type: $type');
      }
    } catch (e) {
      debugPrint('Error adding single measurement: $e');
      return null;
    }
  }
}