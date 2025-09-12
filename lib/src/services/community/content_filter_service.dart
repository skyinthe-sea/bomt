import 'dart:convert';
import 'package:http/http.dart' as http;

/// 콘텐츠 자동 필터링 서비스
/// App Store Guideline 1.2 준수를 위한 부적절한 콘텐츠 자동 검출
class ContentFilterService {
  // 금지 단어 목록 (확장 가능)
  static const List<String> _bannedWords = [
    // 욕설
    '씨발', '개새끼', '병신', '좆', '지랄', '꺼져', '죽어',
    // 혐오 표현
    '혐오', '차별', '증오', '살인', '폭력', '테러',
    // 성적 내용
    '섹스', '자위', '포르노', '음란', '변태',
    // 개인정보
    '주민등록번호', '휴대폰번호', '계좌번호', '비밀번호',
    // 스팸
    '대출', '투자', '도박', '카지노', '광고', '홍보',
  ];

  // 의심스러운 패턴들
  static final List<RegExp> _suspiciousPatterns = [
    // 반복되는 문자 (스팸성)
    RegExp(r'(.)\1{4,}'), // 같은 문자 5번 이상 반복
    // 연속된 특수문자
    RegExp(r'[!@#$%^&*()]{5,}'), // 특수문자 5개 이상 연속
    // 전화번호 패턴
    RegExp(r'01[0-9]-?[0-9]{3,4}-?[0-9]{4}'),
    // 이메일 주소
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
  ];

  /// 콘텐츠 필터링 결과
  static const String filterResultClean = 'clean';
  static const String filterResultSuspicious = 'suspicious'; 
  static const String filterResultBlocked = 'blocked';

  /// 텍스트 콘텐츠 필터링
  /// 반환값: 'clean', 'suspicious', 'blocked'
  static FilterResult filterText(String content) {
    if (content.trim().isEmpty) {
      return FilterResult(filterResultClean, []);
    }

    final violations = <String>[];
    final lowercaseContent = content.toLowerCase();

    // 1. 금지 단어 검사
    for (final word in _bannedWords) {
      if (lowercaseContent.contains(word.toLowerCase())) {
        violations.add('금지 단어 포함: $word');
      }
    }

    // 금지 단어가 있으면 즉시 차단
    if (violations.isNotEmpty) {
      return FilterResult(filterResultBlocked, violations);
    }

    // 2. 의심스러운 패턴 검사
    for (final pattern in _suspiciousPatterns) {
      if (pattern.hasMatch(content)) {
        violations.add('의심스러운 패턴 감지: ${pattern.pattern}');
      }
    }

    // 3. 콘텐츠 길이 검사 (스팸 방지)
    if (content.length > 5000) {
      violations.add('콘텐츠가 너무 깁니다');
    }

    // 4. 반복 게시 패턴 검사 (별도 서비스에서 처리)
    // TODO: 같은 사용자가 동일한 내용을 반복 게시하는지 확인

    return violations.isNotEmpty 
        ? FilterResult(filterResultSuspicious, violations)
        : FilterResult(filterResultClean, []);
  }

  /// 이미지 콘텐츠 필터링 (기본 구현)
  /// 실제 환경에서는 Google Vision API, AWS Rekognition 등 사용 권장
  static FilterResult filterImage(String imageUrl) {
    // 기본적으로 모든 이미지를 허용하되, 신고 시스템으로 처리
    // 향후 AI 기반 이미지 분석 서비스 연동 가능
    return FilterResult(filterResultClean, []);
  }

  /// 사용자 신뢰도 기반 필터링
  /// 신규 사용자나 신고당한 적이 있는 사용자의 콘텐츠는 더 엄격하게 검사
  static FilterResult filterWithUserContext({
    required String content,
    required UserTrustLevel trustLevel,
  }) {
    final baseResult = filterText(content);

    switch (trustLevel) {
      case UserTrustLevel.newUser:
        // 신규 사용자: suspicious도 blocked로 처리
        if (baseResult.status == filterResultSuspicious) {
          return FilterResult(filterResultBlocked, baseResult.violations);
        }
        break;
      case UserTrustLevel.reported:
        // 신고당한 적이 있는 사용자: 더 엄격한 기준 적용
        if (baseResult.status == filterResultSuspicious) {
          return FilterResult(filterResultBlocked, baseResult.violations);
        }
        break;
      case UserTrustLevel.trusted:
        // 신뢰받는 사용자: 기본 기준 적용
        break;
    }

    return baseResult;
  }

  /// 실시간 콘텐츠 검사 (게시글 작성 시)
  static Future<bool> canPublishContent({
    required String content,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      // 1. 텍스트 필터링
      final textResult = filterText(content);
      if (textResult.status == filterResultBlocked) {
        print('콘텐츠 차단: ${textResult.violations.join(', ')}');
        return false;
      }

      // 2. 이미지 필터링 (있는 경우)
      if (imageUrl != null) {
        final imageResult = filterImage(imageUrl);
        if (imageResult.status == filterResultBlocked) {
          print('이미지 차단: ${imageResult.violations.join(', ')}');
          return false;
        }
      }

      // 3. 의심스러운 콘텐츠는 일단 허용하되 모니터링 대상으로 표시
      if (textResult.status == filterResultSuspicious) {
        print('의심스러운 콘텐츠 감지 (모니터링 필요): ${textResult.violations.join(', ')}');
        // TODO: 관리자 검토 대기열에 추가
      }

      return true;
    } catch (e) {
      print('콘텐츠 필터링 오류: $e');
      // 오류 발생 시 안전을 위해 일단 허용 (UX 고려)
      return true;
    }
  }
}

/// 필터링 결과
class FilterResult {
  final String status; // 'clean', 'suspicious', 'blocked'
  final List<String> violations; // 위반 사항들

  const FilterResult(this.status, this.violations);

  bool get isClean => status == ContentFilterService.filterResultClean;
  bool get isSuspicious => status == ContentFilterService.filterResultSuspicious;
  bool get isBlocked => status == ContentFilterService.filterResultBlocked;
}

/// 사용자 신뢰도 레벨
enum UserTrustLevel {
  newUser,    // 신규 사용자
  reported,   // 신고당한 적이 있는 사용자  
  trusted,    // 신뢰받는 사용자 (오랫동안 문제없이 활동)
}