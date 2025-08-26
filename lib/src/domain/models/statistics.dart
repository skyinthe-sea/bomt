/// 통계 날짜 범위 타입
enum StatisticsDateRangeType {
  weekly,
  monthly,
  custom,
}

/// StatisticsDateRangeType 확장 메서드
extension StatisticsDateRangeTypeExtension on StatisticsDateRangeType {
  String toJson() {
    switch (this) {
      case StatisticsDateRangeType.weekly:
        return 'weekly';
      case StatisticsDateRangeType.monthly:
        return 'monthly';
      case StatisticsDateRangeType.custom:
        return 'custom';
    }
  }

  static StatisticsDateRangeType fromJson(String json) {
    switch (json) {
      case 'weekly':
        return StatisticsDateRangeType.weekly;
      case 'monthly':
        return StatisticsDateRangeType.monthly;
      case 'custom':
        return StatisticsDateRangeType.custom;
      default:
        return StatisticsDateRangeType.weekly;
    }
  }
}

/// 통계 날짜 범위
class StatisticsDateRange {
  final StatisticsDateRangeType type;
  final DateTime startDate;
  final DateTime endDate;
  final String label;

  const StatisticsDateRange({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  /// 주간 범위 생성
  factory StatisticsDateRange.weekly({DateTime? date, String? label}) {
    final now = date ?? DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    
    print('📅 [DATE_RANGE_DEBUG] ========== WEEKLY RANGE CREATION ==========');
    print('📅 [DATE_RANGE_DEBUG] Input date (now): $now');
    print('📅 [DATE_RANGE_DEBUG] Weekday number: ${now.weekday} (1=Mon, 7=Sun)');
    print('📅 [DATE_RANGE_DEBUG] Days to subtract for Monday: ${now.weekday - 1}');
    print('📅 [DATE_RANGE_DEBUG] Start of week (calculated): $startOfWeek');
    print('📅 [DATE_RANGE_DEBUG] End of week (calculated): $endOfWeek');
    print('📅 [DATE_RANGE_DEBUG] Final start date (00:00:00): $startDate');
    print('📅 [DATE_RANGE_DEBUG] Final end date (23:59:59): $endDate');
    print('📅 [DATE_RANGE_DEBUG] Week range: ${startDate.day}/${startDate.month} ~ ${endDate.day}/${endDate.month}');
    print('📅 [DATE_RANGE_DEBUG] Total days in range: ${endDate.difference(startDate).inDays + 1}');
    print('📅 [DATE_RANGE_DEBUG] =============================================');
    
    return StatisticsDateRange(
      type: StatisticsDateRangeType.weekly,
      startDate: startDate,
      endDate: endDate,
      label: label ?? '${startOfWeek.month}월 ${startOfWeek.day}일 - ${endOfWeek.month}월 ${endOfWeek.day}일',
    );
  }

  /// 월간 범위 생성
  factory StatisticsDateRange.monthly({DateTime? date, String? label}) {
    final now = date ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return StatisticsDateRange(
      type: StatisticsDateRangeType.monthly,
      startDate: startOfMonth,
      endDate: endOfMonth,
      label: label ?? '${now.year}/${now.month}',
    );
  }

  /// 커스텀 범위 생성
  factory StatisticsDateRange.custom({
    required DateTime startDate,
    required DateTime endDate,
    String? label,
  }) {
    return StatisticsDateRange(
      type: StatisticsDateRangeType.custom,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      label: label ?? '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}',
    );
  }

  /// 날짜 범위 내에 있는지 확인
  bool contains(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
           date.isBefore(endDate.add(const Duration(seconds: 1)));
  }

  /// 총 일수
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'label': label,
    };
  }

  /// JSON에서 역직렬화
  factory StatisticsDateRange.fromJson(Map<String, dynamic> json) {
    return StatisticsDateRange(
      type: StatisticsDateRangeTypeExtension.fromJson(json['type']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      label: json['label'],
    );
  }

  @override
  String toString() {
    return 'StatisticsDateRange(type: $type, label: $label, startDate: $startDate, endDate: $endDate)';
  }
}

/// 통계 메트릭
class StatisticsMetric {
  final String label;
  final double value;
  final String unit;
  final String? description;

  const StatisticsMetric({
    required this.label,
    required this.value,
    required this.unit,
    this.description,
  });

  /// 형식화된 값 반환
  String get formattedValue {
    if (value.isNaN || value.isInfinite) return '0';
    
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  /// 값과 단위를 결합한 문자열
  String get valueWithUnit {
    return '$formattedValue$unit';
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'unit': unit,
      'description': description,
    };
  }

  /// JSON에서 역직렬화
  factory StatisticsMetric.fromJson(Map<String, dynamic> json) {
    return StatisticsMetric(
      label: json['label'],
      value: json['value']?.toDouble() ?? 0.0,
      unit: json['unit'],
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'StatisticsMetric(label: $label, value: $formattedValue, unit: $unit)';
  }
}

/// 카드별 통계 데이터
class CardStatistics {
  final String cardType;
  final String cardName;
  final int totalCount;
  final List<StatisticsMetric> metrics;
  final Map<String, dynamic> additionalData;

