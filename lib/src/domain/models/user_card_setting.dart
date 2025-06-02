class UserCardSetting {
  final String id;
  final String userId;
  final String cardType; // feeding, sleep, diaper, growth, health, etc.
  final bool isVisible;
  final int displayOrder;
  final Map<String, dynamic>? customSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserCardSetting({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.isVisible,
    required this.displayOrder,
    this.customSettings,
    this.createdAt,
    this.updatedAt,
  });

  factory UserCardSetting.fromJson(Map<String, dynamic> json) {
    return UserCardSetting(
      id: json['id'],
      userId: json['user_id'],
      cardType: json['card_type'],
      isVisible: json['is_visible'],
      displayOrder: json['display_order'],
      customSettings: json['custom_settings'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_type': cardType,
      'is_visible': isVisible,
      'display_order': displayOrder,
      'custom_settings': customSettings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}