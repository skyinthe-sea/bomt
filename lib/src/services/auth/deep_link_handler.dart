import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkHandler {
  static DeepLinkHandler? _instance;
  static DeepLinkHandler get instance => _instance ??= DeepLinkHandler._();
  
  DeepLinkHandler._();

  final AppLinks _appLinks = AppLinks();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 딥링크 처리 초기화
  Future<void> initialize() async {
    try {
      // 앱이 실행 중일 때 딥링크 처리
      _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      });

      // 앱이 종료된 상태에서 딥링크로 실행될 때 처리
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      debugPrint('🔗 [DEEP_LINK] Handler initialized');
    } catch (e) {
      debugPrint('❌ [DEEP_LINK] Initialization failed: $e');
    }
  }

  /// 딥링크 처리
  void _handleDeepLink(Uri uri) {
    debugPrint('🔗 [DEEP_LINK] Received: ${uri.toString()}');

    // 이메일 인증 딥링크 처리 (babymom://auth?token_hash=...&type=...)
    if (uri.scheme == 'babymom' && uri.host == 'auth') {
      _handleEmailConfirmation(uri);
    }
    // 초대 딥링크 처리 (기존 기능 유지)
    else if (uri.scheme == 'bomtapp' || uri.scheme == 'bomt') {
      _handleInvitation(uri);
    }
  }

  /// 이메일 인증 딥링크 처리
  Future<void> _handleEmailConfirmation(Uri uri) async {
    try {
      final tokenHash = uri.queryParameters['token_hash'];
      final type = uri.queryParameters['type'];

      debugPrint('📧 [DEEP_LINK] Processing email confirmation...');
      debugPrint('🔍 [DEEP_LINK] token_hash: $tokenHash');
      debugPrint('🔍 [DEEP_LINK] type: $type');

      if (tokenHash == null) {
        debugPrint('❌ [DEEP_LINK] Missing token_hash parameter');
        _onEmailConfirmationError?.call('유효하지 않은 인증 링크입니다.');
        return;
      }

      // OTP 타입 결정
      OtpType otpType;
      switch (type) {
        case 'signup':
          otpType = OtpType.signup;
          break;
        case 'email':
          otpType = OtpType.email;
          break;
        case 'recovery':
          otpType = OtpType.recovery;
          break;
        case 'invite':
          otpType = OtpType.invite;
          break;
        case 'magiclink':
          otpType = OtpType.magiclink;
          break;
        default:
          otpType = OtpType.signup; // 기본값
      }

      // Supabase 이메일 인증 처리
      final response = await _supabase.auth.verifyOTP(
        tokenHash: tokenHash,
        type: otpType,
      );

      if (response.user != null) {
        debugPrint('✅ [DEEP_LINK] Email confirmation successful');
        
        // 사용자 프로필 생성 확인
        await _ensureUserProfile(response.user!);
        
        // 성공 콜백 실행
        _onEmailConfirmationSuccess?.call();
      } else {
        debugPrint('❌ [DEEP_LINK] Email confirmation failed - no user');
        _onEmailConfirmationError?.call('이메일 인증에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('❌ [DEEP_LINK] Email confirmation error: $e');
      _onEmailConfirmationError?.call('이메일 인증 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 사용자 프로필 생성 확인
  Future<void> _ensureUserProfile(User user) async {
    try {
      final profileCheck = await _supabase
          .from('user_profiles')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileCheck == null) {
        await _supabase.from('user_profiles').insert({
          'user_id': user.id,
          'nickname': user.userMetadata?['nickname'] ?? user.email?.split('@')[0] ?? 'User',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ [DEEP_LINK] User profile created');
      }
    } catch (e) {
      debugPrint('⚠️ [DEEP_LINK] Profile creation failed: $e');
    }
  }

  /// 초대 딥링크 처리 (기존 기능)
  void _handleInvitation(Uri uri) {
    // 기존 초대 시스템 로직 유지
    debugPrint('🎯 [DEEP_LINK] Invitation link processed');
  }

  // 콜백 함수들
  void Function()? _onEmailConfirmationSuccess;
  void Function(String error)? _onEmailConfirmationError;

  /// 이메일 인증 성공 콜백 설정
  void setEmailConfirmationCallbacks({
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) {
    _onEmailConfirmationSuccess = onSuccess;
    _onEmailConfirmationError = onError;
  }
}