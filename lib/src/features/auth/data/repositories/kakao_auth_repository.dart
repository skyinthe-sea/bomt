import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../domain/repositories/auth_repository.dart';

class KakaoAuthRepository implements AuthRepository {
  @override
  Future<User?> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          await UserApi.instance.loginWithKakaoTalk();
          return await UserApi.instance.me();
        } catch (error) {
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            return await UserApi.instance.me();
          } catch (e) {
            return null;
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않은 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          return await UserApi.instance.me();
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }
}