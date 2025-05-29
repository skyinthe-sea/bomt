import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/feeding_provider.dart';
import 'feeding_settings_dialog.dart';
import 'swipeable_card.dart';
import 'undo_snackbar.dart';

class FeedingSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final FeedingProvider? feedingProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const FeedingSummaryCard({
    super.key,
    required this.summary,
    this.feedingProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<FeedingSummaryCard> createState() => _FeedingSummaryCardState();
}

class _FeedingSummaryCardState extends State<FeedingSummaryCard>
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
    } else if (widget.feedingProvider != null) {
      _handleQuickFeeding();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else if (widget.feedingProvider != null) {
      _showFeedingSettings();
    }
  }

  Future<void> _handleQuickFeeding() async {
    if (widget.feedingProvider == null) return;

    final success = await widget.feedingProvider!.addQuickFeeding();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('수유 기록이 추가되었습니다'),
              ],
            ),
            backgroundColor: Colors.green[600],
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
                Text('수유 기록 추가에 실패했습니다'),
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

  void _showFeedingSettings() {
    if (widget.feedingProvider == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FeedingSettingsDialog(
        currentDefaults: widget.feedingProvider!.feedingDefaults,
        onSave: (settings) async {
          await widget.feedingProvider!.saveFeedingDefaults(
            type: settings['type'],
            amountMl: settings['amountMl'],
            durationMinutes: settings['durationMinutes'],
            side: settings['side'],
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('수유 설정이 저장되었습니다'),
                  ],
                ),
                backgroundColor: Colors.blue[600],
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
    if (widget.feedingProvider == null || count <= 0) {
      return;
    }

    final success = await widget.feedingProvider!.deleteLatestFeeding();
    
    if (success && mounted) {
      // 언두 스낵바 표시
      UndoSnackbar.showFeedingDeleted(
        context: context,
        onUndo: () async {
          final undoSuccess = await widget.feedingProvider!.undoDelete();
          if (undoSuccess && mounted) {
            UndoSnackbar.showUndoSuccess(
              context: context,
              message: '수유 기록이 복원되었습니다',
            );
          }
        },
        onDismissed: () {
          // 3초 후 언두 데이터 자동 클리어
          widget.feedingProvider?.clearUndoData();
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
    final totalAmount = widget.summary['totalAmount'] ?? 0;
    final lastFeedingMinutesAgo = widget.summary['lastFeedingMinutesAgo'];
    final isUpdating = widget.feedingProvider?.isUpdating ?? false;
    final hasRecentRecord = widget.feedingProvider?.hasRecentRecord ?? false;

    return SwipeableCard(
      onDelete: count > 0 ? _handleDelete : null,
      deleteConfirmMessage: '최근 수유 기록을 삭제하시겠습니까?',
      isDeletable: count > 0 && !isUpdating,
      deleteButtonColor: Colors.blue[600]!,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (isDark 
                        ? Colors.blue.withOpacity(0.2)
                        : const Color(0xFFE3F2FD))
                    : (isDark 
                        ? Colors.blue.withOpacity(0.1)
                        : const Color(0xFFF0F8FF)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPressed
                      ? Colors.blue[400]!.withOpacity(0.5)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
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
                            Icons.local_drink,
                            color: Colors.blue[700],
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '수유',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 메인 콘텐츠 - 좌우 레이아웃
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 왼쪽: 메인 수치
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$count회',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 오른쪽: 부가 정보
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${totalAmount}ml',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '총 수유량',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
    ),
    );
  }
}