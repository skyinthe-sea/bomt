import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleInviteService {
  static final SimpleInviteService _instance = SimpleInviteService._internal();
  factory SimpleInviteService() => _instance;
  SimpleInviteService._internal();

  static SimpleInviteService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  /// 간단한 6자리 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// 초대 코드 생성 및 저장
  Future<String> createInviteCode(String userId, String babyId) async {
    try {
      final code = _generateInviteCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));

      // 기존 활성 초대 코드가 있으면 비활성화
      await _client
          .from('simple_invites')
          .update({'is_active': false})
          .eq('inviter_id', userId)
          .eq('baby_id', babyId)
          .eq('is_active', true);

      // 새 초대 코드 생성
      await _client.from('simple_invites').insert({
        'code': code,
        'inviter_id': userId,
        'baby_id': babyId,
        'expires_at': expiresAt.toIso8601String(),
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ 초대 코드 생성 완료: $code (만료: $expiresAt)');
      return code;

    } catch (e) {
      debugPrint('❌ 초대 코드 생성 실패: $e');
      throw Exception('초대 코드 생성에 실패했습니다: $e');
    }
  }

  /// 초대 코드 정보 조회 (실제 참여하지 않고 정보만 가져오기)
  Future<Map<String, dynamic>> getInviteInfo(String code) async {
    try {
      // 1단계: 초대 코드가 존재하는지 확인
      final codeExistsResponse = await _client
          .from('simple_invites')
          .select('*, babies(name)')
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (codeExistsResponse == null) {
        throw Exception('존재하지 않는 초대 코드입니다');
      }

      // 2단계: 활성 상태인지 확인
      if (!(codeExistsResponse['is_active'] as bool)) {
        throw Exception('이미 사용되었거나 비활성화된 초대 코드입니다');
      }

      // 3단계: 만료 시간 확인
      final expiresAt = DateTime.parse(codeExistsResponse['expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('만료된 초대 코드입니다');
      }

      final inviteResponse = codeExistsResponse;

      final babyName = inviteResponse['babies']['name'] as String;
      
      return {
        'babyName': babyName,
        'babyId': inviteResponse['baby_id'] as String,
        'inviterId': inviteResponse['inviter_id'] as String,
      };

    } catch (e) {
      debugPrint('❌ 초대 코드 정보 조회 실패: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 코드 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 초대 코드로 참여
  Future<bool> joinWithInviteCode(String code, String userId) async {
    try {
      // 1단계: 초대 코드가 존재하는지 확인
      final codeExistsResponse = await _client
          .from('simple_invites')
          .select('*, babies(name)')
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (codeExistsResponse == null) {
        throw Exception('존재하지 않는 초대 코드입니다');
      }

      // 2단계: 활성 상태인지 확인
      if (!(codeExistsResponse['is_active'] as bool)) {
        throw Exception('이미 사용되었거나 비활성화된 초대 코드입니다');
      }

      // 3단계: 만료 시간 확인
      final expiresAt = DateTime.parse(codeExistsResponse['expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('만료된 초대 코드입니다');
      }

      final inviteResponse = codeExistsResponse;

      final babyId = inviteResponse['baby_id'] as String;
      final inviterId = inviteResponse['inviter_id'] as String;
      final babyName = inviteResponse['babies']['name'] as String;

      // 본인이 생성한 초대 코드인지 확인
      if (inviterId == userId) {
        throw Exception('본인이 생성한 초대 코드는 사용할 수 없습니다');
      }

      // 이미 참여한 사용자인지 확인
      final existingMember = await _client
          .from('baby_users')
          .select()
          .eq('baby_id', babyId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('이미 $babyName의 육아에 참여하고 있습니다');
      }

      // 기존 baby_users 관계 모두 삭제 (사용자가 참여 중인 모든 아기 관계 제거)
      await _client
          .from('baby_users')
          .delete()
          .eq('user_id', userId);

      debugPrint('✅ 기존 아기 관계 삭제 완료');

      // baby_users 테이블에 새 구성원 추가
      await _client.from('baby_users').insert({
        'baby_id': babyId,
        'user_id': userId,
        'role': 'owner', // 확실한 역할로 설정
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ 새로운 아기 관계 생성 완료');

      // 초대 코드 비활성화
      await _client
          .from('simple_invites')
          .update({
            'is_active': false,
            'used_by': userId,
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('code', code.toUpperCase());

      // SharedPreferences에 아기 정보 업데이트 트리거
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_baby_data'); // 캐시 삭제하여 새로고침 유도

      debugPrint('✅ 초대 코드로 참여 완료: $code -> $babyName');
      return true;

    } catch (e) {
      debugPrint('❌ 초대 코드 참여 실패: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('초대 참여 중 오류가 발생했습니다: $e');
    }
  }

  /// 활성 초대 코드 조회
  Future<String?> getActiveInviteCode(String userId, String babyId) async {
    try {
      final response = await _client
          .from('simple_invites')
          .select('code')
          .eq('inviter_id', userId)
          .eq('baby_id', babyId)
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      return response?['code'] as String?;
    } catch (e) {
      debugPrint('활성 초대 코드 조회 실패: $e');
      return null;
    }
  }

  /// 만료된 초대 코드 정리
  Future<void> cleanupExpiredCodes() async {
    try {
      await _client
          .from('simple_invites')
          .update({'is_active': false})
          .eq('is_active', true)
          .lt('expires_at', DateTime.now().toIso8601String());
      
      debugPrint('✅ 만료된 초대 코드 정리 완료');
    } catch (e) {
      debugPrint('만료된 초대 코드 정리 실패: $e');
    }
  }
}