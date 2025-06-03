import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../domain/models/timeline_item.dart';
import '../../services/timeline/timeline_service.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

class TimelineProvider extends ChangeNotifier {
  final TimelineService _timelineService = TimelineService.instance;
  final AppEventBus _eventBus = AppEventBus.instance;
  
  List<TimelineItem> _allItems = [];
  List<TimelineItem> _filteredItems = [];
  DateTime _selectedDate = DateTime.now();
  TimelineFilterType _currentFilter = TimelineFilterType.all;
  bool _isLoading = false;
  String? _currentBabyId;
  String? _error;
  
  // 이벤트 구독
  StreamSubscription<DataSyncEvent>? _eventSubscription;

  // Getters
  List<TimelineItem> get filteredItems => _filteredItems;
  List<TimelineItem> get allItems => _allItems;
  DateTime get selectedDate => _selectedDate;
  TimelineFilterType get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get currentBabyId => _currentBabyId;
  String? get error => _error;
  bool get hasItems => _filteredItems.isNotEmpty;

  // 현재 아기 설정
  void setCurrentBaby(String babyId) {
    if (_currentBabyId != babyId) {
      _currentBabyId = babyId;
      _clearData();
      _setupEventListener();
      refreshData();
    }
  }

  // 이벤트 리스너 설정
  void _setupEventListener() {
    if (_currentBabyId == null) return;
    
    // 기존 구독 해제
    _eventSubscription?.cancel();
    
    // 새 구독 설정
    _eventSubscription = _eventBus.getTimelineEventsStream(
      babyId: _currentBabyId!,
      date: _selectedDate,
    ).listen(_handleDataSyncEvent);
    
    debugPrint('📡 [TIMELINE] Event listener setup for baby: $_currentBabyId');
  }

  // 데이터 동기화 이벤트 처리
  void _handleDataSyncEvent(DataSyncEvent event) {
    debugPrint('📨 [TIMELINE] Received event: $event');
    
    // 현재 선택된 날짜와 이벤트 날짜가 같은지 확인
    final eventDate = event.affectedDate;
    if (eventDate.year == _selectedDate.year &&
        eventDate.month == _selectedDate.month &&
        eventDate.day == _selectedDate.day) {
      
      switch (event.action) {
        case DataSyncAction.created:
        case DataSyncAction.updated:
        case DataSyncAction.deleted:
          // 스마트 업데이트: 전체 새로고침 대신 필요한 부분만 업데이트
          _smartRefresh(event);
          break;
        case DataSyncAction.refreshed:
          // 전체 새로고침
          refreshData();
          break;
      }
    }
  }

  // 스마트 새로고침 - 성능 최적화
  Future<void> _smartRefresh(DataSyncEvent event) async {
    if (_currentBabyId == null || _isLoading) return;
    
    debugPrint('🔄 [TIMELINE] Smart refresh for event: ${event.type}');
    
    try {
      // 특정 타입의 데이터만 새로고침
      final newItems = await _timelineService.getTimelineItemsForDate(
        _currentBabyId!,
        _selectedDate,
      );
      
      // 기존 데이터와 새 데이터를 비교하여 변경된 부분만 업데이트
      final hasChanges = _hasDataChanges(newItems);
      
      if (hasChanges) {
        _allItems = newItems;
        _applyFilter();
        notifyListeners();
        debugPrint('✅ [TIMELINE] Smart refresh completed - ${_allItems.length} items');
      } else {
        debugPrint('📋 [TIMELINE] No changes detected, skipping update');
      }
    } catch (e) {
      debugPrint('❌ [TIMELINE] Smart refresh error: $e');
      // 에러 발생 시 풀 리프레시 시도
      refreshData();
    }
  }

  // 데이터 변경 감지
  bool _hasDataChanges(List<TimelineItem> newItems) {
    // 아이템 개수가 다르면 변경됨
    if (_allItems.length != newItems.length) return true;
    
    // ID 목록 비교
    final oldIds = _allItems.map((item) => item.id).toSet();
    final newIds = newItems.map((item) => item.id).toSet();
    
    return !oldIds.containsAll(newIds) || !newIds.containsAll(oldIds);
  }

  // 날짜 변경
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      _setupEventListener(); // 새 날짜에 대한 이벤트 리스너 재설정
      refreshData();
    }
  }

  // 필터 변경
  void setFilter(TimelineFilterType filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilter();
      notifyListeners();
    }
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    if (_currentBabyId == null) return;
    
    debugPrint('🔄 [TIMELINE] Refreshing data for date: ${_selectedDate.toIso8601String()}');
    
    _setLoading(true);
    _error = null;
    
    try {
      final items = await _timelineService.getTimelineItemsForDate(
        _currentBabyId!,
        _selectedDate,
      );
      
      _allItems = items;
      _applyFilter();
      
      debugPrint('✅ [TIMELINE] Data refresh completed. ${_allItems.length} items loaded');
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error refreshing data: $e');
      _error = e.toString();
      _allItems = [];
      _filteredItems = [];
    } finally {
      _setLoading(false);
    }
  }

  // 진행 중인 아이템들 가져오기
  Future<List<TimelineItem>> getOngoingItems() async {
    if (_currentBabyId == null) return [];
    
    try {
      return await _timelineService.getOngoingItems(_currentBabyId!);
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting ongoing items: $e');
      return [];
    }
  }

  // 이전 날짜로 이동
  void goToPreviousDay() {
    final newDate = _selectedDate.subtract(const Duration(days: 1));
    debugPrint('🔥 [PROVIDER] goToPreviousDay: ${_selectedDate.toIso8601String()} -> ${newDate.toIso8601String()}');
    setSelectedDate(newDate);
  }

  // 다음 날짜로 이동
  void goToNextDay() {
    final newDate = _selectedDate.add(const Duration(days: 1));
    debugPrint('🔥 [PROVIDER] goToNextDay: ${_selectedDate.toIso8601String()} -> ${newDate.toIso8601String()}');
    setSelectedDate(newDate);
  }

  // 오늘로 이동
  void goToToday() {
    setSelectedDate(DateTime.now());
  }

  // 날짜가 오늘인지 확인
  bool get isToday {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
           _selectedDate.month == today.month &&
           _selectedDate.day == today.day;
  }

  // 날짜가 미래인지 확인
  bool get isFuture {
    final today = DateTime.now();
    return _selectedDate.isAfter(DateTime(today.year, today.month, today.day));
  }

  // 특정 타입의 아이템 개수 가져오기
  int getItemCountByType(TimelineItemType type) {
    return _allItems.where((item) => item.type == type).length;
  }

  // 필터 적용
  void _applyFilter() {
    _filteredItems = _timelineService.filterItems(_allItems, _currentFilter);
    debugPrint('🔍 [TIMELINE] Applied filter: ${_currentFilter.displayName}. ${_filteredItems.length} items');
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // 데이터 초기화
  void _clearData() {
    _allItems = [];
    _filteredItems = [];
    _error = null;
    _currentFilter = TimelineFilterType.all;
    notifyListeners();
  }

  // 날짜 포맷팅
  String get formattedDate {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[_selectedDate.weekday % 7];
    
    return '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 ($weekday)';
  }

  // 간단한 날짜 포맷팅
  String get shortFormattedDate {
    return '${_selectedDate.month}/${_selectedDate.day}';
  }

  // 리소스 해제
  @override
  void dispose() {
    debugPrint('🗑️ [TIMELINE] TimelineProvider disposed');
    _eventSubscription?.cancel();
    super.dispose();
  }
}