import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/baby/presentation/screens/baby_register_screen.dart';
import '../../features/baby/data/repositories/supabase_baby_repository.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String babyRegisterRoute = '/baby-register';
  static const String settingsRoute = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MyHomePage(
            title: 'Baby One More Time',
            localizationProvider: args?['localizationProvider'] as LocalizationProvider?,
            themeProvider: args?['themeProvider'] as ThemeProvider?,
          ),
        );
      case babyRegisterRoute:
        return MaterialPageRoute(builder: (_) => const BabyRegisterScreen());
      case settingsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(
            localizationProvider: args?['localizationProvider'] as LocalizationProvider,
            themeProvider: args?['themeProvider'] as ThemeProvider?,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

// 수정된 홈 화면 (아기 등록 기능 추가)
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    this.localizationProvider,
    this.themeProvider,
  }) : super(key: key);
  
  final String title;
  final LocalizationProvider? localizationProvider;
  final ThemeProvider? themeProvider;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _repository = SupabaseBabyRepository();
  List<dynamic> _babies = [];
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadBabies();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await UserApi.instance.me();
      setState(() {
        _userName = user.kakaoAccount?.profile?.nickname ?? AppLocalizations.of(context)?.user ?? 'User';
      });
    } catch (e) {
      debugPrint('Failed to load user info: $e');
    }
  }

  Future<void> _loadBabies() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await UserApi.instance.me();
      final userId = user.id.toString();
      final babies = await _repository.getBabiesByUserId(userId);

      setState(() {
        _babies = babies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.babyListLoadError(e.toString()) ?? 'Error loading baby list')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          if (_userName != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)?.welcomeUser(_userName!) ?? '$_userName님',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (widget.localizationProvider != null) {
                Navigator.pushNamed(
                  context,
                  AppRouter.settingsRoute,
                  arguments: {
                    'localizationProvider': widget.localizationProvider,
                    'themeProvider': widget.themeProvider,
                  },
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBabies,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _babies.isEmpty
            ? _buildEmptyState()
            : _buildBabyList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/baby-register').then((_) {
            // 아기 등록 후 목록 새로고침
            _loadBabies();
          });
        },
        tooltip: AppLocalizations.of(context)?.registerBaby ?? 'Register Baby',
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)?.registerBaby ?? 'Register Baby'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.noBabiesRegistered ?? 'No babies registered',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.registerFirstBaby ?? 'Register your first baby!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/baby-register').then((_) {
                  _loadBabies();
                });
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)?.registerBabyButton ?? 'Register Baby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _babies.length,
      itemBuilder: (context, index) {
        final baby = _babies[index];
        final age = DateTime.now().difference(baby.birthDate).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
              child: Icon(
                baby.gender == 'male'
                    ? Icons.boy
                    : baby.gender == 'female'
                    ? Icons.girl
                    : Icons.child_care,
                color: Colors.blue,
              ),
            ),
            title: Text(
              baby.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)?.birthday(baby.birthDate.year, baby.birthDate.month, baby.birthDate.day) ?? 'Birthday: ${baby.birthDate.year}/${baby.birthDate.month}/${baby.birthDate.day}'),
                Text(AppLocalizations.of(context)?.age(age) ?? 'Age: $age days'),
                if (baby.gender != null)
                  Text(AppLocalizations.of(context)?.gender(
                    baby.gender == 'male' 
                      ? AppLocalizations.of(context)?.male ?? 'Boy'
                      : baby.gender == 'female' 
                        ? AppLocalizations.of(context)?.female ?? 'Girl'
                        : AppLocalizations.of(context)?.other ?? 'Other'
                  ) ?? 'Gender: ${baby.gender}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 아기 상세 화면으로 이동 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.babyDetailScreen(baby.name) ?? '${baby.name} Detail Screen (Coming Soon)')),
              );
            },
          ),
        );
      },
    );
  }
}