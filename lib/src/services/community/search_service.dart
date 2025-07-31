import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/community_post.dart';
import '../../core/cache/universal_cache_service.dart';

/// Community search optimization service
/// 
/// Key features:
/// - PostgreSQL Full-Text Search utilization
/// - Multi-language search support (Korean, English, Japanese, etc.)
/// - Smart caching system
/// - Search result debouncing
/// - Performance monitoring
class CommunitySearchService {
  static final CommunitySearchService _instance = CommunitySearchService._internal();
  factory CommunitySearchService() => _instance;
  CommunitySearchService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final UniversalCacheService _cache = UniversalCacheService.instance;

  /// Search debounce timer
  Timer? _searchDebounceTimer;
  
  /// Current ongoing search request
  Completer<List<CommunityPost>>? _currentSearchCompleter;

  /// Execute search (with debouncing)
  Future<List<CommunityPost>> searchPosts({
    required String query,
    String? category,
    String? sortBy,
    int limit = 20,
    int offset = 0,
    Duration debounceDelay = const Duration(milliseconds: 500),
  }) async {
    // Cancel existing search
    _searchDebounceTimer?.cancel();
    _currentSearchCompleter?.complete([]);

    // Create new Completer
    final completer = Completer<List<CommunityPost>>();
    _currentSearchCompleter = completer;

    // Apply debouncing
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

  /// Perform actual search
  Future<List<CommunityPost>> _performSearch({
    required String query,
    String? category,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 1. Generate cache key
      final cacheKey = _generateCacheKey(query, category, sortBy, limit, offset);
      
      // 2. Get results from cache
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

      // 3. Preprocess search query
      final processedQuery = _preprocessSearchQuery(query);
      
      debugPrint('🔍 [SEARCH] Starting search: "$query" -> "$processedQuery" (category: $category, sort: $sortBy)');
      
      // 4. Call Supabase RPC function (Full-Text Search)
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

      // 5. Parse results (handle new JSON structure)
      final List<CommunityPost> posts = [];
      
      try {
        // RPC function returns JSON, so cast directly to List
        final List<dynamic> responseList = response as List<dynamic>;
        
        for (final item in responseList) {
          try {
            final post = CommunityPost.fromJson(item as Map<String, dynamic>);
            posts.add(post);
          } catch (e) {
            debugPrint('❌ [SEARCH] Failed to parse post: $e');
            debugPrint('📄 [SEARCH] Raw data: $item');
            // Skip failed parsing items and continue
          }
        }
      } catch (e) {
        debugPrint('❌ [SEARCH] Failed to parse response structure: $e');
        debugPrint('📄 [SEARCH] Raw response: $response');
      }

      // 6. Cache results (search results are cached for short time)
      await _cache.set(
        key: cacheKey,
        data: posts.map((post) => post.toJson()).toList(),
        strategy: CacheStrategy.short, // 5 minutes cache
      );

      // 7. Performance monitoring
      stopwatch.stop();
      debugPrint('🔍 [SEARCH] Search success: "$query" (${posts.length} results, ${stopwatch.elapsedMilliseconds}ms)');

      return posts;

    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ [SEARCH] Search error: "$query" - $e (${stopwatch.elapsedMilliseconds}ms)');
      rethrow;
    }
  }

  /// Get popular search terms (with caching)
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
      
      // Popular search terms are cached for longer time
      await _cache.set(
        key: cacheKey,
        data: terms,
        strategy: CacheStrategy.long, // 1 hour cache
      );

      return terms;
    } catch (e) {
      debugPrint('❌ [SEARCH] Popular search terms error: $e');
      return [];
    }
  }

  /// Get search suggestions (autocomplete)
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
      
      // Suggestions are cached for medium time
      await _cache.set(
        key: cacheKey,
        data: suggestions,
        strategy: CacheStrategy.medium, // 30 minutes cache
      );

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Preprocess search query (simplified version for LIKE search)
  String _preprocessSearchQuery(String query) {
    // 1. Clean whitespace
    query = query.trim();
    
    // 2. Escape special characters (prevent SQL injection)
    query = query.replaceAll("'", '').replaceAll('"', '').replaceAll('\\', '');
    
    // 3. Remove Korean particles (simple version)
    final koreanParticles = ['은', '는', '이', '가', '을', '를', '에', '의', '로', '으로', '와', '과', '도'];
    for (final particle in koreanParticles) {
      if (query.endsWith(particle)) {
        query = query.substring(0, query.length - particle.length);
        break;
      }
    }
    
    // Return original query as-is for LIKE search
    return query;
  }

  /// Generate cache key
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

  /// Record search event (for analytics)
  Future<void> recordSearchEvent(String query, int resultCount) async {
    try {
      // Execute asynchronously in background (prevent UI blocking)
      _supabase.from('search_analytics').insert({
        'query': query,
        'result_count': resultCount,
        'created_at': DateTime.now().toIso8601String(),
      }).ignore();
    } catch (e) {
      // Ignore analytics data recording failures
    }
  }

  /// Clear search cache
  Future<void> clearSearchCache() async {
    try {
      // Remove search-related cache keys
      await _cache.remove('popular_search_terms');
      
      // Also clear search suggestion caches (pattern matching difficult, needs improvement)
      debugPrint('🧹 [SEARCH] Search cache cleared');
    } catch (e) {
      debugPrint('❌ [SEARCH] Cache clear failed: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _searchDebounceTimer?.cancel();
    if (_currentSearchCompleter != null && !_currentSearchCompleter!.isCompleted) {
      _currentSearchCompleter!.complete([]);
    }
    _currentSearchCompleter = null;
  }
}

