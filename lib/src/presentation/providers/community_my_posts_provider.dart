import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../services/community/community_my_posts_service.dart';
import '../../services/community/community_my_posts_cache_service.dart';
import '../../services/auth/auth_service.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

class CommunityMyPostsProvider with ChangeNotifier {
  final CommunityMyPostsService _service = CommunityMyPostsService();
  final CommunityMyPostsCacheService _cache = CommunityMyPostsCacheService.instance;
  AuthService? _authService;
  final AppEventBus _eventBus = AppEventBus.instance;

  // State
  List<CommunityPost> _myPosts = [];
  List<CommunityComment> _myComments = [];
  bool _isLoadingPosts = false;
  bool _isLoadingComments = false;
  bool _hasMorePosts = true;
  bool _hasMoreComments = true;
  String? _error;
  String? _currentUserId;

  // Pagination
  static const int _pageSize = 20;
  int _postsPage = 0;
  int _commentsPage = 0;

  // Getters
  List<CommunityPost> get myPosts => _myPosts;
  List<CommunityComment> get myComments => _myComments;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingComments => _isLoadingComments;
  bool get hasMorePosts => _hasMorePosts;
  bool get hasMoreComments => _hasMoreComments;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  /// 초기화
  Future<void> initialize() async {
    debugPrint('🏠 [MY_POSTS] Initializing my posts provider');
    
    try {
      // AuthService 초기화
      final prefs = await SharedPreferences.getInstance();
      _authService = AuthService(prefs);
      
      // 현재 사용자 ID 가져오기
      final currentUser = await _authService!.getCurrentUser();
      _currentUserId = currentUser?.id.toString();
      if (_currentUserId == null) {
        debugPrint('❌ [MY_POSTS] No current user ID found');
        return;
      }

      debugPrint('✅ [MY_POSTS] Current user ID: $_currentUserId');

      // 캐시에서 데이터 로드 시도
      await _loadFromCache();

      // 캐시가 비어있거나 오래된 경우 새로 로드
      if (_myPosts.isEmpty || _cache.isCacheExpired(_currentUserId!)) {
        await _loadFreshData();
      }

      // 이벤트 리스너 등록
      _listenToEvents();

    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error initializing: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 캐시에서 데이터 로드
  Future<void> _loadFromCache() async {
    if (_currentUserId == null) return;

    try {
      final cachedPosts = await _cache.getCachedPosts(_currentUserId!);
      final cachedComments = await _cache.getCachedComments(_currentUserId!);

      if (cachedPosts.isNotEmpty || cachedComments.isNotEmpty) {
        _myPosts = cachedPosts;
        _myComments = cachedComments;
        debugPrint('📦 [MY_POSTS] Loaded from cache: ${cachedPosts.length} posts, ${cachedComments.length} comments');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error loading from cache: $e');
    }
  }

  /// 새로운 데이터 로드
  Future<void> _loadFreshData() async {
    if (_currentUserId == null) return;

    debugPrint('🔄 [MY_POSTS] Loading fresh data');
    await Future.wait([
      _loadMyPosts(refresh: true),
      _loadMyComments(refresh: true),
    ]);
  }

  /// 내 글 목록 로드
  Future<void> _loadMyPosts({bool refresh = false}) async {
    if (_currentUserId == null) return;
    if (_isLoadingPosts) return;
    if (!refresh && !_hasMorePosts) return;

    try {
      _isLoadingPosts = true;
      if (refresh) {
        _postsPage = 0;
        _hasMorePosts = true;
      }
      notifyListeners();

      final posts = await _service.getMyPosts(
        userId: _currentUserId!,
        page: _postsPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _myPosts = posts;
      } else {
        _myPosts.addAll(posts);
      }

      _hasMorePosts = posts.length == _pageSize;
      _postsPage++;

      // 캐시 업데이트
      await _cache.cacheMyPosts(_currentUserId!, _myPosts);

      debugPrint('📝 [MY_POSTS] Loaded ${posts.length} posts, total: ${_myPosts.length}');

    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error loading posts: $e');
      _error = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  /// 내 댓글 목록 로드
  Future<void> _loadMyComments({bool refresh = false}) async {
    if (_currentUserId == null) return;
    if (_isLoadingComments) return;
    if (!refresh && !_hasMoreComments) return;

    try {
      _isLoadingComments = true;
      if (refresh) {
        _commentsPage = 0;
        _hasMoreComments = true;
      }
      notifyListeners();

      final comments = await _service.getMyComments(
        userId: _currentUserId!,
        page: _commentsPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _myComments = comments;
      } else {
        _myComments.addAll(comments);
      }

      _hasMoreComments = comments.length == _pageSize;
      _commentsPage++;

      // 캐시 업데이트
      await _cache.cacheMyComments(_currentUserId!, _myComments);

      debugPrint('💬 [MY_POSTS] Loaded ${comments.length} comments, total: ${_myComments.length}');

    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error loading comments: $e');
      _error = e.toString();
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  /// 더 많은 내 글 로드
  Future<void> loadMorePosts() async {
    await _loadMyPosts();
  }

  /// 더 많은 내 댓글 로드
  Future<void> loadMoreComments() async {
    await _loadMyComments();
  }

  /// 내 글 새로고침
  Future<void> refreshPosts() async {
    await _loadMyPosts(refresh: true);
  }

  /// 내 댓글 새로고침
  Future<void> refreshComments() async {
    await _loadMyComments(refresh: true);
  }

  /// 전체 새로고침
  Future<void> refresh() async {
    await _loadFreshData();
  }

  /// 이벤트 리스너 등록
  void _listenToEvents() {
    _eventBus.dataSyncStream.listen((event) {
      if (_currentUserId == null) return;

      // 커뮤니티 관련 이벤트만 처리
      if (!_isCommunityRelevantEvent(event.type)) return;

      debugPrint('🔄 [MY_POSTS] Received community event: ${event.type}');
      
      // 캐시 무효화 및 데이터 새로고침
      _invalidateCacheAndRefresh();
    });
  }

  /// 커뮤니티 관련 이벤트인지 확인
  bool _isCommunityRelevantEvent(DataSyncEventType eventType) {
    const relevantEvents = [
      DataSyncEventType.communityPostCreated,
      DataSyncEventType.communityPostUpdated,
      DataSyncEventType.communityPostDeleted,
      DataSyncEventType.communityCommentCreated,
      DataSyncEventType.communityCommentUpdated,
      DataSyncEventType.communityCommentDeleted,
    ];
    
    return relevantEvents.contains(eventType);
  }

  /// 캐시 무효화 및 새로고침
  Future<void> _invalidateCacheAndRefresh() async {
    if (_currentUserId == null) return;

    try {
      // 캐시 무효화
      await _cache.invalidateCache(_currentUserId!);
      
      // 백그라운드에서 새로고침 (UI 블로킹 방지)
      _loadFreshData();
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error invalidating cache: $e');
    }
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('🗑️ [MY_POSTS] Disposing provider');
    super.dispose();
  }
}