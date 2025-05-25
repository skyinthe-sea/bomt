import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SleepSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  
  const SleepSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final count = summary['count'] ?? 0;
    final totalHours = summary['totalHours'] ?? 0;
    final remainingMinutes = summary['remainingMinutes'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bedtime,
                  color: Colors.indigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.sleep,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$count회',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${totalHours}시간 ${remainingMinutes}분',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.totalSleepTime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}