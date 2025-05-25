import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      
      // 임시로 하드코딩된 아기 정보 사용 (Supabase 연결 문제 해결 전까지)
      final baby = Baby(
        id: 'temp-baby-id',
        name: '임지서',
        birthDate: DateTime(2024, 10, 15),
        gender: 'male',
      );
      
      // 각종 요약 데이터 로드 (이미 샘플 데이터를 반환하도록 수정됨)
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
      
      // 실제 Supabase 쿼리는 주석 처리 (나중에 활성화)
      // final response = await Supabase.instance.client
      //     .from('baby_users')
      //     .select('babies(*)')
      //     .eq('user_id', '4271061560');
      // 
      // if (response.isNotEmpty && response.first['babies'] != null) {
      //   final babyData = response.first['babies'];
      //   final baby = Baby.fromJson(babyData);
      //   ...
      // }
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
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