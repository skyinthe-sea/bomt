import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/feeding_summary_card.dart';
import '../widgets/sleep_summary_card.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/temperature_summary_card.dart';
import '../widgets/growth_info_card.dart';
import '../../../../domain/models/baby.dart';
import '../../data/repositories/home_repository_impl.dart';
import './sample_data_screen.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final _homeRepository = HomeRepositoryImpl();
  
  Baby? _currentBaby;
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
    _loadData();
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
      
      // 각종 요약 데이터 로드
      final feedingSummary = await _homeRepository.getFeedingSummary(baby.id);
      final sleepSummary = await _homeRepository.getSleepSummary(baby.id);
      final diaperSummary = await _homeRepository.getDiaperSummary(baby.id);
      final temperatureSummary = await _homeRepository.getTemperatureSummary(baby.id);
      final growthSummary = await _homeRepository.getGrowthSummary(baby.id);
      
      setState(() {
        _currentBaby = baby;
        _feedingSummary = feedingSummary;
        _sleepSummary = sleepSummary;
        _diaperSummary = diaperSummary;
        _temperatureSummary = temperatureSummary;
        _growthSummary = growthSummary;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
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
                        // Baby list button
                        IconButton(
                          icon: Icon(
                            Icons.child_care,
                            color: theme.colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/baby-list',
                              arguments: {
                                'localizationProvider': widget.localizationProvider,
                                'themeProvider': widget.themeProvider,
                              },
                            );
                          },
                        ),
                        // Temporary button for sample data
                        IconButton(
                          icon: Icon(
                            Icons.add_box,
                            color: theme.colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SampleDataScreen(),
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
                    
                    // 오늘의 요약 섹션
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          l10n.todaySummary ?? '오늘의 요약',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // 요약 카드 그리드
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildListDelegate([
                          FeedingSummaryCard(summary: _feedingSummary),
                          SleepSummaryCard(summary: _sleepSummary),
                          DiaperSummaryCard(summary: _diaperSummary),
                          TemperatureSummaryCard(summary: _temperatureSummary),
                        ]),
                      ),
                    ),
                    
                    // 성장 정보 섹션
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          l10n.growthInfo ?? '성장 정보',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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