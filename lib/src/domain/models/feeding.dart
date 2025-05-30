class Feeding {
  final String id;
  final String babyId;
  final String userId;
  final String type; // breast, bottle, formula, solid
  final int? amountMl;
  final int? durationMinutes;
  final String? side; // left, right, both
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Feeding({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.type,
    this.amountMl,
    this.durationMinutes,
    this.side,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Feeding.fromJson(Map<String, dynamic> json) {
    return Feeding(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      type: json['type'],
      amountMl: json['amount_ml'],
      durationMinutes: json['duration_minutes'],
      side: json['side'],
      notes: json['notes'],
      startedAt: DateTime.parse(json['started_at']).toLocal(),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']).toLocal() : null,
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
      'amount_ml': amountMl,
      'duration_minutes': durationMinutes,
      'side': side,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}