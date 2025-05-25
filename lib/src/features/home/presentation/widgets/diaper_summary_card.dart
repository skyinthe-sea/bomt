import 'package:flutter/material.dart';

class DiaperSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const DiaperSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wetCount = summary['wetCount'] ?? 0;
    final dirtyCount = summary['dirtyCount'] ?? 0;
    final mixedCount = summary['mixedCount'] ?? 0;
    final totalCount = wetCount + dirtyCount + mixedCount;

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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.baby_changing_station,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '기저귀',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '총',
                  '$totalCount회',
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  '소변',
                  '$wetCount회',
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  '대변',
                  '$dirtyCount회',
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  '혼합',
                  '$mixedCount회',
                  Colors.purple,
                ),
              ],
            ),
            if (summary['lastChange'] != null) ...[
              const SizedBox(height: 12),
              Text(
                '마지막 교체: ${_formatTime(summary['lastChange'])}',
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 전';
      } else {
        return '${difference.inDays}일 전';
      }
    } catch (e) {
      return '';
    }
  }
}