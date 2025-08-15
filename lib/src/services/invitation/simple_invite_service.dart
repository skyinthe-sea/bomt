import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../family/family_group_service.dart';

class SimpleInviteService {
  static final SimpleInviteService _instance = SimpleInviteService._internal();
  factory SimpleInviteService() => _instance;
  SimpleInviteService._internal();

  static SimpleInviteService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;
  final FamilyGroupService _familyService = FamilyGroupService.instance;

  /// 간단한 6자리 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// 초대 코드 생성 및 저장 (가족 그룹 기반)
  Future<String> createInviteCode(String userId, [String? babyId]) async {
    try {
      debugPrint('📧 [SIMPLE_INVITE] Creating family invite code for user: $userId');
      
      // 🚀 가족 그룹 기반 초대 코드 생성
      final familyInvite = await _familyService.createFamilyInvite(userId);
      
      debugPrint('✅ [SIMPLE_INVITE] Family invite code created: ${familyInvite.code}');
      return familyInvite.code;

    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 초대 코드 생성 실패: $e');
      throw Exception('초대 코드 생성에 실패했습니다: $e');
    }
  }

  /// 초대 코드 정보 조회 (실제 참여하지 않고 정보만 가져오기)
  Future<Map<String, dynamic>> getInviteInfo(String code) async {
    try {
      debugPrint('🔍 [SIMPLE_INVITE] getInviteInfo - code: $code');
      
      // 🚀 가족 그룹 기반 초대 정보 조회
      final familyInviteInfo = await _familyService.getFamilyInviteInfo(code);
      
      debugPrint('✅ [SIMPLE_INVITE] Family invite info retrieved: $familyInviteInfo');
      
      return {
        'babyName': familyInviteInfo['familyName'],
        'familyName': familyInviteInfo['familyName'],
        'familyGroupId': familyInviteInfo['familyGroupId'],
        'inviterId': familyInviteInfo['inviterId'],
      };

    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 초대 코드 정보 조회 실패: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 코드 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 초대 코드로 참여 (가족 그룹 기반)
  Future<bool> joinWithInviteCode(String code, String userId) async {
    try {
      debugPrint('🔍 [SIMPLE_INVITE] joinWithInviteCode - code: $code, userId: $userId');
      
      // 🚀 가족 그룹 기반 초대 수락
      final success = await _familyService.acceptFamilyInvite(code, userId);
      
      if (success) {
        // SharedPreferences에 아기 정보 업데이트 트리거
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_baby_data'); // 캐시 삭제하여 새로고침 유도
        
        debugPrint('✅ [SIMPLE_INVITE] 가족 초대 수락 완료: $code');
        return true;
      }
      
      return false;

    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 초대 코드 참여 실패: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 참여 중 오류가 발생했습니다: $e');
    }
  }

  /// 활성 초대 코드 조회 (가족 그룹 기반)
  Future<String?> getActiveInviteCode(String userId, [String? babyId]) async {
    try {
      debugPrint('🔍 [SIMPLE_INVITE] getActiveInviteCode - userId: $userId');
      
      // 🚀 가족 그룹 기반 활성 초대 코드 조회
      final activeInvite = await _familyService.getActiveFamilyInvite(userId);
      
      return activeInvite?.code;
    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 활성 초대 코드 조회 실패: $e');
      return null;
    }
  }

  /// 만료된 초대 코드 정리 (가족 그룹 기반)
  Future<void> cleanupExpiredCodes() async {
    try {
      // 🚀 가족 그룹 기반 만료된 초대 코드 정리
      await _familyService.cleanupExpiredInvites();
      
      debugPrint('✅ [SIMPLE_INVITE] 만료된 초대 코드 정리 완료');
    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 만료된 초대 코드 정리 실패: $e');
    }
  }

  /// 🔧 레거시 메서드: 사용되지 않음 (가족 그룹 시스템에서 자동 처리)
  @Deprecated('Use FamilyGroupService.cleanupExpiredInvites() instead')
  Future<void> _cleanupOrphanedInviteCodes() async {
    debugPrint('⚠️ [SIMPLE_INVITE] _cleanupOrphanedInviteCodes is deprecated. Using family group service instead.');
    await _familyService.cleanupExpiredInvites();
  }

  /// 🔧 개발용: 모든 초대 코드 정리 (테스트 시 사용)
  @Deprecated('Use database migration instead')
  Future<void> cleanupAllInviteCodes() async {
    try {
      debugPrint('🗑️ [SIMPLE_INVITE] 레거시 초대 코드 정리 시작...');
      
      // 기존 simple_invites 테이블의 모든 초대 코드 삭제
      await _client
          .from('simple_invites')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // 모든 레코드 삭제
      
      debugPrint('✅ [SIMPLE_INVITE] 레거시 초대 코드 정리 완료');
    } catch (e) {
      debugPrint('❌ [SIMPLE_INVITE] 초대 코드 정리 실패: $e');
    }
  }
}