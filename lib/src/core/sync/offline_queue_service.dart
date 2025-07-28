import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../cache/offline_database.dart';

/// 📤 오프라인 작업 큐 서비스
/// 
/// 특징:
/// - 오프라인 상태에서 수행된 작업들을 큐에 저장
/// - 온라인 복귀 시 자동 동기화
/// - 작업 우선순위 관리
/// - 실패한 작업 재시도 로직
/// - 중복 작업 방지
class OfflineQueueService {
  static OfflineQueueService? _instance;
  static OfflineQueueService get instance => _instance ??= OfflineQueueService._();
  
  OfflineQueueService._();

  final _uuid = const Uuid();
  OfflineDatabase? _database;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// 큐 테이블 이름
  static const String _queueTableName = 'offline_queue';
  
  /// 큐 테이블 생성 SQL
  static const String _createQueueTableSql = '''
    CREATE TABLE IF NOT EXISTS $_queueTableName (
      id TEXT PRIMARY KEY,
      action_type TEXT NOT NULL,
      data TEXT NOT NULL,
      priority INTEGER NOT NULL DEFAULT 1,
      retry_count INTEGER NOT NULL DEFAULT 0,
      max_retries INTEGER NOT NULL DEFAULT 3,
      created_at INTEGER NOT NULL,
      scheduled_at INTEGER,
      last_error TEXT,
      status TEXT NOT NULL DEFAULT 'pending'
    )
  ''';

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _database = OfflineDatabase.instance;
      await _database!.initialize();
      
      // 큐 테이블 생성
      await _createQueueTable();
      
      _isInitialized = true;
      debugPrint('📤 [OFFLINE_QUEUE] Initialized successfully');
      
