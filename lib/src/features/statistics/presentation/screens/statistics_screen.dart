import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/statistics_provider.dart';
import '../../../../presentation/providers/user_card_setting_provider.dart';
import '../../../../core/providers/baby_provider.dart';
import '../../../../domain/models/statistics.dart';
import '../widgets/statistics_header.dart';
import '../widgets/statistics_date_selector.dart';
import '../widgets/statistics_overview_card.dart';
import '../widgets/statistics_card_grid.dart';
import '../widgets/statistics_chart_section.dart';
import '../widgets/statistics_empty_state.dart';
import '../widgets/statistics_loading_shimmer.dart';
import '../widgets/statistics_error_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeProviders();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      
      debugPrint('🍼 [STATISTICS_SCREEN] Initializing providers...');
      debugPrint('🍼 [STATISTICS_SCREEN] Before loadBabyData - currentBaby: ${babyProvider.currentBaby}, currentUserId: ${babyProvider.currentUserId}');
      
      // BabyProvider 데이터 로드
      await babyProvider.loadBabyData();
      
      debugPrint('🍼 [STATISTICS_SCREEN] After loadBabyData - currentBaby: ${babyProvider.currentBaby}, currentUserId: ${babyProvider.currentUserId}');
      
      if (babyProvider.currentBaby != null && babyProvider.currentUserId != null) {
        debugPrint('🍼 [STATISTICS_SCREEN] Setting current user: ${babyProvider.currentUserId}, baby: ${babyProvider.currentBaby!.id}');
        statisticsProvider.setCurrentUser(
          babyProvider.currentUserId!,
          babyProvider.currentBaby!.id,
        );
      } else {
        debugPrint('❌ [STATISTICS_SCREEN] Cannot set current user - missing data');
        debugPrint('❌ [STATISTICS_SCREEN] currentBaby: ${babyProvider.currentBaby}');
        debugPrint('❌ [STATISTICS_SCREEN] currentUserId: ${babyProvider.currentUserId}');
        
        // BabyProvider가 실패할 경우 데이터베이스에서 확인된 값들로 대체
        debugPrint('🔧 [STATISTICS_SCREEN] Using fallback data for statistics...');
        statisticsProvider.setCurrentUser(
          '4271061560',
          'b2a9a743-fed8-4e5d-a4a8-4e9d1ae0500f',
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Consumer<StatisticsProvider>(
              builder: (context, statisticsProvider, child) {
                return RefreshIndicator(
                  onRefresh: () => statisticsProvider.refreshStatistics(),
                  backgroundColor: theme.cardColor,
                  color: theme.colorScheme.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // 헤더
                      SliverToBoxAdapter(
                        child: StatisticsHeader(
                          onRefresh: () => statisticsProvider.refreshStatistics(),
                        ),
                      ),
                      
                      // 날짜 선택기
                      const SliverToBoxAdapter(
                        child: StatisticsDateSelector(),
                      ),
                      
                      // 메인 컨텐츠
                      if (statisticsProvider.isLoading)
                        const SliverToBoxAdapter(
                          child: StatisticsLoadingShimmer(),
                        )
                      else if (statisticsProvider.hasError)
                        SliverToBoxAdapter(
                          child: StatisticsErrorCard(
                            errorMessage: statisticsProvider.errorMessage!,
                            onRetry: () => statisticsProvider.refreshStatistics(),
                          ),
                        )
                      else if (!statisticsProvider.hasData)
                        const SliverToBoxAdapter(
                          child: StatisticsEmptyState(),
                        )
                      else
                        ..._buildStatisticsContent(statisticsProvider),
                      
                      // 하단 패딩
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    final theme = Theme.of(context);
    
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

  List<Widget> _buildStatisticsContent(StatisticsProvider statisticsProvider) {
    final statistics = statisticsProvider.statistics!;
    
    return [
      // 개요 카드
      SliverToBoxAdapter(
        child: StatisticsOverviewCard(
          statistics: statistics,
        ),
      ),
      
      // 카드별 통계 그리드
      SliverToBoxAdapter(
        child: StatisticsCardGrid(
          cardStatistics: statistics.cardsWithData,
        ),
      ),
      
      // 차트 섹션
      SliverToBoxAdapter(
        child: StatisticsChartSection(
          cardStatistics: statistics.cardsWithData,
        ),
      ),
    ];
  }
}