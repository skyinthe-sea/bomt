import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    print('🍼 [BABY_REPO] ======= 아기 등록 레포지토리 시작 =======');
    
    try {
      final babyId = _uuid.v4();
      final now = DateTime.now();
      
      print('🍼 [BABY_REPO] 생성된 아기 ID: $babyId');
      print('🍼 [BABY_REPO] 사용자 ID: $userId');
      print('🍼 [BABY_REPO] 현재 Supabase 세션 확인...');
      
      // 현재 세션 상태 확인 및 강제 새로고침
      print('🍼 [BABY_REPO] 세션 새로고침 시도...');
      await _supabase.auth.refreshSession();
      
      final session = _supabase.auth.currentSession;
      if (session == null) {
        print('🍼 [BABY_REPO] ❌ Supabase 세션이 없음!');
        throw Exception('인증 세션이 없습니다.');
      }
      
      print('🍼 [BABY_REPO] ✅ Supabase 세션 존재: ${session.user?.id}');
      print('🍼 [BABY_REPO] ✅ Access token 존재: ${session.accessToken?.substring(0, 20)}...');
      print('🍼 [BABY_REPO] ✅ Token expiry: ${session.expiresAt}');
      
      // 클라이언트에 토큰이 제대로 설정되어 있는지 확인
      final headers = _supabase.rest.headers;
      print('🍼 [BABY_REPO] ✅ REST client headers: $headers');

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
      
      print('🍼 [BABY_REPO] babies 테이블 삽입 시도...');
      print('🍼 [BABY_REPO] 삽입 데이터: $babyData');

      // 마지막 시도: 기존 클라이언트 사용하되 강제로 헤더 포함
      print('🍼 [BABY_REPO] 기존 클라이언트로 직접 시도...');
      
      // 🚀 RPC를 통한 안전한 아기 등록 (RLS 정책 우회)
      print('🍼 [BABY_REPO] RPC를 통한 아기 등록 시도...');
      final authenticatedUserId = session.user!.id;
      
      final rpcResult = await _supabase.rpc('create_baby_via_rpc', params: {
        'baby_id': babyId,
        'baby_name': name,
        'birth_date': birthDate.toIso8601String(),
        'gender': gender,
        'profile_image_url': null,
        'owner_user_id': authenticatedUserId,
      });
      
      print('🍼 [BABY_REPO] RPC 결과: $rpcResult');
      
      // RPC 결과 확인
      if (rpcResult['success'] != true) {
        print('🍼 [BABY_REPO] ❌ RPC 실패: ${rpcResult['error']}');
        throw Exception('RPC를 통한 아기 등록 실패: ${rpcResult['error']}');
      }
      
      final babyResponse = rpcResult['baby'];
      print('🍼 [BABY_REPO] ✅ RPC를 통한 아기 등록 성공');
      print('🍼 [BABY_REPO] 등록된 아기 데이터: $babyResponse');

      final baby = BabyModel.fromJson(babyResponse).toEntity();
      print('🍼 [BABY_REPO] ✅ 아기 등록 완료: ${baby.name} (ID: ${baby.id})');
      
      return baby;
    } catch (e, stackTrace) {
      print('🍼 [BABY_REPO] ❌ 오류 발생: $e');
      print('🍼 [BABY_REPO] 오류 타입: ${e.runtimeType}');
      print('🍼 [BABY_REPO] 스택 트레이스: $stackTrace');
      
      // Supabase 특정 에러 확인
      if (e.toString().contains('JWT')) {
        print('🍼 [BABY_REPO] JWT 토큰 관련 오류 감지');
      } else if (e.toString().contains('permission denied') || e.toString().contains('RLS')) {
        print('🍼 [BABY_REPO] RLS (Row Level Security) 정책 오류 감지');
      } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        print('🍼 [BABY_REPO] 데이터베이스 테이블이 존재하지 않음');
      } else if (e.toString().contains('violates foreign key constraint')) {
        print('🍼 [BABY_REPO] 외래 키 제약 조건 위반');
      } else if (e.toString().contains('violates unique constraint')) {
        print('🍼 [BABY_REPO] 유니크 제약 조건 위반');
      }
      
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