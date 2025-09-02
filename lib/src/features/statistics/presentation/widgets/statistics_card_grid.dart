import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/statistics.dart';

class StatisticsCardGrid extends StatelessWidget {
  final List<CardStatistics> cardStatistics;

  const StatisticsCardGrid({
    super.key,
    required this.cardStatistics,
  });

  @override
  Widget build(BuildContext context) {
    if (cardStatistics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSectionHeader(context),
          ),
          
          // 카드 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9, // 카드 높이를 더 늘려서 오버플로 방지
            ),
            itemCount: cardStatistics.length,
            itemBuilder: (context, index) {
              return _StatisticsCard(
                cardStatistics: cardStatistics[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Icon(
          Icons.grid_view_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.detailedStatistics,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          l10n.itemsCount(cardStatistics.length),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final CardStatistics cardStatistics;
  final int index;

  const _StatisticsCard({
    required this.cardStatistics,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getCardColor(cardStatistics.cardType, theme);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: cardColor.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12), // 패딩 더 줄임
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCardIcon(cardStatistics.cardType),
                          color: cardColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getLocalizedCardName(context, cardStatistics.cardType),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8), // 간격 더 줄임
                  
                  // 총 횟수
                  _buildMainMetric(context, theme, cardColor),
                  
                  const SizedBox(height: 6), // 간격 더 줄임
                  
                  // 주요 메트릭들
                  Expanded(
                    child: _buildKeyMetrics(context, theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetric(BuildContext context, ThemeData theme, Color cardColor) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.totalCount} ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  TextSpan(
                    text: l10n.timesCount(cardStatistics.totalCount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: cardColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final keyMetrics = _getKeyMetrics(context);
    
    if (keyMetrics.isEmpty) {
      return Center(
        child: Text(
          l10n.noDetailedData,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keyMetrics.map((metric) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 2), // 간격 더 줄임
          child: _buildMetricRow(context, theme, metric),
        ),
      ).toList(),
    );
  }

  Widget _buildMetricRow(BuildContext context, ThemeData theme, StatisticsMetric metric) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getTranslatedMetricLabel(context, metric.label),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 11, // 폰트 크기 축소
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          metric.valueWithUnit,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 11, // 폰트 크기 축소
          ),
        ),
      ],
    );
  }

  String _getTranslatedMetricLabel(BuildContext context, String originalLabel) {
    final l10n = AppLocalizations.of(context)!;
    
    // 기존 한국어와 영어 라벨을 i18n으로 변환
    switch (originalLabel) {
      // 수유 관련 (한국어)
      case '평균 수유량':
        return l10n.averageFeedingAmount;
      case '평균 수유 시간':
        return l10n.averageFeedingDuration;
      case '하루 평균 수유 횟수':
        return l10n.dailyAverageFeedingCount;
      
      // 수유 관련 (영어)
      case 'Average feeding amount':
        return l10n.averageFeedingAmount;
      case 'Average feeding duration':
        return l10n.averageFeedingDuration;
      case 'Daily average feeding count':
        return l10n.dailyAverageFeedingCount;
      
      // 수면 관련 (한국어)
      case '평균 수면 시간':
        return l10n.averageSleepDuration;
      case '하루 평균 총 수면 시간':
        return l10n.dailyTotalSleepDuration;
      case '하루 평균 수면 횟수':
        return l10n.dailyAverageSleepCount;
      
      // 수면 관련 (영어)
      case 'Average sleep duration':
        return l10n.averageSleepDuration;
      case 'Daily total sleep duration':
      case 'Daily average total sleep time':
        return l10n.dailyTotalSleepDuration;
      case 'Daily average sleep count':
        return l10n.dailyAverageSleepCount;
      
      // 기저귀 관련 (한국어)
      case '하루 평균 교체 횟수':
        return l10n.dailyAverageDiaperChangeCount;
      
      // 기저귀 관련 (영어)
      case 'Daily average diaper change count':
      case 'Daily average change count':
        return l10n.dailyAverageDiaperChangeCount;
      
      // 투약 관련 (한국어)
      case '하루 평균 투약 횟수':
        return l10n.dailyAverageMedicationCount;
      case '사용한 약물 종류':
        return l10n.medicationTypesUsed;
      
      // 투약 관련 (영어)
      case 'Daily average medication count':
        return l10n.dailyAverageMedicationCount;
      case 'Types of medication used':
      case 'Medication types used':
        return l10n.medicationTypesUsed;
      
      // 유축 관련 (한국어)
      case '총 유축량':
        return l10n.totalPumpedAmount;
      case '평균 유축량':
        return l10n.averagePumpedAmount;
      
      // 유축 관련 (영어)
      case 'Total pumped amount':
        return l10n.totalPumpedAmount;
      case 'Average pumped amount':
        return l10n.averagePumpedAmount;
      
      // 이유식 관련 (한국어)
      case '하루 평균 이유식 횟수':
        return l10n.dailyAverageSolidFoodCount;
      case '시도한 음식 종류':
        return l10n.triedFoodTypes;
      
      // 이유식 관련 (영어)
      case 'Daily average solid food count':
        return l10n.dailyAverageSolidFoodCount;
      case 'Types of food tried':
      case 'Tried food types':
        return l10n.triedFoodTypes;
      
      // 기본값: 원래 라벨 반환 (번역이 없는 경우)
      default:
        return originalLabel;
    }
  }

  List<StatisticsMetric> _getKeyMetrics(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allMetrics = cardStatistics.metrics;
    
    switch (cardStatistics.cardType) {
      case 'feeding':
        return allMetrics.where((m) => 
          m.label == l10n.averageFeedingAmount || 
          m.label == l10n.averageFeedingDuration ||
          m.label == l10n.dailyAverageFeedingCount ||
          m.label == '평균 수유량' ||
          m.label == '평균 수유 시간' ||
          m.label == '하루 평균 수유 횟수'
        ).take(2).toList();
      case 'sleep':
        return allMetrics.where((m) => 
          m.label == l10n.averageSleepDuration || 
          m.label == l10n.dailyTotalSleepDuration ||
          m.label == l10n.dailyAverageSleepCount ||
          m.label == '평균 수면 시간' ||
          m.label == '하루 평균 총 수면 시간' ||
          m.label == '하루 평균 수면 횟수'
        ).take(2).toList();
      case 'diaper':
        return allMetrics.where((m) => 
          m.label == l10n.dailyAverageDiaperChangeCount ||
          m.label == '하루 평균 교체 횟수'
        ).take(1).toList();
      case 'medication':
        return allMetrics.where((m) => 
          m.label == l10n.dailyAverageMedicationCount ||
          m.label == l10n.medicationTypesUsed ||
          m.label == '하루 평균 투약 횟수' ||
          m.label == '사용한 약물 종류'
        ).take(2).toList();
      case 'milk_pumping':
        return allMetrics.where((m) => 
          m.label == l10n.totalPumpedAmount ||
          m.label == l10n.averagePumpedAmount ||
          m.label == '총 유축량' ||
          m.label == '평균 유축량'
        ).take(2).toList();
      case 'solid_food':
        return allMetrics.where((m) => 
          m.label == l10n.dailyAverageSolidFoodCount ||
          m.label == l10n.triedFoodTypes ||
          m.label == '하루 평균 이유식 횟수' ||
          m.label == '시도한 음식 종류'
        ).take(2).toList();
      default:
        return allMetrics.take(2).toList();
    }
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _StatisticsDetailDialog(
        cardStatistics: cardStatistics,
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'diaper':
        return Icons.child_care_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'milk_pumping':
        return Icons.water_drop_rounded;
      case 'solid_food':
        return Icons.restaurant_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  Color _getCardColor(String cardType, ThemeData theme) {
    switch (cardType) {
      case 'feeding':
        return Colors.blue;
      case 'sleep':
        return Colors.indigo;
      case 'diaper':
        return Colors.orange;
      case 'medication':
        return Colors.red;
      case 'milk_pumping':
        return Colors.cyan;
      case 'solid_food':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getLocalizedCardName(BuildContext context, String cardType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (cardType) {
      case 'feeding':
        return l10n.feeding;
      case 'sleep':
        return l10n.sleep;
      case 'diaper':
        return l10n.diaper;
      case 'medication':
        return l10n.medication;
      case 'milk_pumping':
        return l10n.milkPumping;
      case 'solid_food':
        return l10n.solidFood;
      default:
        return cardType; // fallback to cardType if no translation found
    }
  }
}

class _StatisticsDetailDialog extends StatelessWidget {
  final CardStatistics cardStatistics;

  const _StatisticsDetailDialog({
    required this.cardStatistics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cardColor = _getCardColor(cardStatistics.cardType, theme);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCardIcon(cardStatistics.cardType),
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedCardName(context, cardStatistics.cardType),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          l10n.detailedStatistics,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // 메트릭 목록
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: cardStatistics.metrics.map((metric) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslatedMetricLabel(context, metric.label),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                if (metric.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    metric.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            metric.valueWithUnit,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'diaper':
        return Icons.child_care_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'milk_pumping':
        return Icons.water_drop_rounded;
      case 'solid_food':
        return Icons.restaurant_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  Color _getCardColor(String cardType, ThemeData theme) {
    switch (cardType) {
      case 'feeding':
        return Colors.blue;
      case 'sleep':
        return Colors.indigo;
      case 'diaper':
        return Colors.orange;
      case 'medication':
        return Colors.red;
      case 'milk_pumping':
        return Colors.cyan;
      case 'solid_food':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getLocalizedCardName(BuildContext context, String cardType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (cardType) {
      case 'feeding':
        return l10n.feeding;
      case 'sleep':
        return l10n.sleep;
      case 'diaper':
        return l10n.diaper;
      case 'medication':
        return l10n.medication;
      case 'milk_pumping':
        return l10n.milkPumping;
      case 'solid_food':
        return l10n.solidFood;
      default:
        return cardType; // fallback to cardType if no translation found
    }
  }

  String _getTranslatedMetricLabel(BuildContext context, String originalLabel) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (originalLabel) {
      // 수유 관련 (한국어)
      case '평균 수유량':
        return l10n.averageFeedingAmount;
      case '평균 수유 시간':
        return l10n.averageFeedingDuration;
      case '하루 평균 수유 횟수':
        return l10n.dailyAverageFeedingCount;
      
      // 수유 관련 (영어)
      case 'Average feeding amount':
        return l10n.averageFeedingAmount;
      case 'Average feeding duration':
        return l10n.averageFeedingDuration;
      case 'Daily average feeding count':
        return l10n.dailyAverageFeedingCount;
      
      // 수면 관련 (한국어)
      case '평균 수면 시간':
        return l10n.averageSleepDuration;
      case '하루 평균 총 수면 시간':
        return l10n.dailyTotalSleepDuration;
      case '하루 평균 수면 횟수':
        return l10n.dailyAverageSleepCount;
      
      // 수면 관련 (영어)
      case 'Average sleep duration':
        return l10n.averageSleepDuration;
      case 'Daily total sleep duration':
      case 'Daily average total sleep time':
        return l10n.dailyTotalSleepDuration;
      case 'Daily average sleep count':
        return l10n.dailyAverageSleepCount;
      
      // 기저귀 관련 (한국어)
      case '하루 평균 교체 횟수':
        return l10n.dailyAverageDiaperChangeCount;
      
      // 기저귀 관련 (영어)
      case 'Daily average diaper change count':
      case 'Daily average change count':
        return l10n.dailyAverageDiaperChangeCount;
      
      // 투약 관련 (한국어)
      case '하루 평균 투약 횟수':
        return l10n.dailyAverageMedicationCount;
      case '사용한 약물 종류':
        return l10n.medicationTypesUsed;
      
      // 투약 관련 (영어)
      case 'Daily average medication count':
        return l10n.dailyAverageMedicationCount;
      case 'Types of medication used':
      case 'Medication types used':
        return l10n.medicationTypesUsed;
      
      // 유축 관련 (한국어)
      case '총 유축량':
        return l10n.totalPumpedAmount;
      case '평균 유축량':
        return l10n.averagePumpedAmount;
      
      // 유축 관련 (영어)
      case 'Total pumped amount':
        return l10n.totalPumpedAmount;
      case 'Average pumped amount':
        return l10n.averagePumpedAmount;
      
      // 이유식 관련 (한국어)
      case '하루 평균 이유식 횟수':
        return l10n.dailyAverageSolidFoodCount;
      case '시도한 음식 종류':
        return l10n.triedFoodTypes;
      
      // 이유식 관련 (영어)
      case 'Daily average solid food count':
        return l10n.dailyAverageSolidFoodCount;
      case 'Types of food tried':
      case 'Tried food types':
        return l10n.triedFoodTypes;
      
      default:
        return originalLabel;
    }
  }
}