import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.overallActivityOverview,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            statistics.dateRange.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // 총 활동 수
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: l10n.totalActivities,
            value: statistics.totalActivities.toString(),
            subtitle: l10n.timesUnit,
            icon: Icons.timeline_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 활성 카드 수
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: l10n.activeCards,
            value: statistics.cardsWithData.length.toString(),
            subtitle: l10n.itemsUnit,
            icon: Icons.dashboard_rounded,
            color: theme.colorScheme.secondary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 일평균 활동
        Expanded(
          child: _buildMetricCard(
            theme: theme,
            title: l10n.dailyAverage,
            value: (statistics.totalActivities / statistics.dateRange.totalDays).toStringAsFixed(1),
            subtitle: l10n.timesPerDay,
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
      padding: const EdgeInsets.all(14),
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
            size: 20,
          ),
          const SizedBox(height: 8),
          // 세로 배치: "총 활동" (위) + "3 회" (아래)
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          RichText(
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' ${subtitle.replaceAll('/일', '')}', // "/일" 제거
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSummary(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.activityDistributionByCategory,
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
                context: context,
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
    required BuildContext context,
    required ThemeData theme,
    required CardStatistics cardStats,
    required int totalActivities,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
            _getLocalizedCardName(context, cardStats.cardType),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        
        // 활동 수
        Expanded(
          flex: 2,
          child: Text(
            l10n.timesCount(cardStats.totalCount),
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
}