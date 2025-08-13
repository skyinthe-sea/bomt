import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../widgets/community_app_bar.dart';
import '../widgets/community_category_button.dart';
import '../widgets/community_post_list.dart';
import '../widgets/community_fab.dart';
import '../widgets/community_loading_shimmer.dart';
import 'community_nickname_setup_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounceTimer;
  bool _hasNavigatedToNicknameSetup = false; // 닉네임 설정 화면 이동 방지 플래그

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

              // 🎯 프로필이 없으면 닉네임 설정 화면 표시 (한 번만, 더 엄격한 조건)
              if (provider.currentUserId != null && 
                  provider.currentUserProfile == null && 
                  !provider.isLoading && 
                  !_hasNavigatedToNicknameSetup &&
                  provider.isInitialized) { // 초기화 완료 여부 체크 (categories 대신 isInitialized 사용)
                debugPrint('DEBUG: 🚨 닉네임 설정 화면으로 이동 조건 충족:');
                debugPrint('  - currentUserId: ${provider.currentUserId}');
                debugPrint('  - currentUserProfile: ${provider.currentUserProfile}');
                debugPrint('  - isLoading: ${provider.isLoading}');
                debugPrint('  - isInitialized: ${provider.isInitialized}');
                debugPrint('  - categories loaded: ${provider.categories.length}');
                debugPrint('  - hasNavigatedToNicknameSetup: $_hasNavigatedToNicknameSetup');
                
                _hasNavigatedToNicknameSetup = true; // 플래그 설정으로 중복 이동 방지
                
                // 다음 프레임에서 실행하여 프로필 로드 완료 후 조건 재확인
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint('DEBUG: PostFrameCallback - 닉네임 설정 화면 이동 전 최종 확인');
                  debugPrint('  - currentUserProfile at navigation: ${provider.currentUserProfile}');
                  debugPrint('  - currentUserProfile == null: ${provider.currentUserProfile == null}');
                  
                  if (provider.currentUserProfile == null && mounted) {
                    debugPrint('DEBUG: ✅ 최종 확인 후 닉네임 설정 화면으로 이돔');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CommunityNicknameSetupScreen(isFirstTime: true),
                      ),
                    ).then((_) {
                      // 닉네임 설정 후 돌아왔을 때 프로필만 다시 로드하고 플래그 리셋
                      _hasNavigatedToNicknameSetup = false;
                      provider.loadCurrentUserProfile(); // initialize 대신 프로필만 다시 로드
                    });
                  } else {
                    debugPrint('DEBUG: ❌ 최종 확인 결과 프로필이 있음, 닉네임 설정 화면으로 이동하지 않음');
                    _hasNavigatedToNicknameSetup = false; // 플래그 리셋
                  }
                });
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
                    
                    // 카테고리 및 정렬 컨트롤 (한 줄에 배치)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            // 카테고리 버튼 (왼쪽)
                            const CommunityCategoryButton(),
                            
                            const Spacer(),
                            
                            // 정렬 버튼들 (오른쪽에 작게)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 좋아요순 버튼
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    provider.changePostSortOrder('like_count');
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: provider.postSortOrder == 'like_count'
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surface.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: provider.postSortOrder == 'like_count'
                                            ? theme.colorScheme.primary.withOpacity(0.3)
                                            : theme.colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 14,
                                          color: provider.postSortOrder == 'like_count'
                                              ? Colors.white
                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.sortByLikes,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: provider.postSortOrder == 'like_count'
                                                ? Colors.white
                                                : theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: provider.postSortOrder == 'like_count'
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // 최신순 버튼
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    provider.changePostSortOrder('created_at');
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: provider.postSortOrder == 'created_at'
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surface.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: provider.postSortOrder == 'created_at'
                                            ? theme.colorScheme.primary.withOpacity(0.3)
                                            : theme.colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: provider.postSortOrder == 'created_at'
                                              ? Colors.white
                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.sortByLatest,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: provider.postSortOrder == 'created_at'
                                                ? Colors.white
                                                : theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: provider.postSortOrder == 'created_at'
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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