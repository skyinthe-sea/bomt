import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

abstract class AuthRepository {
  Future<User?> signInWithKakao();
  Future<void> signOut();
}