class TemperatureGuideline {
  final String id;
  final int ageFromMonths; // 시작 월령 (예: 0)
  final int ageToMonths;   // 끝 월령 (예: 3)
  final String countryCode; // 국가 코드 (KR, US 등)
  final String languageCode; // 언어 코드 (ko, en 등)
  
  // 정상 체온 범위
  final double normalTempMin; // 정상 체온 최소값
  final double normalTempMax; // 정상 체온 최대값
  
  // 미열 기준
  final double mildFeverMin; // 미열 시작 온도
  final double mildFeverMax; // 미열 최대 온도
  
  // 고열 기준
  final double highFeverMin; // 고열 시작 온도
  final double? highFeverMax; // 고열 최대 온도 (선택적)
  
  // 저체온 기준
  final double lowTempThreshold; // 저체온 기준점
  
  // 측정 방법별 보정값
  final double rectalOffset;    // 직장 측정 보정값 (+0.5도)
  final double oralOffset;      // 구강 측정 보정값 (0도)
  final double axillaryOffset;  // 겨드랑이 측정 보정값 (-0.5도)
  final double earOffset;       // 귀 측정 보정값 (+0.3도)
  final double foreheadOffset;  // 이마 측정 보정값 (-0.3도)
  
  // 응급 상황 기준
  final double emergencyThreshold; // 응급실 직행 기준 온도
  final bool requiresImmediateAttention; // 즉시 의료진 상담 필요
  
  // 가이드 메시지
  final String normalMessage;    // 정상 체온 시 메시지
  final String mildFeverMessage; // 미열 시 메시지
  final String highFeverMessage; // 고열 시 메시지
  final String lowTempMessage;   // 저체온 시 메시지
  final String emergencyMessage; // 응급 상황 메시지
  
  // 권장 조치
  final String normalCare;       // 정상 시 관리법
  final String mildFeverCare;    // 미열 시 관리법
  final String highFeverCare;    // 고열 시 관리법
  final String lowTempCare;      // 저체온 시 관리법
  
  // 해열제 사용 기준
  final bool canUseFeverReducer; // 해열제 사용 가능 여부
  final double feverReducerThreshold; // 해열제 사용 시작 온도
  final String feverReducerNote; // 해열제 사용 관련 주의사항
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TemperatureGuideline({
    required this.id,
    required this.ageFromMonths,
    required this.ageToMonths,
    required this.countryCode,
    required this.languageCode,
    required this.normalTempMin,
    required this.normalTempMax,
    required this.mildFeverMin,
    required this.mildFeverMax,
    required this.highFeverMin,
    this.highFeverMax,
    required this.lowTempThreshold,
    this.rectalOffset = 0.5,
    this.oralOffset = 0.0,
    this.axillaryOffset = -0.5,
    this.earOffset = 0.3,
    this.foreheadOffset = -0.3,
    required this.emergencyThreshold,
    this.requiresImmediateAttention = false,
    required this.normalMessage,
    required this.mildFeverMessage,
    required this.highFeverMessage,
    required this.lowTempMessage,
    required this.emergencyMessage,
    required this.normalCare,
    required this.mildFeverCare,
    required this.highFeverCare,
    required this.lowTempCare,
    this.canUseFeverReducer = false,
    this.feverReducerThreshold = 38.5,
    this.feverReducerNote = '',
    this.createdAt,
    this.updatedAt,
  });

