import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../presentation/providers/feeding_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../presentation/providers/diaper_provider.dart';
import '../../../../presentation/providers/health_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/feeding_summary_card.dart';
import '../widgets/sleep_summary_card.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/temperature_summary_card.dart';
import '../widgets/growth_info_card.dart';
import '../../../../domain/models/baby.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../../services/baby_guide/baby_guide_service.dart';
import '../../../../domain/models/baby_guide.dart';
import '../widgets/baby_guide_alert.dart';
import '../screens/baby_guide_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final LocalizationProvider? localizationProvider;
  final ThemeProvider? themeProvider;
  
  const HomeScreen({
    super.key,
    this.localizationProvider,
    this.themeProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _homeRepository = HomeRepositoryImpl();
  final _babyGuideService = BabyGuideService.instance;
  final _feedingProvider = FeedingProvider();
  final _sleepProvider = SleepProvider();
  final _diaperProvider = DiaperProvider();
  final _healthProvider = HealthProvider();
  
  Baby? _currentBaby;
  String? _currentUserId;
  bool _isLoading = true;
  
  // 요약 데이터
  Map<String, dynamic> _feedingSummary = {};
  Map<String, dynamic> _sleepSummary = {};
  Map<String, dynamic> _diaperSummary = {};
  Map<String, dynamic> _temperatureSummary = {};
  Map<String, dynamic> _growthSummary = {};

  @override
  void initState() {
    super.initState();
    // App lifecycle observer 등록
    WidgetsBinding.instance.addObserver(this);
    // Provider 변경 리스너 추가
    _feedingProvider.addListener(_onFeedingDataChanged);
    _sleepProvider.addListener(_onSleepDataChanged);
    _diaperProvider.addListener(_onDiaperDataChanged);
    _healthProvider.addListener(_onHealthDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    // App lifecycle observer 제거
    WidgetsBinding.instance.removeObserver(this);
    _feedingProvider.removeListener(_onFeedingDataChanged);
    _sleepProvider.removeListener(_onSleepDataChanged);
    _diaperProvider.removeListener(_onDiaperDataChanged);
    _healthProvider.removeListener(_onHealthDataChanged);
    _feedingProvider.dispose();
    _sleepProvider.dispose();
    _diaperProvider.dispose();
    _healthProvider.dispose();
    super.dispose();
  }

  /// FeedingProvider 데이터 변경 시 호출되는 콜백
  void _onFeedingDataChanged() {
    if (mounted) {
      setState(() {
        _feedingSummary = _feedingProvider.todaySummary;
      });
    }
  }

  /// SleepProvider 데이터 변경 시 호출되는 콜백
  void _onSleepDataChanged() {
    if (mounted) {
      setState(() {
        _sleepSummary = _sleepProvider.todaySummary;
      });
    }
  }

  /// DiaperProvider 데이터 변경 시 호출되는 콜백
  void _onDiaperDataChanged() {
    if (mounted) {
      setState(() {
        _diaperSummary = _diaperProvider.todaySummary;
      });
    }
  }

  /// HealthProvider 데이터 변경 시 호출되는 콜백
  void _onHealthDataChanged() {
    if (mounted) {
      setState(() {
        _temperatureSummary = _healthProvider.todaySummary;
      });
    }
  }

  /// 앱 생명주기 상태 변경 시 호출되는 콜백
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('App lifecycle state changed to: $state');
    
    // 앱이 백그라운드에서 포그라운드로 돌아올 때 데이터 새로고침
    if (state == AppLifecycleState.resumed && _currentBaby != null) {
      debugPrint('App resumed - refreshing home screen data');
      _refreshData();
    }
  }

  /// 데이터만 새로고침 (로딩 상태 없이)
  Future<void> _refreshData() async {
    if (_currentBaby == null || _currentUserId == null) return;
    
    try {
      // 모든 Provider의 데이터를 새로고침
      await Future.wait([
        _feedingProvider.refreshData(),
        _sleepProvider.refreshData(),
        _diaperProvider.refreshData(),
        _healthProvider.refreshData(),
      ]);
      
      // 성장 데이터 새로고침
      final growthSummary = await _homeRepository.getGrowthSummary(_currentBaby!.id);
      
      if (mounted) {
        setState(() {
          _growthSummary = growthSummary;
        });
      }
      
      debugPrint('Home screen data refreshed successfully');
    } catch (e) {
      debugPrint('Error refreshing home screen data: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // 카카오 로그인에서 받은 user_id 가져오기
      final userId = await _getUserId();
      
      if (userId == null) {
        // 로그인이 안되어 있으면 로그인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }
      
      // 해당 user_id와 연결된 아기 정보 조회
      final response = await Supabase.instance.client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            babies (
              id,
              name,
              birth_date,
              gender
            )
          ''')
          .eq('user_id', userId);
      
      if (response.isEmpty || response.first['babies'] == null) {
        // 등록된 아기가 없는 경우
        setState(() {
          _currentBaby = null;
          _currentUserId = null;
          _isLoading = false;
        });
        return;
      }
      
      final babyData = response.first['babies'];
      final baby = Baby.fromJson({
        'id': babyData['id'],
        'name': babyData['name'], 
        'birth_date': babyData['birth_date'],
        'gender': babyData['gender'],
      });
      
      // 모든 Provider 설정
      _feedingProvider.setCurrentBaby(baby.id, userId);
      _sleepProvider.setCurrentBaby(baby.id, userId);
      _diaperProvider.setCurrentBaby(baby.id, userId);
      _healthProvider.setCurrentBaby(baby.id, userId);
      
      // 성장 데이터는 아직 Provider로 이동하지 않음 (추후 개발 예정)
      final growthSummary = await _homeRepository.getGrowthSummary(baby.id);
      
      setState(() {
        _currentBaby = baby;
        _currentUserId = userId;
        // 모든 데이터는 Provider에서 관리됨
        _feedingSummary = _feedingProvider.todaySummary;
        _sleepSummary = _sleepProvider.todaySummary;
        _diaperSummary = _diaperProvider.todaySummary;
        _temperatureSummary = _healthProvider.todaySummary;
        _growthSummary = growthSummary;
        _isLoading = false;
      });
      
      // 아기 정보를 불러온 후 가이드 알럿 확인
      _checkForGuideAlert(userId);
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  /// 가이드 알럿 확인 및 표시
  Future<void> _checkForGuideAlert(String userId) async {
    if (_currentBaby == null) return;
    
    try {
      final guide = await _babyGuideService.checkForPendingAlert(userId, _currentBaby!);
      if (guide != null && mounted) {
        _showGuideAlert(guide, userId);
      }
    } catch (e) {
      debugPrint('Error checking guide alert: $e');
    }
  }
  
  /// 가이드 알럿 다이얼로그 표시
  void _showGuideAlert(BabyGuide guide, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BabyGuideAlert(
        guide: guide,
        baby: _currentBaby!,
        onDismiss: () {
          Navigator.of(context).pop();
          // 알럿을 본 것으로 기록
          _babyGuideService.handleAlertShown(userId, _currentBaby!, guide);
        },
      ),
    );
  }
  
  Future<String?> _getUserId() async {
    try {
      // 카카오 로그인된 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      return user.id.toString();
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }
  
  Widget _buildNoBabyScreen(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.baby_changing_station,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '등록된 아기가 없습니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '아기를 등록하고 육아 기록을 시작해보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 아기 등록 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('아기 등록 기능은 곧 추가될 예정입니다'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('아기 등록하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentBaby == null
                ? _buildNoBabyScreen(context)
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: CustomScrollView(
                  slivers: [
                    // 앱바
                    SliverAppBar(
                      floating: true,
                      backgroundColor: theme.colorScheme.background,
                      elevation: 0,
                      actions: [
                        // Baby guide list button
                        if (_currentBaby != null)
                          IconButton(
                            icon: Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.onBackground,
                            ),
                            tooltip: '육아 가이드',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BabyGuideListScreen(
                                    baby: _currentBaby!,
                                  ),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: theme.colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(
                                  localizationProvider: widget.localizationProvider!,
                                  themeProvider: widget.themeProvider,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    // 아기 정보 카드
                    if (_currentBaby != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BabyInfoCard(
                            baby: _currentBaby!,
                            feedingSummary: _feedingSummary,
                          ),
                        ),
                      ),
                    
                    // 오늘의 요약 섹션 (흰 배경으로 감싸기)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 오늘의 요약 제목
                            Text(
                              l10n.todaySummary ?? '오늘의 요약',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 요약 카드 - 3개 가로 배치
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FeedingSummaryCard(
                                      summary: _feedingSummary,
                                      feedingProvider: _feedingProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: SleepSummaryCard(
                                      summary: _sleepSummary,
                                      sleepProvider: _sleepProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: DiaperSummaryCard(
                                      summary: _diaperSummary,
                                      diaperProvider: _diaperProvider,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 건강 카드 - 재사용을 위해 주석 처리
                            // ChangeNotifierProvider.value(
                            //   value: _healthProvider,
                            //   child: TemperatureSummaryCard(summary: _temperatureSummary),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 성장 정보 섹션
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.growthInfo ?? '성장 정보',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to detailed growth screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('성장 상세 페이지는 곧 추가될 예정입니다'),
                                  ),
                                );
                              },
                              child: Text(
                                '상세보기',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 성장 정보 카드
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: GrowthInfoCard(summary: _growthSummary),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}