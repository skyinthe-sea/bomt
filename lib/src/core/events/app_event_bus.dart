import 'dart:async';
import 'package:flutter/foundation.dart';
import 'data_sync_events.dart';

/// 앱 전체 이벤트 버스 - 데이터 동기화 및 상태 관리
class AppEventBus {
  static AppEventBus? _instance;
  static AppEventBus get instance => _instance ??= AppEventBus._();
  
  AppEventBus._();

  // 이벤트 스트림 컨트롤러들
  final StreamController<DataSyncEvent> _dataSyncController = 
      StreamController<DataSyncEvent>.broadcast();
  
  final StreamController<OngoingActivityEvent> _ongoingActivityController = 
      StreamController<OngoingActivityEvent>.broadcast();

  // 스트림 노출 (읽기 전용)
  Stream<DataSyncEvent> get dataSyncStream => _dataSyncController.stream;
  Stream<OngoingActivityEvent> get ongoingActivityStream => _ongoingActivityController.stream;

  // 통합 스트림 - 모든 데이터 동기화 이벤트
  Stream<DataSyncEvent> get allDataSyncEvents => 
      StreamGroup.merge([dataSyncStream, ongoingActivityStream]);

  /// 데이터 동기화 이벤트 발송
  void emitDataSync(DataSyncEvent event) {
    debugPrint('🚀 [EVENT_BUS] Emitting data sync event: $event');
    _dataSyncController.add(event);
  }

  /// 진행 중인 활동 이벤트 발송
  void emitOngoingActivity(OngoingActivityEvent event) {
    debugPrint('🔄 [EVENT_BUS] Emitting ongoing activity event: $event');
    _ongoingActivityController.add(event);
  }

  /// 특정 타입의 데이터 변경 알림
  void notifyDataChanged({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    required DataSyncAction action,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    final event = DataSyncEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      action: action,
      metadata: metadata,
    );
    emitDataSync(event);
  }

  /// 진행 중인 활동 시작 알림
  void notifyOngoingActivityStarted({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    final event = OngoingActivityEvent.started(
      type: type,
      babyId: babyId,
      date: date,
      recordId: recordId,
      metadata: metadata,
    );
    emitOngoingActivity(event);
  }

  /// 진행 중인 활동 종료 알림
  void notifyOngoingActivityStopped({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    final event = OngoingActivityEvent.stopped(
      type: type,
      babyId: babyId,
      date: date,
      recordId: recordId,
      metadata: metadata,
    );
    emitOngoingActivity(event);
  }

  /// 전체 데이터 새로고침 알림
  void notifyFullRefresh({
    required String babyId,
    DateTime? date,
  }) {
    final event = DataSyncEvent.refreshAll(
      babyId: babyId,
      date: date,
    );
    emitDataSync(event);
  }

  /// 특정 아기 및 날짜에 대한 이벤트 필터링 스트림
  Stream<DataSyncEvent> getFilteredStream({
    required String babyId,
    DateTime? date,
    List<DataSyncEventType>? eventTypes,
  }) {
    return allDataSyncEvents.where((event) {
      // 아기 ID 필터
      if (event.babyId != babyId) return false;
      
      // 날짜 필터 (같은 날짜만)
      if (date != null) {
        final eventDate = event.affectedDate;
        if (eventDate.year != date.year ||
            eventDate.month != date.month ||
            eventDate.day != date.day) {
          return false;
        }
      }
      
      // 이벤트 타입 필터
      if (eventTypes != null && !eventTypes.contains(event.type)) {
        return false;
      }
      
      return true;
    });
  }

  /// 타임라인 관련 이벤트만 필터링
  Stream<DataSyncEvent> getTimelineEventsStream({
    required String babyId,
    DateTime? date,
  }) {
    const timelineEventTypes = [
      DataSyncEventType.feedingChanged,
      DataSyncEventType.sleepChanged,
      DataSyncEventType.diaperChanged,
      DataSyncEventType.medicationChanged,
      DataSyncEventType.milkPumpingChanged,
      DataSyncEventType.solidFoodChanged,
      DataSyncEventType.temperatureChanged,
      DataSyncEventType.allDataRefresh,
    ];

    return getFilteredStream(
      babyId: babyId,
      date: date,
      eventTypes: timelineEventTypes,
    );
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('🗑️ [EVENT_BUS] Disposing event bus');
    _dataSyncController.close();
    _ongoingActivityController.close();
  }
}

/// StreamGroup 대체 구현 (단순화)
class StreamGroup {
  static Stream<T> merge<T>(List<Stream<T>> streams) {
    late StreamController<T> controller;
    List<StreamSubscription<T>> subscriptions = [];

    controller = StreamController<T>(
      onListen: () {
        for (final stream in streams) {
          subscriptions.add(
            stream.listen(
              (data) => controller.add(data),
              onError: (error) => controller.addError(error),
            ),
          );
        }
      },
      onCancel: () {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }
}