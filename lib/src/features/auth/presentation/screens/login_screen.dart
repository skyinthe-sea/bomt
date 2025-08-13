import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../presentation/common_widgets/buttons/auth_button.dart';
import '../../../../presentation/common_widgets/dialogs/email_auth_dialog.dart';
import '../../../../presentation/common_widgets/dialogs/account_linking_dialog.dart';
import '../../../../presentation/common_widgets/dialogs/otp_verification_dialog.dart';
import '../../../../services/auth/account_linking_service.dart';
import '../../data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../services/auth/supabase_auth_service.dart';
import '../../../../services/auth/secure_auth_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../services/locale/device_locale_service.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../services/community/user_profile_service.dart';

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
  bool _isOtpPasswordResetInProgress = false; // 🔐 OTP 비밀번호 재설정 진행 중 플래그
  
  // 🔧 StreamSubscription 추가하여 dispose에서 정리
  StreamSubscription? _authStateSubscription;
  
  @override
  void initState() {
    super.initState();
    _isOtpPasswordResetInProgress = false; // 🔐 플래그 초기화
    _initializeServices();
    _initializeAutoLocale();
    _setupAuthStateListener();
  }
  
  /// 🔐 Auth state 변경 리스너 설정 (비밀번호 재설정 처리)
  void _setupAuthStateListener() {
    _authStateSubscription = _supabaseAuth.supabaseClient.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔐 [LOGIN] Password recovery detected');
        debugPrint('🔐 [LOGIN] OTP reset in progress: $_isOtpPasswordResetInProgress');
        debugPrint('🔐 [LOGIN] Session exists: ${session != null}');
        
        // 🚨 [보안 중요] OTP 비밀번호 재설정 중에는 절대로 자동 로그인하지 않음
        if (_isOtpPasswordResetInProgress) {
          debugPrint('🔐 [LOGIN] ⚠️  SECURITY: OTP password reset in progress - BLOCKING auto login');
          debugPrint('🔐 [LOGIN] ⚠️  SECURITY: All auth state changes during OTP verification are IGNORED');
          return; // 🔒 OTP 진행 중에는 모든 auth 이벤트 무시
        }
        
        if (session != null) {
          // 🔗 웹 기반 Magic Link 비밀번호 재설정에서 돌아온 경우만 자동 로그인
          debugPrint('🔐 [LOGIN] Web-based password recovery - auto login');
          _completeLogin();
        }
      }
    });
  }
  
  @override
  void dispose() {
    // 🔧 StreamSubscription 정리
    _authStateSubscription?.cancel();
    super.dispose();
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
      
      // LocalizationProvider가 사용 가능한지 안전하게 확인
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
      } on ProviderNotFoundException {
        debugPrint('ℹ️ [LOGIN] LocalizationProvider not found, using default locale');
        // Provider가 없어도 앱은 계속 실행 (한국어 기본값 사용)
      } catch (providerError) {
        debugPrint('⚠️ [LOGIN] LocalizationProvider error: $providerError');
        // 다른 Provider 에러가 발생해도 앱은 계속 실행
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
        final userId = user.id.toString();
        debugPrint('✅ [KAKAO_LOGIN] User logged in: $userId');

        // 🆔 Step 1: 카카오 사용자 프로필을 user_profiles에 바로 생성/업데이트
        try {
          debugPrint('👤 [KAKAO_LOGIN] Creating/updating user profile...');
          final adminClient = SupabaseConfig.adminClient;
          
          // 닉네임 생성 (카카오 닉네임 또는 기본값)
          String nickname = user.kakaoAccount?.profile?.nickname ?? '사용자${user.id.toString().substring(0, 5)}';
          final email = user.kakaoAccount?.email;
          final profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;
          
          debugPrint('👤 [KAKAO_LOGIN] Profile data: nickname=$nickname, email=$email');
          
          // user_profiles에 upsert (insert or update)
          await adminClient.from('user_profiles').upsert({
            'user_id': userId,
            'nickname': nickname,
            'email': email,
            'profile_image_url': profileImageUrl,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
          
          debugPrint('✅ [KAKAO_LOGIN] User profile created/updated successfully');
        } catch (profileError) {
          debugPrint('⚠️ [KAKAO_LOGIN] Profile creation failed (non-critical): $profileError');
          // 프로필 생성 실패해도 로그인은 계속 진행
        }

        // 🔐 Step 2: Kakao 세션 정보를 보안 저장소에 저장
        try {
          final secureAuthService = SecureAuthService.instance;
          await secureAuthService.initialize();
          
          if (await AuthApi.instance.hasToken()) {
            final tokenInfo = await UserApi.instance.accessTokenInfo();
            final token = await TokenManagerProvider.instance.manager.getToken();
            
            if (token?.accessToken != null) {
              await secureAuthService.saveLoginSession(
                provider: 'kakao',
                accessToken: token!.accessToken,
                refreshToken: token.refreshToken,
                userId: userId,
                expiresIn: Duration(seconds: tokenInfo.expiresIn ?? 3600),
              );
            }
          }
        } catch (e) {
          debugPrint('⚠️ [LOGIN] Failed to save Kakao session: $e');
        }
        
        try {
          await _completeLogin();
        } catch (e) {
          debugPrint('❌ [LOGIN] Kakao complete login error: $e');
          // 에러 발생 시 안전한 네비게이션 사용
          _safeNavigateToHome();
        }
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
        // 🚀 OTP 기반 회원가입 처리
        final response = await _supabaseAuth.signUpWithEmail(email, password);
        
        if (response.user != null) {
          Navigator.pop(context); // Close email dialog
          
          // 재활성화된 사용자인지 확인
          if (response.user!.appMetadata?['reactivated'] == true) {
            final message = response.user!.userMetadata?['message'] ?? '🎉 환영합니다! 계정이 재활성화되었습니다.';
            final action = response.user!.userMetadata?['action'] ?? '다시 로그인하여 BabyMom을 계속 이용해보세요.';
            
            // 🎉 바로 로그인 완료된 경우
            if (response.user!.appMetadata?['logged_in'] == true) {
              await _showWelcomeBackDialogWithLogin(message, action);
            }
            // 기타 재활성화 경우
            else {
              _showWelcomeBackDialog(message, action);
            }
          }
          // 🔐 OTP 전송되었을 때
          else if (response.user!.appMetadata?['signup_otp_sent'] == true) {
            final message = response.user!.userMetadata?['message'] ?? '인증 코드가 이메일로 전송되었습니다!';
            _showSuccess(message);
            
            // OTP 검증 다이얼로그 표시
            _showOtpVerificationDialog(email, password);
          }
          // 기존 호환성을 위한 fallback
          else if (response.user!.userMetadata?['email_sent'] == true) {
            final message = response.user!.userMetadata?['message'] ?? '이메일 인증이 완료되지 않았습니다. 새로운 인증 메일을 발송했습니다.';
            _showSuccess(message);
            _showEmailConfirmationDialog(email);
          }
          // 기본값
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
          debugPrint('✅ [EMAIL_LOGIN] Login successful, starting safe navigation...');
          
          // 🔄 안전한 네비게이션 직접 사용 (복잡한 _completeLogin 회피)
          if (mounted) {
            // 🔐 개선된 세션 저장 (SecureAuthService 포함)
            try {
              await _authService.setAutoLogin(_autoLoginEnabled);
              await _supabaseAuth.setAutoLogin(_autoLoginEnabled);
              
              // 🔐 SecureAuthService에도 세션 정보 저장 (자동로그인 호환성)
              if (_autoLoginEnabled) {
                final secureAuthService = SecureAuthService.instance;
                await secureAuthService.initialize();
                await secureAuthService.setAutoLoginEnabled(_autoLoginEnabled);
                
                final session = response.session;
                if (session != null) {
                  await secureAuthService.saveLoginSession(
                    provider: 'supabase',
                    accessToken: session.accessToken,
                    refreshToken: session.refreshToken,
                    userId: response.user!.id,
                    expiresIn: Duration(seconds: session.expiresIn ?? 3600),
                  );
                  debugPrint('✅ [EMAIL_LOGIN] Supabase session saved to SecureAuthService');
                }
              }
              
              debugPrint('✅ [EMAIL_LOGIN] All session settings saved');
            } catch (e) {
              debugPrint('⚠️ [EMAIL_LOGIN] Session save error: $e');
              // 세션 저장 실패해도 로그인은 진행
            }
            
            // 🚪 다이얼로그 닫고 홈으로 안전하게 이동
            _safeNavigateToHome();
          }
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
        // 🔐 Google 세션 정보를 보안 저장소에 저장
        try {
          final secureAuthService = SecureAuthService.instance;
          await secureAuthService.initialize();
          
          final googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            clientId: '373535971104-ktelo9crh5vg7kjpfhaq586oufbcab1e.apps.googleusercontent.com',
          );
          
          final currentUser = googleSignIn.currentUser;
          if (currentUser != null) {
            final auth = await currentUser.authentication;
            if (auth.accessToken != null) {
              await secureAuthService.saveLoginSession(
                provider: 'google',
                accessToken: auth.accessToken!,
                refreshToken: auth.idToken,
                userId: currentUser.id,
                expiresIn: const Duration(hours: 1), // Google 토큰은 보통 1시간
              );
            }
          }
        } catch (e) {
          debugPrint('⚠️ [LOGIN] Failed to save Google session: $e');
        }
        
        try {
          await _completeLogin();
        } catch (e) {
          debugPrint('❌ [LOGIN] Google complete login error: $e');
          // 에러 발생 시 안전한 네비게이션 사용
          _safeNavigateToHome();
        }
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
        // 🔐 Facebook 세션 정보를 보안 저장소에 저장
        try {
          final secureAuthService = SecureAuthService.instance;
          await secureAuthService.initialize();
          
          final accessToken = await FacebookAuth.instance.accessToken;
          if (accessToken != null) {
            await secureAuthService.saveLoginSession(
              provider: 'facebook',
              accessToken: accessToken.tokenString,
              expiresIn: const Duration(hours: 2), // Facebook 토큰 기본 만료 시간
            );
          }
        } catch (e) {
          debugPrint('⚠️ [LOGIN] Failed to save Facebook session: $e');
        }
        
        try {
          await _completeLogin();
        } catch (e) {
          debugPrint('❌ [LOGIN] Facebook complete login error: $e');
          // 에러 발생 시 안전한 네비게이션 사용
          _safeNavigateToHome();
        }
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
    try {
      // 🔐 개선된 보안 자동로그인 서비스 사용
      final secureAuthService = SecureAuthService.instance;
      await secureAuthService.initialize();
      
      // 자동로그인 설정 저장 (보안 저장소 사용)
      await secureAuthService.setAutoLoginEnabled(_autoLoginEnabled);
      
      // 기존 방식도 호환성을 위해 유지
      await _authService.setAutoLogin(_autoLoginEnabled);
      await _supabaseAuth.setAutoLogin(_autoLoginEnabled);
      
      // 현재 세션 정보를 보안 저장소에 저장
      final currentUser = _supabaseAuth.currentUser;
      if (currentUser != null) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          await secureAuthService.saveLoginSession(
            provider: 'supabase',
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            userId: currentUser.id,
            expiresIn: Duration(seconds: session.expiresIn ?? 3600),
          );
        }
      }
      
      // 🆔 사용자 프로필 확인 및 생성 (비밀번호 재설정 후 기존 데이터 연결)
      try {
        debugPrint('🔄 [LOGIN] Loading user profile...');
        final userProfileService = UserProfileService();
        final profile = await userProfileService.getOrCreateCurrentUserProfile();
        if (profile != null) {
          debugPrint('✅ [LOGIN] User profile loaded/created: ${profile.nickname}');
        } else {
          debugPrint('⚠️ [LOGIN] User profile is null - will create later');
        }
      } catch (e) {
        debugPrint('❌ [LOGIN] User profile error (non-critical): $e');
        // 🚫 프로필 에러는 사용자에게 표시하지 않음 (로그인 성공을 방해하지 않음)
        // 프로필은 나중에 홈 화면에서 다시 시도할 수 있음
      }
      
      debugPrint('✅ [LOGIN] Auto login settings and session saved securely');
      
      // 로그인 성공 시 메인 화면으로 이동
      if (mounted) {
        // 🔄 안전한 Navigator 스택 정리
        _safeNavigateToHome();
      }
    } catch (e) {
      debugPrint('❌ [LOGIN] Failed to save login session: $e');
      
      // 에러가 발생해도 기존 방식으로 계속 진행
      await _authService.setAutoLogin(_autoLoginEnabled);
      await _supabaseAuth.setAutoLogin(_autoLoginEnabled);
      
      if (mounted) {
        // 🔄 안전한 홈 화면 이동 (fallback 처리)
        _safeNavigateToHome();
      }
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
  
  /// 🔐 OTP 검증 다이얼로그 표시
  Future<void> _showOtpVerificationDialog(String email, String password) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationDialog(
        email: email,
        password: password,
        isLoading: _isEmailLoading,
        onVerify: _verifyOtpAndCompleteSignup,
        onResendOtp: _resendOtp,
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  
  /// 🔐 OTP 검증 및 회원가입 완료
  Future<void> _verifyOtpAndCompleteSignup(String email, String otpCode, String password) async {
    setState(() {
      _isEmailLoading = true;
    });

    try {
      debugPrint('🔐 [OTP_VERIFY] Starting OTP verification for: $email');
      
      final response = await _supabaseAuth.verifySignUpOTP(email, otpCode, password);
      
      if (response.user != null && response.session != null) {
        Navigator.pop(context); // Close OTP dialog
        
        debugPrint('🎉 [OTP_VERIFY] OTP verification successful!');
        
        // 회원가입 완료 성공 메시지
        final message = response.user!.userMetadata?['message'] ?? '🎉 회원가입이 완료되었습니다!';
        _showSuccess(message);
        
        // 자동 로그인 처리
        try {
          await _authService.setAutoLogin(_autoLoginEnabled);
          await _supabaseAuth.setAutoLogin(_autoLoginEnabled);
          
          if (_autoLoginEnabled) {
            final secureAuthService = SecureAuthService.instance;
            await secureAuthService.initialize();
            await secureAuthService.setAutoLoginEnabled(_autoLoginEnabled);
          }
          
          debugPrint('✅ [OTP_VERIFY] Auto login settings saved');
        } catch (settingsError) {
          debugPrint('⚠️ [OTP_VERIFY] Auto login settings error: $settingsError');
        }
        
        // 홈으로 이동
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else {
        _showError('인증에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      debugPrint('❌ [OTP_VERIFY] OTP verification failed: $e');
      final errorMessage = _supabaseAuth.getErrorMessage(e);
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isEmailLoading = false;
        });
      }
    }
  }
  
  /// 🔐 OTP 재전송
  Future<void> _resendOtp(String email) async {
    try {
      debugPrint('📧 [OTP_RESEND] Resending OTP for: $email');
      
      await _supabaseAuth.resendSignUpOTP(email);
      
      _showSuccess('인증 코드를 다시 전송했습니다.');
      debugPrint('✅ [OTP_RESEND] OTP resent successfully');
    } catch (e) {
      debugPrint('❌ [OTP_RESEND] Failed to resend OTP: $e');
      final errorMessage = _supabaseAuth.getErrorMessage(e);
      _showError(errorMessage.isNotEmpty ? errorMessage : '인증 코드 재전송에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 비밀번호 재설정 이메일 다이얼로그 (회원가입 시 fallback으로 사용)
  Future<void> _showPasswordResetEmailDialog(String email) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_reset,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '비밀번호 재설정 이메일',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$email 주소로 비밀번호 재설정 이메일을 발송했습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '회원가입이 완료되었습니다!\n이메일의 링크를 클릭하여 새 비밀번호를 설정하면 계정을 사용하실 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '이메일이 도착하지 않았다면 스팸 폴더를 확인해보세요.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
                await _supabaseAuth.resetPassword(email);
                _showSuccess('비밀번호 재설정 이메일을 다시 발송했습니다.');
              } catch (e) {
                _showError(_supabaseAuth.getErrorMessage(e));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
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
                  try {
                    _completeLogin();
                  } catch (e) {
                    debugPrint('❌ [LOGIN] Email confirmation complete login error: $e');
                    // 에러 발생 시 안전한 네비게이션 사용
                    _safeNavigateToHome();
                  }
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
            try {
              _completeLogin();
            } catch (e) {
              debugPrint('❌ [LOGIN] Account linking complete login error: $e');
              // 에러 발생 시 안전한 네비게이션 사용
              _safeNavigateToHome();
            }
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎨 Header with Icon and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '비밀번호 재설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 🎨 Description
              Text(
                '가입하신 이메일 주소를 입력하세요.\n6자리 인증번호를 보내드립니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 🎨 Modern Email Input Field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: '이메일 주소를 입력하세요',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white.withOpacity(0.5) : const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 🎨 Modern Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: isDarkMode 
                              ? Colors.white.withOpacity(0.1) 
                              : const Color(0xFFF3F4F6),
                          foregroundColor: isDarkMode 
                              ? Colors.white.withOpacity(0.8) 
                              : const Color(0xFF6B7280),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Send Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            Navigator.pop(context);
                            // OTP 방식으로 변경된 비밀번호 재설정 다이얼로그 표시
                            _showOtpPasswordResetDialog(email);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '전송',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎉 비밀번호 변경 성공 다이얼로그
  void _showPasswordChangeSuccessDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎉 성공 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 제목
              Text(
                '비밀번호 변경 완료!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 메시지
              Text(
                '비밀번호가 성공적으로 변경되었습니다.\n새로운 비밀번호로 다시 로그인해주세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 로그인하기 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '로그인하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔐 OTP 방식 비밀번호 재설정 다이얼로그
  Future<void> _showOtpPasswordResetDialog(String email) async {
    if (!mounted) return;
    
    // 🔐 OTP 비밀번호 재설정 시작
    setState(() {
      _isOtpPasswordResetInProgress = true;
    });
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpPasswordResetDialog(
        email: email,
        supabaseAuth: _supabaseAuth,
        onSuccess: () async {
          // 🔐 비밀번호 변경 성공 후 플래그 해제
          if (mounted) {
            setState(() {
              _isOtpPasswordResetInProgress = false;
            });
          }
          
          debugPrint('🎉 [PASSWORD_RESET] Password changed successfully');
          
          // 🚪 다이얼로그 닫기
          if (mounted) {
            Navigator.pop(context);
          }
          
          // 🎉 성공 다이얼로그 표시 (자동 로그인 대신 재로그인 안내)
          if (mounted) {
            _showPasswordChangeSuccessDialog();
          }
        },
        onError: (message) => _showError(message),
        onCancel: () {
          // 🔐 취소 시 플래그 해제
          setState(() {
            _isOtpPasswordResetInProgress = false;
          });
        },
      ),
    );
    
    // 🔐 다이얼로그 종료 후 플래그 해제 (안전장치)
    if (mounted) {
      setState(() {
        _isOtpPasswordResetInProgress = false;
      });
    }
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                  ],
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
                    
                    // 🎨 Simple Logo Section
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 🎨 App Title
                    Text(
                      'BabyMom',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 🎨 Subtitle
                    Text(
                      '아기 성장 기록을 손쉽게 관리하세요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.06),
                    
                    // 🎨 Simple Auth Buttons Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // 🎨 Email Login Button (최상단으로 이동)
                          _buildModernAuthButton(
                            onPressed: _handleEmailAuth,
                            isLoading: _isEmailLoading,
                            backgroundColor: const Color(0xFF6366F1),
                            icon: Icons.email_rounded,
                            text: '이메일로 계속하기',
                            textColor: Colors.white,
                          ),
                    
                          const SizedBox(height: 20),
                          
                          // 🎨 Simple Divider
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '또는',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode 
                                        ? Colors.white.withOpacity(0.5)
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
                          
                          const SizedBox(height: 20),
                          
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
                    
                          const SizedBox(height: 12),
                    
                          // 🎨 Google Login Button with Custom Google Icon (카카오 아래로 이동)
                          _buildGoogleAuthButton(
                            onPressed: _handleGoogleLogin,
                            isLoading: _isGoogleLoading,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 🎨 Simple Auto Login Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
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
                            activeColor: const Color(0xFF6366F1),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _autoLoginEnabled = !_autoLoginEnabled;
                              });
                            },
                            child: Text(
                              '자동 로그인',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode 
                                    ? Colors.white.withOpacity(0.8)
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // 🎨 Simple Terms Notice
                    Text(
                      '로그인 시 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.5)
                            : const Color(0xFF9CA3AF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
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
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null 
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  /// 🔄 안전한 홈 화면 이동
  void _safeNavigateToHome() {
    debugPrint('🏠 [LOGIN] Safe navigation to home starting...');
    
    try {
      // 🔄 단계별 안전한 네비게이션
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        
        try {
          // 🔄 모든 다이얼로그 닫기
          final navigator = Navigator.maybeOf(context);
          if (navigator != null) {
            int popCount = 0;
            while (navigator.canPop() && popCount < 5) {
              navigator.pop();
              popCount++;
            }
            debugPrint('🔄 [LOGIN] Closed $popCount dialogs');
          }
          
          // 🔄 홈 화면으로 안전한 이동 (Provider 정보 포함)
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              
              // 🔐 Provider 정보 가져오기 (현재 context에서 접근 가능한 Provider들)
              LocalizationProvider? localizationProvider;
              ThemeProvider? themeProvider;
              
              try {
                localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
              } catch (e) {
                debugPrint('⚠️ [LOGIN] LocalizationProvider not found: $e');
              }
              
              try {
                themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              } catch (e) {
                debugPrint('⚠️ [LOGIN] ThemeProvider not found: $e');
              }
              
              // 🏠 Provider 정보와 함께 홈으로 이동
              rootNavigator.pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
                arguments: {
                  'localizationProvider': localizationProvider,
                  'themeProvider': themeProvider,
                },
              );
              debugPrint('✅ [LOGIN] Successfully navigated to home with providers');
            }
          });
          
        } catch (navError) {
          debugPrint('❌ [LOGIN] Navigation error: $navError');
          // 에러 발생 시 직접 홈으로 이동
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        }
      });
      
    } catch (e) {
      debugPrint('❌ [LOGIN] Safe navigation error: $e');
      // 최후의 수단: 직접 홈으로 이동
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }
}

/// 🔐 OTP 방식 비밀번호 재설정 다이얼로그
class OtpPasswordResetDialog extends StatefulWidget {
  final String email;
  final dynamic supabaseAuth;
  final VoidCallback onSuccess;
  final Function(String) onError;
  final VoidCallback? onCancel;

  const OtpPasswordResetDialog({
    super.key,
    required this.email,
    required this.supabaseAuth,
    required this.onSuccess,
    required this.onError,
    this.onCancel,
  });

  @override
  State<OtpPasswordResetDialog> createState() => _OtpPasswordResetDialogState();
}

class _OtpPasswordResetDialogState extends State<OtpPasswordResetDialog> {
  int _currentStep = 0; // 0: 이메일 전송, 1: OTP 입력, 2: 새 비밀번호 입력
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 🔧 포커스 노드 추가 (키보드 타입 문제 해결용)
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // 🔧 포커스 노드 리스너 설정 (키보드 타입 강제 활성화)
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        debugPrint('🔧 [PASSWORD_RESET] Password field focused - ensuring text input mode');
      }
    });
    
    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        debugPrint('🔧 [PASSWORD_RESET] Confirm password field focused');
      }
    });
    
    _sendPasswordResetOtp();
  }
  
  @override
  void dispose() {
    // 🔧 리소스 정리
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
  
  /// 🔧 키보드 타입 강제 새로고침 (iOS 키보드 타입 문제 해결)
  void _forceKeyboardRefresh(FocusNode focusNode) async {
    debugPrint('🔧 [PASSWORD_RESET] Forcing keyboard refresh for text input');
    
    // 포커스를 잠깐 제거했다가 다시 주는 방식으로 키보드 새로고침
    focusNode.unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (mounted) {
      focusNode.requestFocus();
    }
  }

  /// 1️⃣ 비밀번호 재설정 OTP 전송
  Future<void> _sendPasswordResetOtp() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      await widget.supabaseAuth.resetPassword(widget.email);
      setState(() {
        _currentStep = 1;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
      widget.onError('OTP 전송에 실패했습니다: ${widget.supabaseAuth.getErrorMessage(e)}');
      if (mounted) Navigator.pop(context);
    }
  }

  /// 2️⃣ OTP 검증
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      widget.onError('6자리 인증번호를 입력해주세요.');
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      print('🔐 [OTP_VERIFY] Starting STRICT OTP verification...');
      print('🔐 [OTP_VERIFY] Email: ${widget.email}');
      print('🔐 [OTP_VERIFY] Token: $otp');
      
      // 🚨 [보안 중요] OTP 검증 과정에서 변수를 통한 성공 확인
      bool otpVerificationSuccessful = false;
      String successMethod = '';
      
      // 🔐 [보안 중요] 세션 존재 여부와 상관없이 반드시 OTP 검증을 수행해야 함
      final currentSession = widget.supabaseAuth.supabaseClient.auth.currentSession;
      print('🔐 [OTP_VERIFY] Current session status: ${currentSession != null ? 'EXISTS' : 'NULL'}');
      
      // ⚠️ 세션이 있어도 실제 OTP 토큰 검증을 반드시 수행
      print('🔐 [OTP_VERIFY] Performing MANDATORY OTP token verification...');
      
      // 🎯 Method 1: Try with recovery type (supabase_flutter 2.9.0 호환)
      print('🔐 [OTP_VERIFY] Method 1: Trying with OtpType.recovery...');
      try {
        final response = await widget.supabaseAuth.supabaseClient.auth.verifyOTP(
          email: widget.email,
          token: otp,
          type: OtpType.recovery,
        );

        print('🔐 [OTP_VERIFY] Recovery response: ${response.toString()}');
        print('🔐 [OTP_VERIFY] Response type: ${response.runtimeType}');

        // supabase_flutter 2.9.0에서는 AuthResponse 구조가 다름
        // 성공 시 session이 있고, 실패 시 exception이 발생
        if (response.session != null && response.user != null) {
          print('✅ [OTP_VERIFY] SUCCESS: Method 1 (recovery) verified OTP token');
          print('🔐 [OTP_VERIFY] Session: ${response.session.toString()}');
          print('🔐 [OTP_VERIFY] User: ${response.user.toString()}');
          otpVerificationSuccessful = true;
          successMethod = 'recovery';
        } else {
          print('❌ [OTP_VERIFY] Method 1 failed - no valid session/user returned');
        }
      } catch (recoveryError) {
        print('❌ [OTP_VERIFY] Method 1 (recovery) failed: $recoveryError');
      }

      // 🎯 Method 2: Try with email type only if Method 1 failed
      if (!otpVerificationSuccessful) {
        print('🔐 [OTP_VERIFY] Method 2: Trying with OtpType.email...');
        try {
          final response2 = await widget.supabaseAuth.supabaseClient.auth.verifyOTP(
            email: widget.email,
            token: otp,
            type: OtpType.email,
          );

          print('🔐 [OTP_VERIFY] Email response: ${response2.toString()}');

          if (response2.session != null && response2.user != null) {
            print('✅ [OTP_VERIFY] SUCCESS: Method 2 (email) verified OTP token');
            print('🔐 [OTP_VERIFY] Session: ${response2.session.toString()}');
            print('🔐 [OTP_VERIFY] User: ${response2.user.toString()}');
            otpVerificationSuccessful = true;
            successMethod = 'email';
          } else {
            print('❌ [OTP_VERIFY] Method 2 failed - no valid session/user returned');
          }
        } catch (emailError) {
          print('❌ [OTP_VERIFY] Method 2 (email) failed: $emailError');
        }
      }

      // 🎯 Method 3: Try token_hash approach only if previous methods failed
      if (!otpVerificationSuccessful) {
        print('🔐 [OTP_VERIFY] Method 3: Trying with token_hash approach...');
        try {
          final response3 = await widget.supabaseAuth.supabaseClient.auth.verifyOTP(
            tokenHash: otp,
            type: OtpType.recovery,
          );

          print('🔐 [OTP_VERIFY] TokenHash response: ${response3.toString()}');

          if (response3.session != null && response3.user != null) {
            print('✅ [OTP_VERIFY] SUCCESS: Method 3 (token_hash) verified OTP token');
            print('🔐 [OTP_VERIFY] Session: ${response3.session.toString()}');
            print('🔐 [OTP_VERIFY] User: ${response3.user.toString()}');
            otpVerificationSuccessful = true;
            successMethod = 'token_hash';
          } else {
            print('❌ [OTP_VERIFY] Method 3 failed - no valid session/user returned');
          }
        } catch (tokenHashError) {
          print('❌ [OTP_VERIFY] Method 3 (token_hash) failed: $tokenHashError');
        }
      }

      // 🚨 [보안 중요] 최종 검증: 실제로 OTP가 성공했는지 확인
      if (!otpVerificationSuccessful) {
        print('❌ [OTP_VERIFY] SECURITY: All verification methods failed for OTP: $otp');
        throw Exception('Invalid OTP code - all verification methods failed');
      }

      // ✅ OTP 검증 성공 - 다음 단계로 진행
      print('✅ [OTP_VERIFY] SECURITY: OTP verification successful with method: $successMethod');
      setState(() {
        _currentStep = 2;
        _isLoading = false;
      });
      
      // 🔧 비밀번호 입력 단계로 이동 시 지연된 포커스 (iOS 키보드 타입 문제 해결)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // 200ms 딜레이를 두고 포커스 - UI가 완전히 렌더링된 후
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            _passwordFocusNode.requestFocus();
            debugPrint('🔧 [PASSWORD_RESET] Delayed auto-focus for text input stability');
          }
        }
      });
      
      return;

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('❌ [OTP_VERIFY] All methods failed: $e');
      widget.onError('인증번호 검증에 실패했습니다.\n\n세부 정보:\n$e\n\n다시 시도하거나 새로운 코드를 요청해주세요.');
    }
  }

  /// 3️⃣ 새 비밀번호 설정
  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 🔐 비밀번호 검증 규칙
    if (password.length < 6) {
      widget.onError('비밀번호는 최소 6자 이상이어야 합니다.');
      return;
    }
    
    if (password.length > 128) {
      widget.onError('비밀번호는 128자 이하여야 합니다.');
      return;
    }

    // 영문+숫자 조합 체크 (선택사항 - 너무 엄격하면 주석 처리)
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    
    if (!hasLetter || !hasDigit) {
      widget.onError('비밀번호는 영문과 숫자를 모두 포함해야 합니다.');
      return;
    }

    if (password != confirmPassword) {
      widget.onError('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      print('🔐 [PASSWORD_UPDATE] Updating password...');
      final response = await widget.supabaseAuth.supabaseClient.auth.updateUser(
        UserAttributes(password: password),
      );

      print('🔐 [PASSWORD_UPDATE] Response: ${response.toString()}');
      print('🔐 [PASSWORD_UPDATE] Response type: ${response.runtimeType}');

      // supabase_flutter 2.9.0에서는 성공 시 user가 있고, 실패 시 exception 발생
      if (response.user != null) {
        print('✅ [PASSWORD_UPDATE] Password updated successfully');
        setState(() => _isLoading = false);
        
        if (mounted) {
          // 🚪 다이얼로그 닫기를 onSuccess 콜백에서 처리하도록 변경
          widget.onSuccess();
        }
      } else {
        print('❌ [PASSWORD_UPDATE] No user returned');
        throw Exception('Password update failed - no user returned');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('❌ [PASSWORD_UPDATE] Exception: $e');
      
      // 🔐 동일한 비밀번호 에러 처리
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('same as') || 
          errorMessage.contains('same password') ||
          errorMessage.contains('identical') ||
          errorMessage.contains('different from the old password') ||
          errorMessage.contains('should be different') ||
          errorMessage.contains('현재 비밀번호와 동일')) {
        // 🎨 동일한 비밀번호 전용 다이얼로그 표시
        if (mounted && context.mounted) {
          _showSamePasswordDialog(context);
        }
      } else {
        widget.onError('비밀번호 변경에 실패했습니다: ${widget.supabaseAuth.getErrorMessage(e)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎨 Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStepTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 🎨 Content
            if (_currentStep == 0) _buildSendingStep(),
            if (_currentStep == 1) _buildOtpStep(),
            if (_currentStep == 2) _buildPasswordStep(),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'OTP 전송 중...';
      case 1: return '인증번호 입력';
      case 2: return '새 비밀번호 설정';
      default: return '비밀번호 재설정';
    }
  }

  Widget _buildSendingStep() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFF6366F1)),
        const SizedBox(height: 16),
        Text(
          '${widget.email}로\n인증번호를 전송하고 있습니다...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          '${widget.email}로 전송된\n6자리 인증번호를 입력하세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // OTP 입력 필드
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.3) : const Color(0xFF9CA3AF),
                letterSpacing: 8,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 확인 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          '새로운 비밀번호를 설정하세요',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 새 비밀번호 입력
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.text, // 🔧 iOS 키보드 타입 문제 해결용
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.none,
            enableSuggestions: false,
            autocorrect: false,
            // 🔧 autofocus 제거 - 수동 포커스로 변경
            onTap: () {
              // 🔧 포커스 시 키보드 타입 강제 재초기화
              _forceKeyboardRefresh(_passwordFocusNode);
            },
            onSubmitted: (value) {
              // 🔧 Enter 키 시 다음 필드로 이동
              _confirmPasswordFocusNode.requestFocus();
            },
            decoration: InputDecoration(
              hintText: '새 비밀번호 (최소 6자, 영문+숫자)',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.5) : const Color(0xFF9CA3AF),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 비밀번호 확인 입력
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: !_isConfirmPasswordVisible,
            keyboardType: TextInputType.text, // 🔧 iOS 키보드 타입 문제 해결용
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.none,
            enableSuggestions: false,
            autocorrect: false,
            onTap: () {
              // 🔧 포커스 시 키보드 타입 강제 재초기화
              _forceKeyboardRefresh(_confirmPasswordFocusNode);
            },
            onSubmitted: (value) {
              // 🔧 Enter 키 시 비밀번호 변경 실행
              _updatePassword();
            },
            decoration: InputDecoration(
              hintText: '비밀번호 확인',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.5) : const Color(0xFF9CA3AF),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 변경 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '비밀번호 변경',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
  
  /// 🎨 동일한 비밀번호 입력 시 전용 다이얼로그
  void _showSamePasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🚫 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 30,
                  color: Colors.orange,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 제목
              Text(
                '동일한 비밀번호입니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 메시지
              Text(
                '현재 사용 중인 비밀번호와 다른\n새로운 비밀번호를 입력해주세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 확인 버튼
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

