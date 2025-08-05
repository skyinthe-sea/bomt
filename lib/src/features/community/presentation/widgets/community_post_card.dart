import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/community_post.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final String? selectedCategorySlug; // 현재 선택된 카테고리

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.selectedCategorySlug,
  });

  Color _getCategoryColor(String? colorString) {
    try {
      if (colorString == null) return const Color(0xFF6366F1);
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  // 카테고리 이름 현지화 함수
  String _getLocalizedCategoryName(AppLocalizations l10n, String categoryName, String? categorySlug) {
    switch (categorySlug) {
      case 'all':
        return l10n.categoryAll;
      case 'popular':
        return l10n.categoryPopular;
      default:
        // 한국어 카테고리 이름을 기반으로 현지화
        switch (categoryName) {
          case '임상':
            return l10n.categoryClinical;
          case '정보공유':
            return l10n.categoryInfoSharing;
          case '수면문제':
            return l10n.categorySleepIssues;
          case '이유식':
            return l10n.categoryBabyFood;
          case '발달단계':
            return l10n.categoryDevelopment;
          case '예방접종':
            return l10n.categoryVaccination;
          case '산후회복':
            return l10n.categoryPostpartum;
          case '일상':
            return l10n.categoryDailyLife;
          default:
            return categoryName; // 기본값으로 원래 이름 반환
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoryColor = _getCategoryColor(post.category?.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(16),
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
                      // 카테고리 태그 (항상 표시)
                      if (post.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _getLocalizedCategoryName(l10n, post.category!.name, post.category!.slug),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      
                      // 이미지 배지 (딤 처리 여부에 따라 다른 표시)
                      if (post.images.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: post.hasMosaic 
                                ? theme.colorScheme.error.withOpacity(0.15)
                                : theme.colorScheme.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: post.hasMosaic 
                                  ? theme.colorScheme.error.withOpacity(0.3)
                                  : theme.colorScheme.secondary.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                post.hasMosaic ? Icons.visibility_off : Icons.image,
                                size: 12,
                                color: post.hasMosaic 
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.secondary,
                              ),
                              if (post.images.length > 1) ...[
                                const SizedBox(width: 2),
                                Text(
                                  post.images.length.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: post.hasMosaic 
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(width: 12),
                      
                      // 작성자 정보
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: categoryColor.withOpacity(0.2),
                              backgroundImage: post.author?.profileImageUrl != null
                                  ? NetworkImage(post.author!.profileImageUrl!)
                                  : null,
                              child: post.author?.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 14,
                                      color: categoryColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.author?.nickname ?? '익명',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        post.timeAgo,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (post.isEdited) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.edited,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.primary.withOpacity(0.7),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.push_pin,
                            size: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 게시글 제목
                  Text(
                    post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 하단 상호작용 버튼들
                  Row(
                    children: [
                      // 좋아요 버튼
                      GestureDetector(
                        onTap: onLike,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: post.isLikedByCurrentUser == true
                                ? theme.colorScheme.error.withOpacity(0.1)
                                : theme.colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: post.isLikedByCurrentUser == true
                                  ? theme.colorScheme.error.withOpacity(0.3)
                                  : theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                post.isLikedByCurrentUser == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: post.isLikedByCurrentUser == true
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.likeCount.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: post.isLikedByCurrentUser == true
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 댓글 버튼
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.commentCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 조회수
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}