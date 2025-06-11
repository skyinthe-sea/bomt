import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_category.dart';

class CommunityService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
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

  // 게시글 목록 조회 (카테고리별, 정렬별)
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

      // 조회수 증가
      await _supabase
          .from('community_posts')
          .update({'view_count': post.viewCount + 1})
          .eq('id', postId);

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
        viewCount: post.viewCount + 1,
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
    required String title,
    required String content,
    List<String>? images,
  }) async {
    try {
      print('DEBUG: createPost 호출 - authorId: $authorId, categoryId: $categoryId');
      print('DEBUG: title: $title');
      
      // 단순한 INSERT만 실행 (조인 없음)
      final response = await _supabase
          .from('community_posts')
          .insert({
            'author_id': authorId,
            'category_id': categoryId,
            'title': title,
            'content': content,
            'images': images ?? [],
          })
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
    required String title,
    required String content,
    List<String>? images,
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
            'title': title,
            'content': content,
            'images': images ?? [],
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

      return true;
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  // 게시글 좋아요/좋아요 취소
  Future<bool> togglePostLike(String postId, String userId) async {
    try {
      // 기존 좋아요 확인
      final existingLike = await _supabase
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existingLike != null) {
        // 좋아요 취소
        await _supabase
            .from('community_likes')
            .delete()
            .eq('id', existingLike['id']);
        return false;
      } else {
        // 좋아요 추가
        await _supabase
            .from('community_likes')
            .insert({
              'user_id': userId,
              'post_id': postId,
            });
        return true;
      }
    } catch (e) {
      throw Exception('좋아요 처리 실패: $e');
    }
  }

  // 댓글 목록 조회 (최상위 댓글만 페이징)
  Future<Map<String, dynamic>> getComments(
    String postId, {
    String? currentUserId,
    int limit = 10,
    int offset = 0,
    String orderBy = 'like_count', // 'like_count' | 'created_at'
    bool ascending = false,
  }) async {
    try {
      // 최상위 댓글만 가져오기 (답글 제외) - 삭제된 댓글도 포함
      final response = await _supabase
          .from('community_comments')
          .select('*')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null) // 최상위 댓글만
          .order(orderBy == 'like_count' ? 'like_count' : 'created_at', ascending: false)
          .order('created_at', ascending: false) // 2차 정렬
          .range(offset, offset + limit - 1);

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
      
      return {
        'comments': commentsWithMeta,
        'totalCount': totalCount,
        'hasMore': offset + limit < totalCount,
      };
    } catch (e) {
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
      final existingLike = await _supabase
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existingLike != null) {
        await _supabase
            .from('community_likes')
            .delete()
            .eq('id', existingLike['id']);
        return false;
      } else {
        await _supabase
            .from('community_likes')
            .insert({
              'user_id': userId,
              'comment_id': commentId,
            });
        return true;
      }
    } catch (e) {
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
}