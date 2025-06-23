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
          
          // 시작일 선택
          _buildDatePickerTile(
            context: context,
            theme: theme,
            title: l10n.startDate,
            date: _startDate,
            onTap: () => _selectStartDate(context),
          ),
          
          const SizedBox(height: 12),
          
          // 종료일 선택
          _buildDatePickerTile(
            context: context,
            theme: theme,
            title: l10n.endDate,
            date: _endDate,
            onTap: () => _selectEndDate(context),
          ),
          
          const SizedBox(height: 24),
          
          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canApply() ? _applyDateRange : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.apply),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
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
    return _startDate != null && _endDate != null && _startDate!.isBefore(_endDate!);
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