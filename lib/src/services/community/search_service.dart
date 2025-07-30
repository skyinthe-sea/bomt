import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/community_post.dart';
import '../../core/cache/universal_cache_service.dart';

/// 커뮤니티 검색 최적화 서비스
/// 
/// 주요 기능:
/// - PostgreSQL Full-Text Search 활용
/// - 다국어 검색 지원 (한국어, 영어, 일본어 등)
/// - 스마트 캐싱 시스템
/// - 검색 결과 디바운싱
/// - 성능 모니터링
class CommunitySearchService {
  static final CommunitySearchService _instance = CommunitySearchService._internal();
  factory CommunitySearchService() => _instance;
  CommunitySearchService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final UniversalCacheService _cache = UniversalCacheService.instance;

  /// 검색 디바운스 타이머
  Timer? _searchDebounceTimer;
  
  /// 현재 진행 중인 검색 요청
  Completer<List<CommunityPost>>? _currentSearchCompleter;

  /// 검색 실행 (디바운싱 적용)
  Future<List<CommunityPost>> searchPosts({
    required String query,
    String? category,
    String? sortBy,
    int limit = 20,
    int offset = 0,
    Duration debounceDelay = const Duration(milliseconds: 500),
  }) async {
    // 기존 검색 취소
    _searchDebounceTimer?.cancel();
    _currentSearchCompleter?.complete([]);

    // 새로운 Completer 생성
    final completer = Completer<List<CommunityPost>>();
    _currentSearchCompleter = completer;

    // 디바운싱 적용
    _searchDebounceTimer = Timer(debounceDelay, () async {
      if (!completer.isCompleted) {
        try {
          final results = await _performSearch(
            query: query,
            category: category,
            sortBy: sortBy,
            limit: limit,
            offset: offset,
          );
          if (!completer.isCompleted) {
            completer.complete(results);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      }
    });

    return completer.future;
  }

  /// 실제 검색 수행
  Future<List<CommunityPost>> _performSearch({
    required String query,
    String? category,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 1. 캐시 키 생성
      final cacheKey = _generateCacheKey(query, category, sortBy, limit, offset);
      
      // 2. 캐시에서 결과 조회
      final cachedResults = await _cache.get<List<CommunityPost>>(
        cacheKey,
        fromJson: (dynamic json) {
          try {
            if (json is List) {
              final List<CommunityPost> posts = [];
              for (final item in json) {
                posts.add(CommunityPost.fromJson(item as Map<String, dynamic>));
              }
              return posts;
            } else if (json is Map && json.containsKey('_list')) {
              final List<dynamic> jsonList = json['_list'] as List<dynamic>;
              final List<CommunityPost> posts = [];
              for (final item in jsonList) {
                posts.add(CommunityPost.fromJson(item as Map<String, dynamic>));
              }
              return posts;
            } else {
              debugPrint('❌ [SEARCH] Unexpected cache format: ${json.runtimeType}');
              return <CommunityPost>[];
            }
          } catch (e) {
            debugPrint('❌ [SEARCH] Cache deserialization failed: $e');
            return <CommunityPost>[];
          }
        },
      );

      if (cachedResults != null) {
        debugPrint('🔍 [SEARCH] Cache hit for query: $query (${cachedResults.length} results)');
        return cachedResults;
      }

      // 3. 검색어 전처리
      final processedQuery = _preprocessSearchQuery(query);
      
      debugPrint('🔍 [SEARCH] Starting search: "$query" -> "$processedQuery" (category: $category, sort: $sortBy)');
      
      // 4. Supabase RPC 함수 호출 (Full-Text Search)
      final response = await _supabase.rpc(
        'search_community_posts_optimized',
        params: {
          'search_query': processedQuery,
          'category_filter': category,
          'sort_by': sortBy ?? 'relevance',
          'result_limit': limit,
          'result_offset': offset,
        },
      );
      
      debugPrint('📡 [SEARCH] RPC response received');

      // 5. 결과 파싱 (새로운 JSON 구조 처리)
      final List<CommunityPost> posts = [];
      
      try {
        // RPC 함수가 JSON을 반환하므로 직접 List로 캐스팅
        final List<dynamic> responseList = response as List<dynamic>;
        
        for (final item in responseList) {
          try {
            final post = CommunityPost.fromJson(item as Map<String, dynamic>);
            posts.add(post);
          } catch (e) {
            debugPrint('❌ [SEARCH] Failed to parse post: $e');
            debugPrint('📄 [SEARCH] Raw data: $item');
            // 파싱 실패한 항목은 건너뛰고 계속 진행
          }
        }
      } catch (e) {
        debugPrint('❌ [SEARCH] Failed to parse response structure: $e');
        debugPrint('📄 [SEARCH] Raw response: $response');
      }

      // 6. 결과 캐싱 (검색 결과는 짧은 시간 캐싱)
      await _cache.set(
        key: cacheKey,
        data: posts.map((post) => post.toJson()).toList(),
        strategy: CacheStrategy.short, // 5분 캐싱
      );

      // 7. 성능 모니터링
      stopwatch.stop();
      debugPrint('🔍 [SEARCH] Search success: "$query" (${posts.length} results, ${stopwatch.elapsedMilliseconds}ms)');

      return posts;

    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ [SEARCH] Search error: "$query" - $e (${stopwatch.elapsedMilliseconds}ms)');
      rethrow;
    }
  }

  /// 인기 검색어 조회 (캐싱 적용)
  Future<List<String>> getPopularSearchTerms({int limit = 10}) async {
    const cacheKey = 'popular_search_terms';
    
    final cached = await _cache.get<List<String>>(
      cacheKey,
      fromJson: (dynamic json) {
        try {
          if (json is List) {
            final List<String> terms = [];
            for (final item in json) {
              terms.add(item.toString());
            }
            return terms;
          } else if (json is Map && json.containsKey('_list')) {
            final List<dynamic> jsonList = json['_list'] as List<dynamic>;
            final List<String> terms = [];
            for (final item in jsonList) {
              terms.add(item.toString());
            }
            return terms;
          } else {
            debugPrint('❌ [SEARCH] Unexpected popular terms cache format: ${json.runtimeType}');
            return <String>[];
          }
        } catch (e) {
          debugPrint('❌ [SEARCH] Popular terms cache deserialization failed: $e');
          return <String>[];
        }
      },
    );

    if (cached != null) {
      return cached;
    }

    try {
      final response = await _supabase.rpc(
        'get_popular_search_terms',
        params: {'result_limit': limit},
      );

      final List<String> terms = (response as List)
          .map((item) => item is Map ? item['query']?.toString() ?? '' : item.toString())
          .where((term) => term.isNotEmpty)
          .toList();
      
      // 인기 검색어는 긴 시간 캐싱
      await _cache.set(
        key: cacheKey,
        data: terms,
        strategy: CacheStrategy.long, // 1시간 캐싱
      );

      return terms;
    } catch (e) {
      debugPrint('❌ [SEARCH] Popular search terms error: $e');
      return [];
    }
  }

  /// 검색 제안어 조회 (자동완성)
  Future<List<String>> getSearchSuggestions(String query, {int limit = 5}) async {
    if (query.length < 2) return [];

    final cacheKey = 'search_suggestions_${query.toLowerCase()}';
    
    final cached = await _cache.get<List<String>>(
      cacheKey,  
      fromJson: (dynamic json) {
        try {
          if (json is List) {
            final List<String> suggestions = [];
            for (final item in json) {
              suggestions.add(item.toString());
            }
            return suggestions;
          } else if (json is Map && json.containsKey('_list')) {
            final List<dynamic> jsonList = json['_list'] as List<dynamic>;
            final List<String> suggestions = [];
            for (final item in jsonList) {
              suggestions.add(item.toString());
            }
            return suggestions;
          } else {
            debugPrint('❌ [SEARCH] Unexpected suggestions cache format: ${json.runtimeType}');
            return <String>[];
          }
        } catch (e) {
          debugPrint('❌ [SEARCH] Suggestions cache deserialization failed: $e');
          return <String>[];
        }
      },
    );

    if (cached != null) {
      return cached;
    }

    try {
      final response = await _supabase.rpc(
        'get_search_suggestions',
        params: {
          'search_input': _preprocessSearchQuery(query),
          'result_limit': limit,
        },
      );

      final List<String> suggestions = (response as List)
          .map((item) => item is Map ? item['suggestion']?.toString() ?? '' : item.toString())
          .where((suggestion) => suggestion.isNotEmpty)
          .toList();
      
      // 제안어는 중간 시간 캐싱
      await _cache.set(
        key: cacheKey,
        data: suggestions,
        strategy: CacheStrategy.medium, // 30분 캐싱
      );

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// 검색어 전처리 (간소화 버전 - LIKE 검색용)
  String _preprocessSearchQuery(String query) {
    // 1. 공백 정리
    query = query.trim();
    
    // 2. 특수문자 이스케이프 (SQL Injection 방지)
    query = query.replaceAll("'", '').replaceAll('"', '').replaceAll('\\', '');
    
    // 3. 한국어 조사 제거 (간단한 버전)
    final koreanParticles = ['은', '는', '이', '가', '을', '를', '에', '의', '로', '으로', '와', '과', '도'];
    for (final particle in koreanParticles) {
      if (query.endsWith(particle)) {
        query = query.substring(0, query.length - particle.length);
        break;
      }
    }
    
    // LIKE 검색용이므로 원본 쿼리 그대로 반환
    return query;
  }

  /// 캐시 키 생성
  String _generateCacheKey(String query, String? category, String? sortBy, int limit, int offset) {
    final keyParts = [
      'community_search',
      query.toLowerCase().replaceAll(' ', '_'),
      category ?? 'all',
      sortBy ?? 'relevance',
      limit.toString(),
      offset.toString(),
    ];
    return keyParts.join('_');
  }

  /// 검색 이벤트 기록 (분석용)
  Future<void> recordSearchEvent(String query, int resultCount) async {
    try {
      // 백그라운드에서 비동기 실행 (UI 블로킹 방지)
      _supabase.from('search_analytics').insert({
        'query': query,
        'result_count': resultCount,
        'created_at': DateTime.now().toIso8601String(),
      }).ignore();
    } catch (e) {
      // 분석 데이터 기록 실패는 무시
    }
  }

  /// 검색 캐시 정리
  Future<void> clearSearchCache() async {
    try {
      // 검색 관련 캐시 키들 제거
      await _cache.remove('popular_search_terms');
      
      // 검색 제안어 캐시들도 정리 (패턴 매칭이 어려우므로 향후 개선 필요)
      debugPrint('🧹 [SEARCH] Search cache cleared');
    } catch (e) {
      debugPrint('❌ [SEARCH] Cache clear failed: $e');
    }
  }

  /// 리소스 정리
  void dispose() {
    _searchDebounceTimer?.cancel();
    if (_currentSearchCompleter != null && !_currentSearchCompleter!.isCompleted) {
      _currentSearchCompleter!.complete([]);
    }
    _currentSearchCompleter = null;
  }
}

