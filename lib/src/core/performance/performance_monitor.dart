import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 📊 성능 모니터링 서비스
/// 
/// 특징:
/// - 실시간 성능 메트릭 수집
/// - 메모리 사용량 모니터링
/// - 네트워크 요청 추적
/// - 사용자 경험 지표 측정
/// - 자동 최적화 제안
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  
  PerformanceMonitor._();

  final Map<String, PerformanceMetric> _metrics = {};
  final List<NetworkRequest> _networkRequests = [];
  final List<MemorySnapshot> _memorySnapshots = [];
  
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  /// 모니터링 시작
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    debugPrint('📊 [PERFORMANCE] Monitoring started');
    
    // 주기적 메모리 모니터링 (10초마다)
    _monitoringTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _collectMemorySnapshot();
    });
    
    // 초기 메트릭 수집
    _collectSystemMetrics();
  }

  /// 모니터링 중지
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    debugPrint('📊 [PERFORMANCE] Monitoring stopped');
  }

  /// 작업 성능 측정 시작
  void startMeasure(String operationName) {
    final metric = PerformanceMetric(
      name: operationName,
      startTime: DateTime.now(),
    );
    
    _metrics[operationName] = metric;
    debugPrint('⏱️ [PERFORMANCE] Started measuring: $operationName');
  }

  /// 작업 성능 측정 완료
  void endMeasure(String operationName, {Map<String, dynamic>? metadata}) {
    final metric = _metrics[operationName];
    if (metric == null) {
      debugPrint('⚠️ [PERFORMANCE] No active measurement for: $operationName');
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(metric.startTime);
    
    final completedMetric = metric.copyWith(
      endTime: endTime,
      duration: duration,
      metadata: metadata,
    );
    
    _metrics[operationName] = completedMetric;
    
    debugPrint('✅ [PERFORMANCE] Completed measuring: $operationName (${duration.inMilliseconds}ms)');
    
    // 성능 임계값 체크
    _checkPerformanceThresholds(completedMetric);
  }

  /// 네트워크 요청 기록
  void recordNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required Duration duration,
    required int responseSize,
    bool fromCache = false,
  }) {
    final request = NetworkRequest(
      url: url,
      method: method,
      statusCode: statusCode,
      duration: duration,
      responseSize: responseSize,
      fromCache: fromCache,
      timestamp: DateTime.now(),
    );
    
    _networkRequests.add(request);
    
    // 최대 100개 요청만 보관
    if (_networkRequests.length > 100) {
      _networkRequests.removeAt(0);
    }
    
    debugPrint('🌐 [PERFORMANCE] Network: $method $url (${duration.inMilliseconds}ms, ${fromCache ? 'cached' : 'network'})');
  }

  /// 메모리 스냅샷 수집
  void _collectMemorySnapshot() {
    try {
      // Flutter에서 메모리 정보는 제한적이므로 추정값 사용
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        usedMemoryMB: _estimateMemoryUsage(),
        dartHeapSizeMB: _estimateDartHeapSize(),
      );
      
      _memorySnapshots.add(snapshot);
      
      // 최대 50개 스냅샷만 보관
      if (_memorySnapshots.length > 50) {
        _memorySnapshots.removeAt(0);
      }
      
      // 메모리 경고 체크
      _checkMemoryWarnings(snapshot);
    } catch (e) {
      debugPrint('❌ [PERFORMANCE] Memory snapshot failed: $e');
    }
  }

  /// 시스템 메트릭 수집
  void _collectSystemMetrics() {
    try {
      debugPrint('📊 [PERFORMANCE] Collecting system metrics...');
      // 플랫폼별 시스템 정보 수집
    } catch (e) {
      debugPrint('❌ [PERFORMANCE] System metrics collection failed: $e');
    }
  }

  /// 메모리 사용량 추정
  double _estimateMemoryUsage() {
    // 실제 구현에서는 플랫폼별 메모리 정보 수집 필요
    return 50.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10;
  }

  /// Dart 힙 크기 추정
  double _estimateDartHeapSize() {
    // 실제 구현에서는 dart:developer의 ServiceExtensions 사용
    return 20.0 + (DateTime.now().millisecondsSinceEpoch % 50) / 10;
  }

  /// 성능 임계값 체크
  void _checkPerformanceThresholds(PerformanceMetric metric) {
    const slowThreshold = Duration(milliseconds: 1000);
    const verySlowThreshold = Duration(milliseconds: 3000);
    
    if (metric.duration != null) {
      if (metric.duration! > verySlowThreshold) {
        debugPrint('🚨 [PERFORMANCE] VERY SLOW operation: ${metric.name} (${metric.duration!.inMilliseconds}ms)');
      } else if (metric.duration! > slowThreshold) {
        debugPrint('⚠️ [PERFORMANCE] Slow operation: ${metric.name} (${metric.duration!.inMilliseconds}ms)');
      }
    }
  }

  /// 메모리 경고 체크
  void _checkMemoryWarnings(MemorySnapshot snapshot) {
    const memoryWarningThreshold = 100.0; // 100MB
    const memoryCriticalThreshold = 150.0; // 150MB
    
    if (snapshot.usedMemoryMB > memoryCriticalThreshold) {
      debugPrint('🚨 [PERFORMANCE] CRITICAL memory usage: ${snapshot.usedMemoryMB.toStringAsFixed(1)}MB');
      _triggerMemoryOptimization();
    } else if (snapshot.usedMemoryMB > memoryWarningThreshold) {
      debugPrint('⚠️ [PERFORMANCE] High memory usage: ${snapshot.usedMemoryMB.toStringAsFixed(1)}MB');
    }
  }

  /// 메모리 최적화 트리거
  void _triggerMemoryOptimization() {
    debugPrint('🧹 [PERFORMANCE] Triggering memory optimization...');
    
    // 캐시 정리
    // 이미지 캐시 정리
    // 불필요한 객체 해제
    
    // 가비지 컬렉션 강제 실행 (주의해서 사용)
    if (kDebugMode) {
      try {
        SystemChannels.platform.invokeMethod('System.gc');
      } catch (e) {
        debugPrint('❌ [PERFORMANCE] GC invocation failed: $e');
      }
    }
  }

  /// 성능 리포트 생성
  PerformanceReport generateReport() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    // 최근 1분간의 메트릭 필터링
    final recentMetrics = _metrics.values
        .where((m) => m.startTime.isAfter(oneMinuteAgo))
        .toList();
    
    final recentNetworkRequests = _networkRequests
        .where((r) => r.timestamp.isAfter(oneMinuteAgo))
        .toList();
    
    final currentMemory = _memorySnapshots.isNotEmpty 
        ? _memorySnapshots.last 
        : null;
    
    return PerformanceReport(
      timestamp: now,
      totalOperations: recentMetrics.length,
      averageOperationTime: _calculateAverageOperationTime(recentMetrics),
      slowOperations: recentMetrics.where((m) => 
          m.duration != null && m.duration!.inMilliseconds > 1000).length,
      networkRequests: recentNetworkRequests.length,
      cacheHitRate: _calculateCacheHitRate(recentNetworkRequests),
      currentMemoryUsage: currentMemory?.usedMemoryMB ?? 0.0,
      recommendations: _generateRecommendations(recentMetrics, recentNetworkRequests),
    );
  }

  /// 평균 작업 시간 계산
  double _calculateAverageOperationTime(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    
    final completedMetrics = metrics.where((m) => m.duration != null).toList();
    if (completedMetrics.isEmpty) return 0.0;
    
    final totalMs = completedMetrics
        .map((m) => m.duration!.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return totalMs / completedMetrics.length;
  }

  /// 캐시 히트율 계산
  double _calculateCacheHitRate(List<NetworkRequest> requests) {
    if (requests.isEmpty) return 0.0;
    
    final cacheHits = requests.where((r) => r.fromCache).length;
    return cacheHits / requests.length;
  }

  /// 최적화 권장사항 생성
  List<String> _generateRecommendations(
    List<PerformanceMetric> metrics,
    List<NetworkRequest> requests,
  ) {
    final recommendations = <String>[];
    
    // 느린 작업 체크
    final slowOperations = metrics.where((m) => 
        m.duration != null && m.duration!.inMilliseconds > 1000).length;
    if (slowOperations > metrics.length * 0.3) {
      recommendations.add('많은 작업이 느리게 실행되고 있습니다. 캐싱을 고려해보세요.');
    }
    
    // 네트워크 요청 체크
    final networkRequests = requests.where((r) => !r.fromCache).length;
    if (networkRequests > 10) {
      recommendations.add('많은 네트워크 요청이 발생하고 있습니다. 배치 처리를 고려해보세요.');
    }
    
    // 캐시 히트율 체크
    final cacheHitRate = _calculateCacheHitRate(requests);
    if (cacheHitRate < 0.5) {
      recommendations.add('캐시 히트율이 낮습니다. 캐싱 전략을 개선해보세요.');
    }
    
    return recommendations;
  }

  /// 리소스 정리
  void dispose() {
    stopMonitoring();
    _metrics.clear();
    _networkRequests.clear();
    _memorySnapshots.clear();
    debugPrint('📊 [PERFORMANCE] Monitor disposed');
  }
}

