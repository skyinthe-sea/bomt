enum NotificationType {
  like('like'),
  comment('comment'),
  reply('reply'),
  mention('mention');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.like,
    );
  }
}

enum NotificationReferenceType {
  post('post'),
  comment('comment');

  const NotificationReferenceType(this.value);
  final String value;

  static NotificationReferenceType fromString(String value) {
    return NotificationReferenceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationReferenceType.post,
    );
  }
}

class CommunityNotification {
  final String id;
  final String recipientId;
  final String? senderId;
  final NotificationType type;
  final String title;
  final String? content;
  final String? referenceId;
  final NotificationReferenceType? referenceType;
  final bool isRead;
  final DateTime createdAt;

  const CommunityNotification({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.title,
    this.content,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.createdAt,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNotification(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      senderId: json['sender_id'] as String?,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String?,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] != null 
          ? NotificationReferenceType.fromString(json['reference_type'] as String)
          : null,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': type.value,
      'title': title,
      'content': content,
      'reference_id': referenceId,
      'reference_type': referenceType?.value,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.month}/${createdAt.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  CommunityNotification copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    NotificationType? type,
    String? title,
    String? content,
    String? referenceId,
    NotificationReferenceType? referenceType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return CommunityNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}