  const CardStatistics({
    required this.cardType,
    required this.cardName,
    required this.totalCount,
    required this.metrics,
    this.additionalData = const {},
  });

  /// 특정 라벨의 메트릭 반환
  StatisticsMetric? getMetric(String label) {
    try {
      return metrics.firstWhere((metric) => metric.label == label);
    } catch (e) {
      return null;
    }
  }

  /// 메트릭이 있는지 확인
  bool hasMetric(String label) {
    return metrics.any((metric) => metric.label == label);
  }

  /// 통계 데이터가 있는지 확인
  bool get hasData {
    return totalCount > 0;
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'cardType': cardType,
      'cardName': cardName,
      'totalCount': totalCount,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'additionalData': additionalData,
    };
  }

  /// JSON에서 역직렬화
  factory CardStatistics.fromJson(Map<String, dynamic> json) {
    return CardStatistics(
      cardType: json['cardType'],
      cardName: json['cardName'],
      totalCount: json['totalCount'],
      metrics: (json['metrics'] as List?)
          ?.map((metric) => StatisticsMetric.fromJson(metric))
          .toList() ?? [],
      additionalData: Map<String, dynamic>.from(json['additionalData'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'CardStatistics(cardType: $cardType, totalCount: $totalCount, metricsCount: ${metrics.length})';
  }
}

/// 전체 통계 데이터
class Statistics {
  final StatisticsDateRange dateRange;
  final List<CardStatistics> cardStatistics;
  final DateTime lastUpdated;

  const Statistics({
    required this.dateRange,
    required this.cardStatistics,
    required this.lastUpdated,
  });

  /// 특정 카드 타입의 통계 반환
  CardStatistics? getCardStatistics(String cardType) {
    try {
      return cardStatistics.firstWhere((stats) => stats.cardType == cardType);
    } catch (e) {
      return null;
    }
  }

  /// 통계 데이터가 있는 카드들만 반환
  List<CardStatistics> get cardsWithData {
    return cardStatistics.where((stats) => stats.hasData).toList();
  }

  /// 전체 활동 수
  int get totalActivities {
    return cardStatistics.fold(0, (sum, stats) => sum + stats.totalCount);
  }

  /// 통계 데이터가 있는지 확인
  bool get hasData {
    return cardStatistics.any((stats) => stats.hasData);
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'dateRange': dateRange.toJson(),
      'cardStatistics': cardStatistics.map((card) => card.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// JSON에서 역직렬화
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      dateRange: StatisticsDateRange.fromJson(json['dateRange']),
      cardStatistics: (json['cardStatistics'] as List?)
          ?.map((card) => CardStatistics.fromJson(card))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  String toString() {
    return 'Statistics(dateRange: ${dateRange.label}, cardsCount: ${cardStatistics.length}, totalActivities: $totalActivities)';
  }
}

/// 통계 차트 데이터 포인트
class StatisticsDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  const StatisticsDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }

  /// JSON에서 역직렬화
  factory StatisticsDataPoint.fromJson(Map<String, dynamic> json) {
    return StatisticsDataPoint(
      date: DateTime.parse(json['date']),
      value: json['value']?.toDouble() ?? 0.0,
      label: json['label'],
    );
  }

  @override
  String toString() {
    return 'StatisticsDataPoint(date: $date, value: $value, label: $label)';
  }
}

/// 통계 차트 데이터
class StatisticsChartData {
  final String title;
  final List<StatisticsDataPoint> dataPoints;
  final String unit;
  final double? minValue;
  final double? maxValue;

  const StatisticsChartData({
    required this.title,
    required this.dataPoints,
    required this.unit,
    this.minValue,
    this.maxValue,
  });

  /// 평균값
  double get averageValue {
    if (dataPoints.isEmpty) return 0.0;
    return dataPoints.fold(0.0, (sum, point) => sum + point.value) / dataPoints.length;
  }

  /// 최대값
  double get maxDataValue {
    if (dataPoints.isEmpty) return 0.0;
    return dataPoints.map((point) => point.value).reduce((a, b) => a > b ? a : b);
  }

  /// 최소값
  double get minDataValue {
    if (dataPoints.isEmpty) return 0.0;
    return dataPoints.map((point) => point.value).reduce((a, b) => a < b ? a : b);
  }

  /// 차트 데이터가 있는지 확인
  bool get hasData {
    return dataPoints.isNotEmpty;
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dataPoints': dataPoints.map((point) => point.toJson()).toList(),
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }

  /// JSON에서 역직렬화
  factory StatisticsChartData.fromJson(Map<String, dynamic> json) {
    return StatisticsChartData(
      title: json['title'],
      dataPoints: (json['dataPoints'] as List?)
          ?.map((point) => StatisticsDataPoint.fromJson(point))
          .toList() ?? [],
      unit: json['unit'],
      minValue: json['minValue']?.toDouble(),
      maxValue: json['maxValue']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'StatisticsChartData(title: $title, dataPointsCount: ${dataPoints.length}, unit: $unit)';
  }
}