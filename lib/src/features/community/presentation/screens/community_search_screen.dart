import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/community_post.dart';
import '../../../../services/community/search_service.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_loading_shimmer.dart';
import 'community_post_detail_screen.dart';

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen>
    with TickerProviderStateMixin {
  
  // 서비스 및 컨트롤러
  final CommunitySearchService _searchService = CommunitySearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // 애니메이션
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // 상태 관리
  List<CommunityPost> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _popularSearchTerms = [];
  List<String> _recentSearches = [];
  
  bool _isLoading = false;
  bool _isLoadingSuggestions = false;
  bool _hasSearched = false;
  bool _showSuggestions = false;
  String _currentQuery = '';
  String? _selectedCategory;
  String _sortBy = 'relevance';
  
  Timer? _suggestionTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPopularSearchTerms();
      _loadRecentSearches();
    });
  }

  void _setupListeners() {
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _suggestionTimer?.cancel();
    _searchService.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    if (query != _currentQuery) {
      _currentQuery = query;
      
      if (query.isNotEmpty) {
        setState(() => _showSuggestions = true);
        _loadSearchSuggestions(query);
      } else {
        setState(() {
          _showSuggestions = false;
          _searchSuggestions.clear();
        });
      }
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _currentQuery.isNotEmpty) {
      setState(() => _showSuggestions = true);
    }
  }

  void _onScroll() {
    // 스크롤 시 키보드 숨기기
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _loadPopularSearchTerms() async {
    try {
      final terms = await _searchService.getPopularSearchTerms();
      if (mounted) {
        setState(() => _popularSearchTerms = terms);
      }
    } catch (e) {
      // 에러 무시 (선택적 기능)
    }
  }

  Future<void> _loadRecentSearches() async {
    // TODO: SharedPreferences에서 최근 검색어 로드
    // 지금은 빈 리스트로 처리
    setState(() => _recentSearches = []);
  }

  Future<void> _loadSearchSuggestions(String query) async {
    _suggestionTimer?.cancel();
    _suggestionTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted || query != _currentQuery) return;
      
      setState(() => _isLoadingSuggestions = true);
      
      try {
        final suggestions = await _searchService.getSearchSuggestions(query);
        if (mounted && query == _currentQuery) {
          setState(() {
            _searchSuggestions = suggestions;
            _isLoadingSuggestions = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingSuggestions = false);
        }
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _showSuggestions = false;
    });

    _searchFocusNode.unfocus();
    HapticFeedback.lightImpact();

    try {
      final results = await _searchService.searchPosts(
        query: query,
        category: _selectedCategory,
        sortBy: _sortBy,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });

        // 검색 이벤트 기록
        _searchService.recordSearchEvent(query, results.length);
        _addToRecentSearches(query);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _addToRecentSearches(String query) {
    // TODO: SharedPreferences에 최근 검색어 저장
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('검색 중 오류가 발생했습니다: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: _buildBackgroundGradient(theme),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // 검색 헤더
                  _buildSearchHeader(theme, l10n),
                  
                  // 필터 섹션
                  if (_hasSearched || _showSuggestions)
                    _buildFilterSection(theme, l10n),
                  
                  // 메인 컨텐츠
                  Expanded(
                    child: _buildMainContent(theme, l10n),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withOpacity(0.8),
          theme.colorScheme.primaryContainer.withOpacity(0.1),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 뒤로가기 버튼
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 검색 입력 필드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _searchFocusNode.hasFocus 
                      ? theme.colorScheme.primary.withOpacity(0.5)
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: '커뮤니티 게시글 검색',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      suffixIcon: _currentQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _currentQuery = '';
                                  _showSuggestions = false;
                                  _hasSearched = false;
                                  _searchResults.clear();
                                });
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _performSearch,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 카테고리 필터
            _buildFilterChip(
              theme: theme,
              label: '전체',
              isSelected: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              theme: theme,
              label: '질문',
              isSelected: _selectedCategory == 'question',
              onTap: () => setState(() => _selectedCategory = 'question'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              theme: theme,
              label: '정보',
              isSelected: _selectedCategory == 'info',
              onTap: () => setState(() => _selectedCategory = 'info'),
            ),
            const SizedBox(width: 16),
            
            // 정렬 방식
            _buildSortDropdown(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(ThemeData theme, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      initialValue: _sortBy,
      onSelected: (value) => setState(() => _sortBy = value),
      child: Container(
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
              Icons.sort_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(_sortBy),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'relevance', child: Text('관련도')),
        PopupMenuItem(value: 'created_at', child: Text('최신순')),
        PopupMenuItem(value: 'like_count', child: Text('좋아요순')),
        PopupMenuItem(value: 'comment_count', child: Text('댓글순')),
      ],
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'relevance': return '관련도';
      case 'created_at': return '최신순';
      case 'like_count': return '좋아요순';
      case 'comment_count': return '댓글순';
      default: return '관련도';
    }
  }

  Widget _buildMainContent(ThemeData theme, AppLocalizations l10n) {
    if (_showSuggestions) {
      return _buildSuggestionsContent(theme, l10n);
    } else if (_isLoading) {
      return const CommunityLoadingShimmer();
    } else if (_hasSearched) {
      return _buildSearchResults(theme, l10n);
    } else {
      return _buildInitialContent(theme, l10n);
    }
  }

  Widget _buildSuggestionsContent(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchSuggestions.isNotEmpty) ...[
            Text(
              '검색 제안',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...(_searchSuggestions.map((suggestion) => 
              ListTile(
                leading: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
                title: Text(suggestion),
                onTap: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, AppLocalizations l10n) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어를 시도해보세요',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CommunityPostCard(
            post: post,
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
              // TODO: 좋아요 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('좋아요 기능 준비 중'),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInitialContent(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인기 검색어
          if (_popularSearchTerms.isNotEmpty) ...[
            Text(
              '인기 검색어',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearchTerms.map((term) => 
                GestureDetector(
                  onTap: () {
                    _searchController.text = term;
                    _performSearch(term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      term,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // 최근 검색어
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색어',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: Text(
                    '전체삭제',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...(_recentSearches.map((search) => 
              ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
                title: Text(search),
                trailing: IconButton(
                  onPressed: () => setState(() => _recentSearches.remove(search)),
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 18,
                  ),
                ),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              ),
            )),
          ],
        ],
      ),
    );
  }
}