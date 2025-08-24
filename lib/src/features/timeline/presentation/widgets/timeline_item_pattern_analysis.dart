import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';

class TimelineItemPatternAnalysis extends StatefulWidget {
  final TimelineItem item;

  const TimelineItemPatternAnalysis({
    super.key,
    required this.item,
  });

  @override
  State<TimelineItemPatternAnalysis> createState() => _TimelineItemPatternAnalysisState();
}

class _TimelineItemPatternAnalysisState extends State<TimelineItemPatternAnalysis>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _shimmerController;
  late Animation<double> _expandAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isExpanded = false;
  bool _isLoading = true;
  List<PatternInsight> _insights = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPatternAnalysis();
  }

  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadPatternAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 패턴 분석 로직을 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 1500));
      
      _insights = _generateMockInsights();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PatternInsight> _generateMockInsights() {
    final insights = <PatternInsight>[];
    final now = DateTime.now();
    final itemData = widget.item.data;

    switch (widget.item.type) {
      case TimelineItemType.feeding:
        // 수유: 실제 FeedingPatternAnalyzer를 사용하는 것이 이상적이지만, 여기서는 참고용 인사이트 제공
        if (itemData.containsKey('amount_ml')) {
          final amount = itemData['amount_ml'] as int?;
          if (amount != null) {
            if (amount >= 150) {
              insights.add(PatternInsight(
                type: InsightType.correlation,
                title: '충분한 양의 수유를 했어요',
                description: '이 양은 아기에게 충분한 포만감을 줄 것으로 예상돼요.',
                confidence: 0.88,
                icon: Icons.sentiment_satisfied_rounded,
                color: const Color(0xFF10B981),
              ));
            }
          }
        }
        
        // 시간별 인사이트
        final hour = widget.item.timestamp.hour;
        if (hour >= 22 || hour < 6) {
          insights.add(PatternInsight(
            type: InsightType.timing,
            title: '새벽 수유 시간이에요',
            description: '새벽 수유는 아기의 성장에 도움이 되지만, 부모의 수면 패턴에 영향을 줄 수 있어요.',
            confidence: 0.82,
            icon: Icons.nights_stay_rounded,
            color: const Color(0xFF8B5FBF),
          ));
        }
        
        insights.add(PatternInsight(
          type: InsightType.suggestion,
          title: '다음 수유 예상 시간',
          description: '일반적으로 2-3시간 후에 다음 수유가 필요할 수 있어요.',
          confidence: 0.75,
          icon: Icons.schedule_rounded,
          color: const Color(0xFF06B6D4),
        ));
        break;

      case TimelineItemType.sleep:
        if (itemData.containsKey('duration_minutes')) {
          final duration = itemData['duration_minutes'] as int?;
          if (duration != null) {
            if (duration >= 180) { // 3시간 이상
              insights.add(PatternInsight(
                type: InsightType.duration,
                title: '긴 시간 잔 수면이었어요',
                description: '${(duration / 60).toStringAsFixed(1)}시간 동안 잤어요. 이는 아기의 성장과 발달에 좋은 신호에요.',
                confidence: 0.92,
                icon: Icons.bedtime_rounded,
                color: const Color(0xFF10B981),
              ));
            } else if (duration < 60) { // 1시간 미만
              insights.add(PatternInsight(
                type: InsightType.quality,
                title: '짧은 수면이었어요',
                description: '짧은 낮잠이나 깨지 않을 수 있도록 환경을 체크해보세요.',
                confidence: 0.78,
                icon: Icons.timer_rounded,
                color: const Color(0xFFFFB020),
              ));
            }
          }
        }
        
        // 수면 품질 인사이트
        if (itemData.containsKey('quality')) {
          final quality = itemData['quality'] as String?;
          if (quality == 'good') {
            insights.add(PatternInsight(
              type: InsightType.quality,
              title: '좋은 수면 품질이었어요',
              description: '좋은 수면은 아기의 뇌 발달과 면역력 향상에 도움이 돼요.',
              confidence: 0.85,
              icon: Icons.sentiment_very_satisfied_rounded,
              color: const Color(0xFF10B981),
            ));
          }
        }
        break;

      case TimelineItemType.diaper:
        final diaperType = itemData['type'] as String?;
        final timeSinceChange = now.difference(widget.item.timestamp);
        
        if (diaperType == 'dirty') {
          insights.add(PatternInsight(
            type: InsightType.general,
            title: '배변 기저귀 교체',
            description: '아기의 소화 기능이 정상적으로 작동하고 있는 좋은 신호에요.',
            confidence: 0.87,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
          ));
        }
        
        if (timeSinceChange.inHours >= 2) {
          insights.add(PatternInsight(
            type: InsightType.frequency,
            title: '기저귀 교체 주기',
            description: '마지막 교체 후 ${timeSinceChange.inHours}시간이 지났어요. 좋은 교체 주기를 유지하고 있어요.',
            confidence: 0.80,
            icon: Icons.timer_rounded,
            color: const Color(0xFF06B6D4),
          ));
        }
        break;

      case TimelineItemType.medication:
        final medicationName = itemData['medication_name'] as String?;
        final dosage = itemData['dosage'] as String?;
        
        insights.add(PatternInsight(
          type: InsightType.timing,
          title: '투약 기록 완료',
          description: medicationName != null 
              ? '$medicationName 투약이 기록되었어요. 정확한 기록은 치료 효과를 높이는 데 도움이 돼요.'
              : '투약 기록이 완료되었어요.',
          confidence: 0.95,
          icon: Icons.medication_rounded,
          color: const Color(0xFFEF4444),
        ));
        
        // 시간별 인사이트
        final medicationHour = widget.item.timestamp.hour;
        if (medicationHour >= 8 && medicationHour <= 10) {
          insights.add(PatternInsight(
            type: InsightType.suggestion,
            title: '아침 투약 시간',
            description: '아침 시간대의 투약은 하루 종일 약물 효과를 유지하는 데 도움이 돼요.',
            confidence: 0.82,
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFF06B6D4),
          ));
        }
        break;

      case TimelineItemType.milkPumping:
        if (itemData.containsKey('amount_ml')) {
          final amount = itemData['amount_ml'] as int?;
          if (amount != null) {
            if (amount >= 100) {
              insights.add(PatternInsight(
                type: InsightType.correlation,
                title: '효과적인 유축이었어요',
                description: '${amount}ml를 유축했어요. 이는 좋은 양으로 모유 저장에 도움이 돼요.',
                confidence: 0.88,
                icon: Icons.local_drink_rounded,
                color: const Color(0xFF06B6D4),
              ));
            } else if (amount < 50) {
              insights.add(PatternInsight(
                type: InsightType.suggestion,
                title: '유축량 개선 팁',
                description: '유축량이 적어요. 충분한 수분 섭취와 스트레스 관리가 도움이 될 수 있어요.',
                confidence: 0.75,
                icon: Icons.tips_and_updates_rounded,
                color: const Color(0xFFFFB020),
              ));
            }
          }
        }
        
        // 유축 시간대 분석
        final pumpingHour = widget.item.timestamp.hour;
        if (pumpingHour >= 6 && pumpingHour <= 10) {
          insights.add(PatternInsight(
            type: InsightType.timing,
            title: '아침 유축 시간',
            description: '아침 시간대는 프롬랙틴 수치가 높아 유축에 가장 좋은 시간이에요.',
            confidence: 0.90,
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFF10B981),
          ));
        }
        break;

      case TimelineItemType.solidFood:
        final foodName = itemData['food_name'] as String?;
        final reaction = itemData['reaction'] as String?;
        
        if (reaction == 'good' || reaction == '좋음') {
          insights.add(PatternInsight(
            type: InsightType.quality,
            title: '아기가 음식을 좋아해요',
            description: foodName != null 
                ? '$foodName에 대한 반응이 좋았어요. 이 음식을 식단에 추가해보세요.'
                : '음식에 대한 반응이 좋았어요.',
            confidence: 0.85,
            icon: Icons.sentiment_very_satisfied_rounded,
            color: const Color(0xFF10B981),
          ));
        }
        
        // 이유식 시간대 분석
        final foodHour = widget.item.timestamp.hour;
        if (foodHour >= 12 && foodHour <= 13) {
          insights.add(PatternInsight(
            type: InsightType.timing,
            title: '점심 시간 이유식',
            description: '점심 시간대 이유식은 아기의 식습관 형성에 도움이 돼요.',
            confidence: 0.80,
            icon: Icons.restaurant_rounded,
            color: const Color(0xFF10B981),
          ));
        }
        
        insights.add(PatternInsight(
          type: InsightType.suggestion,
          title: '영양 균형 관리',
          description: '다양한 재료로 만든 이유식을 번갈아 주면 영양 균형에 도움이 돼요.',
          confidence: 0.75,
          icon: Icons.balance_rounded,
          color: const Color(0xFF06B6D4),
        ));
        break;

      case TimelineItemType.temperature:
        if (itemData.containsKey('temperature')) {
          final temperature = itemData['temperature'] as double?;
          if (temperature != null) {
            if (temperature >= 37.5) {
              insights.add(PatternInsight(
                type: InsightType.general,
                title: '체온이 높아요',
                description: '체온이 ${temperature}°C로 비교적 높습니다. 지속적인 관찰이 필요해요.',
                confidence: 0.92,
                icon: Icons.thermostat_rounded,
                color: const Color(0xFFEF4444),
              ));
            } else if (temperature <= 36.0) {
              insights.add(PatternInsight(
                type: InsightType.general,
                title: '체온이 낮아요',
                description: '체온이 ${temperature}°C로 비교적 낮습니다. 보온에 주의해주세요.',
                confidence: 0.88,
                icon: Icons.ac_unit_rounded,
                color: const Color(0xFF06B6D4),
              ));
            } else {
              insights.add(PatternInsight(
                type: InsightType.quality,
                title: '정상 인 체온입니다',
                description: '체온이 ${temperature}°C로 정상 범위내에 있어요.',
                confidence: 0.95,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
              ));
            }
          }
        }
        
        insights.add(PatternInsight(
          type: InsightType.suggestion,
          title: '정기적인 체온 체크',
          description: '아기의 건강 상태를 파악하기 위해 정기적인 체온 체크를 권장해요.',
          confidence: 0.80,
          icon: Icons.health_and_safety_rounded,
          color: const Color(0xFF10B981),
        ));
        break;

      default:
        insights.add(
          PatternInsight(
            type: InsightType.general,
            title: '기록이 꾸준히 잘 되고 있어요',
            description: '정기적인 기록은 아기 건강 관리에 도움이 돼요.',
            confidence: 0.75,
            icon: Icons.favorite_rounded,
            color: const Color(0xFFEC4899),
          ),
        );
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(theme, localizations),
          
          // 콘텐츠
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? _expandAnimation.value : 0.0,
                  child: child,
                ),
              );
            },
            child: _buildContent(theme, localizations),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
        bottom: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.smartInsights,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLoading 
                        ? localizations.analyzingPatterns
                        : localizations.insightsFound(_insights.length),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // 로딩 또는 확장 아이콘
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            else
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations localizations) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_insights.isEmpty) {
      return _buildEmptyState(theme, localizations);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          ..._insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _insights.length - 1 ? 16 : 0,
              ),
              child: _buildInsightCard(insight, theme, localizations),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...List.generate(2, (index) => _buildShimmerCard(theme)),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: [
                          _shimmerAnimation.value - 0.3,
                          _shimmerAnimation.value,
                          _shimmerAnimation.value + 0.3,
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

  Widget _buildEmptyState(ThemeData theme, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.noInsightsYet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInsightCard(PatternInsight insight, ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight.icon,
                  size: 16,
                  color: insight.color,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              // 신뢰도 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(insight.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(insight.confidence * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getConfidenceColor(insight.confidence),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            insight.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 신뢰도 바
          Row(
            children: [
              Text(
                localizations.confidence,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: insight.confidence,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getConfidenceColor(insight.confidence),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return const Color(0xFF10B981); // Green
    } else if (confidence >= 0.6) {
      return const Color(0xFFFFB020); // Orange
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }
}

// 패턴 인사이트 모델
class PatternInsight {
  final InsightType type;
  final String title;
  final String description;
  final double confidence; // 0.0 ~ 1.0
  final IconData icon;
  final Color color;

  const PatternInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.icon,
    required this.color,
  });
}

enum InsightType {
  timing,      // 시간 관련
  frequency,   // 빈도 관련
  duration,    // 지속시간 관련
  correlation, // 상관관계
  quality,     // 품질 관련
  suggestion,  // 제안
  general,     // 일반
}