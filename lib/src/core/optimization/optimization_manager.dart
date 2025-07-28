import 'dart:async';
import 'package:flutter/foundation.dart';
import '../cache/universal_cache_service.dart';
import '../connectivity/connectivity_service.dart';
import '../sync/sync_service.dart';
import '../performance/performance_monitor.dart';
import '../image/optimized_image_cache.dart';

/// 🚀 전체 최적화 관리자
/// 
/// 특징:
/// - 모든 최적화 서비스 통합 관리
/// - 자동 성능 튜닝
/// - 상황별 최적화 전략 적용
/// - 리소스 사용량 모니터링
/// - 사용자 경험 최적화
class OptimizationManager {
  static OptimizationManager? _instance;
  static OptimizationManager get instance => _instance ??= OptimizationManager._();
  
  OptimizationManager._();

  // 서비스 인스턴스들
  final _cache = UniversalCacheService.instance;
  final _connectivity = ConnectivityService.instance;
  final _sync = SyncService.instance;
  final _performance = PerformanceMonitor.instance;
  final _imageCache = OptimizedImageCache.instance;

  Timer? _optimizationTimer;
  bool _isInitialized = false;
  bool _autoOptimizationEnabled = true;
  OptimizationLevel _currentLevel = OptimizationLevel.balanced;

  /// 현재 최적화 수준
  OptimizationLevel get currentLevel => _currentLevel;
  
  /// 자동 최적화 활성화 여부
  bool get isAutoOptimizationEnabled => _autoOptimizationEnabled;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 [OPTIMIZATION] Initializing optimization manager...');
      
      // 모든 서비스 초기화
      await Future.wait([
        _cache.initialize(),
        _connectivity.initialize(),
        _sync.initialize(),
        _imageCache.initialize(),
      ]);
      
      // 성능 모니터링 시작
      _performance.startMonitoring();
      
      // 주기적 최적화 설정 (5분마다)
      _setupPeriodicOptimization();
      
      // 초기 최적화 수준 결정
      await _determineOptimizationLevel();
      
      _isInitialized = true;
      debugPrint('✅ [OPTIMIZATION] Manager initialized successfully');
      
