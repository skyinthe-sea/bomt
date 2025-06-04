import 'package:flutter/material.dart';
import '../../../../domain/models/statistics.dart';

class StatisticsCardGrid extends StatelessWidget {
  final List<CardStatistics> cardStatistics;

  const StatisticsCardGrid({
    super.key,
    required this.cardStatistics,
  });

  @override
  Widget build(BuildContext context) {
    if (cardStatistics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSectionHeader(context),
          ),
          
          // 카드 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // 카드 높이를 늘려서 오버플로 방지
            ),
            itemCount: cardStatistics.length,
            itemBuilder: (context, index) {
              return _StatisticsCard(
                cardStatistics: cardStatistics[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.grid_view_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '상세 통계',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          '${cardStatistics.length}개 항목',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final CardStatistics cardStatistics;
  final int index;

  const _StatisticsCard({
    required this.cardStatistics,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getCardColor(cardStatistics.cardType, theme);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: cardColor.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14), // 패딩 조금 줄임
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCardIcon(cardStatistics.cardType),
                          color: cardColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cardStatistics.cardName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12), // 간격 줄임
                  
                  // 총 횟수
                  _buildMainMetric(context, theme, cardColor),
                  
                  const SizedBox(height: 10), // 간격 줄임
                  
                  // 주요 메트릭들
                  Expanded(
                    child: _buildKeyMetrics(context, theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetric(BuildContext context, ThemeData theme, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 횟수',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cardStatistics.totalCount}회',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: cardColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, ThemeData theme) {
    final keyMetrics = _getKeyMetrics();
    
    if (keyMetrics.isEmpty) {
      return Center(
        child: Text(
          '상세 데이터 없음',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keyMetrics.map((metric) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 4), // 간격 줄임
          child: _buildMetricRow(context, theme, metric),
        ),
      ).toList(),
    );
  }

  Widget _buildMetricRow(BuildContext context, ThemeData theme, StatisticsMetric metric) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            metric.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          metric.valueWithUnit,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  List<StatisticsMetric> _getKeyMetrics() {
    // 각 카드별로 중요한 메트릭 2-3개만 표시
    final allMetrics = cardStatistics.metrics;
    
    switch (cardStatistics.cardType) {
      case 'feeding':
        return allMetrics.where((m) => 
          m.label == '평균 수유량' || 
          m.label == '평균 수유 시간' ||
          m.label == '하루 평균 수유 횟수'
        ).take(3).toList();
      case 'sleep':
        return allMetrics.where((m) => 
          m.label == '평균 수면 시간' || 
          m.label == '하루 평균 총 수면 시간' ||
          m.label == '하루 평균 수면 횟수'
        ).take(3).toList();
      case 'diaper':
        return allMetrics.where((m) => 
          m.label == '하루 평균 교체 횟수'
        ).take(2).toList();
      default:
        return allMetrics.take(3).toList();
    }
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _StatisticsDetailDialog(
        cardStatistics: cardStatistics,
      ),
    );
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

class _StatisticsDetailDialog extends StatelessWidget {
  final CardStatistics cardStatistics;

  const _StatisticsDetailDialog({
    required this.cardStatistics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getCardColor(cardStatistics.cardType, theme);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCardIcon(cardStatistics.cardType),
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardStatistics.cardName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '상세 통계',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // 메트릭 목록
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: cardStatistics.metrics.map((metric) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metric.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                if (metric.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    metric.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            metric.valueWithUnit,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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