class SolidFood {
  final String id;
  final String babyId;
  final String userId;
  final String foodName;
  final int? amountGrams;
  final String? allergicReaction; // none, mild, moderate, severe
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SolidFood({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.foodName,
    this.amountGrams,
    this.allergicReaction,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SolidFood.fromJson(Map<String, dynamic> json) {
    return SolidFood(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      foodName: json['food_name'],
      amountGrams: json['amount'],
      allergicReaction: json['reaction'],
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
      'food_name': foodName,
      'amount': amountGrams,
      'reaction': allergicReaction,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}