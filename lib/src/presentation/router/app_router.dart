import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/baby/presentation/screens/baby_register_screen.dart';
import '../../features/baby/data/repositories/supabase_baby_repository.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String babyRegisterRoute = '/baby-register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Baby One More Time'));
      case babyRegisterRoute:
        return MaterialPageRoute(builder: (_) => const BabyRegisterScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

// 수정된 홈 화면 (아기 등록 기능 추가)
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

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
        _userName = user.kakaoAccount?.profile?.nickname ?? '사용자';
      });
    } catch (e) {
      print('사용자 정보 로드 실패: $e');
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
          SnackBar(content: Text('아기 목록 로드 중 오류가 발생했습니다: $e')),
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
                  '$_userName님',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
        tooltip: '아기 등록',
        icon: const Icon(Icons.add),
        label: const Text('아기 등록'),
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
            const Text(
              '등록된 아기가 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '첫 번째 아기를 등록해보세요!',
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
              label: const Text('아기 등록하기'),
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
              backgroundColor: Colors.blue.withOpacity(0.2),
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
                Text('생일: ${baby.birthDate.year}년 ${baby.birthDate.month}월 ${baby.birthDate.day}일'),
                Text('나이: ${age}일'),
                if (baby.gender != null)
                  Text('성별: ${baby.gender == 'male' ? '남아' : baby.gender == 'female' ? '여아' : '기타'}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 아기 상세 화면으로 이동 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${baby.name} 상세 화면 (추후 구현)')),
              );
            },
          ),
        );
      },
    );
  }
}