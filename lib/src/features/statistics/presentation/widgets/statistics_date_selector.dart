import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/providers/statistics_provider.dart';
import '../../../../domain/models/statistics.dart';
import '../utils/date_range_localizer.dart';

class StatisticsDateSelector extends StatelessWidget {
  const StatisticsDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 날짜 범위 타입 선택 (주간/월간/커스텀)
          _buildDateRangeTypeSelector(context, theme),
          
          const SizedBox(height: 16),
          
          // 날짜 네비게이션
          _buildDateNavigation(context, theme),
        ],
      ),
    );
  }

  Widget _buildDateRangeTypeSelector(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildDateTypeButton(
                context: context,
                theme: theme,
                label: l10n.weekly,
                isSelected: provider.dateRange.type == StatisticsDateRangeType.weekly,
                onTap: () => provider.setWeeklyRange(),
              ),
              _buildDateTypeButton(
                context: context,
                theme: theme,
                label: l10n.monthly,
                isSelected: provider.dateRange.type == StatisticsDateRangeType.monthly,
                onTap: () => provider.setMonthlyRange(),
              ),
              _buildDateTypeButton(
                context: context,
                theme: theme,
                label: l10n.custom,
                isSelected: provider.dateRange.type == StatisticsDateRangeType.custom,
                onTap: () => _showCustomDatePicker(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTypeButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              // 이전 버튼
              _buildNavButton(
                context: context,
                theme: theme,
                icon: Icons.chevron_left_rounded,
                onPressed: provider.dateRange.type != StatisticsDateRangeType.custom
                    ? () => provider.moveDateRange(false)
                    : null,
              ),
              
              // 현재 날짜 범위 표시
              Expanded(
                child: GestureDetector(
                  onTap: provider.dateRange.type != StatisticsDateRangeType.custom
                      ? () => _showDatePickerDialog(context, provider)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          DateRangeLocalizer.getLocalizedLabel(
                            l10n,
                            provider.dateRange,
                            Localizations.localeOf(context).toString(),
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.daysCount(provider.dateRange.totalDays),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 다음 버튼
              _buildNavButton(
                context: context,
                theme: theme,
                icon: Icons.chevron_right_rounded,
                onPressed: provider.dateRange.type != StatisticsDateRangeType.custom
                    ? () => provider.moveDateRange(true)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onPressed != null
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context, StatisticsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CustomDatePickerSheet(provider: provider),
    );
  }

  void _showDatePickerDialog(BuildContext context, StatisticsProvider provider) {
    if (provider.dateRange.type == StatisticsDateRangeType.weekly) {
      showDatePicker(
        context: context,
        initialDate: provider.dateRange.startDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
      ).then((selectedDate) {
        if (selectedDate != null) {
          provider.setWeeklyRange(date: selectedDate);
        }
      });
    } else if (provider.dateRange.type == StatisticsDateRangeType.monthly) {
      showDatePicker(
        context: context,
        initialDate: provider.dateRange.startDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
      ).then((selectedDate) {
        if (selectedDate != null) {
          provider.setMonthlyRange(date: selectedDate);
        }
      });
    }
  }
}

class _CustomDatePickerSheet extends StatefulWidget {
  final StatisticsProvider provider;

  const _CustomDatePickerSheet({required this.provider});

  @override
  State<_CustomDatePickerSheet> createState() => _CustomDatePickerSheetState();
}

class _CustomDatePickerSheetState extends State<_CustomDatePickerSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.provider.dateRange.type == StatisticsDateRangeType.custom) {
      _startDate = widget.provider.dateRange.startDate;
      _endDate = widget.provider.dateRange.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            l10n.periodSelection,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 빠른 선택 프리셋
          _buildQuickPresets(context, theme),
          
          const SizedBox(height: 24),
          
          // 커스텀 날짜 범위 선택
          _buildCustomDateRangeSection(context, theme),
          
          const SizedBox(height: 24),
          
          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canApply() ? _applyDateRange : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canApply() 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                foregroundColor: _canApply() 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _canApply() ? 3 : 0,
                shadowColor: _canApply() ? theme.colorScheme.primary.withOpacity(0.3) : null,
              ),
              child: Text(
                l10n.apply,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _canApply() 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 빠른 선택 프리셋 버튼들
  Widget _buildQuickPresets(BuildContext context, ThemeData theme) {
    final presets = _getDatePresets();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 선택',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) => _buildPresetChip(context, theme, preset)).toList(),
        ),
      ],
    );
  }

  /// 프리셋 칩 위젯
  Widget _buildPresetChip(BuildContext context, ThemeData theme, Map<String, dynamic> preset) {
    final isSelected = _isPresetSelected(preset);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectPreset(preset),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            preset['label'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 커스텀 날짜 범위 선택 섹션
  Widget _buildCustomDateRangeSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용자 정의',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        // 날짜 범위 선택 버튼
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDateRangePicker(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '날짜 범위 선택',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSelectedRangeText(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: (_startDate != null && _endDate != null)
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null 
                          ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date)
                          : l10n.pleaseSelectDate,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: date != null 
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: _endDate ?? DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _startDate = selectedDate;
        });
      }
    });
  }

  void _selectEndDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _endDate = selectedDate;
        });
      }
    });
  }

  bool _canApply() {
    return _startDate != null && _endDate != null && !_startDate!.isAfter(_endDate!);
  }

  /// 날짜 프리셋 정의
  List<Map<String, dynamic>> _getDatePresets() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      {
        'label': '최근 7일',
        'startDate': today.subtract(const Duration(days: 6)),
        'endDate': today,
      },
      {
        'label': '최근 14일',
        'startDate': today.subtract(const Duration(days: 13)),
        'endDate': today,
      },
      {
        'label': '최근 30일',
        'startDate': today.subtract(const Duration(days: 29)),
        'endDate': today,
      },
      {
        'label': '지난 주',
        'startDate': today.subtract(Duration(days: today.weekday + 6)),
        'endDate': today.subtract(Duration(days: today.weekday)),
      },
      {
        'label': '지난 달',
        'startDate': DateTime(now.year, now.month - 1, 1),
        'endDate': DateTime(now.year, now.month, 0),
      },
      {
        'label': '이번 달',
        'startDate': DateTime(now.year, now.month, 1),
        'endDate': today,
      },
    ];
  }

  /// 현재 선택된 프리셋인지 확인
  bool _isPresetSelected(Map<String, dynamic> preset) {
    if (_startDate == null || _endDate == null) return false;
    
    final presetStart = preset['startDate'] as DateTime;
    final presetEnd = preset['endDate'] as DateTime;
    
    return _startDate!.isAtSameMomentAs(presetStart) && 
           _endDate!.isAtSameMomentAs(presetEnd);
  }

  /// 프리셋 선택
  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _startDate = preset['startDate'] as DateTime;
      _endDate = preset['endDate'] as DateTime;
    });
  }

  /// 날짜 범위 선택 다이얼로그 표시
  void _showDateRangePicker(BuildContext context) async {
    await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _CustomDateRangeDialog(
          initialStartDate: _startDate,
          initialEndDate: _endDate,
          onDateRangeSelected: (startDate, endDate) {
            setState(() {
              _startDate = startDate;
              _endDate = endDate;
            });
          },
        );
      },
    );
  }

  /// 선택된 범위 텍스트 생성
  String _getSelectedRangeText() {
    if (_startDate == null || _endDate == null) {
      return '날짜를 선택하세요';
    }
    
    final formatter = DateFormat('M/d', Localizations.localeOf(context).toString());
    final startText = formatter.format(_startDate!);
    final endText = formatter.format(_endDate!);
    
    if (_startDate!.year == _endDate!.year && 
        _startDate!.month == _endDate!.month && 
        _startDate!.day == _endDate!.day) {
      return startText; // 같은 날인 경우
    }
    
    return '$startText - $endText';
  }

  void _applyDateRange() {
    if (_canApply()) {
      widget.provider.setCustomRange(
        startDate: _startDate!,
        endDate: _endDate!,
      );
      Navigator.of(context).pop();
    }
  }
}

