import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/community_provider.dart';

class CommunityNicknameSetupScreen extends StatefulWidget {
  final bool isFirstTime;

  const CommunityNicknameSetupScreen({
    super.key,
    this.isFirstTime = true,
  });

  @override
  State<CommunityNicknameSetupScreen> createState() => _CommunityNicknameSetupScreenState();
}

class _CommunityNicknameSetupScreenState extends State<CommunityNicknameSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocus = FocusNode();
  
  bool _isChecking = false;
  bool _isSaving = false;
  bool? _isAvailable;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onNicknameChanged);
    
    // CommunityProvider 초기화 및 기존 닉네임 설정
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('DEBUG: CommunityNicknameSetupScreen initState - initializing provider');
      final provider = context.read<CommunityProvider>();
      
      // Provider 초기화
      await provider.initialize();
      print('DEBUG: Provider initialized, currentUserId = ${provider.currentUserId}');
      
      // 로그인 상태 확인
      if (provider.currentUserId == null && mounted) {
        print('DEBUG: currentUserId is null - login required');
        // 로그인이 필요하다는 안내 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? '로그인이 필요합니다. 이메일 또는 카카오톡 계정으로 로그인해주세요.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // 3초 후 이전 화면으로 돌아가기
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
        return;
      }
      
      // 기존 닉네임이 있다면 미리 설정
      if (provider.currentUserProfile?.nickname != null) {
        _nicknameController.text = provider.currentUserProfile!.nickname;
        print('DEBUG: Existing nickname set: ${provider.currentUserProfile!.nickname}');
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nicknameFocus.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    setState(() {
      _isAvailable = null;
      _errorMessage = null;
    });
    
    // 실시간 유효성 검사
    final nickname = _nicknameController.text.trim();
    if (nickname.isNotEmpty) {
      _validateNickname(nickname);
    }
  }

  void _validateNickname(String nickname) {
    // 기본 유효성 검사
    if (nickname.length < 2) {
      setState(() {
        _errorMessage = '닉네임은 2글자 이상이어야 합니다';
        _isAvailable = false;
      });
      return;
    }
    
    if (nickname.length > 20) {
      setState(() {
        _errorMessage = '닉네임은 20글자 이하여야 합니다';
        _isAvailable = false;
      });
      return;
    }
    
    // 특수문자 검사
    if (!RegExp(r'^[가-힣a-zA-Z0-9_]+$').hasMatch(nickname)) {
      setState(() {
        _errorMessage = '한글, 영문, 숫자, 언더바(_)만 사용 가능합니다';
        _isAvailable = false;
      });
      return;
    }
    
    setState(() {
      _errorMessage = null;
      _isAvailable = true;
    });
  }

  Future<void> _handleSave() async {
    print('DEBUG: _handleSave called');
    print('DEBUG: _isSaving = $_isSaving, _isAvailable = $_isAvailable');
    
    if (_isSaving || !(_isAvailable == true)) {
      print('DEBUG: Early return - conditions not met');
      return;
    }

    final nickname = _nicknameController.text.trim();
    print('DEBUG: Processing nickname: $nickname');
    
    setState(() {
      _isSaving = true;
    });

    try {
      print('DEBUG: Getting CommunityProvider...');
      final provider = context.read<CommunityProvider>();
      print('DEBUG: Provider obtained, calling updateUserProfile...');
      final success = await provider.updateUserProfile(nickname: nickname);
      print('DEBUG: updateUserProfile result: $success');
      
      if (success && mounted) {
        if (widget.isFirstTime) {
          // 처음 설정하는 경우, 환영 메시지와 함께 이전 화면으로
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('환영합니다, $nickname님! 🎉'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          // 닉네임 변경하는 경우
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('닉네임이 성공적으로 변경되었습니다!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isAvailable = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 디버그: 현재 상태 출력
    print('DEBUG: Build called - _isAvailable=$_isAvailable, _isSaving=$_isSaving, text="${_nicknameController.text}"');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: !widget.isFirstTime,
      appBar: widget.isFirstTime 
          ? null 
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 상단 여백
                if (!widget.isFirstTime) const SizedBox(height: 40),
                
                // 아이콘과 제목
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  widget.isFirstTime ? '닉네임을 설정해주세요' : '닉네임 변경',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  widget.isFirstTime 
                      ? '커뮤니티에서 사용할 닉네임을 설정해주세요.\n게시글과 댓글에서 다른 사용자들에게 표시됩니다.\n\n🚨 중요: 닉네임은 한 번 설정하면 변경할 수 없습니다.\n신중하게 선택해주세요!'
                      : '🚨 죄송합니다. 닉네임은 한 번 설정하면\n변경할 수 없는 정책입니다.\n\n보안과 사용자 식별을 위해 닉네임 변경을 제한하고 있습니다.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // 닉네임 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(widget.isFirstTime ? 0.9 : 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: !widget.isFirstTime
                          ? theme.colorScheme.outline.withOpacity(0.1)
                          : _nicknameFocus.hasFocus 
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : _isAvailable == false
                                  ? theme.colorScheme.error.withOpacity(0.5)
                                  : _isAvailable == true
                                      ? theme.colorScheme.tertiary.withOpacity(0.5)
                                      : theme.colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: widget.isFirstTime ? [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: TextField(
                        controller: _nicknameController,
                        focusNode: _nicknameFocus,
                        enabled: widget.isFirstTime, // 첫 설정일 때만 활성화
                        decoration: InputDecoration(
                          hintText: '닉네임을 입력하세요',
                          hintStyle: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.person,
                              color: _nicknameFocus.hasFocus
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          suffixIcon: _isChecking
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _isAvailable == true
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.tertiary,
                                      ),
                                    )
                                  : _isAvailable == false
                                      ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Icon(
                                            Icons.error,
                                            color: theme.colorScheme.error,
                                          ),
                                        )
                                      : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLength: 20,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (_isAvailable == true) {
                            _handleSave();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                
                // 에러 메시지 또는 도움말
                const SizedBox(height: 16),
                
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '한글, 영문, 숫자, 언더바(_) 사용 가능 (2-20자)\n💡 다른 사용자가 기억하기 쉬운 닉네임을 추천해요',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.isFirstTime && _isAvailable == true && !_isSaving ? () {
                        print('DEBUG: Button tapped! Calling _handleSave');
                        _handleSave();
                      } : widget.isFirstTime ? null : () {
                        // 닉네임 변경 시도 시 안내 메시지
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('닉네임은 변경할 수 없습니다. 보안과 사용자 식별을 위한 정책입니다.'),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: widget.isFirstTime && _isAvailable == true
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: widget.isFirstTime 
                              ? (_isAvailable == true ? null : theme.colorScheme.outline.withOpacity(0.2))
                              : theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: !widget.isFirstTime ? Border.all(
                            color: theme.colorScheme.error.withOpacity(0.3),
                          ) : null,
                          boxShadow: widget.isFirstTime && _isAvailable == true
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: _isSaving && widget.isFirstTime
                            ? Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            : Text(
                                widget.isFirstTime 
                                    ? '닉네임 설정하고 시작하기' 
                                    : '🚫 닉네임 변경 불가',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: widget.isFirstTime
                                      ? (_isAvailable == true ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5))
                                      : theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.isFirstTime ? 15 : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}