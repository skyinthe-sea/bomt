import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../presentation/common_widgets/buttons/auth_button.dart';
import '../../../../presentation/common_widgets/dialogs/email_auth_dialog.dart';
import '../../data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../services/auth/supabase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final KakaoAuthRepository _authRepository = KakaoAuthRepository();
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService.instance;
  late AuthService _authService;
  bool _isKakaoLoading = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  bool _autoLoginEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    await _supabaseAuth.initialize();
    setState(() {
      _autoLoginEnabled = _authService.getAutoLogin();
    });
  }

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isKakaoLoading = true;
    });

    try {
      final user = await _authRepository.signInWithKakao();
      if (user != null) {
        await _completeLogin();
      } else {
        _showError(AppLocalizations.of(context)?.loginFailed ?? 'Login failed');
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)?.loginError(e.toString()) ?? 'Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isKakaoLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    await showDialog(
      context: context,
      builder: (context) => EmailAuthDialog(
        isLoading: _isEmailLoading,
        onSubmit: _performEmailAuth,
        onForgotPassword: () {
          Navigator.pop(context);
          _showForgotPasswordDialog();
        },
      ),
    );
  }

  Future<void> _performEmailAuth(String email, String password, [EmailAuthMode? mode]) async {
    setState(() {
      _isEmailLoading = true;
    });

    try {
      final response = mode == EmailAuthMode.signUp
          ? await _supabaseAuth.signUpWithEmail(email, password)
          : await _supabaseAuth.signInWithEmail(email, password);

      if (response.user != null) {
        Navigator.pop(context); // Close dialog
        await _completeLogin();
      } else {
        _showError(mode == EmailAuthMode.signUp ? '회원가입에 실패했습니다.' : '로그인에 실패했습니다.');
      }
    } catch (e) {
      _showError(_supabaseAuth.getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isEmailLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final response = await _supabaseAuth.signInWithGoogle();
      if (response.user != null) {
        await _completeLogin();
      } else {
        _showError('Google 로그인에 실패했습니다.');
      }
    } catch (e) {
      _showError(_supabaseAuth.getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      final response = await _supabaseAuth.signInWithFacebook();
      if (response.user != null) {
        await _completeLogin();
      } else {
        _showError('Facebook 로그인에 실패했습니다.');
      }
    } catch (e) {
      _showError(_supabaseAuth.getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
  }

  Future<void> _completeLogin() async {
    // 자동로그인 설정 저장
    await _authService.setAutoLogin(_autoLoginEnabled);
    await _supabaseAuth.setAutoLogin(_autoLoginEnabled);
    
    // 로그인 성공 시 메인 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 재설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('가입하신 이메일 주소를 입력하세요.\n비밀번호 재설정 링크를 보내드립니다.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _supabaseAuth.resetPassword(email);
                  Navigator.pop(context);
                  _showError('비밀번호 재설정 이메일을 발송했습니다.');
                } catch (e) {
                  _showError(_supabaseAuth.getErrorMessage(e));
                }
              }
            },
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [theme.colorScheme.surface, theme.colorScheme.background]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    
                    // 로고 섹션
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 65,
                            color: Colors.white,
                          ),
                          Positioned(
                            bottom: 15,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.child_friendly,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 앱 이름
                    Text(
                      'BabyMom',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 앱 소개 문구
                    Text(
                      AppLocalizations.of(context)?.appTagline ?? '아기의 성장 기록을 쉽게 관리하세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    
                    // 로그인 방법 안내
                    Text(
                      '로그인 방법을 선택해주세요',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 이메일 로그인 버튼
                    AuthButton(
                      type: AuthButtonType.email,
                      onPressed: _handleEmailAuth,
                      isLoading: _isEmailLoading,
                    ),
                    
                    // 구글 로그인 버튼
                    AuthButton(
                      type: AuthButtonType.google,
                      onPressed: _handleGoogleLogin,
                      isLoading: _isGoogleLoading,
                    ),
                    
                    // 페이스북 로그인 버튼
                    AuthButton(
                      type: AuthButtonType.facebook,
                      onPressed: _handleFacebookLogin,
                      isLoading: _isFacebookLoading,
                    ),
                    
                    // 구분선
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 카카오 로그인 버튼
                    AuthButton(
                      type: AuthButtonType.kakao,
                      onPressed: _handleKakaoLogin,
                      isLoading: _isKakaoLoading,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 자동로그인 체크박스
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _autoLoginEnabled,
                            onChanged: (value) {
                              setState(() {
                                _autoLoginEnabled = value ?? false;
                              });
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _autoLoginEnabled = !_autoLoginEnabled;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)?.autoLogin ?? '자동 로그인',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 이용약관 동의
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations.of(context)?.termsNotice ?? '로그인 시 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}