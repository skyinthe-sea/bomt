# 데이터베이스 마이그레이션 후 정리 가이드

## 1. Supabase에서 실행할 스크립트
1. Supabase Dashboard → SQL Editor 접속
2. `add_new_categories.sql` 파일 내용 복사하여 실행
3. 새로운 카테고리 5개가 정상적으로 추가되었는지 확인

## 2. 앱 코드에서 제거해야 할 임시 매핑 로직

### A. community_service.dart - getPosts 메서드
```dart
// 제거할 부분:
final newSystemCategoryMappings = {
  'sleep_issues': 'daily',
  'baby_food': 'daily',
  'development': 'daily',
  'vaccination': 'daily',
  'postpartum': 'daily',
};
```

### B. community_provider.dart - createPost 메서드
```dart
// 제거할 부분:
final newSystemCategoryMappings = {
  'sleep_issues': 'daily',
  'baby_food': 'daily',
  'development': 'daily',
  'vaccination': 'daily',
  'postpartum': 'daily',
};
```

### C. community_provider.dart - loadCategories 메서드  
```dart
// 제거할 부분:
systemCategories.addAll([
  CommunityCategory(
    id: 'sleep_issues',
    name: '수면문제',
    // ... 나머지 5개 카테고리
  ),
]);
```

## 3. 정리 후 기대 효과
- ✅ 실제 데이터베이스 카테고리 사용
- ✅ 일관성 있는 카테고리 필터링
- ✅ 임시 매핑 로직 제거로 코드 간소화
- ✅ 향후 카테고리 관리 용이성