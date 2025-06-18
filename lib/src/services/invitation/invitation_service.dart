import 'dart:async';
import '../../domain/repositories/invitation_repository.dart';
import '../../domain/models/invitation.dart';
import '../../domain/models/invitation_request.dart';
import '../../domain/use_cases/invitation/create_invitation_use_case.dart';
import '../../domain/use_cases/invitation/accept_invitation_use_case.dart';
import '../../domain/use_cases/invitation/manage_invitations_use_case.dart';
import '../../features/invitation/data/repositories/supabase_invitation_repository.dart';
import 'deeplink_service.dart';
import 'invitation_cache_service.dart';

class InvitationService {
  static final InvitationService _instance = InvitationService._internal();
  factory InvitationService() => _instance;
  InvitationService._internal();

  static InvitationService get instance => _instance;

  // 리포지토리 (싱글톤)
  late final InvitationRepository _repository;
  
  // 유스케이스들
  late final CreateInvitationUseCase _createUseCase;
  late final AcceptInvitationUseCase _acceptUseCase;
  late final ManageInvitationsUseCase _manageUseCase;
  
  // 딥링크 서비스
  late final DeepLinkService _deepLinkService;
  
  // 초기화 완료 플래그
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 캐시 서비스 초기화
      await InvitationCacheService.instance.initialize();
      
      // 리포지토리 초기화
      _repository = SupabaseInvitationRepository();
      
      // 유스케이스 초기화
      _createUseCase = CreateInvitationUseCase(_repository);
      _acceptUseCase = AcceptInvitationUseCase(_repository);
      _manageUseCase = ManageInvitationsUseCase(_repository);
      
      // 딥링크 서비스 초기화
      _deepLinkService = DeepLinkService.instance;
      await _deepLinkService.initializeDeepLinks();

      _isInitialized = true;
      print('InvitationService 초기화 완료');
    } catch (e) {
      print('InvitationService 초기화 실패: $e');
      throw Exception('초대 서비스 초기화에 실패했습니다: $e');
    }
  }

  /// 딥링크 이벤트 스트림
  Stream<DeepLinkEvent> get onDeepLink => _deepLinkService.onDeepLink;

  // === 초대 생성 관련 ===

  /// 새로운 초대 생성
  Future<InvitationResult> createInvitation({
    required String babyId,
    required String inviterId,
    required InvitationRole role,
    Duration? validFor,
  }) async {
    _ensureInitialized();

    try {
      final request = CreateInvitationRequest(
        babyId: babyId,
        role: role,
        validFor: validFor,
      );

      final invitation = await _createUseCase.execute(request, inviterId);
      final deepLink = _createUseCase.generateDeepLink(invitation.token);
      
      return InvitationResult.success(
        invitation: invitation,
        deepLink: deepLink,
        message: '초대가 생성되었습니다',
      );
    } catch (e) {
      return InvitationResult.failure('초대 생성에 실패했습니다: $e');
    }
  }

  /// 초대 링크 공유
  Future<bool> shareInvitation(Invitation invitation, String babyName) async {
    _ensureInitialized();

    try {
      final message = _createUseCase.generateShareMessage(
        babyName,
        invitation.role,
        _createUseCase.generateDeepLink(invitation.token),
      );

      await _deepLinkService.shareInviteLink(
        invitation.token,
        message,
        subject: 'BOMT 육아 앱 초대',
      );

      return true;
    } catch (e) {
      print('초대 공유 실패: $e');
      return false;
    }
  }

  // === 초대 수락 관련 ===

  /// 토큰 유효성 검증
  Future<InvitationValidationResult> validateInvitationToken(String token) async {
    _ensureInitialized();
    return await _acceptUseCase.validateToken(token);
  }

  /// 초대 수락
  Future<InvitationResult> acceptInvitation(String token, String userId) async {
    _ensureInitialized();

    try {
      final invitation = await _acceptUseCase.execute(token, userId);
      
      return InvitationResult.success(
        invitation: invitation,
        message: '초대를 수락했습니다',
      );
    } catch (e) {
      return InvitationResult.failure('초대 수락에 실패했습니다: $e');
    }
  }

  // === 초대 관리 관련 ===

  /// 사용자가 생성한 초대 목록
  Future<List<Invitation>> getUserSentInvitations(String userId) async {
    _ensureInitialized();
    return await _manageUseCase.getUserSentInvitations(userId);
  }

  /// 사용자가 수락한 초대 목록
  Future<List<Invitation>> getUserAcceptedInvitations(String userId) async {
    _ensureInitialized();
    return await _manageUseCase.getUserAcceptedInvitations(userId);
  }

  /// 아기에 대한 활성 초대 목록
  Future<List<Invitation>> getBabyActiveInvitations(String babyId) async {
    _ensureInitialized();
    return await _manageUseCase.getBabyActiveInvitations(babyId);
  }

  /// 초대 취소
  Future<InvitationResult> cancelInvitation(String invitationId, String userId, {String reason = ''}) async {
    _ensureInitialized();

    try {
      final invitation = await _manageUseCase.cancelInvitation(invitationId, userId, reason: reason);
      
      return InvitationResult.success(
        invitation: invitation,
        message: '초대가 취소되었습니다',
      );
    } catch (e) {
      return InvitationResult.failure('초대 취소에 실패했습니다: $e');
    }
  }

  /// 초대 상세 정보 조회
  Future<InvitationDetails?> getInvitationDetails(String invitationId) async {
    _ensureInitialized();
    return await _manageUseCase.getInvitationDetails(invitationId);
  }

  /// 초대 통계 조회
  Future<InvitationStatistics> getInvitationStatistics(String userId) async {
    _ensureInitialized();
    return await _manageUseCase.getInvitationStatistics(userId);
  }

  // === 백그라운드 작업 ===

  /// 만료된 초대 정리 (주기적으로 호출)
  Future<void> cleanupExpiredInvitations() async {
    _ensureInitialized();
    
    try {
      await _manageUseCase.cleanupExpiredInvitations();
    } catch (e) {
      print('만료된 초대 정리 실패: $e');
      // 백그라운드 작업이므로 예외를 다시 던지지 않음
    }
  }

  // === 유틸리티 ===

  /// 초기화 확인
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('InvitationService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
  }

  /// 서비스 정리
  void dispose() {
    _deepLinkService.dispose();
    _isInitialized = false;
    print('InvitationService 정리 완료');
  }

  // === 개발/테스트용 ===

  /// 딥링크 테스트 (개발용)
  void testDeepLink(String token) {
    _ensureInitialized();
    _deepLinkService.testInviteLink(token);
  }
}

/// 초대 작업 결과
class InvitationResult {
  final bool isSuccess;
  final String message;
  final Invitation? invitation;
  final String? deepLink;

  const InvitationResult._({
    required this.isSuccess,
    required this.message,
    this.invitation,
    this.deepLink,
  });

  factory InvitationResult.success({
    required Invitation invitation,
    required String message,
    String? deepLink,
  }) {
    return InvitationResult._(
      isSuccess: true,
      message: message,
      invitation: invitation,
      deepLink: deepLink,
    );
  }

  factory InvitationResult.failure(String message) {
    return InvitationResult._(
      isSuccess: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'InvitationResult(success: $isSuccess, message: $message)';
  }
}