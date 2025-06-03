import 'package:flutter/material.dart';
import '../../../../domain/models/timeline_item.dart';

class HourlyPatternChart extends StatelessWidget {
  final List<TimelineItem> timelineItems;
  final DateTime selectedDate;

  const HourlyPatternChart({
    Key? key,
    required this.timelineItems,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '하루 패턴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHourlyChart(),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHourlyChart() {
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          // 시간 축
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final hour = index * 3;
              return Text(
                '${hour}시',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // 패턴 차트
          Expanded(
            child: Row(
              children: List.generate(8, (index) {
                final startHour = index * 3;
                final endHour = startHour + 3;
                return Expanded(
                  child: _buildHourlyColumn(startHour, endHour),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyColumn(int startHour, int endHour) {
    final activitiesInTimeRange = _getActivitiesInTimeRange(startHour, endHour);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...activitiesInTimeRange.map((activity) => 
            _buildActivityBlock(activity)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActivityBlock(TimelineItemType type) {
    Color color;
    switch (type) {
      case TimelineItemType.sleep:
        color = const Color(0xFFA78BFA); // 파스텔 보라
        break;
      case TimelineItemType.feeding:
        color = const Color(0xFF86EFAC); // 파스텔 녹색
        break;
      case TimelineItemType.diaper:
        color = const Color(0xFFFBBF24); // 파스텔 주황
        break;
      case TimelineItemType.medication:
        color = const Color(0xFFF472B6); // 파스텔 핑크
        break;
      case TimelineItemType.milkPumping:
        color = const Color(0xFF5EEAD4); // 파스텔 청록
        break;
      case TimelineItemType.solidFood:
        color = const Color(0xFF93C5FD); // 파스텔 파랑
        break;
      case TimelineItemType.temperature:
        color = const Color(0xFFFC8181); // 파스텔 빨강
        break;
      default:
        color = const Color(0xFF9CA3AF);
    }

    return Container(
      width: double.infinity,
      height: 16,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  List<TimelineItemType> _getActivitiesInTimeRange(int startHour, int endHour) {
    final activities = <TimelineItemType>[];
    
    for (final item in timelineItems) {
      final itemHour = item.timestamp.hour;
      if (itemHour >= startHour && itemHour < endHour) {
        if (!activities.contains(item.type)) {
          activities.add(item.type);
        }
      }
    }
    
    // 수면, 수유, 기저귀 순서로 우선 정렬
    activities.sort((a, b) {
      const priorityOrder = [
        TimelineItemType.sleep,
        TimelineItemType.feeding,
        TimelineItemType.diaper,
        TimelineItemType.medication,
        TimelineItemType.milkPumping,
        TimelineItemType.solidFood,
        TimelineItemType.temperature,
      ];
      
      return priorityOrder.indexOf(a).compareTo(priorityOrder.indexOf(b));
    });
    
    return activities.take(3).toList(); // 최대 3개까지만 표시
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('수면', const Color(0xFFA78BFA)),
        const SizedBox(width: 24),
        _buildLegendItem('수유', const Color(0xFF86EFAC)),
        const SizedBox(width: 24),
        _buildLegendItem('기저귀', const Color(0xFFFBBF24)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}