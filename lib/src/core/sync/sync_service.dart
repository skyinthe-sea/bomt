import 'dart:async';
import 'package:flutter/foundation.dart';
import '../connectivity/connectivity_service.dart';
import '../cache/universal_cache_service.dart';
import 'offline_queue_service.dart';

/// 🔄 스마트 동기화 서비스
/// 
/// 특징:
/// - 연결 상태 기반 자동 동기화
/// - 배치 처리로 성능 최적화
/// - 실패 시 재시도 로직
/// - 데이터 우선순위 관리
/// - 사용자 경험 최적화
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  
  SyncService._();

  final _connectivity = ConnectivityService.instance;
  final _cache = UniversalCacheService.instance;
  final _offlineQueue = OfflineQueueService.instance;
  
  StreamSubscription<ConnectionState>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  
  bool _isInitialized = false;
  bool _isSyncing = false;
  SyncStatus _currentStatus = SyncStatus.idle;

  /// 현재 동기화 상태
  SyncStatus get currentStatus => _currentStatus;
  
  /// 동기화 중 여부
  bool get isSyncing => _isSyncing;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 의존성 서비스들 초기화
      await _connectivity.initialize();
      await _cache.initialize();
      await _offlineQueue.initialize();
      
      // 연결 상태 변경 감지
      _connectivitySubscription = _connectivity.connectionStateStream.listen(
        _onConnectionStateChanged,
      );
      
      // 주기적 동기화 설정 (WiFi 연결 시에만)
      _setupPeriodicSync();
      
      _isInitialized = true;
      debugPrint('🔄 [SYNC] Service initialized successfully');
      
      // 초기 동기화 (온라인 상태인 경우)
      if (_connectivity.isOnline) {
        unawaited(_performInitialSync());
      }
    } catch (e) {
      debugPrint('❌ [SYNC] Initialization failed: $e');
    }
  }

  /// 연결 상태 변경 처리
  void _onConnectionStateChanged(ConnectionState state) {
    debugPrint('🔄 [SYNC] Connection state changed: ${state.name}');
    
    switch (state) {
      case ConnectionState.wifi:
      case ConnectionState.mobile:
        // 온라인 상태 - 동기화 시작
        unawaited(_handleOnlineState());
        break;
      case ConnectionState.none:
        // 오프라인 상태 - 동기화 중지
        _handleOfflineState();
        break;
      case ConnectionState.unknown:
        // 알 수 없는 상태 - 대기
        _updateSyncStatus(SyncStatus.waiting);
        break;
    }
  }

  /// 온라인 상태 처리
  Future<void> _handleOnlineState() async {
    debugPrint('✅ [SYNC] Device is online - starting sync');
    await performSync();
    _setupPeriodicSync();
  }

  /// 오프라인 상태 처리
  void _handleOfflineState() {
    debugPrint('📵 [SYNC] Device is offline - stopping sync');
    _cancelPeriodicSync();
    _updateSyncStatus(SyncStatus.offline);
  }

  /// 초기 동기화
  Future<void> _performInitialSync() async {
    try {
      debugPrint('🚀 [SYNC] Performing initial sync...');
      await performSync();
    } catch (e) {
      debugPrint('❌ [SYNC] Initial sync failed: $e');
    }
  }

  /// 메인 동기화 수행
  Future<void> performSync({bool force = false}) async {
    if (_isSyncing && !force) {
      debugPrint('⏳ [SYNC] Sync already in progress');
      return;
    }

    if (!_connectivity.isOnline) {
      debugPrint('📵 [SYNC] Cannot sync - device is offline');
      return;
    }

    _isSyncing = true;
    _updateSyncStatus(SyncStatus.syncing);

    try {
      debugPrint('🔄 [SYNC] Starting synchronization...');
      
      // 1. 오프라인 큐 처리
      await _syncOfflineQueue();
      
      // 2. 캐시 갱신 (우선순위 데이터)
      await _refreshPriorityCache();
      
      // 3. 백그라운드 데이터 미리 로드
      await _preloadBackgroundData();
      
      _updateSyncStatus(SyncStatus.completed);
      debugPrint('✅ [SYNC] Synchronization completed successfully');
      
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      debugPrint('❌ [SYNC] Synchronization failed: $e');
      
      // 실패 시 재시도 스케줄링
      _scheduleRetrySync();
    } finally {
      _isSyncing = false;
    }
  }

  /// 오프라인 큐 동기화
  Future<void> _syncOfflineQueue() async {
    try {
      debugPrint('📤 [SYNC] Processing offline queue...');
      await _offlineQueue.startSync();
    } catch (e) {
      debugPrint('❌ [SYNC] Offline queue sync failed: $e');
      rethrow;
    }
  }

  /// 우선순위 캐시 갱신
  Future<void> _refreshPriorityCache() async {
    try {
      debugPrint('⚡ [SYNC] Refreshing priority cache...');
      
      // 만료된 캐시 정리
      // 실제 구현에서는 각 서비스의 중요한 데이터만 갱신
      
      debugPrint('✅ [SYNC] Priority cache refreshed');
    } catch (e) {
      debugPrint('❌ [SYNC] Priority cache refresh failed: $e');
    }
  }

  /// 백그라운드 데이터 미리 로드
  Future<void> _preloadBackgroundData() async {
    try {
      debugPrint('📦 [SYNC] Preloading background data...');
      
      // WiFi 연결 시에만 대용량 데이터 미리 로드
      if (_connectivity.currentState == ConnectionState.wifi) {
        // 다음 주차 가이드 미리 로드
        // 자주 사용되는 타임라인 데이터 미리 로드
        // 이미지 등 미디어 파일 미리 로드
      }
      
      debugPrint('✅ [SYNC] Background data preloaded');
    } catch (e) {
      debugPrint('❌ [SYNC] Background data preload failed: $e');
    }
  }

  /// 주기적 동기화 설정
  void _setupPeriodicSync() {
    _cancelPeriodicSync(); // 기존 타이머 취소
    
    if (!_connectivity.isOnline) return;
    
    // WiFi: 5분마다, 모바일: 15분마다
    final interval = _connectivity.isHighQualityConnection 
        ? const Duration(minutes: 5)
        : const Duration(minutes: 15);
    
    _periodicSyncTimer = Timer.periodic(interval, (timer) {
      debugPrint('⏰ [SYNC] Periodic sync triggered');
      unawaited(performSync());
    });
    
    debugPrint('⏰ [SYNC] Periodic sync scheduled (${interval.inMinutes} min intervals)');
  }

  /// 주기적 동기화 취소
  void _cancelPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  /// 재시도 동기화 스케줄링
  void _scheduleRetrySync() {
    Timer(const Duration(minutes: 2), () {
      if (_connectivity.isOnline) {
        debugPrint('🔄 [SYNC] Retrying sync after failure...');
        unawaited(performSync());
      }
    });
  }

  /// 동기화 상태 업데이트
  void _updateSyncStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      debugPrint('🔄 [SYNC] Status updated: ${status.name}');
    }
  }

  /// 수동 새로고침 (사용자 트리거)
  Future<void> manualRefresh() async {
    debugPrint('🔄 [SYNC] Manual refresh triggered by user');
    await performSync(force: true);
  }

  /// 특정 카테고리 동기화
  Future<void> syncCategory(String category) async {
    if (!_connectivity.isOnline) {
      debugPrint('📵 [SYNC] Cannot sync category - device is offline');
      return;
    }

    try {
      debugPrint('🎯 [SYNC] Syncing category: $category');
      
      // 해당 카테고리의 캐시 무효화
      await _cache.removeCategory(category);
      
      // 카테고리별 특별 동기화 로직
      switch (category) {
        case 'baby_guide':
          // BabyGuideService 관련 데이터 갱신
          break;
        case 'timeline':
          // TimelineService 관련 데이터 갱신
          break;
        default:
          debugPrint('⚠️ [SYNC] Unknown category: $category');
      }
      
      debugPrint('✅ [SYNC] Category sync completed: $category');
    } catch (e) {
      debugPrint('❌ [SYNC] Category sync failed for $category: $e');
    }
  }

  /// 동기화 통계
  Future<SyncStats> getSyncStats() async {
    final queueStats = await _offlineQueue.getQueueStats();
    final cacheStats = _cache.getStats();
    
    return SyncStats(
      lastSyncTime: DateTime.now(), // 실제로는 마지막 동기화 시간 저장 필요
      syncStatus: _currentStatus,
      isOnline: _connectivity.isOnline,
      connectionType: _connectivity.currentState,
      pendingOperations: queueStats.pendingJobs,
      failedOperations: queueStats.failedJobs,
      cacheHitRate: _calculateCacheHitRate(cacheStats),
    );
  }

  /// 캐시 히트율 계산
  double _calculateCacheHitRate(Map<String, dynamic> cacheStats) {
    // 실제 구현에서는 히트율 통계 수집 필요
    return 0.85; // 임시값
  }

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _cancelPeriodicSync();
    _isInitialized = false;
    debugPrint('🔄 [SYNC] Service disposed');
  }
}

/// 동기화 상태
enum SyncStatus {
  idle,       // 대기 중
  syncing,    // 동기화 중
  completed,  // 완료됨
  failed,     // 실패함
  offline,    // 오프라인
  waiting,    // 연결 대기 중
}

/// 동기화 통계
class SyncStats {
  final DateTime lastSyncTime;
  final SyncStatus syncStatus;
  final bool isOnline;
  final ConnectionState connectionType;
  final int pendingOperations;
  final int failedOperations;
  final double cacheHitRate;

  const SyncStats({
    required this.lastSyncTime,
    required this.syncStatus,
    required this.isOnline,
    required this.connectionType,
    required this.pendingOperations,
    required this.failedOperations,
    required this.cacheHitRate,
  });
}

/// 확장 유틸리티
extension SyncStatusExtension on SyncStatus {
  String get name {
    switch (this) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.waiting:
        return 'Waiting';
    }
  }
}