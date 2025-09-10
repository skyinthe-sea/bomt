/// 사용자 약관 버전 관리 모델
/// App Store Guideline 1.2 준수를 위한 EULA 시스템
class UserAgreementVersion {
  final String id;
  final String versionCode; // "1.0.0", "1.1.0"
  final Map<String, String> title; // 다국어 제목
  final Map<String, String> content; // 다국어 내용
  final AgreementType agreementType;
  final bool isMandatory; // 필수 동의 여부
  final bool isActive;
  final DateTime effectiveDate; // 약관 발효일
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAgreementVersion({
    required this.id,
    required this.versionCode,
    required this.title,
    required this.content,
    required this.agreementType,
    required this.isMandatory,
    required this.isActive,
    required this.effectiveDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAgreementVersion.fromJson(Map<String, dynamic> json) {
    return UserAgreementVersion(
      id: json['id'] as String,
      versionCode: json['version_code'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      content: Map<String, String>.from(json['content'] as Map),
      agreementType: AgreementType.fromString(json['agreement_type'] as String),
      isMandatory: json['is_mandatory'] as bool,
      isActive: json['is_active'] as bool,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_code': versionCode,
      'title': title,
      'content': content,
      'agreement_type': agreementType.value,
      'is_mandatory': isMandatory,
      'is_active': isActive,
      'effective_date': effectiveDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 현재 언어로 제목 반환
  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? title['ko'] ?? '약관';
  }

  /// 현재 언어로 내용 반환
  String getLocalizedContent(String languageCode) {
    return content[languageCode] ?? content['en'] ?? content['ko'] ?? '';
  }

  UserAgreementVersion copyWith({
    String? id,
    String? versionCode,
    Map<String, String>? title,
    Map<String, String>? content,
    AgreementType? agreementType,
    bool? isMandatory,
    bool? isActive,
    DateTime? effectiveDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAgreementVersion(
      id: id ?? this.id,
      versionCode: versionCode ?? this.versionCode,
      title: title ?? this.title,
      content: content ?? this.content,
      agreementType: agreementType ?? this.agreementType,
      isMandatory: isMandatory ?? this.isMandatory,
      isActive: isActive ?? this.isActive,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAgreementVersion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 약관 종류 enum
enum AgreementType {
  termsOfService('terms_of_service'),
  privacyPolicy('privacy_policy'),
  communityGuidelines('community_guidelines'),
  dataProcessing('data_processing');

  const AgreementType(this.value);
  final String value;

  static AgreementType fromString(String value) {
    return AgreementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AgreementType.termsOfService,
    );
  }

  String getDisplayName(String languageCode) {
    switch (this) {
      case AgreementType.termsOfService:
        return {
          'ko': '이용약관',
          'en': 'Terms of Service',
          'ja': '利用規約',
        }[languageCode] ?? 'Terms of Service';
      case AgreementType.privacyPolicy:
        return {
          'ko': '개인정보 처리방침',
          'en': 'Privacy Policy',
          'ja': 'プライバシーポリシー',
        }[languageCode] ?? 'Privacy Policy';
      case AgreementType.communityGuidelines:
        return {
          'ko': '커뮤니티 가이드라인',
          'en': 'Community Guidelines',
          'ja': 'コミュニティガイドライン',
        }[languageCode] ?? 'Community Guidelines';
      case AgreementType.dataProcessing:
        return {
          'ko': '데이터 처리 동의',
          'en': 'Data Processing Agreement',
          'ja': 'データ処理同意書',
        }[languageCode] ?? 'Data Processing Agreement';
    }
  }
}