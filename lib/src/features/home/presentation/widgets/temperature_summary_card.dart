import 'package:flutter/material.dart';

class TemperatureSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const TemperatureSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestTemp = summary['latestTemperature'] ?? 0.0;
    final minTemp = summary['minTemperature'] ?? 0.0;
    final maxTemp = summary['maxTemperature'] ?? 0.0;
    final avgTemp = summary['avgTemperature'] ?? 0.0;
    final count = summary['count'] ?? 0;

    // Determine temperature status
    final tempStatus = _getTemperatureStatus(latestTemp);
    final statusColor = _getStatusColor(tempStatus);

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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.thermostat,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '체온',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tempStatus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (count > 0) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      '${latestTemp.toStringAsFixed(1)}°C',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTempRange(
                          context,
                          '최저',
                          minTemp,
                          Colors.blue,
                        ),
                        const SizedBox(width: 24),
                        _buildTempRange(
                          context,
                          '평균',
                          avgTemp,
                          theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 24),
                        _buildTempRange(
                          context,
                          '최고',
                          maxTemp,
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (summary['lastMeasurement'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  '마지막 측정: ${_formatTime(summary['lastMeasurement'])}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    '오늘 측정 기록이 없습니다',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempRange(
    BuildContext context,
    String label,
    double temp,
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
          '${temp.toStringAsFixed(1)}°',
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 36.0) {
      return '저체온';
    } else if (temp >= 36.0 && temp < 37.5) {
      return '정상';
    } else if (temp >= 37.5 && temp < 38.0) {
      return '미열';
    } else {
      return '고열';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '저체온':
        return Colors.blue;
      case '정상':
        return Colors.green;
      case '미열':
        return Colors.orange;
      case '고열':
        return Colors.red;
      default:
        return Colors.grey;
    }
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