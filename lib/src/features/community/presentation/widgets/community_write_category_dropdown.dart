import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../presentation/providers/community_provider.dart';

class CommunityWriteCategoryDropdown extends StatefulWidget {
  final CommunityCategory? selectedCategory;
  final Function(CommunityCategory) onCategorySelected;

  const CommunityWriteCategoryDropdown({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CommunityWriteCategoryDropdown> createState() => _CommunityWriteCategoryDropdownState();
}

class _CommunityWriteCategoryDropdownState extends State<CommunityWriteCategoryDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 카테고리 이름 현지화 함수
  String _getLocalizedCategoryName(AppLocalizations l10n, CommunityCategory category) {
    switch (category.slug) {
      case 'all':
        return l10n.categoryAll;
      case 'popular':
        return l10n.categoryPopular;
      default:
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
            return category.name;
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
      case 'apps':
        return Icons.dashboard_rounded;
      case 'local_fire_department':
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'grid':
        return Icons.dashboard_rounded;
      case 'help-circle':
      case 'help_center':
        return Icons.help_center_rounded;
      case 'heart':
      case 'favorite':
        return Icons.favorite_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'baby':
        return Icons.child_care_rounded;
      case 'feeding':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'sleep':
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
      case 'self_care':
        return Icons.healing_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    HapticFeedback.lightImpact();
  }

  void _selectCategory(CommunityCategory category) {
    widget.onCategorySelected(category);
    _toggleDropdown(); // 선택 후 드롭다운 닫기
    HapticFeedback.lightImpact();
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

        final selectedCategory = widget.selectedCategory ?? writableCategories.first;
        final selectedColor = _getCategoryColor(selectedCategory.color);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 라벨
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.selectCategory,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 드롭다운
              Column(
                children: [
                  // 드롭다운 헤더
                  GestureDetector(
                    onTap: _toggleDropdown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            selectedColor.withOpacity(0.15),
                            selectedColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(_isExpanded ? 12 : 16),
                        border: Border.all(
                          color: selectedColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 선택된 카테고리 아이콘
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(selectedCategory.icon),
                              size: 16,
                              color: selectedColor,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 선택된 카테고리 이름
                          Expanded(
                            child: Text(
                              _getLocalizedCategoryName(l10n, selectedCategory),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: selectedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          // 드롭다운 화살표
                          AnimatedBuilder(
                            animation: _iconRotation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _iconRotation.value * 3.14159,
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: selectedColor.withOpacity(0.8),
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 드롭다운 아이템들
                  AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        child: Container(
                          height: _expandAnimation.value * (writableCategories.where((cat) => cat.id != selectedCategory.id).length * 48.0 + 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.95),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: selectedColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: writableCategories
                                    .where((cat) => cat.id != selectedCategory.id)
                                    .map((category) => _buildDropdownItem(
                                          context,
                                          category,
                                          theme,
                                          l10n,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownItem(
    BuildContext context,
    CommunityCategory category,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final categoryColor = _getCategoryColor(category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // 카테고리 아이콘
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    size: 14,
                    color: categoryColor,
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // 카테고리 이름
                Expanded(
                  child: Text(
                    _getLocalizedCategoryName(l10n, category),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}