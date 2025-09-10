import '../../domain/models/timeline_item.dart';

/// 데이터 동기화 이벤트 타입
enum DataSyncEventType {
  /// 수유 데이터 변경
  feedingChanged,
  /// 수면 데이터 변경
  sleepChanged,
  /// 기저귀 데이터 변경
  diaperChanged,
  /// 투약 데이터 변경
  medicationChanged,
  /// 유축 데이터 변경
  milkPumpingChanged,
  /// 이유식 데이터 변경
  solidFoodChanged,
  /// 체온 데이터 변경
  temperatureChanged,
  /// 커뮤니티 게시글 생성
  communityPostCreated,
  /// 커뮤니티 게시글 수정
  communityPostUpdated,
  /// 커뮤니티 게시글 삭제
  communityPostDeleted,
  /// 커뮤니티 댓글 생성
  communityCommentCreated,
  /// 커뮤니티 댓글 수정
  communityCommentUpdated,
  /// 커뮤니티 댓글 삭제
  communityCommentDeleted,
  /// 사용자 차단
  userBlocked,
  /// 사용자 차단 해제
  userUnblocked,
  /// 콘텐츠 신고
  contentReported,
  /// 콘텐츠 신고 처리
  contentReportResolved,
  /// 모든 데이터 새로고침 필요
  allDataRefresh,
}

/// 데이터 동기화 이벤트
class DataSyncEvent {
  final DataSyncEventType type;
  final String babyId;
  final DateTime affectedDate;
  final String? recordId;
  final DataSyncAction action;
  final Map<String, dynamic>? metadata;

  const DataSyncEvent({
    required this.type,
    required this.babyId,
    required this.affectedDate,
    this.recordId,
    required this.action,
    this.metadata,
  });

  /// TimelineItemType에서 DataSyncEventType으로 변환
  static DataSyncEventType fromTimelineItemType(TimelineItemType itemType) {
    switch (itemType) {
      case TimelineItemType.feeding:
        return DataSyncEventType.feedingChanged;
      case TimelineItemType.sleep:
        return DataSyncEventType.sleepChanged;
      case TimelineItemType.diaper:
        return DataSyncEventType.diaperChanged;
      case TimelineItemType.medication:
        return DataSyncEventType.medicationChanged;
      case TimelineItemType.milkPumping:
        return DataSyncEventType.milkPumpingChanged;
      case TimelineItemType.solidFood:
        return DataSyncEventType.solidFoodChanged;
      case TimelineItemType.temperature:
        return DataSyncEventType.temperatureChanged;
    }
  }

  /// 빠른 생성 메서드들
  static DataSyncEvent created({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    return DataSyncEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      action: DataSyncAction.created,
      metadata: metadata,
    );
  }

  static DataSyncEvent updated({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    return DataSyncEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      action: DataSyncAction.updated,
      metadata: metadata,
    );
  }

  static DataSyncEvent deleted({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    return DataSyncEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      action: DataSyncAction.deleted,
      metadata: metadata,
    );
  }

  static DataSyncEvent refreshAll({
    required String babyId,
    DateTime? date,
  }) {
    return DataSyncEvent(
      type: DataSyncEventType.allDataRefresh,
      babyId: babyId,
      affectedDate: date ?? DateTime.now(),
      action: DataSyncAction.refreshed,
    );
  }

  @override
  String toString() {
    return 'DataSyncEvent(type: $type, action: $action, babyId: $babyId, date: ${affectedDate.toIso8601String()}, recordId: $recordId)';
  }
}

/// 데이터 동기화 액션 타입
enum DataSyncAction {
  /// 새로운 데이터 생성
  created,
  /// 기존 데이터 수정
  updated,
  /// 데이터 삭제
  deleted,
  /// 데이터 새로고침
  refreshed,
}

/// 진행 중인 활동 상태 변경 이벤트
class OngoingActivityEvent extends DataSyncEvent {
  final bool isStarted; // true: 시작, false: 종료

  const OngoingActivityEvent({
    required super.type,
    required super.babyId,
    required super.affectedDate,
    super.recordId,
    required this.isStarted,
    super.metadata,
  }) : super(action: DataSyncAction.updated);

  static OngoingActivityEvent started({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    return OngoingActivityEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      isStarted: true,
      metadata: metadata,
    );
  }

  static OngoingActivityEvent stopped({
    required DataSyncEventType type,
    required String babyId,
    required DateTime date,
    String? recordId,
    Map<String, dynamic>? metadata,
  }) {
    return OngoingActivityEvent(
      type: type,
      babyId: babyId,
      affectedDate: date,
      recordId: recordId,
      isStarted: false,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'OngoingActivityEvent(type: $type, isStarted: $isStarted, babyId: $babyId, date: ${affectedDate.toIso8601String()})';
  }
}