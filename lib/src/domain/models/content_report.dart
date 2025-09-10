import 'user_profile.dart';
import 'community_post.dart';
import 'community_comment.dart';

/// 콘텐츠 신고 모델
/// App Store Guideline 1.2 준수를 위한 신고 시스템
class ContentReport {
  final String id;
  final String reporterUserId; // 신고한 사용자
  final String reportedUserId; // 신고당한 사용자
  final ContentType contentType; // 신고된 콘텐츠 타입
  final String contentId; // 신고된 콘텐츠 ID
  final ReportReason reportReason; // 신고 이유
  final String? reportDescription; // 신고 상세 설명
  final ReportStatus status; // 신고 처리 상태
  final String? adminNotes; // 관리자 메모
  final DateTime? resolvedAt; // 처리 완료 시점
  final String? resolvedBy; // 처리한 관리자 ID
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관련 데이터 (조인된 데이터)
  final UserProfile? reporter; // 신고자 프로필
  final UserProfile? reportedUser; // 신고당한 사용자 프로필
  final CommunityPost? reportedPost; // 신고된 게시글 (contentType이 post인 경우)
  final CommunityComment? reportedComment; // 신고된 댓글 (contentType이 comment인 경우)

  const ContentReport({
    required this.id,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.contentType,
    required this.contentId,
    required this.reportReason,
    this.reportDescription,
    required this.status,
    this.adminNotes,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.reporter,
    this.reportedUser,
    this.reportedPost,
    this.reportedComment,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'] as String,
      reporterUserId: json['reporter_user_id'] as String,
      reportedUserId: json['reported_user_id'] as String,
      contentType: ContentType.fromString(json['content_type'] as String),
      contentId: json['content_id'] as String,
      reportReason: ReportReason.fromString(json['report_reason'] as String),
      reportDescription: json['report_description'] as String?,
      status: ReportStatus.fromString(json['status'] as String),
      adminNotes: json['admin_notes'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reporter: json['reporter'] != null
          ? UserProfile.fromJson(json['reporter'] as Map<String, dynamic>)
          : null,
      reportedUser: json['reported_user'] != null
          ? UserProfile.fromJson(json['reported_user'] as Map<String, dynamic>)
          : null,
      reportedPost: json['reported_post'] != null
          ? CommunityPost.fromJson(json['reported_post'] as Map<String, dynamic>)
          : null,
      reportedComment: json['reported_comment'] != null
          ? CommunityComment.fromJson(json['reported_comment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_user_id': reporterUserId,
      'reported_user_id': reportedUserId,
      'content_type': contentType.value,
      'content_id': contentId,
      'report_reason': reportReason.value,
      'report_description': reportDescription,
      'status': status.value,
      'admin_notes': adminNotes,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (reporter != null) 'reporter': reporter!.toJson(),
      if (reportedUser != null) 'reported_user': reportedUser!.toJson(),
      if (reportedPost != null) 'reported_post': reportedPost!.toJson(),
      if (reportedComment != null) 'reported_comment': reportedComment!.toJson(),
    };
  }

  /// 신고 후 경과 시간
  Duration get timeSinceReported => DateTime.now().difference(createdAt);

  /// 처리 완료 여부
  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.dismissed;

  /// 처리 대기 중인지 확인
  bool get isPending => status == ReportStatus.pending;

  /// 검토 중인지 확인
  bool get isUnderReview => status == ReportStatus.reviewing;

  /// 처리 시간 계산 (처리된 경우)
  Duration? get processingTime {
    if (resolvedAt != null) {
      return resolvedAt!.difference(createdAt);
    }
    return null;
  }

  ContentReport copyWith({
    String? id,
    String? reporterUserId,
    String? reportedUserId,
    ContentType? contentType,
    String? contentId,
    ReportReason? reportReason,
    String? reportDescription,
    ReportStatus? status,
    String? adminNotes,
    DateTime? resolvedAt,
    String? resolvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? reporter,
    UserProfile? reportedUser,
    CommunityPost? reportedPost,
    CommunityComment? reportedComment,
  }) {
    return ContentReport(
      id: id ?? this.id,
      reporterUserId: reporterUserId ?? this.reporterUserId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      reportReason: reportReason ?? this.reportReason,
      reportDescription: reportDescription ?? this.reportDescription,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reporter: reporter ?? this.reporter,
      reportedUser: reportedUser ?? this.reportedUser,
      reportedPost: reportedPost ?? this.reportedPost,
      reportedComment: reportedComment ?? this.reportedComment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 신고 대상 콘텐츠 타입
enum ContentType {
  post('post'),
  comment('comment');

  const ContentType(this.value);
  final String value;

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContentType.post,
    );
  }

  String getDisplayName(String languageCode) {
    switch (this) {
      case ContentType.post:
        return {
          'ko': '게시글',
          'en': 'Post',
          'ja': '投稿',
        }[languageCode] ?? 'Post';
      case ContentType.comment:
        return {
          'ko': '댓글',
          'en': 'Comment',
          'ja': 'コメント',
        }[languageCode] ?? 'Comment';
    }
  }
}

/// 신고 이유
enum ReportReason {
  harassment('harassment'),
  spam('spam'),
  inappropriateContent('inappropriate_content'),
  hateSpeech('hate_speech'),
  violence('violence'),
  personalInformation('personal_information'),
  sexualContent('sexual_content'),
  misinformation('misinformation'),
  copyright('copyright'),
  other('other');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => ReportReason.other,
    );
  }

  String getDisplayName(String languageCode) {
    switch (this) {
      case ReportReason.harassment:
        return {
          'ko': '괴롭힘/협박',
          'en': 'Harassment/Threats',
          'ja': 'ハラスメント/脅迫',
        }[languageCode] ?? 'Harassment/Threats';
      case ReportReason.spam:
        return {
          'ko': '스팸/광고',
          'en': 'Spam/Advertisement',
          'ja': 'スパム/広告',
        }[languageCode] ?? 'Spam/Advertisement';
      case ReportReason.inappropriateContent:
        return {
          'ko': '부적절한 내용',
          'en': 'Inappropriate Content',
          'ja': '不適切なコンテンツ',
        }[languageCode] ?? 'Inappropriate Content';
      case ReportReason.hateSpeech:
        return {
          'ko': '혐오 발언',
          'en': 'Hate Speech',
          'ja': 'ヘイトスピーチ',
        }[languageCode] ?? 'Hate Speech';
      case ReportReason.violence:
        return {
          'ko': '폭력적 내용',
          'en': 'Violent Content',
          'ja': '暴力的コンテンツ',
        }[languageCode] ?? 'Violent Content';
      case ReportReason.personalInformation:
        return {
          'ko': '개인정보 노출',
          'en': 'Personal Information Exposure',
          'ja': '個人情報の暴露',
        }[languageCode] ?? 'Personal Information Exposure';
      case ReportReason.sexualContent:
        return {
          'ko': '성적 내용',
          'en': 'Sexual Content',
          'ja': '性的コンテンツ',
        }[languageCode] ?? 'Sexual Content';
      case ReportReason.misinformation:
        return {
          'ko': '허위 정보',
          'en': 'Misinformation',
          'ja': '偽情報',
        }[languageCode] ?? 'Misinformation';
      case ReportReason.copyright:
        return {
          'ko': '저작권 침해',
          'en': 'Copyright Infringement',
          'ja': '著作権侵害',
        }[languageCode] ?? 'Copyright Infringement';
      case ReportReason.other:
        return {
          'ko': '기타',
          'en': 'Other',
          'ja': 'その他',
        }[languageCode] ?? 'Other';
    }
  }
}

/// 신고 처리 상태
enum ReportStatus {
  pending('pending'),
  reviewing('reviewing'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.pending,
    );
  }

  String getDisplayName(String languageCode) {
    switch (this) {
      case ReportStatus.pending:
        return {
          'ko': '처리 대기',
          'en': 'Pending',
          'ja': '処理待ち',
        }[languageCode] ?? 'Pending';
      case ReportStatus.reviewing:
        return {
          'ko': '검토 중',
          'en': 'Under Review',
          'ja': '審査中',
        }[languageCode] ?? 'Under Review';
      case ReportStatus.resolved:
        return {
          'ko': '처리 완료',
          'en': 'Resolved',
          'ja': '処理完了',
        }[languageCode] ?? 'Resolved';
      case ReportStatus.dismissed:
        return {
          'ko': '기각',
          'en': 'Dismissed',
          'ja': '却下',
        }[languageCode] ?? 'Dismissed';
    }
  }
}