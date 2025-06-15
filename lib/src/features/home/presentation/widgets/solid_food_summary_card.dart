import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../presentation/providers/solid_food_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import '../../../../services/solid_food/solid_food_service.dart';
import 'record_detail_overlay.dart';

class SolidFoodSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final SolidFoodProvider? solidFoodProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const SolidFoodSummaryCard({
    super.key,
    required this.summary,
    this.solidFoodProvider,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<SolidFoodSummaryCard> createState() => _SolidFoodSummaryCardState();
}

class _SolidFoodSummaryCardState extends State<SolidFoodSummaryCard>
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
    } else if (widget.solidFoodProvider != null) {
      _handleQuickSolidFood();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      _showSolidFoodRecords();
    }
  }

  Future<void> _showSolidFoodRecords() async {
    if (widget.solidFoodProvider == null) return;

    // Get baby ID from the provider
    final babyId = widget.solidFoodProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's solid food records
      final solidFoods = await SolidFoodService.instance.getTodaySolidFoods(babyId);
      final solidFoodData = solidFoods.map((solidFood) => solidFood.toJson()).toList();

      if (mounted) {
        // Show the overlay
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.solidFood,
            summary: widget.summary,
            records: solidFoodData,
            primaryColor: Colors.green,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              // Refresh the parent data
              widget.solidFoodProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
              widget.solidFoodProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching solid food records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('이유식 기록을 불러오는데 실패했습니다'),
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

  Future<void> _handleQuickSolidFood() async {
    if (widget.solidFoodProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: '이유식',
        onProceed: () => _addQuickSolidFood(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 이유식 추가
      await _addQuickSolidFood();
    }
  }

  Future<void> _addQuickSolidFood() async {
    final success = await widget.solidFoodProvider!.addQuickSolidFood();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('이유식 기록이 추가되었습니다'),
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
                Text('이유식 기록 추가에 실패했습니다'),
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
    final count = widget.summary['count'] ?? 0;
    final totalMeals = count;
    final totalAmount = widget.summary['totalAmount'] ?? 0;
    final isUpdating = widget.solidFoodProvider?.isUpdating ?? false;

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
                        Icons.restaurant,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '이유식',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                        '${totalMeals}끼',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (totalAmount > 0)
                        Text(
                          '총 ${totalAmount}g',
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