import '../entities/baby.dart';

abstract class BabyRepository {
  /// 아기 등록
  Future<Baby> createBaby({
    required String name,
    required DateTime birthDate,
    String? gender,
    required String userId,
  });

  /// 사용자의 아기 목록 조회
  Future<List<Baby>> getBabiesByUserId(String userId);

  /// 아기 정보 수정
  Future<Baby> updateBaby(Baby baby);

  /// 아기 삭제
  Future<void> deleteBaby(String babyId);

  /// 아기 정보 조회
  Future<Baby?> getBabyById(String babyId);

  /// 아기 프로필 이미지 업데이트
  Future<Baby> updateBabyProfileImage(String babyId, String? imageUrl);
}