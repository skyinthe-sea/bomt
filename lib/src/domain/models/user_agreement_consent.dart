import 'user_agreement_version.dart';

/// 사용자별 약관 동의 이력 모델
/// App Store Guideline 1.2 준수를 위한 동의 추적 시스템
class UserAgreementConsent {
  final String id;
  final String userId;
  final String agreementVersionId;
  final DateTime consentedAt; // 동의 시점
  final String? ipAddress; // 법적 증거를 위한 IP 기록
  final String? userAgent; // 동의 시점 사용자 환경
  final bool isWithdrawn; // 동의 철회 여부
  final DateTime? withdrawnAt; // 동의 철회 시점

  // 관련 데이터 (조인된 데이터)
  final UserAgreementVersion? agreementVersion;

  const UserAgreementConsent({
    required this.id,
    required this.userId,
    required this.agreementVersionId,
    required this.consentedAt,
    this.ipAddress,
    this.userAgent,
    required this.isWithdrawn,
    this.withdrawnAt,
    this.agreementVersion,
  });

  factory UserAgreementConsent.fromJson(Map<String, dynamic> json) {
    return UserAgreementConsent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      agreementVersionId: json['agreement_version_id'] as String,
      consentedAt: DateTime.parse(json['consented_at'] as String),
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      isWithdrawn: json['is_withdrawn'] as bool? ?? false,
      withdrawnAt: json['withdrawn_at'] != null 
          ? DateTime.parse(json['withdrawn_at'] as String)
          : null,
      agreementVersion: json['agreement_version'] != null
          ? UserAgreementVersion.fromJson(json['agreement_version'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agreement_version_id': agreementVersionId,
      'consented_at': consentedAt.toIso8601String(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'is_withdrawn': isWithdrawn,
      'withdrawn_at': withdrawnAt?.toIso8601String(),
      if (agreementVersion != null) 'agreement_version': agreementVersion!.toJson(),
    };
  }

  /// 유효한 동의인지 확인 (철회되지 않음)
  bool get isValid => !isWithdrawn;

  /// 동의 후 경과 시간
  Duration get timeSinceConsent => DateTime.now().difference(consentedAt);

  /// 철회 후 경과 시간
  Duration? get timeSinceWithdrawal => 
      withdrawnAt != null ? DateTime.now().difference(withdrawnAt!) : null;

  /// 동의 철회
  UserAgreementConsent withdraw() {
    return copyWith(
      isWithdrawn: true,
      withdrawnAt: DateTime.now(),
    );
  }

  UserAgreementConsent copyWith({
    String? id,
    String? userId,
    String? agreementVersionId,
    DateTime? consentedAt,
    String? ipAddress,
    String? userAgent,
    bool? isWithdrawn,
    DateTime? withdrawnAt,
    UserAgreementVersion? agreementVersion,
  }) {
    return UserAgreementConsent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      agreementVersionId: agreementVersionId ?? this.agreementVersionId,
      consentedAt: consentedAt ?? this.consentedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      agreementVersion: agreementVersion ?? this.agreementVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAgreementConsent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 사용자 동의 상태 요약
class UserConsentStatus {
  final String userId;
  final Map<AgreementType, bool> consentStatus; // 약관 타입별 동의 상태
  final List<UserAgreementConsent> consents; // 모든 동의 내역
  final DateTime lastUpdated;

  const UserConsentStatus({
    required this.userId,
    required this.consentStatus,
    required this.consents,
    required this.lastUpdated,
  });

  /// 모든 필수 약관에 동의했는지 확인
  bool get hasAllRequiredConsents {
    final requiredTypes = [
      AgreementType.termsOfService,
      AgreementType.communityGuidelines,
    ];
    
    return requiredTypes.every((type) => consentStatus[type] == true);
  }

  /// 특정 약관 타입에 동의했는지 확인
  bool hasConsentFor(AgreementType type) {
    return consentStatus[type] == true;
  }

  /// 동의가 필요한 약관 타입들 반환
  List<AgreementType> get missingConsents {
    return consentStatus.entries
        .where((entry) => entry.value == false)
        .map((entry) => entry.key)
        .toList();
  }
}