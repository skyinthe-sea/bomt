import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';  // 새로 추가
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'src/core/config/kakao_config.dart';
import 'src/core/config/supabase_config.dart';
import 'src/presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: KakaoConfig.nativeAppKey);
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby One More Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRouter.loginRoute,
      onGenerateRoute: AppRouter.generateRoute,
      // 한국어 지원 추가
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
    );
  }
}