import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/milk_pumping_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import '../../../../services/milk_pumping/milk_pumping_service.dart';
import 'record_detail_overlay.dart';

class MilkPumpingSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final MilkPumpingProvider? milkPumpingProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const MilkPumpingSummaryCard({
    super.key,
    required this.summary,
    this.milkPumpingProvider,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MilkPumpingSummaryCard> createState() => _MilkPumpingSummaryCardState();
}

class _MilkPumpingSummaryCardState extends State<MilkPumpingSummaryCard>
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
    } else if (widget.milkPumpingProvider != null) {
      _handleQuickMilkPumping();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      _showMilkPumpingRecords();
    }
  }

  Future<void> _showMilkPumpingRecords() async {
    if (widget.milkPumpingProvider == null) return;

    // Get baby ID from the provider
    final babyId = widget.milkPumpingProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's milk pumping records
      final milkPumpings = await MilkPumpingService.instance.getTodayMilkPumpings(babyId);
      final milkPumpingData = milkPumpings.map((milkPumping) => milkPumping.toJson()).toList();

      if (mounted) {
        // Show the overlay
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.milkPumping,
            summary: widget.summary,
            records: milkPumpingData,
            primaryColor: Colors.teal,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              // Refresh the parent data
              widget.milkPumpingProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
              widget.milkPumpingProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching milk pumping records: $e');
      
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

  Future<void> _handleQuickMilkPumping() async {
    if (widget.milkPumpingProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: AppLocalizations.of(context)!.milkPumping,
        onProceed: () => _addQuickMilkPumping(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 유축 추가
      await _addQuickMilkPumping();
    }
  }

  Future<void> _addQuickMilkPumping() async {
    final success = await widget.milkPumpingProvider!.addQuickMilkPumping();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.milkPumpingAdded),
              ],
            ),
            backgroundColor: Colors.teal[600],
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
    final totalAmount = widget.summary['totalAmount'] ?? 0;
    final isUpdating = widget.milkPumpingProvider?.isUpdating ?? false;
    final hasActivePumping = widget.milkPumpingProvider?.hasActivePumping ?? false;

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
                      : hasActivePumping 
                          ? Colors.green.withOpacity(0.3)
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
                        hasActivePumping ? Icons.play_circle_filled : Icons.baby_changing_station,
                        color: hasActivePumping ? Colors.green[700] : Colors.teal[700],
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.milkPumping,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (hasActivePumping)
                        Text(
                          l10n.inProgress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green[300],
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
                      Text(
                        '${totalAmount}${l10n.milliliters}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
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