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
    return GrowthRecord(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      weightKg: json['weight_kg'] != null ? double.parse(json['weight_kg'].toString()) : null,
      heightCm: json['height_cm'] != null ? double.parse(json['height_cm'].toString()) : null,
      headCircumferenceCm: json['head_circumference_cm'] != null ? double.parse(json['head_circumference_cm'].toString()) : null,
      notes: json['notes'],
      weightNotes: json['weight_notes'],
      heightNotes: json['height_notes'],
      recordedAt: DateTime.parse(json['recorded_at']).toLocal(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
    );
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