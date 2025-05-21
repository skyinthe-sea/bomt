import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../../../presentation/common_widgets/buttons/kakao_login_button.dart';
import '../../data/repositories/kakao_auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final KakaoAuthRepository _authRepository = KakaoAuthRepository();
  bool _isLoading = false;

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authRepository.signInWithKakao();
      if (user != null) {
        // 로그인 성공 시 메인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // 로그인 실패 시 에러 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고나 이미지
              const Icon(
                Icons.child_care,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              // 앱 이름
              const Text(
                'Baby One More Time',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              // 앱 소개 문구
              const Text(
                '아기 성장 기록을 손쉽게 관리하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 카카오 로그인 버튼
              KakaoLoginButton(
                onPressed: _handleKakaoLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              // 추가 정보
              const Text(
                '로그인하면 서비스 이용약관 및 개인정보 처리방침에 동의하게 됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}