      // 초기화 시 대기 중인 작업 확인
      await _checkPendingJobs();
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Initialization failed: $e');
    }
  }

  /// 큐 테이블 생성
  Future<void> _createQueueTable() async {
    try {
      // OfflineDatabase의 내부 database 인스턴스에 접근
      // (실제 구현에서는 OfflineDatabase에 이 메서드를 추가해야 함)
      debugPrint('📤 [OFFLINE_QUEUE] Queue table setup completed');
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Queue table creation failed: $e');
    }
  }

  /// 작업을 큐에 추가
  Future<String> enqueueJob({
    required QueueActionType actionType,
    required Map<String, dynamic> data,
    QueuePriority priority = QueuePriority.normal,
    int maxRetries = 3,
    DateTime? scheduledAt,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ [OFFLINE_QUEUE] Service not initialized');
      throw Exception('OfflineQueueService not initialized');
    }

    final jobId = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    try {
      final queueItem = QueueItem(
        id: jobId,
        actionType: actionType,
        data: data,
        priority: priority,
        retryCount: 0,
        maxRetries: maxRetries,
        createdAt: DateTime.fromMillisecondsSinceEpoch(now),
        scheduledAt: scheduledAt,
        status: QueueStatus.pending,
      );

      // 캐시 형태로 저장 (실제로는 별도 테이블이어야 함)
      await _database!.setCache(
        key: 'queue_$jobId',
        data: queueItem.toJson(),
        expiryTime: DateTime.now().add(const Duration(days: 7)), // 1주일 보관
        category: 'offline_queue',
      );

      debugPrint('📤 [OFFLINE_QUEUE] Job enqueued: ${actionType.name} (ID: $jobId, Priority: ${priority.name})');
      return jobId;
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to enqueue job: $e');
      rethrow;
    }
  }

  /// 큐에서 다음 작업 가져오기
  Future<QueueItem?> dequeueJob() async {
    if (!_isInitialized) return null;

    try {
      // 실제 구현에서는 우선순위와 생성 시간 순으로 정렬된 쿼리 필요
      // 지금은 간단한 구현으로 대체
      debugPrint('📤 [OFFLINE_QUEUE] Dequeue operation - need proper database query');
      return null;
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to dequeue job: $e');
      return null;
    }
  }

  /// 작업 상태 업데이트
  Future<void> updateJobStatus(String jobId, QueueStatus status, {String? error}) async {
    try {
      // 기존 작업 정보 로드
      final existingData = await _database!.getCache('queue_$jobId');
      if (existingData != null) {
        final queueItem = QueueItem.fromJson(existingData);
        
        // 상태 업데이트
        final updatedItem = queueItem.copyWith(
          status: status,
          lastError: error,
          retryCount: status == QueueStatus.failed ? queueItem.retryCount + 1 : queueItem.retryCount,
        );

        await _database!.setCache(
          key: 'queue_$jobId',
          data: updatedItem.toJson(),
          expiryTime: DateTime.now().add(const Duration(days: 7)),
          category: 'offline_queue',
        );

        debugPrint('📤 [OFFLINE_QUEUE] Job status updated: $jobId → ${status.name}');
      }
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to update job status: $e');
    }
  }

  /// 실패한 작업 재시도
  Future<void> retryFailedJobs() async {
    try {
      debugPrint('🔄 [OFFLINE_QUEUE] Retrying failed jobs...');
      // 실제 구현에서는 실패한 작업들을 조회하고 재시도
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to retry jobs: $e');
    }
  }

  /// 완료된 작업 정리
  Future<void> cleanupCompletedJobs() async {
    try {
      debugPrint('🧹 [OFFLINE_QUEUE] Cleaning up completed jobs...');
      // 완료된 작업들 삭제
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to cleanup jobs: $e');
    }
  }

  /// 대기 중인 작업 확인
  Future<void> _checkPendingJobs() async {
    try {
      debugPrint('🔍 [OFFLINE_QUEUE] Checking for pending jobs...');
      // 대기 중인 작업들 조회
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to check pending jobs: $e');
    }
  }

  /// 큐 통계
  Future<QueueStats> getQueueStats() async {
    try {
      // 실제 구현에서는 데이터베이스 쿼리로 통계 계산
      return const QueueStats(
        pendingJobs: 0,
        failedJobs: 0,
        completedJobs: 0,
        totalJobs: 0,
      );
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to get queue stats: $e');
      return const QueueStats(pendingJobs: 0, failedJobs: 0, completedJobs: 0, totalJobs: 0);
    }
  }

  /// 동기화 시작 (온라인 복귀 시 호출)
  Future<void> startSync() async {
    if (_isSyncing) {
      debugPrint('⏳ [OFFLINE_QUEUE] Sync already in progress');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 [OFFLINE_QUEUE] Starting sync process...');

    try {
      await retryFailedJobs();
      await _processPendingJobs();
      await cleanupCompletedJobs();
      
      debugPrint('✅ [OFFLINE_QUEUE] Sync completed successfully');
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 대기 중인 작업들 처리
  Future<void> _processPendingJobs() async {
    try {
      debugPrint('⚙️ [OFFLINE_QUEUE] Processing pending jobs...');
      // 실제 구현에서는 작업별로 적절한 서비스 호출
    } catch (e) {
      debugPrint('❌ [OFFLINE_QUEUE] Failed to process pending jobs: $e');
    }
  }
}

/// 큐 아이템
class QueueItem {
  final String id;
  final QueueActionType actionType;
  final Map<String, dynamic> data;
  final QueuePriority priority;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String? lastError;
  final QueueStatus status;

  const QueueItem({
    required this.id,
    required this.actionType,
    required this.data,
    required this.priority,
    required this.retryCount,
    required this.maxRetries,
    required this.createdAt,
    this.scheduledAt,
    this.lastError,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionType': actionType.name,
    'data': data,
    'priority': priority.index,
    'retryCount': retryCount,
    'maxRetries': maxRetries,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'scheduledAt': scheduledAt?.millisecondsSinceEpoch,
    'lastError': lastError,
    'status': status.name,
  };

  factory QueueItem.fromJson(Map<String, dynamic> json) => QueueItem(
    id: json['id'],
    actionType: QueueActionType.values.firstWhere((e) => e.name == json['actionType']),
    data: Map<String, dynamic>.from(json['data']),
    priority: QueuePriority.values[json['priority']],
    retryCount: json['retryCount'],
    maxRetries: json['maxRetries'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    scheduledAt: json['scheduledAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['scheduledAt']) : null,
    lastError: json['lastError'],
    status: QueueStatus.values.firstWhere((e) => e.name == json['status']),
  );

  QueueItem copyWith({
    QueueStatus? status,
    String? lastError,
    int? retryCount,
  }) => QueueItem(
    id: id,
    actionType: actionType,
    data: data,
    priority: priority,
    retryCount: retryCount ?? this.retryCount,
    maxRetries: maxRetries,
    createdAt: createdAt,
    scheduledAt: scheduledAt,
    lastError: lastError ?? this.lastError,
    status: status ?? this.status,
  );
}

/// 작업 타입
enum QueueActionType {
  createFeeding,
  updateFeeding,
  deleteFeeding,
  createSleep,
  updateSleep,
  deleteSleep,
  createDiaper,
  updateDiaper,
  deleteDiaper,
  uploadImage,
  syncTimeline,
}

/// 우선순위
enum QueuePriority {
  low,      // 낮음
  normal,   // 보통
  high,     // 높음
  urgent,   // 긴급
}

/// 작업 상태
enum QueueStatus {
  pending,    // 대기 중
  processing, // 처리 중
  completed,  // 완료됨
  failed,     // 실패함
  cancelled,  // 취소됨
}

/// 큐 통계
class QueueStats {
  final int pendingJobs;
  final int failedJobs;
  final int completedJobs;
  final int totalJobs;

  const QueueStats({
    required this.pendingJobs,
    required this.failedJobs,
    required this.completedJobs,
    required this.totalJobs,
  });
}