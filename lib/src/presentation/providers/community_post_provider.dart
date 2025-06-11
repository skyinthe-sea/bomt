import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/user_profile.dart';
import '../../services/community/community_service.dart';
import '../../services/community/user_profile_service.dart';
import '../../services/community/notification_service.dart';
import '../../services/auth/auth_service.dart';

class CommunityPostProvider with ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  final UserProfileService _userProfileService = UserProfileService();
  final NotificationService _notificationService = NotificationService();

  // State
  CommunityPost? _post;
  List<CommunityComment> _comments = [];
  Map<String, int> _commentReplyCount = {}; // 댓글별 답글 수
  Map<String, bool> _commentHasMoreReplies = {}; // 댓글별 더 많은 답글 여부
  bool _isLoading = false;
  bool _isCommentsLoading = false;
  bool _isLoadingMoreComments = false;
  String? _error;
  UserProfile? _currentUserProfile;
  String? _currentUserId;
  
  // 댓글 페이징 및 정렬 상태
  String _commentSortOrder = 'like_count'; // 'like_count' | 'created_at'
  int _commentOffset = 0;
  int _commentLimit = 10;
  bool _hasMoreComments = true;
  int _totalCommentsCount = 0;

  // Getters
  CommunityPost? get post => _post;
  List<CommunityComment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isCommentsLoading => _isCommentsLoading;
  bool get isLoadingMoreComments => _isLoadingMoreComments;
  String? get error => _error;
  UserProfile? get currentUserProfile => _currentUserProfile;
  String? get currentUserId => _currentUserId;
  String get commentSortOrder => _commentSortOrder;
  bool get hasMoreComments => _hasMoreComments;
  int get totalCommentsCount => _totalCommentsCount;
  
  // 댓글별 답글 정보 조회
  int getReplyCount(String commentId) => _commentReplyCount[commentId] ?? 0;
  bool hasMoreReplies(String commentId) => _commentHasMoreReplies[commentId] ?? false;

  // 게시글 로드
  Future<void> loadPost(String postId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _post = await _communityService.getPost(postId, currentUserId: currentUserId);
      
      if (_post == null) {
        _error = '게시글을 찾을 수 없습니다.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 댓글 로드 (초기 로드)
  Future<void> loadComments(String postId, {bool refresh = false}) async {
    try {
      _isCommentsLoading = true;
      if (refresh) {
        _commentOffset = 0;
        _comments.clear();
        _hasMoreComments = true;
      }
      notifyListeners();

      final result = await _communityService.getComments(
        postId,
        currentUserId: currentUserId,
        limit: _commentLimit,
        offset: _commentOffset,
        orderBy: _commentSortOrder, // 현재 선택된 정렬 순서 사용
      );
      
      final commentsWithMeta = result['comments'] as List<Map<String, dynamic>>;
      _totalCommentsCount = result['totalCount'] as int;
      _hasMoreComments = result['hasMore'] as bool;
      
      // 댓글과 메타데이터 분리
      final newComments = <CommunityComment>[];
      for (final meta in commentsWithMeta) {
        final comment = meta['comment'] as CommunityComment;
        final totalReplyCount = meta['totalReplyCount'] as int;
        final hasMoreReplies = meta['hasMoreReplies'] as bool;
        
        newComments.add(comment);
        _commentReplyCount[comment.id] = totalReplyCount;
        _commentHasMoreReplies[comment.id] = hasMoreReplies;
      }
      
      if (refresh) {
        _comments = newComments;
        _commentReplyCount.clear();
        _commentHasMoreReplies.clear();
        // 새로운 메타데이터로 다시 채우기
        for (final meta in commentsWithMeta) {
          final comment = meta['comment'] as CommunityComment;
          final totalReplyCount = meta['totalReplyCount'] as int;
          final hasMoreReplies = meta['hasMoreReplies'] as bool;
          
          _commentReplyCount[comment.id] = totalReplyCount;
          _commentHasMoreReplies[comment.id] = hasMoreReplies;
        }
      } else {
        _comments.addAll(newComments);
      }
      
      _commentOffset += newComments.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isCommentsLoading = false;
      notifyListeners();
    }
  }
  
  // 더 많은 댓글 로드 (인피니티 스크롤)
  Future<void> loadMoreComments(String postId) async {
    if (!_hasMoreComments || _isLoadingMoreComments) return;
    
    try {
      _isLoadingMoreComments = true;
      notifyListeners();

      final result = await _communityService.getComments(
        postId,
        currentUserId: currentUserId,
        limit: _commentLimit,
        offset: _commentOffset,
        orderBy: _commentSortOrder, // 현재 선택된 정렬 순서 사용
      );
      
      final commentsWithMeta = result['comments'] as List<Map<String, dynamic>>;
      _hasMoreComments = result['hasMore'] as bool;
      
      // 댓글과 메타데이터 분리
      final newComments = <CommunityComment>[];
      for (final meta in commentsWithMeta) {
        final comment = meta['comment'] as CommunityComment;
        final totalReplyCount = meta['totalReplyCount'] as int;
        final hasMoreReplies = meta['hasMoreReplies'] as bool;
        
        newComments.add(comment);
        _commentReplyCount[comment.id] = totalReplyCount;
        _commentHasMoreReplies[comment.id] = hasMoreReplies;
      }
      
      // 중복 댓글 제거 후 추가
      final existingIds = _comments.map((c) => c.id).toSet();
      final filteredComments = newComments.where((comment) => !existingIds.contains(comment.id)).toList();
      
      _comments.addAll(filteredComments);
      _commentOffset += newComments.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMoreComments = false;
      notifyListeners();
    }
  }
  
  // 댓글 정렬 순서 변경
  Future<void> changeCommentSortOrder(String postId, String sortOrder) async {
    if (_commentSortOrder == sortOrder) return;
    
    _commentSortOrder = sortOrder;
    await loadComments(postId, refresh: true);
  }

  // 게시글 좋아요 토글
  Future<void> togglePostLike() async {
    if (_post == null || currentUserId == null) return;

    try {
      final isLiked = await _communityService.togglePostLike(_post!.id, currentUserId!);
      
      _post = _post!.copyWith(
        isLikedByCurrentUser: isLiked,
        likeCount: isLiked ? _post!.likeCount + 1 : _post!.likeCount - 1,
      );
      notifyListeners();

      // 좋아요 알림 생성 (본인 제외)
      if (isLiked && _post!.authorId != currentUserId && _currentUserProfile != null) {
        await _notificationService.createPostLikeNotification(
          postId: _post!.id,
          postAuthorId: _post!.authorId,
          likerUserId: currentUserId!,
          likerNickname: _currentUserProfile!.nickname,
          postTitle: _post!.title,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 댓글 작성 (실시간 업데이트)
  Future<CommunityComment?> createComment({
    required String content,
    String? parentCommentId,
  }) async {
    if (_post == null || currentUserId == null) return null;

    try {
      // 새 댓글 작성
      final newComment = await _communityService.createComment(
        postId: _post!.id,
        authorId: currentUserId!,
        content: content,
        parentCommentId: parentCommentId,
      );

      // 실시간 UI 업데이트
      if (parentCommentId == null) {
        // 일반 댓글인 경우 최상단에 추가
        _comments.insert(0, newComment);
        _totalCommentsCount++;
      } else {
        // 답글인 경우 부모 댓글의 하단에 추가 (기존 방식)
        final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          final parentComment = _comments[parentIndex];
          final updatedReplies = List<CommunityComment>.from(parentComment.replies ?? []);
          // 답글은 하단에 추가 (기존 방식 유지)
          updatedReplies.add(newComment);
          _comments[parentIndex] = parentComment.copyWith(replies: updatedReplies);
        }
        _totalCommentsCount++;
      }
      
      // 게시글의 댓글 수 업데이트
      _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
      notifyListeners();

      // 댓글 알림 생성 (본인 제외)
      if (_post!.authorId != currentUserId && _currentUserProfile != null) {
        await _notificationService.createCommentNotification(
          postId: _post!.id,
          postAuthorId: _post!.authorId,
          commenterUserId: currentUserId!,
          commenterNickname: _currentUserProfile!.nickname,
          postTitle: _post!.title,
        );
      }

      // 대댓글인 경우 원댓글 작성자에게도 알림
      if (parentCommentId != null && _currentUserProfile != null) {
        try {
          final parentComment = _comments.firstWhere(
            (c) => c.id == parentCommentId,
          );
          
          if (parentComment.authorId != currentUserId) {
            await _notificationService.createReplyNotification(
              postId: _post!.id,
              parentCommentAuthorId: parentComment.authorId,
              replierUserId: currentUserId!,
              replierNickname: _currentUserProfile!.nickname,
              replyContent: content,
            );
          }
        } catch (e) {
          // 부모 댓글을 찾을 수 없는 경우 알림을 건너뜀
          print('Parent comment not found for reply notification: $e');
        }
      }
      
      return newComment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // 댓글 좋아요 토글
  Future<void> toggleCommentLike(String commentId) async {
    if (currentUserId == null) return;

    try {
      final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex == -1) return;

      final comment = _comments[commentIndex];
      final isLiked = await _communityService.toggleCommentLike(commentId, currentUserId!);
      
      _comments[commentIndex] = comment.copyWith(
        isLikedByCurrentUser: isLiked,
        likeCount: isLiked ? comment.likeCount + 1 : comment.likeCount - 1,
      );
      notifyListeners();

      // 댓글 좋아요 알림 생성 (본인 제외)
      if (isLiked && comment.authorId != currentUserId && _currentUserProfile != null) {
        await _notificationService.createCommentLikeNotification(
          commentId: commentId,
          commentAuthorId: comment.authorId,
          likerUserId: currentUserId!,
          likerNickname: _currentUserProfile!.nickname,
          commentContent: comment.content,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 카카오 사용자 ID 로드
  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService(prefs);
      final kakaoUser = await authService.getCurrentUser();
      
      if (kakaoUser != null) {
        _currentUserId = kakaoUser.id.toString();
      } else {
        _currentUserId = null;
      }
    } catch (e) {
      _currentUserId = null;
    }
  }

  // 사용자 프로필 로드
  Future<void> loadCurrentUserProfile() async {
    if (currentUserId == null) return;

    try {
      _currentUserProfile = await _userProfileService.getOrCreateCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 초기화
  Future<void> initialize(String postId) async {
    await _loadCurrentUserId();
    await Future.wait([
      loadPost(postId),
      loadComments(postId),
      loadCurrentUserProfile(),
    ]);
  }

  // 댓글 수정
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    if (currentUserId == null) return;

    try {
      final updatedComment = await _communityService.updateComment(
        commentId: commentId,
        authorId: currentUserId!,
        content: content,
      );

      // 댓글 목록에서 해당 댓글 업데이트
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
        notifyListeners();
      } else {
        // 답글인 경우 답글 목록에서 찾아서 업데이트
        for (int i = 0; i < _comments.length; i++) {
          final comment = _comments[i];
          if (comment.replies != null) {
            final replyIndex = comment.replies!.indexWhere((reply) => reply.id == commentId);
            if (replyIndex != -1) {
              final updatedReplies = List<CommunityComment>.from(comment.replies!);
              updatedReplies[replyIndex] = updatedComment;
              _comments[i] = comment.copyWith(replies: updatedReplies);
              notifyListeners();
              break;
            }
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 댓글 삭제 (소프트 삭제)
  Future<void> deleteComment(String commentId) async {
    if (currentUserId == null) return;

    try {
      final deletedComment = await _communityService.deleteComment(commentId, currentUserId!);
      
      // 댓글 목록에서 해당 댓글을 삭제된 상태로 업데이트
      final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex != -1) {
        _comments[commentIndex] = deletedComment;
      } else {
        // 답글인 경우 답글 목록에서 찾아서 업데이트
        for (int i = 0; i < _comments.length; i++) {
          final comment = _comments[i];
          if (comment.replies != null) {
            final replyIndex = comment.replies!.indexWhere((reply) => reply.id == commentId);
            if (replyIndex != -1) {
              final updatedReplies = List<CommunityComment>.from(comment.replies!);
              updatedReplies[replyIndex] = deletedComment;
              _comments[i] = comment.copyWith(replies: updatedReplies);
              break;
            }
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 특정 댓글의 모든 답글 로드
  Future<void> loadAllReplies(String commentId) async {
    try {
      final allReplies = await _communityService.getCommentReplies(
        commentId,
        currentUserId: currentUserId,
      );
      
      // 해당 댓글을 찾아서 답글을 업데이트
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        _comments[commentIndex] = comment.copyWith(replies: allReplies);
        
        // 메타데이터 업데이트 (모든 답글을 로드했으므로 더 이상 없음)
        _commentHasMoreReplies[commentId] = false;
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 댓글 작성자 확인
  bool isCommentAuthor(String commentAuthorId) {
    return currentUserId != null && currentUserId == commentAuthorId;
  }

  // 데이터 클리어
  void clear() {
    _post = null;
    _comments.clear();
    _error = null;
    _commentOffset = 0;
    _hasMoreComments = true;
    _totalCommentsCount = 0;
    notifyListeners();
  }
}