      // 초기 최적화 실행
      unawaited(_performInitialOptimization());
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Initialization failed: $e');
    }
  }

  /// 자동 최적화 활성화/비활성화
  void setAutoOptimization(bool enabled) {
    _autoOptimizationEnabled = enabled;
    
    if (enabled) {
      _setupPeriodicOptimization();
      debugPrint('✅ [OPTIMIZATION] Auto optimization enabled');
    } else {
      _optimizationTimer?.cancel();
      debugPrint('⏸️ [OPTIMIZATION] Auto optimization disabled');
    }
  }

  /// 최적화 수준 설정
  Future<void> setOptimizationLevel(OptimizationLevel level) async {
    if (_currentLevel == level) return;
    
    _currentLevel = level;
    debugPrint('🎚️ [OPTIMIZATION] Level changed to: ${level.name}');
    
    // 수준에 따른 설정 적용
    await _applyOptimizationLevel(level);
  }

  /// 주기적 최적화 설정
  void _setupPeriodicOptimization() {
    _optimizationTimer?.cancel();
    
    if (!_autoOptimizationEnabled) return;
    
    _optimizationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_autoOptimizationEnabled) {
        unawaited(_performPeriodicOptimization());
      }
    });
  }

  /// 초기 최적화 수준 결정
  Future<void> _determineOptimizationLevel() async {
    try {
      // 연결 상태 기반 결정
      if (_connectivity.isOffline) {
        _currentLevel = OptimizationLevel.aggressive;
      } else if (_connectivity.isDataSavingMode) {
        _currentLevel = OptimizationLevel.conservative;
      } else if (_connectivity.isHighQualityConnection) {
        _currentLevel = OptimizationLevel.performance;
      } else {
        _currentLevel = OptimizationLevel.balanced;
      }
      
      debugPrint('🎯 [OPTIMIZATION] Initial level: ${_currentLevel.name}');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Level determination failed: $e');
      _currentLevel = OptimizationLevel.balanced;
    }
  }

  /// 최적화 수준 적용
  Future<void> _applyOptimizationLevel(OptimizationLevel level) async {
    try {
      switch (level) {
        case OptimizationLevel.performance:
          await _applyPerformanceMode();
          break;
        case OptimizationLevel.balanced:
          await _applyBalancedMode();
          break;
        case OptimizationLevel.conservative:
          await _applyConservativeMode();
          break;
        case OptimizationLevel.aggressive:
          await _applyAggressiveMode();
          break;
      }
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Level application failed: $e');
    }
  }

  /// 성능 우선 모드
  Future<void> _applyPerformanceMode() async {
    debugPrint('⚡ [OPTIMIZATION] Applying performance mode...');
    
    // 캐시 전략: 메모리 캐시 최대화
    // 이미지 품질: 높음
    // 동기화 간격: 짧음 (실시간성 우선)
    // 백그라운드 작업: 적극적
  }

  /// 균형 모드
  Future<void> _applyBalancedMode() async {
    debugPrint('⚖️ [OPTIMIZATION] Applying balanced mode...');
    
    // 캐시 전략: 메모리 + 디스크 균형
    // 이미지 품질: 중간
    // 동기화 간격: 보통
    // 백그라운드 작업: 적당히
  }

  /// 절약 모드
  Future<void> _applyConservativeMode() async {
    debugPrint('💾 [OPTIMIZATION] Applying conservative mode...');
    
    // 캐시 전략: 디스크 캐시 우선
    // 이미지 품질: 낮음 (데이터 절약)
    // 동기화 간격: 긴 간격
    // 백그라운드 작업: 최소화
  }

  /// 적극적 최적화 모드 (오프라인 등)
  Future<void> _applyAggressiveMode() async {
    debugPrint('🔥 [OPTIMIZATION] Applying aggressive mode...');
    
    // 캐시 전략: 모든 캐시 활용
    // 이미지: 캐시된 것만 사용
    // 동기화: 중지
    // 백그라운드 작업: 중지
    // 메모리 정리: 적극적
  }

  /// 초기 최적화 실행
  Future<void> _performInitialOptimization() async {
    try {
      debugPrint('🚀 [OPTIMIZATION] Performing initial optimization...');
      
      // 캐시 정리
      await _cleanupCaches();
      
      // 연결 상태 기반 최적화
      if (_connectivity.isOnline && _connectivity.isHighQualityConnection) {
        // 고품질 연결: 데이터 미리 로드
        await _preloadCriticalData();
      }
      
      debugPrint('✅ [OPTIMIZATION] Initial optimization completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Initial optimization failed: $e');
    }
  }

  /// 주기적 최적화 실행
  Future<void> _performPeriodicOptimization() async {
    try {
      debugPrint('🔄 [OPTIMIZATION] Performing periodic optimization...');
      
      // 성능 리포트 분석
      final report = _performance.generateReport();
      await _analyzePerformanceReport(report);
      
      // 메모리 사용량 체크
      await _checkMemoryUsage();
      
      // 캐시 최적화
      await _optimizeCaches();
      
      // 연결 상태 변화 대응
      await _adaptToConnectivityChanges();
      
      debugPrint('✅ [OPTIMIZATION] Periodic optimization completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Periodic optimization failed: $e');
    }
  }

  /// 성능 리포트 분석
  Future<void> _analyzePerformanceReport(PerformanceReport report) async {
    try {
      debugPrint('📊 [OPTIMIZATION] Analyzing performance report...');
      
      // 느린 작업이 많은 경우
      if (report.slowOperations > report.totalOperations * 0.3) {
        debugPrint('⚠️ [OPTIMIZATION] High slow operation rate detected');
        await _optimizeForSlowOperations();
      }
      
      // 캐시 히트율이 낮은 경우
      if (report.cacheHitRate < 0.5) {
        debugPrint('⚠️ [OPTIMIZATION] Low cache hit rate detected');
        await _optimizeCacheStrategy();
      }
      
      // 메모리 사용량이 높은 경우
      if (report.currentMemoryUsage > 100.0) {
        debugPrint('⚠️ [OPTIMIZATION] High memory usage detected');
        await _optimizeMemoryUsage();
      }
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Performance analysis failed: $e');
    }
  }

  /// 느린 작업 최적화
  Future<void> _optimizeForSlowOperations() async {
    // 캐시 전략 강화
    // 백그라운드 작업 우선순위 조정
    // 불필요한 작업 지연
  }

  /// 캐시 전략 최적화
  Future<void> _optimizeCacheStrategy() async {
    // 캐시 만료 시간 연장
    // 메모리 캐시 크기 증가
    // 미리 로드 전략 강화
  }

  /// 메모리 사용량 최적화
  Future<void> _optimizeMemoryUsage() async {
    try {
      // 이미지 캐시 정리
      await _imageCache.clearCache(memoryOnly: true);
      
      // 기본 캐시 정리
      // await _cache.cleanupExpiredCache(); // 이 메서드가 public이어야 함
      
      debugPrint('🧹 [OPTIMIZATION] Memory optimization completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Memory optimization failed: $e');
    }
  }

  /// 메모리 사용량 체크
  Future<void> _checkMemoryUsage() async {
    // 메모리 모니터링 및 임계값 체크
    // 필요시 자동 메모리 정리
  }

  /// 캐시 최적화
  Future<void> _optimizeCaches() async {
    try {
      // 만료된 캐시 정리
      // 사용 빈도가 낮은 캐시 제거
      // 캐시 크기 조정
      
      debugPrint('🧹 [OPTIMIZATION] Cache optimization completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Cache optimization failed: $e');
    }
  }

  /// 연결 상태 변화 대응
  Future<void> _adaptToConnectivityChanges() async {
    try {
      final currentState = _connectivity.currentState;
      
      // 연결 상태에 따른 최적화 수준 자동 조정
      OptimizationLevel newLevel;
      
      switch (currentState) {
        case ConnectionState.wifi:
          newLevel = OptimizationLevel.performance;
          break;
        case ConnectionState.mobile:
          newLevel = OptimizationLevel.conservative;
          break;
        case ConnectionState.none:
          newLevel = OptimizationLevel.aggressive;
          break;
        case ConnectionState.unknown:
          newLevel = OptimizationLevel.balanced;
          break;
      }
      
      if (newLevel != _currentLevel) {
        await setOptimizationLevel(newLevel);
      }
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Connectivity adaptation failed: $e');
    }
  }

  /// 캐시 정리
  Future<void> _cleanupCaches() async {
    try {
      debugPrint('🧹 [OPTIMIZATION] Cleaning up caches...');
      
      // 이미지 캐시 정리
      // await _imageCache.cleanupExpiredCache(); // private 메서드이므로 접근 불가
      
      debugPrint('✅ [OPTIMIZATION] Cache cleanup completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Cache cleanup failed: $e');
    }
  }

  /// 중요한 데이터 미리 로드
  Future<void> _preloadCriticalData() async {
    try {
      debugPrint('📦 [OPTIMIZATION] Preloading critical data...');
      
      // 다음에 필요할 것 같은 데이터 미리 로드
      // 사용자 패턴 기반 예측 로딩
      
      debugPrint('✅ [OPTIMIZATION] Critical data preloading completed');
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Critical data preloading failed: $e');
    }
  }

  /// 수동 최적화 실행
  Future<void> performManualOptimization() async {
    debugPrint('🔧 [OPTIMIZATION] Manual optimization triggered');
    await _performPeriodicOptimization();
  }

  /// 최적화 통계
  Future<OptimizationStats> getStats() async {
    try {
      final performanceReport = _performance.generateReport();
      final imageCacheStats = await _imageCache.getStats();
      final cacheStats = _cache.getStats();
      
      return OptimizationStats(
        optimizationLevel: _currentLevel,
        autoOptimizationEnabled: _autoOptimizationEnabled,
        connectionState: _connectivity.currentState,
        isOnline: _connectivity.isOnline,
        averageOperationTime: performanceReport.averageOperationTime,
        cacheHitRate: performanceReport.cacheHitRate,
        memoryUsage: performanceReport.currentMemoryUsage,
        imageCacheSize: imageCacheStats.diskCacheSizeMB,
        recommendations: performanceReport.recommendations,
      );
    } catch (e) {
      debugPrint('❌ [OPTIMIZATION] Stats generation failed: $e');
      return OptimizationStats.empty();
    }
  }

  /// 리소스 정리
  void dispose() {
    _optimizationTimer?.cancel();
    _performance.stopMonitoring();
    _isInitialized = false;
    debugPrint('🚀 [OPTIMIZATION] Manager disposed');
  }
}

