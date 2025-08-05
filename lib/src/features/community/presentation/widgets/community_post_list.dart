import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../screens/community_post_detail_screen.dart';
import 'community_post_card.dart';
import 'community_ad_card.dart';

class CommunityPostList extends StatelessWidget {
  const CommunityPostList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.posts.isEmpty && !provider.isLoading) {
          return SliverToBoxAdapter(
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noPostsYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.writeFirstPost,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
              final totalPostsWithAds = provider.posts.length + (provider.posts.length ~/ 5);
              
              // 마지막 인덱스에서 상태 UI 표시
              if (index == totalPostsWithAds) {
                return _buildBottomStateWidget(context, provider, l10n);
              }
              
              // 5개마다 광고 삽입
              if ((index + 1) % 6 == 0 && index < provider.posts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: CommunityAdCard(),
                );
              }

              // 광고를 고려한 실제 게시글 인덱스 계산
              final postIndex = index - (index ~/ 6);
              
              if (postIndex >= provider.posts.length) {
                return null;
              }

              final post = provider.posts[postIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: CommunityPostCard(
                  post: post,
                  selectedCategorySlug: provider.selectedCategorySlug, // 현재 선택된 카테고리 전달
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityPostDetailScreen(
                          postId: post.id,
                        ),
                      ),
                    );
                  },
                  onLike: () {
                    provider.togglePostLike(post.id);
                  },
                ),
              );
            },
            // 상태 UI를 위해 +1 추가
            childCount: (provider.posts.length + (provider.posts.length ~/ 5)) + 
                       (provider.posts.isNotEmpty ? 1 : 0),
          ),
        );
      },
    );
  }

  // 하단 상태 위젯 (로딩, 완료, 에러)
  Widget _buildBottomStateWidget(BuildContext context, CommunityProvider provider, AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    // 로딩 중
    if (provider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingNewPosts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    // 에러 발생
    if (provider.error != null) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.failedToLoadPosts,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.checkNetworkAndRetry,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.tryAgain),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      );
    }
    
    // 더 이상 게시글이 없음
    if (!provider.hasMorePosts) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.allPostsChecked,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.waitForNewPosts,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 하단 여백
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      );
    }
    
    // 기본적으로 빈 컨테이너 (아무 상태도 해당하지 않을 때)
    return const SizedBox(height: 20);
  }
}