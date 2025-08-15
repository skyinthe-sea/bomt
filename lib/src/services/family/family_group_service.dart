import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/family_group.dart';
import '../../domain/models/family_invite.dart';

class FamilyGroupService {
  static final FamilyGroupService _instance = FamilyGroupService._internal();
  factory FamilyGroupService() => _instance;
  FamilyGroupService._internal();

  static FamilyGroupService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  /// 6자리 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// 사용자의 가족 그룹 조회
  Future<FamilyGroup?> getUserFamilyGroup(String userId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] getUserFamilyGroup - userId: $userId');
      
      final response = await _client
          .from('baby_users')
          .select('''
            family_group_id,
            family_groups!inner (*)
          ''')
          .eq('user_id', userId)
          .not('family_group_id', 'is', null)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('🏠 [FAMILY_SERVICE] No family group found for user');
        return null;
      }

      final familyGroupData = response['family_groups'];
      return FamilyGroup.fromJson(familyGroupData);
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error getting user family group: $e');
      return null;
    }
  }

  /// 새로운 가족 그룹 생성 (새 사용자용)
  Future<FamilyGroup> createFamilyGroup(String userId, {String name = '우리 가족'}) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] createFamilyGroup - userId: $userId, name: $name');
      
      final response = await _client.rpc('create_family_group_for_user', params: {
        'user_id': userId,
        'group_name': name,
      });

      if (response['success'] != true) {
        throw Exception('가족 그룹 생성 실패: ${response['error']}');
      }

      // 생성된 가족 그룹 조회
      final familyGroup = await _client
          .from('family_groups')
          .select()
          .eq('id', response['family_group_id'])
          .single();

      return FamilyGroup.fromJson(familyGroup);
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error creating family group: $e');
      throw Exception('가족 그룹 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 사용자를 가족 그룹으로 마이그레이션
  Future<FamilyGroup?> migrateUserToFamilyGroup(String userId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] migrateUserToFamilyGroup - userId: $userId');
      
      final response = await _client.rpc('migrate_user_to_family_group', params: {
        'target_user_id': userId,
      });

      if (response['success'] != true) {
        debugPrint('⚠️ [FAMILY_SERVICE] Migration failed or user already has family group');
        return null;
      }

      // 마이그레이션된 가족 그룹 조회
      final familyGroup = await _client
          .from('family_groups')
          .select()
          .eq('id', response['family_group_id'])
          .single();

      return FamilyGroup.fromJson(familyGroup);
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error migrating user to family group: $e');
      return null;
    }
  }

  /// 가족 초대 코드 생성
  Future<FamilyInvite> createFamilyInvite(String userId, {int expirationMinutes = 5}) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] createFamilyInvite - userId: $userId');
      
      // 먼저 사용자의 가족 그룹이 있는지 확인하고, 없으면 마이그레이션 시도
      var familyGroup = await getUserFamilyGroup(userId);
      if (familyGroup == null) {
        debugPrint('🏠 [FAMILY_SERVICE] No family group found, attempting migration...');
        familyGroup = await migrateUserToFamilyGroup(userId);
        if (familyGroup == null) {
          throw Exception('가족 그룹이 없습니다. 먼저 아기를 등록해주세요.');
        }
      }

      final code = _generateInviteCode();
      
      final response = await _client.rpc('create_family_invite_code', params: {
        'inviter_user_id': userId,
        'invite_code': code,
        'expires_minutes': expirationMinutes,
      });

      if (response['success'] != true) {
        throw Exception('초대 코드 생성 실패: ${response['error']}');
      }

      // 생성된 초대 코드 조회
      final invite = await _client
          .from('family_invites')
          .select()
          .eq('code', code)
          .single();

      return FamilyInvite.fromJson(invite);
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error creating family invite: $e');
      throw Exception('초대 코드 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 활성 초대 코드 조회
  Future<FamilyInvite?> getActiveFamilyInvite(String userId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] getActiveFamilyInvite - userId: $userId');
      
      final familyGroup = await getUserFamilyGroup(userId);
      if (familyGroup == null) return null;

      final response = await _client
          .from('family_invites')
          .select()
          .eq('inviter_id', userId)
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response != null ? FamilyInvite.fromJson(response) : null;
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error getting active family invite: $e');
      return null;
    }
  }

  /// 초대 코드 정보 조회 (수락 전 확인용)
  Future<Map<String, dynamic>> getFamilyInviteInfo(String code) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] getFamilyInviteInfo - code: $code');
      debugPrint('🏠 [FAMILY_SERVICE] Current auth state: ${_client.auth.currentUser?.id}');
      debugPrint('🏠 [FAMILY_SERVICE] Current session: ${_client.auth.currentSession?.accessToken?.substring(0, 20)}...');
      
      // 인증 상태 새로고침 시도
      try {
        await _client.auth.refreshSession();
        debugPrint('🏠 [FAMILY_SERVICE] Auth session refreshed');
      } catch (authError) {
        debugPrint('⚠️ [FAMILY_SERVICE] Auth refresh failed (but continuing): $authError');
      }
      
      // 1단계: 초대 코드만 먼저 조회
      debugPrint('🏠 [FAMILY_SERVICE] Querying invite code: ${code.toUpperCase()}');
      final currentTimeUtc = DateTime.now().toUtc();
      debugPrint('🏠 [FAMILY_SERVICE] Current time (UTC): ${currentTimeUtc.toIso8601String()}');
      
      final inviteResponse = await _client
          .from('family_invites')
          .select('*')
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .gt('expires_at', currentTimeUtc.toIso8601String())
          .maybeSingle();

      debugPrint('🏠 [FAMILY_SERVICE] Invite query response: $inviteResponse');

      if (inviteResponse == null) {
        // 더 자세한 디버깅: 코드가 존재하는지 확인
        final anyCodeResponse = await _client
            .from('family_invites')
            .select('*')
            .eq('code', code.toUpperCase())
            .maybeSingle();
            
        debugPrint('🏠 [FAMILY_SERVICE] Any code with this value: $anyCodeResponse');
        
        if (anyCodeResponse == null) {
          throw Exception('존재하지 않는 초대 코드입니다');
        } else if (!(anyCodeResponse['is_active'] as bool)) {
          throw Exception('이미 사용되었거나 비활성화된 초대 코드입니다');
        } else {
          final expiresAt = DateTime.parse(anyCodeResponse['expires_at'] as String);
          final nowUtc = DateTime.now().toUtc();
          debugPrint('🏠 [FAMILY_SERVICE] Code expires at: $expiresAt');
          debugPrint('🏠 [FAMILY_SERVICE] Current time (UTC): $nowUtc');
          debugPrint('🏠 [FAMILY_SERVICE] Is expired: ${nowUtc.isAfter(expiresAt)}');
          throw Exception('만료된 초대 코드입니다');
        }
      }

      debugPrint('✅ [FAMILY_SERVICE] Found valid invite code: $code');
      
      // 2단계: 가족 그룹 정보를 RPC로 조회
      try {
        final familyGroupResponse = await _client
            .rpc('get_family_group_info_for_invite', params: {
              'group_id': inviteResponse['family_group_id']
            });
            
        debugPrint('✅ [FAMILY_SERVICE] Family group info: $familyGroupResponse');
            
        return {
          'familyName': familyGroupResponse['name'] as String,
          'familyGroupId': inviteResponse['family_group_id'] as String,
          'inviterId': inviteResponse['inviter_id'] as String,
        };
      } catch (e) {
        debugPrint('⚠️ [FAMILY_SERVICE] RPC failed, using fallback: $e');
        
        // Fallback: 기본 가족 이름 사용
        return {
          'familyName': '가족',
          'familyGroupId': inviteResponse['family_group_id'] as String,
          'inviterId': inviteResponse['inviter_id'] as String,
        };
      }
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error getting family invite info: $e');
      debugPrint('❌ [FAMILY_SERVICE] Error type: ${e.runtimeType}');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 코드 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 가족 초대 수락
  Future<bool> acceptFamilyInvite(String code, String userId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] acceptFamilyInvite - code: $code, userId: $userId');
      
      final response = await _client.rpc('accept_family_invite', params: {
        'invite_code': code.toUpperCase(),
        'accepter_user_id': userId,
      });

      if (response['success'] != true) {
        throw Exception(response['error'] ?? '초대 수락에 실패했습니다');
      }

      debugPrint('✅ [FAMILY_SERVICE] Family invite accepted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error accepting family invite: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 수락 중 오류가 발생했습니다: $e');
    }
  }

  /// 가족 그룹의 모든 구성원 조회
  Future<List<Map<String, dynamic>>> getFamilyMembers(String familyGroupId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] getFamilyMembers - familyGroupId: $familyGroupId');
      
      final response = await _client
          .from('baby_users')
          .select('''
            user_id,
            role,
            created_at
          ''')
          .eq('family_group_id', familyGroupId);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error getting family members: $e');
      return [];
    }
  }

  /// 가족 그룹의 모든 아기 조회
  Future<List<Map<String, dynamic>>> getFamilyBabies(String familyGroupId) async {
    try {
      debugPrint('🏠 [FAMILY_SERVICE] getFamilyBabies - familyGroupId: $familyGroupId');
      
      final response = await _client
          .from('baby_users')
          .select('''
            babies (*)
          ''')
          .eq('family_group_id', familyGroupId);

      return response
          .where((item) => item['babies'] != null)
          .map((item) => item['babies'] as Map<String, dynamic>)
          .toSet() // 중복 제거
          .toList();
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error getting family babies: $e');
      return [];
    }
  }

  /// 만료된 초대 코드 정리
  Future<void> cleanupExpiredInvites() async {
    try {
      await _client
          .from('family_invites')
          .update({'is_active': false})
          .eq('is_active', true)
          .lt('expires_at', DateTime.now().toUtc().toIso8601String());
      
      debugPrint('✅ [FAMILY_SERVICE] Expired invites cleaned up');
    } catch (e) {
      debugPrint('❌ [FAMILY_SERVICE] Error cleaning up expired invites: $e');
    }
  }
}