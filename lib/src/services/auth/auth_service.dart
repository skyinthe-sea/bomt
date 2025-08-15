import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class AuthService {
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _kakaoTokenKey = 'kakao_access_token';
  
  final SharedPreferences _prefs;
  
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
      final tokenInfo = await UserApi.instance.accessTokenInfo();
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
  Future<User?> getCurrentUser() async {
    print('DEBUG: AuthService.getCurrentUser() 시작');
    try {
      print('DEBUG: 토큰 유효성 확인 중...');
      final hasToken = await hasValidToken();
      print('DEBUG: hasValidToken 결과: $hasToken');
      
      if (hasToken) {
        print('DEBUG: UserApi.instance.me() 호출 중...');
        final user = await UserApi.instance.me();
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
  
  // 로그아웃 시 자동로그인 설정도 함께 제거
  Future<void> clearAutoLogin() async {
    await _prefs.remove(_autoLoginKey);
  }
}