enum TimelineItemType {
  feeding,
  sleep,
  diaper,
  medication,
  milkPumping,
  solidFood,
  temperature,
}

class TimelineItem {
  final String id;
  final TimelineItemType type;
  final DateTime timestamp;
  final String title;
  final String? subtitle;
  final Map<String, dynamic> data;
  final bool isOngoing; // 진행 중인 상태 (예: 수면 중)
  final String? iconName;
  final String? colorCode;

  const TimelineItem({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    this.subtitle,
    required this.data,
    this.isOngoing = false,
    this.iconName,
    this.colorCode,
  });

  // 복사 생성자
  TimelineItem copyWith({
    String? id,
    TimelineItemType? type,
    DateTime? timestamp,
    String? title,
    String? subtitle,
    Map<String, dynamic>? data,
    bool? isOngoing,
    String? iconName,
    String? colorCode,
  }) {
    return TimelineItem(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      data: data ?? this.data,
      isOngoing: isOngoing ?? this.isOngoing,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'subtitle': subtitle,
      'data': data,
      'isOngoing': isOngoing,
      'iconName': iconName,
      'colorCode': colorCode,
    };
  }

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'],
      type: TimelineItemType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      subtitle: json['subtitle'],
      data: Map<String, dynamic>.from(json['data']),
      isOngoing: json['isOngoing'] ?? false,
      iconName: json['iconName'],
      colorCode: json['colorCode'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// 타임라인 필터 타입
enum TimelineFilterType {
  all,
  feeding,
  sleep,
  diaper,
  medication,
  milkPumping,
  solidFood,
  temperature,
}

extension TimelineFilterTypeExtension on TimelineFilterType {
  String get displayName {
    switch (this) {
      case TimelineFilterType.all:
        return '전체';
      case TimelineFilterType.feeding:
        return '수유';
      case TimelineFilterType.sleep:
        return '수면';
      case TimelineFilterType.diaper:
        return '기저귀';
      case TimelineFilterType.medication:
        return '투약';
      case TimelineFilterType.milkPumping:
        return '유축';
      case TimelineFilterType.solidFood:
        return '이유식';
      case TimelineFilterType.temperature:
        return '체온';
    }
  }

  TimelineItemType? get itemType {
    switch (this) {
      case TimelineFilterType.all:
        return null;
      case TimelineFilterType.feeding:
        return TimelineItemType.feeding;
      case TimelineFilterType.sleep:
        return TimelineItemType.sleep;
      case TimelineFilterType.diaper:
        return TimelineItemType.diaper;
      case TimelineFilterType.medication:
        return TimelineItemType.medication;
      case TimelineFilterType.milkPumping:
        return TimelineItemType.milkPumping;
      case TimelineFilterType.solidFood:
        return TimelineItemType.solidFood;
      case TimelineFilterType.temperature:
        return TimelineItemType.temperature;
    }
  }
}