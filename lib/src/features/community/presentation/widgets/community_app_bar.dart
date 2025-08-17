import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../screens/community_notification_screen.dart';
import '../screens/community_search_screen.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../../../../services/community/notification_service.dart';
import '../../../../domain/models/community_category.dart';

class CommunityAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CommunityAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);

  @override
  State<CommunityAppBar> createState() => _CommunityAppBarState();
}

class _CommunityAppBarState extends State<CommunityAppBar>
    with SingleTickerProviderStateMixin {
  int _unreadCount = 0;
  final NotificationService _notificationService = NotificationService();
  bool _isCategoryExpanded = false;
  late AnimationController _categoryAnimationController;
  final LayerLink _categoryLayerLink = LayerLink();
  OverlayEntry? _categoryOverlayEntry;

  @override
  void initState() {
    super.initState();
    _categoryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _categoryOverlayEntry?.remove();
    _categoryOverlayEntry = null;
    _categoryAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final provider = context.read<CommunityProvider>();
      if (provider.currentUserId != null) {
        final count = await _notificationService.getUnreadNotificationCount(
          provider.currentUserId!,
        );
        if (mounted) {
          setState(() {
            _unreadCount = count;
          });
        }
      }
    } catch (e) {
      // 에러 시 무시하고 기본값 유지
    }
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
      default:
        return Icons.category_rounded;
    }
  }

  void _toggleCategoryDropdown() {
    if (!mounted) return;
    
    if (_isCategoryExpanded) {
      _closeCategoryDropdown();
    } else {
      _openCategoryDropdown();
    }
    HapticFeedback.lightImpact();
  }

  void _openCategoryDropdown() {
    if (!mounted) return;
    
    _isCategoryExpanded = true;
    _categoryAnimationController.forward();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    _categoryOverlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          // 외부 터치 감지를 위한 투명 배경
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeCategoryDropdown,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // 실제 드롭다운 메뉴
          Positioned(
            width: 200,
            child: CompositedTransformFollower(
              link: _categoryLayerLink,
              showWhenUnlinked: false,
              offset: Offset(-158, size.height + 4), // 버튼 오른쪽 끝에서 드롭다운 오른쪽 끝을 맞춤
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _categoryAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _categoryAnimationController.value),
                      alignment: Alignment.topRight,
                      child: Opacity(
                        opacity: _categoryAnimationController.value,
                        child: _buildCategoryDropdownContent(overlayContext),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    overlay.insert(_categoryOverlayEntry!);
  }

  void _closeCategoryDropdown() {
    if (!_isCategoryExpanded) return;
    
    _isCategoryExpanded = false;
    
    if (mounted) {
      try {
        _categoryAnimationController.reverse().then((_) {
          if (mounted) {
            _categoryOverlayEntry?.remove();
            _categoryOverlayEntry = null;
          }
        });
      } catch (e) {
        _categoryOverlayEntry?.remove();
        _categoryOverlayEntry = null;
      }
    } else {
      _categoryOverlayEntry?.remove();
      _categoryOverlayEntry = null;
    }
  }

  Widget _buildCategoryDropdownContent(BuildContext overlayContext) {
    if (!mounted) return const SizedBox.shrink();
    
    final theme = Theme.of(overlayContext);
    final l10n = AppLocalizations.of(overlayContext)!;
    
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              child: Column(
                children: provider.categories
                    .map((category) => _buildCategoryDropdownItem(category, provider, theme, l10n))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdownItem(
    CommunityCategory category, 
    CommunityProvider provider, 
    ThemeData theme, 
    AppLocalizations l10n
  ) {
    final categoryColor = _getCategoryColor(category.color);
    final isSelected = provider.selectedCategorySlug == category.slug;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          provider.selectCategory(category.slug);
          _closeCategoryDropdown();
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? categoryColor.withOpacity(0.1) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getLocalizedCategoryName(l10n, category),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? categoryColor 
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 16,
                  color: categoryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.primary.withOpacity(0.7),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: kToolbarHeight + 20,
            flexibleSpace: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // 로고/제목
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '함께 나누는 육아 이야기',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 검색 버튼 (크기 조정)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // 검색 페이지로 이동
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const CommunitySearchScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        tooltip: l10n.search,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    
                    // 알림 버튼 (크기 조정)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          // 알림 화면으로 이동
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CommunityNotificationScreen(),
                            ),
                          );
                          // 돌아왔을 때 알림 개수 업데이트
                          _loadUnreadCount();
                        },
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 18,
                            ),
                            // 읽지 않은 알림 뱃지
                            if (_unreadCount > 0)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        tooltip: l10n.notification,
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    // 카테고리 버튼 (새로 추가)
                    Consumer<CommunityProvider>(
                      builder: (context, provider, child) {
                        if (provider.categories.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return CompositedTransformTarget(
                          link: _categoryLayerLink,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _isCategoryExpanded 
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isCategoryExpanded
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: IconButton(
                              onPressed: _toggleCategoryDropdown,
                              icon: AnimatedRotation(
                                turns: _isCategoryExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.tune,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 18,
                                ),
                              ),
                              tooltip: '카테고리 선택',
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}