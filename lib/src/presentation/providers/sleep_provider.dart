import 'package:flutter/material.dart';
import '../../domain/models/sleep.dart';
import '../../services/sleep/sleep_service.dart';

class SleepProvider extends ChangeNotifier {
  final SleepService _sleepService = SleepService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 수면 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 수면 기록 목록
  List<Sleep> _todaySleeps = [];
  
  // 기본 수면 설정
  Map<String, dynamic> _sleepDefaults = {};
  
  // 현재 진행 중인 수면
  Sleep? _currentActiveSleep;
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  Sleep? _lastDeletedSleep;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<Sleep> get todaySleeps => _todaySleeps;
  Map<String, dynamic> get sleepDefaults => _sleepDefaults;
  Sleep? get currentActiveSleep => _currentActiveSleep;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasActiveSleep => _currentActiveSleep != null;
  bool get canUndo => _lastDeletedSleep != null;
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
        _loadTodaySleeps(),
        _loadSleepDefaults(),
        _loadCurrentActiveSleep(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing sleep data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _sleepService.getTodaySleepSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 수면 기록 로드
  Future<void> _loadTodaySleeps() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySleeps = await _sleepService.getTodaySleeps(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today sleeps: $e');
    }
  }
  
  /// 기본 수면 설정 로드
  Future<void> _loadSleepDefaults() async {
    try {
      _sleepDefaults = await _sleepService.getSleepDefaults();
    } catch (e) {
      debugPrint('Error loading sleep defaults: $e');
    }
  }
  
