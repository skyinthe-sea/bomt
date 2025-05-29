import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../../features/baby/presentation/screens/baby_register_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String babyRegisterRoute = '/baby-register';
  static const String settingsRoute = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
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
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}