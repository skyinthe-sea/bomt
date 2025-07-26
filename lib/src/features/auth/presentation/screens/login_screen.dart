import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/common_widgets/buttons/auth_button.dart';
import '../../../../presentation/common_widgets/dialogs/email_auth_dialog.dart';
import '../../../../presentation/common_widgets/dialogs/account_linking_dialog.dart';
import '../../../../services/auth/account_linking_service.dart';
import '../../data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../services/auth/supabase_auth_service.dart';
import '../../../../services/locale/device_locale_service.dart';
import '../../../../presentation/providers/localization_provider.dart';

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
    _initializeAutoLocale();
  }
  
  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    await _supabaseAuth.initialize();
    setState(() {
      _autoLoginEnabled = _authService.getAutoLogin();
    });
  }

  /// 🌐 자동 로케일 감지 및 적용
  Future<void> _initializeAutoLocale() async {
    try {
      final deviceLocale = DeviceLocaleService.instance;
      
      // 디바이스 로케일 정보 로깅
      deviceLocale.logDeviceInfo();
      
      // LocalizationProvider가 사용 가능한지 확인
      try {
        final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
        final currentLocale = localizationProvider.currentLocale;
        
        // 디바이스 언어 코드를 기반으로 자동 설정
        final deviceLanguageCode = deviceLocale.languageCode;
        
        // 지원하는 언어인지 확인하고 설정
        if (_isSupportedLanguage(deviceLanguageCode) && 
            _shouldUpdateLocale(currentLocale, deviceLanguageCode)) {
          
          debugPrint('🌐 [LOGIN] Auto-applying locale: $deviceLanguageCode');
          await localizationProvider.changeLanguage(Locale(deviceLanguageCode));
        }
      } catch (providerError) {
        debugPrint('⚠️ [LOGIN] LocalizationProvider not available: $providerError');
        // Provider가 없어도 앱은 계속 실행 (한국어 기본값 사용)
      }
    } catch (e) {
      debugPrint('❌ [LOGIN] Auto locale detection failed: $e');
      // 에러가 발생해도 앱 실행은 계속
    }
  }

  /// 지원하는 언어인지 확인
  bool _isSupportedLanguage(String languageCode) {
    const supportedLanguages = ['ko', 'en', 'ja', 'zh'];
    return supportedLanguages.contains(languageCode);
  }

  /// 로케일을 업데이트해야 하는지 확인
  bool _shouldUpdateLocale(Locale currentLocale, String deviceLanguageCode) {
    // 현재 설정이 영어(기본값)이고 디바이스가 다른 언어인 경우 업데이트
    return currentLocale.languageCode == 'en' && deviceLanguageCode != 'en';
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
        if (mounted) {
          _showError(AppLocalizations.of(context)?.loginFailed ?? 'Login failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)?.loginError(e.toString()) ?? 'Login error: $e');
      }
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
      if (mode == EmailAuthMode.signUp) {
        // 회원가입 처리
        final response = await _supabaseAuth.signUpWithEmail(email, password);
        
        if (response.user != null) {
          Navigator.pop(context); // Close dialog
          
          // 재활성화된 사용자인지 확인
          if (response.user!.appMetadata?['reactivated'] == true) {
            final message = response.user!.userMetadata?['message'] ?? '🎉 환영합니다! 계정이 재활성화되었습니다.';
            final action = response.user!.userMetadata?['action'] ?? '다시 로그인하여 BabyMom을 계속 이용해보세요.';
            
            // 🎉 바로 로그인 완료된 경우
            if (response.user!.appMetadata?['logged_in'] == true) {
              // 환영 다이얼로그를 보여주고 확인 버튼 누르면 바로 홈으로
              await _showWelcomeBackDialogWithLogin(message, action);
            }
            // 비밀번호 재설정이 필요한 경우
            else if (response.user!.appMetadata?['password_reset_needed'] == true) {
              _showWelcomeBackDialog(message, action);
            }
            // 기타 재활성화 경우
            else {
              _showWelcomeBackDialog(message, action);
            }
          }
          // 이메일 인증 미완료 사용자인지 확인
          else if (response.user!.appMetadata?['email_sent'] == true) {
            final message = response.user!.userMetadata?['message'] ?? '이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.';
            _showSuccess(message);
            _showEmailConfirmationDialog(email);
          }
          // 일반 신규 가입
          else {
            _showSuccess('회원가입이 완료되었습니다.\n이메일을 확인하여 계정을 인증해주세요.');
            _showEmailConfirmationDialog(email);
          }
        } else {
          _showError('회원가입에 실패했습니다.');
        }
      } else {
        // 로그인 처리
        final response = await _supabaseAuth.signInWithEmail(email, password);
        
        if (response.user != null) {
          Navigator.pop(context); // Close dialog
          await _completeLogin();
        } else {
          _showError('로그인에 실패했습니다.');
        }
      }
    } catch (e) {
      final errorMessage = _supabaseAuth.getErrorMessage(e);
      
      // 🔍 이메일 인증 관련 에러 처리 개선
      if (errorMessage.contains('이메일 인증이 필요합니다') || 
          errorMessage.contains('Email not confirmed') ||
          errorMessage.contains('Email confirmation required')) {
        if (mounted) {
          Navigator.pop(context); // Close dialog
          _showSuccess('이메일 인증이 완료되지 않았습니다.\n새로운 인증 메일을 발송했습니다.');
          _showEmailConfirmationDialog(email);
        }
      } else if (errorMessage.contains('Invalid login credentials')) {
        if (mounted) {
          _showError('이메일 또는 비밀번호가 올바르지 않습니다.');
        }
      } else {
        if (mounted) {
          _showError(errorMessage);
        }
      }
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
        if (mounted) {
          _showError('Google 로그인에 실패했습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(_supabaseAuth.getErrorMessage(e));
      }
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
        if (mounted) {
          _showError('Facebook 로그인에 실패했습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(_supabaseAuth.getErrorMessage(e));
      }
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

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showEmailConfirmationDialog(String email) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('이메일 인증 필요'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.email_outlined,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '$email 주소로 인증 메일을 발송했습니다.\n\n이메일을 확인하고 인증 링크를 클릭해주세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '이메일이 도착하지 않았나요?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _supabaseAuth.resendEmailConfirmation(email);
                _showSuccess('인증 메일을 다시 발송했습니다.');
              } catch (e) {
                _showError(_supabaseAuth.getErrorMessage(e));
              }
            },
            child: const Text('메일 재전송'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWelcomeBackDialog(String message, String action) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 축하 애니메이션 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.8),
                    Colors.pink.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.celebration,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // 환영 메시지
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 액션 메시지
            Text(
              action,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '계속하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWelcomeBackDialogWithLogin(String message, String action) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 축하 애니메이션 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.8),
                    Colors.teal.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // 환영 메시지
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 액션 메시지
            Text(
              action,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 확인 버튼 - 바로 홈으로 이동
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _completeLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BabyMom 시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountLinkingDialog(String newEmail, String existingEmail) async {
    try {
      // 기존 계정 정보 조회
      final linkingService = AccountLinkingService.instance;
      final existingAccounts = await linkingService.findAccountsByEmail(existingEmail);
      
      if (existingAccounts.isEmpty) {
        _showError('기존 계정을 찾을 수 없습니다.');
        return;
      }
      
      final existingAccount = existingAccounts.first;
      
      // 계정 연결 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AccountLinkingDialog(
          newUserEmail: newEmail,
          existingAccount: existingAccount,
          onLinkingComplete: () {
            // 연결 완료 후 홈으로 이동
            _completeLogin();
          },
          onSkip: () {
            // 별도 계정으로 계속 진행 시 일반 회원가입 처리
            _showSuccess('별도 계정으로 가입됩니다.\n이메일을 확인하여 계정을 인증해주세요.');
            _showEmailConfirmationDialog(newEmail);
          },
        ),
      );
      
    } catch (e) {
      _showError('계정 연결 확인 중 오류가 발생했습니다: ${e.toString()}');
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
                  _showSuccess('비밀번호 재설정 이메일을 발송했습니다.');
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
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                    const Color(0xFF020617),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.08),
                    
                    // 🎨 Modern Logo Section
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFA855F7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 🎨 App Title
                    const Text(
                      'BabyMom',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 🎨 Subtitle
                    Text(
                      '아기 성장 기록을 손쉽게 관리하세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.08),
                    
                    // 🎨 Login Methods Title
                    Text(
                      '로그인 방법을 선택해주세요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode 
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 🎨 Modern Auth Buttons Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🎨 Email Login Button
                          _buildModernAuthButton(
                            onPressed: _handleEmailAuth,
                            isLoading: _isEmailLoading,
                            backgroundColor: const Color(0xFF6366F1),
                            icon: Icons.email_rounded,
                            text: '이메일로 계속하기',
                            textColor: Colors.white,
                          ),
                    
                          const SizedBox(height: 16),
                    
                          // 🎨 Google Login Button with Custom Google Icon 
                          _buildGoogleAuthButton(
                            onPressed: _handleGoogleLogin,
                            isLoading: _isGoogleLoading,
                          ),
                    
                          const SizedBox(height: 16),
                    
                          // 🎨 Facebook Login Button
                          _buildModernAuthButton(
                            onPressed: _handleFacebookLogin,
                            isLoading: _isFacebookLoading,
                            backgroundColor: const Color(0xFF1877F2),
                            icon: Icons.facebook_rounded,
                            text: 'Facebook으로 계속하기',
                            textColor: Colors.white,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 🎨 Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDarkMode 
                                      ? Colors.white.withOpacity(0.1)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '또는',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode 
                                        ? Colors.white.withOpacity(0.6)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDarkMode 
                                      ? Colors.white.withOpacity(0.1)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 🎨 Kakao Login Button
                          _buildModernAuthButton(
                            onPressed: _handleKakaoLogin,
                            isLoading: _isKakaoLoading,
                            backgroundColor: const Color(0xFFFFE812),
                            icon: Icons.chat_bubble_rounded,
                            text: '카카오로 계속하기',
                            textColor: const Color(0xFF1F2937),
                            iconColor: const Color(0xFF1F2937),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 🎨 Auto Login Toggle
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: _autoLoginEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _autoLoginEnabled = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _autoLoginEnabled = !_autoLoginEnabled;
                              });
                            },
                            child: Text(
                              '자동 로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode 
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.06),
                    
                    // 🎨 Terms Notice
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '로그인 시 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF9CA3AF),
                          height: 1.4,
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

  /// 🎨 Modern Auth Button Builder
  Widget _buildModernAuthButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required Color backgroundColor,
    required IconData icon,
    required String text,
    required Color textColor,
    Color? iconColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null 
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: iconColor ?? textColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 🎨 Google Auth Button with Authentic Google Logo
  Widget _buildGoogleAuthButton({
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🎨 Real Google Logo Image
                  Image.asset(
                    'assets/images/googlelogo.jpeg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google로 계속하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

