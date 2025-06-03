import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/timeline_item.dart';

class TimelineFilterBar extends StatefulWidget {
  final TimelineFilterType currentFilter;
  final Function(TimelineFilterType) onFilterChanged;
  final Map<TimelineItemType, int> itemCounts;

  const TimelineFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.itemCounts,
  });

  @override
  State<TimelineFilterBar> createState() => _TimelineFilterBarState();
}

class _TimelineFilterBarState extends State<TimelineFilterBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getFilterColor(TimelineFilterType filter) {
    if (filter == TimelineFilterType.all) {
      return Colors.grey;
    }
    
    final itemType = filter.itemType;
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

  IconData _getFilterIcon(TimelineFilterType filter) {
    if (filter == TimelineFilterType.all) {
      return Icons.view_list;
    }
    
    final itemType = filter.itemType;
    if (itemType == null) return Icons.view_list;
    
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

  int _getFilterCount(TimelineFilterType filter) {
    if (filter == TimelineFilterType.all) {
      return widget.itemCounts.values.fold(0, (sum, count) => sum + count);
    }
    
    final itemType = filter.itemType;
    if (itemType == null) return 0;
    
    return widget.itemCounts[itemType] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TimelineFilterType.values.length,
        itemBuilder: (context, index) {
          final filter = TimelineFilterType.values[index];
          final isSelected = widget.currentFilter == filter;
          final filterColor = _getFilterColor(filter);
          final count = _getFilterCount(filter);
          
          return Container(
            margin: EdgeInsets.only(
              right: index < TimelineFilterType.values.length - 1 ? 12 : 0,
            ),
            child: _FilterChip(
              filter: filter,
              isSelected: isSelected,
              color: filterColor,
              count: count,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onFilterChanged(filter);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final TimelineFilterType filter;
  final bool isSelected;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
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

  IconData _getFilterIcon() {
    if (widget.filter == TimelineFilterType.all) {
      return Icons.view_list;
    }
    
    final itemType = widget.filter.itemType;
    if (itemType == null) return Icons.view_list;
    
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color.withOpacity(isDark ? 0.3 : 0.1)
                    : _isPressed
                        ? theme.colorScheme.surface.withOpacity(0.8)
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color.withOpacity(0.5)
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘
                  Icon(
                    _getFilterIcon(),
                    size: 18,
                    color: widget.isSelected
                        ? widget.color
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  
                  const SizedBox(width: 6),
                  
                  // 텍스트
                  Text(
                    widget.filter.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isSelected
                          ? widget.color
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  // 개수 표시 (0이 아닌 경우에만)
                  if (widget.count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? widget.color.withOpacity(0.2)
                            : theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.count.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.isSelected
                              ? widget.color
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}