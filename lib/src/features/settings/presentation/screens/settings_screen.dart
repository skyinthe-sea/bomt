import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          _buildBabyManagementSection(context, l10n),
          const SizedBox(height: 16),
          if (widget.themeProvider != null) ...[
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
                widget.themeProvider!.isDarkMode ? 'On' : 'Off',
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

  void _showAddBabyDialog(BuildContext context) {
    // Provider를 미리 가져오기
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (dialogContext) => _AddBabyDialog(babyProvider: babyProvider),
    );
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