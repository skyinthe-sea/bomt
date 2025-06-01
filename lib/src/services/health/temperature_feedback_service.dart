import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/baby.dart';
import '../../domain/models/temperature_guideline.dart';

class TemperatureFeedbackService {
  static TemperatureFeedbackService? _instance;
  static TemperatureFeedbackService get instance => _instance ??= TemperatureFeedbackService._();
  
  TemperatureFeedbackService._();

  // 하드코딩된 월령별 체온 기준 데이터 (추후 데이터베이스로 이전 예정)
  final List<TemperatureGuideline> _guidelines = [
    // 0~3개월 신생아
    TemperatureGuideline(
      id: '1',
      ageFromMonths: 0,
      ageToMonths: 3,
      countryCode: 'KR',
      languageCode: 'ko',
      normalTempMin: 36.5,
      normalTempMax: 37.5,
      mildFeverMin: 37.6,
      mildFeverMax: 38.0,
      highFeverMin: 38.0,
      lowTempThreshold: 36.0,
      emergencyThreshold: 38.0,
      requiresImmediateAttention: true,
      normalMessage: '정상 체온입니다.',
      mildFeverMessage: '미열이 있습니다. 즉시 소아과에 방문하세요.',
      highFeverMessage: '고열입니다. 응급실로 직행하세요.',
      lowTempMessage: '체온이 낮습니다. 따뜻하게 하고 소아과에 문의하세요.',
      emergencyMessage: '응급상황입니다. 즉시 119에 신고하거나 응급실로 이동하세요.',
      normalCare: '모자+양말로 보온 유지, 피부 접촉 수유하세요.',
      mildFeverCare: '즉시 소아과 방문이 필요합니다.',
      highFeverCare: '응급실 직행이 필요합니다.',
      lowTempCare: '따뜻하게 감싸고 체온을 지속적으로 확인하세요.',
      canUseFeverReducer: false,
      feverReducerNote: '신생아는 해열제 자체 투약을 금지합니다.',
    ),
    
    // 4~6개월
    TemperatureGuideline(
      id: '2',
      ageFromMonths: 4,
      ageToMonths: 6,
      countryCode: 'KR',
      languageCode: 'ko',
      normalTempMin: 36.5,
      normalTempMax: 37.8,
      mildFeverMin: 37.9,
      mildFeverMax: 38.4,
      highFeverMin: 38.5,
      lowTempThreshold: 35.5,
      emergencyThreshold: 39.0,
      requiresImmediateAttention: false,
      normalMessage: '정상 체온입니다.',
      mildFeverMessage: '미열이 있습니다. 관찰하며 체온 변화를 지켜봐 주세요.',
      highFeverMessage: '고열입니다. 소아과 방문이 필요합니다.',
      lowTempMessage: '체온이 낮습니다. 따뜻하게 하고 지켜봐 주세요.',
      emergencyMessage: '39°C 이상 고열 또는 탈수 증상 시 즉시 병원을 방문하세요.',
      normalCare: '가벼운 옷 착용, 실내 온도 22~24°C 유지하세요.',
      mildFeverCare: '충분한 수분 공급과 휴식을 취하게 하세요.',
      highFeverCare: '체중당 10~15mg/kg의 아세트아미노펜을 6시간 간격으로 투여하세요.',
      lowTempCare: '따뜻하게 감싸고 실내 온도를 26°C로 높이세요.',
      canUseFeverReducer: true,
      feverReducerThreshold: 38.5,
      feverReducerNote: '아세트아미노펜만 사용 가능합니다. 이부프로펜은 6개월 미만 금지입니다.',
    ),
    
    // 7~12개월
    TemperatureGuideline(
      id: '3',
      ageFromMonths: 7,
      ageToMonths: 12,
      countryCode: 'KR',
      languageCode: 'ko',
      normalTempMin: 36.5,
      normalTempMax: 37.5,
      mildFeverMin: 37.6,
      mildFeverMax: 38.9,
      highFeverMin: 39.0,
      lowTempThreshold: 35.5,
      emergencyThreshold: 39.5,
      requiresImmediateAttention: false,
      normalMessage: '정상 체온입니다.',
      mildFeverMessage: '미열이 있습니다. 충분한 휴식과 수분 공급을 해주세요.',
      highFeverMessage: '고열입니다. 해열제 투여 후 소아과 방문이 필요합니다.',
      lowTempMessage: '체온이 낮습니다. 따뜻하게 해주세요.',
      emergencyMessage: '39.5°C 이상 또는 경련 증상 시 즉시 응급실로 이동하세요.',
      normalCare: '적절한 옷차림과 실내 온도를 유지하세요.',
      mildFeverCare: '전해질 음료나 수유 빈도를 늘리세요.',
      highFeverCare: '아세트아미노펜 또는 이부프로펜을 체중당 5~10mg/kg로 투여하세요.',
      lowTempCare: '모자, 장갑 착용 후 캥거루 케어를 해주세요.',
      canUseFeverReducer: true,
      feverReducerThreshold: 38.5,
      feverReducerNote: '아세트아미노펜과 이부프로펜 모두 사용 가능하며, 교차 복용 시 최소 2시간 간격을 유지하세요.',
    ),
    
    // 13~36개월
    TemperatureGuideline(
      id: '4',
      ageFromMonths: 13,
      ageToMonths: 36,
      countryCode: 'KR',
      languageCode: 'ko',
      normalTempMin: 36.5,
      normalTempMax: 37.5,
      mildFeverMin: 37.6,
      mildFeverMax: 38.9,
      highFeverMin: 39.0,
      lowTempThreshold: 35.0,
      emergencyThreshold: 40.0,
      requiresImmediateAttention: false,
      normalMessage: '정상 체온입니다.',
      mildFeverMessage: '미열이 있습니다. 활동이 정상이면 관찰하며 지켜봐 주세요.',
      highFeverMessage: '고열입니다. 해열제 투여 후 증상이 지속되면 소아과 방문하세요.',
      lowTempMessage: '체온이 낮습니다. 따뜻하게 해주세요.',
      emergencyMessage: '40°C 이상 고열, 경련, 의식 저하 시 즉시 응급실로 이동하세요.',
      normalCare: '평상시와 같이 관리하세요.',
      mildFeverCare: '충분한 휴식과 수분 공급, 면역 체계가 활성화되고 있습니다.',
      highFeverCare: '해열제 투여 후 증상 관찰하세요.',
      lowTempCare: '전기담요 사용 시 저온 설정으로 급격한 온도 상승을 피하세요.',
      canUseFeverReducer: true,
      feverReducerThreshold: 38.5,
      feverReducerNote: '아세트아미노펜과 이부프로펜 모두 사용 가능합니다.',
    ),
  ];

