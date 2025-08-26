import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../core/cache/universal_cache_service.dart';

/// 내 글/댓글 전용 캐시 서비스
/// 
/// 기능:
/// 1. 내가 작성한 글/댓글의 효율적인 캐싱
/// 2. 메모리 + 디스크 다층 캐시
/// 3. 스마트 캐시 무효화
/// 4. 캐시 만료 관리
class CommunityMyPostsCacheService {
  static CommunityMyPostsCacheService? _instance;
  static CommunityMyPostsCacheService get instance => _instance ??= CommunityMyPostsCacheService._();
  
  CommunityMyPostsCacheService._();
  
  final UniversalCacheService _cache = UniversalCacheService.instance;
  
  // 메모리 캐시 (앱 실행 중만 유지)
  final Map<String, List<CommunityPost>> _memoryPostsCache = {};
  final Map<String, List<CommunityComment>> _memoryCommentsCache = {};
  final Map<String, DateTime> _memoryCacheTime = {};
  
  // 캐시 설정
  static const Duration _cacheExpiry = Duration(minutes: 30); // 30분 캐시 유효
  static const String _postsKeyPrefix = 'my_posts_';
  static const String _commentsKeyPrefix = 'my_comments_';
  static const String _cacheTimeKeyPrefix = 'my_posts_time_';

  /// 내 글 목록 캐시 조회
  Future<List<CommunityPost>> getCachedPosts(String userId) async {
    try {
      // 1. 메모리 캐시 확인 (가장 빠름)
      if (_memoryPostsCache.containsKey(userId) && !isCacheExpired(userId)) {
        debugPrint('🚀 [MY_POSTS_CACHE] Memory cache hit for posts: $userId');
        return _memoryPostsCache[userId]!;
      }
      
      // 2. 디스크 캐시 확인
      final cacheKey = _postsKeyPrefix + userId;
      final cachedData = await _cache.get<List<dynamic>>(cacheKey);
      
      if (cachedData != null && !isCacheExpired(userId)) {
        final posts = cachedData.map((json) => CommunityPost.fromJson(json)).toList();
        
        // 메모리 캐시에도 저장
        _memoryPostsCache[userId] = posts;
        
        debugPrint('💾 [MY_POSTS_CACHE] Disk cache hit for posts: $userId (${posts.length} posts)');
        return posts;
      }
      
      debugPrint('❌ [MY_POSTS_CACHE] Cache miss for posts: $userId');
      return [];
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error reading posts cache: $e');
      return [];
    }
  }

  /// 내 댓글 목록 캐시 조회
  Future<List<CommunityComment>> getCachedComments(String userId) async {
    try {
      // 1. 메모리 캐시 확인
      if (_memoryCommentsCache.containsKey(userId) && !isCacheExpired(userId)) {
        debugPrint('🚀 [MY_POSTS_CACHE] Memory cache hit for comments: $userId');
        return _memoryCommentsCache[userId]!;
      }
      
      // 2. 디스크 캐시 확인
      final cacheKey = _commentsKeyPrefix + userId;
      final cachedData = await _cache.get<List<dynamic>>(cacheKey);
      
      if (cachedData != null && !isCacheExpired(userId)) {
        final comments = cachedData.map((json) => CommunityComment.fromJson(json)).toList();
        
        // 메모리 캐시에도 저장
        _memoryCommentsCache[userId] = comments;
        
        debugPrint('💾 [MY_POSTS_CACHE] Disk cache hit for comments: $userId (${comments.length} comments)');
        return comments;
      }
      
      debugPrint('❌ [MY_POSTS_CACHE] Cache miss for comments: $userId');
      return [];
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error reading comments cache: $e');
      return [];
    }
  }

  /// 내 글 목록 캐시 저장
  Future<void> cacheMyPosts(String userId, List<CommunityPost> posts) async {
    try {
      // 1. 메모리 캐시 저장
      _memoryPostsCache[userId] = posts;
      _memoryCacheTime[userId] = DateTime.now();
      
      // 2. 디스크 캐시 저장
      final cacheKey = _postsKeyPrefix + userId;
      final jsonData = posts.map((post) => post.toJson()).toList();
      
      await Future.wait([
        _cache.set(key: cacheKey, data: jsonData),
        _setCacheTime(userId, DateTime.now()),
      ]);
      
      debugPrint('✅ [MY_POSTS_CACHE] Posts cached: $userId (${posts.length} posts)');
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error caching posts: $e');
    }
  }

