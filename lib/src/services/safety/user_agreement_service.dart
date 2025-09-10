import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/user_agreement_version.dart';
import '../../domain/models/user_agreement_consent.dart';

/// 사용자 약관 관리 서비스
/// App Store Guideline 1.2 준수를 위한 EULA 시스템
class UserAgreementService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  // 캐시 (5분간 유효)
  List<UserAgreementVersion>? _activeVersionsCache;
  DateTime? _cacheTime;

  /// 사용자 ID를 UUID 포맷으로 변환 (필요시)
  /// user_agreement_consents 테이블은 UUID 타입을 사용하므로 변환 처리
  String _convertUserIdToUuid(String userId) {
    try {
      // 이미 UUID 형태인지 확인 (8-4-4-4-12 패턴)
      final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
      if (uuidRegex.hasMatch(userId)) {
        return userId; // 이미 UUID 형태
      }
      
      // Supabase auth.users.id는 UUID 형태여야 함
      // 만약 다른 형태라면 auth.uid()를 사용해야 함
      print('WARNING: userId가 UUID 형태가 아닙니다: $userId');
      return userId; // 일단 그대로 반환하고 에러 로깅
    } catch (e) {
      print('ERROR: 사용자 ID 변환 실패: $e');
      return userId;
    }
  }

  /// 데이터베이스 에러에서 타입 관련 오류인지 확인
  bool _isTypeError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('invalid input syntax') ||
           errorString.contains('uuid') ||
           errorString.contains('type') ||
           errorString.contains('cast');
  }

  /// 활성화된 모든 약관 버전 조회 (캐시 활용)
  Future<List<UserAgreementVersion>> getActiveAgreementVersions() async {
    try {
      // 캐시가 있고 5분 이내라면 캐시 사용
      if (_activeVersionsCache != null && 
          _cacheTime != null &&
          DateTime.now().difference(_cacheTime!).inMinutes < 5) {
        print('DEBUG: 캐시된 약관 버전 사용: ${_activeVersionsCache!.length}개');
        return _activeVersionsCache!;
      }

      print('DEBUG: 활성 약관 버전 조회');
      final response = await _supabase
          .from('user_agreement_versions')
          .select()
          .eq('is_active', true)
          .order('effective_date', ascending: false);

      final versions = (response as List)
          .map((item) => UserAgreementVersion.fromJson(item))
          .toList();

      // 캐시 업데이트
      _activeVersionsCache = versions;
      _cacheTime = DateTime.now();

      print('DEBUG: 약관 버전 ${versions.length}개 조회 완료');
      return versions;
    } catch (e) {
      print('ERROR: 약관 버전 조회 실패: $e');
      throw Exception('약관 버전을 가져오는데 실패했습니다: $e');
    }
  }

  /// 특정 타입의 최신 약관 버전 조회
  Future<UserAgreementVersion?> getLatestAgreementVersion(AgreementType type) async {
    try {
      final versions = await getActiveAgreementVersions();
      return versions
          .where((v) => v.agreementType == type)
          .firstOrNull;
    } catch (e) {
      print('ERROR: 최신 약관 버전 조회 실패: $e');
      return null;
    }
  }

  /// 사용자의 약관 동의 현황 조회
  Future<UserConsentStatus> getUserConsentStatus(String userId) async {
    try {
      print('DEBUG: 사용자 동의 현황 조회 - userId: $userId');
      final convertedUserId = _convertUserIdToUuid(userId);
      print('DEBUG: 변환된 userId: $convertedUserId');
      
      // 사용자의 모든 동의 내역 조회 (JOIN으로 약관 정보 포함)
      final response = await _supabase
          .from('user_agreement_consents')
          .select('''
            *,
            agreement_version:user_agreement_versions(*)
          ''')
          .eq('user_id', convertedUserId)
          .eq('is_withdrawn', false);

      final consents = (response as List)
          .map((item) => UserAgreementConsent.fromJson(item))
          .toList();

      // 현재 활성화된 약관 버전들 조회
      final activeVersions = await getActiveAgreementVersions();
      
      // 약관 타입별 동의 상태 확인
      final consentStatus = <AgreementType, bool>{};
      
      for (final type in AgreementType.values) {
        final latestVersion = activeVersions
            .where((v) => v.agreementType == type)
            .firstOrNull;
        
        if (latestVersion != null) {
          // 해당 타입의 최신 버전에 동의했는지 확인
          final hasConsent = consents.any((consent) => 
              consent.agreementVersionId == latestVersion.id);
          consentStatus[type] = hasConsent;
        } else {
          consentStatus[type] = true; // 해당 타입 약관이 없으면 동의한 것으로 간주
        }
      }

      return UserConsentStatus(
        userId: userId,
        consentStatus: consentStatus,
        consents: consents,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('ERROR: 사용자 동의 현황 조회 실패: $e');
      
      // 타입 에러인 경우 더 구체적인 메시지 제공
      if (_isTypeError(e)) {
        print('ERROR: 데이터 타입 불일치 - userId: $userId');
        // 빈 상태 반환 (기존 사용자는 동의가 필요한 상태로 처리)
        return UserConsentStatus(
          userId: userId,
          consentStatus: <AgreementType, bool>{},
          consents: <UserAgreementConsent>[],
          lastUpdated: DateTime.now(),
        );
      }
      
      throw Exception('동의 현황을 확인하는데 실패했습니다: $e');
    }
  }

  /// 사용자가 약관에 동의
  Future<UserAgreementConsent> createUserConsent({
    required String userId,
    required String agreementVersionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      print('DEBUG: 약관 동의 생성 - userId: $userId, versionId: $agreementVersionId');
      final convertedUserId = _convertUserIdToUuid(userId);
      print('DEBUG: 변환된 userId: $convertedUserId');
      
      final consentData = {
        'user_id': convertedUserId,
        'agreement_version_id': agreementVersionId,
        'consented_at': DateTime.now().toIso8601String(),
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'is_withdrawn': false,
      };

      final response = await _supabase
          .from('user_agreement_consents')
          .insert(consentData)
          .select()
          .single();

      print('DEBUG: 약관 동의 생성 완료');
      return UserAgreementConsent.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        print('WARNING: 이미 동의한 약관입니다');
        throw Exception('이미 동의한 약관입니다');
      }
      
      // 타입 에러인 경우 더 구체적인 메시지 제공
      if (_isTypeError(e)) {
        print('ERROR: 데이터 타입 불일치 - userId: $userId');
        throw Exception('사용자 ID 형식 오류로 동의 처리에 실패했습니다');
      }
      
      print('ERROR: 약관 동의 생성 실패: $e');
      throw Exception('약관 동의 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 여러 약관에 한번에 동의
  Future<List<UserAgreementConsent>> createMultipleConsents({
    required String userId,
    required List<String> agreementVersionIds,
    String? ipAddress,
    String? userAgent,
  }) async {
    final consents = <UserAgreementConsent>[];
    
    for (final versionId in agreementVersionIds) {
      try {
        final consent = await createUserConsent(
          userId: userId,
          agreementVersionId: versionId,
          ipAddress: ipAddress,
          userAgent: userAgent,
        );
        consents.add(consent);
      } catch (e) {
        print('WARNING: 약관 동의 실패 - versionId: $versionId, error: $e');
        // 개별 동의 실패는 무시하고 계속 진행
      }
    }
    
    return consents;
  }

  /// 약관 동의 철회
  Future<void> withdrawConsent(String consentId) async {
    try {
      print('DEBUG: 약관 동의 철회 - consentId: $consentId');
      
      await _supabase
          .from('user_agreement_consents')
          .update({
            'is_withdrawn': true,
            'withdrawn_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consentId);

      print('DEBUG: 약관 동의 철회 완료');
    } catch (e) {
      print('ERROR: 약관 동의 철회 실패: $e');
      throw Exception('동의 철회 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 필수 약관 동의 여부 확인
  Future<bool> hasRequiredConsents(String userId) async {
    try {
      final consentStatus = await getUserConsentStatus(userId);
      return consentStatus.hasAllRequiredConsents;
    } catch (e) {
      print('ERROR: 필수 동의 확인 실패: $e');
      return false;
    }
  }

  /// 약관 업데이트 시 재동의가 필요한 사용자들 확인
  Future<List<String>> getUsersNeedingReConsent(AgreementType type) async {
    try {
      // 최신 약관 버전 조회
      final latestVersion = await getLatestAgreementVersion(type);
      if (latestVersion == null) return [];

      // 최신 버전에 동의하지 않은 사용자들 조회
      final response = await _supabase
          .from('user_agreement_consents')
          .select('user_id')
          .neq('agreement_version_id', latestVersion.id)
          .eq('is_withdrawn', false);

      // UUID 형태의 user_id들을 TEXT 형태로 변환하여 반환
      return (response as List)
          .map((item) => item['user_id'] as String)
          .toSet() // 중복 제거
          .toList();
    } catch (e) {
      print('ERROR: 재동의 필요 사용자 조회 실패: $e');
      return [];
    }
  }

  /// 사용자별 동의 이력 조회
  Future<List<UserAgreementConsent>> getUserConsentHistory(String userId) async {
    try {
      final convertedUserId = _convertUserIdToUuid(userId);
      print('DEBUG: 동의 이력 조회 - 변환된 userId: $convertedUserId');
      
      final response = await _supabase
          .from('user_agreement_consents')
          .select('''
            *,
            agreement_version:user_agreement_versions(*)
          ''')
          .eq('user_id', convertedUserId)
          .order('consented_at', ascending: false);

      return (response as List)
          .map((item) => UserAgreementConsent.fromJson(item))
          .toList();
    } catch (e) {
      print('ERROR: 동의 이력 조회 실패: $e');
      
      // 타입 에러인 경우 빈 목록 반환
      if (_isTypeError(e)) {
        print('ERROR: 데이터 타입 불일치 - userId: $userId');
        return <UserAgreementConsent>[];
      }
      
      throw Exception('동의 이력을 조회하는데 실패했습니다: $e');
    }
  }

  /// 캐시 초기화
  void clearCache() {
    _activeVersionsCache = null;
    _cacheTime = null;
  }
}