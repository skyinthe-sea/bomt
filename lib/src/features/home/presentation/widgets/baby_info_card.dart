import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/baby.dart';

class BabyInfoCard extends StatelessWidget {
  final Baby baby;
  final Map<String, dynamic> feedingSummary;
  
  const BabyInfoCard({
    super.key,
    required this.baby,
    required this.feedingSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // 마지막 수유 시간 계산
    final lastFeedingMinutes = feedingSummary['lastFeedingMinutesAgo'] ?? 0;
    final hours = lastFeedingMinutes ~/ 60;
    final minutes = lastFeedingMinutes % 60;
    final lastFeedingText = hours > 0 
        ? '${hours}시간 ${minutes}분 전' 
        : '${minutes}분 전';
    
    // 다음 수유 예정 시간 (약 4시간 주기로 가정)
    final nextFeedingMinutes = (240 - lastFeedingMinutes).clamp(0, 240);
    final nextHours = nextFeedingMinutes ~/ 60;
    final nextMinutes = nextFeedingMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아기 정보 상단
          Row(
            children: [
              // 아기 아바타
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    baby.name.isNotEmpty ? baby.name[0] : '👶',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 아기 이름과 나이
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baby.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          baby.ageInMonthsAndDays,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.healthy,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 마지막 수유 시간
          if (feedingSummary['lastFeedingTime'] != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.baby_changing_station,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.lastFeeding,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastFeedingText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 진행바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: lastFeedingMinutes / 240, // 4시간 기준
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '약 ${nextHours}시간 ${nextMinutes}분 후 수유 예정',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}