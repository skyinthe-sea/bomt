import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import 'sleep_settings_dialog.dart';
import 'swipeable_card.dart';
import 'undo_snackbar.dart';

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
      _showSleepSettings();
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

  void _showSleepSettings() {
    if (widget.sleepProvider == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SleepSettingsDialog(
        currentDefaults: widget.sleepProvider!.sleepDefaults,
        onSave: (settings) async {
          await widget.sleepProvider!.saveSleepDefaults(
            durationMinutes: settings['durationMinutes'],
            quality: settings['quality'],
            location: settings['location'],
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('수면 설정이 저장되었습니다'),
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
          }
        },
      ),
    );
  }

  Future<void> _handleDelete() async {
    final count = widget.summary['count'] ?? 0;
    if (widget.sleepProvider == null || count <= 0) {
      return;
    }

    final success = await widget.sleepProvider!.deleteLatestSleep();
    
    if (success && mounted) {
      UndoSnackbar.showSleepDeleted(
        context: context,
        onUndo: () async {
          final undoSuccess = await widget.sleepProvider!.undoDelete();
          if (undoSuccess && mounted) {
            UndoSnackbar.showUndoSuccess(
              context: context,
              message: '수면 기록이 복원되었습니다',
            );
          }
        },
        onDismissed: () {
          widget.sleepProvider?.clearUndoData();
        },
      );
    } else if (!success && mounted) {
      UndoSnackbar.showDeleteError(context: context);
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
    final lastSleepMinutesAgo = widget.summary['lastSleepMinutesAgo'];
    final isUpdating = widget.sleepProvider?.isUpdating ?? false;
    final hasActiveSleep = widget.sleepProvider?.hasActiveSleep ?? false;
    final hasRecentRecord = widget.sleepProvider?.hasRecentRecord ?? false;

    return SwipeableCard(
      onDelete: count > 0 ? _handleDelete : null,
      deleteConfirmMessage: widget.sleepProvider?.getDeleteConfirmMessage() ?? '최근 수면 기록을 삭제하시겠습니까?',
      isDeletable: count > 0 && !isUpdating,
      deleteButtonColor: Colors.purple[600]!,
      child: GestureDetector(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (isDark 
                        ? Colors.purple.withOpacity(0.2)
                        : const Color(0xFFE1BEE7))
                    : (isDark 
                        ? Colors.purple.withOpacity(0.1)
                        : const Color(0xFFF8F5FF)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPressed
                      ? Colors.purple[400]!.withOpacity(0.5)
                      : (hasActiveSleep ? Colors.purple[600]! : Colors.transparent),
                  width: 2,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 - 아이콘, 제목, 로딩 인디케이터
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            hasActiveSleep ? Icons.airline_seat_flat : Icons.bedtime,
                            color: hasActiveSleep ? Colors.green[700] : Colors.purple[700],
                            size: 20,
                          ),
                          if (isUpdating)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                      // 힌트 아이콘
                      if (!isUpdating) ...[
                        Icon(
                          hasActiveSleep ? Icons.stop : Icons.play_arrow,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.settings,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 메인 콘텐츠 - 좌우 레이아웃
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 왼쪽: 메인 수치
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count회',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (hasActiveSleep)
                            Text(
                              '진행 중: ${widget.sleepProvider?.getActiveSleepDuration() ?? ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (lastSleepMinutesAgo != null && count > 0)
                            Text(
                              widget.sleepProvider?.getTimeAgoString(lastSleepMinutesAgo) ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      
                      // 오른쪽: 부가 정보
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${totalHours}시간 ${remainingMinutes}분',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '총 수면시간',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // 하단 힌트 텍스트
                  if (!isUpdating) ...[
                    const SizedBox(height: 12),
                    Text(
                      hasActiveSleep 
                          ? (count > 0 ? '터치: 수면 종료 | 꾹 누르기: 설정 | 스와이프: 삭제' : '터치: 수면 종료 | 꾹 누르기: 설정')
                          : (count > 0 ? '터치: 수면 시작 | 꾹 누르기: 설정 | 스와이프: 삭제' : '터치: 수면 시작 | 꾹 누르기: 설정'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }
}