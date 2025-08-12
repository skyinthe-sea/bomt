import 'community_category.dart';
import 'user_profile.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String categoryId;
  final String? title; // X 스타일: 제목 optional
  final String content;
  final List<String> images;
  final List<String> mosaicImages; // 모자이크 처리된 이미지 URL들
  final bool hasMosaic; // 이미지에 모자이크 처리가 있는지 여부
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isPinned;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 타임라인 관련
  final DateTime? timelineDate;
  final Map<String, dynamic>? timelineData;
  
  // 관련 데이터 (조인된 데이터)
  final UserProfile? author;
  final CommunityCategory? category;
  final bool? isLikedByCurrentUser;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.categoryId,
    this.title, // X 스타일: 제목 optional
    required this.content,
    required this.images,
    required this.mosaicImages,
    required this.hasMosaic,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.isPinned,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.timelineDate,
    this.timelineData,
    this.author,
    this.category,
    this.isLikedByCurrentUser,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>?;
    final images = imagesJson?.map((e) => e.toString()).toList() ?? <String>[];
    
    final mosaicImagesJson = json['mosaic_images'] as List<dynamic>?;
    final mosaicImages = mosaicImagesJson?.map((e) => e.toString()).toList() ?? <String>[];

    // 디버깅을 위한 로그
    if (json['category_id'] == null) {
      print('경고: category_id가 null인 게시글 발견: ${json['id']}');
    }

    try {
      return CommunityPost(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        categoryId: json['category_id']?.toString() ?? '', // 빈 문자열로 처리
        title: json['title'] as String?, // X 스타일: null 허용
        content: json['content'] as String? ?? '',
        images: images,
        mosaicImages: mosaicImages,
        hasMosaic: json['has_mosaic'] as bool? ?? false,
        viewCount: json['view_count'] as int? ?? 0,
        likeCount: json['like_count'] as int? ?? 0,
        commentCount: json['comment_count'] as int? ?? 0,
        isPinned: json['is_pinned'] as bool? ?? false,
        isDeleted: json['is_deleted'] as bool? ?? false,
        deletedAt: json['deleted_at'] != null 
            ? DateTime.parse(json['deleted_at'] as String) 
            : null,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        timelineDate: json['timeline_date'] != null 
            ? DateTime.parse(json['timeline_date'] as String)
            : null,
        timelineData: json['timeline_data'] as Map<String, dynamic>?,
        author: json['author'] != null 
            ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
            : null,
        category: json['category'] != null 
            ? CommunityCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        isLikedByCurrentUser: json['is_liked_by_current_user'] as bool?,
      );
    } catch (e) {
      print('ERROR: CommunityPost.fromJson 실패');
      print('ERROR 상세: $e');
      print('JSON 데이터: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'category_id': categoryId,
      if (title != null) 'title': title,
      'content': content,
      'images': images,
      'mosaic_images': mosaicImages,
      'has_mosaic': hasMosaic,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_pinned': isPinned,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (timelineDate != null) 'timeline_date': timelineDate!.toIso8601String().split('T')[0],
      if (timelineData != null) 'timeline_data': timelineData,
      if (author != null) 'author': author!.toJson(),
      if (category != null) 'category': category!.toJson(),
      if (isLikedByCurrentUser != null) 'is_liked_by_current_user': isLikedByCurrentUser,
    };
  }

  String get contentPreview {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
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

  bool get isEdited {
    // 1분 이상 차이나면 수정된 것으로 간주
    return updatedAt.difference(createdAt).inMinutes > 1;
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? categoryId,
    String? title, // X 스타일: nullable
    String? content,
    List<String>? images,
    List<String>? mosaicImages,
    bool? hasMosaic,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isPinned,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? timelineDate,
    Map<String, dynamic>? timelineData,
    UserProfile? author,
    CommunityCategory? category,
    bool? isLikedByCurrentUser,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      mosaicImages: mosaicImages ?? this.mosaicImages,
      hasMosaic: hasMosaic ?? this.hasMosaic,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timelineDate: timelineDate ?? this.timelineDate,
      timelineData: timelineData ?? this.timelineData,
      author: author ?? this.author,
      category: category ?? this.category,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}