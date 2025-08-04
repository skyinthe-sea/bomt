import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/tab_controller_provider.dart';
import '../providers/community_provider.dart';
import '../../core/providers/baby_provider.dart';

class MainScreen extends StatefulWidget {
  final LocalizationProvider? localizationProvider;
  final ThemeProvider? themeProvider;
  
  const MainScreen({
    super.key,
    this.localizationProvider,
    this.themeProvider,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 🛡️ MainScreen 인스턴스 중복 방지를 위한 정적 변수
  static bool _isActive = false;
  static int _instanceCount = 0;
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    
    // 🛡️ 인스턴스 중복 검사 및 카운팅
    _MainScreenState._instanceCount++;
    debugPrint('🏠 [MAIN_SCREEN] Instance created. Count: ${_MainScreenState._instanceCount}');
    
    // 🚨 이미 활성화된 MainScreen이 있으면 이전 것을 비활성화
    if (_MainScreenState._isActive) {
      debugPrint('⚠️ [MAIN_SCREEN] Warning: Another MainScreen is already active! Deactivating previous one.');
    }
    
    _MainScreenState._isActive = true;
    _controller = PersistentTabController(initialIndex: 0);
    
    // 🔄 Navigator 스택 중복 정리 (안전한 지연 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _cleanupNavigatorStack();
        }
      });
    });
  }
  
  /// Navigator 스택에서 중복된 MainScreen 제거 (안전한 방법)
  void _cleanupNavigatorStack() {
    try {
      if (!mounted) return;
      
      debugPrint('🔄 [MAIN_SCREEN] Checking Navigator stack...');
      
      // 🔄 안전한 Navigator 확인
      final navigator = Navigator.maybeOf(context);
      if (navigator == null) {
        debugPrint('⚠️ [MAIN_SCREEN] No Navigator found - skipping cleanup');
        return;
      }
      
      final currentRoute = ModalRoute.of(context)?.settings.name;
      debugPrint('🔄 [MAIN_SCREEN] Current route: $currentRoute');
      debugPrint('🔄 [MAIN_SCREEN] Can pop: ${navigator.canPop()}');
      
      // 🎯 보수적인 스택 정리 (최대 3개만 제거)
      if (navigator.canPop()) {
        debugPrint('🔄 [MAIN_SCREEN] Detected routes in stack - conservative cleanup...');
        
        int popCount = 0;
        while (navigator.canPop() && popCount < 3) { // 최대 3개만 제거
          try {
            navigator.pop();
            popCount++;
            debugPrint('🔄 [MAIN_SCREEN] Popped route $popCount');
            
            // 각 pop 후 잠시 대기
            if (popCount < 3) {
              Future.delayed(const Duration(milliseconds: 100));
            }
          } catch (popError) {
            debugPrint('❌ [MAIN_SCREEN] Pop failed at $popCount: $popError');
            break;
          }
        }
        
        if (popCount > 0) {
          debugPrint('✅ [MAIN_SCREEN] Successfully removed $popCount routes from stack');
        }
      } else {
        debugPrint('✅ [MAIN_SCREEN] Navigator stack is clean - no routes to pop');
      }
      
    } catch (e) {
      debugPrint('❌ [MAIN_SCREEN] Navigator cleanup error: $e');
      // 에러 발생해도 앱은 계속 실행
    }
  }
  

  @override
  void dispose() {
    // 🛡️ 인스턴스 정리
    _MainScreenState._instanceCount--;
    _MainScreenState._isActive = false;
    debugPrint('🏠 [MAIN_SCREEN] Instance disposed. Count: ${_MainScreenState._instanceCount}');
    
    _controller.dispose();
    super.dispose();
  }

  List<PersistentTabConfig> _tabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return [
      PersistentTabConfig(
        screen: HomeScreen(
          localizationProvider: widget.localizationProvider,
          themeProvider: widget.themeProvider,
        ),
        item: ItemConfig(
          icon: const Icon(Icons.home),
          title: l10n.home ?? "홈",
          activeForegroundColor: theme.colorScheme.primary,
          inactiveForegroundColor: isDark ? Colors.grey[600]! : Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: const TimelineScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.timeline),
          title: l10n.timeline ?? "타임라인",
          activeForegroundColor: theme.colorScheme.primary,
          inactiveForegroundColor: isDark ? Colors.grey[600]! : Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: const StatisticsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.bar_chart),
          title: l10n.statistics ?? "통계",
          activeForegroundColor: theme.colorScheme.primary,
          inactiveForegroundColor: isDark ? Colors.grey[600]! : Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: const CommunityScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.people),
          title: l10n.community ?? "커뮤니티",
          activeForegroundColor: theme.colorScheme.primary,
          inactiveForegroundColor: isDark ? Colors.grey[600]! : Colors.grey,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 🛡️ 중복 인스턴스 알림만 (UI 차단하지 않음)
    if (_MainScreenState._instanceCount > 1) {
      debugPrint('⚠️ [MAIN_SCREEN] Multiple instances detected: ${_MainScreenState._instanceCount}');
      // 🔄 3초 후 자동으로 이전 인스턴스 정리 (UI는 정상 렌더링)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _MainScreenState._instanceCount > 1) {
          debugPrint('🧹 [MAIN_SCREEN] Auto-cleanup: Resetting instance count');
          _MainScreenState._instanceCount = 1; // 강제 리셋
        }
      });
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final babyProvider = BabyProvider();
          // BabyProvider 생성 후 데이터 로드
          WidgetsBinding.instance.addPostFrameCallback((_) {
            babyProvider.loadBabyData();
          });
          return babyProvider;
        }),
        ChangeNotifierProvider(create: (context) => StatisticsProvider()),
        ChangeNotifierProvider(create: (context) => TabControllerProvider()),
        ChangeNotifierProvider(create: (context) => CommunityProvider()),
      ],
      child: Builder(
        builder: (context) {
          // TabControllerProvider에 컨트롤러 설정
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<TabControllerProvider>(context, listen: false)
                .setController(_controller);
          });
          
          return PersistentTabView(
            controller: _controller,
            tabs: _tabs(context),
            navBarBuilder: (config) => _buildModernBottomNav(config, theme, isDark),
            backgroundColor: theme.scaffoldBackgroundColor,
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            selectedTabPressConfig: const SelectedTabPressConfig(
              popAction: PopActionType.all,
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernBottomNav(NavBarConfig config, ThemeData theme, bool isDark) {
    return Container(
      color: theme.scaffoldBackgroundColor, // 바깥 배경을 홈스크린과 동일하게
      padding: const EdgeInsets.only(bottom: 30),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          color: isDark 
              ? theme.colorScheme.surface.withOpacity(0.9)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark 
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: isDark 
                ? theme.colorScheme.outline.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: config.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == config.selectedIndex;
                  
                  return _buildModernTabItem(
                    item, 
                    isSelected, 
                    () => config.onItemSelected?.call(index),
                    theme,
                    isDark,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabItem(
    ItemConfig item, 
    bool isSelected, 
    VoidCallback? onTap,
    ThemeData theme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: isSelected ? BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ) : null,
                child: Icon(
                  (item.icon as Icon).icon,
                  size: 22,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : isDark 
                          ? Colors.grey[400] 
                          : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? theme.colorScheme.primary
                    : isDark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
              ),
              child: Text(
                item.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}