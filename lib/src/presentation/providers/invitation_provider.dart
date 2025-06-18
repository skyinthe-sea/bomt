import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/invitation.dart';
import '../../domain/use_cases/invitation/manage_invitations_use_case.dart';
import '../../services/invitation/invitation_service.dart';
import '../../services/invitation/deeplink_service.dart';

class InvitationProvider extends ChangeNotifier {
  final InvitationService _invitationService = InvitationService.instance;
  
  // 상태 관리
  List<Invitation> _sentInvitations = [];
  List<Invitation> _receivedInvitations = [];
  List<Invitation> _pendingInvitations = [];
  InvitationStatistics? _statistics;
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // 오류 상태
  String? _errorMessage;
  
  // 딥링크 처리
  StreamSubscription<DeepLinkEvent>? _deepLinkSubscription;
  
  // Getters
  List<Invitation> get sentInvitations => List.unmodifiable(_sentInvitations);
  List<Invitation> get receivedInvitations => List.unmodifiable(_receivedInvitations);
  List<Invitation> get pendingInvitations => List.unmodifiable(_pendingInvitations);
  InvitationStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  
  // 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      // 초대 서비스 초기화
      await _invitationService.initialize();
      
      // 딥링크 이벤트 리스닝 시작
      _startDeepLinkListening();
      
      _isInitialized = true;
      debugPrint('InvitationProvider 초기화 완료');
    } catch (e) {
      _setError('초대 시스템 초기화에 실패했습니다: $e');
      debugPrint('InvitationProvider 초기화 실패: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 딥링크 이벤트 리스닝
  void _startDeepLinkListening() {
    _deepLinkSubscription = _invitationService.onDeepLink.listen(
      _handleDeepLinkEvent,
      onError: (error) {
        debugPrint('딥링크 이벤트 오류: $error');
        _setError('딥링크 처리 중 오류가 발생했습니다');
      },
    );
  }
  
  // 딥링크 이벤트 처리
  Future<void> _handleDeepLinkEvent(DeepLinkEvent event) async {
    debugPrint('딥링크 이벤트 수신: $event');
    
    if (event is InvitationDeepLinkEvent) {
      await _handleInvitationDeepLink(event.token);
    } else if (event is ErrorDeepLinkEvent) {
      _setError(event.message);
    }
  }
  
  // 초대 딥링크 처리
  Future<void> _handleInvitationDeepLink(String token) async {
    try {
      // 토큰 유효성 검증
      final validation = await _invitationService.validateInvitationToken(token);
      
      if (!validation.isValid) {
        _setError(validation.errorMessage ?? '유효하지 않은 초대입니다');
        return;
      }
      
      // 유효한 초대인 경우 UI에서 처리할 수 있도록 알림
      _notifyInvitationReceived(validation.invitation!);
      
    } catch (e) {
      _setError('초대 처리 중 오류가 발생했습니다: $e');
    }
  }
  
  // 초대 수신 알림 (UI에서 처리)
  void _notifyInvitationReceived(Invitation invitation) {
    // 이 메서드는 UI 컴포넌트에서 listen할 수 있도록 별도의 스트림이나 콜백으로 처리
    debugPrint('유효한 초대 수신: ${invitation.id}');
    // TODO: UI 알림 처리
  }
  
  // 사용자별 초대 데이터 로드
  Future<void> loadUserInvitations(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // 병렬로 데이터 로드
      final results = await Future.wait([
        _invitationService.getUserSentInvitations(userId),
        _invitationService.getUserAcceptedInvitations(userId),
        _invitationService.getInvitationStatistics(userId),
      ]);
      
      _sentInvitations = results[0] as List<Invitation>;
      _receivedInvitations = results[1] as List<Invitation>;
      _statistics = results[2] as InvitationStatistics;
      
      // 대기 중인 초대만 필터링
      _pendingInvitations = _sentInvitations
          .where((inv) => inv.status == InvitationStatus.pending)
          .toList();
      
      debugPrint('사용자 초대 데이터 로드 완료: 보낸 ${_sentInvitations.length}, 받은 ${_receivedInvitations.length}');
      
    } catch (e) {
      _setError('초대 데이터를 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 아기별 활성 초대 로드
  Future<void> loadBabyInvitations(String babyId) async {
    try {
      final activeInvitations = await _invitationService.getBabyActiveInvitations(babyId);
      
      // 현재 아기의 대기 중인 초대 업데이트
      _pendingInvitations = activeInvitations;
      
      debugPrint('아기 활성 초대 로드 완료: ${activeInvitations.length}개');
      notifyListeners();
      
    } catch (e) {
      _setError('아기 초대 정보를 불러오는데 실패했습니다: $e');
    }
  }
  
  // 새 초대 생성
  Future<bool> createInvitation({
    required String babyId,
    required String inviterId,
    required InvitationRole role,
    Duration? validFor,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _invitationService.createInvitation(
        babyId: babyId,
        inviterId: inviterId,
        role: role,
        validFor: validFor,
      );
      
      if (result.isSuccess && result.invitation != null) {
        // 로컬 상태 업데이트
        _sentInvitations.insert(0, result.invitation!);
        _pendingInvitations.insert(0, result.invitation!);
        
        debugPrint('새 초대 생성 완료: ${result.invitation!.id}');
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
      
    } catch (e) {
      _setError('초대 생성에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 초대 수락
  Future<bool> acceptInvitation(String token, String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _invitationService.acceptInvitation(token, userId);
      
      if (result.isSuccess && result.invitation != null) {
        // 로컬 상태 업데이트
        _receivedInvitations.insert(0, result.invitation!);
        
        debugPrint('초대 수락 완료: ${result.invitation!.id}');
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
      
    } catch (e) {
      _setError('초대 수락에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 초대 취소
  Future<bool> cancelInvitation(String invitationId, String userId, {String reason = ''}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _invitationService.cancelInvitation(invitationId, userId, reason: reason);
      
      if (result.isSuccess && result.invitation != null) {
        // 로컬 상태 업데이트
        final updatedInvitation = result.invitation!;
        _updateInvitationInList(_sentInvitations, updatedInvitation);
        _updateInvitationInList(_pendingInvitations, updatedInvitation);
        
        debugPrint('초대 취소 완료: ${updatedInvitation.id}');
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
      
    } catch (e) {
      _setError('초대 취소에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 초대 공유
  Future<bool> shareInvitation(Invitation invitation, String babyName) async {
    try {
      final success = await _invitationService.shareInvitation(invitation, babyName);
      
      if (!success) {
        _setError('초대 공유에 실패했습니다');
      }
      
      return success;
    } catch (e) {
      _setError('초대 공유 중 오류가 발생했습니다: $e');
      return false;
    }
  }
  
  // 만료된 초대 정리
  Future<void> cleanupExpiredInvitations() async {
    try {
      await _invitationService.cleanupExpiredInvitations();
      
      // 로컬 상태에서도 만료된 초대 제거
      _pendingInvitations.removeWhere((inv) => inv.isExpired);
      _sentInvitations.removeWhere((inv) => inv.isExpired);
      
      notifyListeners();
      debugPrint('만료된 초대 정리 완료');
      
    } catch (e) {
      debugPrint('만료된 초대 정리 실패: $e');
      // 백그라운드 작업이므로 UI에는 오류 표시하지 않음
    }
  }
  
  // 유틸리티 메서드들
  void _updateInvitationInList(List<Invitation> list, Invitation updatedInvitation) {
    final index = list.indexWhere((inv) => inv.id == updatedInvitation.id);
    if (index != -1) {
      if (updatedInvitation.status == InvitationStatus.pending) {
        list[index] = updatedInvitation;
      } else {
        list.removeAt(index); // pending이 아닌 초대는 제거
      }
    }
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
    debugPrint('InvitationProvider 오류: $message');
  }
  
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  // 오류 메시지 클리어 (UI에서 호출)
  void clearError() {
    _clearError();
  }
  
  // 수동 새로고침
  Future<void> refresh(String userId) async {
    await loadUserInvitations(userId);
  }
  
  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
    debugPrint('InvitationProvider disposed');
  }
}