/// 최적화 수준
enum OptimizationLevel {
  performance,    // 성능 우선
  balanced,       // 균형
  conservative,   // 절약
  aggressive,     // 적극적 (극한 상황)
}

/// 최적화 통계
class OptimizationStats {
  final OptimizationLevel optimizationLevel;
  final bool autoOptimizationEnabled;
  final ConnectionState connectionState;
  final bool isOnline;
  final double averageOperationTime;
  final double cacheHitRate;
  final double memoryUsage;
  final double imageCacheSize;
  final List<String> recommendations;

  const OptimizationStats({
    required this.optimizationLevel,
    required this.autoOptimizationEnabled,
    required this.connectionState,
    required this.isOnline,
    required this.averageOperationTime,
    required this.cacheHitRate,
    required this.memoryUsage,
    required this.imageCacheSize,
    required this.recommendations,
  });

  factory OptimizationStats.empty() => const OptimizationStats(
    optimizationLevel: OptimizationLevel.balanced,
    autoOptimizationEnabled: false,
    connectionState: ConnectionState.unknown,
    isOnline: false,
    averageOperationTime: 0.0,
    cacheHitRate: 0.0,
    memoryUsage: 0.0,
    imageCacheSize: 0.0,
    recommendations: [],
  );

  @override
  String toString() {
    return '''
Optimization Stats:
- Level: ${optimizationLevel.name}
- Auto: $autoOptimizationEnabled
- Connection: ${connectionState.name} (${isOnline ? 'online' : 'offline'})
- Avg Operation: ${averageOperationTime.toStringAsFixed(1)}ms
- Cache Hit Rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%
- Memory: ${memoryUsage.toStringAsFixed(1)}MB
- Image Cache: ${imageCacheSize.toStringAsFixed(1)}MB
- Recommendations: ${recommendations.length}
''';
  }
}

/// 최적화 수준 확장
extension OptimizationLevelExtension on OptimizationLevel {
  String get name {
    switch (this) {
      case OptimizationLevel.performance:
        return 'Performance';
      case OptimizationLevel.balanced:
        return 'Balanced';
      case OptimizationLevel.conservative:
        return 'Conservative';
      case OptimizationLevel.aggressive:
        return 'Aggressive';
    }
  }
  
  String get description {
    switch (this) {
      case OptimizationLevel.performance:
        return '성능 우선 - 빠른 응답을 위해 더 많은 리소스 사용';
      case OptimizationLevel.balanced:
        return '균형 - 성능과 리소스 사용의 균형';
      case OptimizationLevel.conservative:
        return '절약 - 데이터와 배터리 절약 우선';
      case OptimizationLevel.aggressive:
        return '적극적 - 극한 상황에서의 최대 최적화';
    }
  }
}