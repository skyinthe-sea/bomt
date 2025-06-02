import 'package:flutter/material.dart';
import '../../domain/models/user_card_setting.dart';
import '../../services/user_card_setting/user_card_setting_service.dart';

class UserCardSettingProvider extends ChangeNotifier {
  final UserCardSettingService _userCardSettingService = UserCardSettingService.instance;
  
  // 현재 선택된 사용자 ID
  String? _currentUserId;
  String? _currentBabyId;
  
  // 사용자 카드 설정 목록
  List<UserCardSetting> _userCardSettings = [];
  
  // 기본 카드 설정
  Map<String, dynamic> _cardDefaults = {};
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isUpdating = false;
  
  // 언두를 위한 임시 저장
  UserCardSetting? _lastDeletedSetting;
  int? _lastDeletedIndex;
  
  // Getters
  String? get currentUserId => _currentUserId;
  String? get currentBabyId => _currentBabyId;
  List<UserCardSetting> get userCardSettings => _userCardSettings;
  Map<String, dynamic> get cardDefaults => _cardDefaults;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get canUndo => _lastDeletedSetting != null;
  bool get hasSettings => _userCardSettings.isNotEmpty;
  
  /// 현재 사용자 설정
  void setCurrentUser(String userId, String babyId, {bool autoRefresh = true}) {
    if (_currentUserId != userId || _currentBabyId != babyId) {
      _currentUserId = userId;
      _currentBabyId = babyId;
      // 사용자가 변경되면 데이터 새로고침 (옵션에 따라)
      if (autoRefresh) {
        refreshData();
      }
    }
  }
  
  /// 모든 데이터 새로고침
  Future<void> refreshData({bool showLoading = true}) async {
    debugPrint('🔄 [REFRESH] Starting refreshData (showLoading: $showLoading)...');
    debugPrint('🔄 [REFRESH] Current user ID: $_currentUserId');
    
    if (_currentUserId == null) {
      debugPrint('❌ [REFRESH] No current user ID, returning early');
      return;
    }
    
    bool needsNotification = false;
    
    if (showLoading && !_isLoading) {
      debugPrint('🔄 [REFRESH] Setting isLoading = true');
      _isLoading = true;
      needsNotification = true;
      notifyListeners();
    }
    
    try {
      debugPrint('🔄 [REFRESH] Starting parallel data loading...');
      await Future.wait([
        _loadUserCardSettings(),
        _loadCardDefaults(),
      ]);
      debugPrint('✅ [REFRESH] Data loading completed successfully');
      needsNotification = true;
    } catch (e) {
      debugPrint('❌ [REFRESH] Error refreshing user card setting data: $e');
      debugPrint('❌ [REFRESH] Stack trace: ${StackTrace.current}');
      needsNotification = true;
    } finally {
      if (showLoading && _isLoading) {
        debugPrint('🔄 [REFRESH] Setting isLoading = false');
        _isLoading = false;
        needsNotification = true;
      }
      
      if (needsNotification) {
        debugPrint('🔄 [REFRESH] Calling notifyListeners()');
        notifyListeners();
      } else {
        debugPrint('🔄 [REFRESH] Skipping notifyListeners() - no changes');
      }
      debugPrint('✅ [REFRESH] refreshData completed');
    }
  }
  
  /// 사용자 카드 설정 로드
  Future<void> _loadUserCardSettings() async {
    debugPrint('📚 [LOAD] Starting _loadUserCardSettings...');
    debugPrint('📚 [LOAD] Current user ID: $_currentUserId');
    
    if (_currentUserId == null) {
      debugPrint('❌ [LOAD] No current user ID, returning early');
      return;
    }
    
    try {
      debugPrint('📚 [LOAD] Calling service.getUserCardSettings...');
      _userCardSettings = await _userCardSettingService.getUserCardSettings(_currentUserId!);
      debugPrint('📚 [LOAD] Received ${_userCardSettings.length} card settings');
      
      // 표시 순서대로 정렬
      debugPrint('📚 [LOAD] Sorting by display order...');
      _userCardSettings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      debugPrint('✅ [LOAD] Card settings loaded and sorted successfully');
    } catch (e) {
      debugPrint('❌ [LOAD] Error loading user card settings: $e');
      debugPrint('❌ [LOAD] Stack trace: ${StackTrace.current}');
    }
  }
  
  /// 기본 카드 설정 로드
  Future<void> _loadCardDefaults() async {
    try {
      _cardDefaults = await _userCardSettingService.getCardDefaults();
    } catch (e) {
      debugPrint('Error loading card defaults: $e');
    }
  }
  
  /// 기본 카드 설정 저장
  Future<void> saveCardDefaults({
    bool? isVisible,
    int? displayOrder,
  }) async {
    try {
      await _userCardSettingService.saveCardDefaults(
        isVisible: isVisible,
        displayOrder: displayOrder,
      );
      
      // 설정 저장 후 기본값 새로고침
      await _loadCardDefaults();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving card defaults: $e');
    }
  }
  
  /// 퀵 카드 설정 추가 (기본 설정 사용)
  Future<bool> addQuickCardSetting(String cardType) async {
    if (_currentUserId == null || _currentBabyId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final setting = await _userCardSettingService.addUserCardSetting(
        userId: _currentUserId!,
        babyId: _currentBabyId!,
        cardType: cardType,
        // 기본 설정값들이 자동으로 사용됨
      );
      
      if (setting != null) {
        // 새로운 설정을 목록에 추가
        _userCardSettings.add(setting);
        
        // 표시 순서대로 정렬
        _userCardSettings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding quick card setting: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 커스텀 카드 설정 추가
  Future<bool> addCustomCardSetting({
    required String cardType,
    required bool isVisible,
    required int displayOrder,
    Map<String, dynamic>? customSettings,
  }) async {
    if (_currentUserId == null || _currentBabyId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final setting = await _userCardSettingService.addUserCardSetting(
        userId: _currentUserId!,
        babyId: _currentBabyId!,
        cardType: cardType,
        isVisible: isVisible,
        displayOrder: displayOrder,
        customSettings: customSettings,
      );
      
      if (setting != null) {
        // 새로운 설정을 목록에 추가
        _userCardSettings.add(setting);
        
        // 표시 순서대로 정렬
        _userCardSettings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        return true;
      }
    } catch (e) {
      debugPrint('Error adding custom card setting: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 카드 설정 삭제
  Future<bool> deleteCardSetting(String settingId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _userCardSettingService.deleteUserCardSetting(settingId);
      
      if (success) {
        // 목록에서 제거
        _userCardSettings.removeWhere((setting) => setting.id == settingId);
        
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting card setting: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 카드 설정 삭제 (언두 지원)
  Future<bool> deleteCardSettingWithUndo(String settingId) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 삭제할 설정 찾기
      final index = _userCardSettings.indexWhere((setting) => setting.id == settingId);
      if (index == -1) return false;
      
      final settingToDelete = _userCardSettings[index];
      
      // 언두를 위해 임시 저장
      _lastDeletedSetting = settingToDelete;
      _lastDeletedIndex = index;
      
      final success = await _userCardSettingService.deleteUserCardSetting(settingId);
      
      if (success) {
        // 목록에서 제거
        _userCardSettings.removeAt(index);
        
        return true;
      } else {
        // 실패 시 임시 저장 클리어
        _clearUndoData();
      }
    } catch (e) {
      debugPrint('Error deleting card setting with undo: $e');
      _clearUndoData();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }

  /// 삭제 취소 (언두)
  Future<bool> undoDelete() async {
    if (_lastDeletedSetting == null || _lastDeletedIndex == null || _currentBabyId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      // 설정을 다시 추가
      final restoredSetting = await _userCardSettingService.addUserCardSetting(
        userId: _lastDeletedSetting!.userId,
        babyId: _currentBabyId!,
        cardType: _lastDeletedSetting!.cardType,
        isVisible: _lastDeletedSetting!.isVisible,
        displayOrder: _lastDeletedSetting!.displayOrder,
        customSettings: _lastDeletedSetting!.customSettings,
      );
      
      if (restoredSetting != null) {
        // 원래 위치에 삽입
        _userCardSettings.insert(_lastDeletedIndex!, restoredSetting);
        
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
    _lastDeletedSetting = null;
    _lastDeletedIndex = null;
  }

  /// 언두 데이터 만료 (일정 시간 후 자동 클리어)
  void clearUndoData() {
    _clearUndoData();
    notifyListeners();
  }
  
  /// 카드 설정 수정
  Future<bool> updateCardSetting({
    required String settingId,
    String? cardType,
    bool? isVisible,
    int? displayOrder,
    Map<String, dynamic>? customSettings,
  }) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updatedSetting = await _userCardSettingService.updateUserCardSetting(
        cardSettingId: settingId,
        cardType: cardType,
        isVisible: isVisible,
        displayOrder: displayOrder,
        customSettings: customSettings,
      );
      
      if (updatedSetting != null) {
        // 목록에서 업데이트
        final index = _userCardSettings.indexWhere((setting) => setting.id == settingId);
        if (index != -1) {
          _userCardSettings[index] = updatedSetting;
          
          // 표시 순서가 변경되었다면 재정렬
          if (displayOrder != null) {
            _userCardSettings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          }
        }
        
        return true;
      }
    } catch (e) {
      debugPrint('Error updating card setting: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 카드 표시/숨기기 토글
  Future<bool> toggleCardVisibility(String cardType) async {
    final setting = getSettingByCardType(cardType);
    if (setting == null) return false;
    
    return await updateCardSetting(
      settingId: setting.id,
      isVisible: !setting.isVisible,
    );
  }
  
  /// 카드 순서 변경
  Future<bool> reorderCards(List<String> orderedCardTypes) async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final List<Future<bool>> updates = [];
      
      for (int i = 0; i < orderedCardTypes.length; i++) {
        final cardType = orderedCardTypes[i];
        final setting = getSettingByCardType(cardType);
        
        if (setting != null && setting.displayOrder != i) {
          updates.add(updateCardSetting(
            settingId: setting.id,
            displayOrder: i,
          ));
        }
      }
      
      final results = await Future.wait(updates);
      return results.every((result) => result);
    } catch (e) {
      debugPrint('Error reordering cards: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
  
  /// 카드 타입에 따른 설정 반환
  UserCardSetting? getSettingByCardType(String cardType) {
    try {
      return _userCardSettings.firstWhere((setting) => setting.cardType == cardType);
    } catch (e) {
      return null;
    }
  }
  
  /// 카드가 표시되는지 확인
  bool isCardVisible(String cardType) {
    final setting = getSettingByCardType(cardType);
    return setting?.isVisible ?? false; // 기본값은 숨김 (DB에 명시적으로 설정된 카드만 표시)
  }
  
  /// 카드 표시 순서 반환
  int getCardDisplayOrder(String cardType) {
    final setting = getSettingByCardType(cardType);
    return setting?.displayOrder ?? 999; // 기본값은 마지막 순서
  }
  
  /// 표시되는 카드들만 순서대로 반환
  List<UserCardSetting> getVisibleCardSettings() {
    return _userCardSettings
        .where((setting) => setting.isVisible)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// 활성화된 카드들의 카드 타입을 순서대로 반환
  List<String> getEnabledCardsInOrder() {
    final visibleCards = getVisibleCardSettings()
        .map((setting) => setting.cardType)
        .toList();
    
    // 카드 설정이 없으면 기본 카드들 반환
    if (visibleCards.isEmpty) {
      debugPrint('🃏 [PROVIDER] No card settings found, returning default cards');
      return ['feeding', 'sleep', 'diaper'];
    }
    
    debugPrint('🃏 [PROVIDER] Returning ${visibleCards.length} visible cards: $visibleCards');
    return visibleCards;
  }
  
  /// 숨겨진 카드들 반환
  List<UserCardSetting> getHiddenCardSettings() {
    return _userCardSettings
        .where((setting) => !setting.isVisible)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
  
  /// 카드 타입에 따른 아이콘 반환
  IconData getCardIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink;
      case 'sleep':
        return Icons.bedtime;
      case 'diaper':
        return Icons.child_care;
      case 'growth':
        return Icons.timeline;
      case 'health':
        return Icons.health_and_safety;
      case 'medication':
        return Icons.medication;
      case 'solid_food':
        return Icons.restaurant;
      case 'milk_pumping':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      default:
        return Icons.dashboard;
    }
  }
  
  /// 카드 타입에 따른 이름 반환
  String getCardName(String cardType) {
    switch (cardType) {
      case 'feeding':
        return '수유';
      case 'sleep':
        return '수면';
      case 'diaper':
        return '기저귀';
      case 'growth':
        return '성장';
      case 'health':
        return '건강';
      case 'medication':
        return '투약';
      case 'solid_food':
        return '이유식';
      case 'milk_pumping':
        return '유축';
      case 'temperature':
        return '체온';
      default:
        return cardType;
    }
  }
  
  /// 모든 카드 설정 초기화 (기본값으로 복원)
  Future<bool> resetAllCardSettings() async {
    if (_currentUserId == null || _currentBabyId == null) return false;
    
    _isUpdating = true;
    notifyListeners();
    
    try {
      final success = await _userCardSettingService.resetUserCardSettings(_currentUserId!, _currentBabyId!);
      
      if (success) {
        // 데이터 새로고침
        await _loadUserCardSettings();
        return true;
      }
    } catch (e) {
      debugPrint('Error resetting card settings: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    
    return false;
  }
  
  /// 새로운 카드 타입이 추가될 때 기본 설정 생성
  Future<void> ensureCardSettingExists(String cardType) async {
    if (_currentUserId == null) return;
    
    final setting = getSettingByCardType(cardType);
    if (setting == null) {
      await addQuickCardSetting(cardType);
    }
  }
  
  /// 여러 카드 타입에 대해 기본 설정 생성
  Future<void> ensureCardSettingsExist(List<String> cardTypes) async {
    for (final cardType in cardTypes) {
      await ensureCardSettingExists(cardType);
    }
  }
  
  /// 카드 설정 백업
  Map<String, dynamic> exportCardSettings() {
    return {
      'userId': _currentUserId,
      'settings': _userCardSettings.map((setting) => {
        'cardType': setting.cardType,
        'isVisible': setting.isVisible,
        'displayOrder': setting.displayOrder,
        'customSettings': setting.customSettings,
      }).toList(),
      'defaults': _cardDefaults,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// 카드 설정 복원
  Future<bool> importCardSettings(Map<String, dynamic> data) async {
    if (_currentUserId == null) return false;
    
    try {
      final settings = data['settings'] as List<dynamic>;
      
      // 기존 설정 모두 삭제
      await resetAllCardSettings();
      
      // 새 설정 추가
      for (final settingData in settings) {
        await addCustomCardSetting(
          cardType: settingData['cardType'],
          isVisible: settingData['isVisible'],
          displayOrder: settingData['displayOrder'],
          customSettings: settingData['customSettings'],
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Error importing card settings: $e');
      return false;
    }
  }
}