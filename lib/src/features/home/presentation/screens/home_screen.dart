import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../presentation/providers/feeding_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../presentation/providers/diaper_provider.dart';
import '../../../../presentation/providers/health_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/feeding_summary_card.dart';
import '../widgets/sleep_summary_card.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/temperature_summary_card.dart';
import '../widgets/growth_info_card.dart';
import '../../../../domain/models/baby.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../../services/growth/growth_service.dart';
import '../../../../services/baby_guide/baby_guide_service.dart';
import '../../../../domain/models/baby_guide.dart';
import '../widgets/baby_guide_alert.dart';
import '../screens/baby_guide_list_screen.dart';
import '../../../../services/image/image_service.dart';
import '../../../baby/domain/repositories/baby_repository.dart';
import '../../../baby/data/repositories/supabase_baby_repository.dart';
import '../../../baby/domain/entities/baby.dart' as BabyEntity;
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final LocalizationProvider? localizationProvider;
  final ThemeProvider? themeProvider;
  
  const HomeScreen({
    super.key,
    this.localizationProvider,
    this.themeProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _homeRepository = HomeRepositoryImpl();
  final _babyGuideService = BabyGuideService.instance;
  final _growthService = GrowthService.instance;
  final _feedingProvider = FeedingProvider();
  final _sleepProvider = SleepProvider();
  final _diaperProvider = DiaperProvider();
  final _healthProvider = HealthProvider();
  
  Baby? _currentBaby;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isUploadingImage = false;
  
  // 요약 데이터
  Map<String, dynamic> _feedingSummary = {};
  Map<String, dynamic> _sleepSummary = {};
  Map<String, dynamic> _diaperSummary = {};
  Map<String, dynamic> _temperatureSummary = {};
  Map<String, dynamic> _growthSummary = {};

  @override
  void initState() {
    super.initState();
    // App lifecycle observer 등록
    WidgetsBinding.instance.addObserver(this);
    // Provider 변경 리스너 추가
    _feedingProvider.addListener(_onFeedingDataChanged);
    _sleepProvider.addListener(_onSleepDataChanged);
    _diaperProvider.addListener(_onDiaperDataChanged);
    _healthProvider.addListener(_onHealthDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    // App lifecycle observer 제거
    WidgetsBinding.instance.removeObserver(this);
    _feedingProvider.removeListener(_onFeedingDataChanged);
    _sleepProvider.removeListener(_onSleepDataChanged);
    _diaperProvider.removeListener(_onDiaperDataChanged);
    _healthProvider.removeListener(_onHealthDataChanged);
    _feedingProvider.dispose();
    _sleepProvider.dispose();
    _diaperProvider.dispose();
    _healthProvider.dispose();
    super.dispose();
  }

  /// FeedingProvider 데이터 변경 시 호출되는 콜백
  void _onFeedingDataChanged() {
    if (mounted) {
      setState(() {
        _feedingSummary = _feedingProvider.todaySummary;
      });
    }
  }

  /// SleepProvider 데이터 변경 시 호출되는 콜백
  void _onSleepDataChanged() {
    if (mounted) {
      setState(() {
        _sleepSummary = _sleepProvider.todaySummary;
      });
    }
  }

  /// DiaperProvider 데이터 변경 시 호출되는 콜백
  void _onDiaperDataChanged() {
    if (mounted) {
      setState(() {
        _diaperSummary = _diaperProvider.todaySummary;
      });
    }
  }

  /// HealthProvider 데이터 변경 시 호출되는 콜백
  void _onHealthDataChanged() {
    if (mounted) {
      setState(() {
        _temperatureSummary = _healthProvider.todaySummary;
      });
    }
  }

  /// 앱 생명주기 상태 변경 시 호출되는 콜백
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('App lifecycle state changed to: $state');
    
    // 앱이 백그라운드에서 포그라운드로 돌아올 때 데이터 새로고침
    if (state == AppLifecycleState.resumed && _currentBaby != null) {
      debugPrint('App resumed - refreshing home screen data');
      _refreshData();
    }
  }

  /// 데이터만 새로고침 (로딩 상태 없이)
  Future<void> _refreshData() async {
    if (_currentBaby == null || _currentUserId == null) return;
    
    try {
      // 모든 Provider의 데이터를 새로고침
      await Future.wait([
        _feedingProvider.refreshData(),
        _sleepProvider.refreshData(),
        _diaperProvider.refreshData(),
        _healthProvider.refreshData(),
      ]);
      
      // 성장 데이터 새로고침
      final growthSummary = await _homeRepository.getGrowthSummary(_currentBaby!.id);
      
      if (mounted) {
        setState(() {
          _growthSummary = growthSummary;
        });
      }
      
      debugPrint('Home screen data refreshed successfully');
    } catch (e) {
      debugPrint('Error refreshing home screen data: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // 카카오 로그인에서 받은 user_id 가져오기
      final userId = await _getUserId();
      
      if (userId == null) {
        // 로그인이 안되어 있으면 로그인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }
      
      // 해당 user_id와 연결된 아기 정보 조회
      final response = await Supabase.instance.client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            babies (
              id,
              name,
              birth_date,
              gender,
              profile_image_url,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId);
      
      if (response.isEmpty || response.first['babies'] == null) {
        // 등록된 아기가 없는 경우
        setState(() {
          _currentBaby = null;
          _currentUserId = null;
          _isLoading = false;
        });
        return;
      }
      
      final babyData = response.first['babies'];
      final baby = Baby.fromJson({
        'id': babyData['id'],
        'name': babyData['name'], 
        'birth_date': babyData['birth_date'],
        'gender': babyData['gender'],
        'profile_image_url': babyData['profile_image_url'],
        'created_at': babyData['created_at'],
        'updated_at': babyData['updated_at'],
      });
      
      // 모든 Provider 설정
      _feedingProvider.setCurrentBaby(baby.id, userId);
      _sleepProvider.setCurrentBaby(baby.id, userId);
      _diaperProvider.setCurrentBaby(baby.id, userId);
      _healthProvider.setCurrentBaby(baby.id, userId);
      
      // 성장 데이터는 아직 Provider로 이동하지 않음 (추후 개발 예정)
      final growthSummary = await _homeRepository.getGrowthSummary(baby.id);
      
      setState(() {
        _currentBaby = baby;
        _currentUserId = userId;
        // 모든 데이터는 Provider에서 관리됨
        _feedingSummary = _feedingProvider.todaySummary;
        _sleepSummary = _sleepProvider.todaySummary;
        _diaperSummary = _diaperProvider.todaySummary;
        _temperatureSummary = _healthProvider.todaySummary;
        _growthSummary = growthSummary;
        _isLoading = false;
      });
      
      // 아기 정보를 불러온 후 가이드 알럿 확인
      _checkForGuideAlert(userId);
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  /// 가이드 알럿 확인 및 표시
  Future<void> _checkForGuideAlert(String userId) async {
    if (_currentBaby == null) return;
    
    try {
      final guide = await _babyGuideService.checkForPendingAlert(userId, _currentBaby!);
      if (guide != null && mounted) {
        _showGuideAlert(guide, userId);
      }
    } catch (e) {
      debugPrint('Error checking guide alert: $e');
    }
  }
  
  /// 가이드 알럿 다이얼로그 표시
  void _showGuideAlert(BabyGuide guide, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BabyGuideAlert(
        guide: guide,
        baby: _currentBaby!,
        onDismiss: () {
          Navigator.of(context).pop();
          // 알럿을 본 것으로 기록
          _babyGuideService.handleAlertShown(userId, _currentBaby!, guide);
        },
      ),
    );
  }
  
  /// 프로필 이미지 업데이트
  Future<void> _updateProfileImage() async {
    if (_currentBaby == null) return;
    
    try {
      // iOS 플랫폼에서는 시뮬레이터 제한 안내
      // 실제 device_info 체크 없이 iOS 전체에서 갤러리 우선 권장
      final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
      
      // 이미지 선택 다이얼로그 표시
      final result = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('프로필 사진 설정'),
          content: const Text('사진을 어떻게 선택하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text('카메라'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text('갤러리'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        ),
      );
      
      if (result == null) return;
      
      String? imageUrl;
      
      try {
        // 1. 먼저 이미지 선택 (로딩 없이)
        debugPrint('Opening image picker...');
        final pickedFile = await ImageService.instance.pickImage(source: result);
        if (pickedFile == null) {
          debugPrint('Image selection cancelled by user');
          return; // 사용자가 취소한 경우
        }
        debugPrint('Image selected successfully: ${pickedFile.path}');
        
        // 2. 이미지 선택 완료 후 로딩 상태 표시 (setState 사용)
        if (mounted) {
          setState(() {
            _isUploadingImage = true;
          });
          debugPrint('Upload loading state enabled');
        }
        
        // 3. 이미지 업로드 수행 (기존 프로필 이미지 URL 전달)
        debugPrint('Starting image upload process...');
        imageUrl = await ImageService.instance.uploadImage(
          pickedFile,
          _currentBaby!.id,
          oldImageUrl: _currentBaby!.profileImageUrl,
        );
        debugPrint('Image upload completed. URL: $imageUrl');
        
        // 4. 임시 파일 삭제
        await pickedFile.delete();
        debugPrint('Temporary file deleted');
        
        if (imageUrl != null) {
          // 데이터베이스 업데이트
          debugPrint('Updating database with new profile image URL...');
          final babyRepository = SupabaseBabyRepository();
          final updatedBabyEntity = await babyRepository.updateBabyProfileImage(
            _currentBaby!.id,
            imageUrl,
          );
          debugPrint('Database update completed.');
          
          // Entity를 Model로 변환하여 UI 업데이트
          if (mounted) {
            setState(() {
              _currentBaby = Baby(
                id: updatedBabyEntity.id,
                name: updatedBabyEntity.name,
                birthDate: updatedBabyEntity.birthDate,
                gender: updatedBabyEntity.gender,
                profileImageUrl: updatedBabyEntity.profileImageUrl,
                createdAt: updatedBabyEntity.createdAt,
                updatedAt: updatedBabyEntity.updatedAt,
              );
            });
            debugPrint('UI state updated with new profile image.');
          }
        }
        
      } on PlatformException catch (e) {
        debugPrint('PlatformException caught: ${e.code} - ${e.message}');
        if (e.code == 'channel-error' && e.message?.contains('Unable to establish connection') == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isIOS 
                  ? 'iOS 시뮬레이터에서는 카메라를 사용할 수 없습니다.\n갤러리에서 다시 시도해주세요.'
                  : '카메라 접근에 문제가 발생했습니다.\n갤러리에서 다시 시도해주세요.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          rethrow;
        }
      } catch (e) {
        debugPrint('Unexpected error during image process: $e');
        rethrow;
      } finally {
        // 로딩 상태 끄기 (setState 사용)
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
          debugPrint('Upload loading state disabled');
        }
      }
      
      // 성공 메시지 표시
      if (imageUrl != null && mounted) {
        debugPrint('Showing success message...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      debugPrint('Outer catch - Error updating profile image: $e');
      
      // 최종 안전장치 - 로딩 상태 끄기
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        debugPrint('Emergency upload loading state disabled');
        
        String errorMessage = '프로필 사진 업데이트에 실패했습니다.';
        
        // 에러 타입별 처리
        if (e.toString().contains('로그인이 필요합니다') || 
            e.toString().contains('not authenticated')) {
          errorMessage = '🔐 로그인이 필요합니다!\n\n카카오 또는 이메일로 로그인 후\n프로필 사진을 설정해주세요.';
        } else if (e.toString().contains('profile_image_url') || 
                   e.toString().contains('PGRST204')) {
          errorMessage = '✅ 데이터베이스가 업데이트되었습니다!\n\n앱을 재시작한 후 다시 시도해주세요.';
        } else if (e.toString().contains('Bucket not found') || 
                   e.toString().contains('baby-profiles')) {
          errorMessage = '❌ Storage 버킷이 없습니다!\n\nSupabase 대시보드에서 baby-profiles 버킷을 생성해주세요.';
        } else if (e.toString().contains('permission') || 
                   e.toString().contains('Unauthorized')) {
          errorMessage = '❌ 저장 권한이 없습니다!\n\n로그인 상태를 확인해주세요.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 성장 기록 추가
  Future<void> _addGrowthRecord(dynamic data, String? notes) async {
    if (_currentBaby == null || _currentUserId == null) return;
    
    try {
      dynamic result;
      
      if (data is Map<String, double>) {
        // 동시 입력 (체중과 키 모두)
        debugPrint('동시 입력 감지: $data');
        result = await _growthService.addMultipleMeasurements(
          babyId: _currentBaby!.id,
          userId: _currentUserId!,
          measurements: data,
          notes: notes,
        );
      } else if (data is Map<String, dynamic> && 
                 data.containsKey('type') && 
                 data.containsKey('value')) {
        // 단일 입력 (기존 방식과 호환)
        debugPrint('단일 입력 감지: ${data['type']} = ${data['value']}');
        result = await _growthService.addSingleMeasurement(
          babyId: _currentBaby!.id,
          userId: _currentUserId!,
          type: data['type'] as String,
          value: data['value'] as double,
          notes: notes,
        );
      } else {
        throw Exception('잘못된 데이터 형식입니다');
      }
      
      if (result != null) {
        // 성장 데이터 새로고침
        final growthSummary = await _homeRepository.getGrowthSummary(_currentBaby!.id);
        
        if (mounted) {
          setState(() {
            _growthSummary = growthSummary;
          });
          
          // 성공 메시지 표시
          String message;
          Color backgroundColor;
          IconData icon;
          
          if (data is Map<String, double>) {
            // 동시 입력
            List<String> types = [];
            if (data.containsKey('weight')) types.add('체중');
            if (data.containsKey('height')) types.add('키');
            message = '${types.join('과 ')} 정보가 기록되었습니다';
            backgroundColor = Colors.indigo;
            icon = Icons.dashboard;
          } else {
            // 단일 입력
            final type = data['type'] as String;
            message = '${type == 'weight' ? '체중' : '키'} 정보가 기록되었습니다';
            backgroundColor = type == 'weight' ? Colors.purple : Colors.green;
            icon = type == 'weight' ? Icons.monitor_weight : Icons.height;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(message),
                ],
              ),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        throw Exception('성장 기록 저장에 실패했습니다');
      }
    } catch (e) {
      debugPrint('Error adding growth record: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('성장 기록 저장 중 오류가 발생했습니다'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
  
  Future<String?> _getUserId() async {
    try {
      // 카카오 로그인된 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      return user.id.toString();
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }
  
  Widget _buildNoBabyScreen(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.baby_changing_station,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '등록된 아기가 없습니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '아기를 등록하고 육아 기록을 시작해보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 아기 등록 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('아기 등록 기능은 곧 추가될 예정입니다'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('아기 등록하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 컨텐츠
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentBaby == null
                    ? _buildNoBabyScreen(context)
                    : RefreshIndicator(
                    onRefresh: _loadData,
                    child: CustomScrollView(
                  slivers: [
                    // 앱바
                    SliverAppBar(
                      floating: true,
                      backgroundColor: theme.colorScheme.background,
                      elevation: 0,
                      actions: [
                        // Baby guide list button
                        if (_currentBaby != null)
                          IconButton(
                            icon: Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.onBackground,
                            ),
                            tooltip: '육아 가이드',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BabyGuideListScreen(
                                    baby: _currentBaby!,
                                  ),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: theme.colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(
                                  localizationProvider: widget.localizationProvider!,
                                  themeProvider: widget.themeProvider,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    // 아기 정보 카드
                    if (_currentBaby != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BabyInfoCard(
                            baby: _currentBaby!,
                            feedingSummary: _feedingSummary,
                            onProfileImageTap: _updateProfileImage,
                          ),
                        ),
                      ),
                    
                    // 오늘의 요약 섹션 (흰 배경으로 감싸기)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 오늘의 요약 제목
                            Text(
                              l10n.todaySummary ?? '오늘의 요약',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 요약 카드 - 3개 가로 배치
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FeedingSummaryCard(
                                      summary: _feedingSummary,
                                      feedingProvider: _feedingProvider,
                                      sleepProvider: _sleepProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: SleepSummaryCard(
                                      summary: _sleepSummary,
                                      sleepProvider: _sleepProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: DiaperSummaryCard(
                                      summary: _diaperSummary,
                                      diaperProvider: _diaperProvider,
                                      sleepProvider: _sleepProvider,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 건강 카드 - 재사용을 위해 주석 처리
                            // ChangeNotifierProvider.value(
                            //   value: _healthProvider,
                            //   child: TemperatureSummaryCard(summary: _temperatureSummary),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 성장 정보 섹션
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.growthInfo ?? '성장 정보',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to detailed growth screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('성장 상세 페이지는 곧 추가될 예정입니다'),
                                  ),
                                );
                              },
                              child: Text(
                                '상세보기',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 성장 정보 카드
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: GrowthInfoCard(
                          summary: _growthSummary,
                          onAddRecord: _addGrowthRecord,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 프로필 이미지 업로드 로딩 오버레이
            if (_isUploadingImage)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            '프로필 사진 업로드 중...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}