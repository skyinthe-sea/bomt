import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/feeding/feeding_service.dart';
import '../../../../services/sleep/sleep_service.dart';
import '../../../../services/diaper/diaper_service.dart';
import 'edit_record_dialog.dart';

enum RecordType { feeding, sleep, diaper }

class RecordDetailOverlay extends StatefulWidget {
  final RecordType recordType;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> records;
  final VoidCallback onClose;
  final Color primaryColor;
  final VoidCallback? onRecordDeleted;
  final VoidCallback? onRecordUpdated;

  const RecordDetailOverlay({
    super.key,
    required this.recordType,
    required this.summary,
    required this.records,
    required this.onClose,
    required this.primaryColor,
    this.onRecordDeleted,
    this.onRecordUpdated,
  });

  @override
  State<RecordDetailOverlay> createState() => _RecordDetailOverlayState();
}

class _RecordDetailOverlayState extends State<RecordDetailOverlay>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _cardController;
  late AnimationController _listController;
  
  late Animation<double> _overlayAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<Offset> _cardPositionAnimation;
  late Animation<Size> _cardSizeAnimation;
  late Animation<double> _listAnimation;

  // Local records list for real-time updates
  List<Map<String, dynamic>> _localRecords = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize local records
    _localRecords = List.from(widget.records);
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    ));

    _cardScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _cardPositionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.8),
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _cardSizeAnimation = Tween<Size>(
      begin: const Size(120, 80),
      end: const Size(300, 60),
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
    ));

    _startAnimations();
  }

  void _startAnimations() {
    HapticFeedback.mediumImpact();
    _overlayController.forward();
    
    Future.delayed(const Duration(milliseconds: 80), () {
      _cardController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _listController.forward();
    });
  }

  void _closeOverlay() async {
    HapticFeedback.lightImpact();
    
    await Future.wait([
      _listController.reverse(),
      _cardController.reverse(),
    ]);
    
    await _overlayController.reverse();
    widget.onClose();
  }

  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    if (_isDeleting) return;
    
    final recordId = record['id'] as String; // Move to top level for scope access
    
    setState(() {
      _isDeleting = true;
    });

    try {
      bool success = false;

      switch (widget.recordType) {
        case RecordType.feeding:
          success = await FeedingService.instance.deleteFeeding(recordId);
          break;
        case RecordType.sleep:
          success = await SleepService.instance.deleteSleep(recordId);
          break;
        case RecordType.diaper:
          success = await DiaperService.instance.deleteDiaper(recordId);
          break;
      }

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('${_getRecordTitle()} 기록이 삭제되었습니다'),
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

        // Notify parent to refresh data
        widget.onRecordDeleted?.call();

        // If no records left, close overlay
        if (_localRecords.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _closeOverlay();
          }
        }
      } else if (mounted) {
        // Restore the record if deletion failed
        setState(() {
          if (!_localRecords.any((r) => r['id'] == recordId)) {
            _localRecords.add(record);
          }
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기록 삭제에 실패했습니다'),
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
    } catch (e) {
      debugPrint('Error deleting record: $e');
      if (mounted) {
        // Restore the record if error occurred
        setState(() {
          if (!_localRecords.any((r) => r['id'] == recordId)) {
            _localRecords.add(record);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기록 삭제 중 오류가 발생했습니다'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _cardController.dispose();
    _listController.dispose();
    super.dispose();
  }

  String _getRecordTitle() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return '수유';
      case RecordType.sleep:
        return '수면';
      case RecordType.diaper:
        return '기저귀';
    }
  }

  IconData _getRecordIcon() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return Icons.local_drink;
      case RecordType.sleep:
        return Icons.bedtime;
      case RecordType.diaper:
        return Icons.child_care;
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> record) async {
    HapticFeedback.lightImpact();
    
    await showDialog(
      context: context,
      builder: (context) => EditRecordDialog(
        recordType: widget.recordType,
        record: record,
        onSave: (updatedRecord) => _updateRecord(updatedRecord),
      ),
    );
  }

  Future<void> _updateRecord(Map<String, dynamic> updatedRecord) async {
    try {
      Object? result;
      final recordId = updatedRecord['id'] as String;

      switch (widget.recordType) {
        case RecordType.feeding:
          result = await FeedingService.instance.updateFeeding(
            feedingId: recordId,
            type: updatedRecord['type'],
            amountMl: updatedRecord['amount_ml'],
            durationMinutes: updatedRecord['duration_minutes'],
            side: updatedRecord['side'],
            notes: updatedRecord['notes'],
            startedAt: updatedRecord['started_at'] != null ? DateTime.parse(updatedRecord['started_at']).toLocal() : null,
            endedAt: updatedRecord['ended_at'] != null ? DateTime.parse(updatedRecord['ended_at']).toLocal() : null,
          );
          break;
        case RecordType.sleep:
          result = await SleepService.instance.updateSleep(
            sleepId: recordId,
            durationMinutes: updatedRecord['duration_minutes'],
            quality: updatedRecord['quality'],
            location: updatedRecord['location'],
            notes: updatedRecord['notes'],
            startedAt: updatedRecord['started_at'] != null ? DateTime.parse(updatedRecord['started_at']).toLocal() : null,
            endedAt: updatedRecord['ended_at'] != null ? DateTime.parse(updatedRecord['ended_at']).toLocal() : null,
          );
          break;
        case RecordType.diaper:
          result = await DiaperService.instance.updateDiaper(
            diaperId: recordId,
            type: updatedRecord['type'],
            color: updatedRecord['color'],
            consistency: updatedRecord['consistency'],
            notes: updatedRecord['notes'],
            changedAt: updatedRecord['changed_at'] != null ? DateTime.parse(updatedRecord['changed_at']).toLocal() : null,
          );
          break;
      }
      
      final success = result != null;

      if (success && mounted) {
        // Update local record
        setState(() {
          final index = _localRecords.indexWhere((r) => r['id'] == recordId);
          if (index != -1) {
            _localRecords[index] = updatedRecord;
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('${_getRecordTitle()} 기록이 수정되었습니다'),
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

        // Notify parent to refresh data
        widget.onRecordUpdated?.call();
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기록 수정에 실패했습니다'),
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
    } catch (e) {
      debugPrint('Error updating record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('기록 수정 중 오류가 발생했습니다'),
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

  String _formatRecordTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (recordDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Check if there are no records
    if (_localRecords.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _overlayController,
          _cardController,
          _listController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Dark overlay background
              GestureDetector(
                onTap: _closeOverlay,
                child: Container(
                  color: (isDark ? Colors.black : Colors.black54)
                      .withOpacity(_overlayAnimation.value.clamp(0.0, 1.0)),
                ),
              ),

              // Animated header card
              Positioned(
                top: screenHeight * 0.12 + (_cardPositionAnimation.value.dy * screenHeight * 0.08),
                left: (MediaQuery.of(context).size.width - _cardSizeAnimation.value.width) / 2,
                child: Transform.scale(
                  scale: _cardScaleAnimation.value.clamp(0.0, 2.0),
                  child: GestureDetector(
                    onTap: () {}, // Prevent close when tapping on header
                    child: Container(
                      width: _cardSizeAnimation.value.width,
                      height: _cardSizeAnimation.value.height,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? widget.primaryColor.withOpacity(0.3)
                            : widget.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getRecordIcon(),
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${_getRecordTitle()} (${_localRecords.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Records list - stacked then spreading effect
              Positioned(
                top: screenHeight * 0.25,
                left: 20,
                right: 20,
                bottom: 100,
                child: GestureDetector(
                  onTap: _closeOverlay,
                  behavior: HitTestBehavior.translucent,
                  child: _buildStackedRecordsList(context, isDark),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _overlayController,
        builder: (context, child) {
          return Stack(
            children: [
              // Dark overlay background
              GestureDetector(
                onTap: _closeOverlay,
                child: Container(
                  color: (isDark ? Colors.black : Colors.black54)
                      .withOpacity(_overlayAnimation.value.clamp(0.0, 1.0)),
                ),
              ),

              // Simple message for empty state
              Center(
                child: Opacity(
                  opacity: _overlayAnimation.value.clamp(0.0, 1.0),
                  child: GestureDetector(
                    onTap: () {}, // Prevent close when tapping on message box
                    child: Container(
                      margin: const EdgeInsets.all(40),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
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
                          Icon(
                            _getRecordIcon(),
                            size: 64,
                            color: widget.primaryColor.withOpacity(0.6),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '오늘 ${_getRecordTitle()} 기록이 없습니다',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '탭으로 기록을 추가해보세요',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: _closeOverlay,
                            child: Text(
                              '확인',
                              style: TextStyle(
                                color: widget.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStackedRecordsList(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ListView.builder(
        itemCount: _localRecords.length,
        itemBuilder: (context, index) {
          final record = _localRecords[index];
          return _buildStackedRecordItem(context, record, index, isDark);
        },
      ),
    );
  }

  Widget _buildStackedRecordItem(BuildContext context, Map<String, dynamic> record, int index, bool isDark) {
    final theme = Theme.of(context);
    
    // Calculate staggered animation delay for spreading effect
    final delayFactor = (index * 0.08).clamp(0.0, 0.6);
    
    final spreadAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Interval(
        delayFactor,
        (delayFactor + 0.4).clamp(0.4, 1.0),
        curve: Curves.easeOutBack,
      ),
    ));

    final slideAnimation = Tween<Offset>(
      begin: Offset(0, -index * 0.2), // Stacked effect
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Interval(
        delayFactor,
        (delayFactor + 0.4).clamp(0.4, 1.0),
        curve: Curves.easeOutCubic,
      ),
    ));

    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            slideAnimation.value.dx * MediaQuery.of(context).size.width,
            slideAnimation.value.dy * 100,
          ),
          child: Opacity(
            opacity: spreadAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: (0.8 + (spreadAnimation.value * 0.2)).clamp(0.0, 1.0),
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 8 + (4 * spreadAnimation.value), 
                  left: 4,
                  right: 4,
                ),
                child: Dismissible(
                  key: Key(record['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '삭제',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('${_getRecordTitle()} 기록 삭제'),
                        content: const Text('이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    // Immediately remove from local list to prevent the error
                    final recordId = record['id'] as String;
                    setState(() {
                      _localRecords.removeWhere((r) => r['id'] == recordId);
                    });
                    
                    // Then handle the actual database deletion
                    _deleteRecord(record);
                  },
                  child: GestureDetector(
                    onTap: () => _showEditDialog(record),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.1),
                            blurRadius: 8 * spreadAnimation.value,
                            offset: Offset(0, 4 * spreadAnimation.value),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildRecordItemContent(record),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordItemContent(Map<String, dynamic> record) {
    switch (widget.recordType) {
      case RecordType.feeding:
        return _buildFeedingRecord(record);
      case RecordType.sleep:
        return _buildSleepRecord(record);
      case RecordType.diaper:
        return _buildDiaperRecord(record);
    }
  }

  Widget _buildFeedingRecord(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final startedAt = DateTime.parse(record['started_at']).toLocal();
    final amount = record['amount_ml'] ?? 0;
    final type = record['type'] ?? '';
    final duration = record['duration_minutes'] ?? 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_drink,
            color: Colors.blue[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatRecordTime(startedAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (amount > 0) ...[
                    Text(
                      '${amount}ml',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (duration > 0) const Text(' • '),
                  ],
                  if (duration > 0)
                    Text(
                      '${duration}분',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepRecord(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final startedAt = DateTime.parse(record['started_at']).toLocal();
    final endedAt = record['ended_at'] != null ? DateTime.parse(record['ended_at']).toLocal() : null;
    final duration = record['duration_minutes'] ?? 0;
    final quality = record['quality'] ?? '';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            endedAt == null ? Icons.bedtime : Icons.alarm_off,
            color: Colors.purple[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatRecordTime(startedAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (endedAt != null) ...[
                    const Text(' - '),
                    Text(
                      _formatRecordTime(endedAt),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '진행중',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (duration > 0) ...[
                    Text(
                      '${(duration / 60).floor()}시간 ${duration % 60}분',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (quality.isNotEmpty) const Text(' • '),
                  ],
                  if (quality.isNotEmpty)
                    Text(
                      quality,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiaperRecord(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final changedAt = DateTime.parse(record['changed_at']).toLocal();
    final type = record['type'] ?? '';
    final color = record['color'] ?? '';

    String getTypeEmoji(String type) {
      switch (type.toLowerCase()) {
        case 'wet':
          return '💧';
        case 'dirty':
          return '💩';
        case 'both':
          return '💧💩';
        default:
          return '🍼';
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.child_care,
            color: Colors.amber[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatRecordTime(changedAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getTypeEmoji(type),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    type,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (color.isNotEmpty) ...[
                    const Text(' • '),
                    Text(
                      color,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}