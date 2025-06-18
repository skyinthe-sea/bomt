import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/repositories/invitation_repository.dart';
import '../../../../domain/models/invitation.dart';
import '../../../../domain/models/invitation_request.dart';
import '../../../../services/invitation/invitation_cache_service.dart';

class SupabaseInvitationRepository implements InvitationRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final InvitationCacheService _cache = InvitationCacheService.instance;

  /// 안전한 토큰 생성 (32자 알파넘버릭)
  String _generateSecureToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<Invitation> createInvitation(CreateInvitationRequest request, String inviterId) async {
    try {
      final token = _generateSecureToken();
      final expiresAt = request.expiresAt;

      final response = await _client
          .from('invitations')
          .insert({
            'baby_id': request.babyId,
            'inviter_id': inviterId,
            'token': token,
            'role': request.role.name,
            'status': InvitationStatus.pending.name,
            'expires_at': expiresAt.toIso8601String(),
          })
          .select()
          .single();

      final invitation = Invitation.fromJson(response);
      
      // 캐시에 저장
      _cache.cacheInvitationByToken(token, invitation);
      _cache.cacheInvitationById(invitation.id, invitation);
      
      debugPrint('초대 생성 완료: ${invitation.id}');
      
      return invitation;
    } catch (e) {
      throw _handleException(e, 'createInvitation');
    }
  }

  @override
  Future<Invitation?> getInvitationByToken(String token) async {
    try {
      // 캐시에서 먼저 확인
      final cached = _cache.getCachedInvitationByToken(token);
      if (cached != null) {
        debugPrint('캐시에서 초대 조회: $token');
        return cached;
      }

      dynamic query = _client.from('invitations').select();
      query = query.eq('token', token);
      final response = await query.maybeSingle();

      final invitation = response != null ? Invitation.fromJson(response) : null;
      
      // 결과를 캐시에 저장
      if (invitation != null) {
        _cache.cacheInvitationByToken(token, invitation);
        debugPrint('초대 캐시 저장: $token');
      }
      
      return invitation;
    } catch (e) {
      throw _handleException(e, 'getInvitationByToken');
    }
  }

  @override
  Future<Invitation?> getInvitationById(String id) async {
    try {
      dynamic query = _client.from('invitations').select();
      query = query.eq('id', id);
      final response = await query.maybeSingle();

      return response != null ? Invitation.fromJson(response) : null;
    } catch (e) {
      throw _handleException(e, 'getInvitationById');
    }
  }

  @override
  Future<Invitation> acceptInvitation(AcceptInvitationRequest request) async {
    try {
      // 먼저 토큰으로 유효한 초대를 찾기
      final invitation = await getInvitationByToken(request.token);
      if (invitation == null) {
        throw Exception('초대를 찾을 수 없습니다');
      }

      if (!invitation.canAccept) {
        if (invitation.isExpired) {
          throw Exception('초대가 만료되었습니다');
        } else {
          throw Exception('이미 처리된 초대입니다');
        }
      }

      // 1. 초대 상태 업데이트
      final updatedInvitation = await _client
          .from('invitations')
          .update({
            'invitee_id': request.userId,
            'status': InvitationStatus.accepted.name,
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('token', request.token)
          .select()
          .single();

      // 2. baby_users 테이블에 새 관계 추가 (중복 체크)
      final existingRelation = await _client
          .from('baby_users')
          .select()
          .eq('baby_id', invitation.babyId)
          .eq('user_id', request.userId)
          .maybeSingle();

      if (existingRelation == null) {
        await _client
            .from('baby_users')
            .insert({
              'baby_id': invitation.babyId,
              'user_id': request.userId,
              'role': invitation.role.name,
            });
      }

      return Invitation.fromJson(updatedInvitation);
    } catch (e) {
      throw _handleException(e, 'acceptInvitation');
    }
  }

  @override
  Future<Invitation> cancelInvitation(CancelInvitationRequest request) async {
    try {
      final response = await _client
          .from('invitations')
          .update({
            'status': InvitationStatus.cancelled.name,
          })
          .eq('id', request.invitationId)
          .select()
          .single();

      return Invitation.fromJson(response);
    } catch (e) {
      throw _handleException(e, 'cancelInvitation');
    }
  }

  @override
  Future<List<Invitation>> getInvitations(InvitationFilter filter) async {
    try {
      // 타입 안전성을 위해 dynamic 사용
      dynamic query = _client.from('invitations').select();

      // 필터 적용
      if (filter.babyId != null) {
        query = query.eq('baby_id', filter.babyId!);
      }
      if (filter.inviterId != null) {
        query = query.eq('inviter_id', filter.inviterId!);
      }
      if (filter.inviteeId != null) {
        query = query.eq('invitee_id', filter.inviteeId!);
      }
      if (filter.status != null) {
        query = query.eq('status', filter.status!.name);
      }
      if (filter.role != null) {
        query = query.eq('role', filter.role!.name);
      }

      // 만료된 초대 포함 여부
      if (filter.includeExpired == false) {
        query = query.gte('expires_at', DateTime.now().toIso8601String());
      }

      // 정렬 추가
      query = query.order('created_at', ascending: false);
      
      // 페이지네이션 처리
      if (filter.offset != null && filter.limit != null) {
        final start = filter.offset!;
        final end = start + filter.limit! - 1;
        query = query.range(start, end);
      } else if (filter.limit != null) {
        query = query.limit(filter.limit!);
      }

      final response = await query;
      return response.map<Invitation>((json) => Invitation.fromJson(json)).toList();
    } catch (e) {
      throw _handleException(e, 'getInvitations');
    }
  }

  @override
  Future<List<Invitation>> getInvitationsByInviter(String inviterId) async {
    // 캐시에서 먼저 확인
    final cached = await _cache.getCachedSentInvitations(inviterId);
    if (cached != null) {
      debugPrint('캐시에서 보낸 초대 조회: $inviterId');
      return cached;
    }
    
    final invitations = await getInvitations(InvitationFilter(inviterId: inviterId));
    
    // 결과를 캐시에 저장
    await _cache.cacheSentInvitations(inviterId, invitations);
    debugPrint('보낸 초대 캐시 저장: $inviterId');
    
    return invitations;
  }

  @override
  Future<List<Invitation>> getAcceptedInvitationsByInvitee(String inviteeId) async {
    return getInvitations(InvitationFilter(
      inviteeId: inviteeId,
      status: InvitationStatus.accepted,
    ));
  }

  @override
  Future<List<Invitation>> getActiveInvitationsForBaby(String babyId) async {
    return getInvitations(InvitationFilter(
      babyId: babyId,
      status: InvitationStatus.pending,
      includeExpired: false,
    ));
  }

  @override
  Future<void> expireOldInvitations() async {
    try {
      // SQL 대신 Dart로 직접 처리
      dynamic query = _client.from('invitations')
          .update({'status': InvitationStatus.expired.name});
      query = query.eq('status', InvitationStatus.pending.name);
      query = query.lt('expires_at', DateTime.now().toIso8601String());
      await query;
      
      debugPrint('만료된 초대 정리 완료');
    } catch (e) {
      throw _handleException(e, 'expireOldInvitations');
    }
  }

  @override
  Future<Map<String, int>> getInvitationStats(String userId) async {
    try {
      // 생성한 초대 통계
      final sentResponse = await _client
          .from('invitations')
          .select('status')
          .eq('inviter_id', userId);

      // 받은 초대 통계
      final receivedResponse = await _client
          .from('invitations')
          .select('status')
          .eq('invitee_id', userId);

      final stats = <String, int>{
        'sent_total': sentResponse.length,
        'sent_pending': sentResponse.where((r) => r['status'] == 'pending').length,
        'sent_accepted': sentResponse.where((r) => r['status'] == 'accepted').length,
        'sent_expired': sentResponse.where((r) => r['status'] == 'expired').length,
        'sent_cancelled': sentResponse.where((r) => r['status'] == 'cancelled').length,
        'received_total': receivedResponse.length,
        'received_accepted': receivedResponse.where((r) => r['status'] == 'accepted').length,
      };

      return stats;
    } catch (e) {
      throw _handleException(e, 'getInvitationStats');
    }
  }

  /// 예외 처리 헬퍼
  Exception _handleException(dynamic error, String operation) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505': // unique_violation
          return Exception('이미 존재하는 초대입니다');
        case '23503': // foreign_key_violation
          return Exception('유효하지 않은 아기 정보입니다');
        case 'PGRST116': // not found
          return Exception('초대를 찾을 수 없습니다');
        default:
          return Exception('데이터베이스 오류: ${error.message}');
      }
    }
    
    return Exception('$operation 중 오류가 발생했습니다: $error');
  }
}