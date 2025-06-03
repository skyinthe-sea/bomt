import 'package:flutter/foundation.dart';
import '../../domain/models/timeline_item.dart';
import 'app_event_bus.dart';
import 'data_sync_events.dart';

/// 데이터 동기화 헬퍼 클래스 - 편리한 이벤트 발송을 위한 유틸리티
class DataSyncHelper {
  static final AppEventBus _eventBus = AppEventBus.instance;

  /// 수유 데이터 변경 알림
  static void notifyFeedingChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.feedingChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('🍼 [DATA_SYNC] Feeding data changed: $action');
  }

  /// 수면 데이터 변경 알림
  static void notifySleepChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.sleepChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('😴 [DATA_SYNC] Sleep data changed: $action');
  }

  /// 기저귀 데이터 변경 알림
  static void notifyDiaperChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.diaperChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('👶 [DATA_SYNC] Diaper data changed: $action');
  }

  /// 투약 데이터 변경 알림
  static void notifyMedicationChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.medicationChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('💊 [DATA_SYNC] Medication data changed: $action');
  }

  /// 유축 데이터 변경 알림
  static void notifyMilkPumpingChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.milkPumpingChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('🥛 [DATA_SYNC] Milk pumping data changed: $action');
  }

  /// 이유식 데이터 변경 알림
  static void notifySolidFoodChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.solidFoodChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('🥄 [DATA_SYNC] Solid food data changed: $action');
  }

  /// 체온 데이터 변경 알림
  static void notifyTemperatureChanged({
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    _eventBus.notifyDataChanged(
      type: DataSyncEventType.temperatureChanged,
      babyId: babyId,
      date: date,
      action: action,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('🌡️ [DATA_SYNC] Temperature data changed: $action');
  }

  /// 타임라인 아이템 타입에 따른 자동 알림
  static void notifyTimelineItemChanged({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    switch (itemType) {
      case TimelineItemType.feeding:
        notifyFeedingChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.sleep:
        notifySleepChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.diaper:
        notifyDiaperChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.medication:
        notifyMedicationChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.milkPumping:
        notifyMilkPumpingChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.solidFood:
        notifySolidFoodChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
      case TimelineItemType.temperature:
        notifyTemperatureChanged(
          babyId: babyId,
          date: date,
          action: action,
          recordId: recordId,
          metadata: metadata,
        );
        break;
    }
  }

  /// 진행 중인 활동 시작 알림
  static void notifyOngoingActivityStarted({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    final eventType = DataSyncEvent.fromTimelineItemType(itemType);
    _eventBus.notifyOngoingActivityStarted(
      type: eventType,
      babyId: babyId,
      date: date,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('▶️ [DATA_SYNC] Ongoing activity started: $itemType');
  }

  /// 진행 중인 활동 종료 알림
  static void notifyOngoingActivityStopped({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    final eventType = DataSyncEvent.fromTimelineItemType(itemType);
    _eventBus.notifyOngoingActivityStopped(
      type: eventType,
      babyId: babyId,
      date: date,
      recordId: recordId,
      metadata: metadata,
    );
    debugPrint('⏹️ [DATA_SYNC] Ongoing activity stopped: $itemType');
  }

  /// 전체 데이터 새로고침 알림
  static void notifyFullRefresh({
    required String babyId,
    DateTime? date,
  }) {
    _eventBus.notifyFullRefresh(
      babyId: babyId,
      date: date,
    );
    debugPrint('🔄 [DATA_SYNC] Full refresh requested for baby: $babyId');
  }

  /// 데이터 생성 알림 (편의 메서드)
  static void notifyCreated({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    notifyTimelineItemChanged(
      itemType: itemType,
      babyId: babyId,
      date: date,
      action: DataSyncAction.created,
      recordId: recordId,
      metadata: metadata,
    );
  }

  /// 데이터 수정 알림 (편의 메서드)
  static void notifyUpdated({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    notifyTimelineItemChanged(
      itemType: itemType,
      babyId: babyId,
      date: date,
      action: DataSyncAction.updated,
      recordId: recordId,
      metadata: metadata,
    );
  }

  /// 데이터 삭제 알림 (편의 메서드)
  static void notifyDeleted({
    required TimelineItemType itemType,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    notifyTimelineItemChanged(
      itemType: itemType,
      babyId: babyId,
      date: date,
      action: DataSyncAction.deleted,
      recordId: recordId,
      metadata: metadata,
    );
  }
}