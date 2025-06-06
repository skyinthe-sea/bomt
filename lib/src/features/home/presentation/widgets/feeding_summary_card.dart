import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/feeding_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/feeding/feeding_service.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import 'feeding_settings_dialog.dart';
import 'record_detail_overlay.dart';

class FeedingSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final FeedingProvider? feedingProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const FeedingSummaryCard({
    super.key,
    required this.summary,
    this.feedingProvider,
    this.sleepProvider,
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
      _showFeedingRecords();
    }
  }

  Future<void> _showFeedingRecords() async {
    if (widget.feedingProvider == null) return;

    // Get baby ID from the provider
    final babyId = widget.feedingProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's feeding records
      final feedings = await FeedingService.instance.getTodayFeedings(babyId);
      final feedingData = feedings.map((feeding) => feeding.toJson()).toList();

      if (mounted) {
        // Show the overlay
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.feeding,
            summary: widget.summary,
            records: feedingData,
            primaryColor: Colors.blue,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              // Refresh the parent data
              widget.feedingProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
              widget.feedingProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching feeding records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('수유 기록을 불러오는데 실패했습니다'),
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

  Future<void> _handleQuickFeeding() async {
    if (widget.feedingProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: '수유',
        onProceed: () => _addQuickFeeding(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 수유 추가
      await _addQuickFeeding();
    }
  }

  Future<void> _addQuickFeeding() async {
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 120,
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
                  
                  // 메인 콘텐츠 - 3줄 세로 레이아웃
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 두번째 줄: 횟수 (왼쪽 정렬)
                      Row(
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
                      const SizedBox(height: 8),
                      
                      // 세번째 줄: 총 수유량 (오른쪽 정렬)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '총 ${totalAmount}ml',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
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