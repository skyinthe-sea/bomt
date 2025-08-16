import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
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
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  // 터치 관련 변수 제거

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 120), // 2분에 한 바퀄 (느리게)
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 3초로 느리게
      vsync: this,
    );
    
    // ripple 컨트롤러 제거

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

    // ripple 애니메이션 제거

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
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
          // 하단 정보 영역 제거
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
              // 터치 안내 텍스트 제거
            ],
          ),
        ),
        // 터치 뱃지 제거
      ],
    );
  }

  Widget _buildCircularChart() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return SizedBox(
          width: 340,
          height: 340,
          child: RepaintBoundary( // 성능 최적화를 위한 RepaintBoundary 추가
            child: CustomPaint(
              painter: CircularTimelinePainter(
                timelineItems: widget.timelineItems,
                rotationValue: _rotationAnimation.value,
                pulseValue: _pulseAnimation.value,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }

// _buildSelectedHourInfo 함수 제거

  // 터치 핸들러 함수들 제거

  // 터치 관련 함수들 제거
}

class CircularTimelinePainter extends CustomPainter {
  final List<TimelineItem> timelineItems;
  final double rotationValue;
  final double pulseValue;
  final bool isDark;

  CircularTimelinePainter({
    required this.timelineItems,
    required this.rotationValue,
    required this.pulseValue,
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
    
    // 터치 관련 효과 제거
    
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

    // 분 마커도 그리기 (세밀한 마커)
    final minutePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

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

      // 주요 시간 텍스트 (0, 6, 12, 18시) - 더 직관적인 표시
      if (isMainHour) {
        // 24시간 표기를 더 명확하게
        String hourText;
        if (hour == 0) {
          hourText = '0\n자정'; // 0시 자정
        } else if (hour == 6) {
          hourText = '6\n오전'; // 6시 오전
        } else if (hour == 12) {
          hourText = '12\n정오'; // 12시 정오
        } else if (hour == 18) {
          hourText = '18\n오후'; // 18시 오후
        } else {
          hourText = hour.toString();
        }
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: hourText,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black.withOpacity(0.5),
              fontSize: 10, // 좀 더 작게
              fontWeight: FontWeight.w600,
              height: 1.2, // 줄 간격
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center, // 중앙 정렬
        );
        
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + cos(angle) * (radius - 45) - textPainter.width / 2,
          center.dy + sin(angle) * (radius - 45) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, textOffset);
      }
      
      // 분 마커 그리기 (15분마다)
      for (int minute = 15; minute < 60; minute += 15) {
        final minuteAngle = ((hour * 60 + minute) * 0.25 - 90) * pi / 180; // 0.25도 per minute
        
        if (isDark) {
          minutePaint.color = Colors.white.withOpacity(0.1);
        } else {
          minutePaint.color = Colors.black.withOpacity(0.08);
        }
        
        final minuteStartPoint = Offset(
          center.dx + cos(minuteAngle) * (radius - 4),
          center.dy + sin(minuteAngle) * (radius - 4),
        );
        
        final minuteEndPoint = Offset(
          center.dx + cos(minuteAngle) * radius,
          center.dy + sin(minuteAngle) * radius,
        );
        
        canvas.drawLine(minuteStartPoint, minuteEndPoint, minutePaint);
      }
    }
  }

  void _drawActivityRings(Canvas canvas, Offset center, double radius) {
    // 분 단위로 정밀하게 각진 세그먼트 그리기
    for (final item in timelineItems) {
      _drawRectangularActivitySegment(canvas, center, radius, item);
    }
  }

  void _drawRectangularActivitySegment(Canvas canvas, Offset center, double radius, TimelineItem activity) {
    // 타임라인 데이터에서 시작/종료 시간 추출
    final data = activity.data;
    
    // timeline_started_at과 timeline_ended_at 사용 (없으면 기본값 사용)
    DateTime startTime;
    DateTime endTime;
    
    if (data['timeline_started_at'] != null && data['timeline_ended_at'] != null) {
      startTime = DateTime.parse(data['timeline_started_at']);
      endTime = DateTime.parse(data['timeline_ended_at']);
      
    } else {
      // 기본값: timestamp에서 20분 간 지속
      startTime = activity.timestamp;
      endTime = activity.timestamp.add(const Duration(minutes: 20));
    }
    
    // 🔧 FIX: 수면 데이터의 올바른 UTC 로컬 변환
    final originalStartTime = startTime;
    final originalEndTime = endTime;
    
    // 수면 데이터는 보통 UTC로 저장되므로 로컬 시간으로 변환 필요
    if (activity.type == TimelineItemType.sleep) {
      // 수면 데이터는 항상 UTC로 가정하고 로컬 시간으로 변환
      if (startTime.isUtc) {
        startTime = startTime.toLocal();
      } else {
        // UTC가 아니라면 UTC로 가정하고 로컬 시간으로 변환
        startTime = DateTime.utc(
          startTime.year, startTime.month, startTime.day,
          startTime.hour, startTime.minute, startTime.second, startTime.millisecond
        ).toLocal();
      }
      
      if (endTime.isUtc) {
        endTime = endTime.toLocal();
      } else {
        // UTC가 아니라면 UTC로 가정하고 로컬 시간으로 변환
        endTime = DateTime.utc(
          endTime.year, endTime.month, endTime.day,
          endTime.hour, endTime.minute, endTime.second, endTime.millisecond
        ).toLocal();
      }
    } else {
      // 다른 활동은 기존 로직 사용
      if (startTime.isUtc) {
        startTime = startTime.toLocal();
      }
      if (endTime.isUtc) {
        endTime = endTime.toLocal();
      }
    }
    
    // 시작 및 종료 각도 계산 (분 단위로)
    final startMinuteOfDay = startTime.hour * 60 + startTime.minute;
    final endMinuteOfDay = endTime.hour * 60 + endTime.minute;
    
    // 24시간 = 1440분 = 360도, 따라서 1분 = 0.25도
    final minuteToDegree = 360.0 / 1440.0; // 0.25도 per minute
    
    final startAngle = (startMinuteOfDay * minuteToDegree - 90) * pi / 180;
    final endAngle = (endMinuteOfDay * minuteToDegree - 90) * pi / 180;
    
    
    double sweepAngle;
    if (endMinuteOfDay > startMinuteOfDay) {
      sweepAngle = (endMinuteOfDay - startMinuteOfDay) * minuteToDegree * pi / 180;
    } else {
      sweepAngle = ((1440 - startMinuteOfDay) + endMinuteOfDay) * minuteToDegree * pi / 180;
    }
    
    // 최소/최대 지속시간 제한 (1분 ~ 24시간)
    final minSweep = 1 * minuteToDegree * pi / 180; // 1분
    final maxSweep = 1440 * minuteToDegree * pi / 180; // 24시간 (360도)
    sweepAngle = sweepAngle.clamp(minSweep, maxSweep);
    
    final ringRadius = radius - 20;
    final ringWidth = 30.0;
    
    final colors = _getActivityColors(activity.type);
    
    // 각진 세그먼트를 위한 Path 생성
    _drawAngularSegmentPath(canvas, center, ringRadius, ringWidth, startAngle, sweepAngle, colors, activity.isOngoing);
  }
  
  void _drawAngularSegmentPath(Canvas canvas, Offset center, double radius, double width, 
                              double startAngle, double sweepAngle, Map<String, Color> colors, bool isOngoing) {
    final innerRadius = radius - width / 2;
    final outerRadius = radius + width / 2;
    
    // 세그먼트의 4개 코너 점 계산
    final startInner = Offset(
      center.dx + cos(startAngle) * innerRadius,
      center.dy + sin(startAngle) * innerRadius,
    );
    final startOuter = Offset(
      center.dx + cos(startAngle) * outerRadius,
      center.dy + sin(startAngle) * outerRadius,
    );
    
    final endAngle = startAngle + sweepAngle;
    final endInner = Offset(
      center.dx + cos(endAngle) * innerRadius,
      center.dy + sin(endAngle) * innerRadius,
    );
    final endOuter = Offset(
      center.dx + cos(endAngle) * outerRadius,
      center.dy + sin(endAngle) * outerRadius,
    );
    
    // 각진 세그먼트 Path 생성
    final path = Path();
    
    // 시작점에서 시작 (내부 원)
    path.moveTo(startInner.dx, startInner.dy);
    
    // 내부 원을 따라 호 그리기
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle,
      sweepAngle,
      false,
    );
    
    // 종료점에서 직선으로 외부로
    path.lineTo(endOuter.dx, endOuter.dy);
    
    // 외부 원을 따라 역방향 호 그리기
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      endAngle,
      -sweepAngle,
      false,
    );
    
    // 시작점으로 닫기
    path.close();
    
    // 그림자 효과 제거 (색상 번짐 방지)
    
    // 메인 세그먼트
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          colors['primary']!.withOpacity(0.9),
          colors['secondary']!.withOpacity(0.7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    // 진행 중인 활동은 펄스 효과 (크기 조정)
    if (isOngoing) {
      final scale = pulseValue;
      final matrix = Matrix4.identity()
        ..translate(center.dx, center.dy)
        ..scale(scale)
        ..translate(-center.dx, -center.dy);
      path.transform(matrix.storage);
    }
    
    canvas.drawPath(path, paint);
    
    // 윤곽선 (세밀하고 정확한 경계선)
    final outlinePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    canvas.drawPath(path, outlinePaint);
    
    // 시작/종료 경계선 (세로 선)
    _drawBoundaryLines(canvas, center, innerRadius, outerRadius, startAngle, endAngle, colors);
    
    // 마커 제거 (사용자 요청)
  }
  
  void _drawBoundaryLines(Canvas canvas, Offset center, double innerRadius, double outerRadius,
                         double startAngle, double endAngle, Map<String, Color> colors) {
    final boundaryPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 // 더 세밀하게
      ..strokeCap = StrokeCap.butt;
    
    // 경계선을 세그먼트 영역 내에만 그리기
    final adjustedInnerRadius = innerRadius + 1.5; // 안쪽으로 더 들여가기
    final adjustedOuterRadius = outerRadius - 1.5; // 바깥쪽으로 더 들여가기
    
    // 시작 경계선
    final startInner = Offset(
      center.dx + cos(startAngle) * adjustedInnerRadius,
      center.dy + sin(startAngle) * adjustedInnerRadius,
    );
    final startOuter = Offset(
      center.dx + cos(startAngle) * adjustedOuterRadius,
      center.dy + sin(startAngle) * adjustedOuterRadius,
    );
    
    canvas.drawLine(startInner, startOuter, boundaryPaint);
    
    // 종료 경계선 (충분히 큰 세그먼트인 경우만)
    final angleDiff = (endAngle - startAngle).abs();
    if (angleDiff > pi / 24) { // 7.5도 이상 (30분 이상)
      final endInner = Offset(
        center.dx + cos(endAngle) * adjustedInnerRadius,
        center.dy + sin(endAngle) * adjustedInnerRadius,
      );
      final endOuter = Offset(
        center.dx + cos(endAngle) * adjustedOuterRadius,
        center.dy + sin(endAngle) * adjustedOuterRadius,
      );
      
      canvas.drawLine(endInner, endOuter, boundaryPaint);
    }
  }
  
  void _drawAngularMarkers(Canvas canvas, Offset center, double radius, double width,
                          double startAngle, double endAngle, Map<String, Color> colors) {
    // 마커 크기를 세그먼트 두께에 비례하게 조정
    final markerSize = (width * 0.15).clamp(2.0, 3.5);
    
    // 시작 마커 (더 세밀하고 영역 내에)
    final startMarkerPaint = Paint()
      ..color = colors['primary']!.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final startPosition = Offset(
      center.dx + cos(startAngle) * radius,
      center.dy + sin(startAngle) * radius,
    );
    
    canvas.drawCircle(startPosition, markerSize, startMarkerPaint);
    
    // 종료 마커 (세그먼트가 충분히 큰 경우만)
    final angleDiff = (endAngle - startAngle).abs();
    if (angleDiff > pi / 18) { // 10도 이상 (40분 이상)으로 조건 엄격화
      final endMarkerPaint = Paint()
        ..color = colors['secondary']!.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      final endPosition = Offset(
        center.dx + cos(endAngle) * radius,
        center.dy + sin(endAngle) * radius,
      );
      
      canvas.drawCircle(endPosition, markerSize * 0.8, endMarkerPaint);
    }
  }

  // 사용되지 않는 함수들 제거

// _drawSelectedHourHighlight 함수 제거

// _drawRippleEffect 함수 제거

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
  bool shouldRepaint(covariant CircularTimelinePainter oldDelegate) {
    // 타임라인 데이터가 변경되었을 때만 다시 그리기
    if (timelineItems.length != oldDelegate.timelineItems.length) return true;
    
    // 애니메이션은 전체 재그리기보다는 제한적으로
    if ((rotationValue - oldDelegate.rotationValue).abs() > 0.1 || 
        (pulseValue - oldDelegate.pulseValue).abs() > 0.1) {
      return true;
    }
    
    return false;
  }
}