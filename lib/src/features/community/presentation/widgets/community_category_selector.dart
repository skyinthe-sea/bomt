import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../presentation/providers/community_provider.dart';

class CommunityCategorySelector extends StatelessWidget {
  final CommunityCategory? selectedCategory;
  final Function(CommunityCategory) onCategorySelected;

  const CommunityCategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  // 카테고리 이름 현지화 함수
  String _getLocalizedCategoryName(AppLocalizations l10n, CommunityCategory category) {
    switch (category.slug) {
      case 'all':
        return l10n.categoryAll;
      case 'popular':
        return l10n.categoryPopular;
      default:
        // 한국어 카테고리 이름을 기반으로 현지화
        switch (category.name) {
          case '임상':
            return l10n.categoryClinical;
          case '정보공유':
            return l10n.categoryInfoSharing;
          case '수면문제':
            return l10n.categorySleepIssues;
          case '이유식':
            return l10n.categoryBabyFood;
          case '발달단계':
            return l10n.categoryDevelopment;
          case '예방접종':
            return l10n.categoryVaccination;
          case '산후회복':
            return l10n.categoryPostpartum;
          case '일상':
            return l10n.categoryDailyLife;
          default:
            return category.name; // 기본값으로 원래 이름 반환
        }
    }
  }

  Color _getCategoryColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  IconData _getCategoryIcon(String? iconString) {
    switch (iconString) {
      case 'help-circle':
        return Icons.help_outline;
      case 'heart':
        return Icons.favorite_outline;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        // 작성 가능한 카테고리만 필터링 (인기, 전체 제외)
        final writableCategories = provider.categories
            .where((cat) => cat.slug != 'popular' && cat.slug != 'all')
            .toList();

        if (writableCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.selectCategory,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 카테고리 버튼들
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: writableCategories.map((category) {
                    final isSelected = selectedCategory?.id == category.id;
                    final categoryColor = _getCategoryColor(category.color);
                    
                    return GestureDetector(
                      onTap: () => onCategorySelected(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    categoryColor,
                                    categoryColor.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: isSelected 
                              ? null 
                              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? categoryColor.withOpacity(0.3)
                                : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category.icon),
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getLocalizedCategoryName(l10n, category),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // 선택된 카테고리 설명
              if (selectedCategory != null && selectedCategory!.description != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(selectedCategory!.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(selectedCategory!.color).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: _getCategoryColor(selectedCategory!.color),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedCategory!.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}