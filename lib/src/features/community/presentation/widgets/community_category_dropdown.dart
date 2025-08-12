import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../presentation/providers/community_provider.dart';

class CommunityCategoryDropdown extends StatefulWidget {
  const CommunityCategoryDropdown({super.key});

  @override
  State<CommunityCategoryDropdown> createState() => _CommunityCategoryDropdownState();
}

class _CommunityCategoryDropdownState extends State<CommunityCategoryDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  // 드롭다운 최대 높이 계산 (최대 5개 아이템만 보이도록)
  double _getMaxDropdownHeight(int itemCount) {
    const double itemHeight = 40.0;
    const double padding = 6.0;
    const int maxVisibleItems = 5;
    
    final visibleItemCount = itemCount > maxVisibleItems ? maxVisibleItems : itemCount;
    return (visibleItemCount * itemHeight) + padding;
  }

  void _selectCategory(CommunityProvider provider, CommunityCategory category) {
    provider.selectCategory(category.slug);
    _toggleDropdown(); // 선택 후 드롭다운 닫기
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedCategory = provider.categories.firstWhere(
          (cat) => cat.slug == provider.selectedCategorySlug,
          orElse: () => provider.categories.first,
        );
        
        final selectedColor = _getCategoryColor(selectedCategory.color);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              // 드롭다운 헤더 (더 컴팩트하게)
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        selectedColor.withOpacity(0.85),
                        selectedColor.withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_isExpanded ? 14 : 18),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 선택된 카테고리 아이콘 (더 작게)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(selectedCategory.icon),
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // 선택된 카테고리 이름 (더 작게)
                      Expanded(
                        child: Text(
                          _getLocalizedCategoryName(l10n, selectedCategory),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // 드롭다운 화살표 (더 작게)
                      AnimatedBuilder(
                        animation: _iconRotation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _iconRotation.value * 3.14159,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // 드롭다운 아이템들 (더 컴팩트하고 스크롤 가능)
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  final availableCategories = provider.categories
                      .where((cat) => cat.slug != provider.selectedCategorySlug)
                      .toList();
                  
                  final maxHeight = _getMaxDropdownHeight(availableCategories.length);
                  
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                    child: Container(
                      height: _expandAnimation.value * maxHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface.withOpacity(0.96),
                            theme.colorScheme.surface.withOpacity(0.92),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                        border: Border.all(
                          color: selectedColor.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        // 스크롤 활성화 (많은 카테고리가 있을 때)
                        physics: availableCategories.length > 5 
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Column(
                            children: availableCategories
                                .map((category) => _buildDropdownItem(
                                      context,
                                      category,
                                      provider,
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
        );
      },
    );
  }

  Widget _buildDropdownItem(
    BuildContext context,
    CommunityCategory category,
    CommunityProvider provider,
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
          onTap: () => _selectCategory(provider, category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: categoryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 카테고리 아이콘
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
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
                      fontSize: 13,
                    ),
                  ),
                ),
                
                // 화살표 아이콘
                Icon(
                  Icons.chevron_right,
                  color: categoryColor.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}