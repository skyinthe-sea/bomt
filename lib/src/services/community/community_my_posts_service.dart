import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_category.dart';

class CommunityMyPostsService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// 내가 작성한 게시글 목록 조회
  Future<List<CommunityPost>> getMyPosts({
    required String userId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('=' * 100);
      debugPrint('📝 [MY_POSTS_SERVICE] getMyPosts 시작');
      debugPrint('=' * 100);
      debugPrint('📋 [MY_POSTS_SERVICE] 입력 파라미터:');
      debugPrint('    - userId: $userId');
      debugPrint('    - userId 타입: ${userId.runtimeType}');
      debugPrint('    - userId 길이: ${userId.length}');
      debugPrint('    - page: $page');
      debugPrint('    - pageSize: $pageSize');
      debugPrint('    - range: ${page * pageSize} ~ ${(page + 1) * pageSize - 1}');
      
      // 게시글 조회 (카테고리 정보 포함)
      debugPrint('🔍 [MY_POSTS_SERVICE] SQL 쿼리 실행 중...');
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            community_categories!inner(
              id,
              name,
              slug,
              color,
              icon
            )
          ''')
          .eq('author_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      debugPrint('📥 [MY_POSTS_SERVICE] SQL 쿼리 완료');
      debugPrint('    - Raw response 타입: ${response.runtimeType}');
      debugPrint('    - Raw response 길이: ${response.length}');
      debugPrint('    - Raw response: $response');
      
      debugPrint('🔄 [MY_POSTS_SERVICE] 응답 데이터 파싱 시작...');
      final posts = (response as List).map((postData) {
        debugPrint('    - 게시글 데이터 파싱 중: ${postData['id']}');
        
        // 카테고리 정보 매핑
        final categoryData = postData['community_categories'];
        debugPrint('      - 카테고리 데이터: $categoryData');
        
        final category = categoryData != null 
            ? CommunityCategory.fromJson(categoryData)
            : null;
        debugPrint('      - 파싱된 카테고리: ${category?.name}');

        // 게시글 데이터에서 카테고리 제거 (중복 방지)
        final cleanPostData = Map<String, dynamic>.from(postData);
        cleanPostData.remove('community_categories');
        
        // CommunityPost 생성
        final post = CommunityPost.fromJson(cleanPostData);
        debugPrint('      - 파싱된 게시글: ${post.id}');
        debugPrint('      - author_id: ${post.authorId}');
        debugPrint('      - title: ${post.title ?? "제목없음"}');
        debugPrint('      - content 길이: ${post.content.length}');
        debugPrint('      - created_at: ${post.createdAt}');
        
        // 카테고리 할당
        if (category != null) {
          final finalPost = post.copyWith(category: category);
          debugPrint('      - 카테고리 할당 완료: ${finalPost.category?.name}');
          return finalPost;
        }
        
        debugPrint('      - 카테고리 없이 반환');
        return post;
      }).toList();

      debugPrint('✅ [MY_POSTS_SERVICE] 파싱 완료');
      debugPrint('    - 총 파싱된 posts: ${posts.length}');
      for (int i = 0; i < posts.length; i++) {
        debugPrint('    [$i] ${posts[i].id} - ${posts[i].authorId} - "${posts[i].title ?? "제목없음"}"');
      }
      debugPrint('=' * 100);
      
      return posts;

    } catch (e) {
      debugPrint('❌ [MY_POSTS_SERVICE] Error getting my posts: $e');
      rethrow;
    }
  }

  /// 내가 작성한 댓글 목록 조회 (게시글 정보 포함)
  Future<List<CommunityComment>> getMyComments({
    required String userId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('💬 [MY_POSTS_SERVICE] Getting my comments - userId: $userId, page: $page');
      
      // 댓글 조회 (게시글 정보 포함)
      final response = await _supabase
          .from('community_comments')
          .select('''
            *,
            community_posts!inner(
              id,
              title,
              content,
              author_id,
              category_id,
              created_at
            )
          ''')
          .eq('author_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      debugPrint('💬 [MY_POSTS_SERVICE] Query result: ${response.length} comments');
      
      final comments = (response as List).map((commentData) {
        // 게시글 정보 추출
        final postData = commentData['community_posts'];
        
        // 댓글 데이터에서 게시글 정보 제거
        final cleanCommentData = Map<String, dynamic>.from(commentData);
        cleanCommentData.remove('community_posts');
        
        // CommunityComment 생성
        final comment = CommunityComment.fromJson(cleanCommentData);
        
        // 게시글 정보를 추가 데이터로 포함 (나중에 UI에서 사용)
        return comment.copyWith(
          // 여기에 게시글 정보를 포함할 수 있지만,
          // 현재 CommunityComment 모델에는 post 필드가 없으므로
          // UI에서 별도로 처리하거나 모델을 확장해야 함
        );
      }).toList();

      debugPrint('💬 [MY_POSTS_SERVICE] Successfully parsed ${comments.length} comments');
      return comments;

    } catch (e) {
      debugPrint('❌ [MY_POSTS_SERVICE] Error getting my comments: $e');
      rethrow;
    }
  }

  /// 내가 작성한 댓글 목록 조회 (게시글 제목 포함한 확장 모델)
  Future<List<MyCommentWithPost>> getMyCommentsWithPost({
    required String userId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('💬 [MY_POSTS_SERVICE] Getting my comments with post - userId: $userId, page: $page');
      
      // 댓글 조회 (게시글 정보 포함)
      final response = await _supabase
          .from('community_comments')
          .select('''
            *,
            community_posts!inner(
              id,
              title,
              content,
              author_id,
              category_id,
              created_at
            )
          ''')
          .eq('author_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      debugPrint('💬 [MY_POSTS_SERVICE] Query result: ${response.length} comments');
      
      final commentsWithPost = (response as List).map((data) {
        final commentData = Map<String, dynamic>.from(data);
        final postData = commentData.remove('community_posts');
        
        final comment = CommunityComment.fromJson(commentData);
        final postTitle = postData['title'] as String? ?? '제목 없음';
        final postId = postData['id'] as String;
        
        return MyCommentWithPost(
          comment: comment,
          postId: postId,
          postTitle: postTitle,
        );
      }).toList();

      debugPrint('💬 [MY_POSTS_SERVICE] Successfully parsed ${commentsWithPost.length} comments with post');
      return commentsWithPost;

    } catch (e) {
      debugPrint('❌ [MY_POSTS_SERVICE] Error getting my comments with post: $e');
      rethrow;
    }
  }
}

/// 댓글과 게시글 정보를 함께 담는 모델
class MyCommentWithPost {
  final CommunityComment comment;
  final String postId;
  final String postTitle;

  MyCommentWithPost({
    required this.comment,
    required this.postId,
    required this.postTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'comment': comment.toJson(),
      'postId': postId,
      'postTitle': postTitle,
    };
  }

  factory MyCommentWithPost.fromJson(Map<String, dynamic> json) {
    return MyCommentWithPost(
      comment: CommunityComment.fromJson(json['comment']),
      postId: json['postId'],
      postTitle: json['postTitle'],
    );
  }
}