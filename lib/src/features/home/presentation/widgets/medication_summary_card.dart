import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../presentation/providers/medication_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import '../../../../services/medication/medication_service.dart';
import 'record_detail_overlay.dart';

class MedicationSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final MedicationProvider? medicationProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const MedicationSummaryCard({
    super.key,
    required this.summary,
    this.medicationProvider,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MedicationSummaryCard> createState() => _MedicationSummaryCardState();
}

class _MedicationSummaryCardState extends State<MedicationSummaryCard>
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
    } else if (widget.medicationProvider != null) {
      _handleQuickMedication();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      _showMedicationRecords();
    }
  }

  Future<void> _showMedicationRecords() async {
    if (widget.medicationProvider == null) return;

    // Get baby ID from the provider
    final babyId = widget.medicationProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's medication records
      final medications = await MedicationService.instance.getTodayMedications(babyId);
      final medicationData = medications.map((medication) => medication.toJson()).toList();

      if (mounted) {
        // Show the overlay
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.medication,
            summary: widget.summary,
            records: medicationData,
            primaryColor: Colors.pink,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              // Refresh the parent data
              widget.medicationProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
              widget.medicationProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching medication records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.loadFailed),
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

  Future<void> _handleQuickMedication() async {
    if (widget.medicationProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: AppLocalizations.of(context)!.medication,
        onProceed: () => _addQuickMedication(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 투약 추가
      await _addQuickMedication();
    }
  }

  Future<void> _addQuickMedication() async {
    final success = await widget.medicationProvider!.addQuickMedication();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.medicationAdded),
              ],
            ),
            backgroundColor: Colors.pink[600],
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
                Text(AppLocalizations.of(context)!.saveFailed),
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
    final count = widget.summary['count'] ?? 0;
    final medicineCount = widget.summary['medicineCount'] ?? 0;
    final vitaminCount = widget.summary['vitaminCount'] ?? 0;
    final vaccineCount = widget.summary['vaccineCount'] ?? 0;
    final isUpdating = widget.medicationProvider?.isUpdating ?? false;
    final hasUpcomingMedication = widget.summary['hasUpcomingMedication'] ?? false;

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
                      : hasUpcomingMedication 
                          ? Colors.orange.withOpacity(0.3)
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
                        hasUpcomingMedication ? Icons.schedule : Icons.medical_services,
                        color: hasUpcomingMedication ? Colors.orange[700] : Colors.pink[700],
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.medication,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (hasUpcomingMedication)
                        Text(
                          l10n.scheduled,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[300],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 메인 콘텐츠
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${count} ${l10n.times}',
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
                          if (medicineCount > 0)
                            Text(
                              l10n.medicationScheduled(medicineCount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          if (vitaminCount > 0 || vaccineCount > 0)
                            Text(
                              l10n.medicationTypes(vitaminCount, vaccineCount),
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