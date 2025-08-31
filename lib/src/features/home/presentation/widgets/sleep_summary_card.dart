import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
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
  
  // 중복 입력 방지를 위한 상태
  DateTime? _lastSleepTapTime;
  static const Duration _duplicateCheckDuration = Duration(minutes: 1);

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
      _handleSleepTapWithDuplicateCheck();
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
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.sleepRecordsLoadFailed),
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

  /// 중복 입력 체크와 함께 수면 탭 처리
  Future<void> _handleSleepTapWithDuplicateCheck() async {
    final now = DateTime.now();
    
    // 마지막 탭 시간과 현재 시간의 차이 확인
    if (_lastSleepTapTime != null) {
      final timeDifference = now.difference(_lastSleepTapTime!);
      
      if (timeDifference <= _duplicateCheckDuration) {
        // 1분 이내에 다시 탭한 경우 확인 다이얼로그 표시
        final shouldProceed = await _showDuplicateConfirmationDialog();
        if (!shouldProceed) {
          return; // 사용자가 취소한 경우
        }
      }
    }
    
    // 현재 시간을 마지막 탭 시간으로 저장
    _lastSleepTapTime = now;
    
    // 수면 토글 진행
    await _handleSleepToggle();
  }
  
  /// 중복 입력 확인 다이얼로그 표시
  Future<bool> _showDuplicateConfirmationDialog() async {
    final hasActiveSleep = widget.sleepProvider?.hasActiveSleep ?? false;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _SleepDuplicateConfirmationDialog(
        isEnding: hasActiveSleep,
      ),
    );
    
    return result ?? false;
  }

  Future<void> _handleSleepToggle() async {
    if (widget.sleepProvider == null) return;

    final hasActiveSleep = widget.sleepProvider!.hasActiveSleep;
    final success = await widget.sleepProvider!.toggleSleep();
    
    if (mounted) {
      if (success) {
        final l10n = AppLocalizations.of(context)!;
        final message = hasActiveSleep 
            ? l10n.sleepEnded
            : l10n.sleepStarted;
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
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.sleepRecordProcessFailed),
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
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.sleep,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (hasActiveSleep)
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
                        l10n.sleepCount(count),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          totalHours > 0 || remainingMinutes > 0
                              ? l10n.sleepDuration(totalHours, remainingMinutes)
                              : l10n.sleepZeroHours,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
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

/// 수면 중복 입력 확인 다이얼로그
class _SleepDuplicateConfirmationDialog extends StatefulWidget {
  final bool isEnding;

  const _SleepDuplicateConfirmationDialog({
    required this.isEnding,
  });

  @override
  _SleepDuplicateConfirmationDialogState createState() => _SleepDuplicateConfirmationDialogState();
}

class _SleepDuplicateConfirmationDialogState extends State<_SleepDuplicateConfirmationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleClose(bool result) async {
    // 닫을 때 애니메이션
    await Future.wait([
      _scaleController.reverse(),
      _fadeController.reverse(),
    ]);
    
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이콘
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isEnding ? Icons.alarm_off : Icons.bedtime,
                        color: Colors.purple,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 제목
                    Text(
                      AppLocalizations.of(context)!.duplicateEntryDetected,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 내용
                    Text(
                      widget.isEnding
                          ? AppLocalizations.of(context)!.sleepEndDuplicateConfirm
                          : AppLocalizations.of(context)!.sleepStartDuplicateConfirm,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // 버튼
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _handleClose(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleClose(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.isEnding ? AppLocalizations.of(context)!.end : AppLocalizations.of(context)!.start,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}