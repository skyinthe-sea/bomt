import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../presentation/providers/diaper_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/diaper/diaper_service.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import 'diaper_settings_dialog.dart';
import 'record_detail_overlay.dart';

class DiaperSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final DiaperProvider? diaperProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DiaperSummaryCard({
    super.key,
    required this.summary,
    this.diaperProvider,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<DiaperSummaryCard> createState() => _DiaperSummaryCardState();
}

class _DiaperSummaryCardState extends State<DiaperSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.diaperProvider != null) {
      _handleQuickDiaper();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else if (widget.diaperProvider != null) {
      _showDiaperRecords();
    }
  }

  Future<void> _showDiaperRecords() async {
    if (widget.diaperProvider == null) return;

    final babyId = widget.diaperProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      final diapers = await DiaperService.instance.getTodayDiapers(babyId);
      final diaperData = diapers.map((diaper) => diaper.toJson()).toList();

      if (mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.diaper,
            summary: widget.summary,
            records: diaperData,
            primaryColor: Colors.amber,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              widget.diaperProvider?.refreshData();
            },
            onRecordUpdated: () {
              widget.diaperProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching diaper records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordsLoadFailed),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleQuickDiaper() async {
    if (widget.diaperProvider == null) return;

    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: AppLocalizations.of(context)!.diaperChanged,
        onProceed: () => _addQuickDiaper(),
      );
      
      if (!shouldProceed) return;
    } else {
      await _addQuickDiaper();
    }
  }

  Future<void> _addQuickDiaper() async {
    final success = await widget.diaperProvider!.addQuickDiaper();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordAdded),
              ],
            ),
            backgroundColor: Colors.amber[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordAddFailed),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final wetCount = widget.summary['wetCount'] ?? 0;
    final dirtyCount = widget.summary['dirtyCount'] ?? 0;
    final bothCount = widget.summary['bothCount'] ?? 0;
    final totalCount = widget.summary['totalCount'] ?? (wetCount + dirtyCount + bothCount);
    final lastChangedMinutesAgo = widget.summary['lastChangedMinutesAgo'];
    final isUpdating = widget.diaperProvider?.isUpdating ?? false;
    final hasRecentRecord = widget.diaperProvider?.hasRecentRecord ?? false;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 85,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPressed
                    ? theme.colorScheme.surface.withOpacity(0.95)
                    : theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed
                      ? theme.colorScheme.outline.withOpacity(0.2)
                      : theme.colorScheme.outline.withOpacity(0.1),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Icon(
                        Icons.child_care,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.diaper,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 메인 콘텐츠
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.diaperCount(totalCount),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bothCount > 0)
                            Text(
                              l10n.diaperWetAndDirty(bothCount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          if (wetCount > 0 || dirtyCount > 0)
                            Text(
                              '${l10n.wetCount(wetCount)}, ${l10n.dirtyCount(dirtyCount)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}