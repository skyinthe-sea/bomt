enum InvitationStatus {
  pending,
  accepted,
  expired,
  cancelled;

  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return '대기중';
      case InvitationStatus.accepted:
        return '수락됨';
      case InvitationStatus.expired:
        return '만료됨';
      case InvitationStatus.cancelled:
        return '취소됨';
    }
  }

  static InvitationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'expired':
        return InvitationStatus.expired;
      case 'cancelled':
        return InvitationStatus.cancelled;
      default:
        throw ArgumentError('Unknown invitation status: $value');
    }
  }
}

enum InvitationRole {
  parent,
  caregiver,
  guardian;

  String get displayName {
    switch (this) {
      case InvitationRole.parent:
        return '부모';
      case InvitationRole.caregiver:
        return '돌봄이';
      case InvitationRole.guardian:
        return '보호자';
    }
  }

  static InvitationRole fromString(String value) {
    switch (value) {
      case 'parent':
        return InvitationRole.parent;
      case 'caregiver':
        return InvitationRole.caregiver;
      case 'guardian':
        return InvitationRole.guardian;
      default:
        throw ArgumentError('Unknown invitation role: $value');
    }
  }
}

class Invitation {
  final String id;
  final String babyId;
  final String inviterId;
  final String? inviteeId;
  final String token;
  final InvitationRole role;
  final InvitationStatus status;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invitation({
    required this.id,
    required this.babyId,
    required this.inviterId,
    this.inviteeId,
    required this.token,
    required this.role,
    required this.status,
    required this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      babyId: json['baby_id'] as String,
      inviterId: json['inviter_id'] as String,
      inviteeId: json['invitee_id'] as String?,
      token: json['token'] as String,
      role: InvitationRole.fromString(json['role'] as String),
      status: InvitationStatus.fromString(json['status'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_id': babyId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'token': token,
      'role': role.name,
      'status': status.name,
      'expires_at': expiresAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Invitation copyWith({
    String? id,
    String? babyId,
    String? inviterId,
    String? inviteeId,
    String? token,
    InvitationRole? role,
    InvitationStatus? status,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      token: token ?? this.token,
      role: role ?? this.role,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 초대가 유효한지 확인 (만료되지 않고 pending 상태)
  bool get isValid => 
      status == InvitationStatus.pending && 
      expiresAt.isAfter(DateTime.now());

  /// 초대가 만료되었는지 확인
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  /// 초대를 수락할 수 있는지 확인
  bool get canAccept => isValid;

  /// 남은 시간 계산 (분 단위)
  int get remainingMinutes {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inMinutes;
  }

  /// 남은 시간을 사용자 친화적 형태로 반환
  String get remainingTimeString {
    final remaining = expiresAt.difference(DateTime.now());
    
    if (remaining.isNegative) {
      return '만료됨';
    }
    
    if (remaining.inDays > 0) {
      return '${remaining.inDays}일 남음';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}시간 남음';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}분 남음';
    } else {
      return '곧 만료';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invitation &&
        other.id == id &&
        other.babyId == babyId &&
        other.inviterId == inviterId &&
        other.inviteeId == inviteeId &&
        other.token == token &&
        other.role == role &&
        other.status == status &&
        other.expiresAt == expiresAt &&
        other.acceptedAt == acceptedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      inviterId,
      inviteeId,
      token,
      role,
      status,
      expiresAt,
      acceptedAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Invitation(id: $id, babyId: $babyId, status: $status, role: $role)';
  }
}