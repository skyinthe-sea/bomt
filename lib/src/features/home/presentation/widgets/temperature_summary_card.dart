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
    final isDark = theme.brightness == Brightness.dark;
    final latestTemp = summary['latestTemperature'] ?? 36.5;
    final minTemp = summary['minTemperature'] ?? 0.0;
    final maxTemp = summary['maxTemperature'] ?? 0.0;
    final avgTemp = summary['avgTemperature'] ?? 0.0;
    final count = summary['count'] ?? 0;

    // Determine temperature status
    final tempStatus = _getTemperatureStatus(latestTemp);
    final statusColor = _getStatusColor(tempStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.orange.withOpacity(0.1)
            : const Color(0xFFFFFFF0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Icon(
                Icons.thermostat,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '건강',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 메인 콘텐츠 - 좌우 레이아웃
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 왼쪽: 메인 수치
              Text(
                '${latestTemp.toStringAsFixed(1)}°C',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              // 오른쪽: 부가 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '최근 체온',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tempStatus,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
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