  /// 아기의 월령에 따른 체온 가이드라인 조회
  TemperatureGuideline? getGuidelineForBaby(Baby baby) {
    final ageInMonths = baby.ageInMonths;
    
    try {
      return _guidelines.firstWhere(
        (guideline) => 
          ageInMonths >= guideline.ageFromMonths && 
          ageInMonths <= guideline.ageToMonths,
      );
    } catch (e) {
      debugPrint('No guideline found for age: $ageInMonths months');
      return null;
    }
  }

  /// 체온 상태 분석
  TemperatureStatus analyzeTemperature(
    double temperature, 
    TemperatureGuideline guideline,
    TemperatureMeasurementMethod method,
  ) {
    // 측정 방법에 따른 보정
    double adjustedTemp = temperature;
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        adjustedTemp = temperature - guideline.rectalOffset;
        break;
      case TemperatureMeasurementMethod.oral:
        adjustedTemp = temperature - guideline.oralOffset;
        break;
      case TemperatureMeasurementMethod.axillary:
        adjustedTemp = temperature - guideline.axillaryOffset;
        break;
      case TemperatureMeasurementMethod.ear:
        adjustedTemp = temperature - guideline.earOffset;
        break;
      case TemperatureMeasurementMethod.forehead:
        adjustedTemp = temperature - guideline.foreheadOffset;
        break;
    }

