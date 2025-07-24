import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/timeline_provider.dart';
import '../../../../domain/models/timeline_item.dart';
import '../../../../core/providers/baby_provider.dart';
import '../widgets/glassmorphic_timeline_card.dart';
import '../widgets/clean_background.dart';
import '../widgets/clean_timeline_header.dart';
import '../widgets/circular_timeline_chart.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  late TimelineProvider _timelineProvider;
  late AnimationController _fadeController;
  late AnimationController _scrollController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollListController;
  
  bool _isInitialized = false;
  
  // 화면 포커스 감지용
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  DateTime? _lastFocusTime;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _scrollListController = ScrollController();

    WidgetsBinding.instance.addObserver(this);
    
    // Provider 초기화
    _timelineProvider = TimelineProvider();
    
    // 데이터 로드
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _fadeController.dispose();
    _scrollController.dispose();
    _scrollListController.dispose();
    _timelineProvider.dispose();
    super.dispose();
  }

  // RouteAware 콜백들
  @override
  void didPopNext() {
    // 다른 화면에서 이 화면으로 돌아왔을 때
    _handleScreenFocus();
  }

  @override
  void didPush() {
    // 이 화면이 처음 푸시되었을 때
    _handleScreenFocus();
  }

  @override
  void didPop() {
    // 이 화면이 팝되었을 때
    debugPrint('🔄 [TIMELINE] Screen popped');
  }

  @override
  void didPushNext() {
    // 이 화면 위에 다른 화면이 푸시되었을 때
    debugPrint('🔄 [TIMELINE] Screen pushed next');
  }

  // 화면 포커스 처리
  void _handleScreenFocus() {
    final now = DateTime.now();
    
    // 마지막 포커스로부터 5초 이상 지났을 때만 새로고침
    if (_lastFocusTime == null || 
        now.difference(_lastFocusTime!).inSeconds > 5) {
      
      debugPrint('🔄 [TIMELINE] Screen focused - refreshing data');
      _lastFocusTime = now;
      
      if (_isInitialized) {
        // 부드러운 새로고침 (로딩 표시 없이)
        _timelineProvider.refreshData();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 앱이 포그라운드로 돌아올 때 데이터 새로고침
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _timelineProvider.refreshData();
    }
  }

  Future<void> _initializeData() async {
    try {
      debugPrint('📱 [TIMELINE] Initializing timeline data...');
      
      // BabyProvider의 선택된 아기 사용
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      await babyProvider.loadBabyData();
      
      // 🎯 아기가 없어도 초기화 완료로 처리
      setState(() {
        _isInitialized = true;
      });
      
      if (babyProvider.selectedBaby == null) {
        debugPrint('⚠️ [TIMELINE] No baby selected - showing empty state');
        // 페이드 인 애니메이션 시작 (빈 상태도 보여줘야 함)
        _fadeController.forward();
        return;
      }

      // Provider에 선택된 아기 ID 설정
      _timelineProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
      
      // 페이드 인 애니메이션 시작
      _fadeController.forward();
      
      debugPrint('✅ [TIMELINE] Timeline initialized for baby: ${babyProvider.selectedBaby!.name}');
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error initializing timeline: $e');
      // 에러가 있어도 초기화 완료로 처리
      setState(() {
        _isInitialized = true;
      });
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        // 🎯 아기가 없는 상태 처리
        if (!_isInitialized) {
          return Scaffold(
            body: CleanBackground(
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      '타임라인을 준비하고 있어요...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // 🎯 아기가 등록되지 않은 상태
        if (babyProvider.selectedBaby == null) {
          return Scaffold(
            body: CleanBackground(
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 아이콘
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.baby_changing_station,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 제목
                          Text(
                            '아기를 등록해주세요',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // 설명
                          Text(
                            '아기의 소중한 순간들을 기록하기 위해\n먼저 아기 정보를 등록해주세요.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 등록 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // 홈 화면으로 이동 (홈에서 아기 추가 가능)
                                Navigator.of(context).pushReplacementNamed('/home');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                '홈에서 아기 추가하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
          );
        }

        // 아기가 변경되었을 때 타임라인 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timelineProvider.currentBabyId != babyProvider.selectedBaby!.id) {
            debugPrint('🔄 [TIMELINE] Baby changed, updating timeline for: ${babyProvider.selectedBaby!.name}');
            _timelineProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
          }
        });

        return ChangeNotifierProvider.value(
          value: _timelineProvider,
          child: Scaffold(
            body: CleanBackground(
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // 깔끔한 헤더
                      _buildCleanHeader(),
                      
                      // 스크롤 가능한 콘텐츠
                      Expanded(
                        child: _buildScrollableContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCleanHeader() {
    return Consumer<TimelineProvider>(
      builder: (context, provider, child) {
        return CleanTimelineHeader(
          selectedDate: provider.selectedDate,
          onPreviousDay: () {
            debugPrint('🔥 [TIMELINE] Previous day button pressed');
            HapticFeedback.lightImpact();
            provider.goToPreviousDay();
          },
          onNextDay: () {
            debugPrint('🔥 [TIMELINE] Next day button pressed');
            HapticFeedback.lightImpact();
            provider.goToNextDay();
          },
          onDatePicker: () => _showModernDatePicker(context),
          isFuture: provider.isFuture,
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    return Consumer<TimelineProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            // 새로고침 시 타임라인 데이터 재로드
            await provider.refreshData();
          },
          child: CustomScrollView(
            controller: _scrollListController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
            // 24시간 원형 타임라인 차트
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircularTimelineChart(
                  timelineItems: provider.filteredItems,
                  selectedDate: provider.selectedDate,
                ),
              ),
            ),
            
            // 타임라인 스토리 헤더
            SliverToBoxAdapter(
              child: _buildTimelineStoryHeader(provider),
            ),
            
            // 타임라인 아이템들
            if (provider.isLoading)
              SliverToBoxAdapter(
                child: _buildLoadingState(),
              )
            else if (provider.error != null)
              SliverToBoxAdapter(
                child: _buildErrorState(provider.error!),
              )
            else if (!provider.hasItems)
              SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = provider.filteredItems[index];
                    final isLast = index == provider.filteredItems.length - 1;
                    
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16, 
                        index == 0 ? 8 : 0, 
                        16, 
                        isLast ? 32 : 8
                      ),
                      child: GlassmorphicTimelineCard(
                        item: item,
                        isLast: isLast,
                        onTap: () => _handleItemTap(context, item),
                      ),
                    );
                  },
                  childCount: provider.filteredItems.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineStoryHeader(TimelineProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 스토리 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 스토리 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.todaysStory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.hasItems 
                      ? AppLocalizations.of(context)!.preciousMoments(provider.filteredItems.length)
                      : AppLocalizations.of(context)!.noRecordedMoments,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // 인사이트 표시
          if (provider.hasItems)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '패턴',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.loadingTimeline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadFailed,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noRecordsYet,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.firstMomentMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, TimelineItem item) {
    HapticFeedback.lightImpact();
    // TODO: 상세보기 화면으로 이동
    debugPrint('🎯 타임라인 아이템 선택: ${item.title}');
    
    // 간단한 피드백 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.detailViewComingSoon(item.title)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF8B5FBF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showModernDatePicker(BuildContext context) async {
    final provider = _timelineProvider;
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: AppLocalizations.of(context)!.selectBirthDate,
      cancelText: AppLocalizations.of(context)!.cancel,
      confirmText: AppLocalizations.of(context)!.confirm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF10B981),
              secondary: const Color(0xFF8B5FBF),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      HapticFeedback.selectionClick();
      provider.setSelectedDate(selectedDate);
      
      // 스크롤을 최상단으로
      _scrollListController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }
}