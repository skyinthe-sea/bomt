import 'package:flutter/material.dart';
import '../../../../domain/models/baby.dart';
import '../../../../domain/models/baby_guide.dart';
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

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    try {
      setState(() => _isLoading = true);
      
      // 현재 주령 계산
      _currentWeek = _babyGuideService.calculateWeekNumber(widget.baby.birthDate);
      
      // 로케일 정보 가져오기
      final localeInfo = await _localeService.getLocaleInfo();
      final countryCode = localeInfo['countryCode']!;
      final languageCode = localeInfo['languageCode']!;
      
      // 0주차부터 현재 주령 + 3주까지의 가이드 로드
      final guides = <BabyGuide>[];
      final maxWeek = _currentWeek + 3;
      
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          '${widget.baby.name}의 육아 가이드',
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
                        '사용 가능한 가이드가 없습니다',
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
    Color cardColor;
    Color borderColor;
    IconData statusIcon;
    String statusText;
    
    if (isCurrent) {
      cardColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
      statusIcon = Icons.star;
      statusText = '현재';
    } else if (isPast) {
      cardColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
      statusIcon = Icons.check_circle_outline;
      statusText = '지남';
    } else {
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      statusIcon = Icons.schedule;
      statusText = '예정';
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
                      color: borderColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: borderColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.weekText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: borderColor,
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
              if (guide.frequencyRange != null || guide.singleFeedingRange != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
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
                            if (guide.frequencyRange != null) guide.frequencyRange!,
                            if (guide.singleFeedingRange != null) guide.singleFeedingRange!,
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