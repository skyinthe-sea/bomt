import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../../../domain/models/timeline_item.dart';

class GlassmorphicTimelineCard extends StatefulWidget {
  final TimelineItem item;
  final VoidCallback? onTap;
  final bool isLast;

  const GlassmorphicTimelineCard({
    Key? key,
    required this.item,
    this.onTap,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<GlassmorphicTimelineCard> createState() => _GlassmorphicTimelineCardState();
}

class _GlassmorphicTimelineCardState extends State<GlassmorphicTimelineCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // 진행 중인 아이템이면 펄스 애니메이션 시작
    if (widget.item.isOngoing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시간 표시 및 타임라인 라인
                  _buildTimelineIndicator(),
                  
                  const SizedBox(width: 16),
                  
                  // 글라스모픽 카드
                  Expanded(
                    child: _buildGlassmorphicCard(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineIndicator() {
    final activityColors = _getActivityColors();
    
    return Column(
      children: [
        // 시간 표시
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                activityColors['primary']!.withOpacity(0.1),
                activityColors['secondary']!.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activityColors['primary']!.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            DateFormat('HH:mm').format(widget.item.timestamp),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: activityColors['primary'],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 타임라인 도트와 라인
        Column(
          children: [
            // 진행 중인 아이템용 펄스 도트
            if (widget.item.isOngoing)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activityColors['primary']!.withOpacity(0.3 + _pulseAnimation.value * 0.4),
                      activityColors['primary']!.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activityColors['primary'],
                      boxShadow: [
                        BoxShadow(
                          color: activityColors['primary']!.withOpacity(0.5 + _pulseAnimation.value * 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 일반 도트
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      activityColors['primary']!,
                      activityColors['secondary']!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activityColors['primary']!.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            
            // 연결 라인 (마지막 아이템이 아닐 때)
            if (!widget.isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      activityColors['primary']!.withOpacity(0.3),
                      activityColors['primary']!.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassmorphicCard() {
    final activityColors = _getActivityColors();
    final iconData = _getActivityIcon();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                activityColors['primary']!.withOpacity(0.15),
                activityColors['secondary']!.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2 + _glowAnimation.value * 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: activityColors['primary']!.withOpacity(0.1 + _glowAnimation.value * 0.1),
                blurRadius: 20 + _glowAnimation.value * 10,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activityColors['primary']!,
                      activityColors['secondary']!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: activityColors['primary']!.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 콘텐츠
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                        ),
                        if (widget.item.isOngoing)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activityColors['primary']!,
                                  activityColors['secondary']!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '진행중',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // 서브타이틀
                    if (widget.item.subtitle?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF4A5568).withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getActivityColors() {
    switch (widget.item.type) {
      case TimelineItemType.sleep:
        return {
          'primary': const Color(0xFF8B5FBF),
          'secondary': const Color(0xFFB794F6),
        };
      case TimelineItemType.feeding:
        return {
          'primary': const Color(0xFF38A169),
          'secondary': const Color(0xFF68D391),
        };
      case TimelineItemType.diaper:
        return {
          'primary': const Color(0xFFED8936),
          'secondary': const Color(0xFFFBD38D),
        };
      case TimelineItemType.medication:
        return {
          'primary': const Color(0xFFE53E3E),
          'secondary': const Color(0xFFFC8181),
        };
      case TimelineItemType.milkPumping:
        return {
          'primary': const Color(0xFF319795),
          'secondary': const Color(0xFF81E6D9),
        };
      case TimelineItemType.solidFood:
        return {
          'primary': const Color(0xFF3182CE),
          'secondary': const Color(0xFF90CDF4),
        };
      case TimelineItemType.temperature:
        return {
          'primary': const Color(0xFFD69E2E),
          'secondary': const Color(0xFFF6E05E),
        };
      default:
        return {
          'primary': const Color(0xFF718096),
          'secondary': const Color(0xFFA0AEC0),
        };
    }
  }

  IconData _getActivityIcon() {
    switch (widget.item.type) {
      case TimelineItemType.sleep:
        return Icons.bedtime_rounded;
      case TimelineItemType.feeding:
        return Icons.water_drop_rounded;
      case TimelineItemType.diaper:
        return Icons.child_care_rounded;
      case TimelineItemType.medication:
        return Icons.medication_rounded;
      case TimelineItemType.milkPumping:
        return Icons.opacity_rounded;
      case TimelineItemType.solidFood:
        return Icons.restaurant_rounded;
      case TimelineItemType.temperature:
        return Icons.thermostat_rounded;
      default:
        return Icons.circle;
    }
  }
}