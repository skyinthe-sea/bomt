import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/statistics.dart';
import '../../../../presentation/providers/statistics_provider.dart';
import '../../../../l10n/app_localizations.dart';

class StatisticsChartSection extends StatelessWidget {
  final List<CardStatistics> cardStatistics;

  const StatisticsChartSection({
    super.key,
    required this.cardStatistics,
  });

  @override
  Widget build(BuildContext context) {
    if (cardStatistics.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          _buildSectionHeader(context, theme),
          
          const SizedBox(height: 16),
          
          // 메트릭 타입 선택기
          _buildMetricTypeSelector(context, theme),
          
          const SizedBox(height: 16),
          
          // 차트 리스트
          ...cardStatistics.map((cardStats) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StatisticsChartCard(cardStatistics: cardStats),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          Icons.show_chart_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.chartAnalysis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTypeSelector(BuildContext context, ThemeData theme) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context)!;
        final metricTypes = [
          {'value': 'count', 'label': l10n.countTab},
          {'value': 'amount', 'label': l10n.amountTimeTab},
          {'value': 'duration', 'label': l10n.durationTab},
        ];

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: metricTypes.map((metric) => 
              Expanded(
                child: _buildMetricTypeButton(
                  context: context,
                  theme: theme,
                  label: metric['label']!,
                  value: metric['value']!,
                  isSelected: provider.selectedMetricType == metric['value'],
                  onTap: () => provider.setMetricType(metric['value']!),
                ),
              ),
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMetricTypeButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatisticsChartCard extends StatefulWidget {
  final CardStatistics cardStatistics;

  const _StatisticsChartCard({
    required this.cardStatistics,
  });

  @override
  State<_StatisticsChartCard> createState() => _StatisticsChartCardState();
}

class _StatisticsChartCardState extends State<_StatisticsChartCard> {
  @override
  void initState() {
    super.initState();
    // 차트 위젯이 생성될 때 자동으로 차트 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChartData();
    });
  }

  void _loadChartData() {
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    final existingData = provider.getChartData(widget.cardStatistics.cardType);
    
    // 차트 데이터가 없으면 자동으로 로드
    if (existingData == null) {
      debugPrint('📈 [CHART_CARD] Auto-loading chart data for ${widget.cardStatistics.cardType}');
      provider.refreshChartData(widget.cardStatistics.cardType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getCardColor(widget.cardStatistics.cardType, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardColor.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 차트 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCardIcon(widget.cardStatistics.cardType),
                      color: cardColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getLocalizedCardName(context, widget.cardStatistics.cardType),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _refreshChart(context),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 차트 플레이스홀더
              Consumer<StatisticsProvider>(
                builder: (context, provider, child) {
                  final chartData = provider.getChartData(widget.cardStatistics.cardType);
                  
                  final l10n = AppLocalizations.of(context)!;
                  if (chartData == null) {
                    return _buildChartPlaceholder(theme, l10n.chartDataLoading);
                  } else if (!chartData.hasData) {
                    return _buildChartPlaceholder(theme, l10n.chartDataNotAvailable);
                  } else {
                    return _buildSimpleChart(context, theme, chartData, cardColor);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(ThemeData theme, String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 32,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(BuildContext context, ThemeData theme, StatisticsChartData chartData, Color cardColor) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 차트 제목과 정보
          Row(
            children: [
              Expanded(
                child: Text(
                  _getTranslatedChartTitle(context, chartData.title),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${l10n.averageLabel}${chartData.averageValue.toStringAsFixed(1)}${chartData.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cardColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 간단한 바 차트
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.dataPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final maxValue = chartData.maxDataValue;
                final height = maxValue > 0 ? (point.value / maxValue) : 0.0;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: chartData.dataPoints.length > 15 ? 0.5 : 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: (height * 60).clamp(2.0, 60.0),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.7),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildDateLabel(context, theme, chartData, index, point),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 스마트한 날짜 라벨 생성
  Widget _buildDateLabel(BuildContext context, ThemeData theme, StatisticsChartData chartData, int index, StatisticsDataPoint point) {
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    final dateRange = provider.dateRange;
    final totalDays = chartData.dataPoints.length;
    
    // 날짜 표시 간격 결정
    int displayInterval = _getDisplayInterval(totalDays, dateRange.type);
    
    // 특별한 날짜 (월 시작/중간/끝) 또는 정해진 간격에만 표시
    bool shouldShow = _shouldShowDateLabel(index, totalDays, displayInterval, point.date);
    
    if (!shouldShow) {
      return const SizedBox(height: 12); // 공간 확보를 위한 빈 공간
    }
    
    // 날짜 포맷팅
    String formattedDate = _formatDateLabel(context, point.date, dateRange.type, totalDays);
    
    return Container(
      height: 12,
      child: Text(
        formattedDate,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: totalDays > 15 ? 7 : 8, // 월간일 경우 더 작은 폰트
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 날짜 표시 간격 결정
  int _getDisplayInterval(int totalDays, StatisticsDateRangeType dateRangeType) {
    switch (dateRangeType) {
      case StatisticsDateRangeType.weekly:
        return 1; // 주간: 모든 날짜 표시
      case StatisticsDateRangeType.monthly:
        if (totalDays > 28) {
          return 5; // 월간: 5일 간격 (1, 6, 11, 16, 21, 26, 31일)
        } else {
          return 3; // 짧은 월: 3일 간격
        }
      case StatisticsDateRangeType.custom:
        if (totalDays > 21) {
          return 4; // 커스텀 장기: 4일 간격
        } else if (totalDays > 14) {
          return 2; // 커스텀 중기: 2일 간격
        } else {
          return 1; // 커스텀 단기: 모든 날짜
        }
    }
  }

  /// 날짜 라벨을 표시할지 결정
  bool _shouldShowDateLabel(int index, int totalDays, int interval, DateTime date) {
    // 첫 번째와 마지막은 항상 표시
    if (index == 0 || index == totalDays - 1) {
      return true;
    }
    
    // 월간 차트의 경우 특별한 날짜들 (1일, 15일, 30일, 31일) 표시
    if (totalDays > 25) {
      final day = date.day;
      if (day == 1 || day == 15 || day == 30 || day == 31) {
        return true;
      }
    }
    
    // 정해진 간격으로 표시
    return (index + 1) % interval == 0;
  }

  /// 날짜 포맷팅
  String _formatDateLabel(BuildContext context, DateTime date, StatisticsDateRangeType dateRangeType, int totalDays) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (dateRangeType) {
      case StatisticsDateRangeType.weekly:
        // 주간: 요일 + 날짜 (예: "Mon1", "Tue2")
        final weekdaysString = l10n.weekdaysSundayToSaturday;
        final weekdays = _parseWeekdays(weekdaysString);
        final weekday = weekdays[date.weekday % 7];
        return '$weekday${date.day}';
        
      case StatisticsDateRangeType.monthly:
        // 월간: 날짜만 (예: "1", "15", "30")
        return l10n.dayFormat(date.day);
        
      case StatisticsDateRangeType.custom:
        if (totalDays <= 7) {
          // 짧은 커스텀: 월/일 (예: "7/1")
          return '${date.month}/${date.day}';
        } else {
          // 긴 커스텀: 날짜만
          return l10n.dayFormat(date.day);
        }
    }
  }

  /// 연결된 요일 문자열을 파싱하여 배열로 변환
  List<String> _parseWeekdays(String weekdaysString) {
    // 각 언어에 따라 요일 길이가 다를 수 있으므로 고정 길이로 나누기
    final length = weekdaysString.length ~/ 7; // 7개 요일로 나누기
    final weekdays = <String>[];
    for (int i = 0; i < 7; i++) {
      final start = i * length;
      final end = start + length;
      if (end <= weekdaysString.length) {
        weekdays.add(weekdaysString.substring(start, end));
      }
    }
    
    // 파싱 실패 시 기본값 반환
    if (weekdays.length != 7) {
      final l10n = AppLocalizations.of(context)!;
      return [l10n.sunday, l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday];
    }
    
    return weekdays;
  }

  void _refreshChart(BuildContext context) {
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    provider.refreshChartData(widget.cardStatistics.cardType);
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'diaper':
        return Icons.child_care_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'milk_pumping':
        return Icons.water_drop_rounded;
      case 'solid_food':
        return Icons.restaurant_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  Color _getCardColor(String cardType, ThemeData theme) {
    switch (cardType) {
      case 'feeding':
        return Colors.blue;
      case 'sleep':
        return Colors.indigo;
      case 'diaper':
        return Colors.orange;
      case 'medication':
        return Colors.red;
      case 'milk_pumping':
        return Colors.cyan;
      case 'solid_food':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getLocalizedCardName(BuildContext context, String cardType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (cardType) {
      case 'feeding':
        return l10n.feeding;
      case 'sleep':
        return l10n.sleep;
      case 'diaper':
        return l10n.diaper;
      case 'medication':
        return l10n.medication;
      case 'milk_pumping':
        return l10n.milkPumping;
      case 'solid_food':
        return l10n.solidFood;
      default:
        return cardType; // fallback to cardType if no translation found
    }
  }

  String _getTranslatedChartTitle(BuildContext context, String originalTitle) {
    final l10n = AppLocalizations.of(context)!;
    
    // 기존 한국어 차트 제목을 i18n으로 변환
    switch (originalTitle) {
      // 수유 차트
      case '일별 수유 횟수':
        return l10n.dailyFeedingCount;
      case '일별 수유량':
        return l10n.dailyFeedingAmount;
      case '일별 수유 시간':
        return l10n.dailyFeedingDuration;
      
      // 수면 차트
      case '일별 수면 횟수':
        return l10n.dailySleepCount;
      case '일별 수면 시간':
        return l10n.dailySleepDuration;
      
      // 기저귀 차트
      case '일별 기저귀 교체 횟수':
        return l10n.dailyDiaperChangeCount;
      
      // 투약 차트
      case '일별 투약 횟수':
        return l10n.dailyMedicationCount;
      
      // 유축 차트
      case '일별 유축 횟수':
        return l10n.dailyMilkPumpingCount;
      case '일별 유축량':
        return l10n.dailyMilkPumpingAmount;
      
      // 이유식 차트
      case '일별 이유식 횟수':
        return l10n.dailySolidFoodCount;
      
      // 기본값: 원래 제목 반환 (번역이 없는 경우)
      default:
        return originalTitle;
    }
  }
}