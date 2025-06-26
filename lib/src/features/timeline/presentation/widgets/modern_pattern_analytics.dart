import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';
import 'dart:math';
import '../../../../domain/models/timeline_item.dart';

class ModernPatternAnalytics extends StatefulWidget {
  final List<TimelineItem> timelineItems;
  final DateTime selectedDate;

  const ModernPatternAnalytics({
    Key? key,
    required this.timelineItems,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<ModernPatternAnalytics> createState() => _ModernPatternAnalyticsState();
}

class _ModernPatternAnalyticsState extends State<ModernPatternAnalytics>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // 각 시간대별 바 애니메이션
    _barControllers = List.generate(8, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 800 + index * 100),
        vsync: this,
      );
    });

    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // 순차적으로 바 애니메이션 시작
    _startBarAnimations();
  }

  void _startBarAnimations() async {
    for (int i = 0; i < _barControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (mounted) {
        _barControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    for (final controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildActivityChart(),
              const SizedBox(height: 20),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 펄스 아이콘
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5FBF).withOpacity(0.8 + _pulseController.value * 0.2),
                    const Color(0xFFB794F6).withOpacity(0.6 + _pulseController.value * 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5FBF).withOpacity(0.3 + _pulseController.value * 0.2),
                    blurRadius: 12 + _pulseController.value * 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),
        
        const SizedBox(width: 16),
        
        // 제목과 부제목
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.activityPatternAnalysis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.activityConcentrationTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // AI 인사이트 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF34D399),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 12,
              ),
              SizedBox(width: 4),
              Text(
                'AI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart() {
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          // 시간 레이블
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final hour = index * 3;
              return Text(
                '${hour}시',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // 활동 차트
          Expanded(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  children: List.generate(8, (index) {
                    return Expanded(child: _buildActivityBar(index));
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(int timeSlotIndex) {
    final startHour = timeSlotIndex * 3;
    final endHour = startHour + 3;
    final activities = _getActivitiesInTimeRange(startHour, endHour);
    
    return AnimatedBuilder(
      animation: _barAnimations[timeSlotIndex],
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...activities.map((activity) => _buildActivityBlock(
                activity, 
                timeSlotIndex,
                _barAnimations[timeSlotIndex].value,
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityBlock(TimelineItemType type, int timeSlotIndex, double animationValue) {
    final colors = _getActivityColors(type);
    final waveOffset = sin(_waveController.value * 2 * pi + timeSlotIndex * 0.5) * 2;
    
    return Container(
      width: double.infinity,
      height: (18 + waveOffset) * animationValue,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors['primary']!.withOpacity(0.8),
            colors['secondary']!.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final activityCounts = _getActivityCounts();
    final topActivities = activityCounts.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: topActivities.take(4).map((entry) {
        final colors = _getActivityColors(entry.key);
        final name = _getActivityName(entry.key, context);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors['primary']!.withOpacity(0.1),
                colors['secondary']!.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors['primary']!.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors['primary']!,
                      colors['secondary']!,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${entry.value}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors['primary'],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<TimelineItemType> _getActivitiesInTimeRange(int startHour, int endHour) {
    final activities = <TimelineItemType>[];
    
    for (final item in widget.timelineItems) {
      final itemHour = item.timestamp.hour;
      if (itemHour >= startHour && itemHour < endHour) {
        if (!activities.contains(item.type)) {
          activities.add(item.type);
        }
      }
    }
    
    // 우선순위에 따라 정렬
    const priorityOrder = [
      TimelineItemType.sleep,
      TimelineItemType.feeding,
      TimelineItemType.diaper,
      TimelineItemType.medication,
      TimelineItemType.milkPumping,
      TimelineItemType.solidFood,
      TimelineItemType.temperature,
    ];
    
    activities.sort((a, b) {
      return priorityOrder.indexOf(a).compareTo(priorityOrder.indexOf(b));
    });
    
    return activities.take(3).toList();
  }

  Map<TimelineItemType, int> _getActivityCounts() {
    final counts = <TimelineItemType, int>{};
    
    for (final item in widget.timelineItems) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    
    return counts;
  }

  Map<String, Color> _getActivityColors(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.sleep:
        return {'primary': const Color(0xFF8B5FBF), 'secondary': const Color(0xFFB794F6)};
      case TimelineItemType.feeding:
        return {'primary': const Color(0xFF38A169), 'secondary': const Color(0xFF68D391)};
      case TimelineItemType.diaper:
        return {'primary': const Color(0xFFED8936), 'secondary': const Color(0xFFFBD38D)};
      case TimelineItemType.medication:
        return {'primary': const Color(0xFFE53E3E), 'secondary': const Color(0xFFFC8181)};
      case TimelineItemType.milkPumping:
        return {'primary': const Color(0xFF319795), 'secondary': const Color(0xFF81E6D9)};
      case TimelineItemType.solidFood:
        return {'primary': const Color(0xFF3182CE), 'secondary': const Color(0xFF90CDF4)};
      case TimelineItemType.temperature:
        return {'primary': const Color(0xFFD69E2E), 'secondary': const Color(0xFFF6E05E)};
      default:
        return {'primary': const Color(0xFF718096), 'secondary': const Color(0xFFA0AEC0)};
    }
  }

  String _getActivityName(TimelineItemType type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case TimelineItemType.sleep:
        return l10n.sleep;
      case TimelineItemType.feeding:
        return l10n.feeding;
      case TimelineItemType.diaper:
        return l10n.diaper;
      case TimelineItemType.medication:
        return l10n.medication;
      case TimelineItemType.milkPumping:
        return l10n.milkPumping;
      case TimelineItemType.solidFood:
        return l10n.solidFood;
      case TimelineItemType.temperature:
        return l10n.temperature;
      default:
        return l10n.other;
    }
  }
}