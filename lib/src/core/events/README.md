# 데이터 동기화 시스템 사용법

## 개요
EventBus 기반의 실시간 데이터 동기화 시스템입니다. 홈스크린에서 데이터를 변경하면 타임라인이 자동으로 업데이트됩니다.

## 주요 컴포넌트

### 1. AppEventBus
- 앱 전체 이벤트 버스 (싱글톤)
- 데이터 변경 이벤트를 전파

### 2. DataSyncEvents
- 데이터 변경 이벤트 모델
- 이벤트 타입과 액션 정의

### 3. DataSyncHelper
- 편리한 이벤트 발송을 위한 헬퍼 클래스
- 타입별 이벤트 발송 메서드 제공

## 홈스크린에서 사용법

### 데이터 삭제 시
```dart
import '../core/events/data_sync_helper.dart';

// 수유 데이터 삭제 후
DataSyncHelper.notifyDeleted(
  itemType: TimelineItemType.feeding,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '삭제된레코드ID',
);

// 수면 데이터 삭제 후
DataSyncHelper.notifyDeleted(
  itemType: TimelineItemType.sleep,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '삭제된레코드ID',
);
```

### 데이터 생성 시
```dart
// 새로운 기저귀 기록 생성 후
DataSyncHelper.notifyCreated(
  itemType: TimelineItemType.diaper,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '새로운레코드ID',
);
```

### 데이터 수정 시
```dart
// 투약 정보 수정 후
DataSyncHelper.notifyUpdated(
  itemType: TimelineItemType.medication,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '수정된레코드ID',
);
```

### 진행 중인 활동 관리
```dart
// 수면 시작
DataSyncHelper.notifyOngoingActivityStarted(
  itemType: TimelineItemType.sleep,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '수면레코드ID',
);

// 수면 종료
DataSyncHelper.notifyOngoingActivityStopped(
  itemType: TimelineItemType.sleep,
  babyId: '아기ID',
  date: DateTime.now(),
  recordId: '수면레코드ID',
);
```

### 전체 새로고침
```dart
// 모든 데이터 새로고침 필요 시
DataSyncHelper.notifyFullRefresh(
  babyId: '아기ID',
  date: DateTime.now(), // 선택사항
);
```

## 타임라인에서의 동작

### 자동 업데이트
- 이벤트 수신 시 자동으로 해당 날짜의 데이터만 업데이트
- 스마트 새로고침으로 불필요한 API 호출 최소화

### 화면 포커스 감지
- 다른 화면에서 타임라인으로 돌아올 때 자동 새로고침
- 5초 이내 중복 새로고침 방지

## 성능 최적화

### 스마트 업데이트
- 데이터 변경 감지: ID 목록 비교로 실제 변경 여부 확인
- 필요한 경우에만 UI 업데이트

### 이벤트 필터링
- 현재 아기 ID와 날짜에 해당하는 이벤트만 처리
- 불필요한 업데이트 방지

### 메모리 관리
- Provider dispose 시 이벤트 구독 자동 해제
- RouteObserver 구독 해제

## 디버깅

모든 이벤트는 콘솔에 로그가 출력됩니다:
- `🚀 [EVENT_BUS]`: 이벤트 발송
- `📨 [TIMELINE]`: 이벤트 수신
- `🔄 [TIMELINE]`: 스마트 새로고침
- `✅ [TIMELINE]`: 업데이트 완료