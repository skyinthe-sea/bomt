import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/feeding.dart';

class FeedingPatternAnalysisResult {
  final double averageIntervalHours;
  final bool hasNightFeeding;
  final bool isDataSufficient;
  final String? insufficientDataReason;
  final int totalFeedings;
  final List<double> intervalHours;
  final DateTime? lastFeedingTime;
  final Map<String, dynamic> patternDetails;

  const FeedingPatternAnalysisResult({
    required this.averageIntervalHours,
    required this.hasNightFeeding,
    required this.isDataSufficient,
    this.insufficientDataReason,
    required this.totalFeedings,
    required this.intervalHours,
    this.lastFeedingTime,
    required this.patternDetails,
  });
}

class FeedingPatternAnalyzer {
  static const double _maxReasonableIntervalHours = 6.0;
  static const int _minRequiredFeedings = 3;
  static const int _nightStartHour = 22; // 22:00
  static const int _nightEndHour = 6;    // 06:00
  static const double _nightFeedingThreshold = 0.3; // 30% 이상이면 새벽수유 함
  static const double _maxNormalIntervalHours = 5.0; // 5시간 이상이면 비정상적 간격
  static const double _minNormalIntervalHours = 0.5; // 30분 이하면 비정상적 간격

  static FeedingPatternAnalysisResult analyzePattern(List<Feeding> feedings) {
    if (feedings.isEmpty) {
      return FeedingPatternAnalysisResult(
        averageIntervalHours: 3.0, // 기본값
        hasNightFeeding: false,
        isDataSufficient: false,
        insufficientDataReason: 'no_feeding_records',
        totalFeedings: 0,
        intervalHours: [],
        patternDetails: {},
      );
    }

    if (feedings.length < _minRequiredFeedings) {
      return FeedingPatternAnalysisResult(
        averageIntervalHours: 3.0,
        hasNightFeeding: false,
        isDataSufficient: false,
        insufficientDataReason: 'insufficient_records',
        totalFeedings: feedings.length,
        intervalHours: [],
        lastFeedingTime: feedings.first.startedAt,
        patternDetails: {'required_minimum': _minRequiredFeedings},
      );
    }

    // 시간순 정렬 (최신순)
    final sortedFeedings = List<Feeding>.from(feedings)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // 수유 간격 계산
    final intervals = <double>[];
    for (int i = 0; i < sortedFeedings.length - 1; i++) {
      final current = sortedFeedings[i].startedAt;
      final next = sortedFeedings[i + 1].startedAt;
      final intervalHours = current.difference(next).inMinutes / 60.0;
      
      // 비정상적인 간격 필터링
      if (intervalHours >= _minNormalIntervalHours && intervalHours <= _maxNormalIntervalHours) {
        intervals.add(intervalHours);
      }
    }

    if (intervals.isEmpty) {
      return FeedingPatternAnalysisResult(
        averageIntervalHours: 3.0,
        hasNightFeeding: false,
        isDataSufficient: false,
        insufficientDataReason: 'abnormal_intervals',
        totalFeedings: feedings.length,
        intervalHours: [],
        lastFeedingTime: sortedFeedings.first.startedAt,
        patternDetails: {
          'min_normal_interval': _minNormalIntervalHours,
          'max_normal_interval': _maxNormalIntervalHours,
        },
      );
    }

    // 새벽수유 패턴 분석
    final nightFeedingAnalysis = _analyzeNightFeedingPattern(sortedFeedings);
    final hasNightFeeding = nightFeedingAnalysis['hasNightFeeding'] as bool;

    // 평균 간격 계산
    double averageInterval;
    if (hasNightFeeding) {
      // 새벽수유를 하는 경우: 모든 간격의 평균
      averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    } else {
      // 새벽수유를 안하는 경우: 활동시간대만 필터링
      final dayTimeIntervals = _filterDayTimeIntervals(sortedFeedings, intervals);
      if (dayTimeIntervals.isNotEmpty) {
        averageInterval = dayTimeIntervals.reduce((a, b) => a + b) / dayTimeIntervals.length;
      } else {
        averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      }
    }

    // 데이터 품질 검증
    final dataQualityCheck = _checkDataQuality(intervals, averageInterval, feedings.length);

    return FeedingPatternAnalysisResult(
      averageIntervalHours: averageInterval,
      hasNightFeeding: hasNightFeeding,
      isDataSufficient: dataQualityCheck['isSufficient'] as bool,
      insufficientDataReason: dataQualityCheck['reason'] as String?,
      totalFeedings: feedings.length,
      intervalHours: intervals,
      lastFeedingTime: sortedFeedings.first.startedAt,
      patternDetails: {
        'night_feeding_analysis': nightFeedingAnalysis,
        'data_quality': dataQualityCheck,
        'filtered_intervals_count': intervals.length,
        'original_feedings_count': feedings.length,
      },
    );
  }

