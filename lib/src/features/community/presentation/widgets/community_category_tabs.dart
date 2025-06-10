import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../presentation/providers/community_provider.dart';

class CommunityCategoryTabs extends StatefulWidget {
  const CommunityCategoryTabs({super.key});

  @override
  State<CommunityCategoryTabs> createState() => _CommunityCategoryTabsState();
}

class _CommunityCategoryTabsState extends State<CommunityCategoryTabs>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _scaleControllers = {};

  @override
  void dispose() {
    for (final controller in _scaleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getScaleController(String categorySlug) {
    if (!_scaleControllers.containsKey(categorySlug)) {
      _scaleControllers[categorySlug] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
    }
    return _scaleControllers[categorySlug]!;
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
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'grid':
        return Icons.dashboard_rounded;
      case 'help-circle':
        return Icons.help_center_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'baby':
        return Icons.child_care_rounded;
      case 'feeding':
        return Icons.restaurant_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'play':
        return Icons.toys_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildCategoryGrid(BuildContext context, CommunityProvider provider, ThemeData theme) {
    // 카테고리를 2개씩 그룹화
    final categories = provider.categories;
    final rows = <List<CommunityCategory>>[];
    
    for (int i = 0; i < categories.length; i += 2) {
      final rowCategories = <CommunityCategory>[];
      rowCategories.add(categories[i]);
      if (i + 1 < categories.length) {
        rowCategories.add(categories[i + 1]);
      }
      rows.add(rowCategories);
    }

    return Column(
      children: rows.map((rowCategories) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ...rowCategories.map((category) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: rowCategories.last == category ? 0 : 6,
                      left: rowCategories.first == category ? 0 : 6,
                    ),
                    child: _buildCategoryCard(context, category, provider, theme),
                  ),
                );
              }).toList(),
              // 홀수 개일 때 빈 공간 채우기
              if (rowCategories.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CommunityCategory category, CommunityProvider provider, ThemeData theme) {
    final isSelected = provider.selectedCategorySlug == category.slug;
    final categoryColor = _getCategoryColor(category.color);
    final scaleController = _getScaleController(category.slug);
    
    return GestureDetector(
      onTapDown: (_) {
        scaleController.forward();
      },
      onTapUp: (_) {
        scaleController.reverse();
      },
      onTapCancel: () {
        scaleController.reverse();
      },
      onTap: () {
        HapticFeedback.lightImpact();
        provider.selectCategory(category.slug);
      },
      child: AnimatedBuilder(
        animation: scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (scaleController.value * 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              height: 80,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryColor,
                          categoryColor.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface,
                          theme.colorScheme.surface.withOpacity(0.8),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? categoryColor.withOpacity(0.3)
                      : theme.colorScheme.outline.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: categoryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.selectCategory(category.slug);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 아이콘
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(category.icon),
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : categoryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // 텍스트
                        Text(
                          category.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // 카테고리 Grid
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCategoryGrid(context, provider, theme),
              ),
              
              // 선택된 카테고리 설명 (선택사항)
              if (provider.selectedCategorySlug != 'all')
                () {
                  try {
                    final selectedCategory = provider.categories
                        .firstWhere((cat) => cat.slug == provider.selectedCategorySlug);
                    final description = selectedCategory.description;
                    final categoryColor = _getCategoryColor(selectedCategory.color);
                    
                    if (description != null && description.isNotEmpty) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor.withOpacity(0.08),
                              categoryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_rounded,
                                size: 16,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    // 카테고리를 찾지 못한 경우
                  }
                  return const SizedBox.shrink();
                }(),
            ],
          ),
        );
      },
    );
  }
}