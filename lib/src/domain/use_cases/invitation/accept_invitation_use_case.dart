import '../../repositories/invitation_repository.dart';
import '../../models/invitation.dart';
import '../../models/invitation_request.dart';

class AcceptInvitationUseCase {
  final InvitationRepository _repository;

  AcceptInvitationUseCase(this._repository);

  /// 초대 수락
  /// 
  /// [token] - 초대 토큰
  /// [userId] - 수락하는 사용자 ID
  /// 
  /// Returns: 수락된 초대 정보
  /// Throws: 초대 수락 실패 시 예외
  Future<Invitation> execute(String token, String userId) async {
    // 1. 입력 검증
    if (token.isEmpty) {
      throw Exception('초대 토큰이 필요합니다');
    }
    
    if (userId.isEmpty) {
      throw Exception('사용자 정보가 필요합니다');
    }

    // 2. 토큰으로 초대 조회
    final invitation = await _repository.getInvitationByToken(token);
    if (invitation == null) {
      throw Exception('유효하지 않은 초대 링크입니다');
    }

    // 3. 비즈니스 규칙 검증
    await _validateAcceptance(invitation, userId);

    // 4. 초대 수락 처리
    final request = AcceptInvitationRequest(token: token, userId: userId);
    final acceptedInvitation = await _repository.acceptInvitation(request);

    // 5. 성공 로그
    print('초대 수락 성공: ${invitation.id} (User: $userId, Baby: ${invitation.babyId})');

    return acceptedInvitation;
  }

  /// 초대 수락 검증
  Future<void> _validateAcceptance(Invitation invitation, String userId) async {
    // 1. 초대 상태 확인
    if (invitation.status != InvitationStatus.pending) {
      switch (invitation.status) {
        case InvitationStatus.accepted:
          throw Exception('이미 수락된 초대입니다');
        case InvitationStatus.expired:
          throw Exception('만료된 초대입니다');
        case InvitationStatus.cancelled:
          throw Exception('취소된 초대입니다');
        default:
          throw Exception('처리할 수 없는 초대입니다');
      }
    }

    // 2. 만료 시간 확인
    if (invitation.isExpired) {
      throw Exception('초대가 만료되었습니다');
    }

    // 3. 자기 자신 초대 방지
    if (invitation.inviterId == userId) {
      throw Exception('자신이 생성한 초대는 수락할 수 없습니다');
    }

    // 4. 이미 해당 아기의 구성원인지 확인
    final acceptedInvitations = await _repository.getAcceptedInvitationsByInvitee(userId);
    final alreadyMember = acceptedInvitations
        .any((inv) => inv.babyId == invitation.babyId);
    
    if (alreadyMember) {
      throw Exception('이미 해당 아기의 구성원입니다');
    }
  }

  /// 토큰 유효성 미리 검증 (딥링크 처리 전 호출)
  Future<InvitationValidationResult> validateToken(String token) async {
    try {
      if (token.isEmpty) {
        return InvitationValidationResult.invalid('초대 토큰이 필요합니다');
      }

      final invitation = await _repository.getInvitationByToken(token);
      if (invitation == null) {
        return InvitationValidationResult.invalid('유효하지 않은 초대 링크입니다');
      }

      if (invitation.status != InvitationStatus.pending) {
        return InvitationValidationResult.invalid('처리할 수 없는 초대입니다');
      }

      if (invitation.isExpired) {
        return InvitationValidationResult.invalid('만료된 초대입니다');
      }

      return InvitationValidationResult.valid(invitation);
    } catch (e) {
      return InvitationValidationResult.invalid('초대 검증 중 오류가 발생했습니다: $e');
    }
  }
}

/// 토큰 검증 결과
class InvitationValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Invitation? invitation;

  const InvitationValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.invitation,
  });

  factory InvitationValidationResult.valid(Invitation invitation) {
    return InvitationValidationResult._(
      isValid: true,
      invitation: invitation,
    );
  }

  factory InvitationValidationResult.invalid(String message) {
    return InvitationValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }

  @override
  String toString() {
    return 'InvitationValidationResult(isValid: $isValid, error: $errorMessage)';
  }
}