import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/models/invitation.dart';
import '../../../../services/invitation/invitation_service.dart';
import '../../../../core/providers/baby_provider.dart';

class CreateInvitationScreen extends StatefulWidget {
  const CreateInvitationScreen({Key? key}) : super(key: key);

  @override
  State<CreateInvitationScreen> createState() => _CreateInvitationScreenState();
}

class _CreateInvitationScreenState extends State<CreateInvitationScreen> {
  final InvitationService _invitationService = InvitationService.instance;
  
  InvitationRole _selectedRole = InvitationRole.parent;
  Duration _selectedDuration = const Duration(days: 7);
  bool _isLoading = false;
  String? _currentUserId;
  String? _currentBabyId;

  final List<Duration> _durationOptions = [
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(days: 1),
    const Duration(days: 3),
    const Duration(days: 7),
    const Duration(days: 14),
    const Duration(days: 30),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _updateUserData(BabyProvider babyProvider) {
    final newUserId = babyProvider.currentUserId;
    final newBabyId = babyProvider.currentBaby?.id;
    
    if (_currentUserId != newUserId || _currentBabyId != newBabyId) {
      _currentUserId = newUserId;
      _currentBabyId = newBabyId;
      
      if (_currentUserId == null || _currentBabyId == null) {
        debugPrint('사용자 또는 아기 정보가 없습니다. userId: $_currentUserId, babyId: $_currentBabyId');
      }
    }
  }

  Future<void> _createInvitation() async {
    // 실시간으로 사용자 정보 다시 확인
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    _currentUserId = babyProvider.currentUserId;
    _currentBabyId = babyProvider.currentBaby?.id;
    
    if (_currentUserId == null || _currentBabyId == null) {
      // 개발/테스트용 임시 UUID 생성
      const uuid = Uuid();
      _currentUserId ??= uuid.v4();
      _currentBabyId ??= uuid.v4();
      
      debugPrint('⚠️ 임시 UUID 생성됨 - userId: $_currentUserId, babyId: $_currentBabyId');
      _showErrorSnackBar('테스트 모드: 임시 사용자 정보로 초대를 생성합니다.');
    }

    setState(() => _isLoading = true);

    try {
      final result = await _invitationService.createInvitation(
        babyId: _currentBabyId!,
        inviterId: _currentUserId!,
        role: _selectedRole,
        validFor: _selectedDuration,
      );

      if (result.isSuccess) {
        await _showSuccessDialog(result);
        Navigator.pop(context); // 성공 시 이전 화면으로 돌아가기
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('초대 생성 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog(result) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('초대 생성 완료'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),
            const Text(
              '이제 초대 링크를 공유하거나 초대 관리에서 확인할 수 있습니다.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (result.invitation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _shareInvitation(result.invitation!);
              },
              child: const Text('바로 공유'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareInvitation(Invitation invitation) async {
    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyName = babyProvider.currentBaby?.name ?? '우리 아기';
      
      final success = await _invitationService.shareInvitation(invitation, babyName);
      
      if (success) {
        _showSuccessSnackBar('초대 링크가 공유되었습니다');
      } else {
        _showErrorSnackBar('공유에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('공유 중 오류가 발생했습니다: $e');
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

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else {
      return '${duration.inMinutes}분';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider에서 사용자 및 아기 정보 업데이트
    final babyProvider = Provider.of<BabyProvider>(context);
    _updateUserData(babyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 초대 만들기'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '초대 안내',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '가족 구성원을 초대하여 함께 육아 기록을 관리할 수 있습니다. 초대받은 사람은 앱을 설치한 후 초대 링크를 통해 참여할 수 있습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 역할 선택
            const Text(
              '역할 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...InvitationRole.values.map((role) => RadioListTile<InvitationRole>(
              title: Text(role.displayName),
              subtitle: Text(_getRoleDescription(role)),
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            )),
            
            const SizedBox(height: 24),
            
            // 유효 기간 선택
            const Text(
              '초대 유효 기간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Duration>(
                  value: _selectedDuration,
                  isExpanded: true,
                  items: _durationOptions.map((duration) {
                    return DropdownMenuItem<Duration>(
                      value: duration,
                      child: Text(_formatDuration(duration)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDuration = value);
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Text(
              '선택한 기간이 지나면 초대 링크가 만료됩니다.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 미리보기
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '초대 미리보기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('역할: ${_selectedRole.displayName}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('유효 기간: ${_formatDuration(_selectedDuration)}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createInvitation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('초대 생성 중...'),
                    ],
                  )
                : const Text(
                    '초대 만들기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _getRoleDescription(InvitationRole role) {
    switch (role) {
      case InvitationRole.parent:
        return '아기의 부모로 모든 기록을 관리할 수 있습니다';
      case InvitationRole.caregiver:
        return '아기를 돌보는 사람으로 일부 기록을 관리할 수 있습니다';
      case InvitationRole.guardian:
        return '아기의 보호자로 기록을 조회할 수 있습니다';
    }
  }
}