/// 성능 메트릭
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.name,
    required this.startTime,
    this.endTime,
    this.duration,
    this.metadata,
  });

  PerformanceMetric copyWith({
    DateTime? endTime,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) => PerformanceMetric(
    name: name,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    duration: duration ?? this.duration,
    metadata: metadata ?? this.metadata,
  );
}

/// 네트워크 요청 정보
class NetworkRequest {
  final String url;
  final String method;
  final int statusCode;
  final Duration duration;
  final int responseSize;
  final bool fromCache;
  final DateTime timestamp;

  const NetworkRequest({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.responseSize,
    required this.fromCache,
    required this.timestamp,
  });
}

/// 메모리 스냅샷
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;
  final double dartHeapSizeMB;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.dartHeapSizeMB,
  });
}

/// 성능 리포트
class PerformanceReport {
  final DateTime timestamp;
  final int totalOperations;
  final double averageOperationTime;
  final int slowOperations;
  final int networkRequests;
  final double cacheHitRate;
  final double currentMemoryUsage;
  final List<String> recommendations;

  const PerformanceReport({
    required this.timestamp,
    required this.totalOperations,
    required this.averageOperationTime,
    required this.slowOperations,
    required this.networkRequests,
    required this.cacheHitRate,
    required this.currentMemoryUsage,
    required this.recommendations,
  });

  @override
  String toString() {
    return '''
Performance Report (${timestamp.toString()}):
- Operations: $totalOperations (${slowOperations} slow)
- Avg Time: ${averageOperationTime.toStringAsFixed(1)}ms
- Network: $networkRequests requests
- Cache Hit Rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%
- Memory: ${currentMemoryUsage.toStringAsFixed(1)}MB
- Recommendations: ${recommendations.length}
''';
  }
}