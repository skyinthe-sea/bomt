import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/localization_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../presentation/providers/tab_controller_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../../../presentation/providers/feeding_provider.dart';
import '../../../../presentation/providers/sleep_provider.dart';
import '../../../../presentation/providers/diaper_provider.dart';
import '../../../../presentation/providers/health_provider.dart';
import '../../../../presentation/providers/solid_food_provider.dart';
import '../../../../presentation/providers/medication_provider.dart';
import '../../../../presentation/providers/milk_pumping_provider.dart';
import '../../../../services/user_card_setting/user_card_setting_service.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/feeding_summary_card.dart';
import '../widgets/sleep_summary_card.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/temperature_summary_card.dart';
import '../widgets/growth_info_card.dart';
import '../widgets/solid_food_summary_card.dart';
import '../widgets/medication_summary_card.dart';
import '../widgets/milk_pumping_summary_card.dart';
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
import 'card_settings_screen.dart';

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
  final _solidFoodProvider = SolidFoodProvider();
  final _medicationProvider = MedicationProvider();
  final _milkPumpingProvider = MilkPumpingProvider();
  
  // 카드 설정 서비스 (Provider 대신 직접 서비스 사용)
  final _userCardSettingService = UserCardSettingService.instance;
  List<String> _enabledCardTypes = ['feeding', 'sleep', 'diaper']; // 기본값
  
  Baby? _currentBaby;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isUploadingImage = false;
  
  // 재진입 방지를 위한 플래그
  bool _isLoadingData = false;
  
  // 탭 변경 감지를 위한 변수들
  PersistentTabController? _tabController;
  DateTime? _lastRefreshTime;
  
  // 요약 데이터
  Map<String, dynamic> _feedingSummary = {};
  Map<String, dynamic> _sleepSummary = {};
  Map<String, dynamic> _diaperSummary = {};
  Map<String, dynamic> _temperatureSummary = {};
  Map<String, dynamic> _growthSummary = {};
  Map<String, dynamic> _solidFoodSummary = {};
  Map<String, dynamic> _medicationSummary = {};
  Map<String, dynamic> _milkPumpingSummary = {};

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
    _solidFoodProvider.addListener(_onSolidFoodDataChanged);
    _medicationProvider.addListener(_onMedicationDataChanged);
    _milkPumpingProvider.addListener(_onMilkPumpingDataChanged);
    
    // 탭 컨트롤러 감지 설정 (PostFrameCallback으로 처리)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTabChangeListener();
    });
    
    _loadData();
  }

  @override
  void dispose() {
    // App lifecycle observer 제거
    WidgetsBinding.instance.removeObserver(this);
    // 탭 컨트롤러 리스너 제거
    _tabController?.removeListener(_onTabChanged);
    // Provider 리스너 제거
    _feedingProvider.removeListener(_onFeedingDataChanged);
    _sleepProvider.removeListener(_onSleepDataChanged);
    _diaperProvider.removeListener(_onDiaperDataChanged);
    _healthProvider.removeListener(_onHealthDataChanged);
    _solidFoodProvider.removeListener(_onSolidFoodDataChanged);
    _medicationProvider.removeListener(_onMedicationDataChanged);
    _milkPumpingProvider.removeListener(_onMilkPumpingDataChanged);
    _feedingProvider.dispose();
    _sleepProvider.dispose();
    _diaperProvider.dispose();
    _healthProvider.dispose();
    _solidFoodProvider.dispose();
    _medicationProvider.dispose();
    _milkPumpingProvider.dispose();
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

  /// SolidFoodProvider 데이터 변경 시 호출되는 콜백
  void _onSolidFoodDataChanged() {
    if (mounted) {
      setState(() {
        _solidFoodSummary = _solidFoodProvider.todaySummary;
      });
    }
  }

  /// MedicationProvider 데이터 변경 시 호출되는 콜백
  void _onMedicationDataChanged() {
    if (mounted) {
      setState(() {
        _medicationSummary = _medicationProvider.todaySummary;
      });
    }
  }

  /// MilkPumpingProvider 데이터 변경 시 호출되는 콜백
  void _onMilkPumpingDataChanged() {
    if (mounted) {
      setState(() {
        _milkPumpingSummary = _milkPumpingProvider.todaySummary;
      });
    }
  }

  /// 탭 변경 감지 설정
  void _setupTabChangeListener() {
    try {
      final tabControllerProvider = Provider.of<TabControllerProvider>(context, listen: false);
      _tabController = tabControllerProvider.controller;
      
      if (_tabController != null) {
        _tabController!.addListener(_onTabChanged);
        debugPrint('🏠 [HOME] Tab change listener added successfully');
      } else {
        debugPrint('⚠️ [HOME] TabController is null, retrying in 500ms...');
        // 500ms 후 재시도
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _setupTabChangeListener();
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [HOME] Error setting up tab listener: $e');
    }
  }

  /// 탭 변경 시 호출되는 콜백
  void _onTabChanged() {
    if (!mounted || _tabController == null) return;
    
    final currentIndex = _tabController!.index;
    debugPrint('🏠 [HOME] Tab changed to index: $currentIndex');
    
    // 홈 탭(index 0)으로 돌아왔을 때만 새로고침
    if (currentIndex == 0) {
      debugPrint('🏠 [HOME] Home tab selected - checking for refresh');
      _refreshDataIfNeeded();
    }
  }

  /// 필요시에만 데이터 새로고침 (중복 방지)
  void _refreshDataIfNeeded() {
    final now = DateTime.now();
    
    // 마지막 새로고침으로부터 30초가 지났거나 첫 번째 새로고침인 경우에만 실행
    if (_lastRefreshTime == null || 
        now.difference(_lastRefreshTime!).inSeconds > 30) {
      
      debugPrint('🏠 [HOME] Refreshing data due to tab change');
      _lastRefreshTime = now;
      _refreshData();
    } else {
      debugPrint('🏠 [HOME] Skipping refresh - too recent (${now.difference(_lastRefreshTime!).inSeconds}s ago)');
    }
  }

  /// 앱 생명주기 상태 변경 시 호출되는 콜백
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('App lifecycle state changed to: $state');
    
    // 앱이 백그라운드에서 포그라운드로 돌아올 때 데이터 새로고침
    if (state == AppLifecycleState.resumed && _currentBaby != null && !_isLoadingData) {
      debugPrint('App resumed - refreshing home screen data');
      _refreshData();
    } else if (state == AppLifecycleState.resumed && _isLoadingData) {
      debugPrint('App resumed - skipping refresh, loading already in progress');
    }
  }

  /// 데이터만 새로고침 (로딩 상태 없이)
  Future<void> _refreshData() async {
    if (_currentBaby == null || _currentUserId == null) return;
    
    // 재진입 방지 체크
    if (_isLoadingData) {
      debugPrint('⚠️ [HOME] _refreshData skipped - _loadData in progress');
      return;
    }
    
    try {
      // 모든 Provider의 데이터를 새로고침
      await Future.wait([
        _feedingProvider.refreshData(),
        _sleepProvider.refreshData(),
        _diaperProvider.refreshData(),
        _healthProvider.refreshData(),
        _solidFoodProvider.refreshData(),
        _medicationProvider.refreshData(),
        _milkPumpingProvider.refreshData(),
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
    debugPrint('🏠 [HOME] Starting _loadData...');
    
    // 재진입 방지 체크
    if (_isLoadingData) {
      debugPrint('⚠️ [HOME] _loadData already in progress, skipping...');
      return;
    }
    
    try {
      _isLoadingData = true; // 재진입 방지 플래그 설정
      debugPrint('🏠 [HOME] Setting _isLoading = true');
      setState(() => _isLoading = true);
      
      // 타임아웃 제거하고 직접 실행 (디버깅용)
      debugPrint('🏠 [HOME] Starting data loading without timeout...');
      await _performDataLoading();
      debugPrint('🏠 [HOME] Data loading completed successfully');
      
    } catch (e) {
      debugPrint('❌ [HOME] Error loading home data: $e');
      debugPrint('❌ [HOME] Stack trace: ${StackTrace.current}');
      setState(() => _isLoading = false);
      debugPrint('❌ [HOME] Set _isLoading = false in catch block');
    } finally {
      _isLoadingData = false; // 재진입 방지 플래그 해제
      debugPrint('🏠 [HOME] Released _isLoadingData flag');
    }
  }
  
  /// 실제 데이터 로딩 수행
  Future<void> _performDataLoading() async {
      // 카카오 로그인에서 받은 user_id 가져오기
      debugPrint('🏠 [HOME] Getting user ID...');
      final userId = await _getUserId();
      debugPrint('🏠 [HOME] User ID: $userId');
      
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
      _solidFoodProvider.setCurrentBaby(baby.id, userId);
      _medicationProvider.setCurrentBaby(baby.id, userId);
      _milkPumpingProvider.setCurrentBaby(baby.id, userId);
      
      // 카드 설정 로드 (안전한 방식)
      debugPrint('🏠 [HOME] Loading card settings safely...');
      try {
        await _loadCardSettings(userId);
      } catch (e) {
        debugPrint('❌ [HOME] Card settings load failed, using defaults: $e');
        _enabledCardTypes = ['feeding', 'sleep', 'diaper']; // 폴백 기본값
      }
      
      // 성장 데이터는 아직 Provider로 이동하지 않음 (추후 개발 예정)
      debugPrint('🏠 [HOME] Getting growth summary...');
      final growthSummary = await _homeRepository.getGrowthSummary(baby.id);
      
      debugPrint('🏠 [HOME] Setting final state (_isLoading = false)...');
      setState(() {
        _currentBaby = baby;
        _currentUserId = userId;
        // 모든 데이터는 Provider에서 관리됨
        _feedingSummary = _feedingProvider.todaySummary;
        _sleepSummary = _sleepProvider.todaySummary;
        _diaperSummary = _diaperProvider.todaySummary;
        _temperatureSummary = _healthProvider.todaySummary;
        _solidFoodSummary = _solidFoodProvider.todaySummary;
        _medicationSummary = _medicationProvider.todaySummary;
        _milkPumpingSummary = _milkPumpingProvider.todaySummary;
        _growthSummary = growthSummary;
        _isLoading = false;
      });
      debugPrint('✅ [HOME] Final state set successfully');
      
      // 아기 정보를 불러온 후 가이드 알럿 확인
      debugPrint('🏠 [HOME] Checking for guide alert...');
      _checkForGuideAlert(userId);
      
      debugPrint('✅ [HOME] _performDataLoading completed successfully');
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
  
  /// 카드 설정 로드
  Future<void> _loadCardSettings(String userId) async {
    try {
      debugPrint('🃏 [CARD] Starting card settings load for user: $userId');
      debugPrint('🃏 [CARD] Calling service.getUserCardSettings...');
      
      final cardSettings = await _userCardSettingService.getUserCardSettings(userId);
      debugPrint('🃏 [CARD] Service returned ${cardSettings.length} settings');
      
      if (cardSettings.isNotEmpty) {
        debugPrint('🃏 [CARD] Processing ${cardSettings.length} card settings...');
        
        // 표시되는 카드들만 필터링하고 순서대로 정렬
        final visibleCards = cardSettings
            .where((setting) => setting.isVisible)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        _enabledCardTypes = visibleCards.map((setting) => setting.cardType).toList();
        debugPrint('🃏 [CARD] Loaded ${_enabledCardTypes.length} enabled cards: $_enabledCardTypes');
      } else {
        // 기본 카드 설정
        _enabledCardTypes = ['feeding', 'sleep', 'diaper'];
        debugPrint('🃏 [CARD] No card settings found, using defaults: $_enabledCardTypes');
      }
      
      debugPrint('✅ [CARD] Card settings load completed successfully');
    } catch (e) {
      debugPrint('❌ [CARD] Error loading card settings: $e');
      debugPrint('❌ [CARD] Stack trace: ${StackTrace.current}');
      // 에러 시 기본값 사용
      _enabledCardTypes = ['feeding', 'sleep', 'diaper'];
      debugPrint('🃏 [CARD] Using fallback defaults due to error');
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

  /// 동적 카드 그리드 생성 (단순화된 버전)
  Widget _buildDynamicCardGrid() {
    debugPrint('🏠 [HOME] _buildDynamicCardGrid called');
    debugPrint('🏠 [HOME] Enabled card types: $_enabledCardTypes');
    
    try {
      // 안전장치: 최대 6개 카드로 제한
      final limitedCardTypes = _enabledCardTypes.length > 6 
          ? _enabledCardTypes.sublist(0, 6) 
          : _enabledCardTypes;
      
      debugPrint('🏠 [HOME] Building ${limitedCardTypes.length} cards');
      
      // 각 카드 타입에 맞는 위젯 생성
      final List<Widget> cardWidgets = [];
      for (final cardType in limitedCardTypes) {
        Widget? card = _buildCardWidget(cardType);
        if (card != null) {
          cardWidgets.add(card);
        }
      }
      
      debugPrint('🏠 [HOME] Successfully built ${cardWidgets.length} card widgets');
      
      // 간단한 Grid 레이아웃 (3열)
      return _buildSimpleGrid(cardWidgets);
      
    } catch (e) {
      debugPrint('❌ [HOME] Error in _buildDynamicCardGrid: $e');
      // 폴백: 기본 3개 카드만 표시
      return _buildFallbackGrid();
    }
  }
  
  /// 카드 타입에 따른 위젯 생성
  Widget? _buildCardWidget(String cardType) {
    try {
      switch (cardType) {
        case 'feeding':
          return FeedingSummaryCard(
            summary: _feedingSummary,
            feedingProvider: _feedingProvider,
            sleepProvider: _sleepProvider,
          );
        case 'sleep':
          return SleepSummaryCard(
            summary: _sleepSummary,
            sleepProvider: _sleepProvider,
          );
        case 'diaper':
          return DiaperSummaryCard(
            summary: _diaperSummary,
            diaperProvider: _diaperProvider,
            sleepProvider: _sleepProvider,
          );
        case 'solid_food':
          return SolidFoodSummaryCard(
            summary: _solidFoodSummary,
            solidFoodProvider: _solidFoodProvider,
            sleepProvider: _sleepProvider,
          );
        case 'medication':
          return MedicationSummaryCard(
            summary: _medicationSummary,
            medicationProvider: _medicationProvider,
            sleepProvider: _sleepProvider,
          );
        case 'milk_pumping':
          return MilkPumpingSummaryCard(
            summary: _milkPumpingSummary,
            milkPumpingProvider: _milkPumpingProvider,
            sleepProvider: _sleepProvider,
          );
        case 'temperature':
          return ChangeNotifierProvider.value(
            value: _healthProvider,
            child: TemperatureSummaryCard(
              summary: _temperatureSummary,
            ),
          );
        default:
          debugPrint('⚠️ [HOME] Unknown card type: $cardType');
          return null;
      }
    } catch (e) {
      debugPrint('❌ [HOME] Error building card $cardType: $e');
      return null;
    }
  }
  
  /// 간단한 그리드 레이아웃 (카드 개수에 따라 동적 배치)
  Widget _buildSimpleGrid(List<Widget> cards) {
    debugPrint('🏠 [HOME] Building grid with ${cards.length} cards');
    
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 카드 개수에 따른 열 수 결정
    int columnsPerRow;
    if (cards.length <= 3) {
      columnsPerRow = 3; // 1-3개: 1행에 모두 배치
    } else if (cards.length == 4) {
      columnsPerRow = 2; // 4개: 2x2
    } else {
      columnsPerRow = 3; // 5-6개: 3열로 배치
    }
    
    final List<Widget> rows = [];
    for (int i = 0; i < cards.length; i += columnsPerRow) {
      final List<Widget> rowChildren = [];
      
      for (int j = 0; j < columnsPerRow; j++) {
        if (i + j < cards.length) {
          rowChildren.add(Expanded(child: cards[i + j]));
          if (j < columnsPerRow - 1 && i + j + 1 < cards.length) {
            rowChildren.add(const SizedBox(width: 8));
          }
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }
      
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + columnsPerRow < cards.length ? 12 : 0),
        child: Row(children: rowChildren),
      ));
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: rows),
    );
  }
  
  /// 폴백 그리드 (기본 3개 카드)
  Widget _buildFallbackGrid() {
    debugPrint('🏠 [HOME] Using fallback grid');
    return _buildSimpleGrid([
      FeedingSummaryCard(
        summary: _feedingSummary,
        feedingProvider: _feedingProvider,
        sleepProvider: _sleepProvider,
      ),
      SleepSummaryCard(
        summary: _sleepSummary,
        sleepProvider: _sleepProvider,
      ),
      DiaperSummaryCard(
        summary: _diaperSummary,
        diaperProvider: _diaperProvider,
        sleepProvider: _sleepProvider,
      ),
    ]);
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
                Navigator.of(context).pushNamed('/baby-register');
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
            // 메인 컨텐츠
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentBaby == null
                    ? _buildNoBabyScreen(context)
                    : RefreshIndicator(
                    onRefresh: () async {
                      // RefreshIndicator에서 안전한 새로고침
                      if (!_isLoadingData) {
                        debugPrint('🔄 [HOME] RefreshIndicator triggered - calling _refreshData');
                        await _refreshData();
                      } else {
                        debugPrint('⚠️ [HOME] RefreshIndicator skipped - loading in progress');
                      }
                    },
                    child: CustomScrollView(
                  slivers: [
                    // 앱바
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        // Baby guide list button
                        if (_currentBaby != null)
                          IconButton(
                            icon: Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.onSurface,
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
                            color: theme.colorScheme.onSurface,
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
                    
                    // 오늘의 요약 섹션
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 오늘의 요약 제목과 설정 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.todaySummary ?? '오늘의 요약',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.settings,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    size: 20,
                                  ),
                                  tooltip: '카드 설정',
                                  onPressed: () async {
                                    if (_currentUserId == null || _currentBaby == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
                                      );
                                      return;
                                    }
                                    
                                    debugPrint('🔧 [SETTINGS] Opening card settings...');
                                    
                                    try {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CardSettingsScreen(
                                            userId: _currentUserId!,
                                            babyId: _currentBaby!.id,
                                          ),
                                        ),
                                      );
                                      
                                      debugPrint('🔧 [SETTINGS] Returned from settings, result: $result');
                                      
                                      if (mounted && result == true) {
                                        debugPrint('🔧 [SETTINGS] Settings saved successfully');
                                        
                                        // 간단한 UI 새로고침 (복잡한 로직 제거)
                                        try {
                                          await _loadCardSettings(_currentUserId!);
                                          if (mounted) {
                                            setState(() {});
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('카드 설정이 저장되었습니다'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint('❌ [SETTINGS] Error: $e');
                                        }
                                      } else {
                                        debugPrint('⚠️ [SETTINGS] No result or result is not true: $result');
                                      }
                                    } catch (e) {
                                      debugPrint('❌ [SETTINGS] Error opening settings: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('설정 화면을 열 수 없습니다: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // 동적 카드 렌더링
                            _buildDynamicCardGrid(),
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
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_currentBaby != null) {
                                  Navigator.of(context).pushNamed(
                                    '/growth-chart',
                                    arguments: _currentBaby,
                                  );
                                }
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
    ),
    );
  }
}