import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/statistics_provider.dart';

class StatisticsHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const StatisticsHeader({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 타이틀 섹션
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '통계',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<StatisticsProvider>(
                      builder: (context, provider, child) {
                        if (provider.statistics != null) {
                          return Text(
                            '${provider.dateRange.label} • ${provider.statistics!.totalActivities}개 활동',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          );
                        }
                        return Text(
                          provider.dateRange.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // 액션 버튼들
              Row(
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.refresh_rounded,
                    onPressed: onRefresh,
                    tooltip: '새로고침',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context: context,
                    icon: Icons.share_rounded,
                    onPressed: () => _showShareOptions(context),
                    tooltip: '공유',
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 새로고침 상태 표시
          Consumer<StatisticsProvider>(
            builder: (context, provider, child) {
              if (provider.isRefreshing) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '업데이트 중...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (provider.statistics != null) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.update_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '마지막 업데이트: ${_formatLastUpdated(provider.statistics!.lastUpdated)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '통계 공유',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.image_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text('이미지로 저장'),
              subtitle: const Text('통계를 이미지로 저장합니다'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 이미지 저장 구현
              },
            ),
            ListTile(
              leading: Icon(
                Icons.text_snippet_rounded,
                color: theme.colorScheme.secondary,
              ),
              title: const Text('텍스트로 공유'),
              subtitle: const Text('통계 요약을 텍스트로 공유합니다'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 텍스트 공유 구현
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}