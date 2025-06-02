class Medication {
  final String id;
  final String babyId;
  final String userId;
  final String medicationName;
  final String dosage;
  final String? unit; // ml, mg, tablets, drops
  final String? route; // oral, topical, inhaled
  final String? notes;
  final DateTime administeredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medication({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    this.unit,
    this.route,
    this.notes,
    required this.administeredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      medicationName: json['medication_name'],
      dosage: json['dosage'],
      unit: json['unit'],
      route: json['route'],
      notes: json['notes'],
      administeredAt: DateTime.parse(json['administered_at']).toLocal(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_id': babyId,
      'user_id': userId,
      'medication_name': medicationName,
      'dosage': dosage,
      'unit': unit,
      'route': route,
      'notes': notes,
      'administered_at': administeredAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}