import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/user_profile.dart';
import '../../services/community/community_service.dart';
import '../../services/community/user_profile_service.dart';
import '../../services/community/notification_service.dart';
import '../../services/auth/auth_service.dart';
import '../../core/config/supabase_config.dart';

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
        _comments = _sortCommentsWithPriority(newComments);
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
        final allComments = [..._comments, ...newComments];
        _comments = _sortCommentsWithPriority(allComments);
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
      
      final allComments = [..._comments, ...filteredComments];
      _comments = _sortCommentsWithPriority(allComments);
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

    // 본인 게시글 체크 (클라이언트 사이드)
    if (_post!.authorId == currentUserId) {
      return; // 아무것도 하지 않고 조용히 리턴
    }

    // 기존 상태 백업 (롤백용)
    final originalPost = _post!;
    final originalIsLiked = _post!.isLikedByCurrentUser ?? false;

    try {
      // 🚀 간단한 옵티미스틱 업데이트 (카운트는 서버에서 정확히 받아옴)
      _post = _post!.copyWith(
        isLikedByCurrentUser: !originalIsLiked,
      );
      notifyListeners();
      
      // RPC 함수가 정확한 결과를 반환하므로 그대로 사용
      final isLiked = await _communityService.togglePostLike(_post!.id, currentUserId!);
      
      // 서버에서 최신 상태를 가져와서 정확한 like_count 적용
      final updatedPost = await _communityService.getPost(_post!.id, currentUserId: currentUserId);
      if (updatedPost != null) {
        _post = updatedPost.copyWith(isLikedByCurrentUser: isLiked);
      } else {
        // fallback: 기본값으로 복원
        _post = originalPost;
      }
      notifyListeners();

      // 좋아요 알림 생성 (본인 제외)
      if (isLiked && _post!.authorId != currentUserId && _currentUserProfile != null) {
        await _notificationService.createPostLikeNotification(
          postId: _post!.id,
          postAuthorId: _post!.authorId,
          likerUserId: currentUserId!,
          likerNickname: _currentUserProfile!.nickname,
          postTitle: _post!.title ?? _post!.content.substring(0, _post!.content.length > 50 ? 50 : _post!.content.length),
        );
      }
    } catch (e) {
      // 에러 발생 시 원래 상태로 롤백
      _post = originalPost;
      _error = e.toString();
      notifyListeners();
    }
  }

  // 댓글 작성 (실시간 업데이트)
  Future<CommunityComment?> createComment({
    required String content,
    String? parentCommentId,
  }) async {
    debugPrint('DEBUG: createComment 시작');
    debugPrint('DEBUG: _post = ${_post?.id}');
    debugPrint('DEBUG: currentUserId = $currentUserId');
    debugPrint('DEBUG: content = $content');
    debugPrint('DEBUG: parentCommentId = $parentCommentId');
    
    if (_post == null) {
      debugPrint('DEBUG: ❌ _post가 null이어서 댓글 작성 불가');
      return null;
    }
    
    if (currentUserId == null) {
      debugPrint('DEBUG: ❌ currentUserId가 null이어서 댓글 작성 불가');
      return null;
    }

    try {
      debugPrint('DEBUG: _communityService.createComment 호출 중...');
      // 새 댓글 작성
      final newComment = await _communityService.createComment(
        postId: _post!.id,
        authorId: currentUserId!,
        content: content,
        parentCommentId: parentCommentId,
      );
      debugPrint('DEBUG: ✅ 댓글 작성 성공: ${newComment.id}');

      // 실시간 UI 업데이트
      if (parentCommentId == null) {
        // 일반 댓글인 경우 추가 후 우선순위 정렬
        debugPrint('DEBUG: 일반 댓글 - 추가 후 우선순위 정렬');
        _comments.add(newComment);
        _comments = _sortCommentsWithPriority(_comments);
        _totalCommentsCount++;
      } else {
        // 답글인 경우 부모 댓글의 하단에 추가 (기존 방식)
        debugPrint('DEBUG: 답글 - 부모 댓글에 추가');
        final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          debugPrint('DEBUG: 부모 댓글 찾음: $parentIndex');
          final parentComment = _comments[parentIndex];
          final updatedReplies = List<CommunityComment>.from(parentComment.replies ?? []);
          // 답글은 하단에 추가 (기존 방식 유지)
          updatedReplies.add(newComment);
          _comments[parentIndex] = parentComment.copyWith(replies: updatedReplies);
        } else {
          debugPrint('DEBUG: ❌ 부모 댓글을 찾을 수 없음: $parentCommentId');
        }
        _totalCommentsCount++;
      }
      
      debugPrint('DEBUG: UI 업데이트 완료, 총 댓글 수: $_totalCommentsCount');
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
          postTitle: _post!.title ?? _post!.content.substring(0, _post!.content.length > 50 ? 50 : _post!.content.length),
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
      
      debugPrint('DEBUG: 댓글 작성 프로세스 완료');
      return newComment;
    } catch (e) {
      debugPrint('DEBUG: ❌ 댓글 작성 실패: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // 댓글 좋아요 토글
  Future<void> toggleCommentLike(String commentId) async {
    if (currentUserId == null) return;

    final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    
    // 본인 댓글 체크 (클라이언트 사이드)
    if (comment.authorId == currentUserId) {
      return; // 아무것도 하지 않고 조용히 리턴
    }

    // 기존 상태 백업 (롤백용)
    final originalComment = comment;
    final originalIsLiked = comment.isLikedByCurrentUser ?? false;

    try {
      // 🚀 간단한 옵티미스틱 업데이트 (카운트는 서버에서 정확히 받아옴)
      _comments[commentIndex] = comment.copyWith(
        isLikedByCurrentUser: !originalIsLiked,
      );
      notifyListeners();
      
      // RPC 함수가 정확한 결과를 반환하므로 그대로 사용
      final isLiked = await _communityService.toggleCommentLike(commentId, currentUserId!);
      
      // 댓글 목록을 새로고침하여 정확한 like_count 적용
      await loadComments(_post!.id, refresh: true);
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
      // 에러 발생 시 원래 상태로 롤백
      _comments[commentIndex] = originalComment;
      _error = e.toString();
      notifyListeners();
    }
  }

  // 현재 사용자 ID 로드 (Supabase + 카카오 통합)
  Future<void> _loadCurrentUserId() async {
    debugPrint('DEBUG: CommunityPostProvider _loadCurrentUserId 시작');
    try {
      // 🔐 1순위: Supabase 사용자 확인 (이메일 계정)
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser != null) {
        _currentUserId = supabaseUser.id;
        debugPrint('DEBUG: ✅ CommunityPostProvider Supabase 사용자 발견: $_currentUserId (이메일: ${supabaseUser.email})');
        return;
      } else {
        debugPrint('DEBUG: CommunityPostProvider Supabase 사용자 없음, 카카오 확인 중...');
      }
      
      // 🥇 2순위: 카카오 로그인 사용자 확인
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService(prefs);
      final kakaoUser = await authService.getCurrentUser();
      
      if (kakaoUser != null) {
        _currentUserId = kakaoUser.id.toString();
        debugPrint('DEBUG: ✅ CommunityPostProvider 카카오 사용자 발견: $_currentUserId');
      } else {
        _currentUserId = null;
        debugPrint('DEBUG: ❌ CommunityPostProvider 카카오 사용자도 없음, _currentUserId = null');
      }
    } catch (e) {
      debugPrint('DEBUG: CommunityPostProvider _loadCurrentUserId 예외 발생: $e');
      _currentUserId = null;
    }
    debugPrint('DEBUG: CommunityPostProvider _loadCurrentUserId 완료, 최종 _currentUserId = $_currentUserId');
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

  // 트위터 방식의 댓글 우선순위 정렬
  List<CommunityComment> _sortCommentsWithPriority(List<CommunityComment> comments) {
    if (comments.isEmpty || currentUserId == null) {
      return comments;
    }

    final postAuthorId = _post?.authorId;
    final myComments = <CommunityComment>[];
    final authorComments = <CommunityComment>[];
    final otherComments = <CommunityComment>[];

    // 댓글을 카테고리별로 분류
    for (final comment in comments) {
      if (comment.authorId == currentUserId) {
        myComments.add(comment);
      } else if (postAuthorId != null && comment.authorId == postAuthorId) {
        authorComments.add(comment);
      } else {
        otherComments.add(comment);
      }
    }

    // 각 그룹 내에서 선택된 정렬 순서 적용
    void sortByOrder(List<CommunityComment> commentsToSort) {
      if (_commentSortOrder == 'like_count') {
        // 좋아요순 (내림차순)
        commentsToSort.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      } else {
        // 최신순 (내림차순)
        commentsToSort.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    sortByOrder(myComments);
    sortByOrder(authorComments);
    sortByOrder(otherComments);

    // 트위터 방식 순서: 작성자 댓글 → 본인 댓글 → 나머지 댓글
    return [...authorComments, ...myComments, ...otherComments];
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