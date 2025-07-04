import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActivityTimelineChart extends StatelessWidget {
  final Map<String, dynamic> timelineData;
  final bool isPreview;
  final double? size;

  const ActivityTimelineChart({
    super.key,
    required this.timelineData,
    this.isPreview = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartSize = size ?? (isPreview ? 100.0 : 200.0);

    return Container(
      width: chartSize,
      height: chartSize,
      child: CustomPaint(
        painter: ActivityTimelinePainter(
          timelineData: timelineData,
          theme: theme,
          isPreview: isPreview,
        ),
      ),
    );
  }
}

class ActivityTimelinePainter extends CustomPainter {
  final Map<String, dynamic> timelineData;
  final ThemeData theme;
  final bool isPreview;

  ActivityTimelinePainter({
    required this.timelineData,
    required this.theme,
    required this.isPreview,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // 원 배경 그리기
    final backgroundPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPreview ? 2 : 3;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // 시간 표시 (12시간 간격)
    if (!isPreview) {
      _drawTimeMarkers(canvas, center, radius, size);
    }

    // 활동 데이터 그리기
    final activities = timelineData['activities'] as Map<String, dynamic>?;
    if (activities != null) {
      _drawFeedings(canvas, center, radius, activities['feedings']);
      _drawSleeps(canvas, center, radius, activities['sleeps']);
      _drawDiapers(canvas, center, radius, activities['diapers']);
    }

    // 현재 시간 표시
    if (!isPreview) {
      _drawCurrentTime(canvas, center, radius);
    }
  }

  void _drawTimeMarkers(Canvas canvas, Offset center, double radius, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int hour = 0; hour < 24; hour += 6) {
      final angle = (hour * 15 - 90) * math.pi / 180; // 15도씩 (360/24)
      final x = center.dx + (radius + 15) * math.cos(angle);
      final y = center.dy + (radius + 15) * math.sin(angle);

      textPainter.text = TextSpan(
        text: hour == 0 ? '12' : hour.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawCurrentTime(Canvas canvas, Offset center, double radius) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final totalMinutes = hour * 60 + minute;
    final angle = (totalMinutes * 0.25 - 90) * math.pi / 180; // 0.25도/분 (360/1440)

    final currentTimePaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final x = center.dx + radius * 0.8 * math.cos(angle);
    final y = center.dy + radius * 0.8 * math.sin(angle);

    canvas.drawCircle(Offset(x, y), 4, currentTimePaint);
  }

  void _drawFeedings(Canvas canvas, Offset center, double radius, List<dynamic>? feedings) {
    if (feedings == null) return;

    final feedingPaint = Paint()
      ..color = const Color(0xFFFF9800) // 주황색
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPreview ? 3 : 6
      ..strokeCap = StrokeCap.round;

    for (final feeding in feedings) {
      final startedAt = DateTime.parse(feeding['startedAt']);
      final endedAt = feeding['endedAt'] != null 
          ? DateTime.parse(feeding['endedAt'])
          : null;

      final startAngle = _timeToAngle(startedAt);
      
      if (endedAt != null) {
        // 수유 기간이 있는 경우 호로 그리기
        final endAngle = _timeToAngle(endedAt);
        final sweepAngle = _calculateSweepAngle(startAngle, endAngle);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.9),
          startAngle,
          sweepAngle,
          false,
          feedingPaint,
        );
      } else {
        // 순간 수유인 경우 점으로 표시
        final x = center.dx + radius * 0.9 * math.cos(startAngle);
        final y = center.dy + radius * 0.9 * math.sin(startAngle);
        canvas.drawCircle(Offset(x, y), isPreview ? 2 : 4, feedingPaint..style = PaintingStyle.fill);
      }
    }
  }

  void _drawSleeps(Canvas canvas, Offset center, double radius, List<dynamic>? sleeps) {
    if (sleeps == null) return;

    final sleepPaint = Paint()
      ..color = const Color(0xFF9C27B0) // 보라색
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPreview ? 4 : 8
      ..strokeCap = StrokeCap.round;

    for (final sleep in sleeps) {
      final startedAt = DateTime.parse(sleep['startedAt']);
      final endedAt = sleep['endedAt'] != null 
          ? DateTime.parse(sleep['endedAt'])
          : null;

      final startAngle = _timeToAngle(startedAt);
      
      if (endedAt != null) {
        final endAngle = _timeToAngle(endedAt);
        final sweepAngle = _calculateSweepAngle(startAngle, endAngle);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.7),
          startAngle,
          sweepAngle,
          false,
          sleepPaint,
        );
      }
    }
  }

  void _drawDiapers(Canvas canvas, Offset center, double radius, List<dynamic>? diapers) {
    if (diapers == null) return;

    final diaperPaint = Paint()
      ..color = const Color(0xFF4CAF50) // 녹색
      ..style = PaintingStyle.fill;

    for (final diaper in diapers) {
      final changedAt = DateTime.parse(diaper['changedAt']);
      final angle = _timeToAngle(changedAt);
      
      final x = center.dx + radius * 0.5 * math.cos(angle);
      final y = center.dy + radius * 0.5 * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), isPreview ? 2 : 3, diaperPaint);
    }
  }

  double _timeToAngle(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = hour * 60 + minute;
    // 12시를 위쪽(0도)으로 설정하기 위해 -90도부터 시작
    return (totalMinutes * 0.25 - 90) * math.pi / 180;
  }

  double _calculateSweepAngle(double startAngle, double endAngle) {
    double sweepAngle = endAngle - startAngle;
    if (sweepAngle < 0) {
      sweepAngle += 2 * math.pi; // 자정을 넘어가는 경우 처리
    }
    return sweepAngle;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}