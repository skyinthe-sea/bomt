import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';
import '../utils/timeline_localization_helper.dart';

class TimelineItemWidget extends StatefulWidget {
  final TimelineItem item;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TimelineItemWidget({
    super.key,
    required this.item,
    this.isLast = false,
    this.onTap,
    this.onLongPress,
  });
  

  @override
  State<TimelineItemWidget> createState() => _TimelineItemWidgetState();
}

class _TimelineItemWidgetState extends State<TimelineItemWidget>
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
      end: 0.98,
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

  Color _getItemColor() {
    if (widget.item.colorCode != null) {
      try {
        return Color(int.parse(widget.item.colorCode!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // 기본 색상으로 폴백
      }
    }
    
    // 타입별 기본 색상 (이모티콘 색상과 일치)
    switch (widget.item.type) {
      case TimelineItemType.feeding:
        return const Color(0xFF3B82F6); // Blue 500 - 수유 🍼
      case TimelineItemType.sleep:
        return const Color(0xFF8B5FBF); // Purple - 수면 🌙
      case TimelineItemType.diaper:
        return const Color(0xFFFFB020); // Orange - 기저귀
      case TimelineItemType.medication:
        return const Color(0xFFEF4444); // Red 500 - 투약 💊
      case TimelineItemType.milkPumping:
        return const Color(0xFF06B6D4); // Cyan 500 - 유축 🥛
      case TimelineItemType.solidFood:
        return const Color(0xFF10B981); // Emerald 500 - 이유식 🍽️
      case TimelineItemType.temperature:
        return const Color(0xFFEC4899); // Pink 500 - 체온
    }
  }

  IconData _getItemIcon() {
    switch (widget.item.type) {
      case TimelineItemType.feeding:
        return Icons.local_drink;
      case TimelineItemType.sleep:
        return widget.item.isOngoing ? Icons.airline_seat_flat : Icons.bedtime;
      case TimelineItemType.diaper:
        return Icons.baby_changing_station;
      case TimelineItemType.medication:
        return Icons.medical_services;
      case TimelineItemType.milkPumping:
        return Icons.opacity;
      case TimelineItemType.solidFood:
        return Icons.restaurant;
      case TimelineItemType.temperature:
        return Icons.thermostat;
    }
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // UTC 데이터를 로컬 시간으로 변환
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final hour = localDateTime.hour;
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    
    if (hour == 0) {
      return '${l10n.am} 12:$minute';
    } else if (hour < 12) {
      return '${l10n.am} $hour:$minute';
    } else if (hour == 12) {
      return '${l10n.pm} 12:$minute';
    } else {
      return '${l10n.pm} ${hour - 12}:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemColor = _getItemColor();
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시간 표시 (왼쪽)
                  SizedBox(
                    width: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatTime(widget.item.timestamp, context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 타임라인 라인과 아이콘
                  Column(
                    children: [
                      // 아이콘 (원형 배경)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isPressed 
                              ? itemColor.withOpacity(0.8)
                              : itemColor.withOpacity(isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: itemColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: widget.item.isOngoing ? [
                            BoxShadow(
                              color: itemColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          _getItemIcon(),
                          color: _isPressed 
                              ? Colors.white
                              : itemColor.withOpacity(0.8),
                          size: 20,
                        ),
                      ),
                      
                      // 연결선 (마지막 아이템이 아닌 경우)
                      if (!widget.isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: theme.colorScheme.onBackground.withOpacity(0.1),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 콘텐츠 (오른쪽)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? theme.colorScheme.surface.withOpacity(0.8)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isPressed
                              ? itemColor.withOpacity(0.3)
                              : theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목과 진행 중 표시
                          Row(
                            children: [
                              Text(
                                TimelineLocalizationHelper.getLocalizedTitle(context, widget.item),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (widget.item.isOngoing) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.inProgress,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          // 부제목 (있는 경우)
                          if (widget.item.subtitle != null && 
                              widget.item.subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              TimelineLocalizationHelper.getLocalizedSubtitle(context, widget.item),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                          
                          // 추가 정보 (메모, 특수 데이터 등)
                          _buildAdditionalInfo(context, theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, ThemeData theme) {
    final data = widget.item.data;
    
    // 메모가 있는 경우 표시
    if (data['notes'] != null && data['notes'].toString().isNotEmpty) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data['notes'].toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
}