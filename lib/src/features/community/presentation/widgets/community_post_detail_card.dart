import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../domain/models/community_post.dart';

class CommunityPostDetailCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onLike;
  final Function(String)? onAuthorNameTap;

  const CommunityPostDetailCard({
    super.key,
    required this.post,
    this.onLike,
    this.onAuthorNameTap,
  });

  Color _getCategoryColor(String? colorString) {
    try {
      if (colorString == null) return const Color(0xFF6366F1);
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(post.category?.color);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 정보 (카테고리, 작성자, 시간)
                Row(
                  children: [
                    // 카테고리 태그
                    if (post.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          post.category!.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    const SizedBox(width: 12),
                    
                    // 작성자 정보
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: categoryColor.withOpacity(0.2),
                            backgroundImage: post.author?.profileImageUrl != null
                                ? NetworkImage(post.author!.profileImageUrl!)
                                : null,
                            child: post.author?.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 18,
                                    color: categoryColor,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: onAuthorNameTap != null 
                                      ? () => onAuthorNameTap!(post.author?.nickname ?? '익명')
                                      : null,
                                  child: Text(
                                    post.author?.nickname ?? '익명',
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
                                Row(
                                  children: [
                                    Text(
                                      post.timeAgo,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                    if (post.isEdited) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(수정됨)',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary.withOpacity(0.7),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.viewCount.toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 핀 아이콘
                    if (post.isPinned)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 게시글 제목
                Text(
                  post.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 게시글 내용
                Text(
                  post.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
                
                // 이미지가 있는 경우
                if (post.images.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: post.images.length == 1 ? 1 : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: post.images.length == 1 ? 16 / 9 : 1,
                    ),
                    itemCount: post.images.length > 4 ? 4 : post.images.length,
                    itemBuilder: (context, index) {
                      final isLastItem = index == 3 && post.images.length > 4;
                      
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              post.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                );
                              },
                            ),
                            if (isLastItem)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${post.images.length - 3}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 하단 상호작용 버튼들
                Row(
                  children: [
                    // 좋아요 버튼
                    GestureDetector(
                      onTap: onLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: post.isLikedByCurrentUser == true
                              ? theme.colorScheme.error.withOpacity(0.15)
                              : theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: post.isLikedByCurrentUser == true
                                ? theme.colorScheme.error.withOpacity(0.3)
                                : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.isLikedByCurrentUser == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: post.isLikedByCurrentUser == true
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post.likeCount.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: post.isLikedByCurrentUser == true
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '좋아요',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: post.isLikedByCurrentUser == true
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 댓글 수 표시
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.commentCount.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '댓글',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}