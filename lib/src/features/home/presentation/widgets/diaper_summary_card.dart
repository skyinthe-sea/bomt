import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // Get baby ID from the provider
    final babyId = widget.diaperProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's diaper records
      final diapers = await DiaperService.instance.getTodayDiapers(babyId);
      final diaperData = diapers.map((diaper) => diaper.toJson()).toList();

      if (mounted) {
        // Show the overlay
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
              // Refresh the parent data
              widget.diaperProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
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
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기저귀 기록을 불러오는데 실패했습니다'),
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

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: '기저귀 교체',
        onProceed: () => _addQuickDiaper(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 기저귀 교체 추가
      await _addQuickDiaper();
    }
  }

  Future<void> _addQuickDiaper() async {
    final success = await widget.diaperProvider!.addQuickDiaper();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기저귀 교체 기록이 추가되었습니다'),
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
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기저귀 기록 추가에 실패했습니다'),
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

  void _showDiaperSettings() {
    if (widget.diaperProvider == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DiaperSettingsDialog(
        currentDefaults: widget.diaperProvider!.diaperDefaults,
        onSave: (settings) async {
          await widget.diaperProvider!.saveDiaperDefaults(
            type: settings['type'],
            color: settings['color'],
            consistency: settings['consistency'],
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('기저귀 설정이 저장되었습니다'),
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
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (isDark 
                        ? Colors.amber.withOpacity(0.2)
                        : const Color(0xFFFFF8E1))
                    : (isDark 
                        ? Colors.amber.withOpacity(0.1)
                        : const Color(0xFFFFFDE7)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPressed
                      ? Colors.amber[400]!.withOpacity(0.5)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
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
                            Icons.child_care,
                            color: Colors.amber[700],
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '기저귀',
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
                            '${totalCount}회',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 세번째 줄: 총 교체 세부사항 (오른쪽 정렬)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (bothCount > 0)
                                Text(
                                  '소+대 ${bothCount}회',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple[700],
                                  ),
                                ),
                              if (wetCount > 0 || dirtyCount > 0)
                                Text(
                                  '소${wetCount}, 대${dirtyCount}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[700],
                                  ),
                                ),
                            ],
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final time = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 전';
      } else {
        return '${difference.inDays}일 전';
      }
    } catch (e) {
      return '';
    }
  }
}