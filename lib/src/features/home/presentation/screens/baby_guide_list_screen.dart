import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/models/baby.dart';
import '../../../../domain/models/baby_guide.dart';
import '../../../../domain/models/baby_guide_extensions.dart';
import '../../../../services/baby_guide/baby_guide_service.dart';
import '../../../../services/locale/locale_service.dart';
import '../widgets/baby_guide_alert.dart';

class BabyGuideListScreen extends StatefulWidget {
  final Baby baby;

  const BabyGuideListScreen({
    super.key,
    required this.baby,
  });

  @override
  State<BabyGuideListScreen> createState() => _BabyGuideListScreenState();
}

class _BabyGuideListScreenState extends State<BabyGuideListScreen> {
  final _babyGuideService = BabyGuideService.instance;
  final _localeService = LocaleService.instance;
  
  List<BabyGuide> _guides = [];
  bool _isLoading = true;
  int _currentWeek = 0;
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [BabyGuideListScreen] initState called');
    _checkLanguageChange();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    try {
      setState(() => _isLoading = true);
      
      // 현재 주령 계산
      _currentWeek = _babyGuideService.calculateWeekNumber(widget.baby.birthDate);
      
      // 사용자 설정 언어를 우선적으로 사용하는 로케일 정보 가져오기
      final localeInfo = await _babyGuideService.getUserLocaleInfo();
      final countryCode = localeInfo['countryCode']!;
      final languageCode = localeInfo['languageCode']!;
      
      debugPrint('BabyGuideListScreen: Loading guides with $countryCode/$languageCode');
      
      // 0주차부터 현재 주령 + 1주까지의 가이드 로드
      final guides = <BabyGuide>[];
      final maxWeek = _currentWeek + 1;
      
      for (int week = 0; week <= maxWeek; week++) {
        final guide = await _babyGuideService.getGuideForWeek(
          week,
          countryCode,
          languageCode,
        );
        if (guide != null) {
          guides.add(guide);
        }
      }
      
      // 주차별 내림차순 정렬
      guides.sort((a, b) => b.weekNumber.compareTo(a.weekNumber));
      
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading guides: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showGuideAlert(BabyGuide guide) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BabyGuideAlert(
        guide: guide,
        baby: widget.baby,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 언어 변경 감지 - 시스템 로케일 확인
    final currentLocale = Localizations.localeOf(context);
    final currentLanguageCode = currentLocale.languageCode;
    
    debugPrint('🔍 [BabyGuideListScreen] didChangeDependencies: currentLocale=$currentLocale, lastLanguage=$_lastLanguageCode');
    
    if (_lastLanguageCode != null && _lastLanguageCode != currentLanguageCode) {
      debugPrint('🌍 [BabyGuideListScreen] Language changed from $_lastLanguageCode to $currentLanguageCode - reloading guides');
      _loadGuides();
    }
    _lastLanguageCode = currentLanguageCode;
  }

  /// SharedPreferences를 직접 확인하여 언어 변경 감지
  Future<void> _checkLanguageChange() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserLanguage = prefs.getString('selected_language');
      
      debugPrint('🔍 [BabyGuideListScreen] Current user language from prefs: $currentUserLanguage');
      
      if (_lastLanguageCode != null && _lastLanguageCode != currentUserLanguage) {
        debugPrint('🌍 [BabyGuideListScreen] User language changed from $_lastLanguageCode to $currentUserLanguage - reloading guides');
        _lastLanguageCode = currentUserLanguage;
        await _loadGuides();
      } else if (_lastLanguageCode == null) {
        _lastLanguageCode = currentUserLanguage ?? 'ko';
      }
    } catch (e) {
      debugPrint('❌ [BabyGuideListScreen] Error checking language change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    debugPrint('🔄 [BabyGuideListScreen] build called');
    
    // 언어 변경 체크를 비동기로 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLanguageChange();
    });
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.babyGuideTitle(widget.baby.name),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guides.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noAvailableGuides,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGuides,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _guides.length,
                    itemBuilder: (context, index) {
                      final guide = _guides[index];
                      final isPast = guide.weekNumber < _currentWeek;
                      final isCurrent = guide.weekNumber == _currentWeek;
                      final isFuture = guide.weekNumber > _currentWeek;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildGuideCard(guide, isPast, isCurrent, isFuture, theme),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildGuideCard(
    BabyGuide guide,
    bool isPast,
    bool isCurrent,
    bool isFuture,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    Color cardColor;
    Color borderColor;
    Color iconColor;
    IconData statusIcon;
    String statusText;
    
    if (isCurrent) {
      if (isDark) {
        cardColor = const Color(0xFF1E3A8A).withOpacity(0.2); // 다크 블루 배경
        borderColor = const Color(0xFF3B82F6).withOpacity(0.6); // 더 밝은 블루 경계
        iconColor = const Color(0xFF60A5FA); // 밝은 블루 아이콘
      } else {
        cardColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
        iconColor = Colors.blue.shade600;
      }
      statusIcon = Icons.star;
      statusText = AppLocalizations.of(context)!.current;
    } else if (isPast) {
      if (isDark) {
        cardColor = const Color(0xFF374151).withOpacity(0.3); // 다크 그레이 배경
        borderColor = const Color(0xFF6B7280).withOpacity(0.6); // 그레이 경계
        iconColor = const Color(0xFF9CA3AF); // 밝은 그레이 아이콘
      } else {
        cardColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        iconColor = Colors.grey.shade600;
      }
      statusIcon = Icons.check_circle_outline;
      statusText = AppLocalizations.of(context)!.past;
    } else {
      if (isDark) {
        cardColor = const Color(0xFF92400E).withOpacity(0.2); // 다크 오렌지 배경
        borderColor = const Color(0xFFF59E0B).withOpacity(0.6); // 더 밝은 오렌지 경계
        iconColor = const Color(0xFFFBBF24); // 밝은 오렌지 아이콘
      } else {
        cardColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconColor = Colors.orange.shade600;
      }
      statusIcon = Icons.schedule;
      statusText = AppLocalizations.of(context)!.upcoming;
    }

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: () => _showGuideAlert(guide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.getWeekText(l10n),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 메시지 미리보기
              Text(
                guide.message.length > 80
                    ? '${guide.message.substring(0, 80)}...'
                    : guide.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 수유 정보 요약
              if (guide.getFrequencyRange(l10n) != null || guide.getSingleFeedingRange(l10n) != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? theme.colorScheme.surface.withOpacity(0.8)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.baby_changing_station,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [
                            if (guide.getFrequencyRange(l10n) != null) guide.getFrequencyRange(l10n)!,
                            if (guide.getSingleFeedingRange(l10n) != null) guide.getSingleFeedingRange(l10n)!,
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}