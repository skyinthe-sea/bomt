import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum AuthProvider { email, google, facebook, kakao }

/// 이메일 체크 시 권장 액션
enum EmailAction {
  signUp,            // 회원가입 진행
  signIn,            // 로그인 모드로 전환
  reactivate,        // 탈퇴 계정 재활성화
  resendConfirmation // 이메일 인증 재전송
}

/// 이메일 존재 여부 체크 결과
class EmailCheckResult {
  final bool exists;              // 이메일이 존재하는지
  final bool isDeleted;           // 탈퇴한 계정인지
  final bool canReactivate;       // 재활성화 가능한지
  final String message;           // 사용자에게 보여줄 메시지
  final EmailAction recommendedAction; // 권장 액션
  
  const EmailCheckResult({
    required this.exists,
    required this.isDeleted,
    required this.canReactivate,
    required this.message,
    required this.recommendedAction,
  });
}

class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  static SupabaseAuthService get instance => _instance ??= SupabaseAuthService._();
  
  SupabaseAuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // iOS 클라이언트 ID 사용 (네이티브 앱에 필수)
    clientId: '373535971104-ktelo9crh5vg7kjpfhaq586oufbcab1e.apps.googleusercontent.com',
  );
  
  // SharedPreferences keys
  static const String _autoLoginKey = 'auto_login_enabled';
  
  SharedPreferences? _prefs;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('🔧 [SUPABASE_AUTH] Initialized');
  }

  /// Supabase 클라이언트 접근
  SupabaseClient get supabaseClient => _supabase;

  /// 현재 사용자
  User? get currentUser => _supabase.auth.currentUser;

  /// 로그인 상태 확인
  bool get isLoggedIn => currentUser != null;

  /// 자동 로그인 설정 가져오기 (기본값 true)
  bool getAutoLogin() {
    return _prefs?.getBool(_autoLoginKey) ?? true; // 🔧 기본값 true로 변경
  }

  /// 자동 로그인 설정
  Future<void> setAutoLogin(bool enabled) async {
    await _prefs?.setBool(_autoLoginKey, enabled);
    print('⚙️ [SUPABASE_AUTH] Auto login set to: $enabled');
  }

  /// 이메일 로그인
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      print('📧 [SUPABASE_AUTH] Email sign in attempt for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // 이메일 인증 상태 확인
        if (response.user!.emailConfirmedAt == null) {
          print('⚠️ [SUPABASE_AUTH] Email not confirmed for user: ${response.user!.email}');
          await _supabase.auth.signOut(); // 세션 제거
          
          // 이메일 재발송 시도
          try {
            print('📧 [SUPABASE_AUTH] Resending confirmation email...');
            await _supabase.auth.resend(
              type: OtpType.signup,
              email: email,
              emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
            );
            print('✅ [SUPABASE_AUTH] Confirmation email resent successfully');
            throw AuthException('이메일 인증이 필요합니다.\n새로운 인증 메일을 발송했습니다. 이메일을 확인해주세요.');
          } catch (resendError) {
            print('⚠️ [SUPABASE_AUTH] Failed to resend confirmation email: $resendError');
            throw AuthException('이메일 인증이 필요합니다.\n이메일을 확인해주세요.');
          }
        }
        
        // 탈퇴한 사용자 체크
        await _checkDeletedUser(response.user!.id);
        
        print('✅ [SUPABASE_AUTH] Email sign in successful');
        
        // 프로필 정보 확인 및 생성
        await _ensureUserProfile(response.user!);
      }
      
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Email sign in failed: $e');
      rethrow;
    }
  }

  /// OTP 기반 이메일 회원가입 (1단계: OTP 전송)
  Future<AuthResponse> signUpWithEmailOTP(String email, String password) async {
    try {
      print('📧 [SUPABASE_AUTH] ======= OTP SIGNUP START =======');
      print('📧 [SUPABASE_AUTH] Email: $email');
      
      // 🔍 탈퇴한 사용자인지 이메일로 확인
      print('🔍 [SUPABASE_AUTH] Step 1: Checking for deleted users in user_profiles...');
      final reactivationResponse = await _checkDeletedUserByEmail(email);
      if (reactivationResponse != null) {
        return reactivationResponse;
      }
      
      print('✅ [SUPABASE_AUTH] Step 1 Result: No deleted user found in user_profiles');
      
      // 🚀 OTP 방식으로 회원가입 + 인증코드 전송
      print('🚀 [SUPABASE_AUTH] Step 2: Sending OTP for signup...');
      
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // 새 사용자 생성 허용
        data: {
          'nickname': email.split('@')[0],
          'temp_password': password, // 임시로 저장 (나중에 설정)
        },
        emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
      );
      
      print('✅ [SUPABASE_AUTH] OTP 전송 완료');
      print('📧 [SUPABASE_AUTH] 회원가입용 인증 코드가 이메일로 전송되었습니다');
      
      return AuthResponse(
        user: User(
          id: 'temp_user_id', // 임시 ID (OTP 검증 후 실제 ID 획득)
          appMetadata: {
            'signup_otp_sent': true,
            'signup_step': 'otp_verification',
          },
          userMetadata: {
            'email_sent': true,
            'signup_method': 'otp',
            'message': '인증 코드가 이메일로 전송되었습니다!\n6자리 코드를 입력해주세요.',
            'temp_password': password, // 임시 저장
          },
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        ),
        session: null, // OTP 검증 전이므로 세션 없음
      );
    } catch (e) {
      print('💥 [SUPABASE_AUTH] ======= OTP SIGNUP ERROR =======');
      print('💥 [SUPABASE_AUTH] Error: $e');
      print('💥 [SUPABASE_AUTH] Error type: ${e.runtimeType}');
      
      final errorString = e.toString();
      
      // 🔍 이미 가입된 사용자인 경우
      if (errorString.contains('User already registered') ||
          errorString.contains('email_address_not_authorized')) {
        print('👤 [SUPABASE_AUTH] User already exists - try login instead');
        throw AuthException('이미 가입된 이메일입니다.\n\n로그인을 시도하거나 비밀번호를 잊으셨다면 비밀번호 재설정을 이용해주세요.');
      }
      
      print('💥 [SUPABASE_AUTH] ======= OTP SIGNUP ERROR END =======');
      rethrow;
    }
  }
  
  /// OTP 검증 및 회원가입 완료 (2단계: OTP 검증 후 비밀번호 설정)
  Future<AuthResponse> verifySignUpOTP(String email, String token, String password) async {
    try {
      print('🔐 [SUPABASE_AUTH] ======= OTP VERIFICATION START =======');
      print('📧 [SUPABASE_AUTH] Email: $email');
      print('🔑 [SUPABASE_AUTH] Token: ${token.substring(0, 3)}***');
      
      // OTP 검증
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      
      print('📧 [SUPABASE_AUTH] OTP verification response received');
      print('📧 [SUPABASE_AUTH] Response user: ${response.user?.id}');
      print('📧 [SUPABASE_AUTH] Response session: ${response.session != null}');
      
      if (response.user != null) {
        print('✅ [SUPABASE_AUTH] OTP 검증 성공!');
        
        // 비밀번호 설정
        try {
          await _supabase.auth.updateUser(
            UserAttributes(password: password),
          );
          print('✅ [SUPABASE_AUTH] 비밀번호 설정 완료');
        } catch (passwordError) {
          print('⚠️ [SUPABASE_AUTH] 비밀번호 설정 실패: $passwordError');
          // 비밀번호 설정 실패해도 가입은 성공한 것으로 처리
        }
        
        // 프로필 생성
        await _ensureUserProfile(response.user!);
        
        print('🎉 [SUPABASE_AUTH] 회원가입 완료!');
        
        return AuthResponse(
          user: User(
            id: response.user!.id,
            appMetadata: {
              ...response.user!.appMetadata ?? {},
              'signup_completed': true,
              'signup_method': 'otp',
              'email_verified': true,
            },
            userMetadata: {
              'message': '🎉 회원가입이 완료되었습니다!',
              'action': 'BabyMom을 이용해보세요.',
              'signup_method': 'otp',
            },
            aud: response.user!.aud,
            createdAt: response.user!.createdAt,
            email: response.user!.email,
            emailConfirmedAt: response.user!.emailConfirmedAt,
          ),
          session: response.session,
        );
      }
      
      print('❌ [SUPABASE_AUTH] OTP 검증 실패 - 사용자 없음');
      throw AuthException('인증 코드가 올바르지 않습니다. 다시 시도해주세요.');
      
    } catch (e) {
      print('💥 [SUPABASE_AUTH] ======= OTP VERIFICATION ERROR =======');
      print('💥 [SUPABASE_AUTH] Error: $e');
      
      if (e.toString().contains('invalid_otp') || 
          e.toString().contains('expired') ||
          e.toString().contains('otp_expired')) {
        throw AuthException('인증 코드가 올바르지 않거나 만료되었습니다.\n새로운 인증 코드를 요청해주세요.');
      }
      
      rethrow;
    }
  }

  /// 기존 호환성을 위한 래퍼 함수
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return signUpWithEmailOTP(email, password);
  }
  
  /// OTP 재전송 (회원가입용)
  Future<void> resendSignUpOTP(String email) async {
    try {
      print('📧 [SUPABASE_AUTH] ===== OTP RESEND START =====');
      print('📧 [SUPABASE_AUTH] Email: $email');
      
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // 이미 사용자 존재
        emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
      );
      
      print('✅ [SUPABASE_AUTH] OTP 재전송 완료');
      print('📧 [SUPABASE_AUTH] ===== OTP RESEND END =====');
    } catch (e) {
      print('❌ [SUPABASE_AUTH] OTP 재전송 실패: $e');
      rethrow;
    }
  }

  /// 사용자 존재 여부 확인
  Future<Map<String, dynamic>?> _checkUserExists(String email) async {
    try {
      print('🔍 [SUPABASE_AUTH] === USER EXISTS CHECK START ===');
      print('🔍 [SUPABASE_AUTH] Email: $email');
      print('🔍 [SUPABASE_AUTH] Current session: ${_supabase.auth.currentSession?.user?.email ?? 'null'}');
      
      // 먼저 로그인을 시도해서 사용자 존재 여부와 이메일 인증 상태를 정확히 확인
      try {
        print('🔑 [SUPABASE_AUTH] Step 1: Attempting login with dummy password to check user status...');
        await _supabase.auth.signInWithPassword(
          email: email,
          password: 'dummy_password_for_user_check_12345',
        );
        
        // 로그인 성공하면 안되지만, 혹시 모르니 처리
        print('😱 [SUPABASE_AUTH] Unexpected login success with dummy password!');
        await _supabase.auth.signOut();
        return {
          'status': 'confirmed_dummy_login',
          'email_confirmed_at': DateTime.now().toIso8601String(),
        };
      } catch (loginError) {
        print('🔑 [SUPABASE_AUTH] Login attempt result:');
        print('🔑 [SUPABASE_AUTH] Login error type: ${loginError.runtimeType}');
        print('🔑 [SUPABASE_AUTH] Login error message: $loginError');
        print('🔑 [SUPABASE_AUTH] Login error string: ${loginError.toString()}');
        
        if (loginError.toString().contains('Invalid login credentials')) {
          // 비밀번호 틀림 = 사용자 존재, 이메일 인증 완료
          print('✅ [SUPABASE_AUTH] User exists and email confirmed');
          return {
            'status': 'confirmed',
            'email_confirmed_at': DateTime.now().toIso8601String(),
          };
        } else if (loginError.toString().contains('Email not confirmed')) {
          // 이메일 미인증 = 사용자 존재하지만 인증 필요
          print('📧 [SUPABASE_AUTH] User exists but email not confirmed');
          
          // 이 경우 resend를 시도해서 실제 이메일 발송
          try {
            print('📧 [SUPABASE_AUTH] Step 2: Attempting resend for unconfirmed user...');
            const emailRedirectTo = 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth';
            print('📧 [SUPABASE_AUTH] EmailRedirectTo: $emailRedirectTo');
            
            final resendResult = await _supabase.auth.resend(
              type: OtpType.signup,
              email: email,
              emailRedirectTo: emailRedirectTo,
            );
            
            print('✅ [SUPABASE_AUTH] Resend SUCCESS for unconfirmed user!');
            print('✅ [SUPABASE_AUTH] Resend result: $resendResult');
            print('📧 [SUPABASE_AUTH] EMAIL SHOULD BE SENT');
            
            return {
              'status': 'unconfirmed',
              'email_confirmed_at': null,
              'resend_success': true,
            };
          } catch (resendError) {
            print('❌ [SUPABASE_AUTH] Resend FAILED for unconfirmed user!');
            print('❌ [SUPABASE_AUTH] Resend error: $resendError');
            
            return {
              'status': 'unconfirmed',
              'email_confirmed_at': null,
              'resend_success': false,
            };
          }
        } else {
          // 기타 에러 = 사용자 존재하지 않을 가능성
          print('❓ [SUPABASE_AUTH] User might not exist (other login error)');
          print('❓ [SUPABASE_AUTH] Login error details: ${loginError.toString()}');
          return null;
        }
      }
    } catch (e) {
      print('💥 [SUPABASE_AUTH] CRITICAL ERROR in _checkUserExists:');
      print('💥 [SUPABASE_AUTH] Error type: ${e.runtimeType}');
      print('💥 [SUPABASE_AUTH] Error message: $e');
      print('💥 [SUPABASE_AUTH] Error string: ${e.toString()}');
      return null;
    } finally {
      print('🔍 [SUPABASE_AUTH] === USER EXISTS CHECK END ===');
    }
  }

  /// 기존 사용자 직접 처리 (repeated signup 로그 방지)
  Future<AuthResponse> _handleExistingUserDirect(String email, String password, Map<String, dynamic> userInfo) async {
    try {
      print('🔧 [SUPABASE_AUTH] === HANDLE EXISTING USER START ===');
      print('🔧 [SUPABASE_AUTH] Email: $email');
      print('🔧 [SUPABASE_AUTH] UserInfo: $userInfo');
      
      final status = userInfo['status'];
      final resendSuccess = userInfo['resend_success'] ?? false;
      
      // 이메일 인증 미완료인 경우 (이미 resend 완료됨)
      if (status == 'unconfirmed') {
        print('📧 [SUPABASE_AUTH] Email not confirmed status detected');
        print('📧 [SUPABASE_AUTH] Resend was successful: $resendSuccess');
        if (resendSuccess) {
          print('✅ [SUPABASE_AUTH] Resend was successful - email should have been sent');
          return AuthResponse(
            user: User(
              id: 'unconfirmed_user',
              appMetadata: {'email_sent': true},
              userMetadata: {'message': '이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.'},
              aud: '',
              createdAt: DateTime.now().toIso8601String(),
              email: email,
            ),
          );
        } else {
          print('⚠️ [SUPABASE_AUTH] Resend was not successful - email might not have been sent');
          throw AuthException('이메일 인증이 완료되지 않았습니다. 이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.');
        }
      }
      
      // 이메일 인증 완료된 사용자 - 탈퇴 여부 확인 필요
      if (status == 'confirmed' || status == 'confirmed_dummy_login') {
        print('✅ [SUPABASE_AUTH] User has confirmed email, checking if deleted...');
        
        // 실제 비밀번호로 로그인 시도해서 탈퇴한 사용자인지 확인
        try {
          print('🔑 [SUPABASE_AUTH] Attempting login with real password...');
          final tempResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (tempResponse.user != null) {
            final userId = tempResponse.user!.id;
            print('🔑 [SUPABASE_AUTH] Login successful, checking profile...');
            print('🔑 [SUPABASE_AUTH] User ID: $userId');
            
            // 프로필에서 탈퇴 여부 확인
            final profile = await _supabase
                .from('user_profiles')
                .select('deleted_at, nickname')
                .eq('user_id', userId)
                .maybeSingle();
            
            print('🔍 [SUPABASE_AUTH] Profile check result: $profile');
            
            if (profile != null && profile['deleted_at'] != null) {
              print('🔄 [SUPABASE_AUTH] DELETED USER DETECTED - Reactivating...');
              print('🔄 [SUPABASE_AUTH] Current nickname: ${profile['nickname']}');
              print('🔄 [SUPABASE_AUTH] Deleted at: ${profile['deleted_at']}');
              
              // 탈퇴한 사용자 재활성화
              final updateResult = await _supabase.from('user_profiles').update({
                'deleted_at': null,
                'nickname': email.split('@')[0],
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('user_id', userId);
              
              print('🔄 [SUPABASE_AUTH] Profile update result: $updateResult');
              
              // 로그아웃 후 완료 메시지
              await _supabase.auth.signOut();
              
              print('✅ [SUPABASE_AUTH] User reactivated successfully');
              print('🎉 [SUPABASE_AUTH] Returning success - user should see success message');
              
              // 재활성화 성공 시 특별한 AuthResponse 반환
              return AuthResponse(
                user: User(
                  id: userId,
                  appMetadata: {
                    'reactivated': true,
                    'welcome_back': true,
                    'show_celebration': true,
                  },
                  userMetadata: {
                    'message': '🎉 환영합니다! 계정이 재활성화되었습니다.',
                    'action': '다시 로그인하여 BabyMom을 계속 이용해보세요.',
                    'celebration_emoji': '🎊',
                  },
                  aud: '',
                  createdAt: DateTime.now().toIso8601String(),
                  email: email,
                ),
              );
            } else {
              // 정상적으로 가입된 활성 사용자
              print('👤 [SUPABASE_AUTH] Active user detected');
              await _supabase.auth.signOut();
              throw AuthException('이미 가입된 이메일입니다. 로그인해주세요.');
            }
          }
        } catch (loginError) {
          print('❌ [SUPABASE_AUTH] Login failed during check: $loginError');
          
          if (loginError.toString().contains('Invalid login credentials')) {
            print('🔑 [SUPABASE_AUTH] Wrong password for existing user');
            throw AuthException('이미 가입된 이메일이지만 비밀번호가 다릅니다. 비밀번호를 확인하거나 비밀번호 재설정을 이용해주세요.');
          } else if (loginError.toString().contains('탈퇴한 계정') || 
                     loginError.toString().contains('재활성화') ||
                     loginError.toString().contains('이미 가입된')) {
            rethrow; // 우리가 던진 메시지는 그대로 전달
          }
          
          // 기타 로그인 에러
          print('❌ [SUPABASE_AUTH] Other login error: $loginError');
          throw AuthException('계정 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        }
      }
      
      // 기본 fallback
      print('❓ [SUPABASE_AUTH] Unknown status, fallback error');
      throw AuthException('계정 상태를 확인할 수 없습니다. 잠시 후 다시 시도해주세요.');
      
    } catch (e) {
      print('💥 [SUPABASE_AUTH] Error in _handleExistingUserDirect: $e');
      if (e.toString().contains('재활성화') || 
          e.toString().contains('이미 가입된') ||
          e.toString().contains('이메일 인증이 완료되지 않았습니다') ||
          e.toString().contains('비밀번호가 다릅니다') ||
          e.toString().contains('계정 상태를 확인할 수 없습니다')) {
        rethrow; // 명시적인 메시지는 그대로 전달
      }
      print('❌ [SUPABASE_AUTH] Unexpected error handling existing user directly: $e');
      rethrow;
    } finally {
      print('🔧 [SUPABASE_AUTH] === HANDLE EXISTING USER END ===');
    }
  }

  /// 통합된 Supabase Auth 사용자 존재 확인
  Future<String?> _checkSupabaseAuthUser(String email) async {
    try {
      print('🔍 [SUPABASE_AUTH] Checking Supabase auth user: $email');
      
      // 1단계: user_profiles에서 이메일이 없는 기존 사용자 확인
      print('🔍 [SUPABASE_AUTH] Step 2.1: Skipping email-less profile check...');
      print('🔍 [SUPABASE_AUTH] Will rely on actual signup attempt for accurate detection');
      
      // 2단계: 실제 Supabase auth 상태 확인 (dummy password 방식)
      print('🔍 [SUPABASE_AUTH] Step 2.2: Testing auth status with dummy password...');
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: 'dummy_password_check_12345',
        );
        
        // 로그인 성공하면 안되지만, 혹시 모르니 로그아웃
        print('😱 [SUPABASE_AUTH] Unexpected successful login with dummy password!');
        await _supabase.auth.signOut();
        return '알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        
      } catch (authError) {
        final errorString = authError.toString();
        print('🔍 [SUPABASE_AUTH] Auth check result: $errorString');
        
        if (errorString.contains('Invalid login credentials')) {
          // 비밀번호 틀림 = 사용자 존재함
          print('👤 [SUPABASE_AUTH] User exists in Supabase auth but not in user_profiles');
          print('📝 [SUPABASE_AUTH] This might be a legacy user from before email field was added');
          
          // 이 경우 어떻게 처리할지 결정해야 함
          // 일단은 기존 사용자로 간주
          return '이미 가입된 이메일입니다.\n\n로그인을 시도하거나 비밀번호 재설정을 이용해주세요.';
          
        } else if (errorString.contains('Email not confirmed')) {
          // 이메일 인증 미완료
          print('📧 [SUPABASE_AUTH] Unconfirmed email account exists');
          return '이미 가입된 이메일입니다.\n\n이메일 인증을 완료하거나 로그인을 시도해주세요.';
          
        } else if (errorString.contains('User not found')) {
          // 사용자 없음 - 신규 가입 가능
          print('✅ [SUPABASE_AUTH] User not found, can proceed with signup');
          return null;
          
        } else {
          // 기타 에러 - 신규 사용자로 간주
          print('❓ [SUPABASE_AUTH] Other auth error, treating as new user: $errorString');
          return null;
        }
      }
      
    } catch (e) {
      print('⚠️ [SUPABASE_AUTH] Error in Supabase auth check: $e');
      // 에러 발생 시 신규 사용자로 간주
      return null;
    }
  }

  /// 탈퇴한 사용자 체크 (이메일 기반) - 재활성화 지원
  Future<AuthResponse?> _checkDeletedUserByEmail(String email) async {
    try {
      print('🔍 [SUPABASE_AUTH] Checking deleted user by email: $email');
      
      // 임시 비밀번호로 로그인 시도하여 사용자 존재 확인
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: 'dummy_password_for_check_12345',
        );
        
        // 로그인 성공하면 안되지만, 혹시 모르니 로그아웃
        await _supabase.auth.signOut();
        return null; // 계속 진행
        
      } catch (loginError) {
        print('🔑 [SUPABASE_AUTH] Login check result: ${loginError.toString()}');
        
        if (loginError.toString().contains('Invalid login credentials')) {
          // 비밀번호 틀림 = 사용자 존재함, 탈퇴 여부 확인 필요
          print('👤 [SUPABASE_AUTH] User exists, checking if deleted...');
          
          // user_profiles에서 이메일로 사용자 조회
          final profile = await _supabase
              .from('user_profiles')
              .select('user_id, deleted_at, nickname, email')
              .eq('email', email)
              .maybeSingle();
          
          if (profile == null) {
            print('✅ [SUPABASE_AUTH] No profile found with this email, might be new user');
            return null;
          }
          
          final userId = profile['user_id'] as String;
          print('🔍 [SUPABASE_AUTH] Found user ID: $userId');
          
          if (profile['deleted_at'] != null) {
            print('🔄 [SUPABASE_AUTH] DELETED USER DETECTED - Direct reactivation without email verification');
            print('🔄 [SUPABASE_AUTH] User was deleted at: ${profile['deleted_at']}');
            
            // 🎉 탈퇴한 사용자는 이미 이메일 인증을 마쳤으므로 바로 재활성화
            print('✅ [SUPABASE_AUTH] Returning user - skipping email verification');
            
            // 탈퇴한 사용자 환영 + 바로 로그인 처리 가능 상태로 반환
            return AuthResponse(
              user: User(
                id: userId,
                appMetadata: {
                  'reactivated': true,
                  'welcome_back': true,
                  'skip_email_verification': true,
                  'direct_login': true,
                },
                userMetadata: {
                  'message': '🎉 다시 돌아오신 것을 환영합니다!',
                  'action': '이미 인증된 계정이므로 바로 이용하실 수 있습니다.',
                  'celebration_emoji': '🥳',
                  'skip_email_verification': true,
                },
                aud: '',
                createdAt: DateTime.now().toIso8601String(),
                email: email,
              ),
            );
          } else {
            // 활성 사용자 - 이미 가입된 이메일
            print('👤 [SUPABASE_AUTH] Active user detected, blocking signup');
            throw AuthException('이미 가입된 이메일입니다.\n\n로그인을 시도하거나 비밀번호 재설정을 이용해주세요.');
          }
          
        } else if (loginError.toString().contains('Email not confirmed')) {
          // 이메일 미인증 = 이미 가입했지만 인증 안함
          throw AuthException('이미 가입된 이메일입니다.\n\n이메일 인증을 완료하거나 로그인을 시도해주세요.');
        }
        
        // 기타 에러는 신규 사용자로 간주하고 계속 진행
        print('✅ [SUPABASE_AUTH] New user, proceeding with signup');
        return null;
      }
      
    } catch (e) {
      if (e.toString().contains('이미 가입된') || e.toString().contains('이미 탈퇴한')) {
        rethrow; // 명시적 에러는 그대로 전달
      }
      print('⚠️ [SUPABASE_AUTH] Error checking deleted user by email: $e');
      // 기타 오류는 가입 허용
      return null;
    }
  }

  /// 탈퇴한 사용자 체크
  Future<void> _checkDeletedUser(String userId) async {
    try {
      print('🔍 [SUPABASE_AUTH] Checking if user is deleted: $userId');
      
      final profile = await _supabase
          .from('user_profiles')
          .select('deleted_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile != null && profile['deleted_at'] != null) {
        print('🚫 [SUPABASE_AUTH] User is deleted, blocking login');
        await _supabase.auth.signOut(); // 세션 즉시 제거
        throw AuthException('탈퇴한 계정입니다. 새로 가입해주세요.');
      }
      
      print('✅ [SUPABASE_AUTH] User is active');
    } catch (e) {
      if (e.toString().contains('탈퇴한 계정')) {
        rethrow; // 탈퇴 에러는 그대로 전달
      }
      print('⚠️ [SUPABASE_AUTH] Error checking deleted user: $e');
      // 기타 오류는 로그인 허용 (프로필이 없는 경우 등)
    }
  }

  /// 이미 존재하는 사용자 처리 (탈퇴한 사용자 재활성화, 이메일 인증 미완료 사용자 처리)
  Future<void> _handleExistingUser(String email, String password) async {
    try {
      print('🔍 [SUPABASE_AUTH] Handling existing user: $email');
      
      // 먼저 resend를 시도해보기 (이메일 인증 미완료 사용자인 경우 성공)
      try {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
        );
        print('📧 [SUPABASE_AUTH] Resend successful - user has unconfirmed email');
        throw AuthException('이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.');
      } catch (resendError) {
        print('⚠️ [SUPABASE_AUTH] Resend failed, trying login to check user status');
        
        // resend가 실패하면 로그인을 시도해서 사용자 상태 확인
        try {
          final tempResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (tempResponse.user != null) {
            final userId = tempResponse.user!.id;
            final emailConfirmedAt = tempResponse.user!.emailConfirmedAt;
            
            print('📧 [SUPABASE_AUTH] Login successful - emailConfirmed: ${emailConfirmedAt != null}');
            
            // 이메일 인증은 완료됐지만 로그인된 사용자 - 프로필 확인
            final profile = await _supabase
                .from('user_profiles')
                .select('deleted_at')
                .eq('user_id', userId)
                .maybeSingle();
            
            if (profile != null && profile['deleted_at'] != null) {
              print('🔄 [SUPABASE_AUTH] Reactivating deleted user');
              
              // 탈퇴한 사용자 재활성화
              await _supabase.from('user_profiles').update({
                'deleted_at': null,
                'nickname': email.split('@')[0],
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('user_id', userId);
              
              // 로그아웃 후 완료 메시지
              await _supabase.auth.signOut();
              
              print('✅ [SUPABASE_AUTH] User reactivated successfully');
              throw AuthException('탈퇴한 계정이 재활성화되었습니다. 로그인해주세요.');
            } else {
              // 정상적으로 가입된 활성 사용자
              await _supabase.auth.signOut();
              throw AuthException('이미 가입된 이메일입니다. 로그인해주세요.');
            }
          }
        } catch (loginError) {
          print('❌ [SUPABASE_AUTH] Login also failed: $loginError');
          
          // 로그인도 실패하면 비밀번호 문제일 수 있음
          if (loginError.toString().contains('Invalid login credentials')) {
            throw AuthException('이미 가입된 이메일이지만 비밀번호가 다릅니다. 비밀번호를 확인하거나 비밀번호 재설정을 이용해주세요.');
          }
          
          // 그외의 경우 원본 resend 에러가 더 유용할 수 있음
          throw AuthException('계정 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        }
      }
    } catch (e) {
      if (e.toString().contains('재활성화') || 
          e.toString().contains('이미 가입된') ||
          e.toString().contains('이메일 인증이 완료되지 않았습니다') ||
          e.toString().contains('비밀번호가 다릅니다')) {
        rethrow; // 명시적인 메시지는 그대로 전달
      }
      print('❌ [SUPABASE_AUTH] Error handling existing user: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 생성 확인 및 보완
  Future<void> _ensureUserProfile(User user) async {
    try {
      // 사용자 프로필이 이미 존재하는지 확인
      final profileCheck = await _supabase
          .from('user_profiles')
          .select('user_id, deleted_at, email')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileCheck == null) {
        // 프로필이 없으면 생성
        await _supabase.from('user_profiles').insert({
          'user_id': user.id,
          'nickname': user.userMetadata?['nickname'] ?? user.email?.split('@')[0] ?? 'User',
          'email': user.email, // 이메일 필드 추가
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ [SUPABASE_AUTH] User profile created successfully with email: ${user.email}');
      } else if (profileCheck['email'] == null && user.email != null) {
        // 기존 프로필에 이메일이 없으면 업데이트
        await _supabase.from('user_profiles').update({
          'email': user.email,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
        print('✅ [SUPABASE_AUTH] User profile email updated: ${user.email}');
      } else if (profileCheck['deleted_at'] != null) {
        // 탈퇴한 사용자면 로그인 차단
        await _supabase.auth.signOut();
        throw AuthException('탈퇴한 계정입니다. 새로 가입해주세요.');
      }
    } catch (e) {
      if (e.toString().contains('탈퇴한 계정')) {
        rethrow; // 탈퇴 에러는 그대로 전달
      }
      print('⚠️ [SUPABASE_AUTH] Profile creation failed, but user auth succeeded: $e');
      // 프로필 생성 실패해도 인증은 성공한 것으로 처리
    }
  }

  /// 구글 로그인
  Future<AuthResponse> signInWithGoogle() async {
    try {
      print('🔍 [SUPABASE_AUTH] ======= GOOGLE SIGN IN START =======');
      print('🔍 [SUPABASE_AUTH] Google sign in attempt');
      print('🔍 [SUPABASE_AUTH] Platform: iOS Simulator');
      print('🔍 [SUPABASE_AUTH] GoogleSignIn instance: $_googleSignIn');
      print('🔍 [SUPABASE_AUTH] GoogleSignIn scopes: ${_googleSignIn.scopes}');
      
      // 🔧 iOS 시뮬레이터 체크
      print('⚠️ [SUPABASE_AUTH] IMPORTANT: iOS Simulator has limitations with Google Sign-In');
      print('⚠️ [SUPABASE_AUTH] Consider testing on real device if issues persist');
      
      // Step 1: Google Sign-In 초기화 확인
      print('📱 [SUPABASE_AUTH] Step 1: Checking Google Sign-In initialization...');
      try {
        final bool isSignedIn = await _googleSignIn.isSignedIn();
        print('📱 [SUPABASE_AUTH] Already signed in: $isSignedIn');
        
        if (isSignedIn) {
          print('🔄 [SUPABASE_AUTH] User already signed in, signing out first...');
          await _googleSignIn.signOut();
          print('✅ [SUPABASE_AUTH] Previous session cleared');
        }
      } catch (initError) {
        print('⚠️ [SUPABASE_AUTH] Init check failed: $initError');
        print('⚠️ [SUPABASE_AUTH] This might be normal on iOS Simulator');
      }
      
      // Step 2: Google 로그인 시작
      print('🚀 [SUPABASE_AUTH] Step 2: Starting Google Sign-In flow...');
      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
        print('📱 [SUPABASE_AUTH] Google Sign-In completed');
        print('📱 [SUPABASE_AUTH] GoogleUser result: $googleUser');
      } catch (signInError) {
        print('💥 [SUPABASE_AUTH] Google Sign-In CRASHED!');
        print('💥 [SUPABASE_AUTH] Error type: ${signInError.runtimeType}');
        print('💥 [SUPABASE_AUTH] Error message: $signInError');
        print('💥 [SUPABASE_AUTH] Error string: ${signInError.toString()}');
        
        // iOS 시뮬레이터 특화 에러 체크
        if (signInError.toString().contains('simulator') || 
            signInError.toString().contains('Simulator') ||
            signInError.toString().contains('SIMULATOR')) {
          throw Exception('❌ iOS 시뮬레이터에서는 Google 로그인이 제한될 수 있습니다.\n\n실제 iOS 기기에서 테스트해보세요.');
        }
        
        throw Exception('Google 로그인 초기화 실패: $signInError');
      }
      
      if (googleUser == null) {
        print('❌ [SUPABASE_AUTH] Google 로그인이 취소되었습니다.');
        throw Exception('Google 로그인이 취소되었습니다.');
      }
      
      print('✅ [SUPABASE_AUTH] Google User obtained: ${googleUser.email}');
      print('✅ [SUPABASE_AUTH] Display name: ${googleUser.displayName}');
      print('✅ [SUPABASE_AUTH] ID: ${googleUser.id}');

      // Step 3: Google 인증 정보 가져오기
      print('🔑 [SUPABASE_AUTH] Step 3: Getting Google authentication...');
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
        print('✅ [SUPABASE_AUTH] Google authentication obtained');
        print('🔑 [SUPABASE_AUTH] Access token exists: ${googleAuth.accessToken != null}');
        print('🔑 [SUPABASE_AUTH] ID token exists: ${googleAuth.idToken != null}');
        
        if (googleAuth.accessToken != null) {
          print('🔑 [SUPABASE_AUTH] Access token length: ${googleAuth.accessToken!.length}');
        }
        if (googleAuth.idToken != null) {
          print('🔑 [SUPABASE_AUTH] ID token length: ${googleAuth.idToken!.length}');
        }
      } catch (authError) {
        print('💥 [SUPABASE_AUTH] Google authentication FAILED!');
        print('💥 [SUPABASE_AUTH] Auth error: $authError');
        throw Exception('Google 인증 정보 가져오기 실패: $authError');
      }
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ [SUPABASE_AUTH] Missing tokens:');
        print('❌ [SUPABASE_AUTH] Access token: ${googleAuth.accessToken}');
        print('❌ [SUPABASE_AUTH] ID token: ${googleAuth.idToken}');
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }
      
      print('✅ [SUPABASE_AUTH] All Google tokens obtained successfully');

      // Step 4: Supabase에 Google OAuth로 로그인
      print('🔗 [SUPABASE_AUTH] Step 4: Signing into Supabase with Google tokens...');
      final AuthResponse response;
      try {
        response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken!,
        );
        print('✅ [SUPABASE_AUTH] Supabase Google auth completed');
        print('✅ [SUPABASE_AUTH] Response user: ${response.user?.id}');
        print('✅ [SUPABASE_AUTH] Response session: ${response.session != null}');
      } catch (supabaseError) {
        print('💥 [SUPABASE_AUTH] Supabase Google auth FAILED!');
        print('💥 [SUPABASE_AUTH] Supabase error: $supabaseError');
        print('💥 [SUPABASE_AUTH] Error type: ${supabaseError.runtimeType}');
        throw Exception('Supabase Google 로그인 실패: $supabaseError');
      }

      // Step 5: 사용자 검증
      if (response.user != null) {
        print('👤 [SUPABASE_AUTH] Step 5: Checking user status...');
        print('👤 [SUPABASE_AUTH] User ID: ${response.user!.id}');
        print('👤 [SUPABASE_AUTH] User email: ${response.user!.email}');
        
        try {
          // 탈퇴한 사용자 체크
          await _checkDeletedUser(response.user!.id);
          print('✅ [SUPABASE_AUTH] User status check passed');
        } catch (userCheckError) {
          print('❌ [SUPABASE_AUTH] User status check failed: $userCheckError');
          rethrow;
        }
        
        print('🎉 [SUPABASE_AUTH] Google sign in successful!');
        print('🎉 [SUPABASE_AUTH] Welcome: ${response.user!.email}');
      } else {
        print('❌ [SUPABASE_AUTH] No user in response');
        throw Exception('Google 로그인 후 사용자 정보를 가져올 수 없습니다.');
      }
      
      print('🔍 [SUPABASE_AUTH] ======= GOOGLE SIGN IN SUCCESS =======');
      return response;
    } catch (e) {
      print('💥 [SUPABASE_AUTH] ======= GOOGLE SIGN IN ERROR =======');
      print('💥 [SUPABASE_AUTH] Final error: $e');
      print('💥 [SUPABASE_AUTH] Error type: ${e.runtimeType}');
      print('💥 [SUPABASE_AUTH] Error string: ${e.toString()}');
      
      // 🧹 실패 시 정리
      try {
        print('🧹 [SUPABASE_AUTH] Cleaning up Google Sign-In state...');
        await _googleSignIn.signOut();
        print('✅ [SUPABASE_AUTH] Google Sign-In cleanup completed');
      } catch (cleanupError) {
        print('⚠️ [SUPABASE_AUTH] Cleanup failed: $cleanupError');
        // 정리 실패해도 원본 에러는 그대로 전달
      }
      
      print('💥 [SUPABASE_AUTH] ======= GOOGLE SIGN IN ERROR END =======');
      rethrow;
    }
  }

  /// Facebook 로그인
  Future<AuthResponse> signInWithFacebook() async {
    try {
      print('📘 [SUPABASE_AUTH] Facebook sign in attempt');
      
      // Facebook 로그인 시작
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook 로그인이 취소되었거나 실패했습니다.');
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        throw Exception('Facebook 액세스 토큰을 가져올 수 없습니다.');
      }

      // Supabase에 Facebook OAuth로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken.tokenString,
      );

      if (response.user != null) {
        // 탈퇴한 사용자 체크
        await _checkDeletedUser(response.user!.id);
        
        print('✅ [SUPABASE_AUTH] Facebook sign in successful');
      }
      
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Facebook sign in failed: $e');
      await FacebookAuth.instance.logOut(); // 실패 시 정리
      rethrow;
    }
  }

  /// 카카오 로그인 (기존 방식 유지)
  Future<bool> signInWithKakao() async {
    // 기존 카카오 로그인 로직을 그대로 사용
    // 나중에 Supabase와 연동할 수 있음
    print('💬 [SUPABASE_AUTH] Kakao sign in - using existing implementation');
    return false; // 기존 KakaoAuthRepository 사용
  }

  /// 이메일 인증 재전송 (단순화)
  Future<void> resendEmailConfirmation(String email) async {
    try {
      print('📧 [SUPABASE_AUTH] ===== EMAIL RESEND START =====');
      print('📧 [SUPABASE_AUTH] Email: $email');
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
      );
      
      print('✅ [SUPABASE_AUTH] 이메일 재전송 요청 완료');
      print('📧 [SUPABASE_AUTH] ===== EMAIL RESEND END =====');
    } catch (e) {
      print('❌ [SUPABASE_AUTH] 이메일 재전송 실패: $e');
      
      // Rate limit 관련 에러는 무시 (이미 이메일이 전송되었을 가능성)
      if (e.toString().contains('Email rate limit exceeded') || 
          e.toString().contains('Too many requests') ||
          e.toString().contains('user_repeated_signup')) {
        print('⚠️ [SUPABASE_AUTH] Rate limit - 이전에 전송된 이메일을 확인해보세요');
        return; // 에러를 던지지 않고 성공으로 처리
      }
      
      rethrow;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword(String email, {String? redirectUrl}) async {
    try {
      print('🔐 [SUPABASE_AUTH] Sending password reset email to: $email');
      
      if (redirectUrl != null) {
        print('🔗 [SUPABASE_AUTH] Using Magic Link with redirect URL: $redirectUrl');
        // Magic Link 방식 (redirectTo 포함)
        await _supabase.auth.resetPasswordForEmail(
          email,
          redirectTo: redirectUrl,
        );
      } else {
        print('📧 [SUPABASE_AUTH] Using OTP method (no redirect URL)');
        // OTP 방식 (redirectTo 없음)
        await _supabase.auth.resetPasswordForEmail(email);
      }
      
      print('✅ [SUPABASE_AUTH] Password reset email sent successfully');
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Password reset failed: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      print('🚪 [SUPABASE_AUTH] Starting sign out');
      
      // Supabase 로그아웃
      await _supabase.auth.signOut();
      
      // Google 로그아웃 (안전하게)
      try {
        await _googleSignIn.signOut();
        print('✅ [SUPABASE_AUTH] Google sign out completed');
      } catch (e) {
        print('⚠️ [SUPABASE_AUTH] Google sign out failed: $e');
        // Google 로그아웃 실패해도 계속 진행
      }
      
      // Facebook 로그아웃 (안전하게)
      try {
        await FacebookAuth.instance.logOut();
        print('✅ [SUPABASE_AUTH] Facebook sign out completed');
      } catch (e) {
        print('⚠️ [SUPABASE_AUTH] Facebook sign out failed: $e');
        // Facebook 로그아웃 실패해도 계속 진행 (MissingPluginException 등)
      }
      
      // 자동 로그인 비활성화
      await setAutoLogin(false);
      
      print('✅ [SUPABASE_AUTH] Sign out completed');
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Sign out failed: $e');
      rethrow;
    }
  }

  /// 인증 상태 스트림
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  /// 사용자 정보 업데이트
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      
      print('✅ [SUPABASE_AUTH] User updated successfully');
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] User update failed: $e');
      rethrow;
    }
  }

  /// 자동 로그인 시도
  Future<bool> tryAutoLogin() async {
    try {
      if (!getAutoLogin()) {
        print('🔍 [SUPABASE_AUTH] Auto login disabled');
        return false;
      }

      print('🔍 [SUPABASE_AUTH] Checking auto login');
      
      // Supabase 세션 확인
      final session = _supabase.auth.currentSession;
      if (session != null && !session.isExpired && session.user != null) {
        // 탈퇴한 사용자 체크
        try {
          await _checkDeletedUser(session.user!.id);
          print('✅ [SUPABASE_AUTH] Valid session found, auto login successful');
          return true;
        } catch (e) {
          if (e.toString().contains('탈퇴한 계정')) {
            print('🚫 [SUPABASE_AUTH] Auto login blocked - deleted user');
            await signOut(); // 세션 완전 정리
            return false;
          }
          rethrow;
        }
      }

      print('⚠️ [SUPABASE_AUTH] No valid session found');
      return false;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Auto login failed: $e');
      return false;
    }
  }


  /// 🔍 실시간 이메일 존재 여부 확인 (RPC 함수 사용)
  Future<EmailCheckResult> checkEmailExistsQuick(String email) async {
    print('🔍 [EMAIL_CHECK] ===== RPC EMAIL CHECK START =====');
    print('🔍 [EMAIL_CHECK] Checking email: $email');
    
    try {
      // 🎯 RLS 정책을 우회하는 RPC 함수 사용
      print('🔍 [EMAIL_CHECK] Calling check_email_exists RPC function...');
      final profileResponse = await _supabase
          .rpc('check_email_exists', params: {'email_to_check': email});
      
      print('🔍 [EMAIL_CHECK] RPC response: $profileResponse');
      print('🔍 [EMAIL_CHECK] RPC response type: ${profileResponse.runtimeType}');
      print('🔍 [EMAIL_CHECK] RPC response length: ${profileResponse?.length ?? 0}');
      
      // 🎯 결과 확인: 리스트가 비어있지 않으면 존재함
      if (profileResponse != null && profileResponse.isNotEmpty) {
        final profile = profileResponse.first;
        final isDeleted = profile['deleted_at'] != null;
        final nickname = profile['nickname'] ?? 'Unknown';
        
        print('✅ [EMAIL_CHECK] Email exists in user_profiles - deleted: $isDeleted');
        print('🔍 [EMAIL_CHECK] User details: ${profile['user_id']}, nickname: $nickname');
        
        return EmailCheckResult(
          exists: true,
          isDeleted: isDeleted,
          canReactivate: isDeleted,
          message: isDeleted 
              ? '이전에 탈퇴한 계정입니다. 재가입하시겠어요?'
              : '이미 가입된 이메일입니다. 로그인을 시도해보세요.',
          recommendedAction: isDeleted ? EmailAction.reactivate : EmailAction.signIn,
        );
      }
      
      // 🎯 프로필에서 찾지 못했으면 사용 가능한 이메일
      print('✅ [EMAIL_CHECK] Email not found in user_profiles - available for signup');
      return EmailCheckResult(
        exists: false,
        isDeleted: false,
        canReactivate: false,
        message: '',
        recommendedAction: EmailAction.signUp,
      );
      
    } catch (e) {
      print('❌ [EMAIL_CHECK] RPC error during email check: $e');
      print('❌ [EMAIL_CHECK] Defaulting to signup allowed');
      
      // 에러 발생 시 보수적으로 가입 허용
      return EmailCheckResult(
        exists: false,
        isDeleted: false,
        canReactivate: false,
        message: '',
        recommendedAction: EmailAction.signUp,
      );
    } finally {
      print('🔍 [EMAIL_CHECK] ===== RPC EMAIL CHECK END =====');
    }
  }

  /// 오류 메시지 처리
  String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case 'Email not confirmed':
          return '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
        case 'User already registered':
          return '이미 가입된 이메일입니다.';
        case 'Password should be at least 6 characters':
          return '비밀번호는 6자 이상이어야 합니다.';
        case '이메일 인증이 필요합니다. 이메일을 확인해주세요.':
          return '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
        case '탈퇴한 계정입니다. 새로 가입해주세요.':
          return '탈퇴한 계정입니다. 새로 가입해주세요.';
        case '탈퇴한 계정이 재활성화되었습니다. 이메일을 확인하여 인증을 완료해주세요.':
          return '탈퇴한 계정이 재활성화되었습니다. 이메일을 확인하여 인증을 완료해주세요.';
        case '탈퇴한 계정이 재활성화되었습니다. 로그인해주세요.':
          return '탈퇴한 계정이 재활성화되었습니다. 로그인해주세요.';
        case '이미 가입된 이메일입니다. 로그인해주세요.':
          return '이미 가입된 이메일입니다. 로그인해주세요.';
        case '이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.':
          return '이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.';
        case '이미 가입된 이메일이지만 비밀번호가 다릅니다. 비밀번호를 확인하거나 비밀번호 재설정을 이용해주세요.':
          return '이미 가입된 이메일이지만 비밀번호가 다릅니다. 비밀번호를 확인하거나 비밀번호 재설정을 이용해주세요.';
        case '계정 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.':
          return '계정 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        case '계정 상태를 확인할 수 없습니다. 잠시 후 다시 시도해주세요.':
          return '계정 상태를 확인할 수 없습니다. 잠시 후 다시 시도해주세요.';
        case '인증 메일을 다시 발송했습니다. 이메일을 확인해주세요.':
          return '인증 메일을 다시 발송했습니다. 이메일을 확인해주세요.';
        case '탈퇴한 계정이 재활성화되었습니다. 로그인해주세요.':
          return '탈퇴한 계정이 재활성화되었습니다. 로그인해주세요.';
        case '이메일 인증이 완료되지 않았습니다. 이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.':
          return '이메일 인증이 완료되지 않았습니다. 이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.';
        default:
          if (error.message.contains('탈퇴한 계정')) {
            return '탈퇴한 계정입니다. 새로 가입해주세요.';
          }
          if (error.message.contains('재활성화')) {
            return '계정이 재활성화되었습니다! 이메일을 확인하여 인증을 완료하거나 로그인해주세요.';
          }
          if (error.message.contains('환영합니다')) {
            return error.message; // 환영 메시지는 그대로 전달
          }
          if (error.message.contains('이메일 전송에 실패했습니다')) {
            return '''계정이 재활성화되었습니다!

이메일 전송에 실패했지만 다음 방법을 시도해보세요:
• 기존 비밀번호로 바로 로그인
• 비밀번호 찾기 이용
• 스팸 폴더 확인 (이메일이 늦게 도착할 수 있음)''';
          }
          return error.message;
      }
    }
    
    // Exception 타입이 아닌 경우
    final errorString = error.toString();
    if (errorString.contains('탈퇴한 계정')) {
      return '탈퇴한 계정입니다. 새로 가입해주세요.';
    }
    
    return errorString;
  }
}