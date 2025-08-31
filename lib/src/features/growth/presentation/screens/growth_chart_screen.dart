import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/growth_record.dart';
import '../../../../domain/models/baby.dart';
import '../../../../services/growth/growth_service.dart';
import '../widgets/growth_chart_widget.dart';

class GrowthChartScreen extends StatefulWidget {
  final Baby baby;
  
  const GrowthChartScreen({
    super.key,
    required this.baby,
  });

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  List<GrowthRecord> _growthRecords = [];
  bool _isLoading = true;
  bool _showWeight = true; // true: 체중, false: 키
  
  // 월별 필터링을 위한 상태
  DateTime? _selectedMonth; // null이면 전체 보기
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadGrowthData();
  }

  Future<void> _loadGrowthData() async {
    try {
      final records = await GrowthService.instance
          .getAllGrowthRecords(widget.baby.id);
      
      if (mounted) {
        setState(() {
          _growthRecords = records;
          _availableMonths = _calculateAvailableMonths(records);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// 사용 가능한 월 목록 계산 (데이터가 10개 이상일 때만 월별 필터 활성화)
  List<DateTime> _calculateAvailableMonths(List<GrowthRecord> records) {
    if (records.length < 10) return []; // 데이터가 적으면 월별 필터 비활성화
    
    final monthSet = <String>{};
    
    for (final record in records) {
      final monthKey = '${record.recordedAt.year}-${record.recordedAt.month}';
      monthSet.add(monthKey);
    }
    
    final months = monthSet.map((monthKey) {
      final parts = monthKey.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }).toList();
    
    // 최신 월부터 정렬
    months.sort((a, b) => b.compareTo(a));
    return months;
  }
  
  /// 선택된 월의 데이터만 필터링
  List<GrowthRecord> get _filteredRecords {
    if (_selectedMonth == null) return _growthRecords;
    
    return _growthRecords.where((record) {
      return record.recordedAt.year == _selectedMonth!.year && 
             record.recordedAt.month == _selectedMonth!.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baby = widget.baby;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.babyGrowthChart(baby?.name ?? '아기'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _growthRecords.isEmpty
              ? _buildEmptyState()
              : _buildChartContent(),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noGrowthRecords,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.enterWeightAndHeightFromHome,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // 차트 타입 선택
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  l10n.weight,
                  Icons.monitor_weight_outlined,
                  _showWeight,
                  () => setState(() => _showWeight = true),
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  l10n.height,
                  Icons.height,
                  !_showWeight,
                  () => setState(() => _showWeight = false),
                  colorScheme.secondary.withOpacity(0.1),
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        
        // 월별 필터 (데이터가 충분할 때만 표시)
        if (_availableMonths.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.periodSelection,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 전체 보기 버튼
                        _buildMonthFilter(
                          l10n.all,
                          _selectedMonth == null,
                          () => setState(() => _selectedMonth = null),
                        ),
                        const SizedBox(width: 8),
                        // 월별 버튼들
                        ..._availableMonths.map((month) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildMonthFilter(
                            '${month.year}.${month.month.toString().padLeft(2, '0')}',
                            _selectedMonth != null && 
                            _selectedMonth!.year == month.year && 
                            _selectedMonth!.month == month.month,
                            () => setState(() => _selectedMonth = month),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // 스크롤 가능한 차트 + 추가 정보 영역
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 차트
                Container(
                  height: 320, // 스크롤 영역 내에서 적절한 크기로 조정
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GrowthChartWidget(
                      records: _filteredRecords,
                      showWeight: _showWeight,
                    ),
                  ),
                ),
                
                // 추가 정보 영역
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildAdditionalInfo(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color backgroundColor,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? iconColor : colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? iconColor : colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 추가 정보 영역 구성
  Widget _buildAdditionalInfo() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final records = _filteredRecords;
    
    if (records.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // 성장 인사이트 헤더
          Row(
            children: [
              Icon(
                Icons.insights,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '성장 인사이트',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 성장 속도 및 예측
          Row(
            children: [
              Expanded(child: _buildGrowthRateCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildPredictionCard()),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 기록 빈도 및 다음 권장 기록일
          Row(
            children: [
              Expanded(child: _buildRecordFrequencyCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildNextRecordCard()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 성장 마일스톤
          _buildMilestoneCard(),
        ],
      );
  }
  
  /// 성장 속도 카드
  Widget _buildGrowthRateCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final records = _filteredRecords;
    
    if (records.length < 2) {
      return _buildInfoCard(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.growthRate,
        value: AppLocalizations.of(context)!.dataInsufficient,
        subtitle: AppLocalizations.of(context)!.twoOrMoreRequired,
        color: colorScheme.outline,
      );
    }
    
    // 최근 30일 또는 전체 기간 중 짧은 기간의 평균 성장률 계산
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final recentRecords = sortedRecords.where((record) {
      final daysDiff = DateTime.now().difference(record.recordedAt).inDays;
      return daysDiff <= 30;
    }).toList();
    
    final targetRecords = recentRecords.length >= 2 ? recentRecords : sortedRecords;
    
    if (targetRecords.length < 2) {
      return _buildInfoCard(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.growthRate,
        value: AppLocalizations.of(context)!.dataInsufficient,
        subtitle: AppLocalizations.of(context)!.twoOrMoreRequired,
        color: colorScheme.outline,
      );
    }
    
    final firstRecord = targetRecords.first;
    final lastRecord = targetRecords.last;
    final daysDiff = lastRecord.recordedAt.difference(firstRecord.recordedAt).inDays;
    
    if (daysDiff <= 0) {
      return _buildInfoCard(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.growthRate,
        value: AppLocalizations.of(context)!.calculationNotPossible,
        subtitle: AppLocalizations.of(context)!.periodInsufficient,
        color: colorScheme.outline,
      );
    }
    
    final firstValue = _showWeight ? firstRecord.weightKg : firstRecord.heightCm;
    final lastValue = _showWeight ? lastRecord.weightKg : lastRecord.heightCm;
    
    if (firstValue == null || lastValue == null) {
      return _buildInfoCard(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.growthRate,
        value: AppLocalizations.of(context)!.noDataAvailable,
        subtitle: _showWeight ? AppLocalizations.of(context)!.weightRecordRequired : AppLocalizations.of(context)!.heightRecordRequired,
        color: colorScheme.outline,
      );
    }
    
    final totalChange = lastValue - firstValue;
    final dailyRate = totalChange / daysDiff;
    final monthlyRate = dailyRate * 30;
    final unit = _showWeight ? 'kg' : 'cm';
    
    final isPositive = monthlyRate >= 0;
    final rateColor = isPositive ? Colors.green[600] : Colors.red[600];
    
    return _buildInfoCard(
      icon: isPositive ? Icons.trending_up : Icons.trending_down,
      title: l10n.monthlyAverageGrowth,
      value: '${monthlyRate >= 0 ? '+' : ''}${monthlyRate.toStringAsFixed(2)}$unit',
      subtitle: recentRecords.length >= 2 ? l10n.recentDaysBasis(30) : l10n.entireBasis,
      color: rateColor ?? colorScheme.primary,
    );
  }
  
  /// 성장 예측 카드
  Widget _buildPredictionCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final records = _filteredRecords;
    
    if (records.length < 2) {
      return _buildInfoCard(
        icon: Icons.auto_graph,
        title: l10n.oneMonthPrediction,
        value: l10n.predictionNotPossible,
        subtitle: l10n.dataInsufficient,
        color: colorScheme.outline,
      );
    }
    
    // 최근 기록 기준으로 예측
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    final latestRecord = sortedRecords.first;
    final latestValue = _showWeight ? latestRecord.weightKg : latestRecord.heightCm;
    
    if (latestValue == null) {
      return _buildInfoCard(
        icon: Icons.auto_graph,
        title: l10n.oneMonthPrediction,
        value: l10n.predictionNotPossible,
        subtitle: l10n.currentRecordMissing,
        color: colorScheme.outline,
      );
    }
    
    // 간단한 선형 예측 (최근 2개 기록 기준)
    if (sortedRecords.length >= 2) {
      final previousRecord = sortedRecords[1];
      final previousValue = _showWeight ? previousRecord.weightKg : previousRecord.heightCm;
      
      if (previousValue != null) {
        final daysDiff = latestRecord.recordedAt.difference(previousRecord.recordedAt).inDays;
        
        if (daysDiff > 0) {
          final dailyRate = (latestValue - previousValue) / daysDiff;
          final predicted = latestValue + (dailyRate * 30);
          final unit = _showWeight ? 'kg' : 'cm';
          
          return _buildInfoCard(
            icon: Icons.auto_graph,
            title: l10n.oneMonthPrediction,
            value: '${predicted.toStringAsFixed(1)}$unit',
            subtitle: l10n.currentTrendBasis,
            color: colorScheme.secondary,
          );
        }
      }
    }
    
    return _buildInfoCard(
      icon: Icons.auto_graph,
      title: l10n.oneMonthPrediction,
      value: l10n.predictionNotPossible,
      subtitle: l10n.trendInsufficient,
      color: colorScheme.outline,
    );
  }
  
  /// 기록 빈도 카드
  Widget _buildRecordFrequencyCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final records = _filteredRecords;
    
    if (records.isEmpty) {
      return _buildInfoCard(
        icon: Icons.calendar_month,
        title: l10n.recordFrequency,
        value: l10n.noRecord,
        subtitle: l10n.firstRecordStart,
        color: colorScheme.outline,
      );
    }
    
    if (records.length == 1) {
      return _buildInfoCard(
        icon: Icons.calendar_month,
        title: l10n.recordFrequency,
        value: l10n.oneRecord,
        subtitle: l10n.moreRecordsNeeded,
        color: colorScheme.outline,
      );
    }
    
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final totalDays = sortedRecords.last.recordedAt
        .difference(sortedRecords.first.recordedAt).inDays;
    
    if (totalDays <= 0) {
      return _buildInfoCard(
        icon: Icons.calendar_month,
        title: l10n.recordFrequency,
        value: l10n.sameDayRecord,
        subtitle: l10n.recordedTimes(records.length),
        color: colorScheme.primary,
      );
    }
    
    final avgDays = totalDays / (records.length - 1);
    String frequency;
    Color frequencyColor;
    
    if (avgDays <= 3) {
      frequency = l10n.veryConsistent;
      frequencyColor = Colors.green[600]!;
    } else if (avgDays <= 7) {
      frequency = l10n.consistent;
      frequencyColor = Colors.blue[600]!;
    } else if (avgDays <= 14) {
      frequency = l10n.average;
      frequencyColor = Colors.orange[600]!;
    } else {
      frequency = l10n.irregular;
      frequencyColor = Colors.red[600]!;
    }
    
    return _buildInfoCard(
      icon: Icons.calendar_month,
      title: l10n.recordFrequency,
      value: frequency,
      subtitle: l10n.averageDaysInterval(avgDays.toStringAsFixed(1)),
      color: frequencyColor,
    );
  }
  
  /// 다음 권장 기록일 카드
  Widget _buildNextRecordCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final records = _filteredRecords;
    
    if (records.isEmpty) {
      return _buildInfoCard(
        icon: Icons.notification_important,
        title: l10n.nextRecord,
        value: l10n.now,
        subtitle: l10n.firstRecordStart,
        color: colorScheme.primary,
      );
    }
    
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    final latestRecord = sortedRecords.first;
    final daysSinceLastRecord = DateTime.now().difference(latestRecord.recordedAt).inDays;
    
    if (daysSinceLastRecord >= 7) {
      return _buildInfoCard(
        icon: Icons.notification_important,
        title: l10n.nextRecord,
        value: l10n.now,
        subtitle: l10n.daysAgoRecorded(daysSinceLastRecord),
        color: Colors.red[600]!,
      );
    } else if (daysSinceLastRecord >= 3) {
      return _buildInfoCard(
        icon: Icons.schedule,
        title: l10n.nextRecord,
        value: l10n.soon,
        subtitle: l10n.daysAgoRecorded(daysSinceLastRecord),
        color: Colors.orange[600]!,
      );
    } else {
      final recommendedDays = 7 - daysSinceLastRecord;
      return _buildInfoCard(
        icon: Icons.schedule,
        title: l10n.nextRecord,
        value: l10n.daysLater(recommendedDays),
        subtitle: l10n.weeklyRecordRecommended,
        color: Colors.green[600]!,
      );
    }
  }
  
  /// 성장 마일스톤 카드
  Widget _buildMilestoneCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final records = _filteredRecords;
    
    if (records.isEmpty) {
      return const SizedBox();
    }
    
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    final latestRecord = sortedRecords.first;
    final currentValue = _showWeight ? latestRecord.weightKg : latestRecord.heightCm;
    
    if (currentValue == null) {
      return const SizedBox();
    }
    
    // 다음 마일스톤 계산
    double nextMilestone;
    if (_showWeight) {
      // 체중: 0.5kg 단위로 다음 마일스톤
      nextMilestone = ((currentValue / 0.5).floor() + 1) * 0.5;
    } else {
      // 키: 1cm 단위로 다음 마일스톤
      nextMilestone = ((currentValue / 1).floor() + 1) * 1;
    }
    
    final remaining = nextMilestone - currentValue;
    final unit = _showWeight ? 'kg' : 'cm';
    final progress = currentValue / nextMilestone;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.nextMilestone,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                l10n.targetValue(nextMilestone.toStringAsFixed(1), unit),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 진행률 바
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            l10n.remainingProgress(
              remaining.toStringAsFixed(2),
              unit,
              (progress * 100).toStringAsFixed(1),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 정보 카드 위젯
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  /// 월별 필터 버튼 위젯
  Widget _buildMonthFilter(String text, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary.withOpacity(0.1)
              : colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected 
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}