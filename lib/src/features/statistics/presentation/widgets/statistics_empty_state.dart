import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/statistics_provider.dart';
import '../../../../presentation/providers/tab_controller_provider.dart';

class StatisticsEmptyState extends StatelessWidget {
  const StatisticsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 일러스트레이션
          _buildIllustration(theme),
          
          const SizedBox(height: 24),
          
          // 제목
          Text(
            '통계 데이터가 없습니다',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // 설명
          Consumer<StatisticsProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.dateRange.label} 기간 동안 기록된 활동이 없습니다.\n아기의 활동을 기록해보세요!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // 액션 버튼들
          _buildActionButtons(context, theme),
          
          const SizedBox(height: 24),
          
          // 도움말 카드
          _buildHelpCard(context, theme),
        ],
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원들
                ...List.generate(3, (index) {
                  return Container(
                    width: 120 - (index * 20),
                    height: 120 - (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  );
                }),
                // 중앙 아이콘
                Icon(
                  Icons.bar_chart_rounded,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // 기록하기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToRecord(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('활동 기록하기'),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 날짜 변경 버튼
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _changeDateRange(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('다른 기간 보기'),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _refreshData(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('새로고침'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '통계를 보려면?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...['수유, 수면, 기저귀 등의 활동을 기록하세요', '최소 하루 이상의 데이터가 있어야 통계가 표시됩니다', '홈 화면에서 간편하게 기록할 수 있습니다']
              .map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  void _navigateToRecord(BuildContext context) {
    // 홈 탭으로 이동하여 기록하기
    final tabController = Provider.of<TabControllerProvider>(context, listen: false);
    tabController.navigateToHome();
  }

  void _changeDateRange(BuildContext context) {
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DateRangeBottomSheet(provider: provider),
    );
  }

  void _refreshData(BuildContext context) {
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    provider.refreshStatistics();
  }
}

class _DateRangeBottomSheet extends StatelessWidget {
  final StatisticsProvider provider;

  const _DateRangeBottomSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 제목
          Text(
            '다른 기간 보기',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 날짜 범위 옵션들
          ...[
            {'label': '지난 주', 'onTap': () => _selectLastWeek(context)},
            {'label': '지난 달', 'onTap': () => _selectLastMonth(context)},
            {'label': '지난 3개월', 'onTap': () => _selectLast3Months(context)},
            {'label': '전체 기간', 'onTap': () => _selectAllTime(context)},
          ].map((option) => 
            ListTile(
              leading: Icon(
                Icons.calendar_today_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(option['label']! as String),
              onTap: option['onTap']! as VoidCallback,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _selectLastWeek(BuildContext context) {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    provider.setWeeklyRange(date: lastWeek);
    Navigator.of(context).pop();
  }

  void _selectLastMonth(BuildContext context) {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    provider.setMonthlyRange(date: lastMonth);
    Navigator.of(context).pop();
  }

  void _selectLast3Months(BuildContext context) {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
    provider.setCustomRange(startDate: startDate, endDate: endDate);
    Navigator.of(context).pop();
  }

  void _selectAllTime(BuildContext context) {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    provider.setCustomRange(startDate: startDate, endDate: endDate);
    Navigator.of(context).pop();
  }
}