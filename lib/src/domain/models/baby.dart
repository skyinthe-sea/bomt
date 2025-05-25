import 'package:uuid/uuid.dart';

class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? gender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Baby({
    String? id,
    required this.name,
    required this.birthDate,
    this.gender,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birth_date']),
      gender: json['gender'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'gender': gender,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  // 나이 계산 (일 단위)
  int get ageInDays => DateTime.now().difference(birthDate).inDays;
  
  // 나이 계산 (개월 단위)
  String get ageInMonthsAndDays {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    
    if (now.day < birthDate.day) {
      months--;
    }
    
    final tempDate = DateTime(birthDate.year, birthDate.month + months, birthDate.day);
    final days = now.difference(tempDate).inDays;
    
    return '${months}개월 ${days}일';
  }
}