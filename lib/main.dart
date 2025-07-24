import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'src/core/config/kakao_config.dart';
import 'src/core/config/supabase_config.dart';
import 'src/presentation/router/app_router.dart';
import 'src/services/localization/localization_service.dart';
import 'src/data/repositories/localization_repository_impl.dart';
import 'src/domain/use_cases/localization/change_language_use_case.dart';
import 'src/presentation/providers/localization_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/services/auth/auth_service.dart';
import 'src/services/auth/supabase_auth_service.dart';
import 'src/services/theme/theme_service.dart';
import 'src/core/theme/app_theme.dart';
import 'src/services/alarm/feeding_alarm_service.dart';
import 'src/services/invitation/invitation_service.dart';
import 'src/services/update_check/update_check_service.dart';
import 'src/services/locale/device_locale_service.dart';
import 'src/services/auth/deep_link_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  KakaoSdk.init(nativeAppKey: KakaoConfig.nativeAppKey);
  await SupabaseConfig.initialize();
  await FeedingAlarmService.instance.initialize();
  
  // Initialize invitation system
  try {
    await InvitationService.instance.initialize();
    debugPrint('초대 시스템 초기화 완료');
  } catch (e) {
    debugPrint('초대 시스템 초기화 실패: $e');
    // 초대 시스템 실패해도 앱은 계속 실행
  }
  
  // Initialize update check service
  try {
    UpdateCheckService().initialize();
    debugPrint('업데이트 체크 서비스 초기화 완료');
  } catch (e) {
    debugPrint('업데이트 체크 서비스 초기화 실패: $e');
    // 업데이트 체크 실패해도 앱은 계속 실행
  }
  
  // Log device locale info for debugging
  DeviceLocaleService.instance.logDeviceInfo();
  
  // Initialize deep link handler
  try {
    await DeepLinkHandler.instance.initialize();
    debugPrint('딥링크 핸들러 초기화 완료');
  } catch (e) {
    debugPrint('딥링크 핸들러 초기화 실패: $e');
  }
  
  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  
  // Localization
  final localizationService = LocalizationService(prefs);
  final localizationRepository = LocalizationRepositoryImpl(localizationService);
  final changeLanguageUseCase = ChangeLanguageUseCase(localizationRepository);
  final localizationProvider = LocalizationProvider(changeLanguageUseCase);
  
  // Theme
  final themeService = ThemeService(prefs);
  final themeProvider = ThemeProvider(themeService);
  
  runApp(MyApp(
    localizationProvider: localizationProvider,
    themeProvider: themeProvider,
    prefs: prefs,
  ));
}

class MyApp extends StatefulWidget {
  final LocalizationProvider localizationProvider;
  final ThemeProvider themeProvider;
  final SharedPreferences prefs;
  
  const MyApp({
    super.key,
    required this.localizationProvider,
    required this.themeProvider,
    required this.prefs,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialRoute;
  
  @override
  void initState() {
    super.initState();
    _setupDeepLinkCallbacks();
    _checkAutoLogin();
  }

  void _setupDeepLinkCallbacks() {
    DeepLinkHandler.instance.setEmailConfirmationCallbacks(
      onSuccess: () {
        // 이메일 인증 성공 시 홈으로 이동
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.homeRoute,
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이메일 인증이 완료되었습니다!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onError: (error) {
        // 이메일 인증 실패 시 에러 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
  
  Future<void> _checkAutoLogin() async {
    try {
      final authService = AuthService(widget.prefs);
      
      // Navigator 상태 충돌을 방지하기 위해 지연을 추가
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 자동로그인이 활성화되어 있고 유효한 토큰이 있으면 홈화면으로
      if (authService.getAutoLogin() && await authService.hasValidToken()) {
        // Supabase 인증 상태도 확인
        final supabaseAuth = SupabaseAuthService.instance;
        await supabaseAuth.initialize();
        
        if (await supabaseAuth.tryAutoLogin()) {
          if (mounted) {
            setState(() {
              _initialRoute = AppRouter.homeRoute;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _initialRoute = AppRouter.loginRoute;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _initialRoute = AppRouter.loginRoute;
          });
        }
      }
    } catch (e) {
      debugPrint('Error during auto login check: $e');
      if (mounted) {
        setState(() {
          _initialRoute = AppRouter.loginRoute;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      // 초기 라우트 결정 중 로딩 화면
      return MaterialApp(
        title: 'BabyMom',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.themeProvider.themeMode,
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.themeProvider.isDarkMode
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFF8FAFC),
                  widget.themeProvider.isDarkMode
                      ? const Color(0xFF16213E)
                      : const Color(0xFFE2E8F0),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 모던한 로고
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF667EEA)
                              : const Color(0xFF764BA2),
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF764BA2)
                              : const Color(0xFF667EEA),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF667EEA)
                                  : const Color(0xFF764BA2))
                              .withOpacity(0.3),
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
                          size: 50,
                          color: Colors.white,
                        ),
                        Positioned(
                          bottom: 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.child_friendly,
                              size: 12,
                              color: Color(0xFF667EEA),
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '엄마와 아기의 특별한 순간들',
                    style: TextStyle(
                      fontSize: 16,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A2E))
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // 모던한 로딩 인디케이터
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF667EEA)
                            : const Color(0xFF764BA2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return ListenableBuilder(
      listenable: Listenable.merge([widget.localizationProvider, widget.themeProvider]),
      builder: (context, child) {
        return UpdateCheckService().wrapWithUpdateCheck(
          MaterialApp(
            title: 'BabyMom',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: widget.themeProvider.themeMode,
            initialRoute: _initialRoute,
            onGenerateRoute: (settings) {
              // Pass providers to home route
              if (settings.name == AppRouter.homeRoute) {
                return AppRouter.generateRoute(
                  RouteSettings(
                    name: settings.name,
                    arguments: {
                      'localizationProvider': widget.localizationProvider,
                      'themeProvider': widget.themeProvider,
                    },
                  ),
                );
              }
              return AppRouter.generateRoute(settings);
            },
            locale: widget.localizationProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}