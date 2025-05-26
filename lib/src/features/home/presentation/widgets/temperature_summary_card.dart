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
    final latestTemp = summary['latestTemperature'] ?? 36.5;
    final minTemp = summary['minTemperature'] ?? 0.0;
    final maxTemp = summary['maxTemperature'] ?? 0.0;
    final avgTemp = summary['avgTemperature'] ?? 0.0;
    final count = summary['count'] ?? 0;

    // Determine temperature status
    final tempStatus = _getTemperatureStatus(latestTemp);
    final statusColor = _getStatusColor(tempStatus);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.thermostat,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '체온',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 메인 수치
          Text(
            '${latestTemp.toStringAsFixed(1)}°C',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          // 부가 정보
          Text(
            '최근 체온',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          // 상태 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tempStatus,
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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