import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/statistics.dart';
import '../../../../presentation/providers/statistics_provider.dart';

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
    return Row(
      children: [
        Icon(
          Icons.show_chart_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '차트 분석',
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
        final metricTypes = [
          {'value': 'count', 'label': '횟수'},
          {'value': 'amount', 'label': '양/시간'},
          {'value': 'duration', 'label': '지속시간'},
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
                      widget.cardStatistics.cardName,
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
                  
                  if (chartData == null) {
                    return _buildChartPlaceholder(theme, '차트 데이터 로딩 중...');
                  } else if (!chartData.hasData) {
                    return _buildChartPlaceholder(theme, '차트 데이터가 없습니다.');
                  } else {
                    return _buildSimpleChart(theme, chartData, cardColor);
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

  Widget _buildSimpleChart(ThemeData theme, StatisticsChartData chartData, Color cardColor) {
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
                  chartData.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '평균: ${chartData.averageValue.toStringAsFixed(1)}${chartData.unit}',
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
                    padding: EdgeInsets.symmetric(horizontal: 1.0),
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
                        if (index % (chartData.dataPoints.length > 7 ? 2 : 1) == 0)
                          Text(
                            point.label ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
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
}