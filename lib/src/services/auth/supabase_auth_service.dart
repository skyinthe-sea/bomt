import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum AuthProvider { email, google, facebook, kakao }

class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  static SupabaseAuthService get instance => _instance ??= SupabaseAuthService._();
  
  SupabaseAuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  // SharedPreferences keys
  static const String _autoLoginKey = 'auto_login_enabled';
  
  SharedPreferences? _prefs;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('🔧 [SUPABASE_AUTH] Initialized');
  }

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
        print('✅ [SUPABASE_AUTH] Email sign in successful');
      }
      
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Email sign in failed: $e');
      rethrow;
    }
  }

  /// 이메일 회원가입
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      print('📧 [SUPABASE_AUTH] Email sign up attempt for: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('✅ [SUPABASE_AUTH] Email sign up successful');
      }
      
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Email sign up failed: $e');
      rethrow;
    }
  }

  /// 구글 로그인
  Future<AuthResponse> signInWithGoogle() async {
    try {
      print('🔍 [SUPABASE_AUTH] Google sign in attempt');
      
      // Google 로그인 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      // Supabase에 Google OAuth로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        print('✅ [SUPABASE_AUTH] Google sign in successful');
      }
      
      return response;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Google sign in failed: $e');
      await _googleSignIn.signOut(); // 실패 시 정리
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

  /// 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      print('🔐 [SUPABASE_AUTH] Sending password reset email to: $email');
      
      await _supabase.auth.resetPasswordForEmail(email);
      
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
      
      // Google 로그아웃
      await _googleSignIn.signOut();
      
      // Facebook 로그아웃
      await FacebookAuth.instance.logOut();
      
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
      if (session != null && !session.isExpired) {
        print('✅ [SUPABASE_AUTH] Valid session found, auto login successful');
        return true;
      }

      print('⚠️ [SUPABASE_AUTH] No valid session found');
      return false;
    } catch (e) {
      print('❌ [SUPABASE_AUTH] Auto login failed: $e');
      return false;
    }
  }


  /// 오류 메시지 처리
  String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case 'Email not confirmed':
          return '이메일 인증이 필요합니다.';
        case 'User already registered':
          return '이미 가입된 이메일입니다.';
        case 'Password should be at least 6 characters':
          return '비밀번호는 6자 이상이어야 합니다.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}