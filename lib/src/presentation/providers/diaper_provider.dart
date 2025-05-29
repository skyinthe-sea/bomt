import 'package:flutter/material.dart';
import '../../domain/models/diaper.dart';
import '../../services/diaper/diaper_service.dart';

class DiaperProvider extends ChangeNotifier {
  final DiaperService _diaperService = DiaperService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 기저귀 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 기저귀 교체 기록 목록
  List<Diaper> _todayDiapers = [];
  
  // 기본 기저귀 설정
  Map<String, dynamic> _diaperDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  Diaper? _lastDeletedDiaper;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<Diaper> get todayDiapers => _todayDiapers;
  Map<String, dynamic> get diaperDefaults => _diaperDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedDiaper != null;
  bool get hasRecentRecord => (_todaySummary['totalCount'] ?? 0) > 0;
  
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
        _loadTodayDiapers(),
        _loadDiaperDefaults(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing diaper data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _diaperService.getTodayDiaperSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 기저귀 교체 기록 로드
  Future<void> _loadTodayDiapers() async {
    if (_currentBabyId == null) return;
    
    try {
      _todayDiapers = await _diaperService.getTodayDiapers(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today diapers: $e');
    }
  }
  
  /// 기본 기저귀 설정 로드
  Future<void> _loadDiaperDefaults() async {
    try {
      _diaperDefaults = await _diaperService.getDiaperDefaults();
    } catch (e) {
      debugPrint('Error loading diaper defaults: $e');
    }
  }
  
  /// 기본 기저귀 설정 저장
  Future<void> saveDiaperDefaults({
    String? type,
    String? color,
    String? consistency,
  }) async {
    try {
      await _diaperService.saveDiaperDefaults(
        type: type,
        color: color,
        consistency: consistency,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadDiaperDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving diaper defaults: $e');
    }
  }
  
  /// 퀵 기저귀 교체 기록 추가 (기본 설정 사용)
  Future<bool> addQuickDiaper() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final diaper = await _diaperService.addDiaper(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (diaper != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayDiapers.insert(0, diaper);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick diaper: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 기저귀 교체 기록 추가
  Future<bool> addCustomDiaper({
    String? type,
    String? color,
    String? consistency,
    String? notes,
    DateTime? changedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final diaper = await _diaperService.addDiaper(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        type: type,
        color: color,
        consistency: consistency,
        notes: notes,
        changedAt: changedAt,
      );
      
      if (diaper != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayDiapers.insert(0, diaper);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom diaper: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 기저귀 기록 삭제
  Future<bool> deleteDiaper(String diaperId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _diaperService.deleteDiaper(diaperId);
      
      if (success) {
        // 목록에서 제거
        _todayDiapers.removeWhere((diaper) => diaper.id == diaperId);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting diaper: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 기저귀 기록 삭제 (언두 지원)
  Future<bool> deleteLatestDiaper() async {
    if (_todayDiapers.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestDiaper = _todayDiapers.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedDiaper = latestDiaper;
      _lastDeletedIndex = 0;
      
      final success = await _diaperService.deleteDiaper(latestDiaper.id);
      
      if (success) {
        // 목록에서 제거
        _todayDiapers.removeAt(0);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest diaper: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedDiaper == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredDiaper = await _diaperService.addDiaper(
        babyId: _lastDeletedDiaper!.babyId,
        userId: _lastDeletedDiaper!.userId,
        type: _lastDeletedDiaper!.type,
        color: _lastDeletedDiaper!.color,
        consistency: _lastDeletedDiaper!.consistency,
        notes: _lastDeletedDiaper!.notes,
        changedAt: _lastDeletedDiaper!.changedAt,
      );
      
      if (restoredDiaper != null) {
        // 원래 위치에 삽입
        _todayDiapers.insert(_lastDeletedIndex!, restoredDiaper);
        
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
    _lastDeletedDiaper = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 기저귀 기록 수정
  Future<bool> updateDiaper({
    required String diaperId,
    String? type,
    String? color,
    String? consistency,
    String? notes,
    DateTime? changedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedDiaper = await _diaperService.updateDiaper(
        diaperId: diaperId,
        type: type,
        color: color,
        consistency: consistency,
        notes: notes,
        changedAt: changedAt,
      );
      
      if (updatedDiaper != null) {
        // 목록에서 업데이트
        final index = _todayDiapers.indexWhere((diaper) => diaper.id == diaperId);
        if (index != -1) {
          _todayDiapers[index] = updatedDiaper;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating diaper: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 기저귀 타입에 따른 아이콘 반환
  IconData getDiaperIcon(String type) {
    switch (type) {
      case 'wet':
        return Icons.opacity;
      case 'dirty':
        return Icons.eco;
      case 'both':
        return Icons.child_care;
      default:
        return Icons.child_care;
    }
  }
  
  /// 기저귀 타입에 따른 이름 반환
  String getDiaperTypeName(String type) {
    switch (type) {
      case 'wet':
        return '소변';
      case 'dirty':
        return '대변';
      case 'both':
        return '소변+대변';
      default:
        return '기저귀';
    }
  }
  
  /// 기저귀 타입에 따른 색상 반환
  Color getDiaperTypeColor(String type) {
    switch (type) {
      case 'wet':
        return Colors.blue;
      case 'dirty':
        return Colors.brown;
      case 'both':
        return Colors.purple;
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
  
  /// 색상 이름에 따른 Color 반환
  Color getColorFromName(String colorName) {
    switch (colorName) {
      case '노란색':
        return Colors.yellow[700]!;
      case '갈색':
        return Colors.brown;
      case '녹색':
        return Colors.green;
      case '검은색':
        return Colors.black87;
      case '하얀색':
        return Colors.grey[300]!;
      case '주황색':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  /// 농도/상태에 따른 아이콘 반환
  IconData getConsistencyIcon(String consistency) {
    switch (consistency) {
      case '묽음':
        return Icons.water_drop;
      case '보통':
        return Icons.circle;
      case '딱딱함':
        return Icons.square;
      default:
        return Icons.circle;
    }
  }
  
  /// 다음 교체 권장 시간 계산
  String getNextChangeRecommendation() {
    final summary = _todaySummary;
    final averageInterval = summary['averageInterval'] ?? 180; // 기본 3시간
    final lastChangedMinutesAgo = summary['lastChangedMinutesAgo'];
    
    if (lastChangedMinutesAgo == null) {
      return '권장: 2-3시간마다 확인';
    }
    
    final recommendedMinutes = averageInterval - lastChangedMinutesAgo;
    
    if (recommendedMinutes <= 0) {
      return '교체 시기가 되었습니다';
    } else if (recommendedMinutes < 60) {
      return '${recommendedMinutes}분 후 확인 권장';
    } else {
      final hours = recommendedMinutes ~/ 60;
      final minutes = recommendedMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간 후 확인 권장';
      } else {
        return '${hours}시간 ${minutes}분 후 확인 권장';
      }
    }
  }
}