/// 커스텀 날짜 범위 선택 다이얼로그
class _CustomDateRangeDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  const _CustomDateRangeDialog({
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  });

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog>
    with TickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();
  bool _isSelectingEndDate = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(theme),
                    _buildDateRangeInfo(theme),
                    _buildCalendar(theme),
                    _buildActions(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.date_range_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기간 선택',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '분석할 기간을 선택해주세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildDateInfoCard(
              theme: theme,
              title: '시작일',
              date: _startDate,
              isSelected: !_isSelectingEndDate,
              onTap: () => setState(() => _isSelectingEndDate = false),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          Expanded(
            child: _buildDateInfoCard(
              theme: theme,
              title: '종료일',
              date: _endDate,
              isSelected: _isSelectingEndDate,
              onTap: () => setState(() => _isSelectingEndDate = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoCard({
    required ThemeData theme,
    required String title,
    required DateTime? date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date != null 
                    ? DateFormat('M월 d일', 'ko').format(date)
                    : '날짜 선택',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: date != null 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SimpleCalendar(
        focusedDay: _focusedDay,
        startDate: _startDate,
        endDate: _endDate,
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    final canApply = _startDate != null && _endDate != null && !_startDate!.isAfter(_endDate!);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Text(
                '취소',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canApply ? _applySelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canApply 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                foregroundColor: canApply 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canApply ? 3 : 0,
                shadowColor: canApply ? theme.colorScheme.primary.withOpacity(0.3) : null,
              ),
              child: Text(
                '적용',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: canApply 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      if (!_isSelectingEndDate) {
        // 시작일 선택
        _startDate = selectedDay;
        if (_endDate != null && selectedDay.isAfter(_endDate!)) {
          _endDate = null;
        }
        _isSelectingEndDate = true;
      } else {
        // 종료일 선택
        if (_startDate != null && selectedDay.isBefore(_startDate!)) {
          _startDate = selectedDay;
        } else {
          _endDate = selectedDay;
        }
      }
    });
  }

  void _applySelection() {
    if (_startDate != null && _endDate != null && !_startDate!.isAfter(_endDate!)) {
      widget.onDateRangeSelected(_startDate!, _endDate!);
      Navigator.of(context).pop();
    }
  }
}

/// 간단한 커스텀 캘린더 위젯
class _SimpleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const _SimpleCalendar({
    required this.focusedDay,
    this.startDate,
    this.endDate,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildHeader(theme),
        const SizedBox(height: 16),
        _buildWeekdays(theme),
        const SizedBox(height: 8),
        _buildCalendarGrid(theme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final newMonth = DateTime(focusedDay.year, focusedDay.month - 1);
            onPageChanged(newMonth);
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          DateFormat('yyyy년 M월', 'ko').format(focusedDay),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            final newMonth = DateTime(focusedDay.year, focusedDay.month + 1);
            onPageChanged(newMonth);
          },
          icon: Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdays(ThemeData theme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    
    return Row(
      children: weekdays.map((weekday) => Expanded(
        child: Center(
          child: Text(
            weekday,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    final weeks = <Widget>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(lastDayOfMonth) || weeks.length < 6) {
      final week = <Widget>[];
      
      for (int i = 0; i < 7; i++) {
        week.add(_buildDayCell(theme, currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add(Row(children: week.map((day) => Expanded(child: day)).toList()));
      
      if (currentDate.month != focusedDay.month && weeks.length >= 4) break;
    }
    
    return Column(children: weeks);
  }

  Widget _buildDayCell(ThemeData theme, DateTime day) {
    final isCurrentMonth = day.month == focusedDay.month;
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSelectedDay(day);
    final isInRange = _isInRange(day);
    final isPastDate = day.isAfter(DateTime.now());
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrentMonth && !isPastDate ? () => onDaySelected(day) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: _getDayBackgroundColor(theme, isSelected, isInRange, isToday),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getDayTextColor(theme, isCurrentMonth, isSelected, isToday, isPastDate),
                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSelectedDay(DateTime day) {
    return (startDate != null && _isSameDay(day, startDate!)) ||
           (endDate != null && _isSameDay(day, endDate!));
  }

  bool _isInRange(DateTime day) {
    if (startDate == null || endDate == null) return false;
    return day.isAfter(startDate!) && day.isBefore(endDate!);
  }

  Color? _getDayBackgroundColor(ThemeData theme, bool isSelected, bool isInRange, bool isToday) {
    if (isSelected) {
      return theme.colorScheme.primary;
    } else if (isInRange) {
      return theme.colorScheme.primary.withOpacity(0.1);
    } else if (isToday) {
      return theme.colorScheme.primaryContainer.withOpacity(0.3);
    }
    return null;
  }

  Color _getDayTextColor(ThemeData theme, bool isCurrentMonth, bool isSelected, bool isToday, bool isPastDate) {
    if (isPastDate) {
      return theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      return theme.colorScheme.onPrimary;
    } else if (isToday) {
      return theme.colorScheme.primary;
    } else if (!isCurrentMonth) {
      return theme.colorScheme.onSurface.withOpacity(0.3);
    }
    return theme.colorScheme.onSurface;
  }
}