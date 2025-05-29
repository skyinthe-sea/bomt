import 'package:flutter/material.dart';
import '../../domain/models/feeding.dart';
import '../../services/feeding/feeding_service.dart';

class FeedingProvider extends ChangeNotifier {
  final FeedingService _feedingService = FeedingService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 수유 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 수유 기록 목록
  List<Feeding> _todayFeedings = [];
  
  // 기본 수유 설정
  Map<String, dynamic> _feedingDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  Feeding? _lastDeletedFeeding;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<Feeding> get todayFeedings => _todayFeedings;
  Map<String, dynamic> get feedingDefaults => _feedingDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedFeeding != null;
  bool get hasRecentRecord => (_todaySummary['count'] ?? 0) > 0;
  
  /// 현재 아기 설정
  void setCurrentBaby(String babyId, String userId) {
    if (_currentBabyId != babyId || _currentUserId != userId) {
      _currentBabyId = babyId;
      _currentUserId = userId;
      // 아기가 변경되면 데이터 새로고침
      refreshData();
    }
  }
  
  /// 모든 데이터 새로고침
  Future<void> refreshData() async {
    if (_currentBabyId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        _loadTodaySummary(),
        _loadTodayFeedings(),
        _loadFeedingDefaults(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing feeding data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _feedingService.getTodayFeedingSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 수유 기록 로드
  Future<void> _loadTodayFeedings() async {
    if (_currentBabyId == null) return;
    
    try {
      _todayFeedings = await _feedingService.getTodayFeedings(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today feedings: $e');
    }
  }
  
  /// 기본 수유 설정 로드
  Future<void> _loadFeedingDefaults() async {
    try {
      _feedingDefaults = await _feedingService.getFeedingDefaults();
    } catch (e) {
      debugPrint('Error loading feeding defaults: $e');
    }
  }
  
  /// 기본 수유 설정 저장
  Future<void> saveFeedingDefaults({
    required String type,
    int? amountMl,
    int? durationMinutes,
    String? side,
  }) async {
    try {
      await _feedingService.saveFeedingDefaults(
        type: type,
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadFeedingDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving feeding defaults: $e');
    }
  }
  
  /// 퀵 수유 기록 추가 (기본 설정 사용)
  Future<bool> addQuickFeeding() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final feeding = await _feedingService.addFeeding(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (feeding != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayFeedings.insert(0, feeding);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick feeding: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 수유 기록 추가
  Future<bool> addCustomFeeding({
    required String type,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final feeding = await _feedingService.addFeeding(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        type: type,
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (feeding != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayFeedings.insert(0, feeding);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom feeding: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 수유 기록 삭제
  Future<bool> deleteFeeding(String feedingId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _feedingService.deleteFeeding(feedingId);
      
      if (success) {
        // 목록에서 제거
        _todayFeedings.removeWhere((feeding) => feeding.id == feedingId);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting feeding: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 수유 기록 삭제 (언두 지원)
  Future<bool> deleteLatestFeeding() async {
    if (_todayFeedings.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestFeeding = _todayFeedings.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedFeeding = latestFeeding;
      _lastDeletedIndex = 0;
      
      final success = await _feedingService.deleteFeeding(latestFeeding.id);
      
      if (success) {
        // 목록에서 제거
        _todayFeedings.removeAt(0);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest feeding: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedFeeding == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredFeeding = await _feedingService.addFeeding(
        babyId: _lastDeletedFeeding!.babyId,
        userId: _lastDeletedFeeding!.userId,
        type: _lastDeletedFeeding!.type,
        amountMl: _lastDeletedFeeding!.amountMl,
        durationMinutes: _lastDeletedFeeding!.durationMinutes,
        side: _lastDeletedFeeding!.side,
        notes: _lastDeletedFeeding!.notes,
        startedAt: _lastDeletedFeeding!.startedAt,
        endedAt: _lastDeletedFeeding!.endedAt,
      );
      
      if (restoredFeeding != null) {
        // 원래 위치에 삽입
        _todayFeedings.insert(_lastDeletedIndex!, restoredFeeding);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        // 언두 데이터 클리어
        _clearUndoData();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error undoing delete: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 언두 데이터 클리어
  void _clearUndoData() {
    _lastDeletedFeeding = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 수유 기록 수정
  Future<bool> updateFeeding({
    required String feedingId,
    String? type,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedFeeding = await _feedingService.updateFeeding(
        feedingId: feedingId,
        type: type,
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (updatedFeeding != null) {
        // 목록에서 업데이트
        final index = _todayFeedings.indexWhere((feeding) => feeding.id == feedingId);
        if (index != -1) {
          _todayFeedings[index] = updatedFeeding;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating feeding: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 수유 타입에 따른 아이콘 반환
  IconData getFeedingIcon(String type) {
    switch (type) {
      case 'breast':
        return Icons.child_care;
      case 'bottle':
        return Icons.local_drink;
      case 'formula':
        return Icons.science;
      case 'solid':
        return Icons.restaurant;
      default:
        return Icons.local_drink;
    }
  }
  
  /// 수유 타입에 따른 이름 반환
  String getFeedingTypeName(String type) {
    switch (type) {
      case 'breast':
        return '모유';
      case 'bottle':
        return '젖병';
      case 'formula':
        return '분유';
      case 'solid':
        return '이유식';
      default:
        return '수유';
    }
  }
  
  /// 수유 사이드에 따른 이름 반환
  String getFeedingSideName(String? side) {
    switch (side) {
      case 'left':
        return '왼쪽';
      case 'right':
        return '오른쪽';
      case 'both':
        return '양쪽';
      default:
        return '양쪽';
    }
  }
  
  /// 시간 차이를 사용자 친화적 문자열로 반환
  String getTimeAgoString(int? minutesAgo) {
    if (minutesAgo == null) return '';
    
    if (minutesAgo < 1) {
      return '방금 전';
    } else if (minutesAgo < 60) {
      return '${minutesAgo}분 전';
    } else {
      final hours = minutesAgo ~/ 60;
      final remainingMinutes = minutesAgo % 60;
      if (remainingMinutes == 0) {
        return '${hours}시간 전';
      } else {
        return '${hours}시간 ${remainingMinutes}분 전';
      }
    }
  }
}