import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
              showWeight ? '체중 변화' : '키 변화',
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
                horizontalInterval: showWeight ? 0.5 : 2,
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
                        // 🎯 2025 트렌드: 메모가 있는 포인트는 글로우 효과와 더 큰 사이즈
                        return FlDotCirclePainter(
                          radius: 6,
                          color: baseColor,
                          strokeWidth: 3,
                          strokeColor: colorScheme.surface,
                        );
                      } else {
                        return FlDotCirclePainter(
                          radius: 4,
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
                  getTooltipColor: (touchedSpot) => colorScheme.inverseSurface.withOpacity(0.9),
                  maxContentWidth: 200,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final dataPoint = chartData[touchedSpot.spotIndex];
                      final unit = showWeight ? 'kg' : 'cm';
                      final date = '${dataPoint.date.month}/${dataPoint.date.day}';
                      
                      // 🎨 2025 트렌드: 더 풍부한 토올팁 정보
                      String tooltipText = '$date\n${dataPoint.value.toStringAsFixed(1)}$unit';
                      
                      if (dataPoint.hasNotes) {
                        tooltipText += '\n\n💭 ${dataPoint.notes}';
                      }
                      
                      return LineTooltipItem(
                        tooltipText,
                        TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        
        // 범례 및 통계
        const SizedBox(height: 16),
        _buildStatistics(chartData, context),
        
        // 🎨 2025 트렌드: 메모 섹션
        _buildNotesSection(chartData, context),
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
            showWeight ? '체중 데이터가 없습니다' : '키 데이터가 없습니다',
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
      '${value.toStringAsFixed(0)}$unit',
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
          _buildStatItem('총 기록', '${data.length}개', colorScheme.onSurface.withOpacity(0.7), context),
          _buildStatItem('시작', '${firstValue.toStringAsFixed(1)}$unit', colorScheme.onSurface.withOpacity(0.7), context),
          _buildStatItem('현재', '${lastValue.toStringAsFixed(1)}$unit', colorScheme.onSurface.withOpacity(0.7), context),
          Row(
            children: [
              Icon(changeIcon, size: 16, color: changeColor),
              const SizedBox(width: 4),
              Column(
                children: [
                  Text(
                    '총 변화',
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

  /// 🎨 2025 최신 트렌드 메모 섹션
  Widget _buildNotesSection(List<ChartDataPoint> data, BuildContext context) {
    final notesData = data.where((point) => point.hasNotes).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final measurementType = showWeight ? '체중' : '키';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        
        // 📝 섹션 헤더 (2025 트렌드)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$measurementType 메모',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${notesData.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 📋 메모 내용 또는 빈 상태
        if (notesData.isEmpty)
          _buildEmptyNotesState(context)
        else
          ...notesData.map((notePoint) => _buildNoteCard(notePoint, context)),
      ],
    );
  }

  /// 🎨 메모가 없을 때의 빈 상태 UI (2025 트렌드)
  Widget _buildEmptyNotesState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final measurementType = showWeight ? '체중' : '키';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🎨 2025 트렌드: 부드러운 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note_outlined,
              size: 32,
              color: colorScheme.primary.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 메인 메시지
          Text(
            '아직 $measurementType 메모가 없어요',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 설명 텍스트
          Text(
            '$measurementType 입력할 때 특별한 순간을\n메모로 남겨보세요!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 2025 글래스모피즘 메모 카드
  Widget _buildNoteCard(ChartDataPoint dataPoint, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unit = showWeight ? 'kg' : 'cm';
    
    // 📅 날짜 포맷팅
    final date = dataPoint.date;
    final formattedDate = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // 🎨 2025 글래스모피즘 효과
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ 헤더: 날짜 + 값
            Row(
              children: [
                // 📊 값 배지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (showWeight ? colorScheme.primary : colorScheme.secondary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        showWeight ? Icons.monitor_weight_outlined : Icons.height,
                        size: 16,
                        color: showWeight ? colorScheme.primary : colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dataPoint.value.toStringAsFixed(1)}$unit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: showWeight ? colorScheme.primary : colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // 📅 날짜 정보
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '($weekday)',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 💭 메모 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                dataPoint.notes!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
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