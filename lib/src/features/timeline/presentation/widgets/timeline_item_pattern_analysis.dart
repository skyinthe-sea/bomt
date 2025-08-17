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

    switch (widget.item.type) {
      case TimelineItemType.feeding:
        insights.addAll([
          PatternInsight(
            type: InsightType.timing,
            title: '평소보다 30분 일찍 수유했어요',
            description: '일반적으로 이 시간대보다 늦게 수유하시는 편이에요.',
            confidence: 0.85,
            icon: Icons.schedule_rounded,
            color: const Color(0xFF10B981),
          ),
          PatternInsight(
            type: InsightType.correlation,
            title: '이 수유 후 평균 2시간 잘 잤어요',
            description: '지난 7일간 이 시간대 수유 후 수면 패턴을 분석했어요.',
            confidence: 0.78,
            icon: Icons.bedtime_rounded,
            color: const Color(0xFF8B5FBF),
          ),
          PatternInsight(
            type: InsightType.suggestion,
            title: '다음 수유는 3시간 후 예상돼요',
            description: '평균 수유 간격을 기준으로 한 예측이에요.',
            confidence: 0.72,
            icon: Icons.alarm_rounded,
            color: const Color(0xFF06B6D4),
          ),
        ]);
        break;

      case TimelineItemType.sleep:
        insights.addAll([
          PatternInsight(
            type: InsightType.duration,
            title: '평소보다 40분 더 오래 잤어요',
            description: '지난 주 평균 수면 시간보다 길었어요.',
            confidence: 0.89,
            icon: Icons.timer_rounded,
            color: const Color(0xFF8B5FBF),
          ),
          PatternInsight(
            type: InsightType.quality,
            title: '밤 수면 품질이 개선되고 있어요',
            description: '지난 3일간 야간 깨는 횟수가 줄어들었어요.',
            confidence: 0.82,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF10B981),
          ),
        ]);
        break;

      case TimelineItemType.diaper:
        insights.addAll([
          PatternInsight(
            type: InsightType.frequency,
            title: '기저귀 교체 주기가 규칙적이에요',
            description: '최근 3일간 2-3시간 간격으로 교체하고 있어요.',
            confidence: 0.91,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
          ),
        ]);
        break;

      case TimelineItemType.medication:
        insights.addAll([
          PatternInsight(
            type: InsightType.timing,
            title: '약 복용 시간이 일정해요',
            description: '매일 비슷한 시간에 복용하고 있어요.',
            confidence: 0.94,
            icon: Icons.medication_rounded,
            color: const Color(0xFFEF4444),
          ),
        ]);
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