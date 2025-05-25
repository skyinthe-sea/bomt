class Diaper {
  final String id;
  final String babyId;
  final String userId;
  final String type; // wet, dirty, both
  final String? color;
  final String? consistency;
  final String? notes;
  final DateTime changedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Diaper({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.type,
    this.color,
    this.consistency,
    this.notes,
    required this.changedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Diaper.fromJson(Map<String, dynamic> json) {
    return Diaper(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      type: json['type'],
      color: json['color'],
      consistency: json['consistency'],
      notes: json['notes'],
      changedAt: DateTime.parse(json['changed_at']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_id': babyId,
      'user_id': userId,
      'type': type,
      'color': color,
      'consistency': consistency,
      'notes': notes,
      'changed_at': changedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}