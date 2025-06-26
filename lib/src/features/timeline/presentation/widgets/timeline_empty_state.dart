import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';

class TimelineEmptyState extends StatefulWidget {
  final DateTime selectedDate;
  final TimelineFilterType currentFilter;
  final VoidCallback? onAddRecord;

  const TimelineEmptyState({
    super.key,
    required this.selectedDate,
    required this.currentFilter,
    this.onAddRecord,
  });

  @override
  State<TimelineEmptyState> createState() => _TimelineEmptyStateState();
}

class _TimelineEmptyStateState extends State<TimelineEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getEmptyMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isToday = _isToday(widget.selectedDate);
    final dateString = isToday ? l10n.today : _formatDate(widget.selectedDate, context);
    
    if (widget.currentFilter == TimelineFilterType.all) {
      return l10n.noRecordsForDate(dateString);
    } else {
      return l10n.noRecordsForDateAndFilter(dateString, widget.currentFilter.displayName);
    }
  }

  String _getEmptySubMessage() {
    final isToday = _isToday(widget.selectedDate);
    final isFuture = _isFuture(widget.selectedDate);
    
    final l10n = AppLocalizations.of(context)!;
    
    if (isFuture) {
      return l10n.cannotRecordFuture;
    } else if (isToday) {
      return l10n.addFirstRecord;
    } else {
      return l10n.canAddPastRecord;
    }
  }

  IconData _getEmptyIcon() {
    if (widget.currentFilter == TimelineFilterType.all) {
      return Icons.timeline;
    }
    
    final itemType = widget.currentFilter.itemType;
    if (itemType == null) return Icons.timeline;
    
    switch (itemType) {
      case TimelineItemType.feeding:
        return Icons.local_drink;
      case TimelineItemType.sleep:
        return Icons.bedtime;
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

  Color _getEmptyColor() {
    if (widget.currentFilter == TimelineFilterType.all) {
      return Colors.grey;
    }
    
    final itemType = widget.currentFilter.itemType;
    if (itemType == null) return Colors.grey;
    
    switch (itemType) {
      case TimelineItemType.feeding:
        return Colors.blue;
      case TimelineItemType.sleep:
        return Colors.purple;
      case TimelineItemType.diaper:
        return Colors.orange;
      case TimelineItemType.medication:
        return Colors.pink;
      case TimelineItemType.milkPumping:
        return Colors.teal;
      case TimelineItemType.solidFood:
        return Colors.green;
      case TimelineItemType.temperature:
        return Colors.red;
    }
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  bool _isFuture(DateTime date) {
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    
    DateFormat dateFormat;
    switch (locale) {
      case 'ko':
        dateFormat = DateFormat('M월 d일', 'ko_KR');
        break;
      case 'ja':
        dateFormat = DateFormat('M月d日', 'ja_JP');
        break;
      case 'hi':
        dateFormat = DateFormat('d MMMM', 'hi_IN');
        break;
      default: // 'en'
        dateFormat = DateFormat('MMM d', 'en_US');
        break;
    }
    
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyColor = _getEmptyColor();
    final isFuture = _isFuture(widget.selectedDate);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: emptyColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: emptyColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getEmptyIcon(),
                    size: 56,
                    color: emptyColor.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 메인 메시지
                Text(
                  _getEmptyMessage(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // 서브 메시지
                Text(
                  _getEmptySubMessage(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // 액션 버튼들
                if (!isFuture) ...[
                  // 기록 추가 버튼
                  _ActionButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onAddRecord?.call();
                    },
                    icon: Icons.add,
                    label: AppLocalizations.of(context)!.addRecord,
                    color: emptyColor,
                    isPrimary: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 다른 날짜 보기 버튼
                  _ActionButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: 날짜 선택 다이얼로그 열기
                    },
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context)!.viewOtherDates,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    isPrimary: false,
                  ),
                ] else ...[
                  // 미래 날짜인 경우
                  _ActionButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: 오늘로 이동
                    },
                    icon: Icons.today,
                    label: AppLocalizations.of(context)!.goToToday,
                    color: theme.colorScheme.primary,
                    isPrimary: true,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // 도움말 텍스트
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.quickRecordFromHome,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.isPrimary,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? (_isPressed ? widget.color.withOpacity(0.8) : widget.color)
                    : (_isPressed 
                        ? theme.colorScheme.surface.withOpacity(0.8)
                        : theme.colorScheme.surface),
                borderRadius: BorderRadius.circular(16),
                border: widget.isPrimary ? null : Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary 
                        ? widget.color.withOpacity(0.2)
                        : theme.shadowColor.withOpacity(0.1),
                    blurRadius: widget.isPrimary ? 12 : 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isPrimary 
                        ? Colors.white
                        : widget.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isPrimary 
                          ? Colors.white
                          : widget.color,
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
}