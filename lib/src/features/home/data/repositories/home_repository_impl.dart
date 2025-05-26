import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../core/config/supabase_config.dart';

class HomeRepositoryImpl implements HomeRepository {
  final _supabase = SupabaseConfig.client;

  @override
  Future<Map<String, dynamic>> getFeedingSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 오늘 수유 기록 조회
      final response = await _supabase
          .from('feedings')
          .select('started_at, amount_ml')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDay.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalAmount = 0;
      DateTime? lastFeedingTime;
      int? lastFeedingMinutesAgo;
      
      if (response.isNotEmpty) {
        // 총 수유량 계산
        for (var feeding in response) {
          if (feeding['amount_ml'] != null) {
            totalAmount += feeding['amount_ml'] as int;
          }
        }
        
        // 최근 수유 시간 계산
        final lastFeeding = response.first;
        lastFeedingTime = DateTime.parse(lastFeeding['started_at']);
        lastFeedingMinutesAgo = now.difference(lastFeedingTime).inMinutes;
      }
      
      return {
        'count': count,
        'totalAmount': totalAmount,
        'lastFeedingTime': lastFeedingTime,
        'lastFeedingMinutesAgo': lastFeedingMinutesAgo,
      };
    } catch (e) {
      print('Error getting feeding summary: $e');
      return {
        'count': 0,
        'totalAmount': 0,
        'lastFeedingTime': null,
        'lastFeedingMinutesAgo': null,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getSleepSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 오늘 수면 기록 조회
      final response = await _supabase
          .from('sleeps')
          .select('started_at, ended_at, duration_minutes')
          .eq('baby_id', babyId)
          .gte('started_at', startOfDay.toIso8601String())
          .order('started_at', ascending: false);
      
      int count = response.length;
      int totalMinutes = 0;
      
      for (var sleep in response) {
        if (sleep['duration_minutes'] != null) {
          totalMinutes += sleep['duration_minutes'] as int;
        }
      }
      
      return {
        'count': count,
        'totalMinutes': totalMinutes,
        'totalHours': totalMinutes ~/ 60,
        'remainingMinutes': totalMinutes % 60,
      };
    } catch (e) {
      print('Error getting sleep summary: $e');
      return {
        'count': 0,
        'totalMinutes': 0,
        'totalHours': 0,
        'remainingMinutes': 0,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getDiaperSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 오늘 기저귀 교체 기록 조회
      final response = await _supabase
          .from('diapers')
          .select('type')
          .eq('baby_id', babyId)
          .gte('changed_at', startOfDay.toIso8601String());
      
      int totalCount = response.length;
      int wetCount = 0;
      int dirtyCount = 0;
      int bothCount = 0;
      
      for (var diaper in response) {
        final type = diaper['type'] as String;
        switch (type) {
          case 'wet':
            wetCount++;
            break;
          case 'dirty':
            dirtyCount++;
            break;
          case 'both':
            bothCount++;
            break;
        }
      }
      
      return {
        'totalCount': totalCount,
        'wetCount': wetCount,
        'dirtyCount': dirtyCount,
        'bothCount': bothCount,
      };
    } catch (e) {
      print('Error getting diaper summary: $e');
      return {
        'totalCount': 0,
        'wetCount': 0,
        'dirtyCount': 0,
        'bothCount': 0,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getTemperatureSummary(String babyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 오늘 체온 기록 조회
      final response = await _supabase
          .from('health_records')
          .select('temperature, recorded_at')
          .eq('baby_id', babyId)
          .eq('type', 'temperature')
          .gte('recorded_at', startOfDay.toIso8601String())
          .not('temperature', 'is', null)
          .order('recorded_at', ascending: false);
      
      if (response.isEmpty) {
        return {
          'latestTemperature': 0.0,
          'minTemperature': 0.0,
          'maxTemperature': 0.0,
          'avgTemperature': 0.0,
          'count': 0,
          'latestRecordTime': null,
          'lastMeasurement': null,
          'status': null,
        };
      }
      
      // 온도 데이터 파싱 및 통계 계산
      List<double> temperatures = [];
      for (var record in response) {
        final temp = _parseDouble(record['temperature']);
        if (temp != null) {
          temperatures.add(temp);
        }
      }
      
      if (temperatures.isEmpty) {
        return {
          'latestTemperature': 0.0,
          'minTemperature': 0.0,
          'maxTemperature': 0.0,
          'avgTemperature': 0.0,
          'count': 0,
          'latestRecordTime': null,
          'lastMeasurement': null,
          'status': null,
        };
      }
      
      final latestTemperature = temperatures.first;
      final minTemperature = temperatures.reduce((a, b) => a < b ? a : b);
      final maxTemperature = temperatures.reduce((a, b) => a > b ? a : b);
      final avgTemperature = temperatures.reduce((a, b) => a + b) / temperatures.length;
      final latestRecordTime = DateTime.parse(response.first['recorded_at']);
      
      // 체온 상태 판단
      String status;
      if (latestTemperature < 36.0) {
        status = 'low';
      } else if (latestTemperature <= 37.5) {
        status = 'normal';
      } else {
        status = 'high';
      }
      
      return {
        'latestTemperature': latestTemperature,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'avgTemperature': avgTemperature,
        'count': temperatures.length,
        'latestRecordTime': latestRecordTime,
        'lastMeasurement': latestRecordTime.toIso8601String(),
        'status': status,
      };
    } catch (e) {
      print('Error getting temperature summary: $e');
      return {
        'latestTemperature': 0.0,
        'minTemperature': 0.0,
        'maxTemperature': 0.0,
        'avgTemperature': 0.0,
        'count': 0,
        'latestRecordTime': null,
        'lastMeasurement': null,
        'status': null,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getGrowthSummary(String babyId) async {
    try {
      // 최근 성장 기록 2개 조회 (현재와 이전 비교용)
      final response = await _supabase
          .from('growth_records')
          .select('weight_kg, height_cm, recorded_at')
          .eq('baby_id', babyId)
          .order('recorded_at', ascending: false)
          .limit(2);
      
      if (response.isEmpty) {
        return {
          'currentWeight': null,
          'currentHeight': null,
          'previousWeight': null,
          'previousHeight': null,
          'weightChange': null,
          'heightChange': null,
          'lastRecordDate': null,
        };
      }
      
      final current = response.first;
      final currentWeight = _parseDouble(current['weight_kg']);
      final currentHeight = _parseDouble(current['height_cm']);
      final lastRecordDate = DateTime.parse(current['recorded_at']);
      
      double? weightChange;
      double? heightChange;
      double? previousWeight;
      double? previousHeight;
      
      if (response.length > 1) {
        final previous = response[1];
        previousWeight = _parseDouble(previous['weight_kg']);
        previousHeight = _parseDouble(previous['height_cm']);
        
        if (currentWeight != null && previousWeight != null) {
          weightChange = currentWeight - previousWeight;
        }
        if (currentHeight != null && previousHeight != null) {
          heightChange = currentHeight - previousHeight;
        }
      }
      
      return {
        'latestWeight': currentWeight ?? 0.0,  // 위젯이 기대하는 키로 변경
        'latestHeight': currentHeight ?? 0.0, // 위젯이 기대하는 키로 변경
        'currentWeight': currentWeight,
        'currentHeight': currentHeight,
        'previousWeight': previousWeight,
        'previousHeight': previousHeight,
        'weightChange': weightChange ?? 0.0,
        'heightChange': heightChange ?? 0.0,
        'lastMeasurement': lastRecordDate.toIso8601String(), // 위젯이 기대하는 키로 변경
        'lastRecordDate': lastRecordDate,
      };
    } catch (e) {
      print('Error getting growth summary: $e');
      return {
        'currentWeight': null,
        'currentHeight': null,
        'previousWeight': null,
        'previousHeight': null,
        'weightChange': null,
        'heightChange': null,
        'lastRecordDate': null,
      };
    }
  }
  
  // 문자열을 double로 안전하게 파싱하는 헬퍼 함수
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing double from string: $value');
        return null;
      }
    }
    return null;
  }
}