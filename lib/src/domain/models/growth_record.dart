import 'package:flutter/foundation.dart';

class GrowthRecord {
  final String id;
  final String babyId;
  final String userId;
  final double? weightKg;
  final double? heightCm;
  final double? headCircumferenceCm;
  final String? notes; // 호환성을 위해 유지
  final String? weightNotes; // 체중 전용 메모
  final String? heightNotes; // 키 전용 메모
  final DateTime recordedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GrowthRecord({
    required this.id,
    required this.babyId,
    required this.userId,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.notes,
    this.weightNotes,
    this.heightNotes,
    required this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 [GrowthRecord] fromJson 시작');
    debugPrint('🔍 [GrowthRecord] 입력 JSON: $json');
    
    try {
      final id = json['id'];
      debugPrint('🔍 [GrowthRecord] id 처리: $id (type: ${id.runtimeType})');
      final processedId = id.toString();
      
      final babyId = json['baby_id'];
      debugPrint('🔍 [GrowthRecord] baby_id 처리: $babyId (type: ${babyId.runtimeType})');
      final processedBabyId = babyId.toString();
      
      final userId = json['user_id'];
      debugPrint('🔍 [GrowthRecord] user_id 처리: $userId (type: ${userId.runtimeType})');
      final processedUserId = userId.toString();
      
      final notes = json['notes'];
      debugPrint('🔍 [GrowthRecord] notes 처리: $notes (type: ${notes.runtimeType})');
      final processedNotes = notes == null ? null : notes.toString();
      
      final weightNotes = json['weight_notes'];
      debugPrint('🔍 [GrowthRecord] weight_notes 처리: $weightNotes (type: ${weightNotes.runtimeType})');
      final processedWeightNotes = weightNotes == null ? null : weightNotes.toString();
      
      final heightNotes = json['height_notes'];
      debugPrint('🔍 [GrowthRecord] height_notes 처리: $heightNotes (type: ${heightNotes.runtimeType})');
      final processedHeightNotes = heightNotes == null ? null : heightNotes.toString();
      
      final recordedAt = json['recorded_at'];
      debugPrint('🔍 [GrowthRecord] recorded_at 처리: $recordedAt (type: ${recordedAt.runtimeType})');
      final processedRecordedAt = DateTime.parse(recordedAt.toString()).toLocal();
      
      final createdAt = json['created_at'];
      debugPrint('🔍 [GrowthRecord] created_at 처리: $createdAt (type: ${createdAt.runtimeType})');
      final processedCreatedAt = createdAt != null ? DateTime.parse(createdAt.toString()).toLocal() : null;
      
      final updatedAt = json['updated_at'];
      debugPrint('🔍 [GrowthRecord] updated_at 처리: $updatedAt (type: ${updatedAt.runtimeType})');
      final processedUpdatedAt = updatedAt != null ? DateTime.parse(updatedAt.toString()).toLocal() : null;
      
      debugPrint('🔍 [GrowthRecord] GrowthRecord 생성자 호출 시작');
      final result = GrowthRecord(
        id: processedId,
        babyId: processedBabyId,
        userId: processedUserId,
        weightKg: json['weight_kg'] != null ? double.parse(json['weight_kg'].toString()) : null,
        heightCm: json['height_cm'] != null ? double.parse(json['height_cm'].toString()) : null,
        headCircumferenceCm: json['head_circumference_cm'] != null ? double.parse(json['head_circumference_cm'].toString()) : null,
        notes: processedNotes,
        weightNotes: processedWeightNotes,
        heightNotes: processedHeightNotes,
        recordedAt: processedRecordedAt,
        createdAt: processedCreatedAt,
        updatedAt: processedUpdatedAt,
      );
      
      debugPrint('✅ [GrowthRecord] fromJson 성공 완료');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [GrowthRecord] fromJson 에러: $e');
      debugPrint('❌ [GrowthRecord] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_id': babyId,
      'user_id': userId,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'head_circumference_cm': headCircumferenceCm,
      'notes': notes,
      'weight_notes': weightNotes,
      'height_notes': heightNotes,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 체중 관련 메모 가져오기 (완전 분리)
  String? get effectiveWeightNotes => weightNotes;
  
  /// 키 관련 메모 가져오기 (완전 분리)
  String? get effectiveHeightNotes => heightNotes;
}