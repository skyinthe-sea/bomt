import '../../domain/entities/baby.dart';

class BabyModel extends Baby {
  const BabyModel({
    required super.id,
    required super.name,
    required super.birthDate,
    super.gender,
    required super.createdAt,
    required super.updatedAt,
  });

  /// JSON에서 BabyModel 생성
  factory BabyModel.fromJson(Map<String, dynamic> json) {
    return BabyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String).toLocal(),
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  /// BabyModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Baby Entity에서 BabyModel 생성
  factory BabyModel.fromEntity(Baby baby) {
    return BabyModel(
      id: baby.id,
      name: baby.name,
      birthDate: baby.birthDate,
      gender: baby.gender,
      createdAt: baby.createdAt,
      updatedAt: baby.updatedAt,
    );
  }

  /// BabyModel을 Baby Entity로 변환
  Baby toEntity() {
    return Baby(
      id: id,
      name: name,
      birthDate: birthDate,
      gender: gender,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}