  /// 내 댓글 목록 캐시 저장
  Future<void> cacheMyComments(String userId, List<CommunityComment> comments) async {
    try {
      // 1. 메모리 캐시 저장
      _memoryCommentsCache[userId] = comments;
      _memoryCacheTime[userId] = DateTime.now();
      
      // 2. 디스크 캐시 저장
      final cacheKey = _commentsKeyPrefix + userId;
      final jsonData = comments.map((comment) => comment.toJson()).toList();
      
      await Future.wait([
        _cache.set(key: cacheKey, data: jsonData),
        _setCacheTime(userId, DateTime.now()),
      ]);
      
      debugPrint('✅ [MY_POSTS_CACHE] Comments cached: $userId (${comments.length} comments)');
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error caching comments: $e');
    }
  }

  /// 캐시 만료 여부 확인
  bool isCacheExpired(String userId) {
    try {
      // 1. 메모리에서 확인
      if (_memoryCacheTime.containsKey(userId)) {
        final cacheTime = _memoryCacheTime[userId]!;
        final isExpired = DateTime.now().difference(cacheTime) > _cacheExpiry;
        if (!isExpired) return false;
      }
      
      // 2. 디스크에서 확인 (동기적으로 수행하기 어려우므로 별도 메소드 사용)
      return true; // 안전하게 만료된 것으로 간주
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error checking cache expiry: $e');
      return true; // 에러 시 만료된 것으로 간주
    }
  }

  /// 디스크 캐시 만료 여부 확인 (비동기)
  Future<bool> isCacheExpiredAsync(String userId) async {
    try {
      // 1. 메모리에서 먼저 확인
      if (_memoryCacheTime.containsKey(userId)) {
        final cacheTime = _memoryCacheTime[userId]!;
        return DateTime.now().difference(cacheTime) > _cacheExpiry;
      }
      
      // 2. 디스크에서 확인
      final cacheTime = await _getCacheTime(userId);
      if (cacheTime == null) return true;
      
      return DateTime.now().difference(cacheTime) > _cacheExpiry;
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error checking cache expiry async: $e');
      return true;
    }
  }

  /// 특정 사용자의 모든 캐시 무효화
  Future<void> invalidateCache(String userId) async {
    try {
      debugPrint('🗑️ [MY_POSTS_CACHE] Invalidating cache for user: $userId');
      
      // 1. 메모리 캐시 클리어
      _memoryPostsCache.remove(userId);
      _memoryCommentsCache.remove(userId);
      _memoryCacheTime.remove(userId);
      
      // 2. 디스크 캐시 클리어
      await Future.wait([
        _cache.remove(_postsKeyPrefix + userId),
        _cache.remove(_commentsKeyPrefix + userId),
        _cache.remove(_cacheTimeKeyPrefix + userId),
      ]);
      
      debugPrint('✅ [MY_POSTS_CACHE] Cache invalidated for user: $userId');
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error invalidating cache: $e');
    }
  }

  /// 전체 캐시 클리어
  Future<void> clearAllCache() async {
    try {
      debugPrint('🗑️ [MY_POSTS_CACHE] Clearing all cache');
      
      // 1. 메모리 캐시 클리어
      _memoryPostsCache.clear();
      _memoryCommentsCache.clear();
      _memoryCacheTime.clear();
      
      // 2. 디스크 캐시 클리어 (패턴 기반)
      await Future.wait([
        _cache.removeByPattern('${_postsKeyPrefix}*'),
        _cache.removeByPattern('${_commentsKeyPrefix}*'),
        _cache.removeByPattern('${_cacheTimeKeyPrefix}*'),
      ]);
      
      debugPrint('✅ [MY_POSTS_CACHE] All cache cleared');
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error clearing all cache: $e');
    }
  }

  /// 캐시 시간 저장
  Future<void> _setCacheTime(String userId, DateTime time) async {
    try {
      final cacheKey = _cacheTimeKeyPrefix + userId;
      await _cache.set(key: cacheKey, data: time.millisecondsSinceEpoch.toString());
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error setting cache time: $e');
    }
  }

  /// 캐시 시간 조회
  Future<DateTime?> _getCacheTime(String userId) async {
    try {
      final cacheKey = _cacheTimeKeyPrefix + userId;
      final timeString = await _cache.get<String>(cacheKey);
      if (timeString == null) return null;
      
      final timestamp = int.tryParse(timeString);
      if (timestamp == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
      
    } catch (e) {
      debugPrint('❌ [MY_POSTS_CACHE] Error getting cache time: $e');
      return null;
    }
  }

  /// 캐시 통계 정보
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryPostsCount': _memoryPostsCache.length,
      'memoryCommentsCount': _memoryCommentsCache.length,
      'memoryCacheTimeCount': _memoryCacheTime.length,
      'cacheExpiryMinutes': _cacheExpiry.inMinutes,
    };
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('🗑️ [MY_POSTS_CACHE] Disposing cache service');
    _memoryPostsCache.clear();
    _memoryCommentsCache.clear();
    _memoryCacheTime.clear();
  }
}