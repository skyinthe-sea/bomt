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
import 'src/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: KakaoConfig.nativeAppKey);
  await SupabaseConfig.initialize();
  
  // Initialize localization dependencies
  final prefs = await SharedPreferences.getInstance();
  final localizationService = LocalizationService(prefs);
  final localizationRepository = LocalizationRepositoryImpl(localizationService);
  final changeLanguageUseCase = ChangeLanguageUseCase(localizationRepository);
  final localizationProvider = LocalizationProvider(changeLanguageUseCase);
  
  runApp(MyApp(
    localizationProvider: localizationProvider,
    prefs: prefs,
  ));
}

class MyApp extends StatefulWidget {
  final LocalizationProvider localizationProvider;
  final SharedPreferences prefs;
  
  const MyApp({
    super.key,
    required this.localizationProvider,
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
      listenable: widget.localizationProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'Baby One More Time',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: _initialRoute,
          onGenerateRoute: (settings) {
            // Pass localizationProvider to home route
            if (settings.name == AppRouter.homeRoute) {
              return AppRouter.generateRoute(
                RouteSettings(
                  name: settings.name,
                  arguments: widget.localizationProvider,
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
        );
      },
    );
  }
}