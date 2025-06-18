import '../models/invitation.dart';
import '../models/invitation_request.dart';

abstract class InvitationRepository {
  /// 새로운 초대 생성
  Future<Invitation> createInvitation(CreateInvitationRequest request, String inviterId);

  /// 토큰으로 초대 조회 (딥링크 검증용)
  Future<Invitation?> getInvitationByToken(String token);

  /// 초대 ID로 조회
  Future<Invitation?> getInvitationById(String id);

  /// 초대 수락
  Future<Invitation> acceptInvitation(AcceptInvitationRequest request);

  /// 초대 취소
  Future<Invitation> cancelInvitation(CancelInvitationRequest request);

  /// 특정 조건으로 초대 목록 조회
  Future<List<Invitation>> getInvitations(InvitationFilter filter);

  /// 사용자가 생성한 초대 목록 조회
  Future<List<Invitation>> getInvitationsByInviter(String inviterId);

  /// 사용자가 받은 초대 목록 조회 (수락한 것만)
  Future<List<Invitation>> getAcceptedInvitationsByInvitee(String inviteeId);

  /// 아기에 대한 활성 초대 목록 조회 (pending 상태만)
  Future<List<Invitation>> getActiveInvitationsForBaby(String babyId);

  /// 만료된 초대들을 일괄 처리
  Future<void> expireOldInvitations();

  /// 초대 통계 조회 (선택사항)
  Future<Map<String, int>> getInvitationStats(String userId);
}