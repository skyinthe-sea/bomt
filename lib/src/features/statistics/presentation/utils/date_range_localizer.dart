import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/statistics.dart';

/// Helper class for localizing statistics date range labels
class DateRangeLocalizer {
  /// Generate a localized label for a statistics date range
  static String getLocalizedLabel(
    AppLocalizations l10n,
    StatisticsDateRange dateRange,
    String locale,
  ) {
    switch (dateRange.type) {
      case StatisticsDateRangeType.weekly:
        return _getWeeklyLabel(l10n, dateRange, locale);
      case StatisticsDateRangeType.monthly:
        return _getMonthlyLabel(l10n, dateRange, locale);
      case StatisticsDateRangeType.custom:
        return _getCustomLabel(l10n, dateRange, locale);
    }
  }

  static String _getWeeklyLabel(
    AppLocalizations l10n,
    StatisticsDateRange dateRange,
    String locale,
  ) {
    final start = dateRange.startDate;
    final end = dateRange.endDate;
    
    // Check if it's current week
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
    
    final isCurrentWeek = 
        start.day == currentWeekStart.day && 
        start.month == currentWeekStart.month &&
        start.year == currentWeekStart.year;
    
    if (isCurrentWeek) {
      return '${l10n.thisWeek} (${start.month}/${start.day} - ${end.month}/${end.day})';
    } else {
      // Format according to locale
      switch (locale) {
        case 'ko':
          return '${start.month}/${start.day} - ${end.month}/${end.day} 주';
        case 'ja':
          return '${start.month}/${start.day} - ${end.month}/${end.day} 週';
        case 'hi':
          return '${start.month}/${start.day} - ${end.month}/${end.day} सप्ताह';
        default:
          return '${start.month}/${start.day} - ${end.month}/${end.day} Week';
      }
    }
  }

  static String _getMonthlyLabel(
    AppLocalizations l10n,
    StatisticsDateRange dateRange,
    String locale,
  ) {
    final date = dateRange.startDate;
    final now = DateTime.now();
    
    // Check if it's current month
    final isCurrentMonth = 
        date.month == now.month && date.year == now.year;
    
    if (isCurrentMonth) {
      switch (locale) {
        case 'ko':
          return '${l10n.thisMonth} (${date.year}년 ${date.month}월)';
        case 'ja':
          return '${l10n.thisMonth} (${date.year}年${date.month}月)';
        case 'hi':
          return '${l10n.thisMonth} (${date.year} ${_getHindiMonth(date.month)})';
        default:
          return '${l10n.thisMonth} (${DateFormat.yMMMM('en').format(date)})';
      }
    } else {
      // Format according to locale
      switch (locale) {
        case 'ko':
          return '${date.year}년 ${date.month}월';
        case 'ja':
          return '${date.year}年${date.month}月';
        case 'hi':
          return '${date.year} ${_getHindiMonth(date.month)}';
        default:
          return DateFormat.yMMMM('en').format(date);
      }
    }
  }

  static String _getCustomLabel(
    AppLocalizations l10n,
    StatisticsDateRange dateRange,
    String locale,
  ) {
    final start = dateRange.startDate;
    final end = dateRange.endDate;
    
    // For custom ranges, just show the date range
    switch (locale) {
      case 'ko':
        return '${start.month}/${start.day} - ${end.month}/${end.day}';
      case 'ja':
        return '${start.month}/${start.day} - ${end.month}/${end.day}';
      case 'hi':
        return '${start.month}/${start.day} - ${end.month}/${end.day}';
      default:
        return '${start.month}/${start.day} - ${end.month}/${end.day}';
    }
  }

  static String _getHindiMonth(int month) {
    const hindiMonths = [
      'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
      'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
    ];
    return hindiMonths[month - 1];
  }
}