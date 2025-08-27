import 'dart:async';
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
  StreamSubscription<DataSyncEvent>? _eventSubscription;
  bool _isDisposed = false;

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
    debugPrint('=' * 100);
    debugPrint('🏠 [MY_POSTS] Initializing my posts provider');
    debugPrint('=' * 100);
    
    try {
      // AuthService 초기화
      debugPrint('📋 [MY_POSTS] STEP 1: SharedPreferences 초기화 중...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ [MY_POSTS] SharedPreferences 초기화 완료');
      
      debugPrint('📋 [MY_POSTS] STEP 2: AuthService 초기화 중...');
      _authService = AuthService(prefs);
      debugPrint('✅ [MY_POSTS] AuthService 초기화 완료');
      
      // 현재 사용자 ID 가져오기 (실제 user_id UUID 형태)
      debugPrint('📋 [MY_POSTS] STEP 3: getCurrentUserProfileId() 호출 중...');
      debugPrint('    - 호출 전 _currentUserId: $_currentUserId');
      
      _currentUserId = await _authService!.getCurrentUserProfileId();
      
      debugPrint('    - 호출 후 _currentUserId: $_currentUserId');
      debugPrint('    - _currentUserId 타입: ${_currentUserId.runtimeType}');
      debugPrint('    - _currentUserId == null: ${_currentUserId == null}');
      debugPrint('    - _currentUserId?.isEmpty: ${_currentUserId?.isEmpty}');
      
      if (_currentUserId == null) {
        debugPrint('❌ [MY_POSTS] No current user ID found');
        debugPrint('=' * 100);
        return;
      }

      debugPrint('✅ [MY_POSTS] Current user ID: $_currentUserId');

      // 캐시에서 데이터 로드 시도
      debugPrint('📋 [MY_POSTS] STEP 4: 캐시에서 데이터 로드 시도...');
      await _loadFromCache();
      debugPrint('✅ [MY_POSTS] 캐시 로드 완료 - Posts: ${_myPosts.length}, Comments: ${_myComments.length}');

      // 캐시가 비어있거나 오래된 경우 새로 로드
      final isCacheExpired = _cache.isCacheExpired(_currentUserId!);
      debugPrint('📋 [MY_POSTS] STEP 5: 캐시 상태 확인');
      debugPrint('    - _myPosts.isEmpty: ${_myPosts.isEmpty}');
      debugPrint('    - isCacheExpired: $isCacheExpired');
      debugPrint('    - 새로운 데이터 로드 필요: ${_myPosts.isEmpty || isCacheExpired}');
      
      if (_myPosts.isEmpty || isCacheExpired) {
        debugPrint('📋 [MY_POSTS] STEP 6: 새로운 데이터 로드 중...');
        await _loadFreshData();
        debugPrint('✅ [MY_POSTS] 새 데이터 로드 완료 - Posts: ${_myPosts.length}, Comments: ${_myComments.length}');
      } else {
        debugPrint('✅ [MY_POSTS] 캐시된 데이터 사용 중');
      }

      // 이벤트 리스너 등록
      debugPrint('📋 [MY_POSTS] STEP 7: 이벤트 리스너 등록...');
      _listenToEvents();
      debugPrint('✅ [MY_POSTS] 이벤트 리스너 등록 완료');

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
    debugPrint('🔄 [MY_POSTS] _loadMyPosts 시작 - refresh: $refresh');
    
    if (_currentUserId == null) {
      debugPrint('❌ [MY_POSTS] _currentUserId가 null이어서 종료');
      return;
    }
    if (_isLoadingPosts) {
      debugPrint('❌ [MY_POSTS] 이미 로딩 중이어서 종료');
      return;
    }
    if (!refresh && !_hasMorePosts) {
      debugPrint('❌ [MY_POSTS] 더 이상 로드할 데이터가 없어서 종료');
      return;
    }

    try {
      _isLoadingPosts = true;
      if (refresh) {
        _postsPage = 0;
        _hasMorePosts = true;
        debugPrint('🔄 [MY_POSTS] 페이지 초기화: $_postsPage');
      }
      notifyListeners();

      debugPrint('🌐 [MY_POSTS] API 호출 중...');
      debugPrint('    - userId: $_currentUserId');
      debugPrint('    - page: $_postsPage');
      debugPrint('    - pageSize: $_pageSize');
      
      final posts = await _service.getMyPosts(
        userId: _currentUserId!,
        page: _postsPage,
        pageSize: _pageSize,
      );

      debugPrint('📥 [MY_POSTS] API 응답 수신');
      debugPrint('    - 받은 posts 개수: ${posts.length}');
      debugPrint('    - 각 post의 author_id:');
      for (int i = 0; i < posts.length; i++) {
        debugPrint('      [$i] ${posts[i].id} - author: ${posts[i].authorId}');
        debugPrint('      [$i] 제목: ${posts[i].title ?? "제목없음"}');
        debugPrint('      [$i] 내용: ${posts[i].content.length > 50 ? posts[i].content.substring(0, 50) + "..." : posts[i].content}');
      }

      if (refresh) {
        _myPosts = posts;
        debugPrint('🔄 [MY_POSTS] 전체 교체 완료 - 총 ${_myPosts.length}개');
      } else {
        final oldLength = _myPosts.length;
        _myPosts.addAll(posts);
        debugPrint('🔄 [MY_POSTS] 추가 완료 - ${oldLength}개 → ${_myPosts.length}개');
      }

      _hasMorePosts = posts.length == _pageSize;
      _postsPage++;

      debugPrint('📊 [MY_POSTS] 상태 업데이트');
      debugPrint('    - _hasMorePosts: $_hasMorePosts');
      debugPrint('    - _postsPage: $_postsPage');

      // 캐시 업데이트
      debugPrint('💾 [MY_POSTS] 캐시 업데이트 중...');
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
    _eventSubscription?.cancel(); // 기존 구독 취소
    _eventSubscription = _eventBus.dataSyncStream.listen((event) {
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
    
    // dispose된 경우 처리 중단
    if (_isDisposed) {
      debugPrint('🔄 [MY_POSTS] Provider disposed, skipping refresh');
      return;
    }

    try {
      // 캐시 무효화
      await _cache.invalidateCache(_currentUserId!);
      
      // dispose 확인 후 새로고침
      if (!_isDisposed) {
        // 백그라운드에서 새로고침 (UI 블로킹 방지)
        _loadFreshData();
      } else {
        debugPrint('🔄 [MY_POSTS] Provider disposed during cache invalidation');
      }
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS] Error invalidating cache: $e');
    }
  }

  /// 리소스 정리
  @override
  void dispose() {
    debugPrint('🗑️ [MY_POSTS] Disposing provider');
    _isDisposed = true; // dispose 상태 표시
    _eventSubscription?.cancel(); // 이벤트 구독 취소
    debugPrint('🗑️ [MY_POSTS] Event subscription cancelled');
    super.dispose();
  }
}