import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static DeepLinkService get instance => _instance;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final _deepLinkController = StreamController<DeepLinkEvent>.broadcast();

  /// 딥링크 이벤트 스트림
  Stream<DeepLinkEvent> get onDeepLink => _deepLinkController.stream;

  /// 딥링크 리스닝 시작
  Future<void> initializeDeepLinks() async {
    try {
      // 앱이 종료된 상태에서 딥링크로 실행된 경우 처리
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // 앱이 실행 중일 때 딥링크 처리
      _linkSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (err) {
          print('딥링크 에러: $err');
          _deepLinkController.add(DeepLinkEvent.error('딥링크 처리 중 오류가 발생했습니다: $err'));
        },
      );

      print('딥링크 서비스 초기화 완료');
    } catch (e) {
      print('딥링크 서비스 초기화 실패: $e');
    }
  }

  /// 딥링크 처리
  void _handleDeepLink(Uri uri) {
    try {
      print('딥링크 수신: $uri');

      // 스킴 검증
      if (!_isValidScheme(uri.scheme)) {
        print('지원하지 않는 스킴: ${uri.scheme}');
        return;
      }

      // 경로별 처리
      switch (uri.host) {
        case 'invite':
          _handleInviteLink(uri);
          break;
        default:
          print('알 수 없는 딥링크 호스트: ${uri.host}');
          _deepLinkController.add(DeepLinkEvent.unknown(uri.toString()));
      }
    } catch (e) {
      print('딥링크 처리 오류: $e');
      _deepLinkController.add(DeepLinkEvent.error('딥링크 처리 중 오류가 발생했습니다'));
    }
  }

  /// 초대 링크 처리
  void _handleInviteLink(Uri uri) {
    final token = uri.queryParameters['token'];
    
    if (token == null || token.isEmpty) {
      print('초대 토큰이 없습니다');
      _deepLinkController.add(DeepLinkEvent.error('유효하지 않은 초대 링크입니다'));
      return;
    }

    print('초대 토큰 수신: $token');
    _deepLinkController.add(DeepLinkEvent.invitation(token));
  }

  /// 스킴 유효성 검증
  bool _isValidScheme(String scheme) {
    const validSchemes = ['bomtapp', 'bomt'];
    return validSchemes.contains(scheme.toLowerCase());
  }

  /// 초대 딥링크 생성
  String generateInviteLink(String token, {String scheme = 'bomtapp'}) {
    return '$scheme://invite?token=$token';
  }

  /// 초대 링크 공유
  Future<void> shareInviteLink(String token, String message, {String? subject}) async {
    try {
      final link = generateInviteLink(token);
      final fullMessage = '$message\n\n$link';
      
      await Share.share(
        fullMessage,
        subject: subject ?? 'BOMT 육아 앱 초대',
      );
      
      print('초대 링크 공유 완료: $token');
    } catch (e) {
      print('초대 링크 공유 실패: $e');
      throw Exception('공유 중 오류가 발생했습니다: $e');
    }
  }

  /// 앱 스토어로 리다이렉트 (앱이 설치되지 않은 경우)
  Future<void> redirectToAppStore() async {
    try {
      // Android Play Store
      const androidUrl = 'https://play.google.com/store/apps/details?id=com.example.bomt';
      // iOS App Store  
      const iosUrl = 'https://apps.apple.com/app/bomt/id123456789';
      
      // 플랫폼 감지는 실제 앱에서 Platform.isAndroid/Platform.isIOS 사용
      // 여기서는 간단히 Android URL 사용
      final url = Uri.parse(androidUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('앱 스토어를 열 수 없습니다');
      }
    } catch (e) {
      print('앱 스토어 리다이렉트 실패: $e');
      throw Exception('앱 스토어 연결 중 오류가 발생했습니다');
    }
  }

  /// 딥링크 서비스 정리
  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
    print('딥링크 서비스 정리 완료');
  }

  /// 딥링크 테스트 (개발용)
  void testInviteLink(String token) {
    final uri = Uri.parse(generateInviteLink(token));
    _handleDeepLink(uri);
  }
}

/// 딥링크 이벤트 타입
abstract class DeepLinkEvent {
  const DeepLinkEvent();

  factory DeepLinkEvent.invitation(String token) = InvitationDeepLinkEvent;
  factory DeepLinkEvent.error(String message) = ErrorDeepLinkEvent;
  factory DeepLinkEvent.unknown(String link) = UnknownDeepLinkEvent;
}

/// 초대 딥링크 이벤트
class InvitationDeepLinkEvent extends DeepLinkEvent {
  final String token;
  
  const InvitationDeepLinkEvent(this.token);

  @override
  String toString() => 'InvitationDeepLinkEvent(token: $token)';
}

/// 오류 딥링크 이벤트
class ErrorDeepLinkEvent extends DeepLinkEvent {
  final String message;
  
  const ErrorDeepLinkEvent(this.message);

  @override
  String toString() => 'ErrorDeepLinkEvent(message: $message)';
}

/// 알 수 없는 딥링크 이벤트
class UnknownDeepLinkEvent extends DeepLinkEvent {
  final String link;
  
  const UnknownDeepLinkEvent(this.link);

  @override
  String toString() => 'UnknownDeepLinkEvent(link: $link)';
}