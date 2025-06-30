import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            DateFormat('HH:mm').format(widget.item.timestamp.subtract(const Duration(hours: 9))),
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
              colors: Theme.of(context).brightness == Brightness.dark ? [
                activityColors['primary']!.withOpacity(0.15),
                activityColors['secondary']!.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ] : [
                activityColors['primary']!.withOpacity(0.08),
                activityColors['secondary']!.withOpacity(0.05),
                Colors.black.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2 + _glowAnimation.value * 0.3)
                  : Colors.black.withOpacity(0.1 + _glowAnimation.value * 0.1),
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
                            _buildLocalizedTitle(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1A202C),
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
                            child: Text(
                              AppLocalizations.of(context)!.inProgress,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // 서브타이틀
                    ...[
                      const SizedBox(height: 6),
                      Text(
                        _buildLocalizedSubtitle(context),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF4A5568).withOpacity(0.8),
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

  String _buildLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.item.data;
    
    switch (widget.item.type) {
      case TimelineItemType.feeding:
        return l10n.feeding;
      case TimelineItemType.sleep:
        // 진행 중인 수면인지 확인
        final endedAt = data['ended_at'] as String?;
        return endedAt == null ? l10n.sleeping : l10n.sleep;
      case TimelineItemType.diaper:
        return l10n.diaperChange;
      case TimelineItemType.medication:
        return l10n.medication;
      case TimelineItemType.milkPumping:
        // 진행 중인 유축인지 확인
        final endedAt = data['ended_at'] as String?;
        return endedAt == null ? l10n.pumping : l10n.milkPumping;
      case TimelineItemType.solidFood:
        return l10n.solidFood;
      case TimelineItemType.temperature:
        return l10n.temperatureMeasurement;
      default:
        return widget.item.title;
    }
  }

  String _buildLocalizedSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.item.data;
    
    switch (widget.item.type) {
      case TimelineItemType.feeding:
        return _buildFeedingSubtitle(l10n, data);
      case TimelineItemType.sleep:
        return _buildSleepSubtitle(l10n, data);
      case TimelineItemType.diaper:
        return _buildDiaperSubtitle(l10n, data);
      case TimelineItemType.medication:
        return _buildMedicationSubtitle(l10n, data);
      case TimelineItemType.milkPumping:
        return _buildMilkPumpingSubtitle(l10n, data);
      case TimelineItemType.solidFood:
        return _buildSolidFoodSubtitle(l10n, data);
      case TimelineItemType.temperature:
        return _buildTemperatureSubtitle(l10n, data);
      default:
        return widget.item.subtitle ?? '';
    }
  }

  String _buildFeedingSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    String subtitle = '';
    final type = data['type'] as String?;
    
    if (type == 'bottle' || type == 'formula') {
      subtitle = l10n.formula;
      final amountMl = data['amount_ml'] as int?;
      if (amountMl != null && amountMl > 0) {
        subtitle += ' ${amountMl}ml';
      }
    } else if (type == 'breast') {
      subtitle = l10n.breastMilk;
      final durationMinutes = data['duration_minutes'] as int?;
      if (durationMinutes != null && durationMinutes > 0) {
        subtitle += ' ${durationMinutes}${l10n.minutesText}';
      }
      final side = data['side'] as String?;
      if (side != null) {
        final sideText = side == 'left' ? l10n.left : 
                        side == 'right' ? l10n.right : l10n.both;
        subtitle += ' ($sideText)';
      }
    } else if (type == 'solid') {
      subtitle = l10n.babyFood;
      final amountMl = data['amount_ml'] as int?;
      if (amountMl != null && amountMl > 0) {
        subtitle += ' ${amountMl}ml';
      }
    }
    return subtitle;
  }

  String _buildSleepSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    final endedAt = data['ended_at'] as String?;
    final startedAt = data['started_at'] as String?;
    
    if (endedAt == null && startedAt != null) {
      // 진행 중인 수면
      final start = DateTime.parse(startedAt);
      final now = DateTime.now();
      final duration = now.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${l10n.sleeping} - ${hours}${l10n.hoursText} ${minutes}${l10n.minutesText} ${l10n.elapsed}';
    } else if (endedAt != null && startedAt != null) {
      // 완료된 수면
      final start = DateTime.parse(startedAt);
      final end = DateTime.parse(endedAt);
      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      String subtitle = '${hours}${l10n.hoursText} ${minutes}${l10n.minutesText}';
      
      // 수면 품질 추가
      final quality = data['quality'] as String?;
      if (quality != null) {
        String qualityText;
        switch (quality) {
          case 'good':
            qualityText = l10n.qualityGood;
            break;
          case 'fair':
            qualityText = l10n.qualityFair;
            break;
          case 'poor':
            qualityText = l10n.qualityPoor;
            break;
          default:
            qualityText = quality;
        }
        subtitle += ' (${l10n.quality}: $qualityText)';
      }
      return subtitle;
    }
    return widget.item.subtitle ?? '';
  }

  String _buildDiaperSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    String subtitle = '';
    
    if (type == 'wet') {
      subtitle = l10n.urineOnly;
    } else if (type == 'dirty') {
      subtitle = l10n.stoolOnly;
      final color = data['color'] as String?;
      if (color != null && color.isNotEmpty) {
        subtitle += ' (${l10n.color}: $color)';
      }
      final consistency = data['consistency'] as String?;
      if (consistency != null && consistency.isNotEmpty) {
        subtitle += ' (${l10n.consistency}: $consistency)';
      }
    } else if (type == 'both') {
      subtitle = l10n.urineAndStool;
      final color = data['color'] as String?;
      if (color != null && color.isNotEmpty) {
        subtitle += ' (${l10n.color}: $color)';
      }
    }
    return subtitle;
  }

  String _buildMedicationSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    final route = data['route'] as String?;
    String subtitle = '';
    
    if (route == 'oral') {
      subtitle = l10n.oralMedication;
    } else if (route == 'topical') {
      subtitle = l10n.topical;
    } else if (route == 'inhaled') {
      subtitle = l10n.inhaled;
    } else {
      subtitle = l10n.medication;
    }

    final medicationName = data['medication_name'] as String?;
    if (medicationName != null && medicationName.isNotEmpty) {
      subtitle += ' - $medicationName';
    }

    final dosage = data['dosage'] as String?;
    if (dosage != null && dosage.isNotEmpty) {
      subtitle += ' $dosage';
      final unit = data['unit'] as String?;
      if (unit != null && unit.isNotEmpty) {
        subtitle += unit;
      }
    }
    return subtitle;
  }

  String _buildMilkPumpingSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    final endedAt = data['ended_at'] as String?;
    final startedAt = data['started_at'] as String?;
    
    if (endedAt == null && startedAt != null) {
      // 진행 중인 유축
      final start = DateTime.parse(startedAt);
      final now = DateTime.now();
      final duration = now.difference(start);
      return '${l10n.pumping} - ${duration.inMinutes}${l10n.minutesText} ${l10n.elapsed}';
    } else {
      // 완료된 유축
      String subtitle = '';
      final amountMl = data['amount_ml'] as int?;
      if (amountMl != null && amountMl > 0) {
        subtitle = '${amountMl}ml';
      }
      
      final durationMinutes = data['duration_minutes'] as int?;
      if (durationMinutes != null && durationMinutes > 0) {
        if (subtitle.isNotEmpty) subtitle += ', ';
        subtitle += '${durationMinutes}${l10n.minutesText}';
      }
      
      final side = data['side'] as String?;
      if (side != null) {
        final sideText = side == 'left' ? l10n.left :
                        side == 'right' ? l10n.right : l10n.both;
        if (subtitle.isNotEmpty) subtitle += ' ';
        subtitle += '($sideText)';
      }
      return subtitle;
    }
  }

  String _buildSolidFoodSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    String subtitle = '';
    final foodName = data['food_name'] as String?;
    if (foodName != null && foodName.isNotEmpty) {
      subtitle = foodName;
    }
    
    final amountGrams = data['amount_grams'] as int?;
    if (amountGrams != null && amountGrams > 0) {
      if (subtitle.isNotEmpty) subtitle += ' - ';
      subtitle += '${amountGrams}g';
    }
    return subtitle;
  }

  String _buildTemperatureSubtitle(AppLocalizations l10n, Map<String, dynamic> data) {
    final temperature = data['temperature'] as double?;
    if (temperature != null) {
      String subtitle = '${temperature.toStringAsFixed(1)}°C';
      
      // 온도 상태 판단
      String status;
      if (temperature >= 38.0) {
        status = ' (${l10n.fever})';
      } else if (temperature >= 37.5) {
        status = ' (${l10n.lowFever})';
      } else if (temperature < 36.0) {
        status = ' (${l10n.hypothermia})';
      } else {
        status = ' (${l10n.normal})';
      }
      subtitle += status;
      return subtitle;
    }
    
    final type = data['type'] as String?;
    return type ?? '';
  }
}