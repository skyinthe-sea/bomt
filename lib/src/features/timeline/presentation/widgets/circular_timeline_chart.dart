import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import '../../../../domain/models/timeline_item.dart';

class CircularTimelineChart extends StatefulWidget {
  final List<TimelineItem> timelineItems;
  final DateTime selectedDate;
  final bool hideLabels; // 텍스트 라벨 숨기기 옵션

  const CircularTimelineChart({
    Key? key,
    required this.timelineItems,
    required this.selectedDate,
    this.hideLabels = false, // 기본값은 false (라벨 표시)
  }) : super(key: key);

  @override
  State<CircularTimelineChart> createState() => _CircularTimelineChartState();
}

class _CircularTimelineChartState extends State<CircularTimelineChart>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  int? _selectedHour;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60), // 1분에 한 바퀴
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: isDark ? [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ] : [
            Colors.black.withOpacity(0.04),
            Colors.black.withOpacity(0.02),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (!widget.hideLabels) ...[
            _buildHeader(),
            const SizedBox(height: 24),
          ],
          _buildCircularChart(),
          if (!widget.hideLabels) ...[
            const SizedBox(height: 20),
            if (_selectedHour != null) _buildSelectedHourInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hourActivityPattern,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.touchClockInstruction,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.2),
                const Color(0xFF34D399).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFF059669),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.touch,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularChart() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _rippleAnimation,
      ]),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onTapUp: _handleTapUp,
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: CircularTimelinePainter(
                timelineItems: widget.timelineItems,
                selectedHour: _selectedHour,
                rotationValue: _rotationAnimation.value,
                pulseValue: _pulseAnimation.value,
                rippleValue: _rippleAnimation.value,
                rippleCenter: _lastPanPosition,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedHourInfo() {
    final hourlyActivities = _getActivitiesForHour(_selectedHour!);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ] : [
            Colors.black.withOpacity(0.08),
            Colors.black.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.3)
            : Colors.black.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: _getHourColor(_selectedHour!),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedHour!.toString().padLeft(2, '0')}:00 ${AppLocalizations.of(context)!.timeSlot}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hourlyActivities.isEmpty)
            Text(
              l10n.noActivitiesInTimeframe,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hourlyActivities.map((activity) {
                final colors = _getActivityColors(activity.type);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors['primary']!.withOpacity(0.2),
                        colors['secondary']!.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors['primary']!.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActivityIcon(activity.type),
                        color: colors['primary'],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors['primary'],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final center = Offset(140, 140); // 차트 중심
    final position = details.localPosition - center;
    final angle = atan2(position.dy, position.dx);
    final normalizedAngle = (angle + pi/2) % (2 * pi);
    final hour = ((normalizedAngle / (2 * pi)) * 24).floor();
    
    if (_selectedHour != hour) {
      setState(() {
        _selectedHour = hour;
        _lastPanPosition = details.localPosition;
      });
      
      HapticFeedback.lightImpact();
      _rippleController.forward(from: 0);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final center = Offset(140, 140);
    final position = details.localPosition - center;
    final distance = sqrt(position.dx * position.dx + position.dy * position.dy);
    
    // 차트 영역 내부인지 확인
    if (distance >= 60 && distance <= 120) {
      final angle = atan2(position.dy, position.dx);
      final normalizedAngle = (angle + pi/2) % (2 * pi);
      final hour = ((normalizedAngle / (2 * pi)) * 24).floor();
      
      setState(() {
        _selectedHour = hour;
        _lastPanPosition = details.localPosition;
      });
      
      HapticFeedback.mediumImpact();
      _rippleController.forward(from: 0);
    }
  }

  List<TimelineItem> _getActivitiesForHour(int hour) {
    return widget.timelineItems.where((item) {
      return item.timestamp.hour == hour;
    }).toList();
  }

  Color _getHourColor(int hour) {
    // 시간대별 색상 (하루의 리듬을 반영)
    if (hour >= 6 && hour < 12) {
      return const Color(0xFFFBBF24); // 아침 - 노란색
    } else if (hour >= 12 && hour < 18) {
      return const Color(0xFF10B981); // 낮 - 초록색
    } else if (hour >= 18 && hour < 22) {
      return const Color(0xFFEF4444); // 저녁 - 빨간색
    } else {
      return const Color(0xFF8B5FBF); // 밤 - 보라색
    }
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

  IconData _getActivityIcon(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.sleep:
        return Icons.bedtime_rounded;
      case TimelineItemType.feeding:
        return Icons.water_drop_rounded;
      case TimelineItemType.diaper:
        return Icons.child_care_rounded;
      case TimelineItemType.medication:
        return Icons.medication_rounded;
      case TimelineItemType.milkPumping:
        return Icons.opacity_rounded;
      case TimelineItemType.solidFood:
        return Icons.restaurant_rounded;
      case TimelineItemType.temperature:
        return Icons.thermostat_rounded;
      default:
        return Icons.circle;
    }
  }
}

class CircularTimelinePainter extends CustomPainter {
  final List<TimelineItem> timelineItems;
  final int? selectedHour;
  final double rotationValue;
  final double pulseValue;
  final double rippleValue;
  final Offset? rippleCenter;
  final bool isDark;

  CircularTimelinePainter({
    required this.timelineItems,
    this.selectedHour,
    required this.rotationValue,
    required this.pulseValue,
    required this.rippleValue,
    this.rippleCenter,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;

    // 배경 원 그리기
    _drawBackgroundCircle(canvas, center, radius);
    
    // 시간 마커 그리기
    _drawHourMarkers(canvas, center, radius);
    
    // 활동 링 그리기
    _drawActivityRings(canvas, center, radius);
    
    // 선택된 시간 하이라이트
    if (selectedHour != null) {
      _drawSelectedHourHighlight(canvas, center, radius);
    }
    
    // 리플 효과
    if (rippleCenter != null) {
      _drawRippleEffect(canvas);
    }
    
    // 중앙 시계 아이콘
    _drawCenterClock(canvas, center);
  }

  void _drawBackgroundCircle(Canvas canvas, Offset center, double radius) {
    // 외부 그라디언트 링
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark ? [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ] : [
          Colors.black.withOpacity(0.06),
          Colors.black.withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20));
    
    canvas.drawCircle(center, radius + 20, outerPaint);

    // 메인 배경 원
    final backgroundPaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawCircle(center, radius - 30, backgroundPaint);
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int hour = 0; hour < 24; hour++) {
      final angle = (hour * 15 - 90) * pi / 180; // 15도씩 (360/24)
      final isMainHour = hour % 6 == 0; // 6시간마다 주요 마커
      
      if (isDark) {
        paint.color = isMainHour 
            ? Colors.white.withOpacity(0.6)
            : Colors.white.withOpacity(0.2);
      } else {
        paint.color = isMainHour 
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.15);
      }

      final startRadius = isMainHour ? radius - 15 : radius - 8;
      final endRadius = radius;

      final startPoint = Offset(
        center.dx + cos(angle) * startRadius,
        center.dy + sin(angle) * startRadius,
      );
      
      final endPoint = Offset(
        center.dx + cos(angle) * endRadius,
        center.dy + sin(angle) * endRadius,
      );

      canvas.drawLine(startPoint, endPoint, paint);

      // 주요 시간 텍스트 (0, 6, 12, 18시)
      if (isMainHour) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: hour.toString(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + cos(angle) * (radius - 30) - textPainter.width / 2,
          center.dy + sin(angle) * (radius - 30) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, textOffset);
      }
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
    
    final ringRadius = radius - 15;
    final ringWidth = 20.0;

    // 활동별로 레이어링
    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final colors = _getActivityColors(activity.type);
      final layerRadius = ringRadius - (i * 6); // 레이어별로 반지름 감소
      
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors['primary']!.withOpacity(0.8),
            colors['secondary']!.withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth - (i * 3) // 레이어별로 두께 감소
        ..strokeCap = StrokeCap.round;

      // 진행 중인 활동은 펄스 효과
      if (activity.isOngoing) {
        paint.strokeWidth *= pulseValue;
      }

      final rect = Rect.fromCircle(center: center, radius: layerRadius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  void _drawSelectedHourHighlight(Canvas canvas, Offset center, double radius) {
    final angle = (selectedHour! * 15 - 90) * pi / 180;
    final sweepAngle = 15 * pi / 180;
    
    final highlightPaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 15);
    canvas.drawArc(rect, angle, sweepAngle, false, highlightPaint);
  }

  void _drawRippleEffect(Canvas canvas) {
    if (rippleCenter == null) return;

    final ripplePaint = Paint()
      ..color = isDark 
        ? Colors.white.withOpacity(0.3 * (1 - rippleValue))
        : Colors.black.withOpacity(0.12 * (1 - rippleValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      rippleCenter!,
      30 * rippleValue,
      ripplePaint,
    );
  }

  void _drawCenterClock(Canvas canvas, Offset center) {
    // 중앙 원
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF667EEA),
          Color(0xFF764BA2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 25))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 25, centerPaint);

    // 시계 아이콘 (간단한 시침/분침)
    final clockPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // 시침 (현재 시간 기준)
    final now = DateTime.now();
    final hourAngle = (now.hour % 12 * 30 - 90) * pi / 180;
    final hourHand = Offset(
      center.dx + cos(hourAngle) * 12,
      center.dy + sin(hourAngle) * 12,
    );
    canvas.drawLine(center, hourHand, clockPaint);

    // 분침
    final minuteAngle = (now.minute * 6 - 90) * pi / 180;
    final minuteHand = Offset(
      center.dx + cos(minuteAngle) * 18,
      center.dy + sin(minuteAngle) * 18,
    );
    canvas.drawLine(center, minuteHand, clockPaint);

    // 중심점
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
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