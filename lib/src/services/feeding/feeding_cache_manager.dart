import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feeding_pattern_analyzer.dart';

class FeedingPatternCache {
  final FeedingPatternAnalysisResult result;
  final DateTime cacheTime;
  final int lastFeedingCount;
  final String? lastFeedingId;

  const FeedingPatternCache({
    required this.result,
    required this.cacheTime,
    required this.lastFeedingCount,
    this.lastFeedingId,
  });

  Map<String, dynamic> toJson() => {
    'result': {
      'averageIntervalHours': result.averageIntervalHours,
      'hasNightFeeding': result.hasNightFeeding,
      'isDataSufficient': result.isDataSufficient,
      'insufficientDataReason': result.insufficientDataReason,
      'totalFeedings': result.totalFeedings,
      'intervalHours': result.intervalHours,
      'lastFeedingTime': result.lastFeedingTime?.toIso8601String(),
      'patternDetails': result.patternDetails,
    },
    'cacheTime': cacheTime.toIso8601String(),
    'lastFeedingCount': lastFeedingCount,
    'lastFeedingId': lastFeedingId,
  };

  factory FeedingPatternCache.fromJson(Map<String, dynamic> json) {
    final resultJson = json['result'] as Map<String, dynamic>;
    return FeedingPatternCache(
      result: FeedingPatternAnalysisResult(
        averageIntervalHours: resultJson['averageIntervalHours'] as double,
        hasNightFeeding: resultJson['hasNightFeeding'] as bool,
        isDataSufficient: resultJson['isDataSufficient'] as bool,
        insufficientDataReason: resultJson['insufficientDataReason'] as String?,
        totalFeedings: resultJson['totalFeedings'] as int,
        intervalHours: (resultJson['intervalHours'] as List).cast<double>(),
        lastFeedingTime: resultJson['lastFeedingTime'] != null 
            ? DateTime.parse(resultJson['lastFeedingTime'] as String)
            : null,
        patternDetails: resultJson['patternDetails'] as Map<String, dynamic>,
      ),
      cacheTime: DateTime.parse(json['cacheTime'] as String),
      lastFeedingCount: json['lastFeedingCount'] as int,
      lastFeedingId: json['lastFeedingId'] as String?,
    );
  }
}

class FeedingCacheManager {
  static const String _cacheKey = 'feeding_pattern_cache';
  static const String _lastUpdateKey = 'feeding_pattern_last_update';
  static const Duration _cacheValidDuration = Duration(hours: 24);
  static const int _recalculateThreshold = 3; // 3회 수유 추가 후 재계산

  static FeedingCacheManager? _instance;
  static FeedingCacheManager get instance => _instance ??= FeedingCacheManager._();
  
  FeedingCacheManager._();

  /// 캐시된 패턴 분석 결과 가져오기
  Future<FeedingPatternCache?> getCachedPattern(String babyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$babyId';
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson == null) {
        debugPrint('캐시된 수유 패턴 없음: $babyId');
        return null;
      }

      final cache = FeedingPatternCache.fromJson(jsonDecode(cachedJson));
      
      // 캐시 유효성 검사
      if (!_isCacheValid(cache)) {
        debugPrint('수유 패턴 캐시 만료: $babyId');
        await _clearCache(babyId);
        return null;
      }

