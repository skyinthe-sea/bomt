import 'package:flutter/material.dart';
import '../../../../domain/models/statistics.dart';

class StatisticsOverviewCard extends StatelessWidget {
  final Statistics statistics;

  const StatisticsOverviewCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '전체 활동 개요',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            statistics.dateRange.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 메트릭 그리드
                _buildMetricsGrid(context, theme),
                
                const SizedBox(height: 16),
                
                // 카드별 요약
                _buildCardSummary(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // 총 활동 수
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: '총 활동',
            value: statistics.totalActivities.toString(),
            subtitle: '회',
            icon: Icons.timeline_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 활성 카드 수
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: '활성 카드',
            value: statistics.cardsWithData.length.toString(),
            subtitle: '개',
            icon: Icons.dashboard_rounded,
            color: theme.colorScheme.secondary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 일평균 활동
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: '일평균',
            value: (statistics.totalActivities / statistics.dateRange.totalDays).toStringAsFixed(1),
            subtitle: '회/일',
            icon: Icons.trending_up_rounded,
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSummary(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '카드별 활동 분포',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...statistics.cardsWithData.map((cardStats) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCardSummaryItem(
                theme: theme,
                cardStats: cardStats,
                totalActivities: statistics.totalActivities,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSummaryItem({
    required ThemeData theme,
    required CardStatistics cardStats,
    required int totalActivities,
  }) {
    final percentage = totalActivities > 0 
        ? (cardStats.totalCount / totalActivities * 100)
        : 0.0;

    return Row(
      children: [
        // 카드 아이콘
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getCardColor(cardStats.cardType, theme),
            shape: BoxShape.circle,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 카드명
        Expanded(
          flex: 3,
          child: Text(
            cardStats.cardName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        
        // 활동 수
        Expanded(
          flex: 2,
          child: Text(
            '${cardStats.totalCount}회',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // 비율
        Expanded(
          flex: 2,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _getCardColor(cardStats.cardType, theme),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
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