  /// 현재 진행 중인 수면 로드
  Future<void> _loadCurrentActiveSleep() async {
    if (_currentBabyId == null) return;
    
    try {
      _currentActiveSleep = await _sleepService.getCurrentActiveSleep(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading current active sleep: $e');
    }
  }
  
  /// 기본 수면 설정 저장
  Future<void> saveSleepDefaults({
    int? durationMinutes,
    String? quality,
    String? location,
  }) async {
    try {
      await _sleepService.saveSleepDefaults(
        durationMinutes: durationMinutes,
        quality: quality,
        location: location,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadSleepDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving sleep defaults: $e');
    }
  }
  
  /// 퀵 수면 기록 추가 또는 진행 중인 수면 시작/종료
  Future<bool> toggleSleep() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      if (_currentActiveSleep != null) {
        // 진행 중인 수면이 있으면 종료
        final endedSleep = await _sleepService.endCurrentSleep(
          _currentActiveSleep!.id,
          DateTime.now(),
        );
        
        if (endedSleep != null) {
          _currentActiveSleep = null;
          
          // 목록 업데이트 (종료된 수면을 목록에 추가)
          await _loadTodaySleeps();
          await _loadTodaySummary();
          
          return true;
        }
      } else {
        // 진행 중인 수면이 없으면 새로 시작
        final sleep = await _sleepService.addSleep(
          babyId: _currentBabyId!,
          userId: _currentUserId!,
          startedAt: DateTime.now(),
          endedAt: null, // 진행 중이므로 종료 시간은 null
        );
        
        if (sleep != null) {
          _currentActiveSleep = sleep;
          
          // 요약 데이터 업데이트 (아직 진행 중이므로 목록에는 추가하지 않음)
          await _loadTodaySummary();
          
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error toggling sleep: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 완료된 수면 기록 추가 (기본 설정 사용)
  Future<bool> addQuickSleep() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final sleep = await _sleepService.addSleep(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (sleep != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todaySleeps.insert(0, sleep);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick sleep: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 수면 기록 추가
  Future<bool> addCustomSleep({
    int? durationMinutes,
    String? quality,
    String? location,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final sleep = await _sleepService.addSleep(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        durationMinutes: durationMinutes,
        quality: quality,
        location: location,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (sleep != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todaySleeps.insert(0, sleep);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom sleep: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 수면 기록 삭제
  Future<bool> deleteSleep(String sleepId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _sleepService.deleteSleep(sleepId);
      
      if (success) {
        // 목록에서 제거
        _todaySleeps.removeWhere((sleep) => sleep.id == sleepId);
        
        // 진행 중인 수면이었다면 제거
        if (_currentActiveSleep?.id == sleepId) {
          _currentActiveSleep = null;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting sleep: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 수면 기록 삭제 (언두 지원)
  Future<bool> deleteLatestSleep() async {
    if (_todaySleeps.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestSleep = _todaySleeps.first;
      
      // 진행 중인 수면이라면 특별 처리
      if (_currentActiveSleep?.id == latestSleep.id) {
        // 진행 중인 수면 삭제는 확인 후 처리
        final confirmMessage = '진행 중인 수면을 삭제하시겠습니까?\n수면이 자동으로 종료됩니다.';
        // SwipeableCard에서 confirmMessage를 전달받아 처리
      }
      
      // 언두를 위해 임시 저장
      _lastDeletedSleep = latestSleep;
      _lastDeletedIndex = 0;
      
      final success = await _sleepService.deleteSleep(latestSleep.id);
      
      if (success) {
        // 목록에서 제거
        _todaySleeps.removeAt(0);
        
        // 진행 중인 수면이었다면 제거
        if (_currentActiveSleep?.id == latestSleep.id) {
          _currentActiveSleep = null;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest sleep: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedSleep == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredSleep = await _sleepService.addSleep(
        babyId: _lastDeletedSleep!.babyId,
        userId: _lastDeletedSleep!.userId,
        durationMinutes: _lastDeletedSleep!.durationMinutes,
        quality: _lastDeletedSleep!.quality,
        location: _lastDeletedSleep!.location,
        notes: _lastDeletedSleep!.notes,
        startedAt: _lastDeletedSleep!.startedAt,
        endedAt: _lastDeletedSleep!.endedAt,
      );
      
      if (restoredSleep != null) {
        // 원래 위치에 삽입
        _todaySleeps.insert(_lastDeletedIndex!, restoredSleep);
        
        // 진행 중인 수면이었다면 복원
        if (_lastDeletedSleep!.endedAt == null) {
          _currentActiveSleep = restoredSleep;
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
    _lastDeletedSleep = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }

  /// 진행 중인 수면 삭제 시 확인 메시지
  String getDeleteConfirmMessage() {
    if (_todaySleeps.isEmpty) return '삭제할 수면 기록이 없습니다.';
    
    final latestSleep = _todaySleeps.first;
    if (_currentActiveSleep?.id == latestSleep.id) {
      return '진행 중인 수면을 삭제하시겠습니까?\n수면이 자동으로 종료됩니다.';
    }
    
    return '최근 수면 기록을 삭제하시겠습니까?';
  }
  
  /// 수면 기록 수정
  Future<bool> updateSleep({
    required String sleepId,
    int? durationMinutes,
    String? quality,
    String? location,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedSleep = await _sleepService.updateSleep(
        sleepId: sleepId,
        durationMinutes: durationMinutes,
        quality: quality,
        location: location,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (updatedSleep != null) {
        // 목록에서 업데이트
        final index = _todaySleeps.indexWhere((sleep) => sleep.id == sleepId);
        if (index != -1) {
          _todaySleeps[index] = updatedSleep;
        }
        
        // 진행 중인 수면이었다면 업데이트
        if (_currentActiveSleep?.id == sleepId) {
          _currentActiveSleep = updatedSleep;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating sleep: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 수면 품질에 따른 이름 반환
  String getSleepQualityName(String quality) {
    switch (quality) {
      case 'good':
        return '좋음';
      case 'fair':
        return '보통';
      case 'poor':
        return '나쁨';
      default:
        return '보통';
    }
  }
  
  /// 수면 품질에 따른 색상 반환
  Color getSleepQualityColor(String quality) {
    switch (quality) {
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
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
  
  /// 수면 시간을 사용자 친화적 문자열로 반환
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
  
  /// 현재 진행 중인 수면의 경과 시간 반환
  String getActiveSleepDuration() {
    if (_currentActiveSleep == null) return '';
    
    final now = DateTime.now();
    final elapsed = now.difference(_currentActiveSleep!.startedAt);
    return getDurationString(elapsed.inMinutes);
  }
}