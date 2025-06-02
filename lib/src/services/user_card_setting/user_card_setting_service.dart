import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/user_card_setting.dart';
import '../../core/config/supabase_config.dart';

class UserCardSettingService {
  static UserCardSettingService? _instance;
  static UserCardSettingService get instance => _instance ??= UserCardSettingService._();
  
  UserCardSettingService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _defaultVisibilityKey = 'card_default_visibility';
  static const String _defaultOrderKey = 'card_default_order';
  
  /// 기본 카드 설정 저장
  Future<void> saveCardDefaults({
    bool? isVisible,
    int? displayOrder,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (isVisible != null) {
      await prefs.setBool(_defaultVisibilityKey, isVisible);
    }
    if (displayOrder != null) {
      await prefs.setInt(_defaultOrderKey, displayOrder);
    }
  }
  
  /// 기본 카드 설정 불러오기
  Future<Map<String, dynamic>> getCardDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'isVisible': prefs.getBool(_defaultVisibilityKey) ?? true,
      'displayOrder': prefs.getInt(_defaultOrderKey) ?? 0,
    };
  }
  
  /// 새로운 카드 설정 추가
  Future<UserCardSetting?> addUserCardSetting({
    required String userId,
    required String babyId,
    required String cardType,
    bool? isVisible,
    int? displayOrder,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      // 기본값이 설정되지 않은 경우 저장된 기본값 사용
      final defaults = await getCardDefaults();
      
      final cardSettingData = {
        'id': _uuid.v4(),
        'user_id': userId,
        'card_type': cardType, // baby_id 제거 (테이블에 없는 컬럼)
        'is_visible': isVisible ?? defaults['isVisible'],
        'display_order': displayOrder ?? defaults['displayOrder'],
        // customSettings 필드는 현재 데이터베이스에 없으므로 임시로 제외
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('user_card_settings')
          .insert(cardSettingData)
          .select()
          .single();
      
      return UserCardSetting.fromJson(response);
    } catch (e) {
      debugPrint('Error adding user card setting: $e');
      return null;
    }
  }
  
  /// 사용자의 모든 카드 설정 가져오기
  Future<List<UserCardSetting>> getUserCardSettings(String userId) async {
    debugPrint('🗃️ [SERVICE] Starting getUserCardSettings for user: $userId');
    
    try {
      debugPrint('🗃️ [SERVICE] Executing Supabase query...');
      final response = await _supabase
          .from('user_card_settings')
          .select('*')
          .eq('user_id', userId)
          .order('display_order', ascending: true);
      
      debugPrint('🗃️ [SERVICE] Query completed, processing ${response.length} records');
      
      final result = response.map((json) => UserCardSetting.fromJson(json)).toList();
      debugPrint('✅ [SERVICE] Successfully processed ${result.length} user card settings');
      
      return result;
    } catch (e) {
      debugPrint('❌ [SERVICE] Error getting user card settings: $e');
      debugPrint('❌ [SERVICE] Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  /// 특정 카드 타입의 설정 가져오기
  Future<UserCardSetting?> getCardSettingByType(String userId, String cardType) async {
    try {
      final response = await _supabase
          .from('user_card_settings')
          .select('*')
          .eq('user_id', userId)
          .eq('card_type', cardType)
          .maybeSingle();
      
      if (response != null) {
        return UserCardSetting.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting card setting by type: $e');
      return null;
    }
  }
  
  /// 오늘의 카드 설정 요약 정보 가져오기 (표시 여부별 카운트)
  Future<Map<String, dynamic>> getTodayCardSettingSummary(String userId) async {
    try {
      final response = await _supabase
          .from('user_card_settings')
          .select('card_type, is_visible, display_order')
          .eq('user_id', userId);
      
      int totalCards = response.length;
      int visibleCards = 0;
      int hiddenCards = 0;
      Map<String, bool> cardVisibility = {};
      List<String> visibleCardTypes = [];
      List<String> hiddenCardTypes = [];
      
      for (var setting in response) {
        final cardType = setting['card_type'] as String;
        final isVisible = setting['is_visible'] as bool;
        
        cardVisibility[cardType] = isVisible;
        
        if (isVisible) {
          visibleCards++;
          visibleCardTypes.add(cardType);
        } else {
          hiddenCards++;
          hiddenCardTypes.add(cardType);
        }
      }
      
      return {
        'totalCards': totalCards,
        'visibleCards': visibleCards,
        'hiddenCards': hiddenCards,
        'cardVisibility': cardVisibility,
        'visibleCardTypes': visibleCardTypes,
        'hiddenCardTypes': hiddenCardTypes,
        'visibilityRatio': totalCards > 0 ? visibleCards / totalCards : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting today card setting summary: $e');
      return {
        'totalCards': 0,
        'visibleCards': 0,
        'hiddenCards': 0,
        'cardVisibility': {},
        'visibleCardTypes': [],
        'hiddenCardTypes': [],
        'visibilityRatio': 0.0,
      };
    }
  }
  
  /// 카드 설정 삭제
  Future<bool> deleteUserCardSetting(String cardSettingId) async {
    try {
      await _supabase
          .from('user_card_settings')
          .delete()
          .eq('id', cardSettingId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting user card setting: $e');
      return false;
    }
  }
  
  /// 카드 타입별 설정 삭제
  Future<bool> deleteCardSettingByType(String userId, String cardType) async {
    try {
      await _supabase
          .from('user_card_settings')
          .delete()
          .eq('user_id', userId)
          .eq('card_type', cardType);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting card setting by type: $e');
      return false;
    }
  }
  
  /// 카드 설정 수정
  Future<UserCardSetting?> updateUserCardSetting({
    required String cardSettingId,
    String? cardType,
    bool? isVisible,
    int? displayOrder,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (cardType != null) updateData['card_type'] = cardType;
      if (isVisible != null) updateData['is_visible'] = isVisible;
      if (displayOrder != null) updateData['display_order'] = displayOrder;
      // customSettings 필드는 현재 데이터베이스에 없으므로 임시로 제외
      // if (customSettings != null) updateData['custom_settings'] = customSettings;
      
      final response = await _supabase
          .from('user_card_settings')
          .update(updateData)
          .eq('id', cardSettingId)
          .select()
          .single();
      
      return UserCardSetting.fromJson(response);
    } catch (e) {
      debugPrint('Error updating user card setting: $e');
      return null;
    }
  }
  
  /// 카드 타입별 설정 업데이트 (없으면 생성)
  Future<UserCardSetting?> upsertCardSetting({
    required String userId,
    required String babyId,
    required String cardType,
    bool? isVisible,
    int? displayOrder,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      // 기존 설정이 있는지 확인
      final existingSetting = await getCardSettingByType(userId, cardType);
      
      if (existingSetting != null) {
        // 기존 설정 업데이트
        return await updateUserCardSetting(
          cardSettingId: existingSetting.id,
          isVisible: isVisible,
          displayOrder: displayOrder,
          customSettings: customSettings,
        );
      } else {
        // 새 설정 생성
        return await addUserCardSetting(
          userId: userId,
          babyId: babyId,
          cardType: cardType,
          isVisible: isVisible,
          displayOrder: displayOrder,
          customSettings: customSettings,
        );
      }
    } catch (e) {
      debugPrint('Error upserting card setting: $e');
      return null;
    }
  }
  
  /// 카드 순서 재정렬
  Future<bool> reorderCards(String userId, List<String> cardTypeOrder) async {
    try {
      final batch = <Future>[];
      
      for (int i = 0; i < cardTypeOrder.length; i++) {
        final cardType = cardTypeOrder[i];
        
        final future = _supabase
            .from('user_card_settings')
            .update({
              'display_order': i,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('card_type', cardType);
        
        batch.add(future);
      }
      
      await Future.wait(batch);
      return true;
    } catch (e) {
      debugPrint('Error reordering cards: $e');
      return false;
    }
  }
  
  /// 카드 표시/숨김 토글
  Future<UserCardSetting?> toggleCardVisibility(String userId, String babyId, String cardType) async {
    try {
      final existingSetting = await getCardSettingByType(userId, cardType);
      
      if (existingSetting != null) {
        return await updateUserCardSetting(
          cardSettingId: existingSetting.id,
          isVisible: !existingSetting.isVisible,
        );
      } else {
        // 설정이 없으면 기본값으로 생성 (숨김 상태로)
        return await addUserCardSetting(
          userId: userId,
          babyId: babyId,
          cardType: cardType,
          isVisible: false,
        );
      }
    } catch (e) {
      debugPrint('Error toggling card visibility: $e');
      return null;
    }
  }
  
  /// 기본 카드 설정 초기화 (주요 카드 타입들의 기본 설정 생성)
  Future<bool> initializeDefaultCardSettings(String userId, String babyId) async {
    try {
      final defaultCardTypes = [
        'feeding',
        'sleep',
        'diaper',
        'solid_food',
        'medication',
        'milk_pumping',
      ];
      
      final batch = <Future>[];
      
      for (int i = 0; i < defaultCardTypes.length; i++) {
        final cardType = defaultCardTypes[i];
        
        // 기존 설정이 있는지 확인
        final existingSetting = await getCardSettingByType(userId, cardType);
        
        if (existingSetting == null) {
          // 기존 설정이 없으면 기본 설정 생성
          final future = addUserCardSetting(
            userId: userId,
            babyId: babyId,
            cardType: cardType,
            isVisible: true,
            displayOrder: i,
          );
          
          batch.add(future);
        }
      }
      
      await Future.wait(batch);
      return true;
    } catch (e) {
      debugPrint('Error initializing default card settings: $e');
      return false;
    }
  }
  
  /// 사용자의 모든 카드 설정 초기화 (기본 설정으로 복원)
  Future<bool> resetUserCardSettings(String userId, String babyId) async {
    try {
      // 기존 설정 모두 삭제
      await _supabase
          .from('user_card_settings')
          .delete()
          .eq('user_id', userId);
      
      // 기본 설정으로 다시 초기화
      return await initializeDefaultCardSettings(userId, babyId);
    } catch (e) {
      debugPrint('Error resetting user card settings: $e');
      return false;
    }
  }
  
  /// 사용자의 카드 사용 패턴 분석
  Future<Map<String, dynamic>> getCardUsagePattern(String userId) async {
    try {
      final response = await _supabase
          .from('user_card_settings')
          .select('card_type, is_visible, updated_at')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      
      if (response.isEmpty) {
        return {
          'totalSettings': 0,
          'activeCards': 0,
          'inactiveCards': 0,
          'mostRecentlyUpdated': null,
          'customizedCards': 0,
          'utilizationRate': 0.0,
        };
      }
      
      int totalSettings = response.length;
      int activeCards = 0;
      int customizedCards = 0; // 현재 사용하지 않음
      String? mostRecentlyUpdated;
      DateTime? latestUpdate;
      
      for (var setting in response) {
        if (setting['is_visible'] as bool) {
          activeCards++;
        }
        
        // custom_settings 필드가 없으므로 customizedCards는 0으로 유지
        
        final updatedAt = DateTime.parse(setting['updated_at']);
        if (latestUpdate == null || updatedAt.isAfter(latestUpdate)) {
          latestUpdate = updatedAt;
          mostRecentlyUpdated = setting['card_type'];
        }
      }
      
      return {
        'totalSettings': totalSettings,
        'activeCards': activeCards,
        'inactiveCards': totalSettings - activeCards,
        'mostRecentlyUpdated': mostRecentlyUpdated,
        'mostRecentUpdate': latestUpdate?.toIso8601String(),
        'customizedCards': customizedCards,
        'utilizationRate': totalSettings > 0 ? activeCards / totalSettings : 0.0,
        'customizationRate': totalSettings > 0 ? customizedCards / totalSettings : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting card usage pattern: $e');
      return {
        'totalSettings': 0,
        'activeCards': 0,
        'inactiveCards': 0,
        'mostRecentlyUpdated': null,
        'mostRecentUpdate': null,
        'customizedCards': 0,
        'utilizationRate': 0.0,
        'customizationRate': 0.0,
      };
    }
  }
}