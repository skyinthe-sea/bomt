import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../widgets/community_app_bar.dart';
import '../widgets/community_banner.dart';
import '../widgets/community_category_tabs.dart';
import '../widgets/community_post_list.dart';
import '../widgets/community_fab.dart';
import '../widgets/community_loading_shimmer.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // 디바운싱: 300ms 후에 실행
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final provider = context.read<CommunityProvider>();
      
      // 더 엄격한 조건 체크
      if (provider.isLoading || !provider.hasMorePosts) return;
      
      // 스크롤이 95% 이상일 때만 로드 (더 끝에서 호출)
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.95) {
        provider.loadPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBodyBehindAppBar: false,
        appBar: const CommunityAppBar(),
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
          child: Consumer<CommunityProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.posts.isEmpty) {
                return const CommunityLoadingShimmer();
              }

              return RefreshIndicator(
                onRefresh: provider.refresh,
                backgroundColor: theme.colorScheme.surface,
                color: theme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // 상단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 8),
                    ),
                    
                    // 상단 배너
                    const SliverToBoxAdapter(
                      child: CommunityBanner(),
                    ),
                    
                    // 카테고리 탭
                    const SliverToBoxAdapter(
                      child: CommunityCategoryTabs(),
                    ),
                    
                    // 정렬 버튼
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                      ),
                                      child: Row(
                                        children: [
                                          // 좋아요순 버튼
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                provider.changePostSortOrder('like_count');
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: provider.postSortOrder == 'like_count'
                                                      ? theme.colorScheme.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.favorite,
                                                      size: 16,
                                                      color: provider.postSortOrder == 'like_count'
                                                          ? Colors.white
                                                          : theme.colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      l10n.sortByLikes,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: provider.postSortOrder == 'like_count'
                                                            ? Colors.white
                                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                                        fontWeight: provider.postSortOrder == 'like_count'
                                                            ? FontWeight.w600
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // 최신순 버튼
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                provider.changePostSortOrder('created_at');
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: provider.postSortOrder == 'created_at'
                                                      ? theme.colorScheme.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.schedule,
                                                      size: 16,
                                                      color: provider.postSortOrder == 'created_at'
                                                          ? Colors.white
                                                          : theme.colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      l10n.sortByLatest,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: provider.postSortOrder == 'created_at'
                                                            ? Colors.white
                                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                                        fontWeight: provider.postSortOrder == 'created_at'
                                                            ? FontWeight.w600
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 게시글 목록
                    const CommunityPostList(),
                    
                    // 로딩 인디케이터
                    if (provider.isLoading && provider.posts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    
                    // 하단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: const CommunityFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
  }
}