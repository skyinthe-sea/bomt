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
    final chartData = _processChartData();
    
    if (chartData.isEmpty) {
      return _buildNoDataMessage();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 차트 제목
        Row(
          children: [
            Icon(
              showWeight ? Icons.monitor_weight_outlined : Icons.height,
              color: showWeight ? Colors.blue[600] : Colors.green[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              showWeight ? '체중 변화' : '키 변화',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
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
                  color: Colors.grey[200]!,
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
                    getTitlesWidget: (value, meta) => _buildLeftTitle(value),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: _calculateBottomInterval(chartData.length),
                    getTitlesWidget: (value, meta) => _buildBottomTitle(value, chartData),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.value);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: showWeight ? Colors.blue[400] : Colors.green[400],
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: showWeight ? Colors.blue[600]! : Colors.green[600]!,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (showWeight ? Colors.blue[400]! : Colors.green[400]!)
                            .withOpacity(0.2),
                        (showWeight ? Colors.blue[400]! : Colors.green[400]!)
                            .withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.grey[800]!,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final dataPoint = chartData[touchedSpot.spotIndex];
                      final unit = showWeight ? 'kg' : 'cm';
                      final date = '${dataPoint.date.month}/${dataPoint.date.day}';
                      
                      return LineTooltipItem(
                        '$date\n${dataPoint.value.toStringAsFixed(1)}$unit',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
        _buildStatistics(chartData),
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
      return ChartDataPoint(
        date: record.recordedAt,
        value: value,
      );
    }).toList();
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showWeight ? Icons.monitor_weight_outlined : Icons.height,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            showWeight ? '체중 데이터가 없습니다' : '키 데이터가 없습니다',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTitle(double value) {
    final unit = showWeight ? 'kg' : 'cm';
    return Text(
      '${value.toStringAsFixed(0)}$unit',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11,
      ),
    );
  }

  Widget _buildBottomTitle(double value, List<ChartDataPoint> data) {
    if (value.toInt() >= data.length || value < 0) return const SizedBox();
    
    final dataPoint = data[value.toInt()];
    final month = dataPoint.date.month;
    final day = dataPoint.date.day;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$month/$day',
        style: TextStyle(
          color: Colors.grey[600],
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

  Widget _buildStatistics(List<ChartDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    final firstValue = data.first.value;
    final lastValue = data.last.value;
    final totalChange = lastValue - firstValue;
    final unit = showWeight ? 'kg' : 'cm';
    
    final changeColor = totalChange >= 0 ? Colors.green[600] : Colors.red[600];
    final changeIcon = totalChange >= 0 ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('총 기록', '${data.length}개', Colors.grey[600]!),
          _buildStatItem('시작', '${firstValue.toStringAsFixed(1)}$unit', Colors.grey[600]!),
          _buildStatItem('현재', '${lastValue.toStringAsFixed(1)}$unit', Colors.grey[600]!),
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
                      color: Colors.grey[500],
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
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
}

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}