import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

/// 🔐 보안 강화된 자동로그인 서비스 (2024년 베스트 프랙티스)
/// 
/// 주요 기능:
/// - Flutter Secure Storage로 토큰 암호화 저장
/// - 모든 로그인 방법 통합 관리
/// - 자동 토큰 갱신
/// - 토큰 회전(Rotation) 지원
class SecureAuthService {
  static SecureAuthService? _instance;
  static SecureAuthService get instance => _instance ??= SecureAuthService._();
  
  SecureAuthService._();

  // 🔐 보안 저장소 (iOS Keychain / Android KeyStore)
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // 🗝️ 저장소 키
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _loginProviderKey = 'login_provider';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  SharedPreferences? _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('🔐 [SECURE_AUTH] Initialized with secure storage');
  }

  /// 자동로그인 설정 가져오기
  Future<bool> getAutoLoginEnabled() async {
    try {
      final value = await _secureStorage.read(key: _autoLoginKey);
      return value == 'true' || value == null; // 🔧 null일 때 true 반환 (기본값)
    } catch (e) {
      print('⚠️ [SECURE_AUTH] Failed to read auto login setting: $e');
      // 폴백: SharedPreferences에서 읽기 (기본값 true)
      return _prefs?.getBool(_autoLoginKey) ?? true; // 🔧 기본값 true로 변경
    }
  }

  /// 자동로그인 설정
  Future<void> setAutoLoginEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _autoLoginKey, 
        value: enabled.toString(),
      );
      print('🔐 [SECURE_AUTH] Auto login set to: $enabled');
    } catch (e) {
      print('⚠️ [SECURE_AUTH] Failed to write auto login setting: $e');
      // 폴백: SharedPreferences에 저장
      await _prefs?.setBool(_autoLoginKey, enabled);
    }
  }

  /// 🎯 통합 자동로그인 시도
  Future<bool> tryAutoLogin() async {
    try {
      print('🔍 [SECURE_AUTH] Starting auto login attempt...');
      
      // 1. 자동로그인 설정 확인
      if (!await getAutoLoginEnabled()) {
        print('🚫 [SECURE_AUTH] Auto login disabled by user');
        return false;
      }

      // 2. 저장된 토큰 정보 확인
      final tokenInfo = await _getStoredTokenInfo();
      if (tokenInfo == null) {
        print('🚫 [SECURE_AUTH] No stored token info');
        return false;
      }

      // 3. 토큰 만료 확인 및 갱신
      if (await _isTokenExpired(tokenInfo)) {
        print('⏰ [SECURE_AUTH] Token expired, attempting refresh...');
        
        if (!await _refreshToken(tokenInfo)) {
          print('❌ [SECURE_AUTH] Token refresh failed');
          await _clearAllTokens();
          return false;
        }
        
        // 갱신된 토큰 정보 다시 가져오기
        final refreshedInfo = await _getStoredTokenInfo();
        if (refreshedInfo == null) {
          print('❌ [SECURE_AUTH] Failed to get refreshed token info');
          return false;
        }
        tokenInfo.addAll(refreshedInfo);
      }

      // 4. 로그인 제공자별 세션 검증
      final provider = tokenInfo['provider'] as String?;
      if (provider == null) {
        print('❌ [SECURE_AUTH] No provider information');
        return false;
      }

      final isValid = await _validateProviderSession(provider, tokenInfo);
      if (!isValid) {
        print('❌ [SECURE_AUTH] Provider session validation failed');
        await _clearAllTokens();
        return false;
      }

      print('✅ [SECURE_AUTH] Auto login successful with provider: $provider');
      return true;

    } catch (e) {
      print('❌ [SECURE_AUTH] Auto login failed: $e');
      await _clearAllTokens();
      return false;
    }
  }

  /// 🔐 로그인 성공 시 토큰 저장
  Future<void> saveLoginSession({
    required String provider,
    required String accessToken,
    String? refreshToken,
    String? userId,
    Duration? expiresIn,
  }) async {
    try {
      final now = DateTime.now();
      final expiry = expiresIn != null 
          ? now.add(expiresIn) 
          : now.add(const Duration(hours: 24)); // 기본 24시간

      final futures = <Future<void>>[
        _secureStorage.write(key: _loginProviderKey, value: provider),
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String()),
      ];

      if (refreshToken != null) {
        futures.add(_secureStorage.write(key: _refreshTokenKey, value: refreshToken));
      }

      if (userId != null) {
        futures.add(_secureStorage.write(key: _userIdKey, value: userId));
      }

      await Future.wait(futures);
      
      print('🔐 [SECURE_AUTH] Session saved for provider: $provider');
      print('🔐 [SECURE_AUTH] Token expires at: ${expiry.toIso8601String()}');
    } catch (e) {
      print('❌ [SECURE_AUTH] Failed to save login session: $e');
      rethrow;
    }
  }

  /// 저장된 토큰 정보 가져오기
  Future<Map<String, String>?> _getStoredTokenInfo() async {
    try {
      final results = await Future.wait([
        _secureStorage.read(key: _loginProviderKey),
        _secureStorage.read(key: _accessTokenKey),
        _secureStorage.read(key: _refreshTokenKey),
        _secureStorage.read(key: _tokenExpiryKey),
        _secureStorage.read(key: _userIdKey),
      ]);

      final provider = results[0];
      final accessToken = results[1];
      final refreshToken = results[2];
      final expiry = results[3];
      final userId = results[4];

      if (provider == null || accessToken == null) {
        return null;
      }

      return {
        'provider': provider,
        'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (expiry != null) 'expiry': expiry,
        if (userId != null) 'user_id': userId,
      };
    } catch (e) {
      print('❌ [SECURE_AUTH] Failed to get stored token info: $e');
      return null;
    }
  }

  /// 토큰 만료 확인
  Future<bool> _isTokenExpired(Map<String, String> tokenInfo) async {
    final expiryStr = tokenInfo['expiry'];
    if (expiryStr == null) {
      return true; // 만료 시간이 없으면 만료된 것으로 간주
    }

    try {
      final expiry = DateTime.parse(expiryStr);
      final now = DateTime.now();
      
      // 5분 전에 미리 갱신 (버퍼 시간)
      final isExpired = now.isAfter(expiry.subtract(const Duration(minutes: 5)));
      
      print('🕐 [SECURE_AUTH] Token expiry: $expiry');
      print('🕐 [SECURE_AUTH] Current time: $now');
      print('🕐 [SECURE_AUTH] Is expired: $isExpired');
      
      return isExpired;
    } catch (e) {
      print('❌ [SECURE_AUTH] Failed to parse expiry time: $e');
      return true;
    }
  }

  /// 토큰 갱신
  Future<bool> _refreshToken(Map<String, String> tokenInfo) async {
    final provider = tokenInfo['provider'];
    final refreshToken = tokenInfo['refresh_token'];

    print('🔄 [SECURE_AUTH] Refreshing token for provider: $provider');

    try {
      switch (provider) {
        case 'supabase':
          return await _refreshSupabaseToken();
        
        case 'google':
          return await _refreshGoogleToken();
        
        case 'facebook':
          return await _refreshFacebookToken();
        
        case 'kakao':
          return await _refreshKakaoToken();
        
        default:
          print('❌ [SECURE_AUTH] Unknown provider for refresh: $provider');
          return false;
      }
    } catch (e) {
      print('❌ [SECURE_AUTH] Token refresh failed for $provider: $e');
      return false;
    }
  }

  /// Supabase 토큰 갱신
  Future<bool> _refreshSupabaseToken() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session?.refreshToken != null) {
        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          await saveLoginSession(
            provider: 'supabase',
            accessToken: response.session!.accessToken,
            refreshToken: response.session!.refreshToken,
            userId: response.session!.user.id,
            expiresIn: Duration(seconds: response.session!.expiresIn ?? 3600),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ [SECURE_AUTH] Supabase token refresh failed: $e');
      return false;
    }
  }

  /// Google 토큰 갱신
  Future<bool> _refreshGoogleToken() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: '373535971104-ktelo9crh5vg7kjpfhaq586oufbcab1e.apps.googleusercontent.com',
      );

      final currentUser = await googleSignIn.signInSilently();
      if (currentUser != null) {
        final auth = await currentUser.authentication;
        if (auth.accessToken != null) {
          await saveLoginSession(
            provider: 'google',
            accessToken: auth.accessToken!,
            refreshToken: auth.idToken,
            userId: currentUser.id,
            expiresIn: const Duration(hours: 1), // Google 토큰은 보통 1시간
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ [SECURE_AUTH] Google token refresh failed: $e');
      return false;
    }
  }

  /// Facebook 토큰 갱신
  Future<bool> _refreshFacebookToken() async {
    try {
      final accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null) {
        await saveLoginSession(
          provider: 'facebook',
          accessToken: accessToken.tokenString,
          expiresIn: const Duration(hours: 2), // Facebook 기본 만료 시간
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [SECURE_AUTH] Facebook token refresh failed: $e');
      return false;
    }
  }

  /// Kakao 토큰 갱신
  Future<bool> _refreshKakaoToken() async {
    try {
      if (await AuthApi.instance.hasToken()) {
        final tokenInfo = await UserApi.instance.accessTokenInfo();
        if (tokenInfo.expiresIn != null && tokenInfo.expiresIn! > 300) { // 5분 이상 남음
          // 현재 토큰이 아직 유효한 경우
          await saveLoginSession(
            provider: 'kakao',
            accessToken: (await TokenManagerProvider.instance.manager.getToken())?.accessToken ?? '',
            userId: tokenInfo.id.toString(),
            expiresIn: Duration(seconds: tokenInfo.expiresIn ?? 3600),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ [SECURE_AUTH] Kakao token refresh failed: $e');
      return false;
    }
  }

  /// 제공자별 세션 검증
  Future<bool> _validateProviderSession(String provider, Map<String, String> tokenInfo) async {
    try {
      switch (provider) {
        case 'supabase':
          final session = _supabase.auth.currentSession;
          return session != null && !session.isExpired;
        
        case 'google':
          final googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            clientId: '373535971104-ktelo9crh5vg7kjpfhaq586oufbcab1e.apps.googleusercontent.com',
          );
          final currentUser = await googleSignIn.signInSilently();
          return currentUser != null;
        
        case 'facebook':
          final loginResult = await FacebookAuth.instance.accessToken;
          return loginResult != null;
        
        case 'kakao':
          return await AuthApi.instance.hasToken();
        
        default:
          return false;
      }
    } catch (e) {
      print('❌ [SECURE_AUTH] Session validation failed for $provider: $e');
      return false;
    }
  }

  /// 모든 토큰 삭제
  Future<void> _clearAllTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _loginProviderKey),
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _tokenExpiryKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _autoLoginKey),
      ]);
      print('🗑️ [SECURE_AUTH] All tokens cleared');
    } catch (e) {
      print('❌ [SECURE_AUTH] Failed to clear tokens: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // 현재 제공자 확인
      final tokenInfo = await _getStoredTokenInfo();
      final provider = tokenInfo?['provider'];

      // 제공자별 로그아웃
      if (provider != null) {
        switch (provider) {
          case 'supabase':
            await _supabase.auth.signOut();
            break;
          case 'google':
            final googleSignIn = GoogleSignIn();
            await googleSignIn.signOut();
            break;
          case 'facebook':
            await FacebookAuth.instance.logOut();
            break;
          case 'kakao':
            await UserApi.instance.logout();
            break;
        }
      }

      // 모든 저장된 토큰 삭제
      await _clearAllTokens();
      
      print('👋 [SECURE_AUTH] Sign out completed');
    } catch (e) {
      print('❌ [SECURE_AUTH] Sign out failed: $e');
      // 에러가 발생해도 토큰은 삭제
      await _clearAllTokens();
    }
  }

  /// 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final tokenInfo = await _getStoredTokenInfo();
      if (tokenInfo == null) return false;

      final provider = tokenInfo['provider'];
      if (provider == null) return false;

      return await _validateProviderSession(provider, tokenInfo);
    } catch (e) {
      print('❌ [SECURE_AUTH] Login status check failed: $e');
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final tokenInfo = await _getStoredTokenInfo();
      if (tokenInfo == null) return null;

      return {
        'provider': tokenInfo['provider'],
        'user_id': tokenInfo['user_id'],
        'access_token': tokenInfo['access_token'],
      };
    } catch (e) {
      print('❌ [SECURE_AUTH] Get user info failed: $e');
      return null;
    }
  }
}