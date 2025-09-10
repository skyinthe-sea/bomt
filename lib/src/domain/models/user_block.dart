import 'user_profile.dart';

/// 사용자 차단 관계 모델
/// App Store Guideline 1.2 준수를 위한 사용자 차단 시스템
class UserBlock {
  final String id;
  final String blockerUserId; // 차단한 사용자
  final String blockedUserId; // 차단당한 사용자
  final String? reason; // 차단 이유
  final DateTime createdAt;

  // 관련 데이터 (조인된 데이터)
  final UserProfile? blockedUser; // 차단당한 사용자 프로필

  const UserBlock({
    required this.id,
    required this.blockerUserId,
    required this.blockedUserId,
    this.reason,
    required this.createdAt,
    this.blockedUser,
  });

  factory UserBlock.fromJson(Map<String, dynamic> json) {
    return UserBlock(
      id: json['id'] as String,
      blockerUserId: json['blocker_user_id'] as String,
      blockedUserId: json['blocked_user_id'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      blockedUser: json['blocked_user'] != null
          ? UserProfile.fromJson(json['blocked_user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blocker_user_id': blockerUserId,
      'blocked_user_id': blockedUserId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      if (blockedUser != null) 'blocked_user': blockedUser!.toJson(),
    };
  }

  /// 차단 후 경과 시간
  Duration get timeSinceBlocked => DateTime.now().difference(createdAt);

  /// 차단된 지 며칠인지 (일 단위)
  int get daysSinceBlocked => timeSinceBlocked.inDays;

  UserBlock copyWith({
    String? id,
    String? blockerUserId,
    String? blockedUserId,
    String? reason,
    DateTime? createdAt,
    UserProfile? blockedUser,
  }) {
    return UserBlock(
      id: id ?? this.id,
      blockerUserId: blockerUserId ?? this.blockerUserId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      blockedUser: blockedUser ?? this.blockedUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserBlock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 차단 이유 enum
enum BlockReason {
  harassment('harassment'),
  spam('spam'),
  inappropriateContent('inappropriate_content'),
  hateSpeech('hate_speech'),
  violence('violence'),
  personalInformation('personal_information'),
  other('other');

  const BlockReason(this.value);
  final String value;

  static BlockReason fromString(String value) {
    return BlockReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => BlockReason.other,
    );
  }

  String getDisplayName(String languageCode) {
    switch (this) {
      case BlockReason.harassment:
        return {
          'ko': '괴롭힘/협박',
          'en': 'Harassment/Threats',
          'ja': 'ハラスメント/脅迫',
        }[languageCode] ?? 'Harassment/Threats';
      case BlockReason.spam:
        return {
          'ko': '스팸/광고',
          'en': 'Spam/Advertisement',
          'ja': 'スパム/広告',
        }[languageCode] ?? 'Spam/Advertisement';
      case BlockReason.inappropriateContent:
        return {
          'ko': '부적절한 내용',
          'en': 'Inappropriate Content',
          'ja': '不適切なコンテンツ',
        }[languageCode] ?? 'Inappropriate Content';
      case BlockReason.hateSpeech:
        return {
          'ko': '혐오 발언',
          'en': 'Hate Speech',
          'ja': 'ヘイトスピーチ',
        }[languageCode] ?? 'Hate Speech';
      case BlockReason.violence:
        return {
          'ko': '폭력적 내용',
          'en': 'Violent Content',
          'ja': '暴力的コンテンツ',
        }[languageCode] ?? 'Violent Content';
      case BlockReason.personalInformation:
        return {
          'ko': '개인정보 노출',
          'en': 'Personal Information Exposure',
          'ja': '個人情報の暴露',
        }[languageCode] ?? 'Personal Information Exposure';
      case BlockReason.other:
        return {
          'ko': '기타',
          'en': 'Other',
          'ja': 'その他',
        }[languageCode] ?? 'Other';
    }
  }
}

/// 사용자 차단 상태 요약
class UserBlockStatus {
  final String userId;
  final List<UserBlock> blockedUsers; // 내가 차단한 사용자들
  final List<UserBlock> blockingUsers; // 나를 차단한 사용자들 (알 필요 없음, 내부용)
  final int totalBlockedCount;
  final DateTime lastUpdated;

  const UserBlockStatus({
    required this.userId,
    required this.blockedUsers,
    required this.blockingUsers,
    required this.totalBlockedCount,
    required this.lastUpdated,
  });

  /// 특정 사용자를 차단했는지 확인
  bool isUserBlocked(String targetUserId) {
    return blockedUsers.any((block) => block.blockedUserId == targetUserId);
  }

  /// 특정 사용자에게 차단당했는지 확인 (내부 로직용)
  bool isBlockedBy(String targetUserId) {
    return blockingUsers.any((block) => block.blockerUserId == targetUserId);
  }

  /// 차단한 사용자 ID 목록
  List<String> get blockedUserIds {
    return blockedUsers.map((block) => block.blockedUserId).toList();
  }
}