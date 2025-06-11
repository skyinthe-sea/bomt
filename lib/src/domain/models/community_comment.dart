import 'user_profile.dart';

class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String? parentCommentId;
  final String content;
  final int likeCount;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 관련 데이터
  final UserProfile? author;
  final bool? isLikedByCurrentUser;
  final List<CommunityComment>? replies;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentCommentId,
    required this.content,
    required this.likeCount,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.isLikedByCurrentUser,
    this.replies,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'] as List<dynamic>?;
    final replies = repliesJson?.map((e) => 
        CommunityComment.fromJson(e as Map<String, dynamic>)).toList();

    return CommunityComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int,
      isDeleted: json['is_deleted'] as bool,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null 
          ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool?,
      replies: replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'like_count': likeCount,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (author != null) 'author': author!.toJson(),
      if (isLikedByCurrentUser != null) 'is_liked_by_current_user': isLikedByCurrentUser,
      if (replies != null) 'replies': replies!.map((e) => e.toJson()).toList(),
    };
  }

  bool get isReply => parentCommentId != null;

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

  bool get isEdited {
    // 1분 이상 차이나면 수정된 것으로 간주
    return updatedAt.difference(createdAt).inMinutes > 1;
  }

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? parentCommentId,
    String? content,
    int? likeCount,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? author,
    bool? isLikedByCurrentUser,
    List<CommunityComment>? replies,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      replies: replies ?? this.replies,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}