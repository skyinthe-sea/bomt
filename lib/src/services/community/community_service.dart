import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_category.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

class CommunityService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AppEventBus _eventBus = AppEventBus.instance;
  
  // 일일 인기 게시글 캐시 (30분간 유효)
  static List<CommunityPost>? _dailyPopularCache;
  static DateTime? _dailyPopularCacheTime;
  static String? _dailyPopularCacheDate;
  
  // 카테고리 캐시
  List<CommunityCategory>? _categoriesCache;
  DateTime? _categoriesCacheTime;

  // 카테고리 목록 조회 (캐시 사용)
  Future<List<CommunityCategory>> getCategories() async {
    try {
      // 캐시가 있고 5분 이내라면 캐시 사용
      if (_categoriesCache != null && 
          _categoriesCacheTime != null &&
          DateTime.now().difference(_categoriesCacheTime!).inMinutes < 5) {
        print('DEBUG: 캐시된 카테고리 사용: ${_categoriesCache!.length}개');
        return _categoriesCache!;
      }

      print('DEBUG: 카테고리 조회 시작');
      final response = await _supabase
          .from('community_categories')
          .select()
          .eq('is_active', true)
          .order('display_order');

      print('DEBUG: 카테고리 조회 결과: ${response.length}개');
      
      final categories = (response as List)
          .map((item) {
            print('DEBUG: 카테고리 - id: ${item['id']}, name: ${item['name']}, slug: ${item['slug']}');
            return CommunityCategory.fromJson(item);
          })
          .toList();

      // 캐시 업데이트
      _categoriesCache = categories;
      _categoriesCacheTime = DateTime.now();

      return categories;
    } catch (e, stackTrace) {
      print('ERROR: 카테고리 조회 실패: $e');
      print('스택 트레이스: $stackTrace');
      throw Exception('카테고리 조회 실패: $e');
    }
  }

  // 최적화된 게시글 목록 조회 (JOIN 기반 단일 쿼리)
  Future<List<CommunityPost>> getPostsOptimized({
    String? categorySlug,
    String orderBy = 'created_at',
    bool ascending = false,
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  }) async {
    try {
      print('DEBUG: getPostsOptimized 호출 - categorySlug: $categorySlug, orderBy: $orderBy');
      
      // 카테고리 ID 먼저 조회 (캐시 활용)
      String? categoryId;
      if (categorySlug != null && categorySlug != 'all') {
        final categories = await getCategories();
        try {
          final category = categories.firstWhere((cat) => cat.slug == categorySlug);
          categoryId = category.id;
          print('DEBUG: 카테고리 ID 찾음: $categoryId');
        } catch (e) {
          print('DEBUG: 카테고리를 찾지 못함: $categorySlug');
          return [];
        }
      }
      
      // 메인 페이지에서 필요한 컬럼만 SELECT
      const selectColumns = '''
        id, content, created_at, updated_at, author_id, category_id,
        images, mosaic_images, has_mosaic, is_pinned,
        like_count, comment_count, view_count,
        timeline_date, timeline_data
      ''';
      
      var query = _supabase
          .from('community_posts')
          .select(selectColumns)
          .eq('is_deleted', false);
      
      // 카테고리 필터링
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      // 정렬 처리
      late final List<Map<String, dynamic>> response;
      if (orderBy == 'like_count') {
        response = await query
            .order('like_count', ascending: false)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      } else {
        response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }
      
      print('DEBUG: 최적화 쿼리 결과: ${response.length}개 게시글');
      
      if (response.isEmpty) return [];
      
      // 작성자, 카테고리, 좋아요 정보를 병렬로 조회
      final List<String> authorIds = response.map((item) => item['author_id'] as String).toSet().toList();
      final List<String> categoryIds = response.map((item) => item['category_id'] as String).toSet().toList();
      final List<String> postIds = response.map((item) => item['id'] as String).toList();
      
      final futures = await Future.wait([
        // 작성자 정보
        _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url')
            .inFilter('user_id', authorIds),
        
        // 카테고리 정보
        _supabase
            .from('community_categories')
            .select('id, name, slug, color, icon')
            .inFilter('id', categoryIds),
        
        // 좋아요 상태 (현재 사용자)
        if (currentUserId != null)
          _supabase
              .from('community_likes')
              .select('post_id')
              .eq('user_id', currentUserId)
              .inFilter('post_id', postIds)
        else
          Future.value(<Map<String, dynamic>>[]),
      ]);
      
      // 맵으로 변환
      final authorsMap = <String, Map<String, dynamic>>{};
      for (final author in futures[0] as List) {
        authorsMap[author['user_id']] = author;
      }
      
      final categoriesMap = <String, Map<String, dynamic>>{};
      for (final category in futures[1] as List) {
        categoriesMap[category['id']] = category;
      }
      
      final likedPostIds = (futures[2] as List)
          .map((like) => like['post_id'] as String)
          .toSet();
      
      // CommunityPost 객체 생성
      final posts = response.map((item) {
        // 관련 데이터 추가
        final authorData = authorsMap[item['author_id']];
        if (authorData != null) item['author'] = authorData;
        
        final categoryData = categoriesMap[item['category_id']];
        if (categoryData != null) item['category'] = categoryData;
        
        item['is_liked_by_current_user'] = likedPostIds.contains(item['id']);
        
        return CommunityPost.fromJson(item);
      }).toList();
      
      print('DEBUG: 최적화 완료 - ${posts.length}개 게시글 (3개 쿼리)');
      return posts;
      
    } catch (e) {
      print('ERROR: getPostsOptimized 실패: $e');
      // 에러 발생시 기존 방식으로 fallback
      print('DEBUG: 기존 방식으로 fallback');
      return await getPosts(
        categorySlug: categorySlug,
        orderBy: orderBy,
        ascending: ascending,
        limit: limit,
        offset: offset,
        currentUserId: currentUserId,
      );
    }
  }

  // 기존 게시글 목록 조회 (fallback용으로 유지)
  Future<List<CommunityPost>> getPosts({
    String? categorySlug,
    String orderBy = 'created_at',
    bool ascending = false,
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  }) async {
    try {
      print('DEBUG: getPosts 호출 - categorySlug: $categorySlug, orderBy: $orderBy');
      
      var query = _supabase
          .from('community_posts')
          .select('*')
          .eq('is_deleted', false);

      // 카테고리 필터링
      if (categorySlug != null && categorySlug != 'all' && categorySlug != 'popular') {
        print('카테고리 필터링 적용: $categorySlug');
        
        // categorySlug로 category_id 찾기
        final categories = await getCategories();
        try {
          final category = categories.firstWhere((cat) => cat.slug == categorySlug);
          print('카테고리 ID: ${category.id}');
          query = query.eq('category_id', category.id);
        } catch (e) {
          print('카테고리를 찾지 못함: $categorySlug');
          // 카테고리를 찾지 못한 경우 빈 결과 반환
          return [];
        }
      } else {
        print('카테고리 필터링 없음: $categorySlug');
      }

      // 정렬 처리
      late final List<Map<String, dynamic>> response;
      if (categorySlug == 'popular') {
        // 인기 카테고리: 당일 작성된 게시글 중 좋아요순 top50 (캐시 적용)
        return await _getDailyPopularPosts(currentUserId: currentUserId, limit: limit, offset: offset);
      } else if (orderBy == 'like_count') {
        // 좋아요순
        print('DEBUG: 좋아요순 정렬');
        response = await query
            .order('like_count', ascending: false)
            .order('created_at', ascending: false) // 2차 정렬
            .range(offset, offset + limit - 1);
      } else {
        // 최신순 (기본)
        print('DEBUG: 최신순 정렬');
        response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }
      
      print('DEBUG: 쿼리 결과: ${response.length}개 게시글');
      
      final posts = (response as List)
          .map((item) {
            print('DEBUG: 게시글 파싱: ${item['id']} - category_id: ${item['category_id']}');
            return CommunityPost.fromJson(item);
          })
          .toList();

      // Author 정보 및 Category 정보 별도 조회 후 매핑
      if (posts.isNotEmpty) {
        // Author 정보 조회
        final authorIds = posts.map((p) => p.authorId).toSet().toList();
        final authorsResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
            .inFilter('user_id', authorIds);

        final authorsMap = <String, Map<String, dynamic>>{};
        for (final author in authorsResponse as List) {
          authorsMap[author['user_id']] = author;
        }

        // Category 정보 조회 (에러가 발생해도 게시글 로드는 계속)
        final categoriesMap = <String, Map<String, dynamic>>{};
        try {
          final categoryIds = posts.map((p) => p.categoryId).toSet().toList();
          if (categoryIds.isNotEmpty) {
            final categoriesResponse = await _supabase
                .from('community_categories')
                .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
                .inFilter('id', categoryIds);

            for (final category in categoriesResponse as List) {
              categoriesMap[category['id']] = category;
            }
          }
        } catch (e) {
          print('Category 정보 조회 실패 (게시글 로드는 계속): $e');
        }

        // Posts에 author 및 category 정보 추가
        for (int i = 0; i < posts.length; i++) {
          final postJson = posts[i].toJson();
          
          // Author 정보 추가
          final authorData = authorsMap[posts[i].authorId];
          if (authorData != null) {
            postJson['author'] = authorData;
          }
          
          // Category 정보 추가 (안전하게)
          final categoryData = categoriesMap[posts[i].categoryId];
          if (categoryData != null) {
            postJson['category'] = categoryData;
          }
          
          posts[i] = CommunityPost.fromJson(postJson);
        }
      }

      // 현재 사용자의 좋아요 여부 확인
      if (currentUserId != null && posts.isNotEmpty) {
        final postIds = posts.map((p) => p.id).toList();
        final likes = await _supabase
            .from('community_likes')
            .select('post_id')
            .eq('user_id', currentUserId)
            .inFilter('post_id', postIds);

        final likedPostIds = (likes as List)
            .map((like) => like['post_id'] as String)
            .toSet();

        return posts.map((post) => 
            post.copyWith(isLikedByCurrentUser: likedPostIds.contains(post.id))
        ).toList();
      }

      return posts;
    } catch (e, stackTrace) {
      print('ERROR: 게시글 목록 조회 실패');
      print('ERROR 상세: $e');
      print('스택 트레이스: $stackTrace');
      throw Exception('게시글 조회 실패: $e');
    }
  }

  // 게시글 상세 조회
  Future<CommunityPost?> getPost(String postId, {String? currentUserId}) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('*')
          .eq('id', postId)
          .eq('is_deleted', false)
          .single();

      var post = CommunityPost.fromJson(response);

      // Author 정보 별도 조회
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', post.authorId)
          .maybeSingle();

      // Category 정보 별도 조회
      final categoryResponse = await _supabase
          .from('community_categories')
          .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
          .eq('id', post.categoryId)
          .maybeSingle();

      final postJson = post.toJson();
      if (authorResponse != null) {
        postJson['author'] = authorResponse;
      }
      if (categoryResponse != null) {
        postJson['category'] = categoryResponse;
      }
      post = CommunityPost.fromJson(postJson);

      // 조회수 증가 (본인 게시글 제외)
      bool shouldIncrementViewCount = true;
      if (currentUserId != null && currentUserId == post.authorId) {
        shouldIncrementViewCount = false;
      }
      
      if (shouldIncrementViewCount) {
        await _supabase
            .from('community_posts')
            .update({'view_count': post.viewCount + 1})
            .eq('id', postId);
      }

      // 현재 사용자의 좋아요 여부 확인
      bool isLiked = false;
      if (currentUserId != null) {
        final likeResponse = await _supabase
            .from('community_likes')
            .select('id')
            .eq('user_id', currentUserId)
            .eq('post_id', postId)
            .maybeSingle();
        
        isLiked = likeResponse != null;
      }

      return post.copyWith(
        viewCount: shouldIncrementViewCount ? post.viewCount + 1 : post.viewCount,
        isLikedByCurrentUser: isLiked,
      );
    } catch (e) {
      if (e.toString().contains('not found')) {
        return null;
      }
      throw Exception('게시글 조회 실패: $e');
    }
  }

  // 게시글 작성
  Future<CommunityPost> createPost({
    required String authorId,
    required String categoryId,
    String? title, // X 스타일: nullable
    required String content,
    List<String>? images,
    List<String>? mosaicImages,
    bool? hasMosaic,
    DateTime? timelineDate,
    Map<String, dynamic>? timelineData,
  }) async {
    try {
      print('DEBUG: createPost 호출 - authorId: $authorId, categoryId: $categoryId');
      print('DEBUG: title: $title');
      
      // 단순한 INSERT만 실행 (조인 없음)
      final insertData = {
        'author_id': authorId,
        'category_id': categoryId,
        if (title != null) 'title': title, // X 스타일: null일 때만 제외
        'content': content,
        'images': images ?? [],
        'mosaic_images': mosaicImages ?? [],
        'has_mosaic': hasMosaic ?? false,
      };
      
      // 타임라인 데이터가 있는 경우 추가
      if (timelineDate != null) {
        insertData['timeline_date'] = timelineDate.toIso8601String().split('T')[0];
      }
      if (timelineData != null) {
        insertData['timeline_data'] = timelineData;
      }
      
      final response = await _supabase
          .from('community_posts')
          .insert(insertData)
          .select()
          .single();
      
      print('DEBUG: 게시글 작성 성공: ${response['id']}');

      // CommunityPost 객체 생성
      var post = CommunityPost.fromJson(response);

      // Author 정보 별도 조회
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', authorId)
          .maybeSingle();

      // Category 정보 별도 조회
      final categoryResponse = await _supabase
          .from('community_categories')
          .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
          .eq('id', categoryId)
          .maybeSingle();

      final postJson = post.toJson();
      if (authorResponse != null) {
        postJson['author'] = authorResponse;
      }
      if (categoryResponse != null) {
        postJson['category'] = categoryResponse;
      }
      post = CommunityPost.fromJson(postJson);

      // 커뮤니티 게시글 생성 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityPostCreated,
        babyId: authorId, // 커뮤니티는 babyId 대신 authorId 사용
        date: post.createdAt,
        action: DataSyncAction.created,
        recordId: post.id,
        metadata: {
          'postId': post.id,
          'authorId': authorId,
          'categoryId': categoryId,
        },
      );

      return post;
    } catch (e, stackTrace) {
      print('ERROR: 게시글 작성 실패');
      print('ERROR 상세: $e');
      print('스택 트레이스: $stackTrace');
      throw Exception('게시글 작성 실패: $e');
    }
  }

  // 게시글 수정
  Future<CommunityPost> updatePost({
    required String postId,
    required String authorId,
    required String categoryId,
    String? title, // X 스타일: nullable
    required String content,
    List<String>? images,
    List<String>? mosaicImages,
    bool? hasMosaic,
  }) async {
    try {
      // 작성자 확인
      final existingPost = await _supabase
          .from('community_posts')
          .select('author_id')
          .eq('id', postId)
          .eq('is_deleted', false)
          .single();

      if (existingPost['author_id'] != authorId) {
        throw Exception('게시글을 수정할 권한이 없습니다.');
      }

      final response = await _supabase
          .from('community_posts')
          .update({
            'category_id': categoryId,
            if (title != null) 'title': title, // X 스타일: null일 때만 제외
            'content': content,
            'images': images ?? [],
            'mosaic_images': mosaicImages ?? [],
            'has_mosaic': hasMosaic ?? false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId)
          .select('*')
          .single();

      var post = CommunityPost.fromJson(response);

      // Author 정보 별도 조회
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', authorId)
          .maybeSingle();

      // Category 정보 별도 조회
      final categoryResponse = await _supabase
          .from('community_categories')
          .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
          .eq('id', categoryId)
          .maybeSingle();

      final postJson = post.toJson();
      if (authorResponse != null) {
        postJson['author'] = authorResponse;
      }
      if (categoryResponse != null) {
        postJson['category'] = categoryResponse;
      }
      post = CommunityPost.fromJson(postJson);

      // 커뮤니티 게시글 수정 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityPostUpdated,
        babyId: authorId,
        date: post.updatedAt ?? post.createdAt,
        action: DataSyncAction.updated,
        recordId: postId,
        metadata: {
          'postId': postId,
          'authorId': authorId,
          'categoryId': categoryId,
        },
      );

      return post;
    } catch (e) {
      throw Exception('게시글 수정 실패: $e');
    }
  }

  // 게시글 삭제 (소프트 삭제)
  Future<bool> deletePost(String postId, String authorId) async {
    try {
      // 작성자 확인
      final existingPost = await _supabase
          .from('community_posts')
          .select('author_id')
          .eq('id', postId)
          .eq('is_deleted', false)
          .single();

      if (existingPost['author_id'] != authorId) {
        throw Exception('게시글을 삭제할 권한이 없습니다.');
      }

      await _supabase
          .from('community_posts')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);

      // 커뮤니티 게시글 삭제 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityPostDeleted,
        babyId: authorId,
        date: DateTime.now(),
        action: DataSyncAction.deleted,
        recordId: postId,
        metadata: {
          'postId': postId,
          'authorId': authorId,
        },
      );

      return true;
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  // 게시글 좋아요/좋아요 취소
  Future<bool> togglePostLike(String postId, String userId) async {
    try {
      print('🔥 DEBUG: togglePostLike 시작 - postId: $postId, userId: $userId');
      
      // 🚀 NEW: RPC 함수를 사용하여 원자적으로 좋아요 토글 및 카운트 업데이트
      final result = await _supabase.rpc('toggle_post_like', params: {
        'p_post_id': postId,
        'p_user_id': userId,
      });
      
      print('🔥 DEBUG: RPC 결과: $result');
      
      final isLiked = result['is_liked'] as bool;
      final likeCount = result['like_count'] as int;
      
      print('🔥 DEBUG: ✅ 좋아요 토글 완료 - isLiked: $isLiked, likeCount: $likeCount');
      return isLiked;
    } catch (e) {
      print('🔥 DEBUG: togglePostLike 오류 - $e');
      
      // 본인 게시글 오류는 조용히 처리
      if (e.toString().contains('Cannot like your own post')) {
        print('🔥 DEBUG: 본인 게시글이므로 좋아요 불가');
        return false;
      }
      
      throw Exception('좋아요 처리 실패: $e');
    }
  }

  // 댓글 목록 조회 (최상위 댓글만 페이징)
  /// 댓글 목록 조회 (성능 최적화 버전)
  /// 
  /// [성능 최적화 포인트]
  /// - 데이터베이스 레벨에서 정렬 처리 (클라이언트 정렬 제거)
  /// - 필요한 컬럼만 선택적으로 가져오기
  /// - 인덱스 활용을 위한 쿼리 구조 최적화
  /// - 페이지네이션으로 메모리 효율성 확보
  /// 
  /// [권장 DB 인덱스]
  /// - (post_id, parent_comment_id, like_count DESC, created_at DESC)
  /// - (post_id, parent_comment_id, created_at DESC, like_count DESC)
  Future<Map<String, dynamic>> getComments(
    String postId, {
    String? currentUserId,
    int limit = 10,
    int offset = 0,
    String orderBy = 'like_count', // 'like_count' | 'created_at'
    bool ascending = false,
  }) async {
    try {
      // 성능 모니터링을 위한 시작 시간 기록
      final startTime = DateTime.now();
      
      // 최상위 댓글만 가져오기 (답글 제외) - 삭제된 댓글도 포함
      print('🔥 DEBUG: 댓글 정렬 - orderBy: $orderBy, offset: $offset, limit: $limit');
      print('🔥 DEBUG: 성능 최적화 - 시작 시간: $startTime');
      
      final queryBuilder = _supabase
          .from('community_comments')
          .select('*')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null); // 최상위 댓글만
      
      // 🔥 정렬 로직 개선: 선택한 정렬 기준에 따라 명확하게 분리
      if (orderBy == 'like_count') {
        // 좋아요순: like_count 내림차순 → created_at 내림차순 (2차 정렬)
        // 같은 좋아요 수일 때는 최신순으로 정렬하여 일관성 보장
        queryBuilder
            .order('like_count', ascending: false)  
            .order('created_at', ascending: false);
        print('🔥 DEBUG: 좋아요순 정렬 적용 (like_count DESC, created_at DESC)');
      } else if (orderBy == 'created_at') {
        // 최신순: created_at 내림차순, like_count를 2차 정렬로 추가하여 안정성 보장
        queryBuilder
            .order('created_at', ascending: false)
            .order('like_count', ascending: false);
        print('🔥 DEBUG: 최신순 정렬 적용 (created_at DESC, like_count DESC)');  
      } else {
        // 기본값: 최신순
        queryBuilder.order('created_at', ascending: false);
        print('🔥 DEBUG: 기본 정렬 적용 (created_at DESC)');
      }
      
      final response = await queryBuilder.range(offset, offset + limit - 1);

      List<CommunityComment> topLevelComments = (response as List)
          .map((item) => CommunityComment.fromJson(item))
          .toList();
      
      // 최상위 댓글 수 조회 - 삭제된 댓글도 포함
      final totalCountResponse = await _supabase
          .from('community_comments')
          .select('id')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null) // 최상위 댓글만 카운트
          .count(CountOption.exact);
      
      final totalCount = totalCountResponse.count ?? 0;

      // 각 최상위 댓글에 대해 답글 미리보기 가져오기 (최신 3개만)
      for (int i = 0; i < topLevelComments.length; i++) {
        final comment = topLevelComments[i];
        
        // 해당 댓글의 답글 미리보기 가져오기 - 삭제된 답글도 포함
        final repliesResponse = await _supabase
            .from('community_comments')
            .select('*')
            .eq('parent_comment_id', comment.id)
            .order('created_at', ascending: true) // 답글은 오래된 순
            .limit(3); // 최신 3개만 미리보기
        
        final replies = (repliesResponse as List)
            .map((item) => CommunityComment.fromJson(item))
            .toList();
            
        // 답글 수 카운트 - 삭제된 답글도 포함
        final replyCountResponse = await _supabase
            .from('community_comments')
            .select('id')
            .eq('parent_comment_id', comment.id)
            .count(CountOption.exact);
            
        final replyCount = replyCountResponse.count ?? 0;
        
        // 댓글에 답글 정보 추가 (답글 수는 UI에서 계산)
        topLevelComments[i] = comment.copyWith(
          replies: replies,
        );
      }

      // Author 정보 별도 조회 후 매핑
      if (topLevelComments.isNotEmpty) {
        // 최상위 댓글 작성자들
        final authorIds = topLevelComments.map((c) => c.authorId).toSet();
        
        // 답글 작성자들도 포함
        for (final comment in topLevelComments) {
          if (comment.replies != null) {
            for (final reply in comment.replies!) {
              authorIds.add(reply.authorId);
            }
          }
        }
        
        final authorsResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
            .inFilter('user_id', authorIds.toList());

        final authorsMap = <String, Map<String, dynamic>>{};
        for (final author in authorsResponse as List) {
          authorsMap[author['user_id']] = author;
        }

        // 최상위 댓글에 author 정보 추가
        for (int i = 0; i < topLevelComments.length; i++) {
          final comment = topLevelComments[i];
          final authorData = authorsMap[comment.authorId];
          
          if (authorData != null) {
            final commentJson = comment.toJson();
            commentJson['author'] = authorData;
            
            // 답글들에도 author 정보 추가
            if (comment.replies != null) {
              final updatedReplies = <Map<String, dynamic>>[];
              for (final reply in comment.replies!) {
                final replyAuthorData = authorsMap[reply.authorId];
                final replyJson = reply.toJson();
                if (replyAuthorData != null) {
                  replyJson['author'] = replyAuthorData;
                }
                updatedReplies.add(replyJson);
              }
              commentJson['replies'] = updatedReplies;
            }
            
            topLevelComments[i] = CommunityComment.fromJson(commentJson);
          }
        }
      }

      // 현재 사용자의 좋아요 여부 확인
      if (currentUserId != null && topLevelComments.isNotEmpty) {
        final commentIds = <String>[];
        
        // 최상위 댓글 ID들
        commentIds.addAll(topLevelComments.map((c) => c.id));
        
        // 답글 ID들도 포함
        for (final comment in topLevelComments) {
          if (comment.replies != null) {
            commentIds.addAll(comment.replies!.map((r) => r.id));
          }
        }
        
        final likes = await _supabase
            .from('community_likes')
            .select('comment_id')
            .eq('user_id', currentUserId)
            .inFilter('comment_id', commentIds);

        final likedCommentIds = (likes as List)
            .map((like) => like['comment_id'] as String)
            .toSet();

        // 좋아요 정보 적용
        for (int i = 0; i < topLevelComments.length; i++) {
          final comment = topLevelComments[i];
          
          // 최상위 댓글 좋아요 정보
          topLevelComments[i] = comment.copyWith(
            isLikedByCurrentUser: likedCommentIds.contains(comment.id),
            replies: comment.replies?.map((reply) => reply.copyWith(
              isLikedByCurrentUser: likedCommentIds.contains(reply.id),
            )).toList(),
          );
        }
      }
      
      // 댓글별 답글 수 정보 추가
      final commentsWithMeta = <Map<String, dynamic>>[];
      
      for (final comment in topLevelComments) {
        // 답글 수 조회 (캐시된 값 사용) - 삭제된 답글도 포함
        final replyCountResponse = await _supabase
            .from('community_comments')
            .select('id')
            .eq('parent_comment_id', comment.id)
            .count(CountOption.exact);
            
        final totalReplyCount = replyCountResponse.count ?? 0;
        
        commentsWithMeta.add({
          'comment': comment,
          'totalReplyCount': totalReplyCount,
          'hasMoreReplies': totalReplyCount > (comment.replies?.length ?? 0),
        });
      }
      
      // 성능 모니터링
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('🔥 DEBUG: 성능 최적화 - 완료 시간: $endTime');
      print('🔥 DEBUG: 성능 최적화 - 총 소요 시간: ${duration.inMilliseconds}ms');
      print('🔥 DEBUG: 성능 최적화 - 로드된 댓글 수: ${commentsWithMeta.length}');
      print('🔥 DEBUG: 성능 최적화 - 전체 댓글 수: $totalCount');
      
      // 성능 경고 (1000개 이상의 댓글이 있는 게시글)
      if (totalCount > 1000) {
        print('⚠️  [PERFORMANCE] 대량 댓글 게시글 감지: ${totalCount}개 댓글');
        print('⚠️  [PERFORMANCE] 권장사항: 페이지 크기 조정 또는 가상화 적용 필요');
      }
      
      return {
        'comments': commentsWithMeta,
        'totalCount': totalCount,
        'hasMore': offset + limit < totalCount,
        'loadTime': duration.inMilliseconds, // 성능 메트릭 추가
      };
    } catch (e) {
      print('❌ [ERROR] 댓글 조회 실패: $e');
      throw Exception('댓글 조회 실패: $e');
    }
  }


  // 댓글에서 @태그된 사용자 찾기
  List<String> _extractTaggedUsers(String content) {
    final tagPattern = RegExp(r'@(\w+)');
    final matches = tagPattern.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  // 댓글 작성
  Future<CommunityComment> createComment({
    required String postId,
    required String authorId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      print('🔥 DEBUG: createComment 시작 - postId: $postId, authorId: $authorId, parentCommentId: $parentCommentId');
      
      // 게시글의 현재 comment_count 확인
      final postBefore = await _supabase
          .from('community_posts')
          .select('comment_count')
          .eq('id', postId)
          .single();
      print('🔥 DEBUG: 댓글 작성 전 게시글 comment_count: ${postBefore['comment_count']}');
      
      // 태그된 사용자 추출
      final taggedNicknames = _extractTaggedUsers(content);
      
      final response = await _supabase
          .from('community_comments')
          .insert({
            'post_id': postId,
            'author_id': authorId,
            'content': content,
            'parent_comment_id': parentCommentId,
          })
          .select('*')
          .single();

      print('🔥 DEBUG: 댓글 삽입 완료 - commentId: ${response['id']}');
      
      // 🔥 comment_count는 이제 DB 트리거가 자동 처리
      print('🔥 DEBUG: comment_count는 DB 트리거가 자동 업데이트 처리함');
      
      // 게시글의 변경된 comment_count 확인
      final postAfter = await _supabase
          .from('community_posts')
          .select('comment_count')
          .eq('id', postId)
          .single();
      print('🔥 DEBUG: 댓글 작성 후 게시글 comment_count: ${postAfter['comment_count']} (${postAfter['comment_count'] - postBefore['comment_count']} 증가)');

      var comment = CommunityComment.fromJson(response);

      // Author 정보 별도 조회
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', authorId)
          .maybeSingle();

      if (authorResponse != null) {
        final commentJson = comment.toJson();
        commentJson['author'] = authorResponse;
        comment = CommunityComment.fromJson(commentJson);
      }

      // 태그된 사용자들에게 알림 전송
      if (taggedNicknames.isNotEmpty) {
        await _sendTagNotifications(
          taggedNicknames: taggedNicknames,
          taggerUserId: authorId,
          taggerNickname: authorResponse?['nickname'] ?? '알 수 없는 사용자',
          postId: postId,
          commentContent: content,
        );
      }

      // 커뮤니티 댓글 생성 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityCommentCreated,
        babyId: authorId,
        date: comment.createdAt,
        action: DataSyncAction.created,
        recordId: comment.id,
        metadata: {
          'commentId': comment.id,
          'postId': postId,
          'authorId': authorId,
          'parentCommentId': parentCommentId,
        },
      );

      return comment;
    } catch (e) {
      throw Exception('댓글 작성 실패: $e');
    }
  }
  
  // 특정 댓글의 모든 답글 가져오기
  Future<List<CommunityComment>> getCommentReplies(
    String commentId, {
    String? currentUserId,
  }) async {
    try {
      final response = await _supabase
          .from('community_comments')
          .select('*')
          .eq('parent_comment_id', commentId)
          .order('created_at', ascending: true); // 답글은 오래된 순 - 삭제된 답글도 포함
      
      List<CommunityComment> replies = (response as List)
          .map((item) => CommunityComment.fromJson(item))
          .toList();
      
      // Author 정보 별도 조회 후 매핑
      if (replies.isNotEmpty) {
        final authorIds = replies.map((r) => r.authorId).toSet().toList();
        final authorsResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
            .inFilter('user_id', authorIds);

        final authorsMap = <String, Map<String, dynamic>>{};
        for (final author in authorsResponse as List) {
          authorsMap[author['user_id']] = author;
        }

        // 답글에 author 정보 추가
        for (int i = 0; i < replies.length; i++) {
          final authorData = authorsMap[replies[i].authorId];
          if (authorData != null) {
            final replyJson = replies[i].toJson();
            replyJson['author'] = authorData;
            replies[i] = CommunityComment.fromJson(replyJson);
          }
        }
      }

      // 현재 사용자의 좋아요 여부 확인
      if (currentUserId != null && replies.isNotEmpty) {
        final replyIds = replies.map((r) => r.id).toList();
        final likes = await _supabase
            .from('community_likes')
            .select('comment_id')
            .eq('user_id', currentUserId)
            .inFilter('comment_id', replyIds);

        final likedReplyIds = (likes as List)
            .map((like) => like['comment_id'] as String)
            .toSet();

        replies = replies.map((reply) => 
            reply.copyWith(isLikedByCurrentUser: likedReplyIds.contains(reply.id))
        ).toList();
      }
      
      return replies;
    } catch (e) {
      throw Exception('답글 조회 실패: $e');
    }
  }

  // 태그 알림 전송
  Future<void> _sendTagNotifications({
    required List<String> taggedNicknames,
    required String taggerUserId,
    required String taggerNickname,
    required String postId,
    required String commentContent,
  }) async {
    try {
      // 태그된 닉네임으로 사용자 ID 찾기
      if (taggedNicknames.isEmpty) return;
      
      final taggedUsers = await _supabase
          .from('user_profiles')
          .select('user_id, nickname')
          .inFilter('nickname', taggedNicknames);

      // 각 태그된 사용자에게 알림 생성
      for (final user in taggedUsers as List) {
        final taggedUserId = user['user_id'] as String;
        
        // 본인을 태그한 경우는 알림 생성하지 않음
        if (taggedUserId == taggerUserId) continue;
        
        await _supabase
            .from('community_notifications')
            .insert({
              'recipient_id': taggedUserId,
              'actor_id': taggerUserId,
              'type': 'tag',
              'post_id': postId,
              'message': '$taggerNickname님이 댓글에서 회원님을 언급했습니다',
              'data': {
                'comment_content': commentContent.length > 50 
                    ? '${commentContent.substring(0, 50)}...'
                    : commentContent,
              },
            });
      }
    } catch (e) {
      // 태그 알림 실패는 댓글 작성에 영향을 주지 않도록 로그만 출력
      print('태그 알림 전송 실패: $e');
    }
  }

  // 댓글 좋아요/좋아요 취소
  Future<bool> toggleCommentLike(String commentId, String userId) async {
    try {
      print('🔥 DEBUG: toggleCommentLike 시작 - commentId: $commentId, userId: $userId');
      
      // 🚀 NEW: RPC 함수를 사용하여 원자적으로 댓글 좋아요 토글 및 카운트 업데이트
      final result = await _supabase.rpc('toggle_comment_like', params: {
        'p_comment_id': commentId,
        'p_user_id': userId,
      });
      
      print('🔥 DEBUG: RPC 결과: $result');
      
      final isLiked = result['is_liked'] as bool;
      final likeCount = result['like_count'] as int;
      
      print('🔥 DEBUG: ✅ 댓글 좋아요 토글 완료 - isLiked: $isLiked, likeCount: $likeCount');
      return isLiked;
    } catch (e) {
      print('🔥 DEBUG: toggleCommentLike 오류 - $e');
      
      // 본인 댓글 오류는 조용히 처리
      if (e.toString().contains('Cannot like your own comment')) {
        print('🔥 DEBUG: 본인 댓글이므로 좋아요 불가');
        return false;
      }
      
      throw Exception('댓글 좋아요 처리 실패: $e');
    }
  }

  // 게시글 검색
  Future<List<CommunityPost>> searchPosts({
    required String query,
    String? categorySlug,
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  }) async {
    try {
      var supabaseQuery = _supabase
          .from('community_posts')
          .select('*')
          .eq('is_deleted', false)
          .or('title.ilike.%$query%,content.ilike.%$query%');

      // 카테고리 필터링 준비
      String? categoryId;
      if (categorySlug != null && categorySlug != 'all' && categorySlug != 'popular') {
        final categories = await getCategories();
        try {
          final category = categories.firstWhere((cat) => cat.slug == categorySlug);
          categoryId = category.id;
        } catch (e) {
          // 카테고리를 찾지 못한 경우 필터링하지 않음
        }
      }

      final response = categoryId != null
          ? await supabaseQuery
              .eq('category_id', categoryId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1)
          : await supabaseQuery
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
      final posts = (response as List)
          .map((item) => CommunityPost.fromJson(item))
          .toList();

      // Author 정보 및 Category 정보 별도 조회 후 매핑 (검색용)
      if (posts.isNotEmpty) {
        // Author 정보 조회
        final authorIds = posts.map((p) => p.authorId).toSet().toList();
        final authorsResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
            .inFilter('user_id', authorIds);

        final authorsMap = <String, Map<String, dynamic>>{};
        for (final author in authorsResponse as List) {
          authorsMap[author['user_id']] = author;
        }

        // Category 정보 조회 (에러가 발생해도 게시글 로드는 계속)
        final categoriesMap = <String, Map<String, dynamic>>{};
        try {
          final categoryIds = posts.map((p) => p.categoryId).toSet().toList();
          if (categoryIds.isNotEmpty) {
            final categoriesResponse = await _supabase
                .from('community_categories')
                .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
                .inFilter('id', categoryIds);

            for (final category in categoriesResponse as List) {
              categoriesMap[category['id']] = category;
            }
          }
        } catch (e) {
          print('Category 정보 조회 실패 (검색 계속): $e');
        }

        // Posts에 author 및 category 정보 추가
        for (int i = 0; i < posts.length; i++) {
          final postJson = posts[i].toJson();
          
          // Author 정보 추가
          final authorData = authorsMap[posts[i].authorId];
          if (authorData != null) {
            postJson['author'] = authorData;
          }
          
          // Category 정보 추가 (안전하게)
          final categoryData = categoriesMap[posts[i].categoryId];
          if (categoryData != null) {
            postJson['category'] = categoryData;
          }
          
          posts[i] = CommunityPost.fromJson(postJson);
        }
      }

      // 현재 사용자의 좋아요 여부 확인
      if (currentUserId != null && posts.isNotEmpty) {
        final postIds = posts.map((p) => p.id).toList();
        final likes = await _supabase
            .from('community_likes')
            .select('post_id')
            .eq('user_id', currentUserId)
            .inFilter('post_id', postIds);

        final likedPostIds = (likes as List)
            .map((like) => like['post_id'] as String)
            .toSet();

        return posts.map((post) => 
            post.copyWith(isLikedByCurrentUser: likedPostIds.contains(post.id))
        ).toList();
      }

      return posts;
    } catch (e) {
      throw Exception('게시글 검색 실패: $e');
    }
  }

  // 댓글 수정
  Future<CommunityComment> updateComment({
    required String commentId,
    required String authorId,
    required String content,
  }) async {
    try {
      // 작성자 확인
      final existingComment = await _supabase
          .from('community_comments')
          .select('author_id')
          .eq('id', commentId)
          .eq('is_deleted', false)
          .single();

      if (existingComment['author_id'] != authorId) {
        throw Exception('댓글을 수정할 권한이 없습니다.');
      }

      final response = await _supabase
          .from('community_comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('*')
          .single();

      var comment = CommunityComment.fromJson(response);

      // Author 정보 별도 조회
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', authorId)
          .maybeSingle();

      if (authorResponse != null) {
        final commentJson = comment.toJson();
        commentJson['author'] = authorResponse;
        comment = CommunityComment.fromJson(commentJson);
      }

      // 커뮤니티 댓글 수정 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityCommentUpdated,
        babyId: authorId,
        date: comment.updatedAt ?? comment.createdAt,
        action: DataSyncAction.updated,
        recordId: commentId,
        metadata: {
          'commentId': commentId,
          'authorId': authorId,
        },
      );

      return comment;
    } catch (e) {
      throw Exception('댓글 수정 실패: $e');
    }
  }

  // 댓글 삭제 (소프트 삭제)
  Future<CommunityComment> deleteComment(String commentId, String authorId) async {
    try {
      // 작성자 확인
      final existingComment = await _supabase
          .from('community_comments')
          .select('author_id')
          .eq('id', commentId)
          .eq('is_deleted', false)
          .single();

      if (existingComment['author_id'] != authorId) {
        throw Exception('댓글을 삭제할 권한이 없습니다.');
      }

      // 소프트 삭제 - 내용을 삭제 메시지로 변경하고 is_deleted 플래그 설정
      final response = await _supabase
          .from('community_comments')
          .update({
            'content': '(작성자에 의해 삭제되었습니다)',
            'is_deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('*')
          .single();

      var deletedComment = CommunityComment.fromJson(response);

      // Author 정보 별도 조회 (삭제된 댓글이지만 작성자 정보는 유지)
      final authorResponse = await _supabase
          .from('user_profiles')
          .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
          .eq('user_id', authorId)
          .maybeSingle();

      if (authorResponse != null) {
        final commentJson = deletedComment.toJson();
        commentJson['author'] = authorResponse;
        deletedComment = CommunityComment.fromJson(commentJson);
      }

      // 커뮤니티 댓글 삭제 이벤트 발생
      _eventBus.notifyDataChanged(
        type: DataSyncEventType.communityCommentDeleted,
        babyId: authorId,
        date: DateTime.now(),
        action: DataSyncAction.deleted,
        recordId: commentId,
        metadata: {
          'commentId': commentId,
          'authorId': authorId,
        },
      );

      return deletedComment;
    } catch (e) {
      throw Exception('댓글 삭제 실패: $e');
    }
  }

  // 일일 인기 게시글 조회 (캐시 적용)
  Future<List<CommunityPost>> _getDailyPopularPosts({
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // 캐시 확인 (30분간 유효, 같은 날짜)
      if (_dailyPopularCache != null &&
          _dailyPopularCacheTime != null &&
          _dailyPopularCacheDate == todayString &&
          DateTime.now().difference(_dailyPopularCacheTime!).inMinutes < 30) {
        
        // 캐시에서 페이징 처리하여 반환
        final startIndex = offset;
        final endIndex = (offset + limit).clamp(0, _dailyPopularCache!.length);
        
        if (startIndex >= _dailyPopularCache!.length) {
          return [];
        }
        
        final cachedPosts = _dailyPopularCache!.sublist(startIndex, endIndex);
        
        // 현재 사용자의 좋아요 여부만 다시 확인
        if (currentUserId != null && cachedPosts.isNotEmpty) {
          return await _addCurrentUserLikes(cachedPosts, currentUserId);
        }
        
        return cachedPosts;
      }
      
      // 캐시가 없거나 만료된 경우 새로 조회
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final response = await _supabase
          .from('community_posts')
          .select('*')
          .eq('is_deleted', false)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .gte('like_count', 1) // 최소 1개 이상의 좋아요
          .order('like_count', ascending: false)
          .order('created_at', ascending: false) // 2차 정렬: 최신순
          .limit(50); // 최대 50개만 가져오기
      
      final posts = (response as List)
          .map((item) => CommunityPost.fromJson(item))
          .toList();
      
      // Author 정보 및 Category 정보 별도 조회 후 매핑
      if (posts.isNotEmpty) {
        // Author 정보 조회
        final authorIds = posts.map((p) => p.authorId).toSet().toList();
        final authorsResponse = await _supabase
            .from('user_profiles')
            .select('user_id, nickname, profile_image_url, bio, id, created_at, updated_at')
            .inFilter('user_id', authorIds);

        final authorsMap = <String, Map<String, dynamic>>{};
        for (final author in authorsResponse as List) {
          authorsMap[author['user_id']] = author;
        }

        // Category 정보 조회 (에러가 발생해도 게시글 로드는 계속)
        final categoriesMap = <String, Map<String, dynamic>>{};
        try {
          final categoryIds = posts.map((p) => p.categoryId).toSet().toList();
          if (categoryIds.isNotEmpty) {
            final categoriesResponse = await _supabase
                .from('community_categories')
                .select('id, name, slug, description, color, icon, display_order, is_active, created_at, updated_at')
                .inFilter('id', categoryIds);

            for (final category in categoriesResponse as List) {
              categoriesMap[category['id']] = category;
            }
          }
        } catch (e) {
          print('Category 정보 조회 실패 (인기글 로드 계속): $e');
        }

        // Posts에 author 및 category 정보 추가
        for (int i = 0; i < posts.length; i++) {
          final postJson = posts[i].toJson();
          
          // Author 정보 추가
          final authorData = authorsMap[posts[i].authorId];
          if (authorData != null) {
            postJson['author'] = authorData;
          }
          
          // Category 정보 추가 (안전하게)
          final categoryData = categoriesMap[posts[i].categoryId];
          if (categoryData != null) {
            postJson['category'] = categoryData;
          }
          
          posts[i] = CommunityPost.fromJson(postJson);
        }
      }
      
      // 캐시 업데이트
      _dailyPopularCache = posts;
      _dailyPopularCacheTime = DateTime.now();
      _dailyPopularCacheDate = todayString;
      
      // 페이징 처리하여 반환
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, posts.length);
      
      if (startIndex >= posts.length) {
        return [];
      }
      
      final pagedPosts = posts.sublist(startIndex, endIndex);
      
      // 현재 사용자의 좋아요 여부 확인
      if (currentUserId != null && pagedPosts.isNotEmpty) {
        return await _addCurrentUserLikes(pagedPosts, currentUserId);
      }
      
      return pagedPosts;
    } catch (e) {
      throw Exception('일일 인기 게시글 조회 실패: $e');
    }
  }

  // 현재 사용자의 좋아요 여부 추가
  Future<List<CommunityPost>> _addCurrentUserLikes(List<CommunityPost> posts, String currentUserId) async {
    try {
      final postIds = posts.map((p) => p.id).toList();
      final likes = await _supabase
          .from('community_likes')
          .select('post_id')
          .eq('user_id', currentUserId)
          .inFilter('post_id', postIds);

      final likedPostIds = (likes as List)
          .map((like) => like['post_id'] as String)
          .toSet();

      return posts.map((post) => 
          post.copyWith(isLikedByCurrentUser: likedPostIds.contains(post.id))
      ).toList();
    } catch (e) {
      // 좋아요 정보 조회 실패 시 원본 반환
      return posts;
    }
  }

  /// 게시글 조회수 증가 (중복 방지 로직 포함)
  /// 
  /// 같은 사용자가 같은 게시글을 여러 번 조회해도 조회수는 1번만 증가
  /// 현업에서 많이 사용하는 방식: 사용자별 중복 방지
  Future<bool> incrementViewCount({
    required String postId,
    required String userId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      print('🔥 DEBUG: incrementViewCount 시작 - postId: $postId, userId: $userId');
      
      // 1. 이미 조회한 기록이 있는지 확인
      final existingView = await _supabase
          .from('community_post_views')
          .select('id, viewed_at')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingView != null) {
        print('🔥 DEBUG: 이미 조회한 기록 있음 - 조회수 증가 안함');
        return false; // 이미 조회한 경우 조회수 증가하지 않음
      }
      
      // 2. 조회 기록 삽입 (UNIQUE 제약으로 중복 방지)
      print('🔥 DEBUG: 새로운 조회 기록 삽입 중...');
      await _supabase
          .from('community_post_views')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'ip_address': ipAddress,
            'user_agent': userAgent,
            'viewed_at': DateTime.now().toIso8601String(),
          });
      
      print('🔥 DEBUG: 조회 기록 삽입 완료');
      
      // 3. 게시글의 view_count 증가
      print('🔥 DEBUG: 게시글 view_count 업데이트 시작...');
      
      // 현재 조회수 가져오기
      final currentPost = await _supabase
          .from('community_posts')
          .select('view_count')
          .eq('id', postId)
          .single();
          
      final currentViewCount = currentPost['view_count'] ?? 0;
      print('🔥 DEBUG: 현재 조회수: $currentViewCount');
      
      // 조회수 증가
      await _supabase
          .from('community_posts')
          .update({
            'view_count': currentViewCount + 1
          })
          .eq('id', postId);
      
      print('🔥 DEBUG: 조회수 업데이트 완료 - ${currentViewCount + 1}');
      
      return true; // 조회수 증가 성공
      
    } catch (e) {
      // 중복 삽입 시도 시 (UNIQUE 제약 위반) 조회수 증가하지 않음
      if (e.toString().contains('unique_user_post_view')) {
        print('🔥 DEBUG: 중복 조회 시도 - 조회수 증가 안함');
        return false;
      }
      
      print('❌ ERROR: 조회수 증가 실패: $e');
      return false;
    }
  }

  /// 게시글 상세 조회 (조회수 증가 포함)
  /// 
  /// 게시글을 조회할 때 자동으로 조회수를 증가시킵니다.
  /// 중복 조회는 방지됩니다.
  Future<CommunityPost?> getPostWithViewIncrement({
    required String postId,
    required String currentUserId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      print('🔥 DEBUG: getPostWithViewIncrement 시작 - postId: $postId');
      
      // 1. 게시글 조회
      final post = await getPost(postId, currentUserId: currentUserId);
      if (post == null) return null;
      
      // 2. 조회수 증가 (백그라운드에서 실행 - UI 블로킹 방지)
      Future.microtask(() async {
        await incrementViewCount(
          postId: postId,
          userId: currentUserId,
          ipAddress: ipAddress,
          userAgent: userAgent,
        );
      });
      
      return post;
      
    } catch (e) {
      print('❌ ERROR: getPostWithViewIncrement 실패: $e');
      throw Exception('게시글 조회 실패: $e');
    }
  }
}