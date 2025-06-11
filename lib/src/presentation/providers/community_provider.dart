import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_category.dart';
import '../../domain/models/user_profile.dart';
import '../../services/community/community_service.dart';
import '../../services/community/user_profile_service.dart';
import '../../services/community/notification_service.dart';
import '../../services/auth/auth_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  final UserProfileService _userProfileService = UserProfileService();
  final NotificationService _notificationService = NotificationService();

  // State
  List<CommunityCategory> _categories = [];
  List<CommunityPost> _posts = [];
  String _selectedCategorySlug = 'all';
  String _postSortOrder = 'like_count'; // 'like_count' | 'created_at'
  bool _isLoading = false;
  bool _hasMorePosts = true;
  String? _error;
  UserProfile? _currentUserProfile;
  String? _currentUserId;

  // Getters
  List<CommunityCategory> get categories => _categories;
  List<CommunityPost> get posts => _posts;
  String get selectedCategorySlug => _selectedCategorySlug;
  String get postSortOrder => _postSortOrder;
  bool get isLoading => _isLoading;
  bool get hasMorePosts => _hasMorePosts;
  String? get error => _error;
  UserProfile? get currentUserProfile => _currentUserProfile;
  String? get currentUserId => _currentUserId;

  // 카테고리 로드
  Future<void> loadCategories() async {
    try {
      final categories = await _communityService.getCategories();
      
      // 데이터베이스에서 가져온 카테고리 중 'all' slug가 있는지 확인
      final hasAllCategory = categories.any((cat) => cat.slug == 'all');
      final hasPopularCategory = categories.any((cat) => cat.slug == 'popular');
      
      final systemCategories = <CommunityCategory>[];
      
      // "전체" 카테고리가 DB에 없는 경우에만 추가
      if (!hasAllCategory) {
        systemCategories.add(
          CommunityCategory(
            id: 'all',
            name: '전체',
            slug: 'all',
            description: '모든 카테고리의 게시글을 볼 수 있습니다',
            color: '#6366F1',
            icon: 'grid',
            displayOrder: 0,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // "인기" 카테고리가 DB에 없는 경우에만 추가
      if (!hasPopularCategory) {
        systemCategories.add(
          CommunityCategory(
            id: 'popular',
            name: '인기',
            slug: 'popular',
            description: '오늘 가장 인기 있는 게시글 TOP50을 볼 수 있습니다',
            color: '#EF4444',
            icon: 'fire',
            displayOrder: 1,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      
      // 시스템 카테고리를 앞에, DB 카테고리를 뒤에 배치
      // 카테고리 순서: "전체" → "인기" → 기타
      final allCategories = [...systemCategories, ...categories];
      
      // 순서대로 정렬
      allCategories.sort((a, b) {
        if (a.slug == 'all') return -1;
        if (b.slug == 'all') return 1;
        if (a.slug == 'popular') return -1;
        if (b.slug == 'popular') return 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
      
      _categories = allCategories;
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 게시글 목록 로드
  Future<void> loadPosts({bool refresh = false}) async {
    // 중복 호출 방지 강화
    if (!refresh && (_isLoading || !_hasMorePosts)) {
      return;
    }
    
    if (refresh) {
      _posts.clear();
      _hasMorePosts = true;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('게시글 로드 - 카테고리: $_selectedCategorySlug, 정렬: $_postSortOrder');
      final newPosts = await _communityService.getPosts(
        categorySlug: _selectedCategorySlug,
        orderBy: _postSortOrder,
        ascending: false,
        limit: 20,
        offset: refresh ? 0 : _posts.length,
        currentUserId: currentUserId,
      );

      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }

      // 가져온 데이터가 20개 미만이면 더 이상 데이터가 없음
      _hasMorePosts = newPosts.length >= 20;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카테고리 변경
  Future<void> selectCategory(String categorySlug) async {
    if (_selectedCategorySlug == categorySlug) return;
    
    print('카테고리 변경: $_selectedCategorySlug -> $categorySlug');
    _selectedCategorySlug = categorySlug;
    await loadPosts(refresh: true);
  }
  
  // 게시글 정렬 순서 변경
  Future<void> changePostSortOrder(String sortOrder) async {
    if (_postSortOrder == sortOrder) return;
    
    _postSortOrder = sortOrder;
    await loadPosts(refresh: true);
  }

  // 게시글 좋아요 토글
  Future<void> togglePostLike(String postId) async {
    if (currentUserId == null) return;

    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      final isLiked = await _communityService.togglePostLike(postId, currentUserId!);
      
      _posts[postIndex] = post.copyWith(
        isLikedByCurrentUser: isLiked,
        likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
      );
      notifyListeners();

      // 좋아요 알림 생성 (본인 제외)
      if (isLiked && post.authorId != currentUserId && _currentUserProfile != null) {
        await _notificationService.createPostLikeNotification(
          postId: postId,
          postAuthorId: post.authorId,
          likerUserId: currentUserId!,
          likerNickname: _currentUserProfile!.nickname,
          postTitle: post.title,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 게시글 작성
  Future<CommunityPost?> createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? images,
  }) async {
    if (currentUserId == null) {
      return null;
    }

    try {
      final post = await _communityService.createPost(
        authorId: currentUserId!,
        categoryId: categoryId,
        title: title,
        content: content,
        images: images,
      );

      // 현재 카테고리가 전체이거나 해당 카테고리인 경우 목록에 추가
      if (_selectedCategorySlug == 'all' || 
          _categories.any((cat) => cat.id == categoryId && cat.slug == _selectedCategorySlug)) {
        _posts.insert(0, post);
        notifyListeners();
      }

      return post;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // 게시글 수정
  Future<CommunityPost?> updatePost({
    required String postId,
    required String categoryId,
    required String title,
    required String content,
    List<String>? images,
  }) async {
    if (currentUserId == null) return null;

    try {
      final updatedPost = await _communityService.updatePost(
        postId: postId,
        authorId: currentUserId!,
        categoryId: categoryId,
        title: title,
        content: content,
        images: images,
      );

      // 목록에서 해당 게시글 업데이트
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }

      return updatedPost;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // 게시글 삭제
  Future<bool> deletePost(String postId) async {
    if (currentUserId == null) return false;

    try {
      final success = await _communityService.deletePost(postId, currentUserId!);
      
      if (success) {
        // 목록에서 해당 게시글 제거
        _posts.removeWhere((post) => post.id == postId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 사용자 프로필 로드
  Future<void> loadCurrentUserProfile() async {
    if (currentUserId == null) {
      return;
    }

    try {
      _currentUserProfile = await _userProfileService.getOrCreateCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 사용자 프로필 업데이트
  Future<bool> updateUserProfile({
    String? nickname,
    String? profileImageUrl,
    String? bio,
  }) async {
    if (currentUserId == null) {
      return false;
    }

    try {
      _currentUserProfile = await _userProfileService.updateUserProfile(
        userId: currentUserId!,
        nickname: nickname,
        profileImageUrl: profileImageUrl,
        bio: bio,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
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

  // 초기화
  Future<void> initialize() async {
    try {
      print('DEBUG: CommunityProvider 초기화 시작');
      
      await _loadCurrentUserId();
      print('DEBUG: 사용자 ID 로드 완료: $_currentUserId');
      
      await Future.wait([
        loadCategories(),
        loadCurrentUserProfile(),
      ]);
      print('DEBUG: 카테고리 로드 완료: ${_categories.length}개');
      print('DEBUG: 사용자 프로필 로드 완료: $_currentUserProfile');
      
      await loadPosts(refresh: true);
      print('DEBUG: 게시글 로드 완료: ${_posts.length}개');
      
    } catch (e, stackTrace) {
      print('ERROR: CommunityProvider 초기화 실패');
      print('ERROR 상세: $e');
      print('스택 트레이스: $stackTrace');
      _error = e.toString();
      notifyListeners();
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }
}