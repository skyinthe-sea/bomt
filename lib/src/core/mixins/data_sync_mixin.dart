import 'package:flutter/foundation.dart';
import '../events/app_event_bus.dart';
import '../events/data_sync_events.dart';
import '../events/data_sync_helper.dart';
import '../../domain/models/timeline_item.dart';

/// 데이터 동기화 Mixin - 모든 서비스에서 자동 이벤트 발송
mixin DataSyncMixin {
  /// EventBus 인스턴스
  static final AppEventBus _eventBus = AppEventBus.instance;

  /// 데이터 생성 후 이벤트 발송
  void notifyDataCreated({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      DataSyncHelper.notifyCreated(
        itemType: itemType,
        babyId: babyId,
        date: timestamp,
        recordId: recordId,
        metadata: metadata,
      );
      debugPrint('✅ [DATA_SYNC] Created event sent: $itemType at ${timestamp.toIso8601String()}');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send created event: $e');
    }
  }

  /// 데이터 수정 후 이벤트 발송
  void notifyDataUpdated({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      DataSyncHelper.notifyUpdated(
        itemType: itemType,
        babyId: babyId,
        date: timestamp,
        recordId: recordId,
        metadata: metadata,
      );
      debugPrint('✅ [DATA_SYNC] Updated event sent: $itemType at ${timestamp.toIso8601String()}');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send updated event: $e');
    }
  }

  /// 데이터 삭제 후 이벤트 발송
  void notifyDataDeleted({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      DataSyncHelper.notifyDeleted(
        itemType: itemType,
        babyId: babyId,
        date: timestamp,
        recordId: recordId,
        metadata: metadata,
      );
      debugPrint('✅ [DATA_SYNC] Deleted event sent: $itemType at ${timestamp.toIso8601String()}');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send deleted event: $e');
    }
  }

  /// 진행 중인 활동 시작 알림
  void notifyOngoingStarted({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      DataSyncHelper.notifyOngoingActivityStarted(
        itemType: itemType,
        babyId: babyId,
        date: timestamp,
        recordId: recordId,
        metadata: metadata,
      );
      debugPrint('▶️ [DATA_SYNC] Ongoing started event sent: $itemType');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send ongoing started event: $e');
    }
  }

  /// 진행 중인 활동 종료 알림
  void notifyOngoingStopped({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      DataSyncHelper.notifyOngoingActivityStopped(
        itemType: itemType,
        babyId: babyId,
        date: timestamp,
        recordId: recordId,
        metadata: metadata,
      );
      debugPrint('⏹️ [DATA_SYNC] Ongoing stopped event sent: $itemType');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send ongoing stopped event: $e');
    }
  }

  /// 전체 새로고침 알림
  void notifyFullDataRefresh({
    required String babyId,
    DateTime? timestamp,
  }) {
    try {
      DataSyncHelper.notifyFullRefresh(
        babyId: babyId,
        date: timestamp,
      );
      debugPrint('🔄 [DATA_SYNC] Full refresh event sent for baby: $babyId');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send full refresh event: $e');
    }
  }

  /// 안전한 이벤트 발송 래퍼 - 에러가 발생해도 주요 로직에 영향 없음
  Future<T> withDataSyncEvent<T>({
    required Future<T> Function() operation,
    required TimelineItemType itemType,
    required String babyId,
    required DateTime timestamp,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 주요 작업 실행
      final result = await operation();
      
      // 성공 시 이벤트 발송
      switch (action) {
        case DataSyncAction.created:
          notifyDataCreated(
            itemType: itemType,
            babyId: babyId,
            timestamp: timestamp,
            recordId: recordId,
            metadata: metadata,
          );
          break;
        case DataSyncAction.updated:
          notifyDataUpdated(
            itemType: itemType,
            babyId: babyId,
            timestamp: timestamp,
            recordId: recordId,
            metadata: metadata,
          );
          break;
        case DataSyncAction.deleted:
          notifyDataDeleted(
            itemType: itemType,
            babyId: babyId,
            timestamp: timestamp,
            recordId: recordId,
            metadata: metadata,
          );
          break;
        case DataSyncAction.refreshed:
          notifyFullDataRefresh(
            babyId: babyId,
            timestamp: timestamp,
          );
          break;
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Operation failed, no event sent: $e');
      rethrow;
    }
  }

  /// 배치 이벤트 발송 - 여러 데이터를 한 번에 처리할 때
  void notifyBatchDataChanged({
    required List<TimelineItemType> itemTypes,
    required String babyId,
    required DateTime timestamp,
    required DataSyncAction action,
  }) {
    try {
      for (final itemType in itemTypes) {
        switch (action) {
          case DataSyncAction.created:
            notifyDataCreated(
              itemType: itemType,
              babyId: babyId,
              timestamp: timestamp,
            );
            break;
          case DataSyncAction.updated:
            notifyDataUpdated(
              itemType: itemType,
              babyId: babyId,
              timestamp: timestamp,
            );
            break;
          case DataSyncAction.deleted:
            notifyDataDeleted(
              itemType: itemType,
              babyId: babyId,
              timestamp: timestamp,
            );
            break;
          case DataSyncAction.refreshed:
            notifyFullDataRefresh(babyId: babyId, timestamp: timestamp);
            return; // 전체 새로고침은 한 번만
        }
      }
      debugPrint('🔄 [DATA_SYNC] Batch events sent: ${itemTypes.length} types');
    } catch (e) {
      debugPrint('❌ [DATA_SYNC] Failed to send batch events: $e');
    }
  }
}