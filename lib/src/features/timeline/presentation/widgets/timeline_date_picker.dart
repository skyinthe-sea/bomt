import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

class TimelineDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;
  final bool isToday;
  final bool isFuture;

  const TimelineDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onToday,
    required this.isToday,
    required this.isFuture,
  });

  @override
  State<TimelineDatePicker> createState() => _TimelineDatePickerState();
}

class _TimelineDatePickerState extends State<TimelineDatePicker>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TimelineDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _slideController.forward().then((_) {
        _slideController.reset();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    
    DateFormat dateFormat;
    switch (locale) {
      case 'ko':
        dateFormat = DateFormat('yyyy년 M월 d일 (EEEE)', 'ko_KR');
        break;
      case 'ja':
        dateFormat = DateFormat('yyyy年M月d日 (EEEE)', 'ja_JP');
        break;
      case 'hi':
        dateFormat = DateFormat('d MMMM yyyy (EEEE)', 'hi_IN');
        break;
      default: // 'en'
        dateFormat = DateFormat('MMMM d, yyyy (EEEE)', 'en_US');
        break;
    }
    
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 이전 날짜 버튼
          _DateNavigationButton(
            icon: Icons.chevron_left,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onPreviousDay();
            },
            tooltip: '이전 날짜',
          ),
          
          const SizedBox(width: 12),
          
          // 날짜 표시
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatDate(widget.selectedDate, context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // 오늘/미래 표시
                      if (widget.isToday || widget.isFuture)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.isToday 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.isToday ? '오늘' : '미래',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.isToday 
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 다음 날짜 버튼 (미래가 아닌 경우에만 활성화)
          _DateNavigationButton(
            icon: Icons.chevron_right,
            onTap: widget.isFuture ? null : () {
              HapticFeedback.lightImpact();
              widget.onNextDay();
            },
            tooltip: '다음 날짜',
            disabled: widget.isFuture,
          ),
          
          const SizedBox(width: 8),
          
          // 오늘로 가기 버튼 (오늘이 아닌 경우에만 표시)
          if (!widget.isToday)
            _TodayButton(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onToday();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (selectedDate != null) {
      HapticFeedback.selectionClick();
      widget.onDateChanged(selectedDate);
    }
  }
}

class _DateNavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final bool disabled;

  const _DateNavigationButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.disabled = false,
  });

  @override
  State<_DateNavigationButton> createState() => _DateNavigationButtonState();
}

class _DateNavigationButtonState extends State<_DateNavigationButton>
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
      end: 0.9,
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
    if (widget.disabled || widget.onTap == null) return;
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
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isPressed && !widget.disabled
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.disabled
                      ? theme.colorScheme.onSurface.withOpacity(0.3)
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TodayButton({
    required this.onTap,
  });

  @override
  State<_TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<_TodayButton>
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
      child: Tooltip(
        message: '오늘로 가기',
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? theme.colorScheme.primary.withOpacity(0.8)
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '오늘',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}