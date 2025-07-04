import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/community_post.dart';
import '../../../../domain/models/timeline_item.dart';
import '../../../../core/providers/baby_provider.dart';
import '../../../../services/timeline/timeline_service.dart';
import '../../../timeline/presentation/widgets/circular_timeline_chart.dart';
import 'mosaic_image_widget.dart';

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

  // 저장된 타임라인 데이터를 TimelineItem으로 변환하는 함수
  List<TimelineItem> _parseStoredTimelineData(Map<String, dynamic> timelineData) {
    try {
      // 새로운 형태의 저장된 데이터가 있는지 확인
      if (timelineData.containsKey('timelineItems')) {
        final storedItems = timelineData['timelineItems'] as List<dynamic>;
        print('DEBUG: Found stored timelineItems: ${storedItems.length} items');
        
        return storedItems.map((item) => TimelineItem(
          id: item['id'] ?? '',
          type: TimelineItemType.values.firstWhere(
            (e) => e.name == item['type'],
            orElse: () => TimelineItemType.feeding,
          ),
          timestamp: DateTime.parse(item['timestamp']),
          title: item['title'] ?? '',
          subtitle: item['subtitle'],
          data: Map<String, dynamic>.from(item['data'] ?? {}),
          isOngoing: item['isOngoing'] ?? false,
          colorCode: item['colorCode'],
        )).toList();
      }
      
      return [];
    } catch (e) {
      print('DEBUG: Error parsing stored timeline data: $e');
      return [];
    }
  }

  // 최적화된 타임라인 데이터 로딩 (저장된 데이터 우선 사용)
  Future<List<TimelineItem>> _loadTimelineDataFromDatabase(BuildContext context, DateTime date) async {
    try {
      // 1. 먼저 저장된 타임라인 데이터가 있는지 확인
      if (post.timelineData != null) {
        print('DEBUG: Post has stored timeline data, trying to parse it first');
        final storedItems = _parseStoredTimelineData(post.timelineData!);
        if (storedItems.isNotEmpty) {
          print('DEBUG: Successfully loaded ${storedItems.length} items from stored data');
          return storedItems;
        }
      }

      // 2. BabyProvider의 선택된 아기 사용
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      
      if (babyProvider.selectedBaby == null) {
        print('DEBUG: Post detail - No baby selected, falling back to legacy data');
        return _convertLegacyTimelineData(post.timelineData ?? {});
      }
      
      final currentBaby = babyProvider.selectedBaby!;
      print('DEBUG: Post detail - Loading fresh timeline data - date: $date, baby: ${currentBaby.id}');

      // 3. TimelineService를 사용해서 데이터 가져오기
      final timelineService = TimelineService.instance;
      final timelineItems = await timelineService.getTimelineItemsForDate(currentBaby.id, date);
      
      print('DEBUG: Post detail - TimelineService returned ${timelineItems.length} items');
      for (var item in timelineItems.take(3)) {
        print('DEBUG: Post detail - ${item.type} - ${item.title} - ${item.subtitle} - ${item.timestamp}');
      }
      
      return timelineItems;
    } catch (e) {
      print('DEBUG: Error loading timeline data in post detail: $e');
      // 최후의 수단으로 기존 방식으로 변환 시도
      return _convertLegacyTimelineData(post.timelineData ?? {});
    }
  }

  // 기존 형태의 타임라인 데이터를 TimelineItem으로 변환 (fallback)
  List<TimelineItem> _convertLegacyTimelineData(Map<String, dynamic> timelineData) {
    List<TimelineItem> timelineItems = [];
    
    try {
      final activities = timelineData['activities'] as Map<String, dynamic>?;
      if (activities == null) return timelineItems;

      // 수유 데이터 변환
      final feedings = activities['feedings'] as List<dynamic>?;
      if (feedings != null) {
        for (int i = 0; i < feedings.length; i++) {
          final feeding = feedings[i] as Map<String, dynamic>;
          timelineItems.add(TimelineItem(
            id: 'feeding_$i',
            type: TimelineItemType.feeding,
            timestamp: DateTime.parse(feeding['startedAt']),
            title: '수유',
            subtitle: '${feeding['type']} • ${feeding['amountMl']}ml',
            data: feeding,
            colorCode: '#2196F3',
          ));
        }
      }

      // 수면 데이터 변환
      final sleeps = activities['sleeps'] as List<dynamic>?;
      if (sleeps != null) {
        for (int i = 0; i < sleeps.length; i++) {
          final sleep = sleeps[i] as Map<String, dynamic>;
          final durationMinutes = sleep['durationMinutes'] as int?;
          timelineItems.add(TimelineItem(
            id: 'sleep_$i',
            type: TimelineItemType.sleep,
            timestamp: DateTime.parse(sleep['startedAt']),
            title: '수면',
            subtitle: durationMinutes != null 
                ? '${(durationMinutes / 60).floor()}시간 ${durationMinutes % 60}분'
                : '진행중',
            data: sleep,
            isOngoing: sleep['endedAt'] == null,
            colorCode: '#9C27B0',
          ));
        }
      }

      // 기저귀 데이터 변환
      final diapers = activities['diapers'] as List<dynamic>?;
      if (diapers != null) {
        for (int i = 0; i < diapers.length; i++) {
          final diaper = diapers[i] as Map<String, dynamic>;
          timelineItems.add(TimelineItem(
            id: 'diaper_$i',
            type: TimelineItemType.diaper,
            timestamp: DateTime.parse(diaper['changedAt']),
            title: '기저귀',
            subtitle: diaper['type'],
            data: diaper,
            colorCode: '#FF9800',
          ));
        }
      }

      timelineItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return timelineItems;
    } catch (e) {
      print('DEBUG: Error converting legacy timeline data: $e');
      return timelineItems;
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
                          _getLocalizedCategoryName(l10n, post.category!.name, post.category!.slug),
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
                      // 딤 처리 여부 결정: mosaicImages에 해당 인덱스가 있고 비어있지 않으면 딤 처리
                      final shouldBlur = post.hasMosaic && 
                          index < post.mosaicImages.length && 
                          post.mosaicImages[index].isNotEmpty;
                      
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MosaicImageWidget(
                              originalImageUrl: post.images[index],
                              mosaicImageUrl: null, // 더 이상 사용하지 않음
                              hasMosaic: shouldBlur,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
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
                
                // 타임라인 표시
                if (post.timelineData != null && post.timelineDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timeline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '24시간 활동 패턴',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${post.timelineDate!.month}월 ${post.timelineDate!.day}일',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 350,
                          child: FutureBuilder<List<TimelineItem>>(
                            future: _loadTimelineDataFromDatabase(context, post.timelineDate!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              }
                              
                              if (snapshot.hasError) {
                                print('DEBUG: Error loading timeline data: ${snapshot.error}');
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '타임라인 데이터 로드 오류',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.error.withOpacity(0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              
                              final timelineItems = snapshot.data ?? [];
                              print('DEBUG: Loaded ${timelineItems.length} timeline items from database');
                              
                              if (timelineItems.isEmpty) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '표시할 활동 데이터가 없습니다',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              
                              return Center(
                                child: Transform.scale(
                                  scale: 0.8, // 80% 크기로 축소하여 더 많은 여유 공간 확보
                                  child: CircularTimelineChart(
                                    timelineItems: timelineItems,
                                    selectedDate: post.timelineDate!,
                                    hideLabels: true, // 게시글에서는 라벨 숨김
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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