  factory TemperatureGuideline.fromJson(Map<String, dynamic> json) {
    return TemperatureGuideline(
      id: json['id'] as String,
      ageFromMonths: json['age_from_months'] as int,
      ageToMonths: json['age_to_months'] as int,
      countryCode: json['country_code'] as String,
      languageCode: json['language_code'] as String,
      normalTempMin: (json['normal_temp_min'] as num).toDouble(),
      normalTempMax: (json['normal_temp_max'] as num).toDouble(),
      mildFeverMin: (json['mild_fever_min'] as num).toDouble(),
      mildFeverMax: (json['mild_fever_max'] as num).toDouble(),
      highFeverMin: (json['high_fever_min'] as num).toDouble(),
      highFeverMax: json['high_fever_max'] != null 
          ? (json['high_fever_max'] as num).toDouble() 
          : null,
      lowTempThreshold: (json['low_temp_threshold'] as num).toDouble(),
      rectalOffset: json['rectal_offset'] != null 
          ? (json['rectal_offset'] as num).toDouble() 
          : 0.5,
      oralOffset: json['oral_offset'] != null 
          ? (json['oral_offset'] as num).toDouble() 
          : 0.0,
      axillaryOffset: json['axillary_offset'] != null 
          ? (json['axillary_offset'] as num).toDouble() 
          : -0.5,
      earOffset: json['ear_offset'] != null 
          ? (json['ear_offset'] as num).toDouble() 
          : 0.3,
      foreheadOffset: json['forehead_offset'] != null 
          ? (json['forehead_offset'] as num).toDouble() 
          : -0.3,
      emergencyThreshold: (json['emergency_threshold'] as num).toDouble(),
      requiresImmediateAttention: json['requires_immediate_attention'] ?? false,
      normalMessage: json['normal_message'] as String,
      mildFeverMessage: json['mild_fever_message'] as String,
      highFeverMessage: json['high_fever_message'] as String,
      lowTempMessage: json['low_temp_message'] as String,
      emergencyMessage: json['emergency_message'] as String,
      normalCare: json['normal_care'] as String,
      mildFeverCare: json['mild_fever_care'] as String,
      highFeverCare: json['high_fever_care'] as String,
      lowTempCare: json['low_temp_care'] as String,
      canUseFeverReducer: json['can_use_fever_reducer'] ?? false,
      feverReducerThreshold: json['fever_reducer_threshold'] != null 
          ? (json['fever_reducer_threshold'] as num).toDouble() 
          : 38.5,
      feverReducerNote: json['fever_reducer_note'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age_from_months': ageFromMonths,
      'age_to_months': ageToMonths,
      'country_code': countryCode,
      'language_code': languageCode,
      'normal_temp_min': normalTempMin,
      'normal_temp_max': normalTempMax,
      'mild_fever_min': mildFeverMin,
      'mild_fever_max': mildFeverMax,
      'high_fever_min': highFeverMin,
      'high_fever_max': highFeverMax,
      'low_temp_threshold': lowTempThreshold,
      'rectal_offset': rectalOffset,
      'oral_offset': oralOffset,
      'axillary_offset': axillaryOffset,
      'ear_offset': earOffset,
      'forehead_offset': foreheadOffset,
      'emergency_threshold': emergencyThreshold,
      'requires_immediate_attention': requiresImmediateAttention,
      'normal_message': normalMessage,
      'mild_fever_message': mildFeverMessage,
      'high_fever_message': highFeverMessage,
      'low_temp_message': lowTempMessage,
      'emergency_message': emergencyMessage,
      'normal_care': normalCare,
      'mild_fever_care': mildFeverCare,
      'high_fever_care': highFeverCare,
      'low_temp_care': lowTempCare,
      'can_use_fever_reducer': canUseFeverReducer,
      'fever_reducer_threshold': feverReducerThreshold,
      'fever_reducer_note': feverReducerNote,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TemperatureGuideline copyWith({
    String? id,
    int? ageFromMonths,
    int? ageToMonths,
    String? countryCode,
    String? languageCode,
    double? normalTempMin,
    double? normalTempMax,
    double? mildFeverMin,
    double? mildFeverMax,
    double? highFeverMin,
    double? highFeverMax,
    double? lowTempThreshold,
    double? rectalOffset,
    double? oralOffset,
    double? axillaryOffset,
    double? earOffset,
    double? foreheadOffset,
    double? emergencyThreshold,
    bool? requiresImmediateAttention,
    String? normalMessage,
    String? mildFeverMessage,
    String? highFeverMessage,
    String? lowTempMessage,
    String? emergencyMessage,
    String? normalCare,
    String? mildFeverCare,
    String? highFeverCare,
    String? lowTempCare,
    bool? canUseFeverReducer,
    double? feverReducerThreshold,
    String? feverReducerNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemperatureGuideline(
      id: id ?? this.id,
      ageFromMonths: ageFromMonths ?? this.ageFromMonths,
      ageToMonths: ageToMonths ?? this.ageToMonths,
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
      normalTempMin: normalTempMin ?? this.normalTempMin,
      normalTempMax: normalTempMax ?? this.normalTempMax,
      mildFeverMin: mildFeverMin ?? this.mildFeverMin,
      mildFeverMax: mildFeverMax ?? this.mildFeverMax,
      highFeverMin: highFeverMin ?? this.highFeverMin,
      highFeverMax: highFeverMax ?? this.highFeverMax,
      lowTempThreshold: lowTempThreshold ?? this.lowTempThreshold,
      rectalOffset: rectalOffset ?? this.rectalOffset,
      oralOffset: oralOffset ?? this.oralOffset,
      axillaryOffset: axillaryOffset ?? this.axillaryOffset,
      earOffset: earOffset ?? this.earOffset,
      foreheadOffset: foreheadOffset ?? this.foreheadOffset,
      emergencyThreshold: emergencyThreshold ?? this.emergencyThreshold,
      requiresImmediateAttention: requiresImmediateAttention ?? this.requiresImmediateAttention,
      normalMessage: normalMessage ?? this.normalMessage,
      mildFeverMessage: mildFeverMessage ?? this.mildFeverMessage,
      highFeverMessage: highFeverMessage ?? this.highFeverMessage,
      lowTempMessage: lowTempMessage ?? this.lowTempMessage,
      emergencyMessage: emergencyMessage ?? this.emergencyMessage,
      normalCare: normalCare ?? this.normalCare,
      mildFeverCare: mildFeverCare ?? this.mildFeverCare,
      highFeverCare: highFeverCare ?? this.highFeverCare,
      lowTempCare: lowTempCare ?? this.lowTempCare,
      canUseFeverReducer: canUseFeverReducer ?? this.canUseFeverReducer,
      feverReducerThreshold: feverReducerThreshold ?? this.feverReducerThreshold,
      feverReducerNote: feverReducerNote ?? this.feverReducerNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TemperatureGuideline(id: $id, ageFromMonths: $ageFromMonths, ageToMonths: $ageToMonths, normalRange: $normalTempMin-$normalTempMax°C)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemperatureGuideline &&
        other.id == id &&
        other.ageFromMonths == ageFromMonths &&
        other.ageToMonths == ageToMonths &&
        other.countryCode == countryCode &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    return Object.hash(id, ageFromMonths, ageToMonths, countryCode, languageCode);
  }
}

// 체온 상태 열거형
enum TemperatureStatus {
  lowTemp,      // 저체온
  normal,       // 정상
  mildFever,    // 미열
  highFever,    // 고열
  emergency,    // 응급상황
}

// 체온 측정 방법 열거형
enum TemperatureMeasurementMethod {
  rectal,    // 직장
  oral,      // 구강
  axillary,  // 겨드랑이
  ear,       // 귀
  forehead,  // 이마
}