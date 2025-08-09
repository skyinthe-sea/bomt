import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/auth/supabase_auth_service.dart';

enum EmailAuthMode { signIn, signUp }

class EmailAuthDialog extends StatefulWidget {
  final Future<void> Function(String email, String password, [EmailAuthMode? mode]) onSubmit;
  final VoidCallback? onForgotPassword;
  final bool isLoading;
  final EmailAuthMode initialMode;

  const EmailAuthDialog({
    Key? key,
    required this.onSubmit,
    this.onForgotPassword,
    this.isLoading = false,
    this.initialMode = EmailAuthMode.signUp,
  }) : super(key: key);

  @override
  State<EmailAuthDialog> createState() => _EmailAuthDialogState();
}

class _EmailAuthDialogState extends State<EmailAuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late EmailAuthMode _mode;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // 비밀번호 검증 상태
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;
  
  // 실시간 검증을 위한 포커스 및 입력 상태 추적
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  
  // 🔍 실시간 이메일 체크 관련 상태
  bool _isCheckingEmail = false;
  EmailCheckResult? _emailCheckResult;
  bool _emailTouched = false;
  Timer? _debounceTimer;
  final _supabaseAuth = SupabaseAuthService.instance;
  
  // 🎯 이메일 형식 검증 상태 (즉시 표시)
  String? _emailFormatError;
  bool _emailFormatTouched = false;

  @override
  void initState() {
    super.initState();
    // 초기 모드 설정
    _mode = widget.initialMode;
    // 비밀번호 실시간 검증 리스너 추가
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordMatch);
    // 이메일 형식 실시간 검증 리스너 추가
    _emailController.addListener(_validateEmailFormat);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  /// 비밀번호 실시간 검증
  void _validatePassword() {
    if (!mounted) return;
    
    final password = _passwordController.text;
    setState(() {
      _passwordTouched = true;
      _hasMinLength = password.length >= 6;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
    
    // 비밀번호가 변경되면 확인 비밀번호도 다시 검증
    if (_confirmPasswordTouched) {
      _validatePasswordMatch();
    }
  }
  
  /// 비밀번호 일치 여부 실시간 검증
  void _validatePasswordMatch() {
    if (!mounted) return;
    
    setState(() {
      _confirmPasswordTouched = true;
      // 🎯 비밀번호가 둘 다 비어있으면 일치하지 않는 것으로 처리
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      _passwordsMatch = password.isNotEmpty && confirmPassword.isNotEmpty && password == confirmPassword;
    });
  }
  
  /// 🎯 이메일 형식 실시간 검증
  void _validateEmailFormat() {
    if (!mounted) return;
    
    final email = _emailController.text;
    setState(() {
      _emailFormatTouched = email.isNotEmpty;
      _emailFormatError = email.isEmpty ? null : _getEmailFormatError(email);
      
      // 🎯 이메일 형식이 틀렸으면 기존 체크 결과 완전 초기화
      if (_emailFormatError != null) {
        _emailCheckResult = null;
        _emailTouched = false;
        _isCheckingEmail = false; // 🎯 진행 중인 검색 상태도 초기화
      }
    });
  }
  
  /// 전체 비밀번호 검증 통과 여부
  bool get _isPasswordValid {
    if (_mode == EmailAuthMode.signIn) return true;
    return _hasMinLength && (_hasUppercase || _hasLowercase) && _hasNumber;
  }
  
  /// 회원가입 시 전체 검증 통과 여부
  bool get _isSignUpValid {
    if (_mode == EmailAuthMode.signIn) return true;
    // 이메일 체크 결과가 signUp이 아니면 회원가입 불가
    if (_emailCheckResult?.recommendedAction != EmailAction.signUp && _emailCheckResult?.recommendedAction != EmailAction.reactivate) {
      return false;
    }
    return _isPasswordValid && _passwordsMatch && _confirmPasswordController.text.isNotEmpty;
  }

  /// 🔍 실시간 이메일 중복 체크
  Future<void> _checkEmailExists() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _emailCheckResult = null;
        _isCheckingEmail = false;
      });
      return;
    }
    
    // 🎯 이미 같은 이메일을 검색 중이면 중복 검색 방지
    if (_isCheckingEmail) {
      debugPrint('🔍 [EMAIL_CHECK] Already checking - skipping duplicate request for: $email');
      return;
    }

    // 🎯 검색 시작 시점의 이메일을 기록 (Race Condition 방지)
    final searchEmail = email;
    
    debugPrint('🔍 [EMAIL_CHECK] Starting search for: $searchEmail');

    setState(() {
      _isCheckingEmail = true;
    });

    try {
      final result = await _supabaseAuth.checkEmailExistsQuick(searchEmail);
      debugPrint('🔍 [EMAIL_CHECK] Search completed for: $searchEmail - exists: ${result.exists}');
      
      if (mounted) {
        // 🎯 응답 시점의 이메일과 검색 시점의 이메일이 일치하는지 확인
        final currentEmail = _emailController.text.trim();
        if (currentEmail == searchEmail) {
          // 일치하는 경우에만 결과 적용
          setState(() {
            _emailCheckResult = result;
            _isCheckingEmail = false;
          });
        } else {
          // 일치하지 않는 경우 결과 무시 (Race Condition 방지)
          setState(() {
            _isCheckingEmail = false;
          });
          debugPrint('🔍 [EMAIL_CHECK] Race condition detected - ignoring result for $searchEmail (current: $currentEmail)');
        }
      }
    } catch (e) {
      debugPrint('🔍 [EMAIL_CHECK] Error occurred for: $searchEmail - $e');
      if (mounted) {
        // 🎯 에러 발생 시에도 현재 이메일과 검색 이메일 일치 여부 확인
        final currentEmail = _emailController.text.trim();
        if (currentEmail == searchEmail) {
          setState(() {
            _emailCheckResult = null;
            _isCheckingEmail = false;
          });
          debugPrint('🔍 [EMAIL_CHECK] Error state applied for matching email: $searchEmail');
        } else {
          setState(() {
            _isCheckingEmail = false;
          });
          debugPrint('🔍 [EMAIL_CHECK] Error ignored for mismatched email: $searchEmail (current: $currentEmail)');
        }
      }
    }
  }

  /// 이메일 형식 검증 (더 강화된 버전)
  bool _isValidEmail(String email) {
    // 기본적인 공백 제거
    email = email.trim();
    
    // 빈 문자열 체크
    if (email.isEmpty) return false;
    
    // 기본적인 @ 존재 여부 체크
    if (!email.contains('@')) return false;
    
    // @ 개수가 정확히 1개인지 체크
    if (email.split('@').length != 2) return false;
    
    // @ 앞뒤로 문자가 있는지 체크
    final parts = email.split('@');
    if (parts[0].isEmpty || parts[1].isEmpty) return false;
    
    // 도메인 부분에 점이 있는지 체크
    if (!parts[1].contains('.')) return false;
    
    // 🎯 도메인이 올바른지 더 엄격하게 검증
    if (!_isValidDomain(parts[1])) return false;
    
    // 정규식으로 최종 검증 (더 엄격한 패턴)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email);
  }

  /// 🎯 도메인 유효성 검증 (일반적인 도메인 패턴 체크)
  bool _isValidDomain(String domain) {
    // 도메인이 점으로 시작하거나 끝나면 안됨
    if (domain.startsWith('.') || domain.endsWith('.')) return false;
    
    // 연속된 점이 있으면 안됨
    if (domain.contains('..')) return false;
    
    // 도메인 부분들을 점으로 분리
    final domainParts = domain.split('.');
    
    // 최소 2개 부분이 있어야 함 (예: google.com)
    if (domainParts.length < 2) return false;
    
    // 각 부분이 유효한지 체크
    for (final part in domainParts) {
      if (part.isEmpty) return false;
      if (part.length > 63) return false; // DNS 라벨 최대 길이
      
      // 알파벳, 숫자, 하이픈만 허용
      if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(part)) return false;
      
      // 하이픈으로 시작하거나 끝나면 안됨
      if (part.startsWith('-') || part.endsWith('-')) return false;
    }
    
    // 🎯 실제 존재하는 주요 TLD만 허용 (다중 레벨 도메인 포함)
    if (!_isValidTLD(domain, domainParts)) return false;
    
    // 🎯 잘 알려진 도메인 오타 체크
    if (_isCommonDomainTypo(domain)) return false;
    
    // 🎯 IP 주소 형태 거부 (예: 192.168.1.1)
    if (_isIPAddress(domain)) return false;
    
    return true;
  }

  /// 🎯 유효한 TLD 확인 (다중 레벨 도메인 포함)
  bool _isValidTLD(String domain, List<String> domainParts) {
    // 2단계 TLD (예: co.kr, co.uk) 체크
    if (domainParts.length >= 2) {
      final last2Parts = '${domainParts[domainParts.length - 2]}.${domainParts[domainParts.length - 1]}';
      final valid2LevelTLDs = {
        'co.kr', 'or.kr', 'go.kr', 'ac.kr', 'ne.kr', 're.kr',
        'co.uk', 'org.uk', 'ac.uk', 'gov.uk',
        'co.jp', 'or.jp', 'ac.jp', 'go.jp',
        'com.au', 'net.au', 'org.au', 'edu.au',
        'com.cn', 'net.cn', 'org.cn', 'edu.cn',
      };
      
      if (valid2LevelTLDs.contains(last2Parts.toLowerCase())) {
        return true;
      }
    }
    
    // 1단계 TLD 체크
    final tld = domainParts.last.toLowerCase();
    
    // TLD 길이 체크
    if (tld.length < 2 || tld.length > 6) return false;
    
    // TLD는 순수 알파벳만 허용
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(tld)) return false;
    
    final validTLDs = {
      // 일반적인 gTLD
      'com', 'net', 'org', 'edu', 'gov', 'mil', 'int',
      'biz', 'info', 'name', 'pro', 'museum', 'coop',
      
      // 국가 ccTLD (주요 국가들)
      'kr', 'jp', 'cn', 'us', 'uk', 'de', 'fr', 'it', 'es',
      'ca', 'au', 'in', 'br', 'mx', 'nl', 'se', 'no', 'dk',
      'fi', 'pl', 'ch', 'at', 'be', 'ie', 'nz', 'sg', 'hk',
      'tw', 'th', 'my', 'ph', 'vn', 'id', 'sa', 'ae', 'eg',
      'za', 'ng', 'ke', 'gh', 'ma', 'tn', 'dz', 'ly', 'sd',
      
      // 새로운 gTLD (자주 사용되는 것들)
      'app', 'dev', 'tech', 'blog', 'shop', 'store', 'online',
      'site', 'web', 'email', 'news', 'media', 'photo', 'video',
      'music', 'game', 'travel', 'hotel', 'food', 'health',
      'finance', 'bank', 'insurance', 'legal', 'consulting',
      'academy', 'school', 'university', 'college', 'training',
      'church', 'community', 'club', 'team', 'group',
    };
    
    return validTLDs.contains(tld);
  }

  /// 🎯 IP 주소 형태 감지
  bool _isIPAddress(String domain) {
    // IPv4 패턴 체크 (192.168.1.1 같은 형태)
    final ipv4Pattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipv4Pattern.hasMatch(domain);
  }

  /// 🎯 잘 알려진 도메인 오타 감지
  bool _isCommonDomainTypo(String domain) {
    final commonDomains = {
      // 한국 도메인들
      'naver.com': ['naver.co', 'naver.cm', 'naver.con'],
      'daum.net': ['daum.ne', 'daum.nt', 'daum.com'],
      'hanmail.net': ['hanmail.ne', 'hanmail.nt'],
      'kakao.com': ['kakao.co', 'kakao.cm'],
      
      // 해외 도메인들
      'gmail.com': ['gmail.co', 'gmail.cm', 'gmail.con', 'gmial.com', 'gmai.com'],
      'hotmail.com': ['hotmail.co', 'hotmail.cm', 'hotmai.com'],
      'yahoo.com': ['yahoo.co', 'yahoo.cm', 'yhoo.com'],
      'outlook.com': ['outlook.co', 'outlook.cm', 'outlok.com'],
      'icloud.com': ['icloud.co', 'icloud.cm', 'icoud.com'],
    };

    for (final correctDomain in commonDomains.keys) {
      final typos = commonDomains[correctDomain]!;
      if (typos.contains(domain.toLowerCase())) {
        return true; // 오타로 감지됨
      }
    }
    
    return false;
  }

  /// 🎯 도메인 오타 수정 제안
  String? _suggestDomainCorrection(String domain) {
    final commonDomains = {
      // 한국 도메인들
      'naver.com': ['naver.co', 'naver.cm', 'naver.con'],
      'daum.net': ['daum.ne', 'daum.nt', 'daum.com'],
      'hanmail.net': ['hanmail.ne', 'hanmail.nt'],
      'kakao.com': ['kakao.co', 'kakao.cm'],
      
      // 해외 도메인들
      'gmail.com': ['gmail.co', 'gmail.cm', 'gmail.con', 'gmial.com', 'gmai.com'],
      'hotmail.com': ['hotmail.co', 'hotmail.cm', 'hotmai.com'],
      'yahoo.com': ['yahoo.co', 'yahoo.cm', 'yhoo.com'],
      'outlook.com': ['outlook.co', 'outlook.cm', 'outlok.com'],
      'icloud.com': ['icloud.co', 'icloud.cm', 'icoud.com'],
    };

    for (final correctDomain in commonDomains.keys) {
      final typos = commonDomains[correctDomain]!;
      if (typos.contains(domain.toLowerCase())) {
        return correctDomain; // 올바른 도메인 제안
      }
    }
    
    return null;
  }

  /// 이메일 형식 오류 메시지 생성
  String? _getEmailFormatError(String email) {
    email = email.trim();
    
    if (email.isEmpty) return '이메일을 입력해주세요';
    
    if (!email.contains('@')) {
      return '이메일에 @가 포함되어야 합니다';
    }
    
    if (email.split('@').length != 2) {
      return '@는 하나만 포함되어야 합니다';
    }
    
    final parts = email.split('@');
    if (parts[0].isEmpty) {
      return '@앞에 이메일 주소를 입력해주세요';
    }
    
    if (parts[1].isEmpty) {
      return '@뒤에 도메인을 입력해주세요';
    }
    
    if (!parts[1].contains('.')) {
      return '올바른 도메인 형식이 아닙니다 (예: gmail.com)';
    }
    
    // 🎯 도메인 유효성 체크 추가
    if (!_isValidDomain(parts[1])) {
      // 🎯 도메인 오타 수정 제안
      final suggestion = _suggestDomainCorrection(parts[1]);
      if (suggestion != null) {
        return '혹시 $suggestion을(를) 의도하셨나요?';
      }
      return '올바른 도메인이 아닙니다 (예: gmail.com, naver.com)';
    }
    
    if (!_isValidEmail(email)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    
    return null;
  }

  // 🎯 중복 다이얼로그 방지를 위해 제거됨 - UI 피드백으로 대체됨

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        _mode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85, // 🎯 화면 높이의 85%로 제한
          maxWidth: MediaQuery.of(context).size.width * 0.9,   // 🎯 화면 너비의 90%로 제한
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView( // 🎯 스크롤 가능
            physics: const BouncingScrollPhysics(), // 🎯 부드러운 스크롤
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // 헤더
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // 이메일 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: (hasFocus) {
                          // 🔍 포커스를 잃을 때 실시간 이메일 체크
                          if (!hasFocus && _emailController.text.isNotEmpty) {
                            setState(() {
                              _emailTouched = true;
                            });
                            _checkEmailExists();
                          }
                        },
                        child: _buildTextField(
                          controller: _emailController,
                          label: '이메일',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onEditingComplete: () {
                            // 이메일 입력 완료 시 실시간 체크
                            setState(() {
                              _emailTouched = true;
                            });
                            _checkEmailExists();
                          },
                          onChanged: (value) {
                            // 🎯 이메일 변경 시 즉시 모든 이전 상태 완전 초기화
                            setState(() {
                              _emailCheckResult = null;
                              _emailTouched = false;
                              _isCheckingEmail = false; // 🎯 진행 중인 검색 상태도 초기화
                            });
                            
                            debugPrint('🔍 [EMAIL_CHECK] Email changed to: $value - clearing previous state');
                            
                            // 🔍 형식이 올바른 경우에만 중복 체크 (디바운스 시간 단축)
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                              // 다시 한 번 형식 확인 (실시간 리스너와 동기화)
                              if (mounted && value.isNotEmpty && _isValidEmail(value) && _emailFormatError == null) {
                                debugPrint('🔍 [EMAIL_CHECK] Starting debounced check for: $value');
                                setState(() {
                                  _emailTouched = true;
                                });
                                _checkEmailExists();
                              } else {
                                debugPrint('🔍 [EMAIL_CHECK] Skipping check for: $value (invalid format)');
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            
                            // 🎯 상세한 이메일 형식 오류 메시지 사용
                            final formatError = _getEmailFormatError(value);
                            if (formatError != null) {
                              return formatError;
                            }
                            
                            // 실시간 체크 결과가 있는 경우 추가 검증
                            if (_emailCheckResult?.exists == true && 
                                _emailCheckResult?.recommendedAction == EmailAction.signIn && 
                                _mode == EmailAuthMode.signUp) {
                              return '이미 가입된 이메일입니다. 로그인을 시도해보세요';
                            }
                            return null;
                          },
                          suffixWidget: _mode == EmailAuthMode.signUp ? _buildEmailCheckIndicator() : null,
                        ),
                      ),
                      
                      // 🔍 실시간 이메일 체크 결과 표시 (회원가입 모드에서만)
                      if (_mode == EmailAuthMode.signUp) ...[
                        if (_emailFormatTouched && _emailFormatError != null)
                          _buildEmailFormatErrorFeedback()
                        else if (_emailTouched && _emailCheckResult != null)
                          _buildEmailCheckFeedback(),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 비밀번호 필드
                  _buildTextField(
                    controller: _passwordController,
                    label: '비밀번호',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (_mode == EmailAuthMode.signUp && value.length < 6) {
                        return '비밀번호는 6글자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  
                  // 회원가입 모드일 때만 비밀번호 검증 상태 표시
                  if (_mode == EmailAuthMode.signUp && _passwordTouched)
                    _buildPasswordValidationFeedback(),
                  
                  // 회원가입 모드일 때만 비밀번호 확인 필드
                  if (_mode == EmailAuthMode.signUp) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: '비밀번호 확인',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요';
                        }
                        if (value != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // 액션 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget.onSubmit(_emailController.text, _passwordController.text, _mode);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_mode == EmailAuthMode.signUp ? '회원가입' : '로그인'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 모드 전환
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _mode == EmailAuthMode.signUp 
                          ? '이미 계정이 있으신가요?' 
                          : '계정이 없으신가요?',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _mode = _mode == EmailAuthMode.signUp 
                              ? EmailAuthMode.signIn 
                              : EmailAuthMode.signUp;
                          });
                        },
                        child: Text(
                          _mode == EmailAuthMode.signUp ? '로그인' : '회원가입',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.email_outlined,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mode == EmailAuthMode.signUp ? '회원가입' : '로그인',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _mode == EmailAuthMode.signUp 
                  ? '새 계정을 만들어보세요'
                  : '계정에 로그인하세요',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
  
  Widget _buildEmailFormatErrorFeedback() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _emailFormatError ?? '이메일 형식이 올바르지 않습니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 텍스트 필드 빌더
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    VoidCallback? onEditingComplete,
    Widget? suffixWidget,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixWidget != null 
            ? suffixWidget
            : (isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }
  
  /// 이메일 체크 상태 표시 아이콘
  Widget _buildEmailCheckIndicator() {
    if (_isCheckingEmail) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (_emailCheckResult != null) {
      switch (_emailCheckResult!.recommendedAction) {
        case EmailAction.signUp:
          return Icon(Icons.check_circle, color: Colors.green[600], size: 20);
        case EmailAction.signIn:
          return Icon(Icons.warning, color: Colors.red[600], size: 20);
        default:
          return Icon(Icons.info, color: Colors.orange[600], size: 20);
      }
    }
    
    return const SizedBox.shrink();
  }
  
  /// 🔍 이메일 체크 결과 피드백
  Widget _buildEmailCheckFeedback() {
    if (_emailCheckResult == null) return const SizedBox.shrink();
    
    final result = _emailCheckResult!;
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData iconData;
    String displayMessage = result.message;
    
    switch (result.recommendedAction) {
      case EmailAction.signUp:
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green[800]!;
        borderColor = Colors.green.withOpacity(0.4);
        iconData = Icons.check_circle;
        if (displayMessage.isEmpty) {
          displayMessage = '✨ 사용 가능한 이메일입니다! 회원가입을 진행하세요.';
        }
        break;
      case EmailAction.signIn:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        borderColor = Colors.red.withOpacity(0.5);
        iconData = Icons.warning;
        break;
      case EmailAction.reactivate:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        borderColor = Colors.orange.withOpacity(0.3);
        iconData = Icons.refresh;
        break;
      case EmailAction.resendConfirmation:
        backgroundColor = Colors.amber.withOpacity(0.1);
        textColor = Colors.amber[700]!;
        borderColor = Colors.amber.withOpacity(0.3);
        iconData = Icons.email_outlined;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: result.recommendedAction == EmailAction.signIn ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  iconData,
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
  
  /// 비밀번호 검증 상태 표시
  Widget _buildPasswordValidationFeedback() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '비밀번호 요구사항',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordRequirement(
            '최소 6자 이상', 
            _hasMinLength,
          ),
          _buildPasswordRequirement(
            '영문 대문자 또는 소문자 포함', 
            _hasUppercase || _hasLowercase,
          ),
          _buildPasswordRequirement(
            '숫자 포함', 
            _hasNumber,
          ),
          if (_confirmPasswordTouched)
            _buildPasswordRequirement(
              '비밀번호 일치', 
              _passwordsMatch,
            ),
        ],
      ),
    );
  }
  
  /// 비밀번호 요구사항 항목
  Widget _buildPasswordRequirement(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green[700] : Colors.grey[600],
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
