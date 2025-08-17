import 'package:flutter/material.dart';
import '../../../../domain/models/community_comment.dart';
import 'community_comment_item.dart';

class CommunityCommentList extends StatelessWidget {
  final List<CommunityComment> comments;
  final Function(String) onCommentLike;
  final Function(String, String)? onReply; // (commentId, nickname)
  final Function(String)? onCommentEdit; // commentId
  final Function(String)? onCommentDelete; // commentId
  final Function(String) isCommentAuthor; // authorId -> bool
  final Function(String, String)? onAuthorNameTap; // (commentId, nickname) -> void
  final bool isLoading;
  final String? highlightedCommentId; // 하이라이트된 댓글 ID
  final String? postAuthorId; // 게시글 작성자 ID (OP 표시용)
  final String? currentUserId; // 현재 사용자 ID

  const CommunityCommentList({
    super.key,
    required this.comments,
    required this.onCommentLike,
    this.onReply,
    this.onCommentEdit,
    this.onCommentDelete,
    required this.isCommentAuthor,
    this.onAuthorNameTap,
    required this.isLoading,
    this.highlightedCommentId,
    this.postAuthorId,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '아직 댓글이 없어요',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '첫 번째 댓글을 작성해보세요!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final comment = comments[index];
          
          return _AnimatedCommentItem(
            key: ValueKey('comment_${comment.id}'),
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: CommunityCommentItem(
                comment: comment,
                onLike: () => onCommentLike(comment.id),
                onReply: onReply != null 
                    ? () => onReply!(comment.id, comment.author?.nickname ?? '익명')
                    : null,
                onEdit: onCommentEdit != null 
                    ? () => onCommentEdit!(comment.id)
                    : null,
                onDelete: onCommentDelete != null 
                    ? () => onCommentDelete!(comment.id)
                    : null,
                isAuthor: isCommentAuthor(comment.authorId),
                isCommentAuthor: isCommentAuthor,
                onAuthorNameTap: onAuthorNameTap != null 
                    ? (commentId, nickname) => onAuthorNameTap!(commentId, nickname)
                    : null,
                isHighlighted: highlightedCommentId == comment.id,
                postAuthorId: postAuthorId,
                currentUserId: currentUserId,
              ),
            ),
          );
        },
        childCount: comments.length,
      ),
    );
  }
}

// 2025 트렌드 애니메이션 효과가 적용된 댓글 아이템
class _AnimatedCommentItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedCommentItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedCommentItem> createState() => _AnimatedCommentItemState();
}

class _AnimatedCommentItemState extends State<_AnimatedCommentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)), // 스타거드 애니메이션
      vsync: this,
    );

    // 2025 트렌드: 부드러운 이징 곡선
    final curve = Curves.easeOutBack;
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: curve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: curve),
    ));

    // 약간의 지연 후 애니메이션 시작
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
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}