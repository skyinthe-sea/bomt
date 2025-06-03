import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/user_card_setting_provider.dart';
import '../../../../domain/models/user_card_setting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/user_card_setting/user_card_setting_service.dart';
import '../../../../services/feeding/feeding_service.dart';
import '../../../../services/sleep/sleep_service.dart';
import '../../../../services/solid_food/solid_food_service.dart';
import '../../../../services/medication/medication_service.dart';
import '../../../../services/milk_pumping/milk_pumping_service.dart';
import '../../../../services/diaper/diaper_service.dart';
import '../widgets/default_value_dialog.dart';

/// 카드 설정 화면
/// 
/// 홈 화면에 표시될 카드들의 순서와 표시 여부를 설정할 수 있습니다.
/// - 6가지 카드 타입: 수유, 수면, 기저귀, 이유식, 투약, 유축
/// - 드래그 앤 드롭으로 순서 변경
/// - 토글 스위치로 표시/숨김 설정
/// - 실시간 미리보기
/// - 변경사항 저장/취소
class CardSettingsScreen extends StatefulWidget {
  final String userId;
  final String babyId;
  
  const CardSettingsScreen({
    super.key,
    required this.userId,
    required this.babyId,
  });

  @override
  State<CardSettingsScreen> createState() => _CardSettingsScreenState();
}

class _CardSettingsScreenState extends State<CardSettingsScreen> {
  // Provider 제거하고 직접 서비스 사용
  final _userCardSettingService = UserCardSettingService.instance;
  
  // 사용 가능한 카드 타입들 (순서대로)
  static const List<String> _availableCardTypes = [
    'feeding',
    'sleep', 
    'diaper',
    'solid_food',
    'medication',
    'milk_pumping',
  ];
  
  // 설정 백업 (취소 시 복원용)
  List<UserCardSetting> _originalSettings = [];
  
  // 현재 편집 중인 설정들
  List<CardSettingItem> _editingSettings = [];
  
  // 변경사항 추적
  bool _hasChanges = false;
  