    // 온도 범위에 따른 상태 판정
    if (adjustedTemp >= guideline.emergencyThreshold) {
      return TemperatureStatus.emergency;
    } else if (adjustedTemp >= guideline.highFeverMin) {
      return TemperatureStatus.highFever;
    } else if (adjustedTemp >= guideline.mildFeverMin) {
      return TemperatureStatus.mildFever;
    } else if (adjustedTemp <= guideline.lowTempThreshold) {
      return TemperatureStatus.lowTemp;
    } else {
      return TemperatureStatus.normal;
    }
  }

  /// 체온 피드백 생성
  Map<String, dynamic> generateFeedback(
    Baby baby,
    double temperature,
    TemperatureMeasurementMethod method,
  ) {
    final guideline = getGuidelineForBaby(baby);
    
    if (guideline == null) {
      return {
        'status': TemperatureStatus.normal,
        'message': '월령 정보를 확인할 수 없어 일반적인 기준으로 판단합니다.',
        'careInstructions': '소아과 전문의와 상담하세요.',
        'isEmergency': false,
        'canUseFeverReducer': false,
        'adjustedTemperature': temperature,
      };
    }

    final status = analyzeTemperature(temperature, guideline, method);
    
    // 측정 방법에 따른 보정된 체온
    double adjustedTemp = temperature;
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        adjustedTemp = temperature - guideline.rectalOffset;
        break;
      case TemperatureMeasurementMethod.oral:
        adjustedTemp = temperature - guideline.oralOffset;
        break;
      case TemperatureMeasurementMethod.axillary:
        adjustedTemp = temperature - guideline.axillaryOffset;
        break;
      case TemperatureMeasurementMethod.ear:
        adjustedTemp = temperature - guideline.earOffset;
        break;
      case TemperatureMeasurementMethod.forehead:
        adjustedTemp = temperature - guideline.foreheadOffset;
        break;
    }

    String message;
    String careInstructions;
    bool isEmergency = false;
    
    switch (status) {
      case TemperatureStatus.normal:
        message = guideline.normalMessage;
        careInstructions = guideline.normalCare;
        break;
      case TemperatureStatus.mildFever:
        message = guideline.mildFeverMessage;
        careInstructions = guideline.mildFeverCare;
        break;
      case TemperatureStatus.highFever:
        message = guideline.highFeverMessage;
        careInstructions = guideline.highFeverCare;
        break;
      case TemperatureStatus.lowTemp:
        message = guideline.lowTempMessage;
        careInstructions = guideline.lowTempCare;
        break;
      case TemperatureStatus.emergency:
        message = guideline.emergencyMessage;
        careInstructions = guideline.highFeverCare;
        isEmergency = true;
        break;
    }

    // 해열제 사용 가능 여부 판단
    bool canUseFeverReducer = guideline.canUseFeverReducer && 
                              adjustedTemp >= guideline.feverReducerThreshold;

    return {
      'status': status,
      'message': message,
      'careInstructions': careInstructions,
      'isEmergency': isEmergency,
      'canUseFeverReducer': canUseFeverReducer,
      'feverReducerNote': guideline.feverReducerNote,
      'adjustedTemperature': adjustedTemp,
      'measurementMethod': _getMethodDisplayName(method),
      'ageGroup': '${guideline.ageFromMonths}~${guideline.ageToMonths}개월',
      'requiresImmediateAttention': guideline.requiresImmediateAttention,
    };
  }

  /// 응급 상황 체크
  bool isEmergencyTemperature(Baby baby, double temperature, TemperatureMeasurementMethod method) {
    final guideline = getGuidelineForBaby(baby);
    if (guideline == null) return false;
    
    final status = analyzeTemperature(temperature, guideline, method);
    return status == TemperatureStatus.emergency || 
           (guideline.requiresImmediateAttention && status != TemperatureStatus.normal);
  }

  /// 측정 방법 표시명 반환
  String _getMethodDisplayName(TemperatureMeasurementMethod method) {
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        return '항문';
      case TemperatureMeasurementMethod.oral:
        return '구강';
      case TemperatureMeasurementMethod.axillary:
        return '겨드랑이';
      case TemperatureMeasurementMethod.ear:
        return '귀';
      case TemperatureMeasurementMethod.forehead:
        return '이마';
    }
  }

  /// 체온 상태 색상 반환
  Color getStatusColor(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.normal:
        return const Color(0xFF4CAF50); // 초록색
      case TemperatureStatus.mildFever:
        return const Color(0xFFFF9800); // 주황색
      case TemperatureStatus.highFever:
        return const Color(0xFFF44336); // 빨간색
      case TemperatureStatus.lowTemp:
        return const Color(0xFF2196F3); // 파란색
      case TemperatureStatus.emergency:
        return const Color(0xFF9C27B0); // 보라색
    }
  }

  /// 체온 상태 아이콘 반환
  IconData getStatusIcon(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.normal:
        return Icons.check_circle;
      case TemperatureStatus.mildFever:
        return Icons.warning;
      case TemperatureStatus.highFever:
        return Icons.local_fire_department;
      case TemperatureStatus.lowTemp:
        return Icons.ac_unit;
      case TemperatureStatus.emergency:
        return Icons.emergency;
    }
  }
}