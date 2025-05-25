class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  Baby copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}