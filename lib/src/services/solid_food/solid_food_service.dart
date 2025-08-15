import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/solid_food.dart';
import '../../domain/models/timeline_item.dart';
import '../../core/config/supabase_config.dart';
import '../../core/mixins/data_sync_mixin.dart';
import '../../core/events/data_sync_events.dart';

class SolidFoodService with DataSyncMixin {
  static SolidFoodService? _instance;
  static SolidFoodService get instance => _instance ??= SolidFoodService._();
  
  SolidFoodService._();
  
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();
  
  // SharedPreferences 키
  static const String _foodNameKey = 'solid_food_default_name';
  static const String _amountKey = 'solid_food_default_amount';
  static const String _allergicReactionKey = 'solid_food_default_allergic_reaction';
  
  /// 기본 이유식 설정 저장
  Future<void> saveSolidFoodDefaults({
    String? foodName,
    int? amountGrams,
    String? allergicReaction,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (foodName != null) {
      await prefs.setString(_foodNameKey, foodName);
    }
    if (amountGrams != null) {
      await prefs.setInt(_amountKey, amountGrams);
    }
    if (allergicReaction != null) {
      await prefs.setString(_allergicReactionKey, allergicReaction);
    }
  }
  
  /// 기본 이유식 설정 불러오기
  Future<Map<String, dynamic>> getSolidFoodDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'foodName': prefs.getString(_foodNameKey) ?? '미음',
      'amountGrams': prefs.getInt(_amountKey) ?? 50,
      'allergicReaction': prefs.getString(_allergicReactionKey) ?? 'none',
    };
  }
  
  /// 새로운 이유식 기록 추가
  Future<SolidFood?> addSolidFood({
    required String babyId,
    required String userId,
    String? foodName,
    int? amountGrams,
    String? allergicReaction,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    final solidFoodStartTime = startedAt ?? DateTime.now();
    
    return await withDataSyncEvent(
      operation: () async {
        // 기본값이 설정되지 않은 경우 저장된 기본값 사용
        final defaults = await getSolidFoodDefaults();
        
        final solidFoodData = {
          'id': _uuid.v4(),
          'baby_id': babyId,
          'user_id': userId,
          'food_name': foodName ?? defaults['foodName'],
          'amount': amountGrams ?? defaults['amountGrams'],
          'reaction': allergicReaction ?? defaults['allergicReaction'],
          'notes': notes,
          'started_at': solidFoodStartTime.toUtc().toIso8601String(),
          'ended_at': endedAt?.toUtc().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('solid_foods')
            .insert(solidFoodData)
            .select()
            .single();
        
        return SolidFood.fromJson(response);
      },
      itemType: TimelineItemType.solidFood,
      babyId: babyId,
      timestamp: solidFoodStartTime,
      action: DataSyncAction.created,
    );
  }
  
  /// 오늘의 이유식 요약 정보 가져오기
  Future<Map<String, dynamic>> getTodaySolidFoodSummary(String babyId) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final now = DateTime.now();
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('solid_foods')
          .select('started_at, food_name, amount, reaction')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalAmount = 0;
      DateTime? lastFeedingTime;
      int? lastFeedingMinutesAgo;
      Map<String, int> foodTypeCount = {};
      Map<String, int> allergicReactionCount = {
        'none': 0,
        'mild': 0,
        'moderate': 0,
        'severe': 0,
      };
      
      if (response.isNotEmpty) {
        // 총 섭취량 및 음식별, 알레르기 반응별 계산
        for (var food in response) {
          // 총 양 계산 (정수로 저장됨)
          final amount = food['amount'] as int?;
          if (amount != null) {
            totalAmount += amount;
          }
          
          final foodName = food['food_name'] as String;
          foodTypeCount[foodName] = (foodTypeCount[foodName] ?? 0) + 1;
          
          final allergicReaction = food['reaction'] as String?;
          if (allergicReaction != null && allergicReactionCount.containsKey(allergicReaction)) {
            allergicReactionCount[allergicReaction] = allergicReactionCount[allergicReaction]! + 1;
          }
        }
        
        // 최근 이유식 시간 계산
        final lastFood = response.first;
        lastFeedingTime = DateTime.parse(lastFood['started_at']).toLocal();
        lastFeedingMinutesAgo = now.difference(lastFeedingTime).inMinutes;
      }
      
      return {
        'count': count,
        'totalAmount': totalAmount,
        'lastFeedingTime': lastFeedingTime,
        'lastFeedingMinutesAgo': lastFeedingMinutesAgo,
        'foodTypeCount': foodTypeCount,
        'allergicReactionCount': allergicReactionCount,
        'averageAmount': count > 0 ? (totalAmount / count).round() : 0,
      };
    } catch (e) {
      debugPrint('Error getting today solid food summary: $e');
      return {
        'count': 0,
        'totalAmount': 0,
        'lastFeedingTime': null,
        'lastFeedingMinutesAgo': null,
        'foodTypeCount': {},
        'allergicReactionCount': {
          'none': 0,
          'mild': 0,
          'moderate': 0,
          'severe': 0,
        },
        'averageAmount': 0,
      };
    }
  }
  
  /// 오늘의 이유식 기록 목록 가져오기
  Future<List<SolidFood>> getTodaySolidFoods(String babyId) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final now = DateTime.now();
      final kstOffset = const Duration(hours: 9);
      final nowKst = now.isUtc ? now.add(kstOffset) : now;
      
      // 한국 시간 기준 오늘 자정
      final todayStartKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
      final tomorrowStartKst = todayStartKst.add(const Duration(days: 1));
      
      // UTC로 변환
      final todayStartUtc = todayStartKst.subtract(kstOffset);
      final tomorrowStartUtc = tomorrowStartKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('solid_foods')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', todayStartUtc.toIso8601String())
          .lt('started_at', tomorrowStartUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => SolidFood.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting today solid foods: $e');
      return [];
    }
  }

  /// 특정 날짜의 이유식 기록 목록 가져오기
  Future<List<SolidFood>> getSolidFoodsForDate(String babyId, DateTime date) async {
    try {
      // 한국 시간대 (UTC+9) 명시적 처리
      final kstOffset = const Duration(hours: 9);
      final dateKst = date.isUtc ? date.add(kstOffset) : date;
      
      // 한국 시간 기준 해당 날짜 범위
      final startOfDayKst = DateTime(dateKst.year, dateKst.month, dateKst.day);
      final endOfDayKst = DateTime(dateKst.year, dateKst.month, dateKst.day, 23, 59, 59);
      
      // UTC로 변환
      final startOfDayUtc = startOfDayKst.subtract(kstOffset);
      final endOfDayUtc = endOfDayKst.subtract(kstOffset);
      
      final response = await _supabase
          .from('solid_foods')
          .select('*')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDayUtc.toIso8601String())
          .lte('started_at', endOfDayUtc.toIso8601String())
          .order('started_at', ascending: false);
      
      return response.map((json) => SolidFood.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting solid foods for date: $e');
      return [];
    }
  }
  
  /// 이유식 기록 삭제
  Future<bool> deleteSolidFood(String solidFoodId) async {
    try {
      // 삭제 전 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('solid_foods')
          .select('baby_id, started_at')
          .eq('id', solidFoodId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final startedAt = DateTime.parse(existingResponse['started_at']);
      
      return await withDataSyncEvent(
        operation: () async {
          await _supabase
              .from('solid_foods')
              .delete()
              .eq('id', solidFoodId);
          
          return true;
        },
        itemType: TimelineItemType.solidFood,
        babyId: babyId,
        timestamp: startedAt,
        action: DataSyncAction.deleted,
        recordId: solidFoodId,
      );
    } catch (e) {
      debugPrint('Error deleting solid food: $e');
      return false;
    }
  }
  
  /// 이유식 기록 수정
  Future<SolidFood?> updateSolidFood({
    required String solidFoodId,
    String? foodName,
    int? amountGrams,
    String? allergicReaction,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    try {
      // 기존 데이터 조회 (babyId와 timestamp 정보 필요)
      final existingResponse = await _supabase
          .from('solid_foods')
          .select('baby_id, started_at')
          .eq('id', solidFoodId)
          .single();
      
      final babyId = existingResponse['baby_id'] as String;
      final originalStartedAt = DateTime.parse(existingResponse['started_at']);
      final updateTimestamp = startedAt ?? originalStartedAt;
      
      return await withDataSyncEvent(
        operation: () async {
          final updateData = <String, dynamic>{
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          if (foodName != null) updateData['food_name'] = foodName;
          if (amountGrams != null) updateData['amount_grams'] = amountGrams;
          if (allergicReaction != null) updateData['allergic_reaction'] = allergicReaction;
          if (notes != null) updateData['notes'] = notes;
          if (startedAt != null) updateData['started_at'] = startedAt.toIso8601String();
          if (endedAt != null) updateData['ended_at'] = endedAt.toIso8601String();
          
          final response = await _supabase
              .from('solid_foods')
              .update(updateData)
              .eq('id', solidFoodId)
              .select()
              .single();
          
          return SolidFood.fromJson(response);
        },
        itemType: TimelineItemType.solidFood,
        babyId: babyId,
        timestamp: updateTimestamp,
        action: DataSyncAction.updated,
        recordId: solidFoodId,
      );
    } catch (e) {
      debugPrint('Error updating solid food: $e');
      return null;
    }
  }
  
  /// 최근 일주일간 알레르기 반응 분석
  Future<Map<String, dynamic>> getWeeklyAllergicReactionAnalysis(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(const Duration(days: 7));
      
      final response = await _supabase
          .from('solid_foods')
          .select('food_name, allergic_reaction, started_at')
          .eq('baby_id', babyId)
          .gte('started_at', startOfWeek.toIso8601String())
          .order('started_at', ascending: false);
      
      Map<String, List<String>> foodAllergies = {}; // 음식별 알레르기 반응 목록
      Map<String, int> reactionSeverity = {
        'none': 0,
        'mild': 0,
        'moderate': 0,
        'severe': 0,
      };
      
      for (var food in response) {
        final foodName = food['food_name'] as String;
        final reaction = food['allergic_reaction'] as String? ?? 'none';
        
        if (!foodAllergies.containsKey(foodName)) {
          foodAllergies[foodName] = [];
        }
        foodAllergies[foodName]!.add(reaction);
        
        if (reactionSeverity.containsKey(reaction)) {
          reactionSeverity[reaction] = reactionSeverity[reaction]! + 1;
        }
      }
      
      // 위험한 음식 (moderate 또는 severe 반응이 있는 음식)
      List<String> riskyFoods = [];
      foodAllergies.forEach((food, reactions) {
        if (reactions.any((r) => r == 'moderate' || r == 'severe')) {
          riskyFoods.add(food);
        }
      });
      
      return {
        'totalRecords': response.length,
        'foodAllergies': foodAllergies,
        'reactionSeverity': reactionSeverity,
        'riskyFoods': riskyFoods,
        'safetyScore': reactionSeverity['none']! / 
            (response.isEmpty ? 1 : response.length), // 안전한 비율
      };
    } catch (e) {
      debugPrint('Error getting weekly allergic reaction analysis: $e');
      return {
        'totalRecords': 0,
        'foodAllergies': {},
        'reactionSeverity': {
          'none': 0,
          'mild': 0,
          'moderate': 0,
          'severe': 0,
        },
        'riskyFoods': [],
        'safetyScore': 1.0,
      };
    }
  }
}