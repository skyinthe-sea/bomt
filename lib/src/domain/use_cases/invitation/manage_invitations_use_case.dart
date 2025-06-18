import '../../repositories/invitation_repository.dart';
import '../../models/invitation.dart';
import '../../models/invitation_request.dart';

class ManageInvitationsUseCase {
  final InvitationRepository _repository;

  ManageInvitationsUseCase(this._repository);

  /// 사용자가 생성한 초대 목록 조회
  Future<List<Invitation>> getUserSentInvitations(String userId) async {
    if (userId.isEmpty) {
      throw Exception('사용자 정보가 필요합니다');
    }
    
    return await _repository.getInvitationsByInviter(userId);
  }

  /// 사용자가 수락한 초대 목록 조회  
  Future<List<Invitation>> getUserAcceptedInvitations(String userId) async {
    if (userId.isEmpty) {
      throw Exception('사용자 정보가 필요합니다');
    }
    
    return await _repository.getAcceptedInvitationsByInvitee(userId);
  }

  /// 특정 아기에 대한 활성 초대 목록 조회
  Future<List<Invitation>> getBabyActiveInvitations(String babyId) async {
    if (babyId.isEmpty) {
      throw Exception('아기 정보가 필요합니다');
    }
    
    return await _repository.getActiveInvitationsForBaby(babyId);
  }

  /// 초대 취소
  Future<Invitation> cancelInvitation(String invitationId, String userId, {String reason = ''}) async {
    if (invitationId.isEmpty) {
      throw Exception('초대 정보가 필요합니다');
    }
    
    if (userId.isEmpty) {
      throw Exception('사용자 정보가 필요합니다');
    }

    // 1. 초대 조회 및 권한 확인
    final invitation = await _repository.getInvitationById(invitationId);
    if (invitation == null) {
      throw Exception('초대를 찾을 수 없습니다');
    }

    // 2. 취소 권한 확인 (초대한 사람만 취소 가능)
    if (invitation.inviterId != userId) {
      throw Exception('초대를 취소할 권한이 없습니다');
    }

    // 3. 취소 가능 상태 확인
    if (invitation.status != InvitationStatus.pending) {
      throw Exception('대기 중인 초대만 취소할 수 있습니다');
    }

    // 4. 초대 취소 처리
    final request = CancelInvitationRequest(
      invitationId: invitationId,
      reason: reason,
    );
    
    final cancelledInvitation = await _repository.cancelInvitation(request);
    
    // 5. 성공 로그
    print('초대 취소 성공: $invitationId (사유: ${reason.isEmpty ? '없음' : reason})');
    
    return cancelledInvitation;
  }

  /// 만료된 초대들을 일괄 정리
  Future<void> cleanupExpiredInvitations() async {
    try {
      await _repository.expireOldInvitations();
      print('만료된 초대 정리 완료');
    } catch (e) {
      print('만료된 초대 정리 실패: $e');
      throw Exception('만료된 초대 정리 중 오류가 발생했습니다');
    }
  }

  /// 초대 통계 조회
  Future<InvitationStatistics> getInvitationStatistics(String userId) async {
    if (userId.isEmpty) {
      throw Exception('사용자 정보가 필요합니다');
    }

    try {
      final stats = await _repository.getInvitationStats(userId);
      return InvitationStatistics.fromMap(stats);
    } catch (e) {
      throw Exception('초대 통계 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 초대 상세 정보 조회
  Future<InvitationDetails?> getInvitationDetails(String invitationId) async {
    if (invitationId.isEmpty) {
      throw Exception('초대 정보가 필요합니다');
    }

    final invitation = await _repository.getInvitationById(invitationId);
    if (invitation == null) {
      return null;
    }

    return InvitationDetails(
      invitation: invitation,
      isExpiringSoon: invitation.remainingMinutes < 60 && invitation.remainingMinutes > 0,
      canBeCancelled: invitation.status == InvitationStatus.pending,
      canBeAccepted: invitation.canAccept,
    );
  }

  /// 필터로 초대 검색
  Future<List<Invitation>> searchInvitations(InvitationFilter filter) async {
    return await _repository.getInvitations(filter);
  }
}

/// 초대 통계 정보
class InvitationStatistics {
  final int sentTotal;
  final int sentPending;
  final int sentAccepted;
  final int sentExpired;
  final int sentCancelled;
  final int receivedTotal;
  final int receivedAccepted;

  const InvitationStatistics({
    required this.sentTotal,
    required this.sentPending,
    required this.sentAccepted,
    required this.sentExpired,
    required this.sentCancelled,
    required this.receivedTotal,
    required this.receivedAccepted,
  });

  factory InvitationStatistics.fromMap(Map<String, int> map) {
    return InvitationStatistics(
      sentTotal: map['sent_total'] ?? 0,
      sentPending: map['sent_pending'] ?? 0,
      sentAccepted: map['sent_accepted'] ?? 0,
      sentExpired: map['sent_expired'] ?? 0,
      sentCancelled: map['sent_cancelled'] ?? 0,
      receivedTotal: map['received_total'] ?? 0,
      receivedAccepted: map['received_accepted'] ?? 0,
    );
  }

  /// 송신 성공률 (%)
  double get sentSuccessRate {
    if (sentTotal == 0) return 0.0;
    return (sentAccepted / sentTotal) * 100;
  }

  @override
  String toString() {
    return 'InvitationStatistics(sent: $sentTotal, accepted: $sentAccepted, success: ${sentSuccessRate.toStringAsFixed(1)}%)';
  }
}

/// 초대 상세 정보
class InvitationDetails {
  final Invitation invitation;
  final bool isExpiringSoon;
  final bool canBeCancelled;
  final bool canBeAccepted;

  const InvitationDetails({
    required this.invitation,
    required this.isExpiringSoon,
    required this.canBeCancelled,
    required this.canBeAccepted,
  });

  @override
  String toString() {
    return 'InvitationDetails(id: ${invitation.id}, status: ${invitation.status}, expiring: $isExpiringSoon)';
  }
}