  static Map<String, dynamic> _analyzeNightFeedingPattern(List<Feeding> sortedFeedings) {
    int nightFeedings = 0;
    int totalFeedings = sortedFeedings.length;

    for (final feeding in sortedFeedings) {
      final hour = feeding.startedAt.hour;
      if (hour >= _nightStartHour || hour < _nightEndHour) {
        nightFeedings++;
      }
    }

    final nightFeedingRatio = nightFeedings / totalFeedings;
    final hasNightFeeding = nightFeedingRatio >= _nightFeedingThreshold;

    return {
      'hasNightFeeding': hasNightFeeding,
      'nightFeedingCount': nightFeedings,
      'totalFeedingCount': totalFeedings,
      'nightFeedingRatio': nightFeedingRatio,
      'threshold': _nightFeedingThreshold,
    };
  }

  static List<double> _filterDayTimeIntervals(List<Feeding> sortedFeedings, List<double> intervals) {
    final dayTimeIntervals = <double>[];
    
    for (int i = 0; i < sortedFeedings.length - 1 && i < intervals.length; i++) {
      final currentHour = sortedFeedings[i].startedAt.hour;
      final nextHour = sortedFeedings[i + 1].startedAt.hour;
      
      // 둘 다 활동시간대에 있는 경우만 포함
      if (_isDayTime(currentHour) && _isDayTime(nextHour)) {
        dayTimeIntervals.add(intervals[i]);
      }
    }
    
    return dayTimeIntervals;
  }

  static bool _isDayTime(int hour) {
    return hour >= _nightEndHour && hour < _nightStartHour;
  }

  static Map<String, dynamic> _checkDataQuality(List<double> intervals, double averageInterval, int totalFeedings) {
    // 6시간 이상 간격이면 데이터 품질 문제
    if (averageInterval >= _maxReasonableIntervalHours) {
      return {
        'isSufficient': false,
        'reason': 'long_intervals',
        'averageInterval': averageInterval,
        'maxReasonableInterval': _maxReasonableIntervalHours,
      };
    }

    // 하루 수유 횟수가 너무 적으면 문제 (일반적으로 하루 6-8회)
    final dailyEstimate = 24 / averageInterval;
    if (dailyEstimate < 4) {
      return {
        'isSufficient': false,
        'reason': 'too_few_daily_feedings',
        'estimatedDailyFeedings': dailyEstimate,
        'averageInterval': averageInterval,
      };
    }

    // 간격 변동성이 너무 크면 문제
    if (intervals.length > 1) {
      final variance = _calculateVariance(intervals);
      final standardDeviation = sqrt(variance);
      final coefficientOfVariation = standardDeviation / averageInterval;
      
      if (coefficientOfVariation > 1.0) { // 변동계수가 1.0 이상이면 매우 불규칙
        return {
          'isSufficient': false,
          'reason': 'irregular_pattern',
          'coefficientOfVariation': coefficientOfVariation,
          'standardDeviation': standardDeviation,
        };
      }
    }

    return {
      'isSufficient': true,
      'reason': null,
      'qualityScore': _calculateQualityScore(intervals, averageInterval, totalFeedings),
    };
  }

  static double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences = values.map((value) => (value - mean) * (value - mean));
    return squaredDifferences.reduce((a, b) => a + b) / values.length;
  }

  static double _calculateQualityScore(List<double> intervals, double averageInterval, int totalFeedings) {
    double score = 1.0;
    
    // 기록 수에 따른 점수
    if (totalFeedings < 5) score *= 0.7;
    else if (totalFeedings < 10) score *= 0.85;
    
    // 간격 안정성에 따른 점수
    if (intervals.length > 1) {
      final variance = _calculateVariance(intervals);
      final stabilityScore = 1.0 / (1.0 + variance);
      score *= stabilityScore;
    }
    
    // 평균 간격 합리성에 따른 점수
    if (averageInterval < 1.5 || averageInterval > 5.0) {
      score *= 0.8;
    }
    
    return score.clamp(0.0, 1.0);
  }

  static String getNextFeedingMessage(FeedingPatternAnalysisResult analysis) {
    if (!analysis.isDataSufficient) {
      return 'insufficient_feeding_records';
    }
    
    if (analysis.lastFeedingTime == null) {
      return 'no_recent_feeding';
    }
    
    final now = DateTime.now();
    final timeSinceLastFeeding = now.difference(analysis.lastFeedingTime!);
    final nextFeedingTime = analysis.lastFeedingTime!.add(
      Duration(minutes: (analysis.averageIntervalHours * 60).round())
    );
    
    if (nextFeedingTime.isBefore(now)) {
      return 'feeding_overdue';
    }
    
    final timeUntilNext = nextFeedingTime.difference(now);
    final hoursUntil = timeUntilNext.inHours;
    final minutesUntil = timeUntilNext.inMinutes % 60;
    
    if (hoursUntil == 0) {
      return 'minutes_until_feeding';
    } else {
      return 'hours_minutes_until_feeding';
    }
  }
}