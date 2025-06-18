class Family {
  final String id;
  final String? name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Family({
    required this.id,
    this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      name: json['name'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Family &&
        other.id == id &&
        other.name == name &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, createdBy, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'Family(id: $id, name: $name, createdBy: $createdBy)';
  }
}

/// 가족 구성원 정보
class FamilyMember {
  final String userId;
  final String role; // 'parent', 'caregiver', 'guardian'
  final DateTime joinedAt;

  const FamilyMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'created_at': joinedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember &&
        other.userId == userId &&
        other.role == role &&
        other.joinedAt == joinedAt;
  }

  @override
  int get hashCode {
    return Object.hash(userId, role, joinedAt);
  }

  @override
  String toString() {
    return 'FamilyMember(userId: $userId, role: $role)';
  }
}