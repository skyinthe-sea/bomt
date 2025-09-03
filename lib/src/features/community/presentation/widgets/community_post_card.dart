import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/community_post.dart';

class CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final String? selectedCategorySlug; // 현재 선택된 카테고리
  final String? currentUserId; // 현재 사용자 ID

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.selectedCategorySlug,
    this.currentUserId,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  // 각 이미지별 모자이크 해제 상태 관리
  final Map<int, bool> _imageRevealState = {};

  // 특정 이미지의 모자이크 해제 상태 토글
  void _toggleImageReveal(int index) {
    setState(() {
      _imageRevealState[index] = !(_imageRevealState[index] ?? false);
    });
  }

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

  // 이미지 섹션 (1-5장 대응, 모자이크 처리 포함)
  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    if (widget.post.images.isEmpty) return const SizedBox.shrink();
    
    const double imageHeight = 200.0;
    const double spacing = 4.0;
    const double borderRadius = 12.0;
    
    // 모자이크 상태 확인 함수 (해제 상태도 고려)
    bool shouldShowMosaic(int index) {
      print('🔍 MOSAIC DEBUG: 포스트 "${widget.post.title ?? (widget.post.content.length > 20 ? widget.post.content.substring(0, 20) : widget.post.content)}" 이미지 $index 모자이크 확인');
      print('🔍 MOSAIC DEBUG: hasMosaic = ${widget.post.hasMosaic}');
      print('🔍 MOSAIC DEBUG: mosaicImages = ${widget.post.mosaicImages}');
      print('🔍 MOSAIC DEBUG: mosaicImages.length = ${widget.post.mosaicImages.length}');
      
      if (!widget.post.hasMosaic || widget.post.mosaicImages.isEmpty) {
        print('🔍 MOSAIC DEBUG: 조건1 실패 - hasMosaic=${widget.post.hasMosaic}, mosaicImages.isEmpty=${widget.post.mosaicImages.isEmpty}');
        return false;
      }
      
      if (index >= widget.post.mosaicImages.length) {
        print('🔍 MOSAIC DEBUG: 조건2 실패 - index=$index >= length=${widget.post.mosaicImages.length}');
        return false;
      }
      
      bool isBlurImage = widget.post.mosaicImages[index] == "blur";
      bool isRevealed = _imageRevealState[index] ?? false;
      print('🔍 MOSAIC DEBUG: isBlurImage = $isBlurImage, isRevealed = $isRevealed');
      
      bool result = isBlurImage && !isRevealed;
      print('🔍 MOSAIC DEBUG: shouldShowMosaic 최종 결과 = $result');
      return result; // 블러 이미지이면서 해제되지 않은 경우
    }
    
    Widget buildImageWidget(String imageUrl, int index, {double? width, double? height}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: GestureDetector(
          onTap: shouldShowMosaic(index) ? () => _toggleImageReveal(index) : null,
          child: Container(
            width: width,
            height: height ?? imageHeight,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 이미지
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                
                // 🚨 모자이크 처리 - 완전한 검정색 + 탭 기능
                if (shouldShowMosaic(index))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black, // 완전한 검정색으로 변경
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '민감한 이미지',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '탭하여 보기',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // 이미지 개수에 따른 레이아웃
    switch (widget.post.images.length) {
      case 1:
        // 1장: 전체 너비
        return buildImageWidget(widget.post.images[0], 0);
        
      case 2:
        // 2장: 1:1 분할
        return Row(
          children: [
            Expanded(child: buildImageWidget(widget.post.images[0], 0)),
            const SizedBox(width: spacing),
            Expanded(child: buildImageWidget(widget.post.images[1], 1)),
          ],
        );
        
      case 3:
        // 3장: 큰 이미지 + 2개 작은 이미지
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: buildImageWidget(widget.post.images[0], 0),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: [
                  buildImageWidget(widget.post.images[1], 1, height: (imageHeight - spacing) / 2),
                  const SizedBox(height: spacing),
                  buildImageWidget(widget.post.images[2], 2, height: (imageHeight - spacing) / 2),
                ],
              ),
            ),
          ],
        );
        
      case 4:
        // 4장: 2x2 그리드
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: buildImageWidget(widget.post.images[0], 0, height: (imageHeight - spacing) / 2)),
                const SizedBox(width: spacing),
                Expanded(child: buildImageWidget(widget.post.images[1], 1, height: (imageHeight - spacing) / 2)),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              children: [
                Expanded(child: buildImageWidget(widget.post.images[2], 2, height: (imageHeight - spacing) / 2)),
                const SizedBox(width: spacing),
                Expanded(child: buildImageWidget(widget.post.images[3], 3, height: (imageHeight - spacing) / 2)),
              ],
            ),
          ],
        );
        
      default: // 5장 이상
        // 5장: 첫 번째 큰 이미지 + 2x2 작은 이미지들
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: buildImageWidget(widget.post.images[0], 0),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: buildImageWidget(widget.post.images[1], 1, height: (imageHeight - spacing) / 2)),
                      const SizedBox(width: spacing / 2),
                      Expanded(child: buildImageWidget(widget.post.images[2], 2, height: (imageHeight - spacing) / 2)),
                    ],
                  ),
                  const SizedBox(height: spacing),
                  Row(
                    children: [
                      Expanded(
                        child: buildImageWidget(widget.post.images[3], 3, height: (imageHeight - spacing) / 2),
                      ),
                      const SizedBox(width: spacing / 2),
                      Expanded(
                        child: Stack(
                          children: [
                            buildImageWidget(widget.post.images[4], 4, height: (imageHeight - spacing) / 2),
                            if (widget.post.images.length > 5)
                              Container(
                                height: (imageHeight - spacing) / 2,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(borderRadius),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${widget.post.images.length - 4}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          ],
        );
    }
  }
  
  // 타임라인 뱃지
  Widget _buildTimelineBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
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
            Icons.timeline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.hourActivityPattern,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // X 스타일: 내용 섹션 구현 (반응형 높이 + fade out 효과)
  Widget _buildContentSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    const int maxLines = 6; // 최대 표시 줄 수
    const double fadeHeight = 40.0; // fade out 영역 높이
    
    // 내용이 비어있거나 null인 경우 처리
    final content = widget.post.content?.trim() ?? '';
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: constraints.maxWidth);
        
        // 실제 필요한 줄 수 계산
        final actualLines = textPainter.computeLineMetrics().length;
        final needsFadeOut = actualLines > maxLines;
        
        if (!needsFadeOut) {
          // 짧은 글: 그대로 표시
          return Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          );
        }
        
        // 긴 글: fade out 효과와 함께 표시
        return Stack(
          children: [
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.clip,
            ),
            
            // Fade out 효과
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: fadeHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.surface.withOpacity(0.8),
                      theme.colorScheme.surface.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            
            // "더 보기" 표시 (선택적)
            Positioned(
              bottom: 4,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  l10n.seeMore,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoryColor = _getCategoryColor(widget.post.category?.color);

    return GestureDetector(
      onTap: widget.onTap,
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
                      if (widget.post.category != null)
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
                            _getLocalizedCategoryName(l10n, widget.post.category!.name, widget.post.category!.slug),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      
                      // 이미지 배지는 제거 (실제 이미지로 대체)
                      
                      const SizedBox(width: 12),
                      
                      // 작성자 정보
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: categoryColor.withOpacity(0.2),
                              backgroundImage: widget.post.author?.profileImageUrl != null
                                  ? NetworkImage(widget.post.author!.profileImageUrl!)
                                  : null,
                              child: widget.post.author?.profileImageUrl == null
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
                                    widget.post.author?.nickname ?? '익명',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.post.timeAgo,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (widget.post.isEdited) ...[
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
                      if (widget.post.isPinned)
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
                  
                  // X 스타일: 게시글 내용 직접 표시 (fade out 효과 포함)
                  _buildContentSection(context, theme),
                  
                  // 이미지 섹션 (1-5장 대응)
                  if (widget.post.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildImageSection(context, theme),
                  ],
                  
                  // 타임라인 뱃지
                  if (widget.post.timelineData != null) ...[
                    const SizedBox(height: 8),
                    _buildTimelineBadge(context, theme),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // 하단 상호작용 버튼들
                  Row(
                    children: [
                      // 좋아요 버튼
                      Builder(
                        builder: (context) {
                          // 본인 게시글인지 확인
                          final isOwnPost = widget.currentUserId != null && 
                              widget.currentUserId == widget.post.authorId;
                          
                          return GestureDetector(
                            onTap: isOwnPost ? null : widget.onLike,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isOwnPost
                                    ? theme.colorScheme.outline.withOpacity(0.1)
                                    : widget.post.isLikedByCurrentUser == true
                                        ? theme.colorScheme.error.withOpacity(0.1)
                                        : theme.colorScheme.surface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOwnPost
                                      ? theme.colorScheme.outline.withOpacity(0.2)
                                      : widget.post.isLikedByCurrentUser == true
                                          ? theme.colorScheme.error.withOpacity(0.3)
                                          : theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.post.isLikedByCurrentUser == true
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 14,
                                    color: isOwnPost
                                        ? theme.colorScheme.outline.withOpacity(0.5)
                                        : widget.post.isLikedByCurrentUser == true
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.post.likeCount.toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isOwnPost
                                          ? theme.colorScheme.outline.withOpacity(0.5)
                                          : widget.post.isLikedByCurrentUser == true
                                              ? theme.colorScheme.error
                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                              widget.post.commentCount.toString(),
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
                            widget.post.viewCount.toString(),
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