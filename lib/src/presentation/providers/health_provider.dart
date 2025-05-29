import 'package:flutter/material.dart';
import '../../domain/models/health_record.dart';
import '../../services/health/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _healthService = HealthService.instance;
  
  // 현재 선택된 아기 ID
  String? _currentBabyId;
  String? _currentUserId;
  
  // 오늘의 건강 요약 데이터
  Map<String, dynamic> _todaySummary = {};
  
  // 오늘의 건강 기록 목록
  List<HealthRecord> _todayHealthRecords = [];
  
  // 기본 건강 설정
  Map<String, dynamic> _healthDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  HealthRecord? _lastDeletedRecord;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentBabyId => _currentBabyId;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get todaySummary => _todaySummary;
  List<HealthRecord> get todayHealthRecords => _todayHealthRecords;
  Map<String, dynamic> get healthDefaults => _healthDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedRecord != null;
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
        _loadTodayHealthRecords(),
        _loadHealthDefaults(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing health data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 오늘의 요약 데이터 로드
  Future<void> _loadTodaySummary() async {
    if (_currentBabyId == null) return;
    
    try {
      _todaySummary = await _healthService.getTodayHealthSummary(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today summary: $e');
    }
  }
  
  /// 오늘의 건강 기록 로드
  Future<void> _loadTodayHealthRecords() async {
    if (_currentBabyId == null) return;
    
    try {
      _todayHealthRecords = await _healthService.getTodayHealthRecords(_currentBabyId!);
    } catch (e) {
      debugPrint('Error loading today health records: $e');
    }
  }
  
  /// 기본 건강 설정 로드
  Future<void> _loadHealthDefaults() async {
    try {
      _healthDefaults = await _healthService.getHealthDefaults();
    } catch (e) {
      debugPrint('Error loading health defaults: $e');
    }
  }
  
  /// 기본 건강 설정 저장
  Future<void> saveHealthDefaults({
    double? defaultTemperature,
    String? temperatureUnit,
    String? measurementLocation,
  }) async {
    try {
      await _healthService.saveHealthDefaults(
        defaultTemperature: defaultTemperature,
        temperatureUnit: temperatureUnit,
        measurementLocation: measurementLocation,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadHealthDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving health defaults: $e');
    }
  }

  /// 체온 기본 설정 조회
  Future<Map<String, dynamic>> getTemperatureDefaults() async {
    if (_healthDefaults.isEmpty) {
      await _loadHealthDefaults();
    }
    return _healthDefaults;
  }

  /// 체온 기본 설정 저장 (Map 형태)
  Future<void> saveTemperatureDefaults(Map<String, dynamic> defaults) async {
    await saveHealthDefaults(
      defaultTemperature: defaults['defaultTemperature']?.toDouble(),
      temperatureUnit: defaults['temperatureUnit'],
      measurementLocation: defaults['measurementLocation'],
    );
  }
  
  /// 퀵 체온 기록 추가 (기본 설정 사용)
  Future<bool> addQuickTemperature() async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final healthRecord = await _healthService.addHealthRecord(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        type: 'temperature',
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (healthRecord != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayHealthRecords.insert(0, healthRecord);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick temperature: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 건강 기록 추가
  Future<bool> addCustomHealthRecord({
    String? type,
    double? temperature,
    String? medicationName,
    String? medicationDose,
    String? notes,
    DateTime? recordedAt,
  }) async {
    if (_currentBabyId == null || _currentUserId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final healthRecord = await _healthService.addHealthRecord(
        babyId: _currentBabyId!,
        userId: _currentUserId!,
        type: type,
        temperature: temperature,
        medicationName: medicationName,
        medicationDose: medicationDose,
        notes: notes,
        recordedAt: recordedAt,
      );
      
      if (healthRecord != null) {
        // 새로운 기록을 목록의 맨 앞에 추가
        _todayHealthRecords.insert(0, healthRecord);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom health record: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 건강 기록 삭제
  Future<bool> deleteHealthRecord(String recordId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _healthService.deleteHealthRecord(recordId);
      
      if (success) {
        // 목록에서 제거
        _todayHealthRecords.removeWhere((record) => record.id == recordId);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting health record: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 가장 최근 건강 기록 삭제 (언두 지원)
  Future<bool> deleteLatestHealthRecord() async {
    if (_todayHealthRecords.isEmpty) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 가장 최근 기록 (첫 번째 항목)
      final latestRecord = _todayHealthRecords.first;
      
      // 언두를 위해 임시 저장
      _lastDeletedRecord = latestRecord;
      _lastDeletedIndex = 0;
      
      final success = await _healthService.deleteHealthRecord(latestRecord.id);
      
      if (success) {
        // 목록에서 제거
        _todayHealthRecords.removeAt(0);
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting latest health record: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedRecord == null || _lastDeletedIndex == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 기록을 다시 추가
      final restoredRecord = await _healthService.addHealthRecord(
        babyId: _lastDeletedRecord!.babyId,
        userId: _lastDeletedRecord!.userId,
        type: _lastDeletedRecord!.type,
        temperature: _lastDeletedRecord!.temperature,
        medicationName: _lastDeletedRecord!.medicationName,
        medicationDose: _lastDeletedRecord!.medicationDose,
        notes: _lastDeletedRecord!.notes,
        recordedAt: _lastDeletedRecord!.recordedAt,
      );
      
      if (restoredRecord != null) {
        // 원래 위치에 삽입
        _todayHealthRecords.insert(_lastDeletedIndex!, restoredRecord);
        
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
    _lastDeletedRecord = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 건강 기록 수정
  Future<bool> updateHealthRecord({
    required String recordId,
    String? type,
    double? temperature,
    String? medicationName,
    String? medicationDose,
    String? notes,
    DateTime? recordedAt,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedRecord = await _healthService.updateHealthRecord(
        recordId: recordId,
        type: type,
        temperature: temperature,
        medicationName: medicationName,
        medicationDose: medicationDose,
        notes: notes,
        recordedAt: recordedAt,
      );
      
      if (updatedRecord != null) {
        // 목록에서 업데이트
        final index = _todayHealthRecords.indexWhere((record) => record.id == recordId);
        if (index != -1) {
          _todayHealthRecords[index] = updatedRecord;
        }
        
        // 요약 데이터 업데이트
        await _loadTodaySummary();
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating health record: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 건강 기록 타입에 따른 아이콘 반환
  IconData getHealthRecordIcon(String type) {
    switch (type) {
      case 'temperature':
        return Icons.device_thermostat;
      case 'medication':
        return Icons.medication;
      case 'vaccination':
        return Icons.vaccines;
      case 'illness':
        return Icons.sick;
      case 'doctor_visit':
        return Icons.local_hospital;
      case 'other':
        return Icons.health_and_safety;
      default:
        return Icons.health_and_safety;
    }
  }
  
  /// 건강 기록 타입에 따른 이름 반환
  String getHealthRecordTypeName(String type) {
    switch (type) {
      case 'temperature':
        return '체온';
      case 'medication':
        return '투약';
      case 'vaccination':
        return '예방접종';
      case 'illness':
        return '질병';
      case 'doctor_visit':
        return '병원 방문';
      case 'other':
        return '기타';
      default:
        return '건강';
    }
  }
  
  /// 체온 상태에 따른 색상 반환
  Color getTemperatureStatusColor(String? status) {
    switch (status) {
      case 'low':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'mild_fever':
        return Colors.orange;
      case 'high_fever':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// 체온 상태에 따른 이름 반환
  String getTemperatureStatusName(String? status) {
    switch (status) {
      case 'low':
        return '저체온';
      case 'normal':
        return '정상';
      case 'mild_fever':
        return '미열';
      case 'high_fever':
        return '고열';
      default:
        return '미측정';
    }
  }
  
  /// 체온 상태에 따른 아이콘 반환
  IconData getTemperatureStatusIcon(String? status) {
    switch (status) {
      case 'low':
        return Icons.ac_unit;
      case 'normal':
        return Icons.check_circle;
      case 'mild_fever':
        return Icons.warning;
      case 'high_fever':
        return Icons.local_fire_department;
      default:
        return Icons.device_thermostat;
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
  
  /// 체온 값을 문자열로 포맷
  String formatTemperature(double? temperature) {
    if (temperature == null) return '--';
    return '${temperature.toStringAsFixed(1)}°C';
  }
  
  /// 체온 값의 유효성 검사
  bool isValidTemperature(double temperature) {
    // 일반적인 체온 범위: 30°C ~ 45°C
    return temperature >= 30.0 && temperature <= 45.0;
  }
  
  /// 다음 체온 측정 권장 시간 계산
  String getNextMeasurementRecommendation() {
    final summary = _todaySummary;
    final lastRecordMinutesAgo = summary['lastRecordMinutesAgo'];
    final temperatureStatus = summary['temperatureStatus'];
    
    if (lastRecordMinutesAgo == null) {
      return '체온을 측정해보세요';
    }
    
    // 상태에 따른 권장 측정 간격
    int recommendedInterval = 240; // 기본 4시간
    switch (temperatureStatus) {
      case 'high_fever':
        recommendedInterval = 60; // 1시간
        break;
      case 'mild_fever':
        recommendedInterval = 120; // 2시간
        break;
      case 'low':
        recommendedInterval = 120; // 2시간
        break;
      case 'normal':
        recommendedInterval = 240; // 4시간
        break;
    }
    
    final recommendedMinutes = recommendedInterval - lastRecordMinutesAgo;
    
    if (recommendedMinutes <= 0) {
      return '측정 시기가 되었습니다';
    } else if (recommendedMinutes < 60) {
      return '${recommendedMinutes}분 후 측정 권장';
    } else {
      final hours = recommendedMinutes ~/ 60;
      final minutes = recommendedMinutes % 60;
      if (minutes == 0) {
        return '${hours}시간 후 측정 권장';
      } else {
        return '${hours}시간 ${minutes}분 후 측정 권장';
      }
    }
  }
  
  /// 체온 알림 메시지 생성
  String? getTemperatureAlert() {
    final summary = _todaySummary;
    final temperatureStatus = summary['temperatureStatus'];
    final latestTemperature = summary['latestTemperature'];
    
    if (temperatureStatus == null || latestTemperature == null) return null;
    
    switch (temperatureStatus) {
      case 'high_fever':
        return '고열입니다. 즉시 의료진과 상담하세요.';
      case 'mild_fever':
        return '미열이 있습니다. 수분 보충과 휴식을 취하세요.';
      case 'low':
        return '체온이 낮습니다. 보온에 신경써주세요.';
      default:
        return null;
    }
  }
}