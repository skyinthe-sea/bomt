import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../domain/models/timeline_item.dart';

class CompactTimelineChart extends StatelessWidget {
  final List<TimelineItem> timelineItems;
  final DateTime selectedDate;

  const CompactTimelineChart({
    Key? key,
    required this.timelineItems,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 80, // 훨씬 더 작은 높이
      width: 80,  // 훨씬 더 작은 크기
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: CustomPaint(
        painter: CompactTimelinePainter(
          timelineItems: timelineItems,
          isDark: isDark,
        ),
      ),
    );
  }
}

class CompactTimelinePainter extends CustomPainter {
  final List<TimelineItem> timelineItems;
  final bool isDark;

  CompactTimelinePainter({
    required this.timelineItems,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 배경 원 그리기
    _drawBackgroundCircle(canvas, center, radius);
    
    // 시간 마커 그리기 (간소화)
    _drawSimpleHourMarkers(canvas, center, radius);
    
    // 활동 링 그리기
    _drawActivityRings(canvas, center, radius);
    
    // 중앙 시계 아이콘 (간소화)
    _drawSimpleCenterClock(canvas, center);
  }

  void _drawBackgroundCircle(Canvas canvas, Offset center, double radius) {
    // 메인 배경 원 (더 간소화)
    final backgroundPaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawSimpleHourMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 매우 간소화된 마커 (12시, 6시만)
    for (int hour in [0, 12]) {
      final angle = (hour * 15 - 90) * pi / 180;
      
      paint.color = isDark 
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.15);

      final startPoint = Offset(
        center.dx + cos(angle) * (radius - 4),
        center.dy + sin(angle) * (radius - 4),
      );
      
      final endPoint = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  void _drawActivityRings(Canvas canvas, Offset center, double radius) {
    final hourlyActivities = <int, List<TimelineItem>>{};
    
    // 시간대별로 활동 그룹화
    for (final item in timelineItems) {
      final hour = item.timestamp.hour;
      hourlyActivities.putIfAbsent(hour, () => []).add(item);
    }

    // 각 시간대의 활동 링 그리기
    hourlyActivities.forEach((hour, activities) {
      _drawHourActivityRing(canvas, center, radius, hour, activities);
    });
  }

  void _drawHourActivityRing(Canvas canvas, Offset center, double radius, 
                            int hour, List<TimelineItem> activities) {
    final startAngle = (hour * 15 - 90) * pi / 180;
    final sweepAngle = 15 * pi / 180; // 15도
    
    final ringRadius = radius - 4;
    final ringWidth = 4.0; // 훨씬 더 얇게

    // 첫 번째 활동만 표시 (간소화)
    if (activities.isNotEmpty) {
      final activity = activities.first;
      final colors = _getActivityColors(activity.type);
      
      final paint = Paint()
        ..color = colors['primary']!.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: ringRadius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  void _drawSimpleCenterClock(Canvas canvas, Offset center) {
    // 중앙 원 (훨씬 더 작게)
    final centerPaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, centerPaint);

    // 매우 간단한 시계 바늘
    final clockPaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;

    // 현재 시간 기준 시침만 (더 짧게)
    final now = DateTime.now();
    final hourAngle = (now.hour % 12 * 30 - 90) * pi / 180;
    final hourHand = Offset(
      center.dx + cos(hourAngle) * 3,
      center.dy + sin(hourAngle) * 3,
    );
    canvas.drawLine(center, hourHand, clockPaint);
  }

  Map<String, Color> _getActivityColors(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.sleep:
        return {'primary': const Color(0xFF8B5FBF), 'secondary': const Color(0xFFB794F6)};
      case TimelineItemType.feeding:
        return {'primary': const Color(0xFF38A169), 'secondary': const Color(0xFF68D391)};
      case TimelineItemType.diaper:
        return {'primary': const Color(0xFFED8936), 'secondary': const Color(0xFFFBD38D)};
      case TimelineItemType.medication:
        return {'primary': const Color(0xFFE53E3E), 'secondary': const Color(0xFFFC8181)};
      case TimelineItemType.milkPumping:
        return {'primary': const Color(0xFF319795), 'secondary': const Color(0xFF81E6D9)};
      case TimelineItemType.solidFood:
        return {'primary': const Color(0xFF3182CE), 'secondary': const Color(0xFF90CDF4)};
      case TimelineItemType.temperature:
        return {'primary': const Color(0xFFD69E2E), 'secondary': const Color(0xFFF6E05E)};
      default:
        return {'primary': const Color(0xFF718096), 'secondary': const Color(0xFFA0AEC0)};
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}