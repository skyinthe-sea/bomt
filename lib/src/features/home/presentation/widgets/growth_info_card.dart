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
    final latestWeight = summary['latestWeight'] ?? 7.2;
    final latestHeight = summary['latestHeight'] ?? 67.0;
    final weightChange = summary['weightChange'] ?? 0.12;
    final heightChange = summary['heightChange'] ?? 1.5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGrowthItem(
              context,
              '체중',
              latestWeight,
              'kg',
              weightChange,
              Colors.purple,
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: theme.dividerColor.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (change != 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  '${isPositive ? '+' : '-'}${change.abs().toStringAsFixed(change < 1 ? 3 : 1)}$unit ${unit == 'kg' ? '(2주)' : '(1개월)'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '변화 없음',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp).toLocal();
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