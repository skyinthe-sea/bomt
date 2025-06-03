import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CleanTimelineHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onDatePicker;
  final bool isFuture;

  const CleanTimelineHeader({
    Key? key,
    required this.selectedDate,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onDatePicker,
    required this.isFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 날짜 버튼
          _buildNavigationButton(
            context: context,
            icon: Icons.chevron_left_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onPreviousDay();
            },
          ),
          
          // 날짜 섹션
          Expanded(
            child: _buildDateSection(context),
          ),
          
          // 다음 날짜 버튼
          _buildNavigationButton(
            context: context,
            icon: Icons.chevron_right_rounded,
            onTap: isFuture ? null : () {
              HapticFeedback.lightImpact();
              onNextDay();
            },
            isDisabled: isFuture,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDisabled 
              ? theme.colorScheme.onSurface.withOpacity(0.05)
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDisabled 
              ? theme.colorScheme.onSurface.withOpacity(0.3)
              : theme.colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('M월 d일', 'ko_KR');
    final dayFormat = DateFormat('EEEE', 'ko_KR');
    final formattedDate = dateFormat.format(selectedDate);
    final formattedDay = dayFormat.format(selectedDate);
    
    final isToday = DateTime.now().day == selectedDate.day &&
                   DateTime.now().month == selectedDate.month &&
                   DateTime.now().year == selectedDate.year;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onDatePicker();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF), // 홈스크린 스타일 연한 배경
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '오늘',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDay,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}