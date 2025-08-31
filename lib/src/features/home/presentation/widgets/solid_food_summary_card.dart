import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
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
  
  // 중복 입력 방지를 위한 상태
  DateTime? _lastSolidFoodTapTime;
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
    } else if (widget.solidFoodProvider != null) {
      _handleSolidFoodTapWithDuplicateCheck();
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

  /// 중복 입력 체크와 함께 이유식 탭 처리
  Future<void> _handleSolidFoodTapWithDuplicateCheck() async {
    final now = DateTime.now();
    
    // 마지막 탭 시간과 현재 시간의 차이 확인
    if (_lastSolidFoodTapTime != null) {
      final timeDifference = now.difference(_lastSolidFoodTapTime!);
      
      if (timeDifference <= _duplicateCheckDuration) {
        // 1분 이내에 다시 탭한 경우 확인 다이얼로그 표시
        final shouldProceed = await _showDuplicateConfirmationDialog();
        if (!shouldProceed) {
          return; // 사용자가 취소한 경우
        }
      }
    }
    
    // 현재 시간을 마지막 탭 시간으로 저장
    _lastSolidFoodTapTime = now;
    
    // 이유식 기록 진행
    await _handleQuickSolidFood();
  }
  
  /// 중복 입력 확인 다이얼로그 표시
  Future<bool> _showDuplicateConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _SolidFoodDuplicateConfirmationDialog(),
    );
    
    return result ?? false;
  }

  Future<void> _handleQuickSolidFood() async {
    if (widget.solidFoodProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: AppLocalizations.of(context)!.solidFood,
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
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.solidFoodAdded),
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
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.solidFood,
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
                        l10n.solidFoodMeals(totalMeals),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (totalAmount > 0)
                        Text(
                          l10n.solidFoodAmount(totalAmount),
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

/// 이유식 중복 입력 확인 다이얼로그
class _SolidFoodDuplicateConfirmationDialog extends StatefulWidget {
  @override
  _SolidFoodDuplicateConfirmationDialogState createState() => _SolidFoodDuplicateConfirmationDialogState();
}

class _SolidFoodDuplicateConfirmationDialogState extends State<_SolidFoodDuplicateConfirmationDialog>
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
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 제목
                    Text(
                      AppLocalizations.of(context)!.duplicateInputDetected,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 내용
                    Text(
                      AppLocalizations.of(context)!.solidFoodDuplicateConfirm,
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
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.record,
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