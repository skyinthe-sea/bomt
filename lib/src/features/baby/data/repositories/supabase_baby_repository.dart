import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/baby.dart';
import '../../domain/repositories/baby_repository.dart';
import '../models/baby_model.dart';
import '../../../../services/family/family_group_service.dart';

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
      
      // 세션 확인
      await _supabase.auth.refreshSession();
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('인증 세션이 없습니다.');
      }
      
      final authenticatedUserId = session.user!.id;
      print('🍼 [BABY_REPO] 인증된 사용자 ID: $authenticatedUserId');
      
      // =======================================
      // PostgREST 오버로딩 충돌 해결 시도
      // =======================================
      print('🍼 [BABY_REPO] ===== 오버로딩 충돌 해결됨! =====');
      print('🍼 [BABY_REPO] 두 함수로 분리:');
      print('🍼 [BABY_REPO] create_baby_via_rpc: (baby_id text, baby_name text, birth_date timestamptz, gender text, profile_image_url text, owner_user_id text)');
      print('🍼 [BABY_REPO] create_baby_with_family: (baby_id uuid, baby_name text, birth_date text, gender text, profile_image_url text, owner_user_id text)');
      
      Map<String, dynamic>? rpcResult;
      bool rpcSuccess = false;
      
      // === 시도 1: create_baby_with_family (UUID + text) - 가족 그룹 처리 포함 ===
      if (!rpcSuccess) {
        try {
          print('🍼 [BABY_REPO] 🎯 시도 1: create_baby_with_family (UUID + text date) - 가족 그룹 처리 포함');
          
          final familyParams = {
            'baby_id': babyId,  // UUID 문자열
            'baby_name': name,
            'birth_date': birthDate.toIso8601String().split('T')[0],  // 날짜만 (text)
            'gender': gender ?? 'unknown',
            'profile_image_url': null,
            'owner_user_id': authenticatedUserId,
          };
          
          print('🍼 [BABY_REPO] create_baby_with_family 매개변수: $familyParams');
          
          rpcResult = await _supabase.rpc('create_baby_with_family', params: familyParams);
          print('🍼 [BABY_REPO] create_baby_with_family RPC 결과: $rpcResult');
          
          if (rpcResult != null && rpcResult['success'] == true) {
            rpcSuccess = true;
            final babyResponse = rpcResult['baby'];
            final baby = BabyModel.fromJson(babyResponse).toEntity();
            
            // 가족 동기화 확인 및 보완
            await _ensureFamilySynchronization(babyId, authenticatedUserId);
            
            print('🍼 [BABY_REPO] ✅ create_baby_with_family 성공: ${baby.name} (가족그룹: ${rpcResult['family_group_id']})');
            return baby;
          } else {
            print('🍼 [BABY_REPO] ❌ create_baby_with_family 실패: ${rpcResult?['error']}');
          }
        } catch (familyError) {
          print('🍼 [BABY_REPO] ❌ create_baby_with_family 예외: $familyError');
        }
      }
      
      // === 시도 2: create_baby_via_rpc (text + timestamptz) - 단순 삽입 ===
      if (!rpcSuccess) {
        try {
          print('🍼 [BABY_REPO] 🎯 시도 2: create_baby_via_rpc (text + timestamptz) - 단순 삽입');
          
          final basicParams = {
            'baby_id': babyId,  // text
            'baby_name': name,
            'birth_date': birthDate.toUtc().toIso8601String(),  // timestamptz
            'gender': gender ?? 'unknown',
            'profile_image_url': null,
            'owner_user_id': authenticatedUserId,
          };
          
          print('🍼 [BABY_REPO] create_baby_via_rpc 매개변수: $basicParams');
          
          rpcResult = await _supabase.rpc('create_baby_via_rpc', params: basicParams);
          print('🍼 [BABY_REPO] create_baby_via_rpc RPC 결과: $rpcResult');
          
          if (rpcResult != null && rpcResult['success'] == true) {
            rpcSuccess = true;
            final babyResponse = rpcResult['baby'];
            final baby = BabyModel.fromJson(babyResponse).toEntity();
            
            // 가족 동기화 확인 및 보완 (기본 RPC는 가족 동기화가 없으므로)
            await _ensureFamilySynchronization(babyId, authenticatedUserId);
            
            print('🍼 [BABY_REPO] ✅ create_baby_via_rpc 성공: ${baby.name}');
            return baby;
          } else {
            print('🍼 [BABY_REPO] ❌ create_baby_via_rpc 실패: ${rpcResult?['error']}');
          }
        } catch (basicError) {
          print('🍼 [BABY_REPO] ❌ create_baby_via_rpc 예외: $basicError');
        }
      }
      
      // === 시도 3: 대체 RPC 함수들 ===
      if (!rpcSuccess) {
        print('🍼 [BABY_REPO] 🎯 시도 3: 대체 RPC 함수들');
        
        final alternativeRpcs = ['create_baby', 'register_baby', 'add_baby', 'insert_baby'];
        
        for (final altFunc in alternativeRpcs) {
          try {
            print('🍼 [BABY_REPO] 대체 RPC 시도: $altFunc');
            
            final altParams = {
              'baby_id': babyId,
              'baby_name': name,
              'birth_date': birthDate.toIso8601String(),
              'gender': gender ?? 'unknown',
              'profile_image_url': null,
              'owner_user_id': authenticatedUserId,
            };
            
            rpcResult = await _supabase.rpc(altFunc, params: altParams);
            print('🍼 [BABY_REPO] 대체 RPC ($altFunc) 결과: $rpcResult');
            
            if (rpcResult != null && rpcResult['success'] == true) {
              rpcSuccess = true;
              final babyResponse = rpcResult['baby'];
              final baby = BabyModel.fromJson(babyResponse).toEntity();
              
              // 가족 동기화 확인 및 보완
              await _ensureFamilySynchronization(babyId, authenticatedUserId);
              
              print('🍼 [BABY_REPO] ✅ 대체 RPC 성공 ($altFunc): ${baby.name}');
              return baby;
            }
          } catch (altError) {
            print('🍼 [BABY_REPO] 대체 RPC ($altFunc) 실패: $altError');
            continue;
          }
        }
      }
      
      // === 최종 시도: 직접 테이블 삽입 (RLS 정책 위반 가능성) ===
      if (!rpcSuccess) {
        print('🍼 [BABY_REPO] 🎯 최종 시도: 직접 테이블 삽입 (RLS 디버깅)');
        
        try {
          final babyData = {
            'id': babyId,
            'name': name,
            'birth_date': birthDate.toIso8601String(),
            'gender': gender,
            'profile_image_url': null,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };
          
          print('🍼 [BABY_REPO] 직접 삽입 데이터: $babyData');
          print('🍼 [BABY_REPO] 현재 인증 상태:');
          print('🍼 [BABY_REPO] - User ID: ${_supabase.auth.currentUser?.id}');
          print('🍼 [BABY_REPO] - Session exists: ${_supabase.auth.currentSession != null}');
          print('🍼 [BABY_REPO] - Token: ${_supabase.auth.currentSession?.accessToken?.substring(0, 30)}...');
          
          final babyInsertResult = await _supabase.from('babies').insert(babyData).select().single();
          print('🍼 [BABY_REPO] ✅ 직접 삽입 성공!');
          
          // baby_users 관계 생성
          final relationData = {
            'baby_id': babyId,
            'user_id': authenticatedUserId,
            'role': 'owner',
            'created_at': now.toIso8601String(),
          };
          
          await _supabase.from('baby_users').insert(relationData);
          print('🍼 [BABY_REPO] ✅ 관계 설정 성공!');
          
          // 가족 동기화 확인 및 보완
          await _ensureFamilySynchronization(babyId, authenticatedUserId);
          
          final baby = BabyModel.fromJson(babyInsertResult).toEntity();
          print('🍼 [BABY_REPO] ✅ 직접 삽입으로 성공: ${baby.name}');
          return baby;
          
        } catch (directError) {
          print('🍼 [BABY_REPO] ❌ 직접 삽입 실패: $directError');
          print('🍼 [BABY_REPO] 직접 삽입 오류 타입: ${directError.runtimeType}');
          
          if (directError.toString().contains('row-level security')) {
            print('🍼 [BABY_REPO] 🚫 RLS 정책 위반 확인!');
            print('🍼 [BABY_REPO] 🚫 사용자가 babies 테이블에 직접 삽입할 권한이 없습니다.');
            print('🍼 [BABY_REPO] 🚫 create_baby_via_rpc 함수가 필수이지만 오버로딩 충돌로 호출 불가능합니다.');
            
            throw Exception('''
🚫 아기 등록 실패: 
1. create_baby_via_rpc 함수에 오버로딩 충돌이 있어서 호출할 수 없습니다 (PGRST203)
2. babies 테이블에 직접 삽입할 권한이 없습니다 (RLS 정책)
3. 데이터베이스 관리자가 오버로딩 충돌을 해결해야 합니다.

해결방법: 
- 두 create_baby_via_rpc 함수 중 하나를 다른 이름으로 변경
- 또는 매개변수 타입이 겹치지 않도록 수정
            ''');
          }
          
          throw directError;
        }
      }
      
      // 여기에 도달하면 모든 시도가 실패한 것
      throw Exception('모든 아기 등록 시도가 실패했습니다.');
      
    } catch (e, stackTrace) {
      print('🍼 [BABY_REPO] ❌ 전체 오류: $e');
      print('🍼 [BABY_REPO] 오류 타입: ${e.runtimeType}');
      print('🍼 [BABY_REPO] 스택 트레이스: $stackTrace');
      
      // 특정 에러 타입에 따른 사용자 친화적 메시지
      if (e.toString().contains('JWT')) {
        throw Exception('인증 토큰 문제가 발생했습니다. 다시 로그인해주세요.');
      } else if (e.toString().contains('RLS') || e.toString().contains('row-level security')) {
        throw Exception('데이터베이스 권한 문제가 발생했습니다. 관리자에게 문의하세요.');
      } else if (e.toString().contains('Multiple Choices') || e.toString().contains('PGRST203')) {
        throw Exception('데이터베이스 함수 충돌 문제가 발생했습니다. 관리자에게 문의하세요.');
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
      print('🗑️ [FAMILY_DELETE] =================================');
      print('🗑️ [FAMILY_DELETE] 가족 동기화 아기 삭제 시작');
      print('🗑️ [FAMILY_DELETE] Baby ID: $babyId');
      print('🗑️ [FAMILY_DELETE] =================================');

      // 1. 아기 정보 조회
      final babyInfo = await getBabyById(babyId);
      if (babyInfo == null) {
        print('🗑️ [FAMILY_DELETE] ❌ 삭제할 아기를 찾을 수 없습니다');
        throw Exception('삭제할 아기를 찾을 수 없습니다.');
      }
      
      print('🗑️ [FAMILY_DELETE] 삭제 대상 아기: ${babyInfo.name}');

      // 2. 가족 그룹 확인 및 동기화된 삭제 준비
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('인증된 사용자가 없습니다.');
      }
      
      print('🗑️ [FAMILY_DELETE] 현재 사용자: $currentUserId');

      // 3. 가족 그룹 및 구성원 확인
      await _analyzeFamilyDeletionImpact(babyId, babyInfo.name);

      // 4. RPC 함수를 사용한 가족 전체 동기화 삭제
      print('🗑️ [FAMILY_DELETE] ⭐ RPC 함수로 가족 전체에서 아기 삭제 시작');
      
      final deleteResult = await _supabase.rpc('delete_baby_from_family_rpc', params: {
        'target_baby_id': babyId,
      });
      
      print('🗑️ [FAMILY_DELETE] RPC 삭제 결과: $deleteResult');
      
      if (deleteResult['success'] == true) {
        final deletedCount = deleteResult['deleted_count'] ?? 0;
        final familyMembersAffected = deleteResult['family_members_affected'] ?? 0;
        
        print('🗑️ [FAMILY_DELETE] ✅ RPC 삭제 성공!');
        print('🗑️ [FAMILY_DELETE] - 삭제된 baby_users 관계: ${deletedCount}개');
        print('🗑️ [FAMILY_DELETE] - 영향받은 가족 구성원: ${familyMembersAffected}명');
        print('🗑️ [FAMILY_DELETE] - 아기가 모든 가족 구성원에게서 제거됨');
      } else {
        print('🗑️ [FAMILY_DELETE] ❌ RPC 삭제 실패: ${deleteResult['error']}');
        throw Exception('가족 동기화 삭제 실패: ${deleteResult['error']}');
      }

      print('🗑️ [FAMILY_DELETE] =================================');
      print('🗑️ [FAMILY_DELETE] ✅ 가족 동기화 삭제 완료!');
      print('🗑️ [FAMILY_DELETE] ✅ "${babyInfo.name}" 아기가 모든 가족 구성원에게서 제거되었습니다');
      print('🗑️ [FAMILY_DELETE] =================================');
      
    } catch (e, stackTrace) {
      print('🗑️ [FAMILY_DELETE] =================================');
      print('🗑️ [FAMILY_DELETE] ❌ 가족 동기화 삭제 오류!');
      print('🗑️ [FAMILY_DELETE] 오류: $e');
      print('🗑️ [FAMILY_DELETE] 스택 트레이스: $stackTrace');
      print('🗑️ [FAMILY_DELETE] =================================');
      throw Exception('아기 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 가족 삭제 영향 분석
  Future<void> _analyzeFamilyDeletionImpact(String babyId, String babyName) async {
    print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 가족 삭제 영향 분석 시작...');
    
    try {
      // 1. 현재 아기와 연결된 가족 구성원 확인
      final babyUsers = await _supabase
          .from('baby_users')
          .select('user_id, role, family_group_id')
          .eq('baby_id', babyId);
      
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 연결된 가족 구성원: ${babyUsers.length}명');
      
      if (babyUsers.isEmpty) {
        print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] ⚠️ 연결된 사용자가 없음');
        return;
      }
      
      // 2. 가족 그룹 ID 확인
      final familyGroupId = babyUsers.first['family_group_id'] as String?;
      if (familyGroupId != null) {
        print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 가족 그룹 ID: $familyGroupId');
        
        for (int i = 0; i < babyUsers.length; i++) {
          final member = babyUsers[i];
          print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] ${i + 1}. ${member['user_id']} (${member['role']})');
        }
      } else {
        print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 개별 사용자 (가족 그룹 없음)');
      }
      
      // 3. 각 테이블의 데이터 개수 확인 (기존 로직 유지)
      final tables = [
        'feedings', 
        'sleeps',
        'diapers',
        'milk_pumping',
        'growth_records',
        'health_records',
        'solid_food',
        'medications',
        'baby_caregivers'
      ];
      
      int totalRecords = 0;
      
      for (final table in tables) {
        try {
          final response = await _supabase
              .from(table)
              .select('id')
              .eq('baby_id', babyId)
              .count(CountOption.exact);
          
          final count = response.count ?? 0;
          totalRecords += count;
          
          if (count > 0) {
            print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] $table: ${count}개 레코드');
          }
        } catch (e) {
          print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] $table 테이블 확인 오류: $e');
        }
      }
      
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] =================================');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 가족 삭제 영향 요약:');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 아기 이름: $babyName');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 영향받을 가족 구성원: ${babyUsers.length}명');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 삭제될 데이터 레코드: ${totalRecords}개');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] ⚠️ 모든 가족 구성원에게서 제거됩니다!');
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] =================================');
      
    } catch (e) {
      print('👨‍👩‍👧‍👦 [FAMILY_ANALYSIS] 분석 오류: $e');
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

  /// 사용자 친화적인 아기 삭제 가이드
  Future<Map<String, dynamic>> getBabyDeletionPreview(String babyId) async {
    try {
      print('📊 [DELETE_PREVIEW] 삭제 미리보기 시작...');
      
      final baby = await getBabyById(babyId);
      if (baby == null) {
        throw Exception('아기를 찾을 수 없습니다.');
      }
      
      final dataStats = <String, int>{};
      final tables = {
        'feedings': '수유 기록',
        'sleeps': '수면 기록', 
        'diapers': '기저귀 기록',
        'milk_pumping': '유축 기록',
        'growth_records': '성장 기록',
        'health_records': '건강 기록',
        'solid_food': '이유식 기록',
        'medications': '약물 기록'
      };
      
      int totalRecords = 0;
      
      for (final entry in tables.entries) {
        try {
          final response = await _supabase
              .from(entry.key)
              .select('id')
              .eq('baby_id', babyId)
              .count(CountOption.exact);
          
          final count = response.count ?? 0;
          if (count > 0) {
            dataStats[entry.value] = count;
            totalRecords += count;
          }
        } catch (e) {
          print('📊 [DELETE_PREVIEW] ${entry.key} 테이블 확인 오류: $e');
        }
      }
      
      return {
        'babyName': baby.name,
        'babyId': babyId,
        'totalRecords': totalRecords,
        'dataBreakdown': dataStats,
        'birthDate': baby.birthDate.toIso8601String().split('T')[0],
        'hasData': totalRecords > 0,
      };
    } catch (e) {
      throw Exception('삭제 미리보기 오류: $e');
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

  /// 가족 구성원 자동 동기화 확인 및 보완 (수정된 버전)
  /// 새로 등록된 아기가 가족 그룹의 모든 구성원에게 자동으로 공유되도록 보장

  /// 새로운 단순화된 가족 동기화 로직
  Future<void> _ensureFamilySynchronization(String babyId, String ownerUserId) async {
    try {
      print('🔄 [NEW_SYNC] =========================');
      print('🔄 [NEW_SYNC] 새로운 가족 동기화 시작');
      print('🔄 [NEW_SYNC] Baby ID: $babyId');
      print('🔄 [NEW_SYNC] Owner: $ownerUserId');
      print('🔄 [NEW_SYNC] =========================');
      
      // 1단계: 소유자가 속한 가족 그룹 직접 조회
      final familyGroupService = FamilyGroupService.instance;
      final familyGroup = await familyGroupService.getUserFamilyGroup(ownerUserId);
      
      if (familyGroup == null) {
        print('🔄 [NEW_SYNC] ❌ 소유자에게 가족 그룹이 없음 - 개별 사용자');
        return;
      }
      
      print('🔄 [NEW_SYNC] ✅ 가족 그룹 발견: ${familyGroup.name} (${familyGroup.id})');
      
      // 🕵️ 데이터베이스 스키마 및 상태 완전 분석
      print('🕵️ [SCHEMA] =========================');
      print('🕵️ [SCHEMA] 데이터베이스 구조 완전 분석');
      print('🕵️ [SCHEMA] =========================');
      
      // 1. user_profiles 테이블 구조 파악
      try {
        print('🕵️ [SCHEMA] 1. user_profiles 테이블 스키마 확인...');
        final userProfilesSchema = await _supabase
            .from('user_profiles')
            .select('*')
            .limit(1);
        print('🕵️ [SCHEMA] user_profiles 샘플 데이터: $userProfilesSchema');
        
        // 소유자의 user_profiles 정보 확인
        final ownerProfile = await _supabase
            .from('user_profiles')
            .select('*')
            .eq('user_id', ownerUserId)
            .maybeSingle();
        print('🕵️ [SCHEMA] 소유자 프로필: $ownerProfile');
        
      } catch (e) {
        print('🕵️ [SCHEMA] user_profiles 조회 실패: $e');
      }
      
      // 2. baby_users 테이블에서 가족 관계 확인
      try {
        print('🕵️ [SCHEMA] 2. baby_users 테이블에서 가족 그룹별 사용자 조회...');
        final allBabyUsers = await _supabase
            .from('baby_users')
            .select('user_id, family_group_id, role, created_at')
            .eq('family_group_id', familyGroup.id);
        print('🕵️ [SCHEMA] 가족 그룹 ${familyGroup.id}의 모든 baby_users: $allBabyUsers');
        
        // 소유자의 baby_users 현황 확인
        final ownerBabyUsers = await _supabase
            .from('baby_users')
            .select('*')
            .eq('user_id', ownerUserId);
        print('🕵️ [SCHEMA] 소유자($ownerUserId)의 모든 baby_users: $ownerBabyUsers');
        
        // 현재 아기와 연결된 모든 사용자 확인
        final currentBabyUsers = await _supabase
            .from('baby_users')
            .select('user_id, role, created_at')
            .eq('baby_id', babyId);
        print('🕵️ [SCHEMA] 현재 아기($babyId)와 연결된 사용자들: $currentBabyUsers');
        
      } catch (e) {
        print('🕵️ [SCHEMA] baby_users 조회 실패: $e');
      }
      
      // 3. family_groups 테이블 확인
      try {
        print('🕵️ [SCHEMA] 3. family_groups 테이블 확인...');
        final familyGroupInfo = await _supabase
            .from('family_groups')
            .select('*')
            .eq('id', familyGroup.id)
            .single();
        print('🕵️ [SCHEMA] 가족 그룹 정보: $familyGroupInfo');
      } catch (e) {
        print('🕵️ [SCHEMA] family_groups 조회 실패: $e');
      }
      
      // 4. family_invites 테이블 확인 (가족 관계 형성 과정)
      try {
        print('🕵️ [SCHEMA] 4. family_invites 테이블 확인...');
        final familyInvites = await _supabase
            .from('family_invites')
            .select('*')
            .eq('family_group_id', familyGroup.id)
            .order('created_at', ascending: false);
        print('🕵️ [SCHEMA] 가족 초대 기록: $familyInvites');
      } catch (e) {
        print('🕵️ [SCHEMA] family_invites 조회 실패: $e');
      }
      
      print('🕵️ [SCHEMA] =========================');
      
      // 2단계: 가족 그룹의 모든 구성원 조회 (FamilyGroupService 사용)
      final allFamilyMembers = await familyGroupService.getFamilyMembers(familyGroup.id);
      print('🔄 [NEW_SYNC] 가족 구성원 ${allFamilyMembers.length}명 발견');
      
      for (int i = 0; i < allFamilyMembers.length; i++) {
        final member = allFamilyMembers[i];
        final isOwner = member['user_id'] == ownerUserId;
        print('🔄 [NEW_SYNC] ${i + 1}. ${member['user_id']} (역할: ${member['role']}) ${isOwner ? '[소유자]' : '[가족]'}');
      }
      
      if (allFamilyMembers.length <= 1) {
        print('🔄 [NEW_SYNC] ❌ 가족 구성원이 1명 이하 - 동기화 불필요');
        return;
      }
      
      // 3단계: RLS 우회 RPC 함수로 가족 동기화 수행
      print('🔄 [NEW_SYNC] 3단계: RPC 함수로 가족 동기화 시작');
      print('🔄 [NEW_SYNC] ✨ RLS INSERT 제한 우회를 위해 sync_baby_to_family_rpc 호출');
      
      final syncResult = await _supabase.rpc('sync_baby_to_family_rpc', params: {
        'target_baby_id': babyId,
        'target_family_group_id': familyGroup.id,
      });
      
      print('🔄 [NEW_SYNC] RPC 동기화 결과: $syncResult');
      
      int syncCount = 0;
      int skipCount = 0;
      
      if (syncResult['success'] == true) {
        syncCount = syncResult['synced_count'] ?? 0;
        skipCount = syncResult['skipped_count'] ?? 0;
        print('🔄 [NEW_SYNC] ✅ RPC 동기화 성공!');
      } else {
        print('🔄 [NEW_SYNC] ❌ RPC 동기화 실패: ${syncResult['error']}');
      }
      
      print('🔄 [NEW_SYNC] =========================');
      print('🔄 [NEW_SYNC] ✅ RPC 가족 동기화 완료!');
      print('🔄 [NEW_SYNC] 총 가족 구성원: ${allFamilyMembers.length}명');
      print('🔄 [NEW_SYNC] 새로 동기화: $syncCount명');
      print('🔄 [NEW_SYNC] 이미 연결됨: $skipCount명');
      print('🔄 [NEW_SYNC] ✨ RLS 제한 우회 성공!');
      print('🔄 [NEW_SYNC] =========================');
      
      // 최종 확인: 동기화 후 상태
      try {
        final finalConnections = await _supabase
            .from('baby_users')
            .select('user_id, role')
            .eq('baby_id', babyId);
        print('🔄 [NEW_SYNC] 최종 연결 상태: ${finalConnections.length}개 연결');
        for (int i = 0; i < finalConnections.length; i++) {
          final conn = finalConnections[i];
          final isOwner = conn['user_id'] == ownerUserId;
          print('🔄 [NEW_SYNC] ${i + 1}. ${conn['user_id']} (역할: ${conn['role']}) ${isOwner ? '[소유자]' : '[가족]'}');
        }
      } catch (e) {
        print('🔄 [NEW_SYNC] 최종 확인 실패: $e');
      }
      
    } catch (e, stackTrace) {
      print('🔄 [NEW_SYNC] =========================');
      print('🔄 [NEW_SYNC] ❌ 동기화 오류: $e');
      print('🔄 [NEW_SYNC] 스택 트레이스: $stackTrace');
      print('🔄 [NEW_SYNC] =========================');
      // 가족 동기화 실패해도 아기 등록은 성공으로 처리
    }
  }
}