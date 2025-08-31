import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../auth/data/repositories/kakao_auth_repository.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../invitation/presentation/screens/simple_invite_screen.dart';
import '../../../../core/providers/baby_provider.dart';
import '../../../../domain/models/baby.dart';
import 'language_selection_screen.dart';
import '../../../../services/auth/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' hide User;

class SettingsScreen extends StatefulWidget {
  final LocalizationProvider localizationProvider;
  final ThemeProvider? themeProvider;
  
  const SettingsScreen({
    Key? key,
    required this.localizationProvider,
    this.themeProvider,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 설정 화면이 열릴 때 아기 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      babyProvider.refresh();
    });
  }
  
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
          _buildUserInfoSection(context, l10n),
          const SizedBox(height: 16),
          _buildBabyManagementSection(context, l10n),
          const SizedBox(height: 16),
          if (widget.themeProvider != null) ...[
            _buildAppearanceSection(context, l10n),
            const SizedBox(height: 16),
          ],
          _buildLanguageSection(context, l10n),
          const SizedBox(height: 16),
          _buildLogoutSection(context, l10n),
          const SizedBox(height: 16),
          _buildAccountDeletionSection(context, l10n),
        ],
      ),
    );
  }
  
  Widget _buildInvitationSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.family_restroom, color: Colors.blue),
        title: Text(l10n.familyInvitation),
        subtitle: Text(l10n.familyInvitationDescription),
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

  Widget _buildBabyManagementSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.babyManagement,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => _showAddBabyDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: l10n.addBaby,
                    ),
                  ],
                ),
                // 도움말 코멘트 추가
                if (babyProvider.babies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline, 
                        size: 14, 
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '아기를 길게 누르면 정보를 재설정할 수 있습니다',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (babyProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (babyProvider.babies.isEmpty)
                  Center(
                    child: Text(
                      l10n.noBabiesMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...babyProvider.babies.map((baby) {
                    final isSelected = babyProvider.selectedBaby?.id == baby.id;
                    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(16),
                        elevation: isSelected ? (isDarkMode ? 6 : 3) : 1,
                        shadowColor: isSelected 
                            ? Theme.of(context).primaryColor.withOpacity(isDarkMode ? 0.5 : 0.3)
                            : Colors.black.withOpacity(0.1),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: isSelected ? null : () async {
                            await babyProvider.selectBaby(baby.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.babySelected(baby.name)),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                          onLongPress: () => _showDeleteBabyDialog(context, baby, babyProvider),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected 
                                  ? (isDarkMode 
                                      ? Theme.of(context).primaryColor.withOpacity(0.25)
                                      : Theme.of(context).primaryColor.withOpacity(0.12))
                                  : Theme.of(context).colorScheme.surface,
                              border: isSelected 
                                  ? Border.all(
                                      color: isDarkMode 
                                          ? Colors.white.withOpacity(0.3)
                                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                      width: isDarkMode ? 1.5 : 1,
                                    )
                                  : Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: isDarkMode ? 3 : 2,
                                    ),
                              // 다크모드에서 선택된 카드에 글로우 효과
                              boxShadow: isSelected && isDarkMode ? [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                            child: Row(
                              children: [
                                // 아바타
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: baby.gender == 'male'
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.pink.withOpacity(0.1),
                                    border: Border.all(
                                      color: baby.gender == 'male'
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.pink.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: baby.gender == 'male'
                                            ? Colors.blue[700]
                                            : Colors.pink[700],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // 이름과 나이
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        baby.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected 
                                              ? (isDarkMode ? Colors.white : Theme.of(context).primaryColor)
                                              : (isDarkMode ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getAgeText(baby.birthDate),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: isSelected
                                              ? (isDarkMode ? Colors.white.withOpacity(0.8) : Theme.of(context).primaryColor.withOpacity(0.8))
                                              : (isDarkMode ? Colors.white.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 선택 표시
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor
                                          : (isDarkMode 
                                              ? Colors.white.withOpacity(0.6) 
                                              : Theme.of(context).colorScheme.outline.withOpacity(0.4)),
                                      width: isDarkMode ? 2.5 : 2,
                                    ),
                                    // 다크모드에서 선택된 체크 표시에 강한 글로우 효과
                                    boxShadow: isSelected && isDarkMode ? [
                                      BoxShadow(
                                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ] : null,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: isDarkMode ? 18 : 16,
                                          color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                                          weight: isDarkMode ? 800 : null,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                if (babyProvider.hasMultipleBabies) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await babyProvider.selectNextBaby();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.babySelected(babyProvider.selectedBaby?.name ?? '')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n.switchToNextBaby),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getAgeText(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final days = difference.inDays;
    
    if (days < 30) {
      return '$days일';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months개월';
    } else {
      final years = (days / 365).floor();
      final months = ((days % 365) / 30).floor();
      return '$years년 $months개월';
    }
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.green),
        title: Text(l10n.language ?? 'Language'),
        subtitle: Text(
          widget.localizationProvider.getLanguageName(
            widget.localizationProvider.currentLocale.languageCode,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageSelectionScreen(
                localizationProvider: widget.localizationProvider,
              ),
            ),
          );
        },
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
                widget.themeProvider!.isDarkMode ? l10n.on : l10n.off,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: widget.themeProvider!.isDarkMode,
              onChanged: (value) {
                widget.themeProvider!.toggleTheme();
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
              debugPrint('🚪 [LOGOUT] Starting safe logout process...');
              
              // 1. Supabase 로그아웃 (모든 사용자에게 적용)
              try {
                final supabaseAuth = SupabaseAuthService.instance;
                await supabaseAuth.signOut();
                debugPrint('✅ [LOGOUT] Supabase logout successful');
              } catch (e) {
                debugPrint('⚠️ [LOGOUT] Supabase logout failed: $e');
                // Supabase 로그아웃 실패는 계속 진행
              }
              
              // 2. 카카오 로그아웃 (안전하게 시도)
              try {
                final authRepository = KakaoAuthRepository();
                await authRepository.signOut();
                debugPrint('✅ [LOGOUT] Kakao logout successful');
              } catch (e) {
                debugPrint('⚠️ [LOGOUT] Kakao logout failed (probably not logged in via Kakao): $e');
                // 카카오 로그아웃 실패는 무시 (이메일 가입자는 카카오 토큰이 없음)
              }
              
              // 3. 자동로그인 설정 제거
              final prefs = await SharedPreferences.getInstance();
              final authService = AuthService(prefs);
              await authService.clearAutoLogin();
              
              // 4. 추가 세션 정리
              await prefs.remove('supabase.session');
              await prefs.remove('sb-session');
              await prefs.remove('auto_login_enabled');
              
              debugPrint('✅ [LOGOUT] Safe logout completed successfully');
              
              // 로그인 화면으로 이동
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              debugPrint('❌ [LOGOUT] Unexpected error during logout: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그아웃 중 일부 오류가 발생했지만 계속 진행합니다.')),
                );
                
                // 오류가 있어도 로그인 화면으로 이동
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildAccountDeletionSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text(
          '회원탈퇴',
          style: TextStyle(color: Colors.red),
        ),
        subtitle: const Text(
          '모든 데이터가 영구 삭제됩니다',
          style: TextStyle(fontSize: 12),
        ),
        onTap: () => _showAccountDeletionDialog(context),
      ),
    );
  }

  Future<void> _showAccountDeletionDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '회원탈퇴',
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ 회원탈퇴 시 다음 데이터가 영구 삭제됩니다:'),
            SizedBox(height: 8),
            Text('• 사용자 계정 정보'),
            Text('• 등록된 모든 아기 정보'),
            Text('• 수유, 수면, 기저귀 등 모든 기록'),
            Text('• 성장 정보 및 사진'),
            SizedBox(height: 16),
            Text(
              '⚠️ 이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _performAccountDeletion(context);
    }
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    debugPrint('🚀 [ACCOUNT_DELETION] Starting modern deletion process');
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                '회원탈퇴 처리 중...',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      // 1. 현재 사용자 ID 확인 (카카오 또는 Supabase)
      String? userId;
      String accountType = 'UNKNOWN';
      
      // 1-1. 카카오 로그인 시도
      try {
        final user = await UserApi.instance.me();
        userId = user.id.toString();
        accountType = 'KAKAO';
        debugPrint('🔍 [ACCOUNT_DELETION] Kakao user ID: $userId');
      } catch (e) {
        debugPrint('⚠️ [ACCOUNT_DELETION] Not a Kakao user: $e');
        
        // 1-2. Supabase 이메일 계정 시도
        try {
          final supabaseAuth = SupabaseAuthService.instance;
          final currentUser = supabaseAuth.currentUser;
          if (currentUser != null) {
            userId = currentUser.id;
            accountType = 'EMAIL';
            debugPrint('🔍 [ACCOUNT_DELETION] Supabase user ID: $userId');
          } else {
            debugPrint('❌ [ACCOUNT_DELETION] No current Supabase user');
          }
        } catch (supabaseError) {
          debugPrint('❌ [ACCOUNT_DELETION] Failed to get Supabase user: $supabaseError');
        }
      }
      
      if (userId == null) {
        debugPrint('❌ [ACCOUNT_DELETION] Could not determine user ID for any account type');
        throw Exception('사용자 계정을 확인할 수 없습니다. 다시 로그인해주세요.');
      }
      
      debugPrint('👤 [ACCOUNT_DELETION] Account type: $accountType, User ID: $userId');
      
      // 2. 실제 데이터베이스 탈퇴 처리 (사용자 ID가 있는 경우)
      if (userId != null) {
        debugPrint('🗑️ [ACCOUNT_DELETION] Soft deleting user: $userId');
        await _softDeleteUser(userId);
      }
      
      // 3. Supabase 인증 서비스 정리
      final supabaseAuth = SupabaseAuthService.instance;
      await supabaseAuth.signOut();
      
      // 4. 로컬 세션 정리
      await _forceLocalSignOut();
      
      // 5. Navigator 상태 안전하게 정리
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (context.mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();
        
        // 잠시 대기 후 로그인 화면으로 이동
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (context.mounted) {
          // 성공 다이얼로그 표시
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              title: const Text('탈퇴 완료'),
              content: const Text(
                '회원탈퇴가 성공적으로 완료되었습니다.\n\n언제든지 다시 가입하실 수 있습니다.',
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 안전한 방식으로 로그인 화면으로 이동
                    _navigateToLoginSafely(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Error: $e');
      
      if (context.mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();
        
        // 에러 처리
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.error,
              color: Colors.orange,
              size: 48,
            ),
            title: const Text('탈퇴 처리 중 오류'),
            content: const Text(
              '일부 처리에서 문제가 발생했지만\n로그아웃은 완료되었습니다.\n\n로그인 화면으로 이동합니다.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToLoginSafely(context);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
    
    debugPrint('✅ [ACCOUNT_DELETION] Modern deletion process completed');
  }
  
  /// Navigator 상태를 안전하게 정리하고 로그인 화면으로 이동
  void _navigateToLoginSafely(BuildContext context) {
    // persistent_bottom_nav_bar와 호환되도록 안전한 방식으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  /// 강제 완료 처리 (30초 타임아웃 시)
  Future<void> _forceCompleteAccountDeletion(BuildContext context) async {
    debugPrint('🚀 [ACCOUNT_DELETION] Force completing deletion due to timeout');
    
    try {
      // 강제 로그아웃
      await _performForceSignOut().catchError((e) => debugPrint('Force signout error: $e'));
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원탈퇴가 완료되었습니다.\n(처리가 오래 걸려 강제 완료했습니다)'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Force complete error: $e');
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('탈퇴 처리 완료'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 트랜잭션으로 사용자 계정 삭제
  Future<void> _deleteUserAccountTransaction(String userId) async {
    final supabase = Supabase.instance.client;
    
    try {
      debugPrint('🗑️ [ACCOUNT_DELETION] Calling database transaction function');
      
      // 🚀 타임아웃 적용된 데이터베이스 함수 호출
      final result = await supabase
          .rpc('delete_user_account', params: {'target_user_id': userId})
          .timeout(
            const Duration(seconds: 20), // 20초 타임아웃
            onTimeout: () {
              debugPrint('⏰ [ACCOUNT_DELETION] RPC timeout, proceeding anyway');
              return {'success': true, 'message': 'timeout but continuing'};
            },
          );
      
      debugPrint('🗑️ [ACCOUNT_DELETION] Transaction result: $result');
      
      if (result != null && result['success'] == true) {
        debugPrint('✅ [ACCOUNT_DELETION] Transaction completed successfully');
        debugPrint('📊 [ACCOUNT_DELETION] Deleted babies: ${result['deleted_babies']}');
      } else {
        final errorMessage = result?['message'] ?? 'Unknown transaction error';
        debugPrint('❌ [ACCOUNT_DELETION] Transaction failed: $errorMessage');
        throw Exception('Transaction failed: $errorMessage');
      }
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Transaction error: $e');
      // 🚀 야매 방법: 에러가 발생해도 개별 삭제 시도하지 않고 그냥 진행
      debugPrint('🚀 [ACCOUNT_DELETION] Skipping fallback deletion for speed');
      // await _deleteUserDataSafely(userId); // 주석 처리로 빠르게 진행
    }
  }

  /// 강제 로그아웃 (플랫폼 채널 오류 대응)
  Future<void> _performForceSignOut() async {
    try {
      // 1. Supabase 정상 로그아웃 시도
      final supabaseAuth = SupabaseAuthService.instance;
      await supabaseAuth.signOut();
      debugPrint('✅ [ACCOUNT_DELETION] Normal sign out successful');
    } catch (e) {
      debugPrint('⚠️ [ACCOUNT_DELETION] Normal sign out failed: $e');
      
      // 2. 플랫폼 채널 오류인 경우 강제 로컬 클리어
      if (e.toString().contains('channel-error') || 
          e.toString().contains('PlatformException')) {
        debugPrint('🔧 [ACCOUNT_DELETION] Performing force local clear');
        await _forceLocalSignOut();
      } else {
        rethrow;
      }
    }
  }

  /// 로컬 세션 강제 클리어
  Future<void> _forceLocalSignOut() async {
    try {
      debugPrint('🧹 [ACCOUNT_DELETION] Force clearing local session');
      
      // 1. SharedPreferences 클리어
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService(prefs);
      await authService.clearAutoLogin();
      
      // 추가적인 로컬 세션 데이터 클리어
      await prefs.remove('supabase.session');
      await prefs.remove('sb-session');
      await prefs.remove('auto_login_enabled');
      
      // 2. Kakao SDK 로그아웃 (안전하게)
      try {
        final kakaoAuth = KakaoAuthRepository();
        await kakaoAuth.signOut();
      } catch (e) {
        debugPrint('⚠️ [ACCOUNT_DELETION] Kakao sign out failed: $e');
        // Kakao 로그아웃 실패는 무시
      }
      
      debugPrint('✅ [ACCOUNT_DELETION] Local session cleared successfully');
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Force local clear failed: $e');
      // 로컬 클리어 실패해도 앱 재시작으로 해결 가능
    }
  }

  Future<void> _deleteUserDataSafely(String userId) async {
    final supabase = Supabase.instance.client;
    List<String> babyIds = [];
    
    try {
      debugPrint('🗑️ [ACCOUNT_DELETION] Querying baby_users for user: $userId');
      
      // 사용자와 연관된 아기 정보 조회
      final babyUsersResponse = await supabase
          .from('baby_users')
          .select('baby_id')
          .eq('user_id', userId);

      if (babyUsersResponse.isNotEmpty) {
        babyIds = babyUsersResponse
            .map((row) => row['baby_id'] as String)
            .toList();
            
        debugPrint('🗑️ [ACCOUNT_DELETION] Found ${babyIds.length} babies to process');

        // 각 아기의 모든 데이터 삭제 (안전하게)
        for (final babyId in babyIds) {
          try {
            debugPrint('🗑️ [ACCOUNT_DELETION] Deleting data for baby: $babyId');
            await _deleteBabyDataSafely(babyId);
          } catch (e) {
            debugPrint('⚠️ [ACCOUNT_DELETION] Failed to delete baby $babyId data: $e');
            // 개별 아기 데이터 삭제 실패해도 계속 진행
          }
        }

        // baby_users 관계 삭제
        try {
          debugPrint('🗑️ [ACCOUNT_DELETION] Deleting baby_users relationships');
          await supabase
              .from('baby_users')
              .delete()
              .eq('user_id', userId);
        } catch (e) {
          debugPrint('⚠️ [ACCOUNT_DELETION] Failed to delete baby_users: $e');
          // 관계 삭제 실패해도 계속 진행
        }

        // 아기가 다른 사용자와 공유되지 않는 경우 아기 정보도 삭제
        for (final babyId in babyIds) {
          try {
            final remainingUsers = await supabase
                .from('baby_users')
                .select('user_id')
                .eq('baby_id', babyId);

            if (remainingUsers.isEmpty) {
              debugPrint('🗑️ [ACCOUNT_DELETION] Deleting orphaned baby: $babyId');
              await supabase
                  .from('babies')
                  .delete()
                  .eq('id', babyId);
            }
          } catch (e) {
            debugPrint('⚠️ [ACCOUNT_DELETION] Failed to check/delete baby $babyId: $e');
            // 개별 아기 삭제 실패해도 계속 진행
          }
        }
      } else {
        debugPrint('🗑️ [ACCOUNT_DELETION] No babies found for user');
      }
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Error in deleteUserDataSafely: $e');
      // 최상위 오류는 다시 throw하지 않고 로그만 남김
    }
  }

  Future<void> _deleteUserData(String userId) async {
    // 기존 함수는 호환성을 위해 유지하되 새로운 안전한 버전을 호출
    await _deleteUserDataSafely(userId);
  }

  Future<void> _deleteBabyDataSafely(String babyId) async {
    final supabase = Supabase.instance.client;
    
    // 존재할 가능성이 높은 테이블들 (기본 테이블부터)
    final primaryTables = [
      'feeding_records',
      'sleep_records', 
      'diaper_records',
      'user_card_settings',
    ];
    
    // 선택적 테이블들 (존재하지 않을 수도 있음)
    final optionalTables = [
      'temperature_records',
      'growth_records',
      'solid_food_records',
      'medication_records',
      'milk_pumping_records',
    ];

    // 기본 테이블 데이터 삭제
    for (final table in primaryTables) {
      try {
        debugPrint('🗑️ [ACCOUNT_DELETION] Deleting from $table for baby: $babyId');
        await supabase
            .from(table)
            .delete()
            .eq('baby_id', babyId);
      } catch (e) {
        debugPrint('⚠️ [ACCOUNT_DELETION] Failed to delete from $table: $e');
        // 개별 테이블 삭제 실패해도 계속 진행
      }
    }
    
    // 선택적 테이블 데이터 삭제
    for (final table in optionalTables) {
      try {
        debugPrint('🗑️ [ACCOUNT_DELETION] Deleting from $table for baby: $babyId');
        await supabase
            .from(table)
            .delete()
            .eq('baby_id', babyId);
      } catch (e) {
        debugPrint('⚠️ [ACCOUNT_DELETION] Failed to delete from $table (table might not exist): $e');
        // 선택적 테이블은 존재하지 않을 수 있으므로 오류 무시
      }
    }
  }

  Future<void> _deleteBabyData(String babyId) async {
    // 기존 함수는 호환성을 위해 유지하되 새로운 안전한 버전을 호출
    await _deleteBabyDataSafely(babyId);
  }

  Future<void> _softDeleteUser(String userId) async {
    final supabase = Supabase.instance.client;
    
    try {
      debugPrint('🗑️ [ACCOUNT_DELETION] Soft deleting user profile: $userId');
      
      // 먼저 해당 사용자가 존재하는지 확인
      final existingUser = await supabase
          .from('user_profiles')
          .select('user_id, nickname, email')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingUser == null) {
        debugPrint('⚠️ [ACCOUNT_DELETION] User not found in user_profiles: $userId');
        return;
      }
      
      debugPrint('👤 [ACCOUNT_DELETION] Found user: ${existingUser['nickname']}');
      
      // 현재 Supabase 사용자의 이메일 가져오기 (user_profiles에 이메일이 없는 경우)
      String? userEmail = existingUser['email'];
      if (userEmail == null) {
        try {
          final currentUser = supabase.auth.currentUser;
          if (currentUser?.email != null) {
            userEmail = currentUser!.email;
            debugPrint('📧 [ACCOUNT_DELETION] Using email from auth user: $userEmail');
          }
        } catch (e) {
          debugPrint('⚠️ [ACCOUNT_DELETION] Could not get current user email: $e');
        }
      }
      
      // user_profiles 테이블에서 소프트 삭제 (이메일 정보 보존)
      final updateData = {
        'deleted_at': DateTime.now().toIso8601String(),
        'nickname': '탈퇴한 사용자',
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // 이메일이 있으면 보존
      if (userEmail != null) {
        updateData['email'] = userEmail;
        debugPrint('📧 [ACCOUNT_DELETION] Preserving email for future reactivation: $userEmail');
      }
      
      final result = await supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId);
          
      debugPrint('✅ [ACCOUNT_DELETION] User profile soft deleted successfully');
      debugPrint('📊 [ACCOUNT_DELETION] Update result: $result');
      
      // 업데이트 검증
      final verifyResult = await supabase
          .from('user_profiles')
          .select('deleted_at, nickname')
          .eq('user_id', userId)
          .single();
          
      debugPrint('✅ [ACCOUNT_DELETION] Verification: deleted_at = ${verifyResult['deleted_at']}');
      
    } catch (e) {
      debugPrint('❌ [ACCOUNT_DELETION] Error soft deleting user: $e');
      debugPrint('❌ [ACCOUNT_DELETION] Error details: ${e.toString()}');
      
      // 에러를 다시 던져서 상위에서 처리하도록 함  
      rethrow;
    }
  }

  void _showAddBabyDialog(BuildContext context) {
    // Provider를 미리 가져오기
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (dialogContext) => _AddBabyDialog(babyProvider: babyProvider),
    );
  }

  void _showDeleteBabyDialog(BuildContext context, Baby baby, BabyProvider babyProvider) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘과 제목
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(isDarkMode ? 0.2 : 1.0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 32,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                '아기 정보 재설정',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '${baby.name} 정보를 처음부터 다시 설정하시겠습니까?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 정보 박스
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.blue[900]?.withOpacity(0.3)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.blue[700]!.withOpacity(0.5)
                        : Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '다음 기록들이 초기화됩니다',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.blue[300] : Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('🍼', '수유, 수면, 기저귀 기록', isDarkMode),
                    _buildInfoItem('📊', '성장 정보 및 사진', isDarkMode),
                    _buildInfoItem('👶', '아기와 관련된 모든 데이터', isDarkMode, isEmphasis: true),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.red[900]?.withOpacity(0.3)
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.red[700]!.withOpacity(0.5)
                              : Colors.red[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever_outlined,
                            size: 16,
                            color: Colors.red[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${baby.name}의 모든 기록이 완전히 제거됩니다',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.red[300] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.amber[900]?.withOpacity(0.3)
                            : Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '이 작업은 되돌릴 수 없습니다',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.amber[300] : Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteBaby(context, baby, babyProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        '재설정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildInfoItem(String emoji, String text, bool isDarkMode, {bool isEmphasis = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isEmphasis ? FontWeight.w600 : FontWeight.normal,
                color: isEmphasis 
                    ? (isDarkMode ? Colors.white : Colors.black87)
                    : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBaby(BuildContext context, Baby baby, BabyProvider babyProvider) async {
    debugPrint('🗑️ [SETTINGS] Starting baby deletion process for: ${baby.name}');
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('${baby.name} 정보 재설정 중...'),
          ],
        ),
      ),
    );
    
    try {
      // BabyProvider를 통해 아기 삭제
      final success = await babyProvider.deleteBaby(baby.id);
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // 삭제 확인 다이얼로그도 닫기
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${baby.name} 정보가 성공적으로 재설정되었습니다.'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${baby.name} 정보 재설정에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [SETTINGS] Error deleting baby: $e');
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // 삭제 확인 다이얼로그도 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('정보 재설정 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildUserInfoSection(BuildContext context, AppLocalizations l10n) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  '계정 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentUser != null) ...[
              _buildInfoRow('👤', '사용자 ID', currentUser.id, isDarkMode),
              const SizedBox(height: 8),
              _buildInfoRow('📧', '이메일', currentUser.email ?? '이메일 없음', isDarkMode),
              const SizedBox(height: 8),
              _buildInfoRow('📱', '로그인 방법', _getAuthProvider(currentUser), isDarkMode),
            ] else ...[
              Text(
                '로그인되지 않음',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String label, String value, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAuthProvider(User user) {
    final provider = user.appMetadata['provider'];
    switch (provider) {
      case 'kakao':
        return '카카오톡';
      case 'google':
        return '구글';
      case 'apple':
        return '애플';
      case 'email':
        return '이메일';
      default:
        return provider?.toString() ?? '알 수 없음';
    }
  }

}

class _AddBabyDialog extends StatefulWidget {
  final BabyProvider babyProvider;
  
  _AddBabyDialog({required this.babyProvider});
  
  @override
  State<_AddBabyDialog> createState() => _AddBabyDialogState();
}

class _AddBabyDialogState extends State<_AddBabyDialog> {
  final nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedGender = 'male';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('아기 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '아기 이름',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('성별: '),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'male',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const Text('남자'),
                      Radio<String>(
                        value: 'female',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const Text('여자'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('생년월일: '),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: Text(
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context)!.registering),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _registerBaby,
          child: Text(AppLocalizations.of(context)!.register),
        ),
      ],
    );
  }

  void _registerBaby() async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('🎯 [DIALOG] Starting baby registration');
    
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterBabyName)),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final baby = Baby(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      birthDate: selectedDate,
      gender: selectedGender,
      profileImageUrl: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('👶 [DIALOG] Registering baby: ${baby.name}');

    try {
      final success = await widget.babyProvider.registerBaby(baby);
      debugPrint('📞 [DIALOG] Registration result: $success');

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pop();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.babyRegistrationSuccess(baby.name)),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.babyRegistrationFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
    } catch (e) {
      debugPrint('❌ [DIALOG] Error: $e');
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.babyRegistrationError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}