import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/baby_provider.dart';
import '../../../../domain/models/baby.dart';
import '../../../../services/invitation/simple_invite_service.dart';
import 'debug_info_screen.dart';

class SimpleInviteScreen extends StatefulWidget {
  const SimpleInviteScreen({Key? key}) : super(key: key);

  @override
  State<SimpleInviteScreen> createState() => _SimpleInviteScreenState();
}

class _SimpleInviteScreenState extends State<SimpleInviteScreen> {
  final SimpleInviteService _inviteService = SimpleInviteService.instance;
  final TextEditingController _inviteCodeController = TextEditingController();
  
  bool _isLoading = false;
  String? _generatedInviteCode;
  DateTime? _codeCreatedAt;
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _loadSavedInviteCode();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // 저장된 초대 코드 로드
  Future<void> _loadSavedInviteCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('current_invite_code');
    final savedCreatedAt = prefs.getString('invite_code_created_at');
    
    if (savedCode != null && savedCreatedAt != null) {
      final createdAt = DateTime.parse(savedCreatedAt);
      final expiresAt = createdAt.add(const Duration(minutes: 5));
      
      if (DateTime.now().isBefore(expiresAt)) {
        setState(() {
          _generatedInviteCode = savedCode;
          _codeCreatedAt = createdAt;
        });
        _startTimer();
      } else {
        // 만료된 코드 삭제
        await _clearSavedInviteCode();
        if (mounted) {
          _showErrorSnackBar('생성한 초대 코드가 만료되었습니다. 새로 생성해주세요.');
        }
      }
    }
  }

  // 초대 코드 저장
  Future<void> _saveInviteCode(String code, DateTime createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_invite_code', code);
    await prefs.setString('invite_code_created_at', createdAt.toIso8601String());
  }

  // 저장된 초대 코드 삭제
  Future<void> _clearSavedInviteCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_invite_code');
    await prefs.remove('invite_code_created_at');
  }

  // 타이머 시작
  void _startTimer() {
    if (_codeCreatedAt == null) return;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final expiresAt = _codeCreatedAt!.add(const Duration(minutes: 5));
      final remaining = expiresAt.difference(now);
      
      if (remaining.isNegative) {
        timer.cancel();
        setState(() {
          _generatedInviteCode = null;
          _codeCreatedAt = null;
          _remainingTime = null;
        });
        _clearSavedInviteCode();
        if (mounted) {
          _showErrorSnackBar('생성한 초대 코드가 만료되었습니다. 새로 생성해주세요.');
        }
      } else {
        setState(() {
          _remainingTime = remaining;
        });
      }
    });
  }

  // 초대 코드 생성
  Future<void> _generateInviteCode() async {
    final l10n = AppLocalizations.of(context)!;
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    
    // 먼저 BabyProvider를 새로고침하여 최신 정보 로드
    await babyProvider.loadBabyData();
    
    final userId = babyProvider.currentUserId;
    final babyId = babyProvider.currentBaby?.id;
    final babyName = babyProvider.currentBaby?.name ?? '우리 아기';
    
    debugPrint('🔍 초대 코드 생성 시도 - userId: $userId, babyId: $babyId, babyName: $babyName');
    
    if (userId == null || babyId == null) {
      // 개발/테스트용: 임시 아기 생성 제안
      final shouldCreateTestBaby = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.noBabyInfo),
          content: Text(l10n.noBabyInfoDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.create),
            ),
          ],
        ),
      );
      
      if (shouldCreateTestBaby == true) {
        await _createTestBaby();
        // 다시 시도
        await _generateInviteCode();
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 기존 활성 초대 코드가 있는지 확인
      final existingCode = await _inviteService.getActiveInviteCode(userId, babyId);
      
      setState(() => _isLoading = false);
      
      if (existingCode != null) {
        // 기존 코드가 있으면 경고 다이얼로그 표시
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.generateNewInviteCode),
            content: Text(l10n.replaceExistingCode),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.confirm),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        );
        
        if (shouldProceed != true) return;
      }
      
      setState(() => _isLoading = true);

      // 실제 초대 코드 생성
      final code = await _inviteService.createInviteCode(userId, babyId);
      final createdAt = DateTime.now();
      
      setState(() {
        _generatedInviteCode = code;
        _codeCreatedAt = createdAt;
      });

      // 코드 저장 및 타이머 시작
      await _saveInviteCode(code, createdAt);
      _startTimer();

      if (existingCode != null) {
        _showSuccessSnackBar('기존 코드가 만료되고 새로운 초대 코드가 생성되었습니다: $code');
      } else {
        _showSuccessSnackBar('초대 코드가 생성되었습니다: $code');
      }
      
    } catch (e) {
      debugPrint('❌ 초대 코드 생성 실패: $e');
      _showErrorSnackBar('초대 코드 생성 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 초대 코드로 참여
  Future<void> _joinWithInviteCode() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _inviteCodeController.text.trim().toUpperCase();
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    
    // 사용자 정보 새로고침 (실시간 카카오 API 호출)
    await babyProvider.loadBabyData();
    final userId = babyProvider.currentUserId;
    
    debugPrint('🔍 초대 코드 참여 시도 - code: $code, userId: $userId');
    
    if (code.isEmpty) {
      _showErrorSnackBar(l10n.pleaseEnterInviteCode);
      return;
    }

    if (code.length != 6) {
      _showErrorSnackBar(l10n.inviteCodeMustBe6Digits);
      return;
    }

    if (userId == null) {
      _showErrorSnackBar(l10n.pleaseLoginFirst);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 먼저 초대 코드 정보 확인 (실제 참여하지 않고 정보만 가져오기)
      final inviteInfo = await _inviteService.getInviteInfo(code);
      
      setState(() => _isLoading = false);
      
      // 경고 다이얼로그 표시
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.acceptInvitation),
          content: Text(
            l10n.acceptInvitationWarning(inviteInfo['babyName'] ?? '')
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      );
      
      if (shouldProceed != true) return;
      
      setState(() => _isLoading = true);
      
      // 실제 초대 코드로 참여
      final success = await _inviteService.joinWithInviteCode(code, userId);
      
      if (success) {
        _showSuccessSnackBar('초대를 수락했습니다! 새로운 아기와 함께 육아를 시작해보세요.');
        
        // BabyProvider 완전 새로고침
        await babyProvider.refresh();
        
        // 홈 화면으로 강제 이동하여 전체 앱 상태 새로고침
        if (mounted) {
          // 🔄 먼저 모든 다이얼로그 닫기
          try {
            while (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } catch (e) {
            debugPrint('⚠️ [SIMPLE_INVITE] Dialog cleanup warning: $e');
          }
          
          // 🔄 최상위 Navigator로 홈 화면 이동
          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            '/', // 홈 화면 라우트
            (Route<dynamic> route) => false, // 모든 이전 화면 제거
          );
        }
      }
      
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 초대 코드 복사
  void _copyInviteCode() {
    final l10n = AppLocalizations.of(context)!;
    if (_generatedInviteCode == null) return;
    
    Clipboard.setData(ClipboardData(text: _generatedInviteCode!));
    _showSuccessSnackBar(l10n.copiedToClipboard);
  }

  // 남은 시간을 포맷하여 반환
  String _formatRemainingTime() {
    final l10n = AppLocalizations.of(context)!;
    if (_remainingTime == null) return '';
    
    final minutes = _remainingTime!.inMinutes;
    final seconds = _remainingTime!.inSeconds % 60;
    return l10n.minutesAndSeconds(minutes, seconds);
  }

  // 테스트용 아기 생성
  Future<void> _createTestBaby() async {
    try {
      const uuid = Uuid();
      final testBaby = Baby(
        id: uuid.v4(),
        name: '테스트 아기',
        birthDate: DateTime.now().subtract(const Duration(days: 30)),
        gender: 'other',
        profileImageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final success = await babyProvider.registerBaby(testBaby);
      
      if (success) {
        _showSuccessSnackBar('테스트용 아기가 생성되었습니다!');
      } else {
        _showErrorSnackBar('아기 생성에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('아기 생성 중 오류가 발생했습니다: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final babyProvider = Provider.of<BabyProvider>(context);
    final babyName = babyProvider.currentBaby?.name ?? l10n.babyName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyInvitation),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugInfoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 섹션
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.careTogetherWith(babyName),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.inviteFamilyDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blueGrey[200]
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 초대 코드 생성 섹션
            Text(
              l10n.generateInviteCode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey[600]!.withValues(alpha: 0.5)
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blueGrey[800]?.withValues(alpha: 0.3)
                    : Colors.white,
              ),
              child: Column(
                children: [
                  Text(
                    l10n.generateInviteCodeDescription,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blueGrey[200]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_generatedInviteCode != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[900]!.withValues(alpha: 0.3)
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.green[400]!
                              : Colors.green[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[400]
                                    : Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.inviteCodeGenerated,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.green[400]
                                      : Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _generatedInviteCode!,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.blueGrey[200]
                                      : Colors.grey[700],
                                ),
                                onPressed: _copyInviteCode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.orange[400]
                                    : Colors.orange[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _remainingTime != null
                                    ? l10n.remainingTime(_formatRemainingTime())
                                    : l10n.validTime,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.orange[400]
                                      : Colors.orange[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateInviteCode,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.qr_code),
                      label: Text(_isLoading ? l10n.generating : l10n.generateInviteCodeButton),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 구분선
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey[600]?.withValues(alpha: 0.4)
                        : Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.orText,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blueGrey[300]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey[600]?.withValues(alpha: 0.4)
                        : Colors.grey[300],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 초대 코드 입력 섹션
            Text(
              l10n.joinWithInviteCode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey[600]!.withValues(alpha: 0.5)
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blueGrey[800]?.withValues(alpha: 0.3)
                    : Colors.white,
              ),
              child: Column(
                children: [
                  Text(
                    l10n.enterInviteCodeDescription,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blueGrey[200]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      labelText: l10n.inviteCodePlaceholder,
                      hintText: 'ABC123',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _joinWithInviteCode,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(_isLoading ? l10n.joining : l10n.acceptInvite),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}