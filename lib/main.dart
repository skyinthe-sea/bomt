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
import 'src/services/theme/theme_service.dart';
import 'src/core/theme/app_theme.dart';
import 'src/services/alarm/feeding_alarm_service.dart';
import 'src/services/invitation/invitation_service.dart';
import 'src/services/update_check/update_check_service.dart';
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
    _checkAutoLogin();
  }
  
  Future<void> _checkAutoLogin() async {
    final authService = AuthService(widget.prefs);
    
    // 자동로그인이 활성화되어 있고 유효한 토큰이 있으면 홈화면으로
    if (authService.getAutoLogin() && await authService.hasValidToken()) {
      setState(() {
        _initialRoute = AppRouter.homeRoute;
      });
    } else {
      setState(() {
        _initialRoute = AppRouter.loginRoute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      // 초기 라우트 결정 중 로딩 화면
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return ListenableBuilder(
      listenable: Listenable.merge([widget.localizationProvider, widget.themeProvider]),
      builder: (context, child) {
        return UpdateCheckService().wrapWithUpdateCheck(
          MaterialApp(
            title: 'Baby One More Time',
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