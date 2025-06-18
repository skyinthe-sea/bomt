import '../../repositories/invitation_repository.dart';
import '../../models/invitation.dart';
import '../../models/invitation_request.dart';

class CreateInvitationUseCase {
  final InvitationRepository _repository;

  CreateInvitationUseCase(this._repository);

  /// 새로운 초대 생성
  /// 
  /// [request] - 초대 생성 요청 데이터
  /// [inviterId] - 초대하는 사용자 ID
  /// 
  /// Returns: 생성된 초대 정보
  /// Throws: 초대 생성 실패 시 예외
  Future<Invitation> execute(CreateInvitationRequest request, String inviterId) async {
    // 비즈니스 규칙 검증
    await _validateInvitationRequest(request, inviterId);
    
    // 초대 생성
    final invitation = await _repository.createInvitation(request, inviterId);
    
    // 성공 로그 (프로덕션에서는 적절한 로깅 시스템 사용)
    print('초대 생성 성공: ${invitation.id} (Baby: ${request.babyId}, Role: ${request.role})');
    
    return invitation;
  }

  /// 초대 요청 검증
  Future<void> _validateInvitationRequest(CreateInvitationRequest request, String inviterId) async {
    // 1. 기본 유효성 검사
    if (request.babyId.isEmpty) {
      throw Exception('아기 정보가 필요합니다');
    }
    
    if (inviterId.isEmpty) {
      throw Exception('초대하는 사용자 정보가 필요합니다');
    }

    // 2. 유효 기간 검증 (최소 1시간, 최대 30일)
    final validFor = request.effectiveValidFor;
    if (validFor.inHours < 1) {
      throw Exception('초대 유효 기간은 최소 1시간이어야 합니다');
    }
    if (validFor.inDays > 30) {
      throw Exception('초대 유효 기간은 최대 30일까지 가능합니다');
    }

    // 3. 중복 초대 확인 - 같은 아기에 대한 활성 초대가 이미 있는지 확인
    final activeInvitations = await _repository.getActiveInvitationsForBaby(request.babyId);
    final existingInvitation = activeInvitations
        .where((inv) => inv.inviterId == inviterId && inv.role == request.role)
        .isNotEmpty;
    
    if (existingInvitation) {
      throw Exception('해당 역할에 대한 활성 초대가 이미 존재합니다');
    }

    // 4. 초대 제한 확인 (한 아기당 최대 5개의 활성 초대)
    if (activeInvitations.length >= 5) {
      throw Exception('활성 초대가 너무 많습니다. 기존 초대를 처리한 후 다시 시도해주세요');
    }
  }

  /// 딥링크 URL 생성
  String generateDeepLink(String token, {String scheme = 'bomtapp'}) {
    return '$scheme://invite?token=$token';
  }

  /// 공유용 메시지 생성
  String generateShareMessage(String babyName, InvitationRole role, String deepLink) {
    final roleText = role.displayName;
    
    return '''
🍼 BOMT 육아 기록 앱 초대

$babyName의 $roleText로 함께 육아 기록을 관리해보세요!

📱 앱이 없다면 먼저 설치해주세요:
- Android: Play 스토어에서 "BOMT" 검색
- iOS: App Store에서 "BOMT" 검색

📲 앱 설치 후 아래 링크를 클릭하세요:
$deepLink

⏰ 이 초대는 7일간 유효합니다.
''';
  }
}