import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../../features/baby/presentation/screens/baby_register_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/growth/presentation/screens/growth_chart_screen.dart';
import '../../domain/models/baby.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String babyRegisterRoute = '/baby-register';
  static const String settingsRoute = '/settings';
  static const String growthChartRoute = '/growth-chart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final localizationProvider = args?['localizationProvider'] as LocalizationProvider?;
        final themeProvider = args?['themeProvider'] as ThemeProvider?;
        
        if (localizationProvider != null) {
          // 두 Provider 모두 제공
          return MaterialPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider<LocalizationProvider>.value(
                  value: localizationProvider,
                ),
                if (themeProvider != null)
                  ChangeNotifierProvider<ThemeProvider>.value(
                    value: themeProvider,
                  ),
              ],
              child: const LoginScreen(),
            ),
          );
        } else {
          // Fallback - Provider 없이도 안전하게 실행
          debugPrint('⚠️ [APP_ROUTER] LoginScreen called without LocalizationProvider');
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      case homeRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MainScreen(
            localizationProvider: args?['localizationProvider'] as LocalizationProvider?,
            themeProvider: args?['themeProvider'] as ThemeProvider?,
          ),
        );
      case babyRegisterRoute:
        return MaterialPageRoute(builder: (_) => const BabyRegisterScreen());
      case settingsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(
            localizationProvider: args?['localizationProvider'] as LocalizationProvider,
            themeProvider: args?['themeProvider'] as ThemeProvider?,
          ),
        );
      case growthChartRoute:
        final baby = settings.arguments as Baby;
        return MaterialPageRoute(
          builder: (_) => GrowthChartScreen(baby: baby),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}