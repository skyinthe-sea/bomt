import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../../../presentation/providers/timeline_provider.dart';
import '../../../../domain/models/timeline_item.dart';
import '../../../../domain/models/baby.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../baby/data/repositories/supabase_baby_repository.dart';
import '../widgets/glassmorphic_timeline_card.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/modern_timeline_header.dart';
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
  
  Baby? _currentBaby;
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
      debugPrint('📱 [TIMELINE] Initializing modern timeline data...');
      
      // 사용자 정보 가져오기
      final userId = await _getUserId();
      if (userId == null) {
        debugPrint('❌ [TIMELINE] No user ID found');
        return;
      }

      // 아기 정보 가져오기
      final baby = await _getCurrentBaby(userId);
      if (baby == null) {
        debugPrint('❌ [TIMELINE] No baby found for user: $userId');
        return;
      }

      setState(() {
        _currentBaby = baby;
        _isInitialized = true;
      });

      // Provider에 아기 ID 설정
      _timelineProvider.setCurrentBaby(baby.id);
      
      // 페이드 인 애니메이션 시작
      _fadeController.forward();
      
      debugPrint('✅ [TIMELINE] Modern timeline initialized successfully');
    } catch (e) {
      debugPrint('❌ [TIMELINE] Error initializing timeline: $e');
    }
  }

  Future<String?> _getUserId() async {
    try {
      final user = await UserApi.instance.me();
      return user.id.toString();
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<Baby?> _getCurrentBaby(String userId) async {
    try {
      final babyRepository = SupabaseBabyRepository();
      final babyEntities = await babyRepository.getBabiesByUserId(userId);
      if (babyEntities.isEmpty) return null;
      
      // Entity를 Model로 변환
      final babyEntity = babyEntities.first;
      return Baby(
        id: babyEntity.id,
        name: babyEntity.name,
        birthDate: babyEntity.birthDate,
        gender: babyEntity.gender,
        profileImageUrl: babyEntity.profileImageUrl,
        createdAt: babyEntity.createdAt,
        updatedAt: babyEntity.updatedAt,
      );
    } catch (e) {
      debugPrint('Error getting baby: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _currentBaby == null) {
      return Scaffold(
        body: AnimatedGradientBackground(
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF8B5FBF),
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  '타임라인을 준비하고 있어요...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _timelineProvider,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: AnimatedGradientBackground(
          child: Stack(
            children: [
              // 부유하는 파티클 효과
              const FloatingParticles(particleCount: 15),
              
              // 메인 콘텐츠
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ModernGradientOverlay(
                    child: Column(
                      children: [
                        // 모던 헤더
                        _buildModernHeader(),
                        
                        // 스크롤 가능한 콘텐츠
                        Expanded(
                          child: _buildScrollableContent(),
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
    );
  }

  Widget _buildModernHeader() {
    return Consumer<TimelineProvider>(
      builder: (context, provider, child) {
        return ModernTimelineHeader(
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
        return CustomScrollView(
          controller: _scrollListController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 24시간 원형 타임라인 차트
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                        20, 
                        index == 0 ? 16 : 0, 
                        20, 
                        isLast ? 40 : 0
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
        );
      },
    );
  }

  Widget _buildTimelineStoryHeader(TimelineProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 스토리 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF34D399),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 스토리 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 스토리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.hasItems 
                      ? '${provider.filteredItems.length}개의 소중한 순간들' 
                      : '아직 기록된 순간이 없어요',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5FBF).withOpacity(0.2),
                    const Color(0xFFB794F6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5FBF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF8B5FBF),
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '패턴',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5FBF),
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
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8B5FBF),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            '타임라인을 불러오고 있어요...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFF87171).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            '데이터를 불러올 수 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 24),
          Text(
            '아직 기록이 없어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '첫 번째 소중한 순간을 기록해보세요.\n매일의 작은 변화들이 모여 큰 성장이 됩니다.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
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
        content: Text('${item.title} 상세보기 (개발 예정)'),
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
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
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