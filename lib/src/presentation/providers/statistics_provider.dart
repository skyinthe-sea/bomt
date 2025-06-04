import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/statistics.dart';
import '../../services/statistics/statistics_service.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService.instance;
  final AppEventBus _eventBus = AppEventBus.instance;
  
  // 현재 선택된 사용자 정보
  String? _currentUserId;
  String? _currentBabyId;
  
  // 통계 데이터
  Statistics? _statistics;
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // 날짜 범위
  StatisticsDateRange _dateRange = StatisticsDateRange.weekly();
  
  // 선택된 메트릭 타입 (차트용)
  String _selectedMetricType = 'count';
  
  // 차트 데이터
  Map<String, StatisticsChartData> _chartDataCache = {};
  
  // 에러 상태
  String? _errorMessage;
  
  // EventBus 구독
  StreamSubscription<DataSyncEvent>? _eventSubscription;
  
  // Getters
  String? get currentUserId => _currentUserId;
  String? get currentBabyId => _currentBabyId;
  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  StatisticsDateRange get dateRange => _dateRange;
  String get selectedMetricType => _selectedMetricType;
  Map<String, StatisticsChartData> get chartDataCache => _chartDataCache;
  String? get errorMessage => _errorMessage;
  bool get hasData => _statistics?.hasData ?? false;
  bool get hasError => _errorMessage != null;

  StatisticsProvider() {
    _initializeEventListener();
  }

  /// EventBus 리스너 초기화
  void _initializeEventListener() {
    _eventSubscription = _eventBus.dataSyncStream.listen((event) {
      debugPrint('📊 [STATS_PROVIDER] Received data sync event: ${event.type}');
      
      // 현재 아기와 관련된 이벤트만 처리
      if (_currentBabyId != null && event.babyId == _currentBabyId) {
        // 통계에 영향을 주는 이벤트 타입들만 처리
        if (_isStatisticsRelevantEvent(event.type)) {
          debugPrint('📊 [STATS_PROVIDER] Statistics relevant event detected, refreshing...');
          _refreshStatisticsDebounced();
        }
      }
    });
    
    debugPrint('📊 [STATS_PROVIDER] Event listener initialized');
  }

  /// 통계에 영향을 주는 이벤트인지 확인
  bool _isStatisticsRelevantEvent(DataSyncEventType eventType) {
    const relevantEvents = [
      DataSyncEventType.feedingChanged,
      DataSyncEventType.sleepChanged,
      DataSyncEventType.diaperChanged,
      DataSyncEventType.medicationChanged,
      DataSyncEventType.milkPumpingChanged,
      DataSyncEventType.solidFoodChanged,
      DataSyncEventType.allDataRefresh,
    ];
    
    return relevantEvents.contains(eventType);
  }

  /// 디바운스를 위한 타이머
  Timer? _refreshTimer;

  /// 디바운스된 통계 새로고침
  void _refreshStatisticsDebounced() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 500), () {
      refreshStatistics(showLoading: false);
    });
  }

  /// 현재 사용자 설정
  void setCurrentUser(String userId, String babyId, {bool autoRefresh = true}) {
    debugPrint('📊 [STATS_PROVIDER] setCurrentUser called with userId: $userId, babyId: $babyId, autoRefresh: $autoRefresh');
    debugPrint('📊 [STATS_PROVIDER] Current userId: $_currentUserId, Current babyId: $_currentBabyId');
    
    if (_currentUserId != userId || _currentBabyId != babyId) {
      debugPrint('📊 [STATS_PROVIDER] User changed, updating...');
      
      _currentUserId = userId;
      _currentBabyId = babyId;
      
      // 이전 데이터 클리어
      _statistics = null;
      _chartDataCache.clear();
      _errorMessage = null;
      
      if (autoRefresh) {
        debugPrint('📊 [STATS_PROVIDER] Auto-refreshing statistics...');
        refreshStatistics();
      }
      
      notifyListeners();
    } else {
      debugPrint('📊 [STATS_PROVIDER] Same user, no changes needed');
    }
  }

  /// 날짜 범위 변경
  void setDateRange(StatisticsDateRange dateRange, {bool autoRefresh = true}) {
    if (_dateRange != dateRange) {
      debugPrint('📊 [STATS_PROVIDER] Setting date range: ${dateRange.label}');
      
      _dateRange = dateRange;
      
      // 차트 데이터 캐시 클리어 (날짜 범위가 변경되었으므로)
      _chartDataCache.clear();
      
      if (autoRefresh) {
        refreshStatistics();
      }
      
      notifyListeners();
    }
  }

  /// 주간 범위로 설정
  void setWeeklyRange({DateTime? date}) {
    setDateRange(StatisticsDateRange.weekly(date: date));
  }

  /// 월간 범위로 설정
  void setMonthlyRange({DateTime? date}) {
    setDateRange(StatisticsDateRange.monthly(date: date));
  }

  /// 커스텀 범위로 설정
  void setCustomRange({required DateTime startDate, required DateTime endDate}) {
    setDateRange(StatisticsDateRange.custom(startDate: startDate, endDate: endDate));
  }

  /// 메트릭 타입 변경 (차트용)
  void setMetricType(String metricType, {bool autoRefreshCharts = true}) {
    if (_selectedMetricType != metricType) {
      debugPrint('📊 [STATS_PROVIDER] Setting metric type: $metricType');
      
      _selectedMetricType = metricType;
      
      // 차트 데이터 캐시 클리어 (메트릭이 변경되었으므로)
      if (autoRefreshCharts) {
        _chartDataCache.clear();
        _refreshChartsForVisibleCards();
      }
      
      notifyListeners();
    }
  }

  /// 통계 데이터 새로고침
  Future<void> refreshStatistics({bool showLoading = true}) async {
    if (_currentUserId == null || _currentBabyId == null) {
      debugPrint('⚠️ [STATS_PROVIDER] Cannot refresh statistics: missing user or baby ID');
      debugPrint('⚠️ [STATS_PROVIDER] Current user ID: $_currentUserId, Current baby ID: $_currentBabyId');
      return;
    }

    debugPrint('📊 [STATS_PROVIDER] Starting statistics refresh (showLoading: $showLoading)');
    debugPrint('📊 [STATS_PROVIDER] User ID: $_currentUserId, Baby ID: $_currentBabyId');
    debugPrint('📊 [STATS_PROVIDER] Date range: ${_dateRange.label} (${_dateRange.startDate} to ${_dateRange.endDate})');

    _errorMessage = null;
    
    if (showLoading) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    
    notifyListeners();

    try {
      final statistics = await _statisticsService.generateStatistics(
        userId: _currentUserId!,
        babyId: _currentBabyId!,
        dateRange: _dateRange,
      );

      _statistics = statistics;
      
      debugPrint('📊 [STATS_PROVIDER] Statistics refreshed successfully');
      debugPrint('📊 [STATS_PROVIDER] Cards with data: ${statistics.cardsWithData.length}');
      
      // 표시 가능한 카드들의 차트 데이터 새로고침 (자동으로 로드)
      await _refreshChartsForVisibleCards();
      
    } catch (e) {
      debugPrint('❌ [STATS_PROVIDER] Error refreshing statistics: $e');
      _errorMessage = '통계 데이터를 불러오는 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// 표시 가능한 카드들의 차트 데이터 새로고침
  Future<void> _refreshChartsForVisibleCards() async {
    if (_statistics == null || _currentUserId == null || _currentBabyId == null) {
      debugPrint('📈 [STATS_PROVIDER] Cannot refresh charts - missing statistics or user data');
      return;
    }

    debugPrint('📈 [STATS_PROVIDER] Refreshing charts for ${_statistics!.cardsWithData.length} visible cards');

    for (final cardStats in _statistics!.cardsWithData) {
      debugPrint('📈 [STATS_PROVIDER] Loading chart data for: ${cardStats.cardType}');
      await _loadChartDataForCard(cardStats.cardType);
    }
    
    debugPrint('📈 [STATS_PROVIDER] All chart data loading completed');
  }

  /// 특정 카드의 차트 데이터 로드
  Future<void> _loadChartDataForCard(String cardType) async {
    if (_currentUserId == null || _currentBabyId == null) return;

    try {
      final chartData = await _statisticsService.generateChartData(
        cardType: cardType,
        userId: _currentUserId!,
        babyId: _currentBabyId!,
        dateRange: _dateRange,
        metricType: _selectedMetricType,
      );

      _chartDataCache[cardType] = chartData;
      
      debugPrint('📈 [STATS_PROVIDER] Chart data loaded for $cardType (${chartData.dataPoints.length} points)');
      
      // UI 업데이트를 위해 리스너들에게 알림
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [STATS_PROVIDER] Error loading chart data for $cardType: $e');
    }
  }

  /// 특정 카드의 차트 데이터 가져오기
  StatisticsChartData? getChartData(String cardType) {
    return _chartDataCache[cardType];
  }

  /// 차트 데이터 새로고침
  Future<void> refreshChartData(String cardType) async {
    debugPrint('📈 [STATS_PROVIDER] Manually refreshing chart data for $cardType');
    await _loadChartDataForCard(cardType);
    notifyListeners();
  }

  /// 모든 차트 데이터 새로고침
  Future<void> refreshAllChartData() async {
    debugPrint('📈 [STATS_PROVIDER] Manually refreshing all chart data');
    _chartDataCache.clear();
    await _refreshChartsForVisibleCards();
    notifyListeners();
  }

  /// 특정 카드의 통계 데이터 가져오기
  CardStatistics? getCardStatistics(String cardType) {
    return _statistics?.getCardStatistics(cardType);
  }

  /// 데이터가 있는 카드들만 반환
  List<CardStatistics> get cardsWithData {
    return _statistics?.cardsWithData ?? [];
  }

  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 날짜 범위를 이전/다음으로 이동
  void moveDateRange(bool forward) {
    DateTime newDate;
    
    switch (_dateRange.type) {
      case StatisticsDateRangeType.weekly:
        newDate = forward 
            ? _dateRange.startDate.add(const Duration(days: 7))
            : _dateRange.startDate.subtract(const Duration(days: 7));
        setDateRange(StatisticsDateRange.weekly(date: newDate));
        break;
        
      case StatisticsDateRangeType.monthly:
        if (forward) {
          newDate = DateTime(_dateRange.startDate.year, _dateRange.startDate.month + 1, 1);
        } else {
          newDate = DateTime(_dateRange.startDate.year, _dateRange.startDate.month - 1, 1);
        }
        setDateRange(StatisticsDateRange.monthly(date: newDate));
        break;
        
      case StatisticsDateRangeType.custom:
        // 커스텀 범위는 직접 이동하지 않음
        break;
    }
  }

  /// 오늘 날짜로 이동
  void moveToToday() {
    switch (_dateRange.type) {
      case StatisticsDateRangeType.weekly:
        setDateRange(StatisticsDateRange.weekly());
        break;
      case StatisticsDateRangeType.monthly:
        setDateRange(StatisticsDateRange.monthly());
        break;
      case StatisticsDateRangeType.custom:
        // 커스텀 범위는 오늘로 이동하지 않음
        break;
    }
  }

  /// 통계 데이터 내보내기
  Map<String, dynamic> exportStatistics() {
    if (_statistics == null) return {};

    return {
      'dateRange': {
        'type': _dateRange.type.toString(),
        'startDate': _dateRange.startDate.toIso8601String(),
        'endDate': _dateRange.endDate.toIso8601String(),
        'label': _dateRange.label,
      },
      'totalActivities': _statistics!.totalActivities,
      'cardStatistics': _statistics!.cardStatistics.map((card) => {
        'cardType': card.cardType,
        'cardName': card.cardName,
        'totalCount': card.totalCount,
        'metrics': card.metrics.map((metric) => {
          'label': metric.label,
          'value': metric.value,
          'unit': metric.unit,
          'formattedValue': metric.formattedValue,
        }).toList(),
      }).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  void dispose() {
    debugPrint('📊 [STATS_PROVIDER] Disposing provider');
    _eventSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}