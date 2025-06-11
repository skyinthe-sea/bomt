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
      case 'apps':
        return Icons.dashboard_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'grid':
        return Icons.dashboard_rounded;
      case 'help-circle':
        return Icons.help_center_rounded;
      case 'help_center':
        return Icons.help_center_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'baby':
        return Icons.child_care_rounded;
      case 'feeding':
        return Icons.restaurant_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'nightlight':
        return Icons.nightlight_rounded;
      case 'play':
        return Icons.toys_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'vaccines':
        return Icons.vaccines_rounded;
      case 'healing':
        return Icons.healing_rounded;
      case 'self_care':
        return Icons.healing_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildCategoryGrid(BuildContext context, CommunityProvider provider, ThemeData theme) {
    // 카테고리를 3개씩 그룹화 (3x3 그리드)
    final categories = provider.categories;
    final rows = <List<CommunityCategory>>[];
    
    for (int i = 0; i < categories.length; i += 3) {
      final rowCategories = <CommunityCategory>[];
      for (int j = 0; j < 3 && i + j < categories.length; j++) {
        rowCategories.add(categories[i + j]);
      }
      rows.add(rowCategories);
    }

    return Column(
      children: rows.map((rowCategories) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              ...rowCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < 2 ? 4 : 0,
                      left: index > 0 ? 4 : 0,
                    ),
                    child: _buildCategoryCard(context, category, provider, theme),
                  ),
                );
              }).toList(),
              // 빈 공간 채우기
              ...List.generate(3 - rowCategories.length, (index) => const Expanded(child: SizedBox())),
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
              height: 85, // 오버플로우 완전 방지 (+5px 추가)
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
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 아이콘
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(category.icon),
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : categoryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 텍스트
                        Flexible(
                          child: Text(
                            category.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 10,
                              height: 1.0, // 줄 높이 명시적 설정
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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