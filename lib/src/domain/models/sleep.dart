class Sleep {
  final String id;
  final String babyId;
  final String userId;
  final int? durationMinutes;
  final String? quality; // good, fair, poor
  final String? location;
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Sleep({
    required this.id,
    required this.babyId,
    required this.userId,
    this.durationMinutes,
    this.quality,
    this.location,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Sleep.fromJson(Map<String, dynamic> json) {
    return Sleep(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      durationMinutes: json['duration_minutes'],
      quality: json['quality'],
      location: json['location'],
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
      'duration_minutes': durationMinutes,
      'quality': quality,
      'location': location,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}