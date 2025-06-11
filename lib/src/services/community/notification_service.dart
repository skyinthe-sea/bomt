import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/community_notification.dart';

class NotificationService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // 알림 생성
  Future<void> createNotification({
    required String recipientId,
    String? senderId,
    required NotificationType type,
    required String title,
    String? content,
    String? referenceId,
    NotificationReferenceType? referenceType,
  }) async {
    try {
      // 자기 자신에게는 알림을 보내지 않음
      if (recipientId == senderId) return;

      await _supabase.from('notifications').insert({
        'recipient_id': recipientId,
        'sender_id': senderId,
        'type': type.value,
        'title': title,
        'content': content,
        'reference_id': referenceId,
        'reference_type': referenceType?.value,
      });
    } catch (e) {
      throw Exception('알림 생성 실패: $e');
    }
  }

  // 사용자의 알림 목록 조회
  Future<List<CommunityNotification>> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
    bool? isRead,
  }) async {
    try {
      var query = _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', userId);

      final response = isRead != null
          ? await query
              .eq('is_read', isRead)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1)
          : await query
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
      return (response as List)
          .map((item) => CommunityNotification.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('알림 조회 실패: $e');
    }
  }

  // 알림 읽음 처리
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('알림 읽음 처리 실패: $e');
    }
  }

  // 모든 알림 읽음 처리
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('모든 알림 읽음 처리 실패: $e');
    }
  }

  // 읽지 않은 알림 개수 조회
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      throw Exception('읽지 않은 알림 개수 조회 실패: $e');
    }
  }

  // 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('알림 삭제 실패: $e');
    }
  }

  // 오래된 알림 정리 (30일 이상된 읽은 알림)
  Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      await _supabase
          .from('notifications')
          .delete()
          .eq('is_read', true)
          .lt('created_at', thirtyDaysAgo.toIso8601String());
    } catch (e) {
      throw Exception('오래된 알림 정리 실패: $e');
    }
  }

  // 게시글 좋아요 알림 생성
  Future<void> createPostLikeNotification({
    required String postId,
    required String postAuthorId,
    required String likerUserId,
    required String likerNickname,
    required String postTitle,
  }) async {
    await createNotification(
      recipientId: postAuthorId,
      senderId: likerUserId,
      type: NotificationType.like,
      title: '$likerNickname님이 회원님의 게시글을 좋아합니다',
      content: postTitle,
      referenceId: postId,
      referenceType: NotificationReferenceType.post,
    );
  }

  // 댓글 알림 생성
  Future<void> createCommentNotification({
    required String postId,
    required String postAuthorId,
    required String commenterUserId,
    required String commenterNickname,
    required String postTitle,
  }) async {
    await createNotification(
      recipientId: postAuthorId,
      senderId: commenterUserId,
      type: NotificationType.comment,
      title: '$commenterNickname님이 회원님의 게시글에 댓글을 남겼습니다',
      content: postTitle,
      referenceId: postId,
      referenceType: NotificationReferenceType.post,
    );
  }

  // 댓글 좋아요 알림 생성
  Future<void> createCommentLikeNotification({
    required String commentId,
    required String commentAuthorId,
    required String likerUserId,
    required String likerNickname,
    required String commentContent,
  }) async {
    await createNotification(
      recipientId: commentAuthorId,
      senderId: likerUserId,
      type: NotificationType.like,
      title: '$likerNickname님이 회원님의 댓글을 좋아합니다',
      content: commentContent.length > 30 
          ? '${commentContent.substring(0, 30)}...'
          : commentContent,
      referenceId: commentId,
      referenceType: NotificationReferenceType.comment,
    );
  }

  // 대댓글 알림 생성
  Future<void> createReplyNotification({
    required String postId,
    required String parentCommentAuthorId,
    required String replierUserId,
    required String replierNickname,
    required String replyContent,
  }) async {
    await createNotification(
      recipientId: parentCommentAuthorId,
      senderId: replierUserId,
      type: NotificationType.reply,
      title: '$replierNickname님이 회원님의 댓글에 답글을 남겼습니다',
      content: replyContent.length > 30 
          ? '${replyContent.substring(0, 30)}...'
          : replyContent,
      referenceId: postId,
      referenceType: NotificationReferenceType.post,
    );
  }
}