      debugPrint('캐시된 수유 패턴 사용: $babyId');
      return cache;
    } catch (e) {
      debugPrint('수유 패턴 캐시 로드 오류: $e');
      await _clearCache(babyId); // 손상된 캐시 제거
      return null;
    }
  }

  /// 패턴 분석 결과 캐싱
  Future<void> cachePattern({
    required String babyId,
    required FeedingPatternAnalysisResult result,
    required int currentFeedingCount,
    String? lastFeedingId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$babyId';
      
      final cache = FeedingPatternCache(
        result: result,
        cacheTime: DateTime.now(),
        lastFeedingCount: currentFeedingCount,
        lastFeedingId: lastFeedingId,
      );

      await prefs.setString(cacheKey, jsonEncode(cache.toJson()));
      await _updateLastCacheTime(babyId);
      
      debugPrint('수유 패턴 캐시 저장: $babyId (count: $currentFeedingCount)');
    } catch (e) {
      debugPrint('수유 패턴 캐시 저장 오류: $e');
    }
  }

  /// 새로운 수유 기록 추가 시 캐시 무효화 체크
  Future<bool> shouldRecalculate(String babyId, int currentFeedingCount) async {
    try {
      final cachedPattern = await getCachedPattern(babyId);
      if (cachedPattern == null) {
        debugPrint('캐시 없음 - 재계산 필요: $babyId');
        return true;
      }

      final feedingCountDifference = currentFeedingCount - cachedPattern.lastFeedingCount;
      
      if (feedingCountDifference >= _recalculateThreshold) {
        debugPrint('수유 횟수 증가로 재계산 필요: $babyId ($feedingCountDifference회 추가)');
        return true;
      }

      // 마지막 수유 후 시간이 패턴과 크게 다르면 재계산
      if (cachedPattern.result.lastFeedingTime != null) {
        final timeSinceLastFeeding = DateTime.now().difference(cachedPattern.result.lastFeedingTime!);
        final expectedInterval = Duration(
          minutes: (cachedPattern.result.averageIntervalHours * 60).round()
        );
        
        final deviation = (timeSinceLastFeeding.inMinutes - expectedInterval.inMinutes).abs();
        if (deviation > expectedInterval.inMinutes * 0.5) { // 50% 이상 차이
          debugPrint('수유 패턴 변화 감지로 재계산 필요: $babyId');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('재계산 필요성 체크 오류: $e');
      return true; // 오류 시 안전하게 재계산
    }
  }

  /// 캐시 강제 무효화
  Future<void> invalidateCache(String babyId) async {
    await _clearCache(babyId);
    debugPrint('수유 패턴 캐시 강제 무효화: $babyId');
  }

  /// 모든 베이비의 캐시 정리
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKey)).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      debugPrint('모든 수유 패턴 캐시 정리 완료');
    } catch (e) {
      debugPrint('캐시 정리 오류: $e');
    }
  }

  /// 캐시 유효성 검사
  bool _isCacheValid(FeedingPatternCache cache) {
    final now = DateTime.now();
    
    // 시간 기반 만료 체크
    if (now.difference(cache.cacheTime) > _cacheValidDuration) {
      return false;
    }

    // 데이터 무결성 체크
    if (cache.result.totalFeedings <= 0) {
      return false;
    }

    return true;
  }

  /// 특정 베이비 캐시 제거
  Future<void> _clearCache(String babyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$babyId';
      final lastUpdateKey = '${_lastUpdateKey}_$babyId';
      
      await prefs.remove(cacheKey);
      await prefs.remove(lastUpdateKey);
    } catch (e) {
      debugPrint('캐시 제거 오류: $e');
    }
  }

  /// 마지막 캐시 업데이트 시간 기록
  Future<void> _updateLastCacheTime(String babyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateKey = '${_lastUpdateKey}_$babyId';
      await prefs.setString(lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('마지막 업데이트 시간 저장 오류: $e');
    }
  }

  /// 캐시 통계 정보
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getKeys().where((key) => key.startsWith(_cacheKey)).toList();
      
      int validCaches = 0;
      int expiredCaches = 0;
      
      for (final key in cacheKeys) {
        try {
          final cachedJson = prefs.getString(key);
          if (cachedJson != null) {
            final cache = FeedingPatternCache.fromJson(jsonDecode(cachedJson));
            if (_isCacheValid(cache)) {
              validCaches++;
            } else {
              expiredCaches++;
            }
          }
        } catch (e) {
          expiredCaches++;
        }
      }
      
      return {
        'totalCaches': cacheKeys.length,
        'validCaches': validCaches,
        'expiredCaches': expiredCaches,
        'cacheValidDurationHours': _cacheValidDuration.inHours,
        'recalculateThreshold': _recalculateThreshold,
      };
    } catch (e) {
      debugPrint('캐시 통계 조회 오류: $e');
      return {};
    }
  }

  /// 백그라운드 캐시 정리 (만료된 캐시 제거)
  Future<void> cleanupExpiredCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getKeys().where((key) => key.startsWith(_cacheKey)).toList();
      int cleanedCount = 0;
      
      for (final key in cacheKeys) {
        try {
          final cachedJson = prefs.getString(key);
          if (cachedJson != null) {
            final cache = FeedingPatternCache.fromJson(jsonDecode(cachedJson));
            if (!_isCacheValid(cache)) {
              await prefs.remove(key);
              cleanedCount++;
            }
          }
        } catch (e) {
          // 손상된 캐시 제거
          await prefs.remove(key);
          cleanedCount++;
        }
      }
      
      debugPrint('만료된 캐시 정리 완료: $cleanedCount개');
    } catch (e) {
      debugPrint('캐시 정리 오류: $e');
    }
  }
}