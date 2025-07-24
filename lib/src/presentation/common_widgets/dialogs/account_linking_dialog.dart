import 'package:flutter/material.dart';
import '../../../services/auth/account_linking_service.dart';
import '../../../services/auth/supabase_auth_service.dart';

class AccountLinkingDialog extends StatefulWidget {
  final String newUserEmail;
  final AccountInfo existingAccount;
  final VoidCallback? onLinkingComplete;
  final VoidCallback? onSkip;

  const AccountLinkingDialog({
    Key? key,
    required this.newUserEmail,
    required this.existingAccount,
    this.onLinkingComplete,
    this.onSkip,
  }) : super(key: key);

  @override
  State<AccountLinkingDialog> createState() => _AccountLinkingDialogState();
}

class _AccountLinkingDialogState extends State<AccountLinkingDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPasswordField = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.8),
                  Colors.purple.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.link,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '계정 연결',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상황 설명
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기존 계정 발견',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.newUserEmail} 주소로 이미 가입된 계정이 있습니다.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountCard(widget.existingAccount),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 옵션 설명
            const Text(
              '어떻게 진행하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 비밀번호 입력 필드 (조건부 표시)
            if (_showPasswordField) ...[
              const Text(
                '기존 계정과 연결하려면 비밀번호를 입력해주세요:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '기존 계정 비밀번호',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _errorMessage,
                ),
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // 로딩 인디케이터
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        // 건너뛰기 버튼
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.of(context).pop();
            widget.onSkip?.call();
          },
          child: const Text('별도 계정으로 계속'),
        ),
        
        // 연결 버튼
        if (!_showPasswordField)
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _showPasswordField = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('기존 계정과 연결'),
          ),
        
        // 확인 버튼 (비밀번호 입력 후)
        if (_showPasswordField)
          ElevatedButton(
            onPressed: _isLoading ? null : _performLinking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('연결하기'),
          ),
      ],
    );
  }

  Widget _buildAccountCard(AccountInfo account) {
    IconData accountIcon;
    Color accountColor;
    String accountTypeText;
    
    switch (account.type) {
      case AccountType.kakao:
        accountIcon = Icons.chat_bubble;
        accountColor = const Color(0xFFFFE812);
        accountTypeText = '카카오';
        break;
      case AccountType.email:
        accountIcon = Icons.email;
        accountColor = Colors.blue;
        accountTypeText = '이메일';
        break;
      case AccountType.google:
        accountIcon = Icons.g_mobiledata;
        accountColor = Colors.red;
        accountTypeText = '구글';
        break;
      case AccountType.facebook:
        accountIcon = Icons.facebook;
        accountColor = Colors.blue[800]!;
        accountTypeText = '페이스북';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accountColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accountIcon,
              color: accountColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.nickname ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$accountTypeText 계정',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (account.isDeleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '탈퇴',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _performLinking() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 기존 계정으로 비밀번호 검증
      final supabaseAuth = SupabaseAuthService.instance;
      
      if (widget.existingAccount.email == null) {
        throw Exception('기존 계정의 이메일 정보가 없습니다.');
      }
      
      try {
        await supabaseAuth.signInWithEmail(
          widget.existingAccount.email!,
          password,
        );
        
        // 검증 성공 시 즉시 로그아웃 (연결만 확인)
        await supabaseAuth.signOut();
        
      } catch (e) {
        if (e.toString().contains('Invalid login credentials')) {
          setState(() {
            _errorMessage = '비밀번호가 올바르지 않습니다.';
            _isLoading = false;
          });
          return;
        }
        rethrow;
      }

      // 2. 계정 연결 수행
      final linkingService = AccountLinkingService.instance;
      final success = await linkingService.linkAccounts(
        primaryUserId: widget.existingAccount.userId,
        secondaryUserId: 'current_new_user_id', // 실제로는 새 사용자 ID 필요
        primaryType: widget.existingAccount.type,
        secondaryType: AccountType.email, // 현재 가입 방식
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          
          // 성공 다이얼로그 표시
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              title: const Text('계정 연결 완료'),
              content: const Text(
                '계정이 성공적으로 연결되었습니다!\n\n이제 두 가지 방법으로 모두 로그인할 수 있습니다.',
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onLinkingComplete?.call();
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
      } else {
        throw Exception('계정 연결에 실패했습니다.');
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '계정 연결 중 오류가 발생했습니다: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}