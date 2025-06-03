import 'package:flutter/foundation.dart';
import '../../domain/models/timeline_item.dart';
import '../../domain/models/feeding.dart';
import '../../domain/models/sleep.dart';
import '../../domain/models/diaper.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/milk_pumping.dart';
import '../../domain/models/solid_food.dart';
import '../../domain/models/health_record.dart';
import '../feeding/feeding_service.dart';
import '../sleep/sleep_service.dart';
import '../diaper/diaper_service.dart';
import '../medication/medication_service.dart';
import '../milk_pumping/milk_pumping_service.dart';
import '../solid_food/solid_food_service.dart';
import '../health/health_service.dart';

class TimelineService {
  static TimelineService? _instance;
  static TimelineService get instance => _instance ??= TimelineService._();
  TimelineService._();

  // 특정 날짜의 모든 타임라인 아이템 가져오기
  Future<List<TimelineItem>> getTimelineItemsForDate(
    String babyId,
    DateTime date,
  ) async {
    try {
      debugPrint('📅 [TIMELINE] Getting timeline items for date: ${date.toIso8601String()}');
      
      final List<TimelineItem> allItems = [];

      // 모든 서비스에서 데이터를 병렬로 가져오기
      final results = await Future.wait([
        _getFeedingItems(babyId, date),
        _getSleepItems(babyId, date),
        _getDiaperItems(babyId, date),
        _getMedicationItems(babyId, date),
        _getMilkPumpingItems(babyId, date),
        _getSolidFoodItems(babyId, date),
        _getTemperatureItems(babyId, date),
      ]);

      // 모든 아이템들을 하나의 리스트로 합치기
      for (final items in results) {
        allItems.addAll(items);
      }

      // 시간순으로 정렬 (최신 순)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('📅 [TIMELINE] Found ${allItems.length} timeline items');
      return allItems;
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting timeline items: $e');
      return [];
    }
  }

  // 수유 아이템 변환
  Future<List<TimelineItem>> _getFeedingItems(String babyId, DateTime date) async {
    try {
      final feedings = await FeedingService.instance.getFeedingsForDate(babyId, date);
      return feedings.map((feeding) => _convertFeedingToTimelineItem(feeding)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting feeding items: $e');
      return [];
    }
  }

  // 수면 아이템 변환
  Future<List<TimelineItem>> _getSleepItems(String babyId, DateTime date) async {
    try {
      final sleeps = await SleepService.instance.getSleepsForDate(babyId, date);
      return sleeps.map((sleep) => _convertSleepToTimelineItem(sleep)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting sleep items: $e');
      return [];
    }
  }

  // 기저귀 아이템 변환
  Future<List<TimelineItem>> _getDiaperItems(String babyId, DateTime date) async {
    try {
      final diapers = await DiaperService.instance.getDiapersForDate(babyId, date);
      return diapers.map((diaper) => _convertDiaperToTimelineItem(diaper)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting diaper items: $e');
      return [];
    }
  }

  // 투약 아이템 변환
  Future<List<TimelineItem>> _getMedicationItems(String babyId, DateTime date) async {
    try {
      final medications = await MedicationService.instance.getMedicationsForDate(babyId, date);
      return medications.map((medication) => _convertMedicationToTimelineItem(medication)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting medication items: $e');
      return [];
    }
  }

  // 유축 아이템 변환
  Future<List<TimelineItem>> _getMilkPumpingItems(String babyId, DateTime date) async {
    try {
      final milkPumpings = await MilkPumpingService.instance.getMilkPumpingsForDate(babyId, date);
      return milkPumpings.map((milkPumping) => _convertMilkPumpingToTimelineItem(milkPumping)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting milk pumping items: $e');
      return [];
    }
  }

  // 이유식 아이템 변환
  Future<List<TimelineItem>> _getSolidFoodItems(String babyId, DateTime date) async {
    try {
      final solidFoods = await SolidFoodService.instance.getSolidFoodsForDate(babyId, date);
      return solidFoods.map((solidFood) => _convertSolidFoodToTimelineItem(solidFood)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting solid food items: $e');
      return [];
    }
  }

  // 체온 아이템 변환
  Future<List<TimelineItem>> _getTemperatureItems(String babyId, DateTime date) async {
    try {
      final healthRecords = await HealthService.instance.getHealthRecordsForDate(babyId, date);
      return healthRecords.map((health) => _convertHealthToTimelineItem(health)).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting temperature items: $e');
      return [];
    }
  }

  // 변환 메서드들
  TimelineItem _convertFeedingToTimelineItem(Feeding feeding) {
    String subtitle = '';
    if (feeding.type == 'bottle' || feeding.type == 'formula') {
      subtitle = '분유';
      if (feeding.amountMl != null && feeding.amountMl! > 0) {
        subtitle += ' ${feeding.amountMl}ml';
      }
    } else if (feeding.type == 'breast') {
      subtitle = '모유';
      if (feeding.durationMinutes != null && feeding.durationMinutes! > 0) {
        subtitle += ' ${feeding.durationMinutes}분';
      }
      if (feeding.side != null) {
        final sideText = feeding.side == 'left' ? '왼쪽' : 
                        feeding.side == 'right' ? '오른쪽' : '양쪽';
        subtitle += ' ($sideText)';
      }
    } else if (feeding.type == 'solid') {
      subtitle = '이유식';
      if (feeding.amountMl != null && feeding.amountMl! > 0) {
        subtitle += ' ${feeding.amountMl}ml';
      }
    }

    return TimelineItem(
      id: feeding.id,
      type: TimelineItemType.feeding,
      timestamp: feeding.startedAt,
      title: '수유',
      subtitle: subtitle,
      data: feeding.toJson(),
      colorCode: '#2196F3', // 파란색
    );
  }

  TimelineItem _convertSleepToTimelineItem(Sleep sleep) {
    String subtitle;
    bool isOngoing = false;

    if (sleep.endedAt == null) {
      // 진행 중인 수면
      final now = DateTime.now();
      final duration = now.difference(sleep.startedAt);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      subtitle = '수면 중 - ${hours}시간 ${minutes}분 경과';
      isOngoing = true;
    } else {
      // 완료된 수면
      final duration = sleep.endedAt!.difference(sleep.startedAt);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      subtitle = '${hours}시간 ${minutes}분';
      
      // 수면 품질 추가
      if (sleep.quality != null) {
        final qualityText = sleep.quality == 'good' ? '좋음' :
                           sleep.quality == 'fair' ? '보통' : '나쁨';
        subtitle += ' (품질: $qualityText)';
      }
    }

    return TimelineItem(
      id: sleep.id,
      type: TimelineItemType.sleep,
      timestamp: sleep.startedAt,
      title: isOngoing ? '수면 중' : '수면',
      subtitle: subtitle,
      data: sleep.toJson(),
      isOngoing: isOngoing,
      colorCode: '#9C27B0', // 보라색
    );
  }

  TimelineItem _convertDiaperToTimelineItem(Diaper diaper) {
    String subtitle = '';
    if (diaper.type == 'wet') {
      subtitle = '소변만';
    } else if (diaper.type == 'dirty') {
      subtitle = '대변만';
      // 색상과 농도 정보 추가
      if (diaper.color != null && diaper.color!.isNotEmpty) {
        subtitle += ' (색상: ${diaper.color})';
      }
      if (diaper.consistency != null && diaper.consistency!.isNotEmpty) {
        subtitle += ' (농도: ${diaper.consistency})';
      }
    } else if (diaper.type == 'both') {
      subtitle = '소변 + 대변';
      if (diaper.color != null && diaper.color!.isNotEmpty) {
        subtitle += ' (색상: ${diaper.color})';
      }
    }

    return TimelineItem(
      id: diaper.id,
      type: TimelineItemType.diaper,
      timestamp: diaper.changedAt,
      title: '기저귀 교체',
      subtitle: subtitle,
      data: diaper.toJson(),
      colorCode: '#FF9800', // 주황색
    );
  }

  TimelineItem _convertMedicationToTimelineItem(Medication medication) {
    String subtitle = '';
    if (medication.route == 'oral') {
      subtitle = '경구 투약';
    } else if (medication.route == 'topical') {
      subtitle = '외용';
    } else if (medication.route == 'inhaled') {
      subtitle = '흡입';
    } else {
      subtitle = '투약';
    }

    if (medication.medicationName.isNotEmpty) {
      subtitle += ' - ${medication.medicationName}';
    }

    if (medication.dosage.isNotEmpty) {
      subtitle += ' ${medication.dosage}';
      if (medication.unit != null && medication.unit!.isNotEmpty) {
        subtitle += medication.unit!;
      }
    }

    return TimelineItem(
      id: medication.id,
      type: TimelineItemType.medication,
      timestamp: medication.administeredAt,
      title: '투약',
      subtitle: subtitle,
      data: medication.toJson(),
      colorCode: '#E91E63', // 핑크색
    );
  }

  TimelineItem _convertMilkPumpingToTimelineItem(MilkPumping milkPumping) {
    String subtitle = '';
    bool isOngoing = false;
    
    // 진행 중인 유축인지 확인
    if (milkPumping.endedAt == null) {
      final now = DateTime.now();
      final duration = now.difference(milkPumping.startedAt);
      subtitle = '유축 중 - ${duration.inMinutes}분 경과';
      isOngoing = true;
    } else {
      // 완료된 유축
      if (milkPumping.amountMl != null && milkPumping.amountMl! > 0) {
        subtitle = '${milkPumping.amountMl}ml';
      }
      if (milkPumping.durationMinutes != null && milkPumping.durationMinutes! > 0) {
        if (subtitle.isNotEmpty) subtitle += ', ';
        subtitle += '${milkPumping.durationMinutes}분';
      }
      
      // 위치 정보 추가
      if (milkPumping.side != null) {
        final sideText = milkPumping.side == 'left' ? '왼쪽' :
                        milkPumping.side == 'right' ? '오른쪽' : '양쪽';
        if (subtitle.isNotEmpty) subtitle += ' ';
        subtitle += '($sideText)';
      }
    }

    return TimelineItem(
      id: milkPumping.id,
      type: TimelineItemType.milkPumping,
      timestamp: milkPumping.startedAt,
      title: isOngoing ? '유축 중' : '유축',
      subtitle: subtitle,
      data: milkPumping.toJson(),
      isOngoing: isOngoing,
      colorCode: '#009688', // 청록색
    );
  }

  TimelineItem _convertSolidFoodToTimelineItem(SolidFood solidFood) {
    String subtitle = '';
    if (solidFood.foodName.isNotEmpty) {
      subtitle = solidFood.foodName;
    }
    if (solidFood.amountGrams != null && solidFood.amountGrams! > 0) {
      if (subtitle.isNotEmpty) subtitle += ' - ';
      subtitle += '${solidFood.amountGrams}g';
    }

    return TimelineItem(
      id: solidFood.id,
      type: TimelineItemType.solidFood,
      timestamp: solidFood.startedAt,
      title: '이유식',
      subtitle: subtitle,
      data: solidFood.toJson(),
      colorCode: '#4CAF50', // 녹색
    );
  }

  TimelineItem _convertHealthToTimelineItem(HealthRecord health) {
    String subtitle = '';
    
    if (health.temperature != null) {
      subtitle = '${health.temperature!.toStringAsFixed(1)}°C';
      
      // 온도 상태 판단
      String status = '';
      if (health.temperature! >= 38.0) {
        status = ' (발열)';
      } else if (health.temperature! >= 37.5) {
        status = ' (미열)';
      } else if (health.temperature! < 36.0) {
        status = ' (저체온)';
      } else {
        status = ' (정상)';
      }
      subtitle += status;
    } else {
      subtitle = health.type;
    }

    return TimelineItem(
      id: health.id,
      type: TimelineItemType.temperature,
      timestamp: health.recordedAt,
      title: '체온 측정',
      subtitle: subtitle,
      data: health.toJson(),
      colorCode: '#FF5722', // 주황-빨강색
    );
  }

  // 필터링
  List<TimelineItem> filterItems(
    List<TimelineItem> items,
    TimelineFilterType filterType,
  ) {
    if (filterType == TimelineFilterType.all) {
      return items;
    }

    final targetType = filterType.itemType;
    if (targetType == null) return items;

    return items.where((item) => item.type == targetType).toList();
  }

  // 진행 중인 아이템들 가져오기 (수면 등)
  Future<List<TimelineItem>> getOngoingItems(String babyId) async {
    try {
      final items = await getTimelineItemsForDate(babyId, DateTime.now());
      return items.where((item) => item.isOngoing).toList();
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error getting ongoing items: $e');
      return [];
    }
  }
}