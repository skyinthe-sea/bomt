import 'package:flutter/material.dart';
import '../../domain/models/milk_pumping.dart';
import '../../services/milk_pumping/milk_pumping_service.dart';

class MilkPumpingProvider extends ChangeNotifier {
  final MilkPumpingService _milkPumpingService = MilkPumpingService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 유축 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 유축 기록 목록
  List<MilkPumping> _todayMilkPumpings = [];
  
  // 기본 유축 설정
  Map<String, dynamic> _milkPumpingDefaults = {};
  
  // 현재 진행 중인 유축
  MilkPumping? _currentActivePumping;
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  MilkPumping? _lastDeletedMilkPumping;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<MilkPumping> get todayMilkPumpings => _todayMilkPumpings;
  Map<String, dynamic> get milkPumpingDefaults => _milkPumpingDefaults;
  MilkPumping? get currentActivePumping => _currentActivePumping;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasActivePumping => _currentActivePumping != null;
  bool get canUndo => _lastDeletedMilkPumping != null;
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
        _loadTodayMilkPumpings(),
        _loadMilkPumpingDefaults(),
        _loadCurrentActivePumping(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing milk pumping data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _milkPumpingService.getTodayMilkPumpingSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 유축 기록 로드
  Future<void> _loadTodayMilkPumpings() async {
    if (_currentBabyId == null) return;
    
    try {
      _todayMilkPumpings = await _milkPumpingService.getTodayMilkPumpings(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today milk pumpings: $e');
    }
  }
  
  /// 기본 유축 설정 로드
  Future<void> _loadMilkPumpingDefaults() async {
    try {
      _milkPumpingDefaults = await _milkPumpingService.getMilkPumpingDefaults();
    } catch (e) {
      debugPrint('Error loading milk pumping defaults: $e');
    }
  }
  
  /// 현재 진행 중인 유축 로드
  Future<void> _loadCurrentActivePumping() async {
    if (_currentBabyId == null) return;
    
    try {
      _currentActivePumping = await _milkPumpingService.getCurrentActivePumping(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading current active pumping: $e');
    }
  }
  
  /// 기본 유축 설정 저장
  Future<void> saveMilkPumpingDefaults({
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
  }) async {
    try {
      await _milkPumpingService.saveMilkPumpingDefaults(
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
        storageLocation: storageLocation,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadMilkPumpingDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving milk pumping defaults: $e');
    }
  }
  
  /// 퀵 유축 기록 추가 또는 진행 중인 유축 시작/종료
  Future<bool> togglePumping() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      if (_currentActivePumping != null) {
        // 진행 중인 유축이 있으면 종료
        final endedPumping = await _milkPumpingService.endCurrentPumping(
          _currentActivePumping!.id,
          endTime: DateTime.now(),
        );
        
        if (endedPumping != null) {
          _currentActivePumping = null;
          
          // 목록 업데이트 (종료된 유축을 목록에 추가)
          await _loadTodayMilkPumpings();
          await _loadTodaySummary();
          
          return true;
        }
      } else {
        // 진행 중인 유축이 없으면 새로 시작
        final pumping = await _milkPumpingService.addMilkPumping(
          babyId: _currentBabyId!,
          userId: _currentUserId!,
          startedAt: DateTime.now(),
          endedAt: null, // 진행 중이므로 종료 시간은 null
        );
        
        if (pumping != null) {
          _currentActivePumping = pumping;
          
          // 요약 데이터 업데이트 (아직 진행 중이므로 목록에는 추가하지 않음)
          await _loadTodaySummary();
          
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error toggling pumping: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 완료된 유축 기록 추가 (기본 설정 사용)
  Future<bool> addQuickMilkPumping() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final milkPumping = await _milkPumpingService.addMilkPumping(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (milkPumping != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayMilkPumpings.insert(0, milkPumping);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick milk pumping: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 유축 기록 추가
  Future<bool> addCustomMilkPumping({
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final milkPumping = await _milkPumpingService.addMilkPumping(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
        storageLocation: storageLocation,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (milkPumping != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayMilkPumpings.insert(0, milkPumping);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom milk pumping: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 유축 기록 삭제
  Future<bool> deleteMilkPumping(String milkPumpingId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _milkPumpingService.deleteMilkPumping(milkPumpingId);
      
      if (success) {
        // 목록에서 제거
        _todayMilkPumpings.removeWhere((pumping) => pumping.id == milkPumpingId);
        
        // 진행 중인 유축이었다면 제거
        if (_currentActivePumping?.id == milkPumpingId) {
          _currentActivePumping = null;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting milk pumping: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 유축 기록 삭제 (언두 지원)
  Future<bool> deleteLatestMilkPumping() async {
    if (_todayMilkPumpings.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestPumping = _todayMilkPumpings.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedMilkPumping = latestPumping;
      _lastDeletedIndex = 0;
      
      final success = await _milkPumpingService.deleteMilkPumping(latestPumping.id);
      
      if (success) {
        // 목록에서 제거
        _todayMilkPumpings.removeAt(0);
        
        // 진행 중인 유축이었다면 제거
        if (_currentActivePumping?.id == latestPumping.id) {
          _currentActivePumping = null;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest milk pumping: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedMilkPumping == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredPumping = await _milkPumpingService.addMilkPumping(
        babyId: _lastDeletedMilkPumping!.babyId,
        userId: _lastDeletedMilkPumping!.userId,
        amountMl: _lastDeletedMilkPumping!.amountMl,
        durationMinutes: _lastDeletedMilkPumping!.durationMinutes,
        side: _lastDeletedMilkPumping!.side,
        storageLocation: _lastDeletedMilkPumping!.storageLocation,
        notes: _lastDeletedMilkPumping!.notes,
        startedAt: _lastDeletedMilkPumping!.startedAt,
        endedAt: _lastDeletedMilkPumping!.endedAt,
      );
      
      if (restoredPumping != null) {
        // 원래 위치에 삽입
        _todayMilkPumpings.insert(_lastDeletedIndex!, restoredPumping);
        
        // 진행 중인 유축이었다면 복원
        if (_lastDeletedMilkPumping!.endedAt == null) {
          _currentActivePumping = restoredPumping;
        }
        
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
    _lastDeletedMilkPumping = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 유축 기록 수정
  Future<bool> updateMilkPumping({
    required String milkPumpingId,
    int? amountMl,
    int? durationMinutes,
    String? side,
    String? storageLocation,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedPumping = await _milkPumpingService.updateMilkPumping(
        milkPumpingId: milkPumpingId,
        amountMl: amountMl,
        durationMinutes: durationMinutes,
        side: side,
        storageLocation: storageLocation,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (updatedPumping != null) {
        // 목록에서 업데이트
        final index = _todayMilkPumpings.indexWhere((pumping) => pumping.id == milkPumpingId);
        if (index != -1) {
          _todayMilkPumpings[index] = updatedPumping;
        }
        
        // 진행 중인 유축이었다면 업데이트
        if (_currentActivePumping?.id == milkPumpingId) {
          _currentActivePumping = updatedPumping;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating milk pumping: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 유축 사이드에 따른 아이콘 반환
  IconData getSideIcon(String? side) {
    switch (side) {
      case 'left':
        return Icons.navigate_before;
      case 'right':
        return Icons.navigate_next;
      case 'both':
        return Icons.unfold_more;
      default:
        return Icons.unfold_more;
    }
  }
  
  /// 유축 사이드에 따른 이름 반환
  String getSideName(String? side) {
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
  
  /// 저장 위치에 따른 아이콘 반환
  IconData getStorageLocationIcon(String? location) {
    switch (location) {
      case 'fridge':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'immediate_use':
        return Icons.local_drink;
      default:
        return Icons.storage;
    }
  }
  
  /// 저장 위치에 따른 이름 반환
  String getStorageLocationName(String? location) {
    switch (location) {
      case 'fridge':
        return '냉장고';
      case 'freezer':
        return '냉동실';
      case 'immediate_use':
        return '즉시 사용';
      default:
        return '기타';
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
  
  /// 유축 시간을 사용자 친화적 문자열로 반환
  String getDurationString(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}분';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${minutes}분';
      }
    }
  }
  
  /// 현재 진행 중인 유축의 경과 시간 반환
  String getActivePumpingDuration() {
    if (_currentActivePumping == null) return '';
    
    final now = DateTime.now();
    final elapsed = now.difference(_currentActivePumping!.startedAt);
    return getDurationString(elapsed.inMinutes);
  }
  
  /// 유축량을 사용자 친화적 문자열로 반환
  String getAmountString(int? amountMl) {
    if (amountMl == null) return '';
    return '${amountMl}ml';
  }
  
  /// 다음 유축 권장 시간 계산
  String getNextPumpingRecommendation() {
    final summary = _todaySummary;
    final averageInterval = summary['averageInterval'] ?? 180; // 기본 3시간
    final lastPumpingMinutesAgo = summary['lastPumpingMinutesAgo'];
    
    if (lastPumpingMinutesAgo == null) {
      return '권장: 2-4시간마다 유축';
    }
    
    final recommendedMinutes = averageInterval - lastPumpingMinutesAgo;
    
    if (recommendedMinutes <= 0) {
      return '유축 시간이 되었습니다';
    } else if (recommendedMinutes < 60) {
      return '${recommendedMinutes}분 후 유축 권장';
    } else {
      final hours = recommendedMinutes ~/ 60;
      final minutes = recommendedMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간 후 유축 권장';
      } else {
        return '${hours}시간 ${minutes}분 후 유축 권장';
      }
    }
  }
  
  /// 오늘 총 유축량 반환
  int getTotalAmountToday() {
    return _todayMilkPumpings
        .where((pumping) => pumping.amountMl != null)
        .map((pumping) => pumping.amountMl!)
        .fold(0, (sum, amount) => sum + amount);
  }
  
  /// 오늘 총 유축 시간 반환
  int getTotalDurationToday() {
    return _todayMilkPumpings
        .where((pumping) => pumping.durationMinutes != null)
        .map((pumping) => pumping.durationMinutes!)
        .fold(0, (sum, duration) => sum + duration);
  }
}