import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
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
  
  // 중복 입력 방지를 위한 상태
  DateTime? _lastDiaperTapTime;
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
    } else if (widget.diaperProvider != null) {
      _handleDiaperTapWithDuplicateCheck();
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

    final babyId = widget.diaperProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      final diapers = await DiaperService.instance.getTodayDiapers(babyId);
      final diaperData = diapers.map((diaper) => diaper.toJson()).toList();

      if (mounted) {
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
              widget.diaperProvider?.refreshData();
            },
            onRecordUpdated: () {
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
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordsLoadFailed),
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

  /// 중복 입력 체크와 함께 기저귀 탭 처리
  Future<void> _handleDiaperTapWithDuplicateCheck() async {
    final now = DateTime.now();
    
    // 마지막 탭 시간과 현재 시간의 차이 확인
    if (_lastDiaperTapTime != null) {
      final timeDifference = now.difference(_lastDiaperTapTime!);
      
      if (timeDifference <= _duplicateCheckDuration) {
        // 1분 이내에 다시 탭한 경우 확인 다이얼로그 표시
        final shouldProceed = await _showDuplicateConfirmationDialog();
        if (!shouldProceed) {
          return; // 사용자가 취소한 경우
        }
      }
    }
    
    // 현재 시간을 마지막 탭 시간으로 저장
    _lastDiaperTapTime = now;
    
    // 기저귀 타입 선택 다이얼로그 표시
    await _showDiaperTypeSelectionDialog();
  }
  
  /// 중복 입력 확인 다이얼로그 표시
  Future<bool> _showDuplicateConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _DiaperDuplicateConfirmationDialog(),
    );
    
    return result ?? false;
  }
  
  /// 기저귀 타입 선택 다이얼로그 표시
  Future<void> _showDiaperTypeSelectionDialog() async {
    final selectedType = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _DiaperTypeSelectionDialog(),
    );
    
    if (selectedType != null) {
      await _handleQuickDiaper(selectedType);
    }
  }

  Future<void> _handleQuickDiaper([String? selectedType]) async {
    if (widget.diaperProvider == null) return;

    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: AppLocalizations.of(context)!.diaperChanged,
        onProceed: () => _addQuickDiaper(),
      );
      
      if (!shouldProceed) return;
    } else {
      await _addQuickDiaper(selectedType);
    }
  }

  Future<void> _addQuickDiaper([String? diaperType]) async {
    final success = await widget.diaperProvider!.addQuickDiaper(type: diaperType);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordAdded),
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
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.diaperRecordAddFailed),
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
                        Icons.child_care,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.diaper,
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
                        l10n.diaperCount(totalCount),
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
                          if (bothCount > 0)
                            Text(
                              l10n.diaperWetAndDirty(bothCount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          if (wetCount > 0 || dirtyCount > 0) ...[
                            Text(
                              l10n.wetCount(wetCount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              l10n.dirtyCount(dirtyCount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
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

/// 기저귀 중복 입력 확인 다이얼로그
class _DiaperDuplicateConfirmationDialog extends StatefulWidget {
  @override
  _DiaperDuplicateConfirmationDialogState createState() => _DiaperDuplicateConfirmationDialogState();
}

class _DiaperDuplicateConfirmationDialogState extends State<_DiaperDuplicateConfirmationDialog>
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
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.child_care,
                        color: Colors.amber,
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
                      '방금 전에 기저귀 교체를 기록하셨습니다.\n정말로 다시 기록하시겠습니까?',
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
                              backgroundColor: Colors.amber,
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

/// 기저귀 타입 선택 다이얼로그
class _DiaperTypeSelectionDialog extends StatefulWidget {
  @override
  _DiaperTypeSelectionDialogState createState() => _DiaperTypeSelectionDialogState();
}

class _DiaperTypeSelectionDialogState extends State<_DiaperTypeSelectionDialog>
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

  Future<void> _handleSelection(String type) async {
    // 닫을 때 애니메이션
    await Future.wait([
      _scaleController.reverse(),
      _fadeController.reverse(),
    ]);
    
    if (mounted) {
      Navigator.of(context).pop(type);
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
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.child_care,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 제목
                    Text(
                      '기저귀 교체',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 내용
                    Text(
                      '어떤 종류로 교체하셨나요?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // 선택 버튼들
                    Column(
                      children: [
                        // 소변 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleSelection('wet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.opacity, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '소변',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 대변 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleSelection('dirty'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.eco, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '대변',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 소변+대변 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleSelection('both'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.child_care, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '소변+대변',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 취소 버튼
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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