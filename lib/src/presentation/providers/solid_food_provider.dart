import 'package:flutter/material.dart';
import '../../domain/models/solid_food.dart';
import '../../services/solid_food/solid_food_service.dart';

class SolidFoodProvider extends ChangeNotifier {
  final SolidFoodService _solidFoodService = SolidFoodService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 이유식 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 이유식 기록 목록
  List<SolidFood> _todaySolidFoods = [];
  
  // 기본 이유식 설정
  Map<String, dynamic> _solidFoodDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  SolidFood? _lastDeletedSolidFood;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<SolidFood> get todaySolidFoods => _todaySolidFoods;
  Map<String, dynamic> get solidFoodDefaults => _solidFoodDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedSolidFood != null;
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
        _loadTodaySolidFoods(),
        _loadSolidFoodDefaults(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing solid food data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _solidFoodService.getTodaySolidFoodSummary(_currentBabyId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today summary: $e');
      notifyListeners();
    }
  }
  
  /// 오늘의 이유식 기록 로드
  Future<void> _loadTodaySolidFoods() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySolidFoods = await _solidFoodService.getTodaySolidFoods(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today solid foods: $e');
    }
  }
  
  /// 기본 이유식 설정 로드
  Future<void> _loadSolidFoodDefaults() async {
    try {
      _solidFoodDefaults = await _solidFoodService.getSolidFoodDefaults();
    } catch (e) {
      debugPrint('Error loading solid food defaults: $e');
    }
  }
  
  /// 기본 이유식 설정 저장
  Future<void> saveSolidFoodDefaults({
    String? foodName,
    int? amountGrams,
    String? allergicReaction,
  }) async {
    try {
      await _solidFoodService.saveSolidFoodDefaults(
        foodName: foodName,
        amountGrams: amountGrams,
        allergicReaction: allergicReaction,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadSolidFoodDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving solid food defaults: $e');
    }
  }
  
  /// 퀵 이유식 기록 추가 (기본 설정 사용)
  Future<bool> addQuickSolidFood() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final solidFood = await _solidFoodService.addSolidFood(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (solidFood != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todaySolidFoods.insert(0, solidFood);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick solid food: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 이유식 기록 추가
  Future<bool> addCustomSolidFood({
    required String foodName,
    int? amountGrams,
    String? allergicReaction,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final solidFood = await _solidFoodService.addSolidFood(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        foodName: foodName,
        amountGrams: amountGrams,
        allergicReaction: allergicReaction,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (solidFood != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todaySolidFoods.insert(0, solidFood);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom solid food: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 이유식 기록 삭제
  Future<bool> deleteSolidFood(String solidFoodId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _solidFoodService.deleteSolidFood(solidFoodId);
      
      if (success) {
        // 목록에서 제거
        _todaySolidFoods.removeWhere((solidFood) => solidFood.id == solidFoodId);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting solid food: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 이유식 기록 삭제 (언두 지원)
  Future<bool> deleteLatestSolidFood() async {
    if (_todaySolidFoods.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestSolidFood = _todaySolidFoods.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedSolidFood = latestSolidFood;
      _lastDeletedIndex = 0;
      
      final success = await _solidFoodService.deleteSolidFood(latestSolidFood.id);
      
      if (success) {
        // 목록에서 제거
        _todaySolidFoods.removeAt(0);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest solid food: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedSolidFood == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredSolidFood = await _solidFoodService.addSolidFood(
        babyId: _lastDeletedSolidFood!.babyId,
        userId: _lastDeletedSolidFood!.userId,
        foodName: _lastDeletedSolidFood!.foodName,
        amountGrams: _lastDeletedSolidFood!.amountGrams,
        allergicReaction: _lastDeletedSolidFood!.allergicReaction,
        notes: _lastDeletedSolidFood!.notes,
        startedAt: _lastDeletedSolidFood!.startedAt,
        endedAt: _lastDeletedSolidFood!.endedAt,
      );
      
      if (restoredSolidFood != null) {
        // 원래 위치에 삽입
        _todaySolidFoods.insert(_lastDeletedIndex!, restoredSolidFood);
        
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
    _lastDeletedSolidFood = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 이유식 기록 수정
  Future<bool> updateSolidFood({
    required String solidFoodId,
    String? foodName,
    int? amountGrams,
    String? allergicReaction,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedSolidFood = await _solidFoodService.updateSolidFood(
        solidFoodId: solidFoodId,
        foodName: foodName,
        amountGrams: amountGrams,
        allergicReaction: allergicReaction,
        notes: notes,
        startedAt: startedAt,
        endedAt: endedAt,
      );
      
      if (updatedSolidFood != null) {
        // 목록에서 업데이트
        final index = _todaySolidFoods.indexWhere((solidFood) => solidFood.id == solidFoodId);
        if (index != -1) {
          _todaySolidFoods[index] = updatedSolidFood;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating solid food: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 알레르기 반응에 따른 아이콘 반환
  IconData getAllergicReactionIcon(String? reaction) {
    switch (reaction) {
      case 'none':
        return Icons.check_circle;
      case 'mild':
        return Icons.warning_amber;
      case 'moderate':
        return Icons.warning;
      case 'severe':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }
  
  /// 알레르기 반응에 따른 이름 반환
  String getAllergicReactionName(String? reaction) {
    switch (reaction) {
      case 'none':
        return '없음';
      case 'mild':
        return '경미';
      case 'moderate':
        return '보통';
      case 'severe':
        return '심각';
      default:
        return '알 수 없음';
    }
  }
  
  /// 알레르기 반응에 따른 색상 반환
  Color getAllergicReactionColor(String? reaction) {
    switch (reaction) {
      case 'none':
        return Colors.green;
      case 'mild':
        return Colors.orange;
      case 'moderate':
        return Colors.red;
      case 'severe':
        return Colors.red[700]!;
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
  
  /// 양을 사용자 친화적 문자열로 반환
  String getAmountString(int? amountGrams) {
    if (amountGrams == null) return '';
    
    if (amountGrams < 1000) {
      return '${amountGrams}g';
    } else {
      final kg = amountGrams / 1000;
      return '${kg.toStringAsFixed(1)}kg';
    }
  }
  
  /// 다음 이유식 권장 시간 계산
  String getNextFeedingRecommendation() {
    final summary = _todaySummary;
    final averageInterval = summary['averageInterval'] ?? 240; // 기본 4시간
    final lastFeedingMinutesAgo = summary['lastFeedingMinutesAgo'];
    
    if (lastFeedingMinutesAgo == null) {
      return '권장: 4-6시간마다 식사';
    }
    
    final recommendedMinutes = averageInterval - lastFeedingMinutesAgo;
    
    if (recommendedMinutes <= 0) {
      return '식사 시간이 되었습니다';
    } else if (recommendedMinutes < 60) {
      return '${recommendedMinutes}분 후 식사 권장';
    } else {
      final hours = recommendedMinutes ~/ 60;
      final minutes = recommendedMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간 후 식사 권장';
      } else {
        return '${hours}시간 ${minutes}분 후 식사 권장';
      }
    }
  }
}