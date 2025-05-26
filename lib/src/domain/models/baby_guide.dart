class BabyGuide {
  final String id;
  final int weekNumber;
  final String countryCode;
  final String languageCode;
  final int? feedingAmountMin;
  final int? feedingAmountMax;
  final int? frequencyMin;
  final int? frequencyMax;
  final int? singleFeedingMin;
  final int? singleFeedingMax;
  final String message;
  final Map<String, dynamic>? policyInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BabyGuide({
    required this.id,
    required this.weekNumber,
    required this.countryCode,
    required this.languageCode,
    this.feedingAmountMin,
    this.feedingAmountMax,
    this.frequencyMin,
    this.frequencyMax,
    this.singleFeedingMin,
    this.singleFeedingMax,
    required this.message,
    this.policyInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BabyGuide.fromJson(Map<String, dynamic> json) {
    return BabyGuide(
      id: json['id'] as String,
      weekNumber: json['week_number'] as int,
      countryCode: json['country_code'] as String,
      languageCode: json['language_code'] as String,
      feedingAmountMin: json['feeding_amount_min'] as int?,
      feedingAmountMax: json['feeding_amount_max'] as int?,
      frequencyMin: json['frequency_min'] as int?,
      frequencyMax: json['frequency_max'] as int?,
      singleFeedingMin: json['single_feeding_min'] as int?,
      singleFeedingMax: json['single_feeding_max'] as int?,
      message: json['message'] as String,
      policyInfo: json['policy_info'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'country_code': countryCode,
      'language_code': languageCode,
      'feeding_amount_min': feedingAmountMin,
      'feeding_amount_max': feedingAmountMax,
      'frequency_min': frequencyMin,
      'frequency_max': frequencyMax,
      'single_feeding_min': singleFeedingMin,
      'single_feeding_max': singleFeedingMax,
      'message': message,
      'policy_info': policyInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 수유량 범위 텍스트 반환
  String? get feedingAmountRange {
    if (feedingAmountMin != null && feedingAmountMax != null) {
      return '${feedingAmountMin}ml - ${feedingAmountMax}ml';
    } else if (feedingAmountMin != null) {
      return '${feedingAmountMin}ml 이상';
    } else if (feedingAmountMax != null) {
      return '${feedingAmountMax}ml 이하';
    }
    return null;
  }

  /// 수유 횟수 범위 텍스트 반환
  String? get frequencyRange {
    if (frequencyMin != null && frequencyMax != null) {
      return '하루 ${frequencyMin}회 - ${frequencyMax}회';
    } else if (frequencyMin != null) {
      return '하루 ${frequencyMin}회 이상';
    } else if (frequencyMax != null) {
      return '하루 ${frequencyMax}회 이하';
    }
    return null;
  }

  /// 1회 수유량 범위 텍스트 반환
  String? get singleFeedingRange {
    if (singleFeedingMin != null && singleFeedingMax != null) {
      return '${singleFeedingMin}ml - ${singleFeedingMax}ml';
    } else if (singleFeedingMin != null) {
      return '${singleFeedingMin}ml 이상';
    } else if (singleFeedingMax != null) {
      return '${singleFeedingMax}ml 이하';
    }
    return null;
  }

  /// 주차 표시 텍스트
  String get weekText {
    if (weekNumber == 0) {
      return '신생아 (0주차)';
    } else {
      return '${weekNumber}주차';
    }
  }
}