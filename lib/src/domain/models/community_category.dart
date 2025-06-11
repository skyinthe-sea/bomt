class CommunityCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String color;
  final String? icon;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.color,
    this.icon,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityCategory.fromJson(Map<String, dynamic> json) {
    try {
      return CommunityCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        color: json['color'] as String? ?? '#6366F1',
        icon: json['icon'] as String?,
        displayOrder: json['display_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('ERROR: CommunityCategory.fromJson 실패');
      print('ERROR 상세: $e');
      print('JSON 데이터: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'color': color,
      'icon': icon,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommunityCategory copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? color,
    String? icon,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityCategory &&
        other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.description == description &&
        other.color == color &&
        other.icon == icon &&
        other.displayOrder == displayOrder &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      slug,
      description,
      color,
      icon,
      displayOrder,
      isActive,
      createdAt,
      updatedAt,
    );
  }
}