import 'package:flutter/material.dart';
import '../../domain/models/medication.dart';
import '../../services/medication/medication_service.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationService _medicationService = MedicationService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 투약 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 투약 기록 목록
  List<Medication> _todayMedications = [];
  
  // 기본 투약 설정
  Map<String, dynamic> _medicationDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  Medication? _lastDeletedMedication;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<Medication> get todayMedications => _todayMedications;
  Map<String, dynamic> get medicationDefaults => _medicationDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedMedication != null;
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
        _loadTodayMedications(),
        _loadMedicationDefaults(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing medication data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _medicationService.getTodayMedicationSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 투약 기록 로드
  Future<void> _loadTodayMedications() async {
    if (_currentBabyId == null) return;
    
    try {
      _todayMedications = await _medicationService.getTodayMedications(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today medications: $e');
    }
  }
  
  /// 기본 투약 설정 로드
  Future<void> _loadMedicationDefaults() async {
    try {
      _medicationDefaults = await _medicationService.getMedicationDefaults();
    } catch (e) {
      debugPrint('Error loading medication defaults: $e');
    }
  }
  
  /// 기본 투약 설정 저장
  Future<void> saveMedicationDefaults({
    String? medicationName,
    String? dosage,
    String? unit,
    String? route,
  }) async {
    try {
      await _medicationService.saveMedicationDefaults(
        medicationName: medicationName,
        dosage: dosage,
        unit: unit,
        route: route,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadMedicationDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving medication defaults: $e');
    }
  }
  
  /// 퀵 투약 기록 추가 (기본 설정 사용)
  Future<bool> addQuickMedication() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final medication = await _medicationService.addMedication(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (medication != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayMedications.insert(0, medication);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick medication: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 투약 기록 추가
  Future<bool> addCustomMedication({
    required String medicationName,
    required String dosage,
    String? unit,
    String? route,
    String? notes,
    DateTime? administeredAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final medication = await _medicationService.addMedication(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        medicationName: medicationName,
        dosage: dosage,
        unit: unit,
        route: route,
        notes: notes,
        administeredAt: administeredAt,
      );
      
      if (medication != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayMedications.insert(0, medication);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom medication: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 투약 기록 삭제
  Future<bool> deleteMedication(String medicationId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _medicationService.deleteMedication(medicationId);
      
      if (success) {
        // 목록에서 제거
        _todayMedications.removeWhere((medication) => medication.id == medicationId);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting medication: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 투약 기록 삭제 (언두 지원)
  Future<bool> deleteLatestMedication() async {
    if (_todayMedications.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestMedication = _todayMedications.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedMedication = latestMedication;
      _lastDeletedIndex = 0;
      
      final success = await _medicationService.deleteMedication(latestMedication.id);
      
      if (success) {
        // 목록에서 제거
        _todayMedications.removeAt(0);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest medication: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedMedication == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredMedication = await _medicationService.addMedication(
        babyId: _lastDeletedMedication!.babyId,
        userId: _lastDeletedMedication!.userId,
        medicationName: _lastDeletedMedication!.medicationName,
        dosage: _lastDeletedMedication!.dosage,
        unit: _lastDeletedMedication!.unit,
        route: _lastDeletedMedication!.route,
        notes: _lastDeletedMedication!.notes,
        administeredAt: _lastDeletedMedication!.administeredAt,
      );
      
      if (restoredMedication != null) {
        // 원래 위치에 삽입
        _todayMedications.insert(_lastDeletedIndex!, restoredMedication);
        
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
    _lastDeletedMedication = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 투약 기록 수정
  Future<bool> updateMedication({
    required String medicationId,
    String? medicationName,
    String? dosage,
    String? unit,
    String? route,
    String? notes,
    DateTime? administeredAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedMedication = await _medicationService.updateMedication(
        medicationId: medicationId,
        medicationName: medicationName,
        dosage: dosage,
        unit: unit,
        route: route,
        notes: notes,
        administeredAt: administeredAt,
      );
      
      if (updatedMedication != null) {
        // 목록에서 업데이트
        final index = _todayMedications.indexWhere((medication) => medication.id == medicationId);
        if (index != -1) {
          _todayMedications[index] = updatedMedication;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating medication: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 투약 경로에 따른 아이콘 반환
  IconData getRouteIcon(String? route) {
    switch (route) {
      case 'oral':
        return Icons.medication_liquid;
      case 'topical':
        return Icons.healing;
      case 'inhaled':
        return Icons.air;
      case 'injection':
        return Icons.medical_services;
      default:
        return Icons.medication;
    }
  }
  
  /// 투약 경로에 따른 이름 반환
  String getRouteName(String? route) {
    switch (route) {
      case 'oral':
        return '경구';
      case 'topical':
        return '외용';
      case 'inhaled':
        return '흡입';
      case 'injection':
        return '주사';
      default:
        return '기타';
    }
  }
  
  /// 단위에 따른 표시 이름 반환
  String getUnitName(String? unit) {
    switch (unit) {
      case 'ml':
        return 'ml';
      case 'mg':
        return 'mg';
      case 'tablets':
        return '정';
      case 'drops':
        return '방울';
      case 'tsp':
        return '티스푼';
      case 'tbsp':
        return '큰술';
      default:
        return '';
    }
  }
  
  /// 투약량을 사용자 친화적 문자열로 반환
  String getDosageString(String dosage, String? unit) {
    final unitName = getUnitName(unit);
    return unitName.isEmpty ? dosage : '$dosage$unitName';
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
  
  /// 다음 투약 권장 시간 계산
  String getNextMedicationRecommendation() {
    final summary = _todaySummary;
    final averageInterval = summary['averageInterval'] ?? 480; // 기본 8시간
    final lastMedicationMinutesAgo = summary['lastMedicationMinutesAgo'];
    
    if (lastMedicationMinutesAgo == null) {
      return '의사 처방에 따라 투약';
    }
    
    final recommendedMinutes = averageInterval - lastMedicationMinutesAgo;
    
    if (recommendedMinutes <= 0) {
      return '투약 시간을 확인하세요';
    } else if (recommendedMinutes < 60) {
      return '${recommendedMinutes}분 후 투약 예정';
    } else {
      final hours = recommendedMinutes ~/ 60;
      final minutes = recommendedMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간 후 투약 예정';
      } else {
        return '${hours}시간 ${minutes}분 후 투약 예정';
      }
    }
  }
  
  /// 투약 기록이 있는지 확인
  bool hasMedicationToday() {
    return _todayMedications.isNotEmpty;
  }
  
  /// 특정 약물의 오늘 투약 횟수 반환
  int getTodayDoseCount(String medicationName) {
    return _todayMedications
        .where((medication) => medication.medicationName.toLowerCase() == medicationName.toLowerCase())
        .length;
  }
  
  /// 투약 기록을 약물별로 그룹화
  Map<String, List<Medication>> getMedicationsByName() {
    final grouped = <String, List<Medication>>{};
    
    for (final medication in _todayMedications) {
      final name = medication.medicationName;
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(medication);
    }
    
    return grouped;
  }
}