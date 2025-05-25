import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../../features/record/presentation/screens/record_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';

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
        screen: const RecordScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.add_circle, size: 36),
          title: l10n.record ?? "기록",
          activeForegroundColor: theme.colorScheme.secondary,
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
    
    return PersistentTabView(
      controller: _controller,
      tabs: _tabs(context),
      navBarBuilder: (config) => Style6BottomNavBar(
        navBarConfig: config,
        navBarDecoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          color: theme.colorScheme.surface,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      selectedTabPressConfig: const SelectedTabPressConfig(
        popAction: PopActionType.all,
      ),
    );
  }
}