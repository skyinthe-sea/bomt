import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../presentation/providers/medication_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../services/sleep/sleep_interruption_service.dart';
import '../../../../services/medication/medication_service.dart';
import 'record_detail_overlay.dart';

class MedicationSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final MedicationProvider? medicationProvider;
  final SleepProvider? sleepProvider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const MedicationSummaryCard({
    super.key,
    required this.summary,
    this.medicationProvider,
    this.sleepProvider,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MedicationSummaryCard> createState() => _MedicationSummaryCardState();
}

class _MedicationSummaryCardState extends State<MedicationSummaryCard>
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
    } else if (widget.medicationProvider != null) {
      _handleQuickMedication();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      _showMedicationRecords();
    }
  }

  Future<void> _showMedicationRecords() async {
    if (widget.medicationProvider == null) return;

    // Get baby ID from the provider
    final babyId = widget.medicationProvider!.currentBabyId;
    if (babyId == null) return;

    try {
      // Fetch today's medication records
      final medications = await MedicationService.instance.getTodayMedications(babyId);
      final medicationData = medications.map((medication) => medication.toJson()).toList();

      if (mounted) {
        // Show the overlay
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          builder: (context) => RecordDetailOverlay(
            recordType: RecordType.medication,
            summary: widget.summary,
            records: medicationData,
            primaryColor: Colors.pink,
            onClose: () => Navigator.of(context).pop(),
            onRecordDeleted: () {
              // Refresh the parent data
              widget.medicationProvider?.refreshData();
            },
            onRecordUpdated: () {
              // Refresh the parent data
              widget.medicationProvider?.refreshData();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching medication records: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('투약 기록을 불러오는데 실패했습니다'),
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

  Future<void> _handleQuickMedication() async {
    if (widget.medicationProvider == null) return;

    // 수면 중단 확인 로직
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final shouldProceed = await SleepInterruptionService.instance.showSleepInterruptionDialog(
        context: context,
        sleepProvider: widget.sleepProvider!,
        activityName: '투약',
        onProceed: () => _addQuickMedication(),
      );
      
      if (!shouldProceed) return;
    } else {
      // 진행 중인 수면이 없으면 바로 투약 추가
      await _addQuickMedication();
    }
  }

  Future<void> _addQuickMedication() async {
    final success = await widget.medicationProvider!.addQuickMedication();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('투약 기록이 추가되었습니다'),
              ],
            ),
            backgroundColor: Colors.pink[600],
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
                Text('투약 기록 추가에 실패했습니다'),
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
    final medicineCount = widget.summary['medicineCount'] ?? 0;
    final vitaminCount = widget.summary['vitaminCount'] ?? 0;
    final vaccineCount = widget.summary['vaccineCount'] ?? 0;
    final isUpdating = widget.medicationProvider?.isUpdating ?? false;
    final hasUpcomingMedication = widget.summary['hasUpcomingMedication'] ?? false;

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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (isDark 
                        ? Colors.pink.withOpacity(0.2)
                        : const Color(0xFFFCE4EC))
                    : (isDark 
                        ? Colors.pink.withOpacity(0.1)
                        : const Color(0xFFFFF0F5)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPressed
                      ? Colors.pink[400]!.withOpacity(0.5)
                      : (hasUpcomingMedication ? Colors.pink[600]! : Colors.transparent),
                  width: 2,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
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
                            hasUpcomingMedication ? Icons.schedule : Icons.medical_services,
                            color: hasUpcomingMedication ? Colors.orange[700] : Colors.pink[700],
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '투약',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (hasUpcomingMedication) ...[
                        Text(
                          '예정',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
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
                            '${count}회',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 세번째 줄: 투약 종류별 세부사항 (오른쪽 정렬)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (medicineCount > 0)
                                Text(
                                  '약 ${medicineCount}회',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.pink[700],
                                  ),
                                ),
                              if (vitaminCount > 0 || vaccineCount > 0)
                                Text(
                                  '영양제 ${vitaminCount}, 백신 ${vaccineCount}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.pink[600],
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
}