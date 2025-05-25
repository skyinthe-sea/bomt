import 'package:flutter/material.dart';

class GrowthInfoCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const GrowthInfoCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestWeight = summary['latestWeight'] ?? 0.0;
    final latestHeight = summary['latestHeight'] ?? 0.0;
    final weightChange = summary['weightChange'] ?? 0.0;
    final heightChange = summary['heightChange'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '성장',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGrowthItem(
                    context,
                    '몸무게',
                    latestWeight,
                    'kg',
                    weightChange,
                    Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _buildGrowthItem(
                    context,
                    '키',
                    latestHeight,
                    'cm',
                    heightChange,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (summary['lastMeasurement'] != null) ...[
              const SizedBox(height: 12),
              Text(
                '마지막 측정: ${_formatDate(summary['lastMeasurement'])}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthItem(
    BuildContext context,
    String label,
    double value,
    String unit,
    double change,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isPositive = change >= 0;
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        if (change != 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}$unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            '변화 없음',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return '오늘';
      } else if (difference.inDays == 1) {
        return '어제';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}주 전';
      } else {
        return '${(difference.inDays / 30).floor()}개월 전';
      }
    } catch (e) {
      return '';
    }
  }
}