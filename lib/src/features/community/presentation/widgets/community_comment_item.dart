import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/community_comment.dart';
import '../../../../presentation/providers/community_post_provider.dart';

class CommunityCommentItem extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String, String)? onAuthorNameTap; // (commentId, nickname) -> void
  final bool isReply;
  final bool isAuthor;
  final Function(String)? isCommentAuthor; // authorId -> bool
  final bool isHighlighted; // 하이라이트 여부
  final String? postAuthorId; // 게시글 작성자 ID (OP 표시용)

  const CommunityCommentItem({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onAuthorNameTap,
    this.isReply = false,
    this.isAuthor = false,
    this.isCommentAuthor,
    this.isHighlighted = false,
    this.postAuthorId,
  });

  // 삭제된 댓글 내용 표시
  Widget _buildDeletedContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.delete_outline,
            size: 16,
            color: theme.colorScheme.outline.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            comment.content, // "(작성자에 의해 삭제되었습니다)"
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // @태그가 포함된 댓글 내용을 하이라이트하여 표시
  Widget _buildContentWithTags(BuildContext context, String content) {
    final theme = Theme.of(context);
    final tagPattern = RegExp(r'(@\w+)');
    final matches = tagPattern.allMatches(content);
    
    if (matches.isEmpty) {
      // 태그가 없으면 일반 텍스트로 표시
      return Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
          height: 1.5,
        ),
      );
    }
    
    // 태그가 있으면 RichText로 하이라이트 표시
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;
    
    for (final match in matches) {
      // 태그 이전 텍스트 추가
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: content.substring(lastMatchEnd, match.start),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ));
      }
      
      // 태그 텍스트 추가 (하이라이트)
      spans.add(TextSpan(
        text: match.group(0),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ));
      
      lastMatchEnd = match.end;
    }
    
    // 마지막 태그 이후 텍스트 추가
    if (lastMatchEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastMatchEnd),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedScale(
          scale: isHighlighted ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              left: isReply ? 32 : 0, // 답글일 때 들여쓰기
              top: 8,
              right: 0,
              bottom: 8,
            ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? theme.colorScheme.primary.withOpacity(0.15) // 하이라이트 색상
                : isReply 
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? theme.colorScheme.primary.withOpacity(0.3) // 하이라이트 테두리
                  : isReply 
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.outline.withOpacity(0.1),
              width: isHighlighted ? 2.0 : 1.0, // 하이라이트 시 두껴 테두리
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: isHighlighted ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 정보 (작성자, 시간)
                Row(
                  children: [
                    // 프로필 이미지
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      backgroundImage: comment.author?.profileImageUrl != null
                          ? NetworkImage(comment.author!.profileImageUrl!)
                          : null,
                      child: comment.author?.profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 16,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 작성자 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: onAuthorNameTap != null 
                                ? () => onAuthorNameTap!(comment.id, comment.author?.nickname ?? '익명')
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    comment.author?.nickname ?? '익명',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: onAuthorNameTap != null 
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      decoration: onAuthorNameTap != null 
                                          ? TextDecoration.underline
                                          : null,
                                      decorationColor: theme.colorScheme.primary.withOpacity(0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // OP (게시글 작성자) 배지
                                if (postAuthorId != null && comment.authorId == postAuthorId) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      '작성자',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                comment.timeAgo,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              if (comment.isEdited) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(수정됨)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 더보기 버튼 (삭제되지 않은 댓글만)
                    if (!comment.isDeleted)
                      PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'copy':
                            _copyComment(context);
                            break;
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            _showDeleteDialog(context);
                            break;
                          case 'report':
                            _showReportDialog(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        // 복사 옵션 (모든 사용자)
                        PopupMenuItem<String>(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy,
                                size: 18,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              const SizedBox(width: 8),
                              const Text('복사'),
                            ],
                          ),
                        ),
                        if (isAuthor) ...[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text('수정'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                const Text('삭제'),
                              ],
                            ),
                          ),
                        ],
                        if (!isAuthor)
                          PopupMenuItem<String>(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.report,
                                  size: 18,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(width: 8),
                                const Text('신고'),
                              ],
                            ),
                          ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 댓글 내용 (@태그 하이라이트 포함)
                comment.isDeleted 
                    ? _buildDeletedContent(context)
                    : _buildContentWithTags(context, comment.content),
                
                const SizedBox(height: 16),
                
                // 하단 액션 버튼들 (삭제된 댓글은 제한된 액션만)
                if (!comment.isDeleted)
                  Row(
                    children: [
                      // 좋아요 버튼
                      GestureDetector(
                        onTap: onLike,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: comment.isLikedByCurrentUser == true
                                ? theme.colorScheme.error.withOpacity(0.1)
                                : theme.colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: comment.isLikedByCurrentUser == true
                                  ? theme.colorScheme.error.withOpacity(0.3)
                                  : theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.isLikedByCurrentUser == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: comment.isLikedByCurrentUser == true
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              // 좋아요 수 표시 (5개 이상일 때만 표시)
                            if (comment.likeCount >= 5) ...[
                                const SizedBox(width: 4),
                                Text(
                                  comment.likeCount.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: comment.isLikedByCurrentUser == true
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 답글 버튼 (최상위 댓글에만 표시)
                      if (!isReply)
                        GestureDetector(
                          onTap: onReply,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.reply,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '답글',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // 삭제된 댓글의 경우 삭제 시간 표시
                  Text(
                    comment.deletedAt != null 
                        ? '${_formatDeletedTime(comment.deletedAt!)}에 삭제됨'
                        : '삭제됨',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline.withOpacity(0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
            ),
          ),
        ),
      ),
    
      // 답글 목록 표시 (최상위 댓글에만)
      if (!isReply && comment.replies != null && comment.replies!.isNotEmpty)
        ...comment.replies!.asMap().entries.map((entry) {
          final replyIndex = entry.key;
          final reply = entry.value;
          
          return _AnimatedReplyItem(
            key: ValueKey('reply_${reply.id}'),
            index: replyIndex,
            child: CommunityCommentItem(
              comment: reply,
              onLike: onLike,
              isReply: true,
              isAuthor: isCommentAuthor != null ? isCommentAuthor!(reply.authorId) : false,
              isCommentAuthor: isCommentAuthor,
              onEdit: onEdit,
              onDelete: onDelete,
              onAuthorNameTap: onAuthorNameTap,
              isHighlighted: false, // 답글은 하이라이트하지 않음
              postAuthorId: postAuthorId,
            ),
          );
        }),
      
      // 답글 더 보기 버튼 (최상위 댓글에서 더 많은 답글이 있을 때)
      if (!isReply)
        Consumer<CommunityPostProvider>(
          builder: (context, provider, child) {
            final hasMoreReplies = provider.hasMoreReplies(comment.id);
            final totalReplyCount = provider.getReplyCount(comment.id);
            final currentReplyCount = comment.replies?.length ?? 0;
            final remainingReplyCount = totalReplyCount - currentReplyCount;
            
            if (!hasMoreReplies || remainingReplyCount <= 0) {
              return const SizedBox.shrink();
            }
            
            final theme = Theme.of(context);
            
            return Container(
              margin: const EdgeInsets.only(left: 32, top: 8),
              child: GestureDetector(
                onTap: () => provider.loadAllReplies(comment.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '답글 ${remainingReplyCount}개 더 보기',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    ],
  );
  }

  // 댓글 복사
  void _copyComment(BuildContext context) {
    // 삭제된 댓글은 복사하지 않음
    if (comment.isDeleted) return;
    
    Clipboard.setData(ClipboardData(text: comment.content));
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text('댓글이 복사되었습니다'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 삭제 시간 포맷팅
  String _formatDeletedTime(DateTime deletedAt) {
    final now = DateTime.now();
    final difference = now.difference(deletedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('댓글 신고'),
        content: const Text('이 댓글을 신고하시겠습니까?\n부적절한 내용이나 스팸으로 신고됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다.')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }
}

// 답글용 애니메이션 위젯
class _AnimatedReplyItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedReplyItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedReplyItem> createState() => _AnimatedReplyItemState();
}

class _AnimatedReplyItemState extends State<_AnimatedReplyItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 80)), // 답글은 더 빠르게
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0), // 왼쪽에서 슬라이드
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}