class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? gender;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.gender,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Baby copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}