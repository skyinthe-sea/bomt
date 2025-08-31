import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/growth_record.dart';

class GrowthChartWidget extends StatelessWidget {
  final List<GrowthRecord> records;
  final bool showWeight;

  const GrowthChartWidget({
    super.key,
    required this.records,
    required this.showWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final chartData = _processChartData();
    
    if (chartData.isEmpty) {
      return _buildNoDataMessage(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 차트 제목
        Row(
          children: [
            Icon(
              showWeight ? Icons.monitor_weight_outlined : Icons.height,
              color: showWeight ? colorScheme.primary : colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              showWeight ? localizations.weightChange : localizations.heightChange,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // 차트
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: showWeight ? 0.2 : 1, // 체중 0.2kg, 키 1cm 간격으로 더 세밀하게
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colorScheme.outline.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) => _buildLeftTitle(value, context),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: _calculateBottomInterval(chartData.length),
                    getTitlesWidget: (value, meta) => _buildBottomTitle(value, chartData, context),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
                  bottom: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.value);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: showWeight ? colorScheme.primary : colorScheme.secondary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final hasNotes = index < chartData.length && chartData[index].hasNotes;
                      final baseColor = showWeight ? colorScheme.primary : colorScheme.secondary;
                      
                      if (hasNotes) {
                        // 🎯 메모가 있는 포인트: 기본 원 + 위에 작은 인디케이터
                        return _DotWithIndicatorPainter(
                          radius: 4.5,
                          dotColor: baseColor,
                          strokeColor: colorScheme.surface,
                          strokeWidth: 2,
                          indicatorColor: baseColor,
                        );
                      } else {
                        // 일반 점은 기본 원으로 표시
                        return FlDotCirclePainter(
                          radius: 4.5,
                          color: baseColor,
                          strokeWidth: 2,
                          strokeColor: colorScheme.surface,
                        );
                      }
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (showWeight ? colorScheme.primary : colorScheme.secondary)
                            .withOpacity(0.2),
                        (showWeight ? colorScheme.primary : colorScheme.secondary)
                            .withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  // 에러 방지를 위해 올바른 수의 null 아이템 반환
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) => null).toList();
                  },
                ),
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null) {
                    for (final spot in touchResponse.lineBarSpots!) {
                      final dataPoint = chartData[spot.spotIndex];
                      if (dataPoint.hasNotes) {
                        _showMemoPopup(context, dataPoint);
                        break; // 첫 번째 메모가 있는 점만 처리
                      }
                    }
                  }
                },
                touchSpotThreshold: 20, // 터치 영역을 넓게 설정
              ),
            ),
          ),
        ),
        
        // 범례 및 통계
        const SizedBox(height: 16),
        _buildStatistics(chartData, context),
      ],
    );
  }

  List<ChartDataPoint> _processChartData() {
    final filteredRecords = records.where((record) {
      return showWeight ? record.weightKg != null : record.heightCm != null;
    }).toList();

    // 날짜별로 그룹핑하고 같은 날짜의 경우 마지막 기록 사용
    final Map<String, GrowthRecord> dailyRecords = {};
    
    for (final record in filteredRecords) {
      final dateKey = '${record.recordedAt.year}-${record.recordedAt.month}-${record.recordedAt.day}';
      
      // 같은 날짜가 이미 있으면 더 최근 기록으로 교체
      if (!dailyRecords.containsKey(dateKey) || 
          record.recordedAt.isAfter(dailyRecords[dateKey]!.recordedAt)) {
        dailyRecords[dateKey] = record;
      }
    }

    // 날짜순으로 정렬
    final sortedRecords = dailyRecords.values.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return sortedRecords.map((record) {
      final value = showWeight ? record.weightKg! : record.heightCm!;
      // 🎯 2025 최적화: 체중/키에 맞는 메모만 가져오기
      final effectiveNotes = showWeight 
          ? record.effectiveWeightNotes 
          : record.effectiveHeightNotes;
      
      return ChartDataPoint(
        date: record.recordedAt,
        value: value,
        notes: effectiveNotes,
        record: record,
      );
    }).toList();
  }

  Widget _buildNoDataMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showWeight ? Icons.monitor_weight_outlined : Icons.height,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            showWeight ? localizations.weightDataEmpty : localizations.heightDataEmpty,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTitle(double value, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unit = showWeight ? 'kg' : 'cm';
    return Text(
      '${value.toStringAsFixed(1)}$unit',
      style: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.6),
        fontSize: 11,
      ),
    );
  }

  Widget _buildBottomTitle(double value, List<ChartDataPoint> data, BuildContext context) {
    if (value.toInt() >= data.length || value < 0) return const SizedBox();
    
    final colorScheme = Theme.of(context).colorScheme;
    final dataPoint = data[value.toInt()];
    final month = dataPoint.date.month;
    final day = dataPoint.date.day;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$month/$day',
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11,
        ),
      ),
    );
  }

  double _calculateBottomInterval(int dataLength) {
    if (dataLength <= 5) return 1;
    if (dataLength <= 10) return 2;
    if (dataLength <= 20) return 4;
    return (dataLength / 5).ceil().toDouble();
  }

  Widget _buildStatistics(List<ChartDataPoint> data, BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final firstValue = data.first.value;
    final lastValue = data.last.value;
    final totalChange = lastValue - firstValue;
    final unit = showWeight ? 'kg' : 'cm';
    
    // 성장의 경우 증가가 좋으므로 색상을 다르게 처리
    final changeColor = totalChange >= 0 
      ? (colorScheme.brightness == Brightness.dark ? Colors.green[400] : Colors.green[600])
      : (colorScheme.brightness == Brightness.dark ? Colors.red[400] : Colors.red[600]);
    final changeIcon = totalChange >= 0 ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(localizations.totalRecords, '${data.length}', colorScheme.onSurface.withOpacity(0.7), context),
          _buildStatItem(localizations.start, '${firstValue.toStringAsFixed(1)}$unit', colorScheme.onSurface.withOpacity(0.7), context),
          _buildStatItem(localizations.current, '${lastValue.toStringAsFixed(1)}$unit', colorScheme.onSurface.withOpacity(0.7), context),
          Row(
            children: [
              Icon(changeIcon, size: 16, color: changeColor),
              const SizedBox(width: 4),
              Column(
                children: [
                  Text(
                    localizations.totalChange,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    '${totalChange >= 0 ? '+' : ''}${totalChange.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
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

  Widget _buildStatItem(String label, String value, Color color, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }


  /// 🎯 메모 팝업 표시
  void _showMemoPopup(BuildContext context, ChartDataPoint dataPoint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final unit = showWeight ? 'kg' : 'cm';
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (showWeight ? colorScheme.primary : colorScheme.secondary).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        showWeight ? Icons.monitor_weight_outlined : Icons.height,
                        size: 20,
                        color: showWeight ? colorScheme.primary : colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${showWeight ? localizations.weight : localizations.height} ${localizations.record}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${dataPoint.date.year}.${dataPoint.date.month.toString().padLeft(2, '0')}.${dataPoint.date.day.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 값 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${dataPoint.value.toStringAsFixed(1)}$unit',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: showWeight ? colorScheme.primary : colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            (showWeight ? colorScheme.primary : colorScheme.secondary).red,
                            (showWeight ? colorScheme.primary : colorScheme.secondary).green,
                            (showWeight ? colorScheme.primary : colorScheme.secondary).blue,
                            0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sticky_note_2,
                          color: showWeight ? colorScheme.primary : colorScheme.secondary,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 메모 내용
                Text(
                  localizations.memo,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dataPoint.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? notes;
  final GrowthRecord record;

  ChartDataPoint({
    required this.date,
    required this.value,
    this.notes,
    required this.record,
  });

  bool get hasNotes => notes != null && notes!.isNotEmpty;
}

/// 🎯 기본 원점 + 인디케이터가 있는 커스텀 dot 페인터
class _DotWithIndicatorPainter extends FlDotPainter {
  final double radius;
  final Color dotColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color indicatorColor;

  _DotWithIndicatorPainter({
    required this.radius,
    required this.dotColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.indicatorColor,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;


    // 1. 기본 원점 그리기
    canvas.drawCircle(offsetInCanvas, radius, dotPaint);
    canvas.drawCircle(offsetInCanvas, radius, strokePaint);

    // 2. 작은 인디케이터 (원형 배지) 그리기 - 점 우상단에 위치
    final indicatorCenter = Offset(
      offsetInCanvas.dx + radius * 0.7, // 우상단으로 위치
      offsetInCanvas.dy - radius * 0.7,
    );
    
    final indicatorRadius = radius * 0.35; // 작은 크기
    
    // 인디케이터 배경 (더 밝은 색상)
    final indicatorBgPaint = Paint()
      ..color = Color.fromRGBO(
        indicatorColor.red,
        indicatorColor.green,
        indicatorColor.blue,
        0.9,
      )
      ..style = PaintingStyle.fill;

    // 작은 원형 배지 그리기
    canvas.drawCircle(indicatorCenter, indicatorRadius, indicatorBgPaint);
    
    // 인디케이터 테두리 (얇게)
    final indicatorStrokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(indicatorCenter, indicatorRadius, indicatorStrokePaint);
    
    // 중심에 작은 점 추가 (더 명확하게)
    final centerDotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorCenter, indicatorRadius * 0.4, centerDotPaint);
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(radius * 2.4, radius * 2.4); // 인디케이터까지 고려한 크기
  }

  @override
  Color get mainColor => dotColor;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is _DotWithIndicatorPainter && b is _DotWithIndicatorPainter) {
      return _DotWithIndicatorPainter(
        radius: lerpDouble(a.radius, b.radius, t) ?? radius,
        dotColor: Color.lerp(a.dotColor, b.dotColor, t) ?? dotColor,
        strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t) ?? strokeColor,
        strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t) ?? strokeWidth,
        indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t) ?? indicatorColor,
      );
    }
    return this;
  }

  @override
  List<Object?> get props => [radius, dotColor, strokeColor, strokeWidth, indicatorColor];
}