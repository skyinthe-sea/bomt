class HealthRecord {
  final String id;
  final String babyId;
  final String userId;
  final String type; // temperature, medication, vaccination, illness, doctor_visit, other
  final double? temperature;
  final String? medicationName;
  final String? medicationDose;
  final String? notes;
  final DateTime recordedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthRecord({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.type,
    this.temperature,
    this.medicationName,
    this.medicationDose,
    this.notes,
    required this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      type: json['type'],
      temperature: json['temperature'] != null ? double.parse(json['temperature'].toString()) : null,
      medicationName: json['medication_name'],
      medicationDose: json['medication_dose'],
      notes: json['notes'],
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
      'type': type,
      'temperature': temperature,
      'medication_name': medicationName,
      'medication_dose': medicationDose,
      'notes': notes,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}