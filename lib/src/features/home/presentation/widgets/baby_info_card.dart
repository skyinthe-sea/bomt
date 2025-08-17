import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/baby.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../health/presentation/screens/temperature_input_screen.dart';

class BabyInfoCard extends StatefulWidget {
  final Baby baby;
  final Map<String, dynamic> feedingSummary;
  final SleepProvider? sleepProvider;
  final VoidCallback? onProfileImageTap;
  
  const BabyInfoCard({
    super.key,
    required this.baby,
    required this.feedingSummary,
    this.sleepProvider,
    this.onProfileImageTap,
  });

  @override
  State<BabyInfoCard> createState() => _BabyInfoCardState();
}

class _BabyInfoCardState extends State<BabyInfoCard> {
  Timer? _timer;
  int _elapsedMinutes = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateElapsedTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateElapsedTime();
      }
    });
  }

  void _updateElapsedTime() {
    if (widget.sleepProvider?.hasActiveSleep == true) {
      final activeSleep = widget.sleepProvider?.currentActiveSleep;
      if (activeSleep?.startedAt != null) {
        final now = DateTime.now();
        // UTC 시간을 로컬 시간으로 변환하여 계산
        final startedAtLocal = activeSleep!.startedAt.toLocal();
        final elapsed = now.difference(startedAtLocal);
        setState(() {
          _elapsedMinutes = elapsed.inMinutes.abs(); // 음수 방지
        });
        debugPrint('Sleep elapsed: ${elapsed.inMinutes} minutes (started: $startedAtLocal, now: $now)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate last feeding time or sleep elapsed time - display in minutes only
    final lastFeedingMinutes = widget.feedingSummary['lastFeedingMinutesAgo'] ?? 0;
    final isActiveSleep = widget.sleepProvider?.hasActiveSleep ?? false;
    
    // Show sleep elapsed time if sleep is active, otherwise show last feeding time
    final displayText = isActiveSleep 
        ? '${_elapsedMinutes}분 진행 중'
        : l10n.minutesAgo(lastFeedingMinutes);
    
    // 다음 수유까지 남은 시간 (알람 서비스에서 제공)
    final minutesUntilNextFeeding = widget.feedingSummary['minutesUntilNextFeeding'];
    final nextFeedingTime = widget.feedingSummary['nextFeedingTime'];
    
    // 아기 나이별 표준 수유 간격 (의학 가이드라인)
    final babyAgeInDays = widget.baby.ageInDays; 
    final standardFeedingInterval = babyAgeInDays <= 30 
        ? 150  // 신생아: 2.5시간
        : babyAgeInDays <= 180 
            ? 180  // 영아: 3시간
            : 240; // 6개월 이상: 4시간
    
    int nextFeedingMinutes;
    int nextHours;
    int nextMinutes;
    double progressValue;
    
    if (minutesUntilNextFeeding != null && minutesUntilNextFeeding >= 0) {
      // 알람 서비스에서 제공하는 실제 다음 수유까지 남은 시간 사용
      nextFeedingMinutes = minutesUntilNextFeeding;
      nextHours = nextFeedingMinutes ~/ 60;
      nextMinutes = nextFeedingMinutes % 60;
      
      // 진행률은 마지막 수유부터 다음 수유까지의 총 시간 대비 경과 시간
      final totalIntervalMinutes = lastFeedingMinutes + nextFeedingMinutes;
      progressValue = totalIntervalMinutes > 0 
          ? (lastFeedingMinutes / totalIntervalMinutes).clamp(0.0, 1.0)
          : 0.0;
    } else {
      // 표준 가이드라인 기반 기본 로직 사용
      nextFeedingMinutes = lastFeedingMinutes >= standardFeedingInterval 
          ? 0  // 이미 수유 시간이 지났으면 지금 수유 필요
          : (standardFeedingInterval - lastFeedingMinutes).round();
      nextHours = nextFeedingMinutes ~/ 60;
      nextMinutes = nextFeedingMinutes % 60;
      progressValue = (lastFeedingMinutes / standardFeedingInterval).clamp(0.0, 1.0);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
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
                      onTap: widget.onProfileImageTap,
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
                              child: widget.baby.profileImageUrl != null && widget.baby.profileImageUrl!.isNotEmpty
                                  ? Image.network(
                                      widget.baby.profileImageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            widget.baby.name.isNotEmpty ? widget.baby.name[0] : '👶',
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
                                        widget.baby.name.isNotEmpty ? widget.baby.name[0] : '👶',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          // 편집 아이콘
                          if (widget.onProfileImageTap != null)
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
                            widget.baby.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  final age = widget.baby.ageMonthsAndDays;
                                  return Text(
                                    l10n.ageMonthsAndDays(age['days']!, age['months']!),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  );
                                },
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
                    // 체온 체크 버튼
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TemperatureInputScreen(baby: widget.baby),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.thermostat,
                              color: Colors.red[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 마지막 수유 시간 또는 수면 진행 시간 섹션
                if (widget.feedingSummary['lastFeedingTime'] != null || isActiveSleep) ...[
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
                              isActiveSleep ? Icons.bedtime : Icons.local_drink,
                              color: isActiveSleep ? Colors.purple : theme.colorScheme.primary,
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
                              isActiveSleep ? '수면 진행 시간' : l10n.lastFeedingTime,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              displayText,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 표준 가이드라인 기반 메시지
                                Text(
                                  _buildNextFeedingText(l10n, minutesUntilNextFeeding, nextFeedingMinutes, nextHours, nextMinutes),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: nextFeedingMinutes == 0 
                                        ? Colors.orange
                                        : nextFeedingMinutes < 30 
                                            ? Colors.orange[700]
                                            : theme.colorScheme.primary,
                                    fontWeight: nextFeedingMinutes <= 30 ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                // 개인 패턴 정보 및 경고 (있는 경우)
                                ..._buildPersonalPatternInfo(theme, l10n),
                              ],
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
  
  List<Widget> _buildPersonalPatternInfo(ThemeData theme, AppLocalizations l10n) {
    final personalPattern = widget.feedingSummary['personalPattern'] as Map<String, dynamic>?;
    
    if (personalPattern == null) {
      return [];
    }
    
    final List<Widget> widgets = [];
    
    // 개인 패턴 정보 표시 (참고용)
    final intervalMinutes = personalPattern['intervalMinutes'] as int?;
    if (intervalMinutes != null) {
      final hours = intervalMinutes ~/ 60;
      final minutes = intervalMinutes % 60;
      final intervalText = hours > 0 
          ? '${hours}시간 ${minutes}분'
          : '${minutes}분';
      
      widgets.add(
        const SizedBox(height: 2),
      );
      widgets.add(
        Text(
          '개인 패턴: ${intervalText} 간격 (참고용)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      );
    }
    
    // 경고 메시지 표시
    final status = personalPattern['status'] as String?;
    final warning = personalPattern['warning'] as String?;
    
    if (status != 'normal' && warning != null) {
      widgets.add(
        const SizedBox(height: 3),
      );
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: status == 'too_frequent' 
                ? Colors.orange.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: status == 'too_frequent' 
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'too_frequent' 
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline,
                size: 10,
                color: status == 'too_frequent' 
                    ? Colors.orange[700]
                    : Colors.blue[700],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status == 'too_frequent' 
                        ? Colors.orange[700]
                        : Colors.blue[700],
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }
  
  String _buildNextFeedingText(AppLocalizations l10n, int? minutesUntilNextFeeding, int nextFeedingMinutes, int nextHours, int nextMinutes) {
    // 표준 가이드라인 기반 메시지 우선
    final nextFeedingMessage = widget.feedingSummary['nextFeedingMessage'] as String?;
    
    if (nextFeedingMessage != null) {
      switch (nextFeedingMessage) {
        case 'feeding_time_now':
          return '표준 수유 시간입니다';
        case 'feeding_time_soon':
          return '곧 표준 수유 시간입니다 (${nextMinutes}분 후)';
        case 'standard_schedule':
          return nextHours > 0 
              ? '표준 수유까지 ${nextHours}시간 ${nextMinutes}분'
              : '표준 수유까지 ${nextMinutes}분';
        case 'insufficient_feeding_records':
          return '수유 기록이 부족합니다 (표준 간격 적용)';
        case 'feeding_overdue':
          return '표준 수유 시간이 지났습니다';
        case 'no_recent_feeding':
          return '최근 수유 기록이 없습니다';
        default:
          break;
      }
    }
    
    // 기본 표준 가이드라인 메시지
    if (minutesUntilNextFeeding != null) {
      if (nextFeedingMinutes <= 0) {
        return '표준 수유 시간입니다';
      } else if (nextFeedingMinutes < 30) {
        return '곧 표준 수유 시간입니다 (${nextMinutes}분 후)';
      } else {
        return nextHours > 0 
            ? '표준 수유까지 ${nextHours}시간 ${nextMinutes}분'
            : '표준 수유까지 ${nextMinutes}분';
      }
    } else {
      return '표준 수유 간격을 확인하세요';
    }
  }
}