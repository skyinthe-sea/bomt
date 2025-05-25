import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../presentation/common_widgets/buttons/kakao_login_button.dart';
import '../../data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final KakaoAuthRepository _authRepository = KakaoAuthRepository();
  late AuthService _authService;
  bool _isLoading = false;
  bool _autoLoginEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAuthService();
  }
  
  Future<void> _initializeAuthService() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    setState(() {
      _autoLoginEnabled = _authService.getAutoLogin();
    });
  }

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authRepository.signInWithKakao();
      if (user != null) {
        // 자동로그인 설정 저장
        await _authService.setAutoLogin(_autoLoginEnabled);
        
        // 로그인 성공 시 메인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // 로그인 실패 시 에러 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.loginFailed ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.loginError(e.toString()) ?? 'Login error: $e')),
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
              Text(
                AppLocalizations.of(context)?.appTagline ?? 'Easily manage your baby\'s growth records',
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
              const SizedBox(height: 8),
              // 자동로그인 체크박스
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _autoLoginEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoLoginEnabled = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoLoginEnabled = !_autoLoginEnabled;
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)?.autoLogin ?? 'Auto Login',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 추가 정보
              Text(
                AppLocalizations.of(context)?.termsNotice ?? 'By logging in, you agree to our Terms of Service and Privacy Policy',
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