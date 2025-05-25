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
  
  // 자동로그인 설정 가져오기
  bool getAutoLogin() {
    return _prefs.getBool(_autoLoginKey) ?? false;
  }
  
  // 카카오 토큰 유효성 검사
  Future<bool> hasValidToken() async {
    try {
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      // 토큰이 유효하면 true
      return tokenInfo != null;
    } catch (e) {
      return false;
    }
  }
  
  // 현재 로그인된 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    try {
      if (await hasValidToken()) {
        return await UserApi.instance.me();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // 로그아웃 시 자동로그인 설정도 함께 제거
  Future<void> clearAutoLogin() async {
    await _prefs.remove(_autoLoginKey);
  }
}