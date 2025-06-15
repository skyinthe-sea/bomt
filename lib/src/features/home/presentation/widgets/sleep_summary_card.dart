import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/sleep/sleep_service.dart';
import 'record_detail_overlay.dart';

class SleepSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const SleepSummaryCard({
    super.key,
    required this.summary,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<SleepSummaryCard> createState() => _SleepSummaryCardState();
}

class _SleepSummaryCardState extends State<SleepSummaryCard>
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
    } else if (widget.sleepProvider != null) {
      _handleSleepToggle();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else if (widget.sleepProvider != null) {
      _showSleepRecords();
    }
  }

  Future<void> _showSleepRecords() async {
    if (widget.sleepProvider == null) return;

    final babyId = widget.sleepProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      final sleeps = await SleepService.instance.getTodaySleeps(babyId);
      final sleepData = sleeps.map((sleep) => sleep.toJson()).toList();

      if (mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.sleep,
            summary: widget.summary,
            records: sleepData,
            primaryColor: Colors.purple,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              widget.sleepProvider?.refreshData();
            },
            onRecordUpdated: () {
              widget.sleepProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching sleep records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('수면 기록을 불러오는데 실패했습니다'),
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

  Future<void> _handleSleepToggle() async {
    if (widget.sleepProvider == null) return;

    final hasActiveSleep = widget.sleepProvider!.hasActiveSleep;
    final success = await widget.sleepProvider!.toggleSleep();
    
    if (mounted) {
      if (success) {
        final message = hasActiveSleep 
            ? '수면이 종료되었습니다'
            : '수면을 시작했습니다';
        final icon = hasActiveSleep 
            ? Icons.alarm_off 
            : Icons.bedtime;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(message),
              ],
            ),
            backgroundColor: Colors.purple[600],
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
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('수면 기록 처리에 실패했습니다'),
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
    final isDark = theme.brightness == Brightness.dark;
    
    final count = widget.summary['count'] ?? 0;
    final totalHours = widget.summary['totalHours'] ?? 0;
    final remainingMinutes = widget.summary['remainingMinutes'] ?? 0;
    final isUpdating = widget.sleepProvider?.isUpdating ?? false;
    final hasActiveSleep = widget.sleepProvider?.hasActiveSleep ?? false;

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
                      : hasActiveSleep 
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
                        hasActiveSleep ? Icons.airline_seat_flat : Icons.bedtime,
                        color: hasActiveSleep ? Colors.green[700] : Colors.purple[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '수면',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (hasActiveSleep)
                        Text(
                          '진행 중',
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
                        '$count회',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '총 ${totalHours}시간 ${remainingMinutes}분',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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