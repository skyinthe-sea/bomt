import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/baby.dart';
import '../../../../services/health/health_service.dart';

class TemperatureChartScreen extends StatefulWidget {
  final Baby baby;

  const TemperatureChartScreen({
    super.key,
    required this.baby,
  });

  @override
  State<TemperatureChartScreen> createState() => _TemperatureChartScreenState();
}

class _TemperatureChartScreenState extends State<TemperatureChartScreen> 
    with TickerProviderStateMixin {
  int _selectedDays = 7;
  bool _isLoading = false;
  Map<String, dynamic> _temperatureData = {};
  
  // 메모 팝업 관련 상태
  bool _isNotePopupVisible = false;
  String? _selectedNote;
  DateTime? _selectedTime;
  double? _selectedTemp;
  Offset _popupPosition = Offset.zero;
  
  late AnimationController _popupAnimationController;
  late Animation<double> _popupScaleAnimation;
  late Animation<double> _popupOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _popupAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _popupScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _popupOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _loadTemperatureData();
  }
  
  @override
  void dispose() {
    _popupAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTemperatureData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await HealthService.instance.getTemperatureTrend(
        widget.baby.id,
        days: _selectedDays,
      );
      
      setState(() {
        _temperatureData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading temperature data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 메모 팝업을 보여주는 메서드
  void _showNotePopup({
    required String note,
    required DateTime time,
    required double temperature,
    required Offset position,
  }) {
    setState(() {
      _selectedNote = note;
      _selectedTime = time;
      _selectedTemp = temperature;
      _popupPosition = position;
      _isNotePopupVisible = true;
    });
    
    _popupAnimationController.forward();
  }
  
  // 메모 팝업을 숨기는 메서드
  void _hideNotePopup() {
    _popupAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isNotePopupVisible = false;
          _selectedNote = null;
          _selectedTime = null;
          _selectedTemp = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.temperatureTrend),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아기 정보 카드
                      _buildBabyInfoCard(theme),
                      
                      const SizedBox(height: 24),
                      
                      // 기간 선택 버튼
                      _buildPeriodSelector(theme),
                      
                      const SizedBox(height: 24),
                      
                      // 체온 그래프
                      _buildTemperatureChart(theme),
                      
                      const SizedBox(height: 24),
                      
                      // 통계 카드들
                      _buildStatsCards(theme),
                      
                      const SizedBox(height: 24),
                      
                      // 추세 분석
                      _buildTrendAnalysis(theme),
                    ],
                  ),
                ),
                
                // 메모 팝업 오버레이
                if (_isNotePopupVisible) _buildNotePopup(theme),
              ],
            ),
    );
  }

  Widget _buildBabyInfoCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red[400]!,
                  Colors.orange[400]!,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.thermostat,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.babyTemperatureRecord(widget.baby.name),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.baby.ageInMonthsAndDays,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.recentDaysTrend(_selectedDays),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final periods = [
      {'days': 3, 'label': l10n.days3},
      {'days': 7, 'label': l10n.days7},
      {'days': 14, 'label': l10n.weeks2},
      {'days': 30, 'label': l10n.month1},
    ];

    return Row(
      children: periods.map((period) {
        final isSelected = _selectedDays == period['days'] as int;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDays = period['days'] as int;
                });
                _loadTemperatureData();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period['label'] as String,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTemperatureChart(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final data = _temperatureData['data'] as List<Map<String, dynamic>>? ?? [];
    
    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat_outlined,
                size: 64,
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noTemperatureRecordsInPeriod,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final temp = entry.value['temperature'] as double;
      return FlSpot(index, temp);
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.temperatureChangeTrend,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
                  LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (spots.length / 4).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= data.length) return const Text('');
                        final date = data[value.toInt()]['time'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}°',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 0.5,
                maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 0.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final temp = spot.y;
                        final dataPoint = data[index];
                        final hasNote = dataPoint['notes'] != null && 
                                       (dataPoint['notes'] as String).isNotEmpty;
                        
                        Color dotColor;
                        if (temp < 36.0) {
                          dotColor = Colors.blue;
                        } else if (temp <= 37.5) {
                          dotColor = Colors.green;
                        } else if (temp <= 38.5) {
                          dotColor = Colors.orange;
                        } else {
                          dotColor = Colors.red;
                        }
                        
                        // 메모가 있는 경우 더 크고 특별한 표시
                        if (hasNote) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: dotColor,
                            strokeWidth: 3,
                            strokeColor: Colors.white,
                          );
                        } else {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: dotColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
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
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
                      final spot = touchResponse!.lineBarSpots!.first;
                      final dataPoint = data[spot.x.toInt()];
                      final note = dataPoint['notes'] as String?;
                      
                      if (note != null && note.isNotEmpty) {
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(event.localPosition);
                        
                        _showNotePopup(
                          note: note,
                          time: dataPoint['time'] as DateTime,
                          temperature: dataPoint['temperature'] as double,
                          position: localPosition,
                        );
                      }
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => theme.colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dataPoint = data[spot.x.toInt()];
                        final temp = dataPoint['temperature'] as double;
                        final time = dataPoint['time'] as DateTime;
                        final note = dataPoint['notes'] as String?;
                        
                        String tooltipText = '${DateFormat('MM/dd HH:mm').format(time)}\n${temp.toStringAsFixed(1)}°C';
                        if (note != null && note.isNotEmpty) {
                          tooltipText += '\n${l10n.noteAvailableTapToView}';
                        }
                        
                        return LineTooltipItem(
                          tooltipText,
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final data = _temperatureData['data'] as List<Map<String, dynamic>>? ?? [];
    final totalRecords = _temperatureData['totalRecords'] as int? ?? 0;
    final avgTemp = _temperatureData['averageTemperature'] as double? ?? 0.0;
    
    double? minTemp, maxTemp;
    if (data.isNotEmpty) {
      final temps = data.map((e) => e['temperature'] as double).toList();
      minTemp = temps.reduce((a, b) => a < b ? a : b);
      maxTemp = temps.reduce((a, b) => a > b ? a : b);
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme: theme,
            title: l10n.averageTemperature,
            value: '${avgTemp.toStringAsFixed(1)}°C',
            icon: Icons.timeline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            title: l10n.highestTemperature,
            value: maxTemp != null ? '${maxTemp.toStringAsFixed(1)}°C' : '-',
            icon: Icons.keyboard_arrow_up,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            title: l10n.lowestTemperature,
            value: minTemp != null ? '${minTemp.toStringAsFixed(1)}°C' : '-',
            icon: Icons.keyboard_arrow_down,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final trend = _temperatureData['trend'] as String? ?? 'stable';
    final data = _temperatureData['data'] as List<Map<String, dynamic>>? ?? [];
    
    String trendText;
    IconData trendIcon;
    Color trendColor;
    
    switch (trend) {
      case 'rising':
        trendText = l10n.temperatureRisingTrend;
        trendIcon = Icons.trending_up;
        trendColor = Colors.red;
        break;
      case 'falling':
        trendText = l10n.temperatureFallingTrend;
        trendIcon = Icons.trending_down;
        trendColor = Colors.blue;
        break;
      default:
        trendText = l10n.temperatureStableTrend;
        trendIcon = Icons.trending_flat;
        trendColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '추세 분석',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trendIcon,
                  color: trendColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trendText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.totalMeasurements(data.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 멋진 애니메이션과 함께 메모 팝업을 그리는 메서드
  Widget _buildNotePopup(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _hideNotePopup,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            Positioned(
              left: _popupPosition.dx.clamp(20.0, MediaQuery.of(context).size.width - 300),
              top: (_popupPosition.dy - 100).clamp(100.0, MediaQuery.of(context).size.height - 200),
              child: AnimatedBuilder(
                animation: _popupAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _popupScaleAnimation.value,
                    child: Opacity(
                      opacity: _popupOpacityAnimation.value,
                      child: Material(
                        elevation: 20,
                        borderRadius: BorderRadius.circular(20),
                        shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surface.withOpacity(0.9),
                              ],
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
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
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.note_alt_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.temperatureRecordMemo,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MM월 dd일 HH:mm').format(_selectedTime!),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _hideNotePopup,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outline.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 체온 정보
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getTemperatureColor(_selectedTemp!).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getTemperatureColor(_selectedTemp!).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thermostat,
                                      color: _getTemperatureColor(_selectedTemp!),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedTemp!.toStringAsFixed(1)}°C',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getTemperatureColor(_selectedTemp!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getTemperatureColor(_selectedTemp!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getTemperatureStatus(_selectedTemp!),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 메모 내용
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _selectedNote!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 체온에 따른 색상 반환
  Color _getTemperatureColor(double temperature) {
    if (temperature < 36.0) {
      return Colors.blue;
    } else if (temperature <= 37.5) {
      return Colors.green;
    } else if (temperature <= 38.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  // 체온 상태 텍스트 반환
  String _getTemperatureStatus(double temperature) {
    final l10n = AppLocalizations.of(context)!;
    if (temperature < 36.0) {
      return l10n.hypothermia;
    } else if (temperature <= 37.5) {
      return l10n.normal;
    } else if (temperature <= 38.5) {
      return l10n.lowFever;
    } else {
      return l10n.fever;
    }
  }
}