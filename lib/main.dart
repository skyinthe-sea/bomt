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
  
  runApp(MyApp(localizationProvider: localizationProvider));
}

class MyApp extends StatelessWidget {
  final LocalizationProvider localizationProvider;
  
  const MyApp({super.key, required this.localizationProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localizationProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'Baby One More Time',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: AppRouter.loginRoute,
          onGenerateRoute: (settings) {
            // Pass localizationProvider to home route
            if (settings.name == AppRouter.homeRoute) {
              return AppRouter.generateRoute(
                RouteSettings(
                  name: settings.name,
                  arguments: localizationProvider,
                ),
              );
            }
            return AppRouter.generateRoute(settings);
          },
          locale: localizationProvider.currentLocale,
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