import 'package:uuid/uuid.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/baby.dart';
import '../../domain/repositories/baby_repository.dart';
import '../models/baby_model.dart';

class SupabaseBabyRepository implements BabyRepository {
  final _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();

  @override
  Future<Baby> createBaby({
    required String name,
    required DateTime birthDate,
    String? gender,
    required String userId,
  }) async {
    try {
      final babyId = _uuid.v4();
      final now = DateTime.now();

      // 1. babies 테이블에 아기 정보 삽입
      final babyData = {
        'id': babyId,
        'name': name,
        'birth_date': birthDate.toIso8601String(),
        'gender': gender,
        'profile_image_url': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final babyResponse = await _supabase
          .from('babies')
          .insert(babyData)
          .select()
          .single();

      // 2. baby_users 테이블에 관계 설정 (owner 권한)
      await _supabase.from('baby_users').insert({
        'id': _uuid.v4(),
        'baby_id': babyId,
        'user_id': userId,
        'role': 'owner',
        'created_at': now.toIso8601String(),
      });

      return BabyModel.fromJson(babyResponse).toEntity();
    } catch (e) {
      throw Exception('아기 등록 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<Baby>> getBabiesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('baby_users')
          .select('''
            babies (
              id,
              name,
              birth_date,
              gender,
              profile_image_url,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId);

      final List<Baby> babies = [];
      for (final item in response) {
        if (item['babies'] != null) {
          babies.add(BabyModel.fromJson(item['babies']).toEntity());
        }
      }

      return babies;
    } catch (e) {
      throw Exception('아기 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Baby> updateBaby(Baby baby) async {
    try {
      final babyModel = BabyModel.fromEntity(baby);
      final updateData = {
        'name': babyModel.name,
        'birth_date': babyModel.birthDate.toIso8601String(),
        'gender': babyModel.gender,
        'profile_image_url': babyModel.profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('babies')
          .update(updateData)
          .eq('id', baby.id)
          .select()
          .single();

      return BabyModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('아기 정보 수정 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> deleteBaby(String babyId) async {
    try {
      // 1. 먼저 baby_users 관계 삭제
      await _supabase
          .from('baby_users')
          .delete()
          .eq('baby_id', babyId);

      // 2. babies 테이블에서 삭제
      await _supabase
          .from('babies')
          .delete()
          .eq('id', babyId);
    } catch (e) {
      throw Exception('아기 삭제 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Baby?> getBabyById(String babyId) async {
    try {
      final response = await _supabase
          .from('babies')
          .select()
          .eq('id', babyId)
          .maybeSingle();

      if (response == null) return null;

      return BabyModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('아기 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Baby> updateBabyProfileImage(String babyId, String? imageUrl) async {
    try {
      final updateData = {
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('babies')
          .update(updateData)
          .eq('id', babyId)
          .select()
          .single();

      return BabyModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('아기 프로필 이미지 업데이트 중 오류가 발생했습니다: $e');
    }
  }
}