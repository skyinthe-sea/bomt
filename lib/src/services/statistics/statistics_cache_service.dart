import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/statistics.dart';
import '../../core/cache/universal_cache_service.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

/// 통계 데이터 전용 캐시 서비스
/// 
/// 기능:
/// 1. 통계 데이터 및 차트 데이터의 효율적인 캐싱
/// 2. CRUD 이벤트 기반 스마트 캐시 무효화
/// 3. 메모리 + 디스크 다층 캐시
/// 4. 날짜별/사용자별 세분화된 캐시 키 관리
class StatisticsCacheService {
  static StatisticsCacheService? _instance;
  static StatisticsCacheService get instance => _instance ??= StatisticsCacheService._();
  
  StatisticsCacheService._() {
    _initializeEventListeners();
  }
  
  final UniversalCacheService _cache = UniversalCacheService.instance;
  final AppEventBus _eventBus = AppEventBus.instance;
  
  // 메모리 캐시 (앱 실행 중만 유지)
  final Map<String, Statistics> _memoryStatisticsCache = {};
  final Map<String, StatisticsChartData> _memoryChartCache = {};
  
  // 이벤트 구독
  StreamSubscription<DataSyncEvent>? _eventSubscription;
  
  // 캐시 무효화 타이머 (연속된 이벤트를 그룹화)
  Timer? _invalidationTimer;
  final Set<String> _pendingInvalidationKeys = {};

  /// 이벤트 리스너 초기화
  void _initializeEventListeners() {
    _eventSubscription = _eventBus.dataSyncStream.listen((event) {
      debugPrint('🗄️ [STATS_CACHE] Received data sync event: ${event.type} for baby: ${event.babyId}');
      
      if (_isStatisticsRelevantEvent(event.type)) {
        _scheduleInvalidation(event.babyId, event.type);
      }
    });
    
    debugPrint('🗄️ [STATS_CACHE] Event listeners initialized');
  }

  /// 통계에 영향을 주는 이벤트인지 확인
  bool _isStatisticsRelevantEvent(DataSyncEventType eventType) {
    const relevantEvents = [
      DataSyncEventType.feedingChanged,
      DataSyncEventType.sleepChanged,
      DataSyncEventType.diaperChanged,
      DataSyncEventType.medicationChanged,
      DataSyncEventType.milkPumpingChanged,
      DataSyncEventType.solidFoodChanged,
      DataSyncEventType.allDataRefresh,
    ];
    
    return relevantEvents.contains(eventType);
  }

  /// 캐시 무효화 스케줄링 (디바운스 처리)
  void _scheduleInvalidation(String babyId, DataSyncEventType eventType) {
    _pendingInvalidationKeys.add('${babyId}_$eventType');
    
    _invalidationTimer?.cancel();
    _invalidationTimer = Timer(const Duration(milliseconds: 1000), () async {
      await _processPendingInvalidations();
    });
  }

  /// 대기 중인 무효화 처리
  Future<void> _processPendingInvalidations() async {
    if (_pendingInvalidationKeys.isEmpty) return;

    debugPrint('🗑️ [STATS_CACHE] Processing ${_pendingInvalidationKeys.length} pending invalidations');
    
    final babyIds = _pendingInvalidationKeys
        .map((key) => key.split('_')[0])
        .toSet();
    
    for (final babyId in babyIds) {
      await _invalidateCacheForBaby(babyId);
    }
    
    _pendingInvalidationKeys.clear();
    debugPrint('🗑️ [STATS_CACHE] Invalidation processing completed');
  }

  /// 특정 아기의 모든 캐시 무효화
  Future<void> _invalidateCacheForBaby(String babyId) async {
    try {
      debugPrint('🗑️ [STATS_CACHE] Invalidating all cache for baby: $babyId');
      
      // 1. 메모리 캐시 클리어
      _memoryStatisticsCache.removeWhere((key, value) => key.contains('_${babyId}_'));
      _memoryChartCache.removeWhere((key, value) => key.contains('_${babyId}_'));
      
      // 2. 디스크 캐시 패턴 기반 삭제
      await _cache.removeByPattern('statistics_*_${babyId}_*');
      await _cache.removeByPattern('chart_*_${babyId}_*');
      
      debugPrint('🗑️ [STATS_CACHE] Cache invalidated for baby: $babyId');
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error invalidating cache for baby $babyId: $e');
    }
  }

  /// 통계 데이터 캐시 조회
  Future<Statistics?> getStatistics({
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
  }) async {
    final cacheKey = _generateStatisticsCacheKey(userId, babyId, dateRange);
    
    // 1. 메모리 캐시 확인 (가장 빠름)
    if (_memoryStatisticsCache.containsKey(cacheKey)) {
      debugPrint('🚀 [STATS_CACHE] Memory cache hit for statistics: $cacheKey');
      return _memoryStatisticsCache[cacheKey];
    }
    
    // 2. 디스크 캐시 확인
    try {
      final cached = await _cache.get<Statistics>(
        cacheKey,
        fromJson: Statistics.fromJson,
      );
      
      if (cached != null) {
        // 메모리 캐시에도 저장
        _memoryStatisticsCache[cacheKey] = cached;
        debugPrint('💾 [STATS_CACHE] Disk cache hit for statistics: $cacheKey');
        return cached;
      }
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error reading statistics from disk cache: $e');
    }
    
    debugPrint('❌ [STATS_CACHE] Cache miss for statistics: $cacheKey');
    return null;
  }

  /// 통계 데이터 캐시 저장
  Future<void> setStatistics({
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
    required Statistics statistics,
  }) async {
    final cacheKey = _generateStatisticsCacheKey(userId, babyId, dateRange);
    
    try {
      // 1. 메모리 캐시 저장
      _memoryStatisticsCache[cacheKey] = statistics;
      
      // 2. 디스크 캐시 저장
      await _cache.set(
        key: cacheKey,
        data: statistics,
        strategy: CacheStrategy.long, // 긴 캐시 보관 기간
        category: 'statistics',
      );
      
      debugPrint('✅ [STATS_CACHE] Statistics cached: $cacheKey');
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error caching statistics: $e');
    }
  }

  /// 차트 데이터 캐시 조회
  Future<StatisticsChartData?> getChartData({
    required String cardType,
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
    required String metricType,
  }) async {
    final cacheKey = _generateChartCacheKey(cardType, userId, babyId, dateRange, metricType);
    
    // 1. 메모리 캐시 확인
    if (_memoryChartCache.containsKey(cacheKey)) {
      debugPrint('🚀 [STATS_CACHE] Memory cache hit for chart: $cacheKey');
      return _memoryChartCache[cacheKey];
    }
    
    // 2. 디스크 캐시 확인
    try {
      final cached = await _cache.get<StatisticsChartData>(
        cacheKey,
        fromJson: StatisticsChartData.fromJson,
      );
      
      if (cached != null) {
        // 메모리 캐시에도 저장
        _memoryChartCache[cacheKey] = cached;
        debugPrint('💾 [STATS_CACHE] Disk cache hit for chart: $cacheKey');
        return cached;
      }
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error reading chart from disk cache: $e');
    }
    
    debugPrint('❌ [STATS_CACHE] Cache miss for chart: $cacheKey');
    return null;
  }

  /// 차트 데이터 캐시 저장
  Future<void> setChartData({
    required String cardType,
    required String userId,
    required String babyId,
    required StatisticsDateRange dateRange,
    required String metricType,
    required StatisticsChartData chartData,
  }) async {
    final cacheKey = _generateChartCacheKey(cardType, userId, babyId, dateRange, metricType);
    
    try {
      // 1. 메모리 캐시 저장
      _memoryChartCache[cacheKey] = chartData;
      
      // 2. 디스크 캐시 저장
      await _cache.set(
        key: cacheKey,
        data: chartData,
        strategy: CacheStrategy.long,
        category: 'statistics',
      );
      
      debugPrint('✅ [STATS_CACHE] Chart data cached: $cacheKey');
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error caching chart data: $e');
    }
  }

  /// 통계 캐시 키 생성
  String _generateStatisticsCacheKey(String userId, String babyId, StatisticsDateRange dateRange) {
    final startDateStr = '${dateRange.startDate.year}${dateRange.startDate.month.toString().padLeft(2, '0')}${dateRange.startDate.day.toString().padLeft(2, '0')}';
    return 'statistics_${userId}_${babyId}_${dateRange.type.toJson()}_$startDateStr';
  }

  /// 차트 캐시 키 생성
  String _generateChartCacheKey(
    String cardType,
    String userId,
    String babyId,
    StatisticsDateRange dateRange,
    String metricType,
  ) {
    final startDateStr = '${dateRange.startDate.year}${dateRange.startDate.month.toString().padLeft(2, '0')}${dateRange.startDate.day.toString().padLeft(2, '0')}';
    return 'chart_${cardType}_${userId}_${babyId}_${dateRange.type.toJson()}_${startDateStr}_$metricType';
  }

  /// 특정 사용자/아기의 모든 캐시 삭제 (수동)
  Future<void> clearCacheForBaby(String userId, String babyId) async {
    await _invalidateCacheForBaby(babyId);
  }

  /// 전체 통계 캐시 삭제
  Future<void> clearAllStatisticsCache() async {
    try {
      // 1. 메모리 캐시 클리어
      _memoryStatisticsCache.clear();
      _memoryChartCache.clear();
      
      // 2. 디스크 캐시 클리어
      await _cache.removeCategory('statistics');
      
      debugPrint('🗑️ [STATS_CACHE] All statistics cache cleared');
    } catch (e) {
      debugPrint('❌ [STATS_CACHE] Error clearing all cache: $e');
    }
  }

  /// 캐시 통계 정보
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryStatisticsCount': _memoryStatisticsCache.length,
      'memoryChartCount': _memoryChartCache.length,
      'pendingInvalidations': _pendingInvalidationKeys.length,
    };
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('🗄️ [STATS_CACHE] Disposing cache service');
    _eventSubscription?.cancel();
    _invalidationTimer?.cancel();
    _memoryStatisticsCache.clear();
    _memoryChartCache.clear();
    _pendingInvalidationKeys.clear();
  }
}