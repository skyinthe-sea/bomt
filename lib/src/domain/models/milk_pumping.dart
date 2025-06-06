class MilkPumping {
  final String id;
  final String babyId;
  final String userId;
  final int? amountMl;
  final int? durationMinutes;
  final String? side; // left, right, both
  final String? storageLocation; // fridge, freezer, immediate_use
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MilkPumping({
    required this.id,
    required this.babyId,
    required this.userId,
    this.amountMl,
    this.durationMinutes,
    this.side,
    this.storageLocation,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory MilkPumping.fromJson(Map<String, dynamic> json) {
    return MilkPumping(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      amountMl: json['amount_ml'],
      durationMinutes: json['duration_minutes'],
      side: json['side'],
      storageLocation: json['storage_method'],
      notes: json['notes'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_id': babyId,
      'user_id': userId,
      'amount_ml': amountMl,
      'duration_minutes': durationMinutes,
      'side': side,
      'storage_method': storageLocation,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}