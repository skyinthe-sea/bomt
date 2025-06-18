import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../auth/data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../invitation/presentation/screens/simple_invite_screen.dart';

class SettingsScreen extends StatelessWidget {
  final LocalizationProvider localizationProvider;
  final ThemeProvider? themeProvider;
  
  const SettingsScreen({
    Key? key,
    required this.localizationProvider,
    this.themeProvider,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings ?? 'Settings'),
      ),
      body: ListView(
        children: [
          _buildInvitationSection(context, l10n),
          const SizedBox(height: 16),
          if (themeProvider != null) ...[
            _buildAppearanceSection(context, l10n),
            const SizedBox(height: 16),
          ],
          _buildLanguageSection(context, l10n),
          const SizedBox(height: 16),
          _buildLogoutSection(context, l10n),
        ],
      ),
    );
  }
  
  Widget _buildInvitationSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.family_restroom, color: Colors.blue),
        title: const Text('가족 초대'),
        subtitle: const Text('초대 코드로 가족과 함께 육아 기록을 관리하세요'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SimpleInviteScreen(),
            ),
          );
        },
      ),
    );
  }


  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language ?? 'Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...localizationProvider.supportedLocales.map((locale) {
              final isSelected = localizationProvider.currentLocale.languageCode == locale.languageCode;
              return RadioListTile<String>(
                title: Text(
                  localizationProvider.getLanguageName(locale.languageCode),
                ),
                value: locale.languageCode,
                groupValue: localizationProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localizationProvider.changeLanguage(Locale(value));
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appearance,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: Text(
                themeProvider!.isDarkMode ? 'On' : 'Off',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: themeProvider!.isDarkMode,
              onChanged: (value) {
                themeProvider!.toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text(
          l10n.logout ?? 'Logout',
          style: const TextStyle(color: Colors.red),
        ),
        onTap: () async {
          // 로그아웃 확인 다이얼로그
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.logout ?? 'Logout'),
              content: Text(l10n.logoutConfirm ?? 'Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.no ?? 'No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    l10n.yes ?? 'Yes',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            try {
              // 로그아웃 처리
              final authRepository = KakaoAuthRepository();
              await authRepository.signOut();
              
              // 자동로그인 설정 제거
              final prefs = await SharedPreferences.getInstance();
              final authService = AuthService(prefs);
              await authService.clearAutoLogin();
              
              // 로그인 화면으로 이동
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            }
          }
        },
      ),
    );
  }
}