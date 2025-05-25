import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../core/config/supabase_config.dart';

class HomeRepositoryImpl implements HomeRepository {
  final _supabase = SupabaseConfig.client;

  @override
  Future<Map<String, dynamic>> getFeedingSummary(String babyId) async {
    try {
      // 임시 샘플 데이터 반환 (네트워크 문제로 인해)
      final now = DateTime.now();
      final lastFeedingTime = now.subtract(Duration(hours: 1, minutes: 20));
      
      return {
        'count': 5,
        'totalAmount': 720,
        'lastFeedingTime': lastFeedingTime,
        'lastFeedingMinutesAgo': 80, // 1시간 20분 전
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
      // 임시 샘플 데이터 반환
      final totalMinutes = 380; // 6시간 20분
      
      return {
        'count': 3,
        'totalMinutes': totalMinutes,
        'totalHours': totalMinutes ~/ 60, // 6시간
        'remainingMinutes': totalMinutes % 60, // 20분
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
      // 임시 샘플 데이터 반환
      return {
        'totalCount': 7,
        'wetCount': 5, // 소변
        'dirtyCount': 2, // 대변
        'bothCount': 0, // 혼합
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
      // 임시 샘플 데이터 반환
      final now = DateTime.now();
      final latestRecordTime = now.subtract(Duration(hours: 2));
      
      return {
        'latestTemperature': 36.5,
        'latestRecordTime': latestRecordTime,
        'status': 'normal',
      };
    } catch (e) {
      print('Error getting temperature summary: $e');
      return {
        'latestTemperature': null,
        'latestRecordTime': null,
        'status': null,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getGrowthSummary(String babyId) async {
    try {
      // 임시 샘플 데이터 반환
      final now = DateTime.now();
      final lastRecordDate = now.subtract(Duration(days: 7));
      
      return {
        'currentWeight': 7.2, // 현재 몸무게 (kg)
        'currentHeight': 67.0, // 현재 키 (cm)
        'previousWeight': 7.08, // 이전 몸무게
        'previousHeight': 65.5, // 이전 키
        'weightChange': 0.12, // 몸무게 증가량 (120g)
        'heightChange': 1.5, // 키 증가량 (1.5cm)
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
}