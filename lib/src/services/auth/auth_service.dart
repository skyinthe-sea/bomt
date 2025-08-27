import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class AuthService {
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _kakaoTokenKey = 'kakao_access_token';
  
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  AuthService(this._prefs);
  
  // 자동로그인 설정 저장
  Future<void> setAutoLogin(bool enabled) async {
    await _prefs.setBool(_autoLoginKey, enabled);
  }
  
  // 자동로그인 설정 가져오기 (기본값 true)
  bool getAutoLogin() {
    return _prefs.getBool(_autoLoginKey) ?? true; // 🔧 기본값 true로 변경
  }
  
  // 카카오 토큰 유효성 검사
  Future<bool> hasValidToken() async {
    print('DEBUG: AuthService.hasValidToken() 시작');
    try {
      final tokenInfo = await kakao.UserApi.instance.accessTokenInfo();
      print('DEBUG: tokenInfo = $tokenInfo');
      // 토큰이 유효하면 true
      final isValid = tokenInfo != null;
      print('DEBUG: 토큰 유효성: $isValid');
      return isValid;
    } catch (e) {
      print('DEBUG: hasValidToken 예외 발생: $e');
      return false;
    }
  }
  
  // 현재 로그인된 사용자 정보 가져오기
  Future<kakao.User?> getCurrentUser() async {
    print('DEBUG: AuthService.getCurrentUser() 시작');
    try {
      print('DEBUG: 토큰 유효성 확인 중...');
      final hasToken = await hasValidToken();
      print('DEBUG: hasValidToken 결과: $hasToken');
      
      if (hasToken) {
        print('DEBUG: UserApi.instance.me() 호출 중...');
        final user = await kakao.UserApi.instance.me();
        print('DEBUG: 카카오 사용자 정보 획득: $user');
        print('DEBUG: 사용자 ID: ${user?.id}');
        return user;
      } else {
        print('DEBUG: 유효한 토큰이 없어서 null 반환');
        return null;
      }
    } catch (e) {
      print('DEBUG: getCurrentUser 예외 발생: $e');
      return null;
    }
  }

  // 실제 사용자 프로필 ID 가져오기 (UUID 형태)
  Future<String?> getCurrentUserProfileId() async {
    print('=' * 100);
    print('🔐 [AUTH_SERVICE] getCurrentUserProfileId() 시작');
    print('=' * 100);
    
    // ⚡ COMPARISON: CommunityProvider와 동일한 방식으로 확인
    print('🔍 [AUTH_SERVICE] COMPARISON: CommunityProvider 방식으로도 확인해보기...');
    final testSupabaseUser = _supabase.auth.currentUser;
    print('    - _supabase.auth.currentUser: $testSupabaseUser');
    print('    - _supabase.auth.currentUser == null: ${testSupabaseUser == null}');
    print('    - SupabaseConfig.client == _supabase: ${SupabaseConfig.client == _supabase}');
    print('=' * 50);
    
    try {
      // 🔐 1순위: Supabase 사용자 확인 (이메일 계정)
      print('📋 [AUTH_SERVICE] STEP 1: Supabase 인증 확인 중...');
      print('    - SupabaseConfig.client: ${SupabaseConfig.client}');
      print('    - SupabaseConfig.client.auth: ${SupabaseConfig.client.auth}');
      
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      print('    - supabaseUser: $supabaseUser');
      print('    - supabaseUser == null: ${supabaseUser == null}');
      print('    - supabaseUser.runtimeType: ${supabaseUser?.runtimeType}');
      
      if (supabaseUser != null) {
        final userId = supabaseUser.id;
        print('✅ [AUTH_SERVICE] Supabase 사용자 발견!');
        print('    - User ID: $userId');
        print('    - User ID type: ${userId.runtimeType}');
        print('    - User ID length: ${userId.length}');
        print('    - Email: ${supabaseUser.email}');
        print('    - Email Confirmed: ${supabaseUser.emailConfirmedAt}');
        print('    - Last Sign In: ${supabaseUser.lastSignInAt}');
        print('    - Created At: ${supabaseUser.createdAt}');
        print('    - Auth 상태: ${SupabaseConfig.client.auth.currentSession}');
        print('=' * 100);
        return userId;
      } else {
        print('❌ [AUTH_SERVICE] Supabase 사용자 없음, 추가 정보:');
        print('    - Auth session: ${SupabaseConfig.client.auth.currentSession}');
        print('    - Auth session == null: ${SupabaseConfig.client.auth.currentSession == null}');
        if (SupabaseConfig.client.auth.currentSession != null) {
          print('    - Session user: ${SupabaseConfig.client.auth.currentSession!.user}');
          print('    - Session access token: ${SupabaseConfig.client.auth.currentSession!.accessToken != null ? "존재함" : "없음"}');
        }
        print('    - 카카오 확인으로 넘어감...');
      }
      
      // 🥇 2순위: 카카오 로그인 사용자 확인
      print('📋 [AUTH_SERVICE] STEP 2: 카카오 사용자 정보 가져오기 중...');
      final kakaoUser = await getCurrentUser();
      print('    - kakaoUser: $kakaoUser');
      print('    - kakaoUser == null: ${kakaoUser == null}');
      
      if (kakaoUser == null) {
        print('❌ [AUTH_SERVICE] 카카오 사용자 정보도 없음');
        print('=' * 100);
        return null;
      }

      final kakaoId = kakaoUser.id.toString();
      final kakaoEmail = kakaoUser.kakaoAccount?.email;
      print('✅ [AUTH_SERVICE] 카카오 사용자 정보 획득');
      print('    - 카카오 ID: $kakaoId');
      print('    - 카카오 이메일: $kakaoEmail');

      // 3. user_profiles 테이블에서 실제 user_id 찾기
      print('📋 [AUTH_SERVICE] STEP 3: user_profiles 테이블에서 실제 user_id 찾기');
      
      // 2-1. linked_to 필드로 매칭 시도
      print('    [2-1] linked_to 방식으로 검색 중...');
      try {
        final response = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, email')
            .eq('linked_to', kakaoId)
            .maybeSingle();
        
        print('        - 쿼리 결과: $response');
        if (response != null) {
          final userId = response['user_id'] as String;
          final nickname = response['nickname'];
          final email = response['email'];
          print('✅ [AUTH_SERVICE] linked_to 방식으로 사용자 찾음!');
          print('        - user_id: $userId');
          print('        - nickname: $nickname');
          print('        - email: $email');
          print('=' * 100);
          return userId;
        } else {
          print('        - linked_to 방식: 매칭되는 사용자 없음');
        }
      } catch (e) {
        print('❌ [AUTH_SERVICE] linked_to 방식으로 검색 실패: $e');
      }

      // 2-2. 카카오 이메일로 매칭 시도
      if (kakaoEmail != null) {
        print('    [2-2] 이메일 방식으로 검색 중: $kakaoEmail');
        try {
          final response = await _supabase
              .from('user_profiles')
              .select('user_id, nickname, linked_to')
              .eq('email', kakaoEmail)
              .maybeSingle();
          
          print('        - 쿼리 결과: $response');
          if (response != null) {
            final userId = response['user_id'] as String;
            final nickname = response['nickname'];
            final linkedTo = response['linked_to'];
            print('✅ [AUTH_SERVICE] 이메일 방식으로 사용자 찾음!');
            print('        - user_id: $userId');
            print('        - nickname: $nickname');
            print('        - linked_to: $linkedTo');
            print('=' * 100);
            return userId;
          } else {
            print('        - 이메일 방식: 매칭되는 사용자 없음');
          }
        } catch (e) {
          print('❌ [AUTH_SERVICE] 이메일 방식으로 검색 실패: $e');
        }
      } else {
        print('    [2-2] 카카오 이메일이 없어서 건너뜀');
      }

      // 2-3. 카카오 ID로 직접 매칭 시도 (폴백)
      print('    [2-3] 카카오 ID 직접 매칭 시도: $kakaoId');
      try {
        final response = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, email')
            .eq('user_id', kakaoId)
            .maybeSingle();
        
        print('        - 쿼리 결과: $response');
        if (response != null) {
          final userId = response['user_id'] as String;
          final nickname = response['nickname'];
          final email = response['email'];
          print('✅ [AUTH_SERVICE] 카카오 ID 직접 매칭으로 사용자 찾음!');
          print('        - user_id: $userId');
          print('        - nickname: $nickname');
          print('        - email: $email');
          print('=' * 100);
          return userId;
        } else {
          print('        - 카카오 ID 직접 매칭: 매칭되는 사용자 없음');
        }
      } catch (e) {
        print('❌ [AUTH_SERVICE] 카카오 ID 직접 매칭 실패: $e');
      }

      // 🔍 최후 확인: 직접 DB 조회로 사용자 존재 여부 확인
      print('📋 [AUTH_SERVICE] STEP 4: 최후 확인 - 직접 DB에서 사용자 찾기...');
      try {
        print('    [DIRECT_DB] skyinthe_sea로 검색 중...');
        final directResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, email, linked_to')
            .or('nickname.eq.skyinthe_sea,email.ilike.%skyinthe_sea%')
            .limit(5);
        
        print('    [DIRECT_DB] 결과: $directResponse');
        if (directResponse.isNotEmpty) {
          print('✅ [AUTH_SERVICE] DB에서 skyinthe_sea 사용자들 발견!');
          for (var user in directResponse) {
            print('        - user_id: ${user['user_id']}');
            print('        - nickname: ${user['nickname']}');
            print('        - email: ${user['email']}');
            print('        - linked_to: ${user['linked_to']}');
          }
        }
      } catch (e) {
        print('❌ [AUTH_SERVICE] 직접 DB 조회 실패: $e');
      }

      print('❌ [AUTH_SERVICE] 어떤 방식으로도 user_id를 찾을 수 없음');
      print('    - 시도한 방법들:');
      print('      1. Supabase currentUser 확인');
      print('      2. linked_to = $kakaoId');
      print('      3. email = $kakaoEmail');  
      print('      4. user_id = $kakaoId');
      print('      5. 직접 DB에서 skyinthe_sea 검색');
      print('=' * 100);
      return null;

    } catch (e, stackTrace) {
      print('❌ [AUTH_SERVICE] getCurrentUserProfileId 예외 발생');
      print('    - 에러: $e');
      print('    - 에러 타입: ${e.runtimeType}');
      print('    - 스택 트레이스: $stackTrace');
      print('=' * 100);
      return null;
    }
  }
  
  // 로그아웃 시 자동로그인 설정도 함께 제거
  Future<void> clearAutoLogin() async {
    await _prefs.remove(_autoLoginKey);
  }
}