  // 초기화 여부 추적
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }
  
  /// 설정 초기화
  void _initializeSettings() {
    // 먼저 기본 설정으로 초기화
    _editingSettings = _createDefaultSettings();
    
    // 비동기적으로 실제 설정 로드
    _loadUserCardSettings();
  }
  
  /// 사용자 카드 설정 로드
  Future<void> _loadUserCardSettings() async {
    try {
      debugPrint('🔄 [CARD_SETTINGS] Loading user card settings...');
      final userCardSettings = await _userCardSettingService.getUserCardSettings(widget.userId);
      debugPrint('🔄 [CARD_SETTINGS] Loaded ${userCardSettings.length} settings');
      
      if (mounted) {
        setState(() {
          _originalSettings = userCardSettings;
          _editingSettings = _createEditingSettingsFromData(userCardSettings);
        });
        debugPrint('✅ [CARD_SETTINGS] Settings loaded and UI updated');
      }
    } catch (e) {
      debugPrint('❌ [CARD_SETTINGS] Error loading user card settings: $e');
      if (mounted) {
        setState(() {
          _editingSettings = _createDefaultSettings();
        });
      }
    }
  }
  
  /// 기본 설정 생성 (에러 발생 시 사용)
  List<CardSettingItem> _createDefaultSettings() {
    final List<CardSettingItem> items = [];
    
    for (int i = 0; i < _availableCardTypes.length; i++) {
      final cardType = _availableCardTypes[i];
      items.add(CardSettingItem(
        cardType: cardType,
        isVisible: i < 3, // 처음 3개만 기본으로 표시
        displayOrder: i,
        iconData: _getDefaultIcon(cardType),
        name: _getCardNameSafe(cardType),
        customSettings: {},
      ));
    }
    
    return items;
  }
  
  /// 기존 데이터에서 편집용 설정 목록 생성
  List<CardSettingItem> _createEditingSettingsFromData(List<UserCardSetting> userCardSettings) {
    final List<CardSettingItem> items = [];
    
    // 기존 설정이 있는 카드들 먼저 추가
    for (final cardType in _availableCardTypes) {
      final existingSetting = userCardSettings.firstWhere(
        (setting) => setting.cardType == cardType,
        orElse: () => UserCardSetting(
          id: '',
          userId: widget.userId,
          cardType: cardType,
          isVisible: false,
          displayOrder: items.length,
          customSettings: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      items.add(CardSettingItem(
        cardType: cardType,
        isVisible: existingSetting.isVisible,
        displayOrder: existingSetting.displayOrder,
        iconData: _getDefaultIcon(cardType),
        name: _getCardNameSafe(cardType),
        customSettings: existingSetting.customSettings ?? {},
      ));
    }
    
    // 표시 순서대로 정렬
    items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    
    return items;
  }
  
  /// 설정 변경 감지
  void _onSettingChanged() {
    setState(() {
      _hasChanges = _hasSettingsChanged();
    });
  }
  
  /// 변경사항이 있는지 확인
  bool _hasSettingsChanged() {
    // 순서 변경 확인
    for (int i = 0; i < _editingSettings.length; i++) {
      final editingItem = _editingSettings[i];
      final originalSetting = _originalSettings.firstWhere(
        (setting) => setting.cardType == editingItem.cardType,
        orElse: () => UserCardSetting(
          id: '',
          userId: widget.userId,
          cardType: editingItem.cardType,
          isVisible: false,
          displayOrder: i,
          customSettings: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      // 표시 순서가 다른 경우
      if (editingItem.displayOrder != originalSetting.displayOrder) {
        return true;
      }
      
      // 표시 여부가 다른 경우
      if (editingItem.isVisible != originalSetting.isVisible) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 카드 순서 변경
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // newIndex 조정 (드래그 중인 아이템이 제거되어 인덱스가 변경됨)
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      
      // 아이템 이동
      final item = _editingSettings.removeAt(oldIndex);
      _editingSettings.insert(newIndex, item);
      
      // 표시 순서 재설정
      for (int i = 0; i < _editingSettings.length; i++) {
        _editingSettings[i] = _editingSettings[i].copyWith(displayOrder: i);
      }
      
      // 햅틱 피드백
      HapticFeedback.lightImpact();
      
      _onSettingChanged();
    });
  }
  
  /// 카드 표시/숨김 토글
  void _onVisibilityToggle(int index) {
    setState(() {
      final item = _editingSettings[index];
      _editingSettings[index] = item.copyWith(isVisible: !item.isVisible);
      
      // 햅틱 피드백
      HapticFeedback.selectionClick();
      
      _onSettingChanged();
    });
  }
  
  /// 설정 저장 (완전히 단순화된 버전)
  Future<void> _saveSettings() async {
    try {
      debugPrint('🚀 [SAVE] Starting simple save process...');
      
      // 직접 저장 수행 (로딩 다이얼로그 없이)
      await _performSaveSettings();
      
      debugPrint('🚀 [SAVE] Save completed, closing screen...');
      
      // 즉시 화면 닫기
      if (mounted) {
        Navigator.of(context).pop(true);
        debugPrint('✅ [SAVE] Screen closed with result: true');
      } else {
        debugPrint('❌ [SAVE] Widget not mounted, cannot close screen');
      }
      
    } catch (e) {
      debugPrint('❌ [SAVE] Error in _saveSettings: $e');
      
      if (mounted) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// 실제 설정 저장 수행
  Future<void> _performSaveSettings() async {
    debugPrint('📝 [PERFORM] Starting _performSaveSettings...');
    debugPrint('📝 [PERFORM] Saving ${_editingSettings.length} card settings...');
    
    try {
      // 각 편집된 설정에 대해 개별 처리
      for (int i = 0; i < _editingSettings.length; i++) {
        final item = _editingSettings[i];
        debugPrint('📝 [PERFORM] Processing card ${i + 1}/${_editingSettings.length}: ${item.cardType}');
        debugPrint('📝 [PERFORM] - visible: ${item.isVisible}, order: ${item.displayOrder}');
        
        final existingSetting = _originalSettings.firstWhere(
          (setting) => setting.cardType == item.cardType,
          orElse: () => UserCardSetting(
            id: '',
            userId: widget.userId,
            cardType: item.cardType,
            isVisible: false,
            displayOrder: i,
            customSettings: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (existingSetting.id.isNotEmpty) {
          // 기존 설정이 있으면 업데이트
          debugPrint('📝 [PERFORM] - Updating existing setting for ${item.cardType}...');
          final updatedSetting = await _userCardSettingService.updateUserCardSetting(
            cardSettingId: existingSetting.id,
            isVisible: item.isVisible,
            displayOrder: item.displayOrder,
            customSettings: item.customSettings,
          );
          
          if (updatedSetting == null) {
            debugPrint('❌ [PERFORM] - Update failed for ${item.cardType}');
            throw Exception('${item.cardType} 설정 업데이트에 실패했습니다');
          }
          debugPrint('✅ [PERFORM] - Successfully updated ${item.cardType}');
        } else {
          // 기존 설정이 없으면 생성
          debugPrint('📝 [PERFORM] - Creating new setting for ${item.cardType}...');
          final newSetting = await _userCardSettingService.addUserCardSetting(
            userId: widget.userId,
            babyId: widget.babyId,
            cardType: item.cardType,
            isVisible: item.isVisible,
            displayOrder: item.displayOrder,
            customSettings: item.customSettings,
          );
          
          if (newSetting == null) {
            debugPrint('❌ [PERFORM] - Creation failed for ${item.cardType}');
            throw Exception('${item.cardType} 설정 생성에 실패했습니다');
          }
          debugPrint('✅ [PERFORM] - Successfully created ${item.cardType}');
        }
      }
      
      debugPrint('✅ [PERFORM] All settings saved successfully');
      
    } catch (e) {
      debugPrint('❌ [PERFORM] Error in _performSaveSettings: $e');
      rethrow;
    }
  }
  
  
  /// 저장 실패 처리
  Future<void> _handleSaveError(String error) async {
    if (!mounted) return;
    
    // 에러 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '설정 저장 중 오류가 발생했습니다. 다시 시도해 주세요.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '다시 시도',
          textColor: Colors.white,
          onPressed: _saveSettings,
        ),
      ),
    );
  }
  
  /// 설정 취소 (원래 설정으로 복원)
  void _cancelSettings() {
    if (_hasChanges) {
      // 변경사항이 있으면 확인 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.cancel),
          content: Text('변경된 설정을 취소하고 이전 상태로 돌아가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('계속 편집'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 설정 화면 닫기
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      );
    } else {
      // 변경사항이 없으면 바로 닫기
      Navigator.of(context).pop();
    }
  }
  
  /// WillPopScope 처리
  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.cancel),
          content: Text('변경된 설정을 저장하지 않고 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('계속 편집'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('나가기'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            '카드 설정',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelSettings,
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveSettings,
                child: Text(
                  '저장',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // 안내 메시지
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '카드 설정 가이드',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 토글 스위치로 카드 표시/숨김을 설정하세요\n• 드래그하여 카드 순서를 변경하세요\n• 변경사항은 실시간으로 미리보기됩니다',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // 카드 목록
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _editingSettings.length,
                    onReorder: _onReorder,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.05,
                            child: Card(
                              elevation: 8,
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final item = _editingSettings[index];
                      
                      return Container(
                        key: ValueKey(item.cardType),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Card(
                          elevation: 0,
                          color: item.isVisible 
                              ? theme.colorScheme.surface
                              : theme.colorScheme.surface.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: item.isVisible
                                  ? theme.colorScheme.outline.withOpacity(0.2)
                                  : theme.colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            // 리스트 아이템 터치 시 기본값 설정 다이얼로그 열기
                            onTap: () => _showDefaultValueDialog(item.cardType),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.isVisible
                                    ? _getCardColor(item.cardType).withOpacity(0.1)
                                    : theme.colorScheme.outline.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.iconData,
                                color: item.isVisible
                                    ? _getCardColor(item.cardType)
                                    : theme.colorScheme.outline.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: item.isVisible
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                // 기본값 설정 힌트 아이콘 (작게)
                                Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: theme.colorScheme.outline.withOpacity(0.4),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              item.isVisible 
                                  ? '표시됨 • 터치하여 기본값 설정' 
                                  : '숨김 • 터치하여 기본값 설정',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: item.isVisible
                                    ? _getCardColor(item.cardType)
                                    : theme.colorScheme.outline.withOpacity(0.7),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 토글 스위치
                                Switch.adaptive(
                                  value: item.isVisible,
                                  onChanged: (_) => _onVisibilityToggle(index),
                                  activeColor: _getCardColor(item.cardType),
                                ),
                                const SizedBox(width: 8),
                                // 드래그 핸들
                                Icon(
                                  Icons.drag_handle,
                                  color: theme.colorScheme.outline.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // 하단 버튼들
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelSettings,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasChanges ? _saveSettings : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _hasChanges
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      child: Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _hasChanges
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 카드 타입에 따른 다국어 이름 반환
  String _getCardName(String cardType) {
    final l10n = AppLocalizations.of(context)!;
    switch (cardType) {
      case 'feeding':
        return l10n.feeding;
      case 'sleep':
        return l10n.sleep;
      case 'diaper':
        return '기저귀';
      case 'solid_food':
        return '이유식';
      case 'medication':
        return '투약';
      case 'milk_pumping':
        return '유축';
      default:
        return cardType;
    }
  }
  
  /// 안전한 카드 이름 반환 (context 없이도 사용 가능)
  String _getCardNameSafe(String cardType) {
    switch (cardType) {
      case 'feeding':
        return '수유';
      case 'sleep':
        return '수면';
      case 'diaper':
        return '기저귀';
      case 'solid_food':
        return '이유식';
      case 'medication':
        return '투약';
      case 'milk_pumping':
        return '유축';
      default:
        return cardType;
    }
  }
  
  /// 기본 아이콘 반환 (provider 없이도 사용 가능)
  IconData _getDefaultIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink;
      case 'sleep':
        return Icons.bedtime;
      case 'diaper':
        return Icons.child_care;
      case 'solid_food':
        return Icons.restaurant;
      case 'medication':
        return Icons.medical_services;
      case 'milk_pumping':
        return Icons.baby_changing_station;
      default:
        return Icons.help_outline;
    }
  }
  
  /// 기본값 설정 다이얼로그 표시
  void _showDefaultValueDialog(String cardType) {
    debugPrint('🎨 [DIALOG] Opening default value dialog for: $cardType');
    
    showDialog(
      context: context,
      builder: (context) => DefaultValueDialog(
        cardType: cardType,
        cardColor: _getCardColor(cardType),
        cardName: _getCardNameSafe(cardType),
        currentSettings: _getCurrentCustomSettings(cardType),
        onSave: (newSettings) => _updateCustomSettings(cardType, newSettings),
      ),
    );
  }
  
  /// 현재 카드의 커스텀 설정 가져오기 (SharedPreferences에서)
  Map<String, dynamic> _getCurrentCustomSettings(String cardType) {
    // 편집 중인 설정에서 가져오기 (실시간 반영)
    final editingItem = _editingSettings.firstWhere(
      (item) => item.cardType == cardType,
      orElse: () => CardSettingItem(
        cardType: cardType,
        isVisible: false,
        displayOrder: 0,
        iconData: _getDefaultIcon(cardType),
        name: _getCardNameSafe(cardType),
        customSettings: {},
      ),
    );
    
    // 현재는 편집 중인 설정에서 반환하되, 나중에 SharedPreferences에서 읽어올 수 있음
    return editingItem.customSettings;
  }
  
  /// 커스텀 설정 업데이트 (임시로 SharedPreferences에 저장)
  void _updateCustomSettings(String cardType, Map<String, dynamic> newSettings) async {
    debugPrint('🎨 [SETTINGS] Updating custom settings for $cardType: $newSettings');
    
    try {
      // 개별 서비스에 저장
      switch (cardType) {
        case 'feeding':
          final feedingService = FeedingService.instance;
          await feedingService.saveFeedingDefaults(
            type: newSettings['type'],
            amountMl: newSettings['amount_ml'],
            durationMinutes: newSettings['duration_minutes'],
            side: newSettings['side'],
          );
          break;
        case 'sleep':
          final sleepService = SleepService.instance;
          await sleepService.saveSleepDefaults(
            durationMinutes: newSettings['duration_minutes'],
            quality: newSettings['quality'],
            location: newSettings['location'],
          );
          break;
        case 'solid_food':
          final solidFoodService = SolidFoodService.instance;
          await solidFoodService.saveSolidFoodDefaults(
            foodName: newSettings['food_name'],
            amountGrams: newSettings['amount_grams'],
            allergicReaction: newSettings['allergic_reaction'],
          );
          break;
        case 'medication':
          final medicationService = MedicationService.instance;
          await medicationService.saveMedicationDefaults(
            medicationName: newSettings['medication_name'],
            dosage: newSettings['dosage'],
            unit: newSettings['unit'],
            route: newSettings['route'],
          );
          break;
        case 'milk_pumping':
          final milkPumpingService = MilkPumpingService.instance;
          await milkPumpingService.saveMilkPumpingDefaults(
            amountMl: newSettings['amount_ml'],
            durationMinutes: newSettings['duration_minutes'],
            side: newSettings['side'],
            storageLocation: newSettings['storage_location'],
          );
          break;
        case 'diaper':
          final diaperService = DiaperService.instance;
          await diaperService.saveDiaperDefaults(
            type: newSettings['type'],
            color: newSettings['color'],
            consistency: newSettings['consistency'],
          );
          break;
      }
      
      // 편집 중인 설정에서 해당 카드 찾아서 업데이트
      final index = _editingSettings.indexWhere((item) => item.cardType == cardType);
      if (index != -1) {
        setState(() {
          _editingSettings[index] = _editingSettings[index].copyWith(
            customSettings: newSettings,
          );
        });
        
        // 변경사항 감지를 위해 설정 변경 플래그 설정
        _onSettingChanged();
      }
      
      debugPrint('✅ [SETTINGS] Custom settings updated successfully');
    } catch (e) {
      debugPrint('❌ [SETTINGS] Error updating custom settings: $e');
    }
  }

  /// 카드 타입에 따른 색상 반환
  Color _getCardColor(String cardType) {
    switch (cardType) {
      case 'feeding':
        return const Color(0xFF4FC3F7); // Light Blue
      case 'sleep':
        return const Color(0xFF9C27B0); // Purple
      case 'diaper':
        return const Color(0xFFFFB74D); // Orange
      case 'solid_food':
        return const Color(0xFF66BB6A); // Green
      case 'medication':
        return const Color(0xFFEF5350); // Red
      case 'milk_pumping':
        return const Color(0xFF42A5F5); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

/// 편집 중인 카드 설정 아이템
class CardSettingItem {
  final String cardType;
  final bool isVisible;
  final int displayOrder;
  final IconData iconData;
  final String name;
  final Map<String, dynamic> customSettings;
  
  const CardSettingItem({
    required this.cardType,
    required this.isVisible,
    required this.displayOrder,
    required this.iconData,
    required this.name,
    required this.customSettings,
  });
  
  CardSettingItem copyWith({
    String? cardType,
    bool? isVisible,
    int? displayOrder,
    IconData? iconData,
    String? name,
    Map<String, dynamic>? customSettings,
  }) {
    return CardSettingItem(
      cardType: cardType ?? this.cardType,
      isVisible: isVisible ?? this.isVisible,
      displayOrder: displayOrder ?? this.displayOrder,
      iconData: iconData ?? this.iconData,
      name: name ?? this.name,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}