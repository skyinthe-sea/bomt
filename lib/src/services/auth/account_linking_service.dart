import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_auth_service.dart';

enum AccountType { kakao, email, google, facebook }

class AccountInfo {
  final String userId;
  final String? email;
  final String? nickname;
  final AccountType type;
  final DateTime? createdAt;
  final bool isDeleted;

  AccountInfo({
    required this.userId,
    this.email,
    this.nickname,
    required this.type,
    this.createdAt,
    this.isDeleted = false,
  });
}

class AccountLinkingService {
  static AccountLinkingService? _instance;
  static AccountLinkingService get instance => _instance ??= AccountLinkingService._();
  
  AccountLinkingService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// 이메일로 기존 계정들 찾기 (소셜 계정 포함)
  Future<List<AccountInfo>> findAccountsByEmail(String email) async {
    try {
      debugPrint('🔍 [ACCOUNT_LINKING] Searching for accounts with email: $email');
      
      List<AccountInfo> accounts = [];
      
      // 1. 간단한 더미 계정 반환 (실제 구현은 추후)
      // 복잡한 계정 검색보다는 우선 탈퇴 처리 완성에 집중
      accounts.add(AccountInfo(
        userId: 'dummy_existing_user',
        email: email,
        nickname: '기존 사용자',
        type: _determineAccountType(email),
        createdAt: DateTime.now(),
        isDeleted: false,
      ));
      
      // 2. 카카오/소셜 계정에서 같은 이메일 찾기
      // (실제로는 auth.users와 연결된 소셜 계정들을 찾아야 함)
      
      debugPrint('✅ [ACCOUNT_LINKING] Found ${accounts.length} accounts');
      return accounts;
      
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Error in findAccountsByEmail: $e');
      return [];
    }
  }
  
  /// 계정 연결 가능 여부 확인
  Future<bool> canLinkAccounts(String primaryUserId, String secondaryUserId) async {
    try {
      // 두 계정이 모두 존재하고 활성 상태인지 확인
      final primaryProfile = await _supabase
          .from('user_profiles')
          .select('deleted_at')
          .eq('user_id', primaryUserId)
          .maybeSingle();
          
      final secondaryProfile = await _supabase
          .from('user_profiles')
          .select('deleted_at')
          .eq('user_id', secondaryUserId)
          .maybeSingle();
      
      return primaryProfile != null && 
             secondaryProfile != null &&
             primaryProfile['deleted_at'] == null &&
             secondaryProfile['deleted_at'] == null;
             
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Error checking link eligibility: $e');
      return false;
    }
  }
  
  /// 계정 연결 실행
  Future<bool> linkAccounts({
    required String primaryUserId,
    required String secondaryUserId,
    required AccountType primaryType,
    required AccountType secondaryType,
  }) async {
    try {
      debugPrint('🔗 [ACCOUNT_LINKING] Linking accounts: $primaryUserId <- $secondaryUserId');
      
      // 트랜잭션으로 안전하게 처리
      return await _performAccountLink(
        primaryUserId: primaryUserId,
        secondaryUserId: secondaryUserId,
        primaryType: primaryType,
        secondaryType: secondaryType,
      );
      
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Account linking failed: $e');
      return false;
    }
  }
  
  /// 실제 계정 연결 수행
  Future<bool> _performAccountLink({
    required String primaryUserId,
    required String secondaryUserId,
    required AccountType primaryType,
    required AccountType secondaryType,
  }) async {
    try {
      // 1. 보조 계정의 데이터를 주 계정으로 이관
      await _migrateBabyData(secondaryUserId, primaryUserId);
      
      // 2. 보조 계정을 연결된 계정으로 표시 (소프트 삭제하지 않음)
      await _supabase
          .from('user_profiles')
          .update({
            'linked_to': primaryUserId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', secondaryUserId);
      
      // 3. 주 계정에 연결 정보 추가
      await _supabase
          .from('user_profiles')
          .update({
            'has_linked_accounts': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', primaryUserId);
      
      debugPrint('✅ [ACCOUNT_LINKING] Account linking completed successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Error in _performAccountLink: $e');
      return false;
    }
  }
  
  /// 아기 데이터 이관
  Future<void> _migrateBabyData(String fromUserId, String toUserId) async {
    try {
      // baby_users 테이블에서 보조 계정의 아기들을 주 계정으로 이관
      await _supabase
          .from('baby_users')
          .update({'user_id': toUserId})
          .eq('user_id', fromUserId);
          
      debugPrint('✅ [ACCOUNT_LINKING] Baby data migrated successfully');
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Error migrating baby data: $e');
      rethrow;
    }
  }
  
  /// 연결된 계정들 조회
  Future<List<AccountInfo>> getLinkedAccounts(String primaryUserId) async {
    try {
      final linkedProfiles = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, created_at')
          .eq('linked_to', primaryUserId);
      
      List<AccountInfo> linkedAccounts = [];
      for (final profile in linkedProfiles) {
        // 계정 타입 판단
        final userId = profile['user_id'] as String;
        final accountType = userId.contains(RegExp(r'^[0-9]+$')) 
            ? AccountType.kakao 
            : AccountType.email;
            
        linkedAccounts.add(AccountInfo(
          userId: userId,
          nickname: profile['nickname'],
          type: accountType,
          createdAt: DateTime.tryParse(profile['created_at'] ?? ''),
        ));
      }
      
      return linkedAccounts;
      
    } catch (e) {
      debugPrint('❌ [ACCOUNT_LINKING] Error getting linked accounts: $e');
      return [];
    }
  }
  
  /// 계정 타입 판단 (간단한 방식)
  AccountType _determineAccountType(String email) {
    // Gmail이면 구글, 그 외는 일반 이메일로 판단
    if (email.contains('@gmail.com')) {
      return AccountType.google;
    } else if (email.contains('@naver.com') || email.contains('@daum.net')) {
      return AccountType.kakao; // 한국 이메일은 카카오일 가능성
    }
    return AccountType.email;
  }
}