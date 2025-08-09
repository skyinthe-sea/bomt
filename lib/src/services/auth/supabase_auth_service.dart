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

  /// 자동 로그인 설정 가져오기
  bool getAutoLogin() {
    return _prefs?.getBool(_autoLoginKey) ?? false;
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

  /// 이메일 회원가입 (단순화)
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      print('📧 [SUPABASE_AUTH] ======= SIMPLE EMAIL SIGNUP START =======');
      print('📧 [SUPABASE_AUTH] Email: $email');
      
      // 🔍 탈퇴한 사용자인지 이메일로 확인 및 재활성화 처리  
      print('🔍 [SUPABASE_AUTH] Step 1: Checking for deleted users in user_profiles...');
      final reactivationResponse = await _checkDeletedUserByEmail(email);
      if (reactivationResponse != null) {
        // 탈퇴한 사용자 발견 - 재활성화 처리
        final userId = reactivationResponse.user!.id;
        print('🔄 [SUPABASE_AUTH] Reactivating deleted user: $userId');
        
        // 프로필 재활성화 (deleted_at을 null로 설정)
        await _supabase.from('user_profiles').update({
          'deleted_at': null,
          'nickname': email.split('@')[0],
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
        
        print('✅ [SUPABASE_AUTH] User profile reactivated successfully');
        
        // 🎉 탈퇴한 사용자는 바로 로그인 처리
        try {
          print('🔑 [SUPABASE_AUTH] Creating session for returning user...');
          
          // 실제 로그인 시도 (패스워드가 맞으면 바로 로그인)
          final loginResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (loginResponse.user != null) {
            print('🎉 [SUPABASE_AUTH] Returning user login successful!');
            
            // 프로필 확인 및 업데이트
            await _ensureUserProfile(loginResponse.user!);
            
            // 환영 메시지와 함께 로그인 완료 상태 반환
            return AuthResponse(
              user: User(
                id: userId,
                appMetadata: {
                  'reactivated': true,
                  'welcome_back': true,
                  'logged_in': true,
                },
                userMetadata: {
                  'message': '🎉 다시 돌아오신 것을 환영합니다!',
                  'action': '바로 BabyMom을 이용하실 수 있습니다.',
                  'celebration_emoji': '🥳',
                },
                aud: loginResponse.user!.aud,
                createdAt: loginResponse.user!.createdAt,
                email: email,
              ),
              session: loginResponse.session,
            );
          }
        } catch (loginError) {
          print('⚠️ [SUPABASE_AUTH] Login failed for returning user, falling back to password reset flow: $loginError');
          
          // 로그인 실패 시 비밀번호 재설정 안내
          return AuthResponse(
            user: User(
              id: userId,
              appMetadata: {
                'reactivated': true,
                'password_reset_needed': true,
              },
              userMetadata: {
                'message': '🎉 다시 돌아오신 것을 환영합니다!',
                'action': '비밀번호가 변경되었을 수 있습니다. 비밀번호 재설정을 통해 로그인해주세요.',
                'celebration_emoji': '🥳',
              },
              aud: '',
              createdAt: DateTime.now().toIso8601String(),
              email: email,
            ),
          );
        }
        
        print('📧 [SUPABASE_AUTH] ======= REACTIVATION COMPLETE =======');
        return reactivationResponse;
      }
      
      print('✅ [SUPABASE_AUTH] Step 1 Result: No deleted user found in user_profiles');
      
      // 🚀 실제 Supabase signup 시도 (강화된 이메일 전송 확인)
      print('🚀 [SUPABASE_AUTH] Step 2: Attempting actual Supabase signup...');
      
      AuthResponse? signupResponse;
      bool emailSent = false;
      String emailMethod = '';
      
      // 1차 시도: 표준 signup
      try {
        signupResponse = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'nickname': email.split('@')[0],
          },
          emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
        );
        
        print('📧 [SUPABASE_AUTH] SignUp response received');
        print('📧 [SUPABASE_AUTH] Response user: ${signupResponse?.user?.id}');
        
        if (signupResponse?.user != null) {
          emailSent = true;
          emailMethod = 'standard_signup';
          print('✅ [SUPABASE_AUTH] 1차 시도 성공: Standard signup with email');
        }
      } catch (signupError) {
        print('⚠️ [SUPABASE_AUTH] 1차 시도 실패: $signupError');
        
        // 2차 시도: redirect URL 없이 signup
        await Future.delayed(const Duration(milliseconds: 1000));
        try {
          signupResponse = await _supabase.auth.signUp(
            email: email,
            password: password,
            data: {
              'nickname': email.split('@')[0],
            },
          );
          
          if (signupResponse?.user != null) {
            emailSent = true;
            emailMethod = 'simple_signup';
            print('✅ [SUPABASE_AUTH] 2차 시도 성공: Simple signup without redirect');
          }
        } catch (simpleSignupError) {
          print('⚠️ [SUPABASE_AUTH] 2차 시도 실패: $simpleSignupError');
          
          // 3차 시도: 잠시 대기 후 resend 방식
          await Future.delayed(const Duration(milliseconds: 1500));
          try {
            // 먼저 기본 signup 시도 (이메일 없이)
            signupResponse = await _supabase.auth.signUp(
              email: email,
              password: password,
              data: {'nickname': email.split('@')[0]},
            );
            
            if (signupResponse?.user != null) {
              // 그 다음 resend로 이메일 전송
              await Future.delayed(const Duration(milliseconds: 500));
              await _supabase.auth.resend(
                type: OtpType.signup,
                email: email,
                emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
              );
              emailSent = true;
              emailMethod = 'signup_then_resend';
              print('✅ [SUPABASE_AUTH] 3차 시도 성공: Signup then manual resend');
            }
          } catch (resendSignupError) {
            print('❌ [SUPABASE_AUTH] 3차 시도 실패: $resendSignupError');
            throw signupError; // 원본 에러 전달
          }
        }
      }
      
      if (signupResponse?.user != null) {
        print('✅ [SUPABASE_AUTH] Email sign up successful');
        
        if (!emailSent) {
          // 🔧 Fallback: 비밀번호 찾기 방식으로 이메일 재전송 시도
          print('🔧 [SUPABASE_AUTH] Signup email failed, trying password reset method as fallback...');
          
          // 세션 로그아웃 먼저 (중요)
          await _supabase.auth.signOut();
          await Future.delayed(const Duration(milliseconds: 1000));
          
          try {
            // 비밀번호 찾기와 동일한 방식으로 이메일 전송
            await _supabase.auth.resetPasswordForEmail(
              email,
              redirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
            );
            emailSent = true;
            emailMethod = 'password_reset_fallback';
            print('✅ [SUPABASE_AUTH] Fallback email sent successfully using password reset method');
          } catch (resetError) {
            print('⚠️ [SUPABASE_AUTH] Password reset fallback also failed: $resetError');
            
            // 더 간단한 방식으로 시도
            try {
              await _supabase.auth.resetPasswordForEmail(email);
              emailSent = true;
              emailMethod = 'simple_password_reset_fallback';
              print('✅ [SUPABASE_AUTH] Simple password reset fallback succeeded');
            } catch (simpleResetError) {
              print('❌ [SUPABASE_AUTH] All email sending methods failed: $simpleResetError');
            }
          }
        } else {
          // 이메일 인증 전까지 세션 제거
          await _supabase.auth.signOut();
          print('🚪 [SUPABASE_AUTH] Session signed out for new user');
        }
        
        if (emailSent) {
          print('📧 [SUPABASE_AUTH] 이메일 전송 확인됨! 방법: $emailMethod');
          
          // 성공한 방법에 따른 메시지 설정
          final metadata = Map<String, dynamic>.from(signupResponse!.user!.userMetadata ?? {});
          
          if (emailMethod.contains('password_reset')) {
            metadata.addAll({
              'email_sent': true,
              'email_method': emailMethod,
              'signup_completed': true,
              'special_message': '📧 회원가입 완료! 비밀번호 재설정 이메일을 확인하여 계정을 활성화해주세요.',
              'email_type': 'password_reset_for_signup',
            });
          } else {
            metadata.addAll({
              'email_sent': true,
              'email_method': emailMethod,
              'signup_completed': true,
            });
          }
          
          // 업데이트된 User 객체 생성
          final updatedUser = User(
            id: signupResponse!.user!.id,
            appMetadata: signupResponse!.user!.appMetadata,
            userMetadata: metadata,
            aud: signupResponse!.user!.aud,
            createdAt: signupResponse!.user!.createdAt,
            email: signupResponse!.user!.email,
            emailConfirmedAt: signupResponse!.user!.emailConfirmedAt,
          );
          
          signupResponse = AuthResponse(
            user: updatedUser,
            session: signupResponse!.session,
          );
        } else {
          print('⚠️ [SUPABASE_AUTH] 가입은 성공했지만 모든 이메일 전송 방법이 실패');
          
          // 이메일 전송 실패해도 세션은 로그아웃
          await _supabase.auth.signOut();
          
          // 실패 정보 포함한 응답 생성
          final metadata = Map<String, dynamic>.from(signupResponse!.user!.userMetadata ?? {});
          metadata.addAll({
            'email_sent': false,
            'signup_completed': true,
            'fallback_message': '회원가입은 완료되었으나 이메일 전송에 실패했습니다.\n잠시 후 다시 시도하거나 로그인을 시도해보세요.',
          });
          
          final updatedUser = User(
            id: signupResponse!.user!.id,
            appMetadata: signupResponse!.user!.appMetadata,
            userMetadata: metadata,
            aud: signupResponse!.user!.aud,
            createdAt: signupResponse!.user!.createdAt,
            email: signupResponse!.user!.email,
            emailConfirmedAt: signupResponse!.user!.emailConfirmedAt,
          );
          
          signupResponse = AuthResponse(
            user: updatedUser,
            session: signupResponse!.session,
          );
        }
      }
      
      print('📧 [SUPABASE_AUTH] ======= ENHANCED EMAIL SIGNUP END =======');
      return signupResponse ?? AuthResponse(user: null, session: null);
    } catch (e) {
      print('💥 [SUPABASE_AUTH] ======= EMAIL SIGNUP ERROR =======');
      print('💥 [SUPABASE_AUTH] Error: $e');
      print('💥 [SUPABASE_AUTH] Error type: ${e.runtimeType}');
      
      final errorString = e.toString();
      
      // 🔍 사용자가 이미 존재하는 경우 상세 분석
      if (errorString.contains('User already registered')) {
        print('👤 [SUPABASE_AUTH] User already exists in Supabase auth');
        print('🔍 [SUPABASE_AUTH] Step 3: Checking if this is a deleted user without email in profile...');
        
        // user_profiles에서 이 사용자가 탈퇴했는지 확인
        // 실제 로그인을 시도해서 사용자 ID를 얻어보자
        try {
          print('🔑 [SUPABASE_AUTH] Attempting login to get user info...');
          final loginResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (loginResponse.user != null) {
            final userId = loginResponse.user!.id;
            print('🔍 [SUPABASE_AUTH] Successfully logged in, user ID: $userId');
            
            // 프로필 확인
            final profile = await _supabase
                .from('user_profiles')
                .select('deleted_at, email, nickname')
                .eq('user_id', userId)
                .maybeSingle();
            
            print('🔍 [SUPABASE_AUTH] Profile check result: $profile');
            
            if (profile != null && profile['deleted_at'] != null) {
              print('🔄 [SUPABASE_AUTH] FOUND DELETED USER! Reactivating...');
              
              // 탈퇴한 사용자 재활성화
              await _supabase.from('user_profiles').update({
                'deleted_at': null,
                'email': email, // 이메일도 업데이트
                'nickname': email.split('@')[0],
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('user_id', userId);
              
              print('✅ [SUPABASE_AUTH] User profile reactivated successfully');
              
              // 🚨 핵심 수정: 재활성화된 사용자 처리 개선
              print('📧 [SUPABASE_AUTH] Handling reactivated user email confirmation...');
              
              // 먼저 로그인 세션 완전히 종료
              await _supabase.auth.signOut();
              
              // 세션 정리 대기 (중요: 이메일 재전송 전에 세션이 완전히 정리되도록)
              await Future.delayed(const Duration(milliseconds: 800));
              
              try {
                print('📧 [SUPABASE_AUTH] Attempting email resend for reactivated user...');
                print('📧 [SUPABASE_AUTH] Email: $email');
                print('📧 [SUPABASE_AUTH] User ID: $userId');
                
                // 🔧 다중 시도 이메일 전송 (더 강화된 방식)
                bool emailSent = false;
                String emailMethod = '';
                
                // 1차 시도: 표준 resend
                try {
                  await _supabase.auth.resend(
                    type: OtpType.signup,
                    email: email,
                    emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
                  );
                  emailSent = true;
                  emailMethod = 'standard_resend';
                  print('✅ [SUPABASE_AUTH] 1차 시도 성공: Standard resend');
                } catch (resendError1) {
                  print('⚠️ [SUPABASE_AUTH] 1차 시도 실패: $resendError1');
                  
                  // 2차 시도: 더 긴 대기 후 재시도
                  await Future.delayed(const Duration(milliseconds: 1500));
                  try {
                    await _supabase.auth.resend(
                      type: OtpType.signup,
                      email: email,
                      emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
                    );
                    emailSent = true;
                    emailMethod = 'delayed_resend';
                    print('✅ [SUPABASE_AUTH] 2차 시도 성공: Delayed resend');
                  } catch (resendError2) {
                    print('⚠️ [SUPABASE_AUTH] 2차 시도 실패: $resendError2');
                    
                    // 3차 시도: 비밀번호 리셋 방식
                    await Future.delayed(const Duration(milliseconds: 1000));
                    try {
                      await _supabase.auth.resetPasswordForEmail(
                        email,
                        redirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
                      );
                      emailSent = true;
                      emailMethod = 'password_reset_fallback';
                      print('✅ [SUPABASE_AUTH] 3차 시도 성공: Password reset email');
                    } catch (resetError) {
                      print('⚠️ [SUPABASE_AUTH] 3차 시도 실패: $resetError');
                      
                      // 4차 시도: 다른 redirect URL로 시도
                      try {
                        await _supabase.auth.resend(
                          type: OtpType.signup,
                          email: email,
                          // redirect URL 없이 시도
                        );
                        emailSent = true;
                        emailMethod = 'simple_resend';
                        print('✅ [SUPABASE_AUTH] 4차 시도 성공: Simple resend without redirect');
                      } catch (finalError) {
                        print('❌ [SUPABASE_AUTH] 모든 이메일 전송 시도 실패: $finalError');
                        emailSent = false;
                      }
                    }
                  }
                }
                
                if (emailSent) {
                  print('🎉 [SUPABASE_AUTH] 이메일 전송 성공! 방법: $emailMethod');
                  
                  // 성공한 방법에 따라 다른 메시지 제공
                  String successMessage = '';
                  String actionMessage = '';
                  
                  if (emailMethod == 'password_reset_fallback') {
                    successMessage = '🎉 계정이 재활성화되었습니다!';
                    actionMessage = '비밀번호 재설정 이메일이 전송되었습니다.\n이메일을 확인하여 새 비밀번호를 설정해주세요.';
                  } else {
                    successMessage = '🎉 환영합니다! 계정이 재활성화되었습니다.';
                    actionMessage = '인증 이메일이 전송되었습니다.\n이메일을 확인하여 인증을 완료해주세요.';
                  }
                  
                  return AuthResponse(
                    user: User(
                      id: userId,
                      appMetadata: {
                        'reactivated': true,
                        'welcome_back': true,
                        'email_sent': true,
                        'method': emailMethod,
                        'email_confirmed': true,
                      },
                      userMetadata: {
                        'message': successMessage,
                        'action': actionMessage,
                        'email_sent': true,
                        'email_type': emailMethod == 'password_reset_fallback' ? 'password_reset' : 'confirmation',
                      },
                      aud: '',
                      createdAt: DateTime.now().toIso8601String(),
                      email: email,
                    ),
                  );
                } else {
                  print('❌ [SUPABASE_AUTH] 모든 이메일 전송 방법 실패');
                  
                  // 모든 이메일 전송 시도 실패 - 더 명확한 안내와 대안 제시
                  return AuthResponse(
                    user: User(
                      id: userId,
                      appMetadata: {
                        'reactivated': true,
                        'welcome_back': true,
                        'email_sent': false,
                        'email_failed': true,
                        'show_manual_login_option': true,
                        'show_password_reset_option': true,
                      },
                      userMetadata: {
                        'message': '🎉 계정이 재활성화되었습니다!',
                        'action': '''이메일 전송에 실패했습니다. 다음 방법을 시도해보세요:

1️⃣ 기존 비밀번호로 바로 로그인 시도
2️⃣ "비밀번호 찾기"로 새 비밀번호 설정
3️⃣ 잠시 후 다시 가입 시도

이메일이 늦게 도착할 수도 있으니 스팸 폴더도 확인해보세요.''',
                        'email_sent': false,
                        'suggestion': '로그인 시도 또는 비밀번호 찾기',
                        'troubleshooting': true,
                      },
                      aud: '',
                      createdAt: DateTime.now().toIso8601String(),
                      email: email,
                    ),
                  );
                }
              } catch (criticalError) {
                print('💥 [SUPABASE_AUTH] 치명적 오류 발생: $criticalError');
                
                return AuthResponse(
                  user: User(
                    id: userId,
                    appMetadata: {
                      'reactivated': true,
                      'welcome_back': true,
                      'email_sent': false,
                      'critical_error': true,
                    },
                    userMetadata: {
                      'message': '🎉 계정이 재활성화되었습니다!',
                      'action': '이메일 전송 중 오류가 발생했습니다.\n비밀번호 찾기를 이용하거나 잠시 후 다시 시도해주세요.',
                      'email_sent': false,
                      'error': true,
                    },
                    aud: '',
                    createdAt: DateTime.now().toIso8601String(),
                    email: email,
                  ),
                );
              }
            } else {
              // 활성 사용자 - 로그인 성공했으므로 로그아웃하고 안내
              await _supabase.auth.signOut();
              print('👤 [SUPABASE_AUTH] Active user detected');
              
              // 프로필에 이메일이 없으면 업데이트
              if (profile != null && profile['email'] == null) {
                print('📝 [SUPABASE_AUTH] Updating missing email in profile');
                await _supabase.from('user_profiles').update({
                  'email': email,
                  'updated_at': DateTime.now().toIso8601String(),
                }).eq('user_id', userId);
              }
              
              throw AuthException('이미 가입된 이메일입니다.\n\n로그인을 시도해주세요.');
            }
          }
        } catch (loginError) {
          print('❌ [SUPABASE_AUTH] Login attempt failed: $loginError');
          
          if (loginError.toString().contains('Invalid login credentials')) {
            throw AuthException('이미 가입된 이메일이지만 비밀번호가 다릅니다.\n\n비밀번호를 확인하거나 비밀번호 재설정을 이용해주세요.');
          } else if (loginError.toString().contains('Email not confirmed')) {
            // 이메일 인증 미완료 - resend 시도
            try {
              await _supabase.auth.resend(
                type: OtpType.signup,
                email: email,
                emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
              );
              throw AuthException('이미 가입된 이메일입니다.\n\n이메일 인증이 완료되지 않아 새로운 인증 메일을 발송했습니다.');
            } catch (resendError) {
              throw AuthException('이미 가입된 이메일입니다.\n\n이메일 인증을 완료하거나 로그인을 시도해주세요.');
            }
          } else {
            rethrow;
          }
        }
      } else {
        // 기타 에러는 그대로 전달
        print('💥 [SUPABASE_AUTH] Other signup error: $errorString');
      }
      
      print('💥 [SUPABASE_AUTH] ======= EMAIL SIGNUP ERROR END =======');
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

  /// 이메일 인증 재전송 (강화된 다중 시도 방식)
  Future<void> resendEmailConfirmation(String email) async {
    try {
      print('📧 [SUPABASE_AUTH] ===== ENHANCED EMAIL RESEND START =====');
      print('📧 [SUPABASE_AUTH] Email: $email');
      
      bool emailSent = false;
      String method = '';
      
      // 1차 시도: 표준 resend
      try {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
        );
        emailSent = true;
        method = 'standard_resend';
        print('✅ [SUPABASE_AUTH] 1차 시도 성공: Standard resend');
      } catch (resendError1) {
        print('⚠️ [SUPABASE_AUTH] 1차 시도 실패: $resendError1');
        
        // Rate limit이나 repeated signup은 성공으로 처리
        if (resendError1.toString().contains('Email rate limit exceeded') || 
            resendError1.toString().contains('Too many requests') ||
            resendError1.toString().contains('user_repeated_signup')) {
          print('⚠️ [SUPABASE_AUTH] Rate limit 또는 중복 가입 - 성공으로 처리');
          emailSent = true;
          method = 'rate_limited_success';
        } else {
          // 2차 시도: 더 긴 대기 후 재시도
          await Future.delayed(const Duration(milliseconds: 2000));
          try {
            await _supabase.auth.resend(
              type: OtpType.signup,
              email: email,
              emailRedirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
            );
            emailSent = true;
            method = 'delayed_resend';
            print('✅ [SUPABASE_AUTH] 2차 시도 성공: Delayed resend');
          } catch (resendError2) {
            print('⚠️ [SUPABASE_AUTH] 2차 시도 실패: $resendError2');
            
            // 3차 시도: redirect URL 없이
            await Future.delayed(const Duration(milliseconds: 1000));
            try {
              await _supabase.auth.resend(
                type: OtpType.signup,
                email: email,
              );
              emailSent = true;
              method = 'simple_resend';
              print('✅ [SUPABASE_AUTH] 3차 시도 성공: Simple resend without redirect');
            } catch (resendError3) {
              print('⚠️ [SUPABASE_AUTH] 3차 시도 실패: $resendError3');
              
              // 4차 시도: 비밀번호 재설정 이메일로 대체
              await Future.delayed(const Duration(milliseconds: 1000));
              try {
                await _supabase.auth.resetPasswordForEmail(
                  email,
                  redirectTo: 'https://gowkatetjgcawxemuabm.supabase.co/auth/v1/callback?redirect_to=babymom://auth',
                );
                emailSent = true;
                method = 'password_reset_alternative';
                print('✅ [SUPABASE_AUTH] 4차 시도 성공: Password reset as alternative');
              } catch (resetError) {
                print('❌ [SUPABASE_AUTH] 모든 이메일 전송 시도 실패: $resetError');
                
                // Rate limit 계열 에러는 성공으로 처리
                if (resendError1.toString().contains('Email rate limit exceeded') || 
                    resendError1.toString().contains('Too many requests') ||
                    resendError1.toString().contains('user_repeated_signup')) {
                  print('⚠️ [SUPABASE_AUTH] Original error was rate limit - treating as success');
                  emailSent = true;
                  method = 'rate_limited_fallback';
                } else {
                  emailSent = false;
                  throw resendError1; // 원본 에러 전달
                }
              }
            }
          }
        }
      }
      
      if (emailSent) {
        print('🎉 [SUPABASE_AUTH] 이메일 재전송 성공! 방법: $method');
        
        if (method == 'password_reset_alternative') {
          print('📧 [SUPABASE_AUTH] 주의: 비밀번호 재설정 이메일로 대체됨');
        } else if (method.contains('rate_limited')) {
          print('📧 [SUPABASE_AUTH] 주의: Rate limit으로 인해 이전 이메일이 여전히 유효할 수 있음');
        }
      } else {
        print('❌ [SUPABASE_AUTH] 모든 이메일 전송 시도 실패');
      }
      
      print('📧 [SUPABASE_AUTH] ===== ENHANCED EMAIL RESEND END =====');
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Critical error in enhanced resend: $e');
      
      // Rate limit 관련 에러는 무시하고 성공으로 처리
      if (e.toString().contains('Email rate limit exceeded') || 
          e.toString().contains('Too many requests') ||
          e.toString().contains('user_repeated_signup')) {
        print('⚠️ [SUPABASE_AUTH] Rate limit or repeated signup, but treating as success');
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