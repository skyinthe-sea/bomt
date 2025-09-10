import 'package:flutter/material.dart';
import '../../domain/models/user_block.dart';
import '../../domain/models/content_report.dart';
import '../../domain/models/user_agreement_consent.dart';
import '../../services/safety/user_block_service.dart';
import '../../services/safety/content_report_service.dart';
import '../../services/safety/user_agreement_service.dart';
import '../../services/auth/supabase_auth_service.dart';

/// 안전 기능 통합 Provider
/// App Store Guideline 1.2 준수를 위한 통합 관리
class SafetyProvider with ChangeNotifier {
  final UserBlockService _blockService = UserBlockService();
  final ContentReportService _reportService = ContentReportService();
  final UserAgreementService _agreementService = UserAgreementService();
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  // 상태 관리
  List<UserBlock> _blockedUsers = [];
  Set<String> _blockedUserIds = {};
  UserConsentStatus? _consentStatus;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserBlock> get blockedUsers => _blockedUsers;
  Set<String> get blockedUserIds => _blockedUserIds;
  UserConsentStatus? get consentStatus => _consentStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 현재 사용자 ID 가져오기
  String? get _currentUserId => _authService.currentUser?.id;

  /// 초기화
  Future<void> initialize() async {
    if (_currentUserId == null) return;
    
    try {
      _setLoading(true);
      await Future.wait([
        _loadBlockedUsers(),
        _loadConsentStatus(),
      ]);
    } catch (e) {
      _setError('초기화 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 차단된 사용자 목록 로드
  Future<void> _loadBlockedUsers() async {
    if (_currentUserId == null) return;
    
    try {
      final blockedUsers = await _blockService.getBlockedUsers(_currentUserId!);
      _blockedUsers = blockedUsers;
      _blockedUserIds = blockedUsers.map((block) => block.blockedUserId).toSet();
      _clearError();
    } catch (e) {
      print('차단 목록 로드 실패: $e');
    }
  }

  /// EULA 동의 상태 로드
  Future<void> _loadConsentStatus() async {
    if (_currentUserId == null) return;
    
    try {
      final consentStatus = await _agreementService.getUserConsentStatus(_currentUserId!);
      _consentStatus = consentStatus;
      _clearError();
    } catch (e) {
      print('동의 상태 로드 실패: $e');
    }
  }

  /// 사용자 차단
  Future<bool> blockUser({
    required String targetUserId,
    String? reason,
  }) async {
    if (_currentUserId == null) return false;
    
    try {
      _setLoading(true);
      
      await _blockService.blockUser(
        blockerUserId: _currentUserId!,
        blockedUserId: targetUserId,
        reason: reason,
      );
      
      // 로컬 상태 업데이트
      _blockedUserIds.add(targetUserId);
      await _loadBlockedUsers(); // 전체 목록 새로고침
      
      _clearError();
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('사용자 차단 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 차단 해제
  Future<bool> unblockUser(String targetUserId) async {
    if (_currentUserId == null) return false;
    
    try {
      _setLoading(true);
      
      await _blockService.unblockUser(
        blockerUserId: _currentUserId!,
        blockedUserId: targetUserId,
      );
      
      // 로컬 상태 업데이트
      _blockedUserIds.remove(targetUserId);
      _blockedUsers.removeWhere((block) => block.blockedUserId == targetUserId);
      
      _clearError();
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('차단 해제 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 콘텐츠 신고
  Future<bool> reportContent({
    required String reportedUserId,
    required ContentType contentType,
    required String contentId,
    required ReportReason reportReason,
    String? reportDescription,
  }) async {
    if (_currentUserId == null) return false;
    
    try {
      _setLoading(true);
      
      await _reportService.reportContent(
        reporterUserId: _currentUserId!,
        reportedUserId: reportedUserId,
        contentType: contentType,
        contentId: contentId,
        reportReason: reportReason,
        reportDescription: reportDescription,
      );
      
      _clearError();
      return true;
      
    } catch (e) {
      _setError('신고 처리 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 사용자가 차단되었는지 확인
  bool isUserBlocked(String userId) {
    return _blockedUserIds.contains(userId);
  }

  /// 콘텐츠 필터링 (차단된 사용자의 콘텐츠 제거)
  List<T> filterBlockedContent<T>(List<T> content, String Function(T) getUserId) {
    return content.where((item) => !isUserBlocked(getUserId(item))).toList();
  }

  /// EULA 동의 필요 여부 확인
  bool get needsEulaConsent {
    return _consentStatus?.hasAllRequiredConsents != true;
  }

  /// EULA 동의 처리
  Future<bool> agreeToTerms(List<String> agreementVersionIds) async {
    if (_currentUserId == null) return false;
    
    try {
      _setLoading(true);
      
      await _agreementService.createMultipleConsents(
        userId: _currentUserId!,
        agreementVersionIds: agreementVersionIds,
      );
      
      // 동의 상태 새로고침
      await _loadConsentStatus();
      
      _clearError();
      return true;
      
    } catch (e) {
      _setError('약관 동의 처리 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 캐시 초기화 및 새로고침
  Future<void> refresh() async {
    _blockService.clearCache();
    _agreementService.clearCache();
    await initialize();
  }

  /// 상태 관리 헬퍼 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// SafetyProvider를 위한 확장 메서드
extension SafetyProviderExtensions on BuildContext {
  SafetyProvider get safety => SafetyProvider(); // Provider.of<SafetyProvider>(this, listen: false);
  SafetyProvider get watchSafety => SafetyProvider(); // Provider.of<SafetyProvider>(this);
}