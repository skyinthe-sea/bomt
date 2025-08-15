class FamilyInvite {
  final String id;
  final String code;
  final String familyGroupId;
  final String inviterId;
  final DateTime expiresAt;
  final bool isActive;
  final String? usedBy;
  final DateTime? usedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyInvite({
    required this.id,
    required this.code,
    required this.familyGroupId,
    required this.inviterId,
    required this.expiresAt,
    required this.isActive,
    this.usedBy,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyInvite.fromJson(Map<String, dynamic> json) {
    return FamilyInvite(
      id: json['id'] as String,
      code: json['code'] as String,
      familyGroupId: json['family_group_id'] as String,
      inviterId: json['inviter_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool,
      usedBy: json['used_by'] as String?,
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'family_group_id': familyGroupId,
      'inviter_id': inviterId,
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'used_by': usedBy,
      'used_at': usedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => isActive && !isExpired;
  bool get isUsed => usedBy != null;

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  FamilyInvite copyWith({
    String? id,
    String? code,
    String? familyGroupId,
    String? inviterId,
    DateTime? expiresAt,
    bool? isActive,
    String? usedBy,
    DateTime? usedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyInvite(
      id: id ?? this.id,
      code: code ?? this.code,
      familyGroupId: familyGroupId ?? this.familyGroupId,
      inviterId: inviterId ?? this.inviterId,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      usedBy: usedBy ?? this.usedBy,
      usedAt: usedAt ?? this.usedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyInvite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FamilyInvite(id: $id, code: $code, isActive: $isActive, isExpired: $isExpired)';
  }
}