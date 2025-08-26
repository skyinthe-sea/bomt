import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../presentation/providers/community_my_posts_provider.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_loading_shimmer.dart';

class CommunityMyPostsScreen extends StatefulWidget {
  const CommunityMyPostsScreen({super.key});

  @override
  State<CommunityMyPostsScreen> createState() => _CommunityMyPostsScreenState();
}

class _CommunityMyPostsScreenState extends State<CommunityMyPostsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _postsScrollController = ScrollController();
  final ScrollController _commentsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _postsScrollController.addListener(_onPostsScroll);
    _commentsScrollController.addListener(_onCommentsScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityMyPostsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postsScrollController.dispose();
    _commentsScrollController.dispose();
    super.dispose();
  }

  void _onPostsScroll() {
    if (_postsScrollController.position.pixels >=
        _postsScrollController.position.maxScrollExtent * 0.9) {
      context.read<CommunityMyPostsProvider>().loadMorePosts();
    }
  }

  void _onCommentsScroll() {
    if (_commentsScrollController.position.pixels >=
        _commentsScrollController.position.maxScrollExtent * 0.9) {
      context.read<CommunityMyPostsProvider>().loadMoreComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '내 활동',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '내가 쓴 글'),
            Tab(text: '내가 쓴 댓글'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyPostsTab(),
            _buildMyCommentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPostsTab() {
    return Consumer<CommunityMyPostsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPosts && provider.myPosts.isEmpty) {
          return const CommunityLoadingShimmer();
        }

        if (provider.myPosts.isEmpty && !provider.isLoadingPosts) {
          return _buildEmptyState('아직 작성한 글이 없어요', Icons.edit_outlined);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshPosts(),
          child: ListView.separated(
            controller: _postsScrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: provider.myPosts.length + (provider.hasMorePosts ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= provider.myPosts.length) {
                return _buildLoadingIndicator();
              }

              final post = provider.myPosts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommunityPostCard(
                  post: post,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyCommentsTab() {
    return Consumer<CommunityMyPostsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingComments && provider.myComments.isEmpty) {
          return const CommunityLoadingShimmer();
        }

        if (provider.myComments.isEmpty && !provider.isLoadingComments) {
          return _buildEmptyState('아직 작성한 댓글이 없어요', Icons.chat_bubble_outline);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshComments(),
          child: ListView.separated(
            controller: _commentsScrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: provider.myComments.length + (provider.hasMoreComments ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= provider.myComments.length) {
                return _buildLoadingIndicator();
              }

              final comment = provider.myComments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCommentCard(comment),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommentCard(dynamic comment) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: 해당 게시글로 이동
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 댓글 내용
              Text(
                comment.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 하단 정보
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '게시글로 이동',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '커뮤니티에서 다른 부모들과 소통해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}