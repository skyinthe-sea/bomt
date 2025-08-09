import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'growth_record_input_dialog.dart';

class GrowthInfoCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final Future<void> Function(dynamic data, String? notes)? onAddRecord;

  const GrowthInfoCard({
    super.key,
    required this.summary,
    this.onAddRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestWeight = summary['latestWeight'];
    final latestHeight = summary['latestHeight'];
    final weightChange = summary['weightChange'] ?? 0.0;
    final heightChange = summary['heightChange'] ?? 0.0;
    final weightTimePeriod = summary['weightTimePeriod'];
    final heightTimePeriod = summary['heightTimePeriod'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGrowthItem(
              context,
              l10n.weight,
              latestWeight ?? 0.0,
              'kg',
              weightChange,
              const Color(0xFFAB47BC), // 라벤더 파스텔
              'weight',
              hasValue: latestWeight != null && latestWeight > 0,
              timePeriod: weightTimePeriod,
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: theme.dividerColor.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildGrowthItem(
              context,
              l10n.height,
              latestHeight ?? 0.0,
              'cm',
              heightChange,
              const Color(0xFF66BB6A), // 민트 파스텔
              'height',
              hasValue: latestHeight != null && latestHeight > 0,
              timePeriod: heightTimePeriod,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(
    BuildContext context,
    String label,
    double value,
    String unit,
    double change,
    Color color,
    String type, {
    bool hasValue = true,
    String? timePeriod,
  }) {
    final theme = Theme.of(context);
    final isPositive = change >= 0;
    
    return InkWell(
      onTap: onAddRecord != null ? () => _showGrowthInputDialog(context, type, hasValue ? value : 0.0) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: !hasValue && onAddRecord != null 
              ? color.withOpacity(0.02) 
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onAddRecord != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    hasValue ? Icons.add_circle_outline : Icons.add,
                    size: hasValue ? 16 : 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (hasValue)
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              )
            else
              Text(
                '-- $unit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            const SizedBox(height: 8),
            if (hasValue && change != 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${isPositive ? '+' : '-'}${change.abs().toStringAsFixed(1)}$unit ${timePeriod ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (hasValue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.noChange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.firstRecord,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showGrowthInputDialog(BuildContext context, String type, double currentValue) {
    final latestWeight = summary['latestWeight'];
    final latestHeight = summary['latestHeight'];
    
    showDialog(
      context: context,
      builder: (context) => GrowthRecordInputDialog(
        initialType: type,
        initialValue: currentValue,
        initialWeightValue: (latestWeight != null && latestWeight > 0) ? latestWeight.toDouble() : null,
        initialHeightValue: (latestHeight != null && latestHeight > 0) ? latestHeight.toDouble() : null,
        onSave: (data, notes) async {
          if (onAddRecord != null) {
            await onAddRecord!(data, notes);
          }
        },
      ),
    );
  }

}