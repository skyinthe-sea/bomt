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
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
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