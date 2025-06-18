import 'invitation.dart';

/// 초대 생성 요청 데이터
class CreateInvitationRequest {
  final String babyId;
  final InvitationRole role;
  final Duration? validFor; // 유효 기간 (기본값: 7일)

  const CreateInvitationRequest({
    required this.babyId,
    required this.role,
    this.validFor,
  });

  /// 기본 유효 기간 (7일)
  static const Duration defaultValidFor = Duration(days: 7);

  /// 실제 사용할 유효 기간
  Duration get effectiveValidFor => validFor ?? defaultValidFor;

  /// 만료 시간 계산
  DateTime get expiresAt => DateTime.now().add(effectiveValidFor);

  Map<String, dynamic> toJson() {
    return {
      'baby_id': babyId,
      'role': role.name,
      'valid_for_minutes': effectiveValidFor.inMinutes,
    };
  }

  @override
  String toString() {
    return 'CreateInvitationRequest(babyId: $babyId, role: $role, validFor: $effectiveValidFor)';
  }
}

/// 초대 수락 요청 데이터
class AcceptInvitationRequest {
  final String token;
  final String userId; // 수락하는 사용자의 ID

  const AcceptInvitationRequest({
    required this.token,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'AcceptInvitationRequest(token: $token, userId: $userId)';
  }
}

/// 초대 취소 요청 데이터
class CancelInvitationRequest {
  final String invitationId;
  final String reason; // 취소 이유 (선택사항)

  const CancelInvitationRequest({
    required this.invitationId,
    this.reason = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'invitation_id': invitationId,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'CancelInvitationRequest(invitationId: $invitationId, reason: $reason)';
  }
}

/// 초대 검색 필터
class InvitationFilter {
  final String? babyId;
  final String? inviterId;
  final String? inviteeId;
  final InvitationStatus? status;
  final InvitationRole? role;
  final bool? includeExpired;
  final int? limit;
  final int? offset;

  const InvitationFilter({
    this.babyId,
    this.inviterId,
    this.inviteeId,
    this.status,
    this.role,
    this.includeExpired,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (babyId != null) params['baby_id'] = babyId;
    if (inviterId != null) params['inviter_id'] = inviterId;
    if (inviteeId != null) params['invitee_id'] = inviteeId;
    if (status != null) params['status'] = status!.name;
    if (role != null) params['role'] = role!.name;
    if (includeExpired != null) params['include_expired'] = includeExpired;
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    
    return params;
  }

  @override
  String toString() {
    return 'InvitationFilter(babyId: $babyId, status: $status, role: $role)';
  }
}