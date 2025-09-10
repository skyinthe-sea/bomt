import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/user_block.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

/// 사용자 차단 관리 서비스
/// App Store Guideline 1.2 준수를 위한 사용자 차단 시스템
class UserBlockService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AppEventBus _eventBus = AppEventBus.instance;

  // 캐시 (현재 사용자의 차단 목록)
  Map<String, List<UserBlock>> _blockedUsersCache = {};
  Map<String, DateTime> _cacheTime = {};

  /// 사용자가 차단한 사용자 목록 조회 (캐시 활용)
  Future<List<UserBlock>> getBlockedUsers(String userId) async {
    try {
      // 캐시가 있고 2분 이내라면 캐시 사용
      if (_blockedUsersCache.containsKey(userId) &&
          _cacheTime[userId] != null &&
          DateTime.now().difference(_cacheTime[userId]!).inMinutes < 2) {
        print('DEBUG: 캐시된 차단 목록 사용: ${_blockedUsersCache[userId]!.length}개');
        return _blockedUsersCache[userId]!;
      }

      print('DEBUG: 사용자 차단 목록 조회 - userId: $userId');
      
      final response = await _supabase
          .from('user_blocks')
          .select('''
            *,
            blocked_user:user_profiles!user_blocks_blocked_user_id_fkey(*)
          ''')
          .eq('blocker_user_id', userId)
          .order('created_at', ascending: false);

      final blockedUsers = (response as List)
          .map((item) => UserBlock.fromJson(item))
          .toList();

      // 캐시 업데이트
      _blockedUsersCache[userId] = blockedUsers;
      _cacheTime[userId] = DateTime.now();

      print('DEBUG: 차단 목록 ${blockedUsers.length}개 조회 완료');
      return blockedUsers;
    } catch (e) {
      print('ERROR: 차단 목록 조회 실패: $e');
      throw Exception('차단 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 사용자 차단
  Future<UserBlock> blockUser({
    required String blockerUserId,
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      // 자기 자신을 차단하려는 경우 방지
      if (blockerUserId == blockedUserId) {
        throw Exception('자기 자신을 차단할 수 없습니다');
      }

      print('DEBUG: 사용자 차단 - blocker: $blockerUserId, blocked: $blockedUserId');
      
      final blockData = {
        'blocker_user_id': blockerUserId,
        'blocked_user_id': blockedUserId,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_blocks')
          .insert(blockData)
          .select('''
            *,
            blocked_user:user_profiles!user_blocks_blocked_user_id_fkey(*)
          ''')
          .single();

      final userBlock = UserBlock.fromJson(response);

      // 캐시 초기화 (변경사항 반영)
      _clearUserCache(blockerUserId);

      // 차단 이벤트 발생
      _eventBus.emitDataSync(UserBlockedEvent(
        blockerUserId: blockerUserId,
        blockedUserId: blockedUserId,
        userBlock: userBlock,
      ));

      print('DEBUG: 사용자 차단 완료');
      return userBlock;
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        print('WARNING: 이미 차단한 사용자입니다');
        throw Exception('이미 차단한 사용자입니다');
      }
      
      print('ERROR: 사용자 차단 실패: $e');
      throw Exception('사용자 차단 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 차단 해제
  Future<void> unblockUser({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    try {
      print('DEBUG: 사용자 차단 해제 - blocker: $blockerUserId, blocked: $blockedUserId');
      
      final result = await _supabase
          .from('user_blocks')
          .delete()
          .eq('blocker_user_id', blockerUserId)
          .eq('blocked_user_id', blockedUserId)
          .select();

      if ((result as List).isEmpty) {
        throw Exception('차단 기록을 찾을 수 없습니다');
      }

      // 캐시 초기화 (변경사항 반영)
      _clearUserCache(blockerUserId);

      // 차단 해제 이벤트 발생
      _eventBus.emitDataSync(UserUnblockedEvent(
        blockerUserId: blockerUserId,
        blockedUserId: blockedUserId,
      ));

      print('DEBUG: 사용자 차단 해제 완료');
    } catch (e) {
      print('ERROR: 사용자 차단 해제 실패: $e');
      throw Exception('차단 해제 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 사용자를 차단했는지 확인
  Future<bool> isUserBlocked({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    try {
      final blockedUsers = await getBlockedUsers(blockerUserId);
      return blockedUsers.any((block) => block.blockedUserId == blockedUserId);
    } catch (e) {
      print('ERROR: 차단 상태 확인 실패: $e');
      return false;
    }
  }

  /// 사용자의 차단 상태 요약 정보 조회
  Future<UserBlockStatus> getUserBlockStatus(String userId) async {
    try {
      // 내가 차단한 사용자들
      final blockedUsers = await getBlockedUsers(userId);

      // 나를 차단한 사용자들은 성능상의 이유로 필요시에만 조회
      // 일반적으로 사용자는 자신을 차단한 사람이 누구인지 알 필요가 없음

      return UserBlockStatus(
        userId: userId,
        blockedUsers: blockedUsers,
        blockingUsers: [], // 필요시에만 구현
        totalBlockedCount: blockedUsers.length,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('ERROR: 사용자 차단 상태 조회 실패: $e');
      throw Exception('차단 상태를 확인하는데 실패했습니다: $e');
    }
  }

  /// 차단된 사용자의 콘텐츠를 필터링하기 위한 ID 목록 반환
  Future<List<String>> getBlockedUserIds(String userId) async {
    try {
      final blockedUsers = await getBlockedUsers(userId);
      return blockedUsers.map((block) => block.blockedUserId).toList();
    } catch (e) {
      print('ERROR: 차단된 사용자 ID 목록 조회 실패: $e');
      return [];
    }
  }

  /// 사용자가 차단당한 횟수 조회 (관리자용)
  Future<int> getBlockedCount(String userId) async {
    try {
      final response = await _supabase
          .from('user_blocks')
          .select('id')
          .eq('blocked_user_id', userId)
          .count();

      return response.count;
    } catch (e) {
      print('ERROR: 차단당한 횟수 조회 실패: $e');
      return 0;
    }
  }

  /// 차단 통계 조회 (관리자용)
  Future<Map<String, int>> getBlockingStatistics() async {
    try {
      // 전체 차단 관계 수
      final totalResponse = await _supabase
          .from('user_blocks')
          .select('id')
          .count();

      // 최근 24시간 내 차단 수
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final recentResponse = await _supabase
          .from('user_blocks')
          .select('id')
          .gte('created_at', yesterday.toIso8601String())
          .count();

      return {
        'total_blocks': totalResponse.count,
        'recent_blocks': recentResponse.count,
      };
    } catch (e) {
      print('ERROR: 차단 통계 조회 실패: $e');
      return {'total_blocks': 0, 'recent_blocks': 0};
    }
  }

  /// 사용자별 캐시 초기화
  void _clearUserCache(String userId) {
    _blockedUsersCache.remove(userId);
    _cacheTime.remove(userId);
  }

  /// 전체 캐시 초기화
  void clearCache() {
    _blockedUsersCache.clear();
    _cacheTime.clear();
  }

  /// 특정 사용자들이 서로 차단 관계인지 확인 (양방향)
  Future<bool> areUsersBlocking(String userId1, String userId2) async {
    try {
      final isUser1BlockingUser2 = await isUserBlocked(
        blockerUserId: userId1,
        blockedUserId: userId2,
      );
      
      final isUser2BlockingUser1 = await isUserBlocked(
        blockerUserId: userId2,
        blockedUserId: userId1,
      );

      return isUser1BlockingUser2 || isUser2BlockingUser1;
    } catch (e) {
      print('ERROR: 상호 차단 상태 확인 실패: $e');
      return false;
    }
  }
}

/// 차단 관련 이벤트들
class UserBlockedEvent extends DataSyncEvent {
  final String blockerUserId;
  final String blockedUserId;
  final UserBlock userBlock;

  UserBlockedEvent({
    required this.blockerUserId,
    required this.blockedUserId,
    required this.userBlock,
  }) : super(
      type: DataSyncEventType.userBlocked,
      babyId: blockerUserId,
      affectedDate: DateTime.now(),
      action: DataSyncAction.created,
      metadata: {
        'blockedUserId': blockedUserId,
        'userBlockId': userBlock.id,
      },
    );
}

class UserUnblockedEvent extends DataSyncEvent {
  final String blockerUserId;
  final String blockedUserId;

  UserUnblockedEvent({
    required this.blockerUserId,
    required this.blockedUserId,
  }) : super(
      type: DataSyncEventType.userUnblocked,
      babyId: blockerUserId,
      affectedDate: DateTime.now(),
      action: DataSyncAction.deleted,
      metadata: {
        'blockedUserId': blockedUserId,
      },
    );
}