import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/baby.dart';

class BabyInfoCard extends StatelessWidget {
  final Baby baby;
  final Map<String, dynamic> feedingSummary;
  final VoidCallback? onProfileImageTap;
  
  const BabyInfoCard({
    super.key,
    required this.baby,
    required this.feedingSummary,
    this.onProfileImageTap,
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
    final feedingInterval = 240; // 4시간 = 240분
    final nextFeedingMinutes = lastFeedingMinutes >= feedingInterval 
        ? 0  // 이미 수유 시간이 지났으면 지금 수유 필요
        : feedingInterval - lastFeedingMinutes;
    final nextHours = nextFeedingMinutes ~/ 60;
    final nextMinutes = nextFeedingMinutes % 60;
    
    // 진행률 계산 (0.0 ~ 1.0)
    final progressValue = (lastFeedingMinutes / feedingInterval).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
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
              GestureDetector(
                onTap: onProfileImageTap,
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: baby.profileImageUrl != null && baby.profileImageUrl!.isNotEmpty
                            ? Image.network(
                                baby.profileImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      baby.name.isNotEmpty ? baby.name[0] : '👶',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  baby.name.isNotEmpty ? baby.name[0] : '👶',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // 편집 아이콘
                    if (onProfileImageTap != null)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 10,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
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
          
          const SizedBox(height: 16),
          
          // 마지막 수유 시간 섹션
          if (feedingSummary['lastFeedingTime'] != null) ...[
            Row(
              children: [
                // 원형 진행 인디케이터
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 원
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      // 진행 원
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 5,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressValue >= 1.0 
                                ? Colors.orange 
                                : progressValue >= 0.8 
                                    ? Colors.orange[700]! 
                                    : theme.colorScheme.primary
                          ),
                        ),
                      ),
                      // 중앙 아이콘
                      Icon(
                        Icons.local_drink,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '마지막 수유 시간',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lastFeedingText,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressValue,
                          child: Container(
                            decoration: BoxDecoration(
                              color: progressValue >= 1.0 
                                  ? Colors.orange 
                                  : progressValue >= 0.8 
                                      ? Colors.orange[700]! 
                                      : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nextFeedingMinutes == 0 
                            ? '지금 수유 시간입니다'
                            : nextFeedingMinutes < 30
                                ? '곧 수유 시간입니다 (${nextMinutes}분 후)'
                                : '약 ${nextHours > 0 ? '${nextHours}시간 ' : ''}${nextMinutes}분 후 수유 예정',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: nextFeedingMinutes == 0 
                              ? Colors.orange
                              : nextFeedingMinutes < 30 
                                  ? Colors.orange[700]
                                  : theme.colorScheme.primary,
                          fontWeight: nextFeedingMinutes <= 30 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}