import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/health_provider.dart';
import 'temperature_settings_dialog.dart';
import 'swipeable_card.dart';
import 'undo_snackbar.dart';

class TemperatureSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;

  const TemperatureSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  State<TemperatureSummaryCard> createState() => _TemperatureSummaryCardState();
}

class _TemperatureSummaryCardState extends State<TemperatureSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

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

  Future<void> _onTap() async {
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      final healthProvider = Provider.of<HealthProvider>(context, listen: false);
      await healthProvider.addQuickTemperature();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체온이 기록되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기록 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onLongPress() async {
    HapticFeedback.mediumImpact();
    
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final currentDefaults = await healthProvider.getTemperatureDefaults();
    
    if (!mounted) return;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TemperatureSettingsDialog(
        currentDefaults: currentDefaults,
        onSave: (newDefaults) async {
          await healthProvider.saveTemperatureDefaults(newDefaults);
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('체온 설정이 저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final count = widget.summary['count'] ?? 0;
    
    if (count <= 0) {
      return;
    }

    final success = await healthProvider.deleteLatestHealthRecord();
    
    if (success && mounted) {
      UndoSnackbar.showHealthDeleted(
        context: context,
        onUndo: () async {
          final undoSuccess = await healthProvider.undoDelete();
          if (undoSuccess && mounted) {
            UndoSnackbar.showUndoSuccess(
              context: context,
              message: '건강 기록이 복원되었습니다',
            );
          }
        },
        onDismissed: () {
          healthProvider.clearUndoData();
        },
      );
    } else if (!success && mounted) {
      UndoSnackbar.showDeleteError(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final latestTemp = widget.summary['latestTemperature'] ?? 36.5;
    final minTemp = widget.summary['minTemperature'] ?? 0.0;
    final maxTemp = widget.summary['maxTemperature'] ?? 0.0;
    final avgTemp = widget.summary['avgTemperature'] ?? 0.0;
    final count = widget.summary['count'] ?? 0;

    // Determine temperature status
    final tempStatus = _getTemperatureStatus(latestTemp);
    final statusColor = _getStatusColor(tempStatus);
    
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final hasRecentRecord = healthProvider.hasRecentRecord;

    return SwipeableCard(
      onDelete: count > 0 ? _handleDelete : null,
      deleteConfirmMessage: '최근 체온 기록을 삭제하시겠습니까?',
      isDeletable: count > 0 && !_isLoading,
      deleteButtonColor: Colors.orange[600]!,
      child: GestureDetector(
      onTap: _isLoading ? null : _onTap,
      onLongPress: _isLoading ? null : _onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.orange.withOpacity(0.1)
                    : const Color(0xFFFFFFF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 아이콘과 제목
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          if (_isLoading)
                            Positioned.fill(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange[700]!,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '건강',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoading)
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 메인 콘텐츠 - 좌우 레이아웃
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 왼쪽: 메인 수치
                      Text(
                        '${latestTemp.toStringAsFixed(1)}°C',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      // 오른쪽: 부가 정보
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '최근 체온',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tempStatus,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (count > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTempInfo(context, '평균', avgTemp, Colors.blue),
                        _buildTempInfo(context, '최저', minTemp, Colors.cyan),
                        _buildTempInfo(context, '최고', maxTemp, Colors.red),
                      ],
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

  Widget _buildTempInfo(
    BuildContext context,
    String label,
    double temp,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${temp.toStringAsFixed(1)}°',
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 36.0) {
      return '저체온';
    } else if (temp >= 36.0 && temp < 37.5) {
      return '정상';
    } else if (temp >= 37.5 && temp < 38.0) {
      return '미열';
    } else {
      return '고열';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '저체온':
        return Colors.blue;
      case '정상':
        return Colors.green;
      case '미열':
        return Colors.orange;
      case '고열':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}