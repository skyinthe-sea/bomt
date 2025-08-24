import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth/secure_auth_service.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/baby.dart';
import '../../domain/models/family_group.dart';
import '../../features/baby/data/repositories/supabase_baby_repository.dart';
import '../../features/baby/domain/entities/baby.dart' as BabyEntity;
import '../../services/family/family_group_service.dart';
import 'dart:async';

class BabyProvider extends ChangeNotifier {
  List<Baby> _babies = [];
  Baby? _selectedBaby;
  String? _currentUserId;
  FamilyGroup? _currentFamilyGroup;
  bool _isLoading = false;
  
  // Repository 및 서비스 인스턴스 추가
  final SupabaseBabyRepository _babyRepository = SupabaseBabyRepository();
  final FamilyGroupService _familyGroupService = FamilyGroupService.instance;

  static const String _selectedBabyIdKey = 'selected_baby_id';
  
  // 🚀 실시간 동기화를 위한 변수들
  RealtimeChannel? _babyUsersChannel;
  RealtimeChannel? _babiesChannel;
  Timer? _debounceTimer;

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _selectedBaby;
  Baby? get selectedBaby => _selectedBaby;
  String? get currentUserId => _currentUserId;
  FamilyGroup? get currentFamilyGroup => _currentFamilyGroup;
  bool get isLoading => _isLoading;
  bool get hasBaby => _selectedBaby != null;
  bool get hasMultipleBabies => _babies.length > 1;
  bool get hasFamilyGroup => _currentFamilyGroup != null;

  /// 아기 정보 로드 (가족 그룹 기반)
  Future<void> loadBabyData() async {
    try {
      debugPrint('🚀 [BABY_PROVIDER] ==========================================');
      debugPrint('🚀 [BABY_PROVIDER] STARTING LOAD BABY DATA WITH DETAILED LOGS');
      debugPrint('🚀 [BABY_PROVIDER] ==========================================');
      _setLoading(true);
      
      // 카카오 로그인에서 받은 user_id 가져오기
      final userId = await _getUserId();
      debugPrint('👶 [BABY_PROVIDER] Retrieved user_id: $userId');
      
      if (userId == null) {
        debugPrint('❌ [BABY_PROVIDER] No user_id found, clearing baby data');
        _clearBabyData();
        return;
      }
      
      // 🚀 가족 그룹 정보 먼저 로드
      debugPrint('🏠 [BABY_PROVIDER] ===== FAMILY GROUP LOADING =====');
      debugPrint('🏠 [BABY_PROVIDER] Loading family group for user: $userId');
      _currentFamilyGroup = await _familyGroupService.getUserFamilyGroup(userId);
      
      if (_currentFamilyGroup == null) {
        // 가족 그룹이 없으면 마이그레이션 시도
        debugPrint('🏠 [BABY_PROVIDER] ⚠️ No family group found, attempting migration...');
        _currentFamilyGroup = await _familyGroupService.migrateUserToFamilyGroup(userId);
      }
      
      if (_currentFamilyGroup == null) {
        debugPrint('❌ [BABY_PROVIDER] ❌ CRITICAL: No family group available after migration');
        _clearBabyData();
        return;
      }
      
      debugPrint('✅ [BABY_PROVIDER] ✅ Family group loaded successfully!');
      debugPrint('🏠 [BABY_PROVIDER] Family Group Details:');
      debugPrint('🏠 [BABY_PROVIDER]   - ID: ${_currentFamilyGroup!.id}');
      debugPrint('🏠 [BABY_PROVIDER]   - Name: ${_currentFamilyGroup!.name}');
      debugPrint('🏠 [BABY_PROVIDER]   - Created By: ${_currentFamilyGroup!.createdBy}');
      
      // 🚀 가족 그룹에 속한 모든 아기 정보 조회 (사용자 상관없이)
      debugPrint('👶 [BABY_PROVIDER] 🔍 Querying ALL babies in family group: ${_currentFamilyGroup!.id}');
      debugPrint('👶 [BABY_PROVIDER] 🔍 Current user: $userId');
      
      // 가족 그룹에 속한 모든 아기를 DISTINCT하게 조회
      final response = await Supabase.instance.client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            family_group_id,
            user_id,
            created_at,
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
          .eq('family_group_id', _currentFamilyGroup!.id);
      
      debugPrint('📊 [BABY_PROVIDER] ===== BABY QUERY RESULTS =====');
      debugPrint('📊 [BABY_PROVIDER] Total baby_users records found: ${response.length}');
      
      for (int i = 0; i < response.length; i++) {
        final record = response[i];
        final babyData = record['babies'];
        debugPrint('📊 [BABY_PROVIDER] Record $i Details:');
        debugPrint('📊 [BABY_PROVIDER]   - baby_id: ${record['baby_id']}');
        debugPrint('📊 [BABY_PROVIDER]   - user_id: ${record['user_id']}');
        debugPrint('📊 [BABY_PROVIDER]   - role: ${record['role']}');
        debugPrint('📊 [BABY_PROVIDER]   - baby_name: ${babyData?['name'] ?? 'NULL'}');
        debugPrint('📊 [BABY_PROVIDER]   - family_group_id: ${record['family_group_id']}');
        debugPrint('📊 [BABY_PROVIDER]   - created_at: ${record['created_at']}');
      }
      
      if (response.isEmpty) {
        // 등록된 아기가 없는 경우
        debugPrint('❌ [BABY_PROVIDER] No babies found in family group: ${_currentFamilyGroup!.id}');
        _clearBabyData();
        return;
      }
      
      // 🚀 중복 제거: Map을 사용해서 고유한 아기만 수집
      final uniqueBabies = <String, Baby>{}; // baby_id를 키로 사용
      final userRoles = <String, String>{}; // 현재 사용자의 아기별 역할 저장
      
      debugPrint('👶 [BABY_PROVIDER] 🔍 Processing ${response.length} baby_users records...');
      
      for (final item in response) {
        final babyId = item['baby_id'] as String;
        final recordUserId = item['user_id'] as String;
        final role = item['role'] as String?;
        
        // 현재 사용자의 역할 정보 저장
        if (recordUserId == userId && role != null) {
          userRoles[babyId] = role;
          debugPrint('👶 [BABY_PROVIDER] 🔍 User role for baby $babyId: $role');
        }
        
        // 중복 체크: 이미 처리한 아기는 건너뛰기
        if (uniqueBabies.containsKey(babyId)) {
          debugPrint('👶 [BABY_PROVIDER] 🔄 Skipped duplicate baby: $babyId');
          continue;
        }
        
        Baby? baby;
        
        if (item['babies'] != null) {
          // JOIN으로 가져온 데이터 사용
          final babyData = item['babies'];
          baby = Baby.fromJson({
            'id': babyData['id'],
            'name': babyData['name'], 
            'birth_date': babyData['birth_date'],
            'gender': babyData['gender'],
            'profile_image_url': babyData['profile_image_url'],
            'created_at': babyData['created_at'],
            'updated_at': babyData['updated_at'],
          });
          debugPrint('👶 [BABY_PROVIDER] ✅ Parsed baby from JOIN: ${baby.name} (${baby.id})');
        } else {
          // 🔧 JOIN 실패 시 baby_id로 직접 조회
          debugPrint('⚠️ [BABY_PROVIDER] JOIN failed for baby_id: $babyId, querying directly...');
          
          try {
            final babyResponse = await Supabase.instance.client
                .from('babies')
                .select('*')
                .eq('id', babyId)
                .maybeSingle();
                
            if (babyResponse != null) {
              baby = Baby.fromJson(babyResponse);
              debugPrint('✅ [BABY_PROVIDER] Baby loaded directly: ${baby.name} (${baby.id})');
            } else {
              debugPrint('❌ [BABY_PROVIDER] Baby not found in direct query: $babyId');
            }
          } catch (e) {
            debugPrint('❌ [BABY_PROVIDER] Error in direct baby query: $e');
          }
        }
        
        if (baby != null) {
          uniqueBabies[babyId] = baby;
        }
      }
      
      final babies = uniqueBabies.values.toList();
      
      debugPrint('🎯 [BABY_PROVIDER] ===== FINAL PROCESSING RESULTS =====');
      debugPrint('🎯 [BABY_PROVIDER] Total unique babies extracted: ${babies.length}');
      debugPrint('🎯 [BABY_PROVIDER] Current user roles: $userRoles');
      debugPrint('🎯 [BABY_PROVIDER] Final babies list:');
      
      for (int i = 0; i < babies.length; i++) {
        final baby = babies[i];
        debugPrint('🎯 [BABY_PROVIDER] Baby $i: ${baby.name} (ID: ${baby.id})');
      }
      
      _babies = babies;
      _currentUserId = userId;
      
      debugPrint('✅ [BABY_PROVIDER] ✅ BABY LOADING COMPLETED: ${babies.length} babies loaded');
      debugPrint('✅ [BABY_PROVIDER] Current user ID set to: $userId');
      debugPrint('✅ [BABY_PROVIDER] Family group: ${_currentFamilyGroup!.name} (${_currentFamilyGroup!.id})');
      
      // 선택된 아기 복원 또는 첫 번째 아기 선택
      await _restoreSelectedBaby();
      
    } catch (e) {
      debugPrint('Error loading baby data: $e');
      _clearBabyData();
    } finally {
      _setLoading(false);
    }
    
    // 🚀 실시간 동기화 리스너 설정
    _setupRealtimeListeners();
  }

  /// 실시간 동기화 리스너 설정
  void _setupRealtimeListeners() {
    if (_currentFamilyGroup == null || _currentUserId == null) {
      debugPrint('⚠️ [REALTIME] Cannot setup listeners: missing family group or user ID');
      return;
    }
    
    debugPrint('🔄 [REALTIME] Setting up realtime listeners for family group: ${_currentFamilyGroup!.id}');
    
    // 기존 리스너 정리
    _cleanupRealtimeListeners();
    
    // baby_users 테이블 변경 감지
    _babyUsersChannel = Supabase.instance.client
        .channel('baby_users_changes_${_currentFamilyGroup!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'baby_users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'family_group_id',
            value: _currentFamilyGroup!.id,
          ),
          callback: (payload) {
            debugPrint('🔄 [REALTIME] baby_users change detected: ${payload.eventType}');
            debugPrint('🔄 [REALTIME] Payload: ${payload.newRecord}');
            _handleBabyUsersChange(payload);
          },
        )
        .subscribe();
    
    // babies 테이블 변경 감지 (아기 정보 업데이트용)
    _babiesChannel = Supabase.instance.client
        .channel('babies_changes_global')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'babies',
          callback: (payload) {
            debugPrint('🔄 [REALTIME] babies change detected: ${payload.eventType}');
            debugPrint('🔄 [REALTIME] Baby data: ${payload.newRecord ?? payload.oldRecord}');
            _handleBabiesChange(payload);
          },
        )
        .subscribe();
        
    debugPrint('✅ [REALTIME] Realtime listeners setup complete');
  }

  /// baby_users 테이블 변경 처리
  void _handleBabyUsersChange(PostgresChangePayload payload) {
    // 디바운싱: 빠른 연속 변경을 방지
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      debugPrint('🔄 [REALTIME] Processing baby_users change after debounce...');
      _reloadBabyDataQuietly();
    });
  }

  /// babies 테이블 변경 처리
  void _handleBabiesChange(PostgresChangePayload payload) {
    final babyId = payload.newRecord?['id'] ?? payload.oldRecord?['id'];
    if (babyId != null) {
      // 현재 가족의 아기인지 확인
      final isOurBaby = _babies.any((baby) => baby.id == babyId);
      if (isOurBaby) {
        debugPrint('🔄 [REALTIME] Our baby $babyId changed, reloading...');
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _reloadBabyDataQuietly();
        });
      }
    }
  }

  /// 조용히 아기 데이터 다시 로드 (로딩 인디케이터 없이)
  Future<void> _reloadBabyDataQuietly() async {
    try {
      debugPrint('🔄 [REALTIME] Quietly reloading baby data...');
      final userId = await _getUserId();
      if (userId == null) return;
      
      // 현재 선택된 아기 ID 저장
      final currentSelectedId = _selectedBaby?.id;
      
      await loadBabyData();
      
      // 이전에 선택된 아기가 여전히 존재하면 다시 선택
      if (currentSelectedId != null) {
        final stillExists = _babies.any((baby) => baby.id == currentSelectedId);
        if (!stillExists) {
          debugPrint('🔄 [REALTIME] Previously selected baby no longer exists, selecting first available');
          if (_babies.isNotEmpty) {
            _selectedBaby = _babies.first;
            await _saveSelectedBabyId(_selectedBaby!.id);
          }
        }
      }
      
      debugPrint('✅ [REALTIME] Quiet reload complete, ${_babies.length} babies loaded');
    } catch (e) {
      debugPrint('❌ [REALTIME] Error in quiet reload: $e');
    }
  }

  /// 실시간 리스너 정리
  void _cleanupRealtimeListeners() {
    debugPrint('🧹 [REALTIME] Cleaning up realtime listeners');
    
    _debounceTimer?.cancel();
    _debounceTimer = null;
    
    if (_babyUsersChannel != null) {
      Supabase.instance.client.removeChannel(_babyUsersChannel!);
      _babyUsersChannel = null;
    }
    
    if (_babiesChannel != null) {
      Supabase.instance.client.removeChannel(_babiesChannel!);
      _babiesChannel = null;
    }
  }

  @override
  void dispose() {
    _cleanupRealtimeListeners();
    super.dispose();
  }

  /// 아기 정보 업데이트
  Future<bool> updateBaby(Baby updatedBaby) async {
    try {
      _setLoading(true);
      
      final response = await Supabase.instance.client
          .from('babies')
          .update({
            'name': updatedBaby.name,
            'birth_date': updatedBaby.birthDate.toIso8601String(),
            'gender': updatedBaby.gender,
            'profile_image_url': updatedBaby.profileImageUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', updatedBaby.id)
          .select()
          .single();
      
      final baby = Baby.fromJson(response);
      
      // babies 리스트 업데이트
      final index = _babies.indexWhere((b) => b.id == baby.id);
      if (index != -1) {
        _babies[index] = baby;
      }
      
      // 선택된 아기인 경우 업데이트
      if (_selectedBaby?.id == baby.id) {
        _selectedBaby = baby;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating baby: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 아기 프로필 이미지 업데이트
  Future<bool> updateProfileImage(String imageUrl) async {
    if (_selectedBaby == null) return false;
    
    try {
      _setLoading(true);
      
      await Supabase.instance.client
          .from('babies')
          .update({
            'profile_image_url': imageUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', _selectedBaby!.id);
      
      final updatedBaby = Baby(
        id: _selectedBaby!.id,
        name: _selectedBaby!.name,
        birthDate: _selectedBaby!.birthDate,
        gender: _selectedBaby!.gender,
        profileImageUrl: imageUrl,
        createdAt: _selectedBaby!.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // babies 리스트 업데이트
      final index = _babies.indexWhere((b) => b.id == updatedBaby.id);
      if (index != -1) {
        _babies[index] = updatedBaby;
      }
      
      _selectedBaby = updatedBaby;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 아기 등록 (Repository 사용)
  Future<bool> registerBaby(Baby baby) async {
    debugPrint('=== BABY REGISTRATION DEBUG START ===');
    debugPrint('🔄 [BABY_PROVIDER] Starting baby registration using repository');
    debugPrint('📋 [BABY_PROVIDER] Baby details:');
    debugPrint('   - ID: ${baby.id}');
    debugPrint('   - Name: ${baby.name}');
    debugPrint('   - Birth Date: ${baby.birthDate}');
    debugPrint('   - Gender: ${baby.gender}');
    debugPrint('   - Current babies count: ${_babies.length}');
    
    try {
      debugPrint('🔑 [BABY_PROVIDER] Step 1: Getting user ID...');
      final userId = await _getUserId();
      if (userId == null) {
        debugPrint('❌ [BABY_PROVIDER] ERROR: No user ID found');
        return false;
      }
      debugPrint('✅ [BABY_PROVIDER] User ID retrieved: $userId');

      debugPrint('🏗️ [BABY_PROVIDER] Step 2: Using SupabaseBabyRepository for registration...');
      
      // Repository를 사용해서 아기 등록 (이미 구현된 로직 재사용)
      final registeredBabyEntity = await _babyRepository.createBaby(
        name: baby.name,
        birthDate: baby.birthDate,
        gender: baby.gender,
        userId: userId,
      );
      
      debugPrint('✅ [BABY_PROVIDER] Baby registered successfully through repository');
      debugPrint('✅ [BABY_PROVIDER] Registered baby ID: ${registeredBabyEntity.id}');

      debugPrint('🔄 [BABY_PROVIDER] Step 3: Converting entity to domain model...');
      // Repository에서 반환된 Entity를 도메인 모델로 변환
      final registeredBaby = Baby(
        id: registeredBabyEntity.id,
        name: registeredBabyEntity.name,
        birthDate: registeredBabyEntity.birthDate,
        gender: registeredBabyEntity.gender,
        profileImageUrl: registeredBabyEntity.profileImageUrl,
        createdAt: registeredBabyEntity.createdAt,
        updatedAt: registeredBabyEntity.updatedAt,
      );

      debugPrint('📦 [BABY_PROVIDER] Step 4: Updating local state...');
      _babies.add(registeredBaby);
      if (_babies.length == 1 || _selectedBaby == null) {
        _selectedBaby = registeredBaby;
        // SharedPreferences 저장을 비동기로 분리 (블로킹 방지)
        _saveSelectedBabyId(registeredBaby.id).catchError((e) {
          debugPrint('Error saving selected baby ID: $e');
        });
      }
      notifyListeners();

      debugPrint('🎉 [BABY_PROVIDER] Baby registered successfully: ${registeredBaby.name}');
      
      // 🚀 가족 그룹 동기화 검증
      await _verifyFamilyGroupSynchronization(registeredBaby.id, userId);
      
      debugPrint('=== BABY REGISTRATION DEBUG END (SUCCESS) ===');
      return true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ [BABY_PROVIDER] Registration error occurred:');
      debugPrint('   - Error: $e');
      debugPrint('   - Error type: ${e.runtimeType}');
      debugPrint('   - Stack trace: $stackTrace');
      debugPrint('=== BABY REGISTRATION DEBUG END (ERROR) ===');
      return false;
    }
  }

  /// 아기 삭제
  Future<bool> deleteBaby(String babyId) async {
    debugPrint('🗑️ [BABY_PROVIDER] Starting baby deletion: $babyId');
    
    try {
      _setLoading(true);
      
      // Repository를 통해 아기 삭제
      await _babyRepository.deleteBaby(babyId);
      
      // 로컬 상태에서 아기 제거
      _babies.removeWhere((baby) => baby.id == babyId);
      
      // 삭제된 아기가 선택된 아기인 경우 처리
      if (_selectedBaby?.id == babyId) {
        if (_babies.isNotEmpty) {
          // 다른 아기가 있으면 첫 번째 아기 선택
          _selectedBaby = _babies.first;
          await _saveSelectedBabyId(_selectedBaby!.id);
        } else {
          // 아기가 없으면 선택 해제
          _selectedBaby = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_selectedBabyIdKey);
        }
      }
      
      notifyListeners();
      debugPrint('✅ [BABY_PROVIDER] Baby deleted successfully: $babyId');
      
      // 🚀 가족 그룹 동기화 검증 (삭제 후)
      final currentUserId = await _getUserId();
      if (currentUserId != null) {
        await _verifyFamilyGroupDesynchronization(babyId, currentUserId);
      }
      
      return true;
      
    } catch (e) {
      debugPrint('❌ [BABY_PROVIDER] Error deleting baby: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// 가족 그룹 동기화 검증 (등록 후)
  Future<void> _verifyFamilyGroupSynchronization(String babyId, String currentUserId) async {
    try {
      debugPrint('🔍 [FAMILY_SYNC] ================================');
      debugPrint('🔍 [FAMILY_SYNC] 가족 그룹 동기화 검증 시작');
      debugPrint('🔍 [FAMILY_SYNC] Baby ID: $babyId');
      debugPrint('🔍 [FAMILY_SYNC] Current User: $currentUserId');
      debugPrint('🔍 [FAMILY_SYNC] ================================');
      
      if (_currentFamilyGroup == null) {
        debugPrint('⚠️ [FAMILY_SYNC] No family group found for verification');
        return;
      }
      
      debugPrint('🏠 [FAMILY_SYNC] Current family group: ${_currentFamilyGroup!.name} (ID: ${_currentFamilyGroup!.id})');
      
      // 1. 가족 그룹의 모든 멤버 조회 (baby_users 테이블에서 고유한 user_id들)
      final familyMembersResponse = await Supabase.instance.client
          .from('baby_users')
          .select('user_id, role')
          .eq('family_group_id', _currentFamilyGroup!.id);
      
      // 고유한 사용자 추출 (같은 사용자가 여러 아기를 가질 수 있으므로)
      final uniqueUsers = <String, Map<String, dynamic>>{};
      for (final record in familyMembersResponse) {
        final userId = record['user_id'] as String;
        if (!uniqueUsers.containsKey(userId)) {
          uniqueUsers[userId] = {
            'user_id': userId,
            'role': record['role'],
          };
        }
      }
      final familyMembers = uniqueUsers.values.toList();
          
      debugPrint('🔍 [FAMILY_SYNC] Family group "${_currentFamilyGroup!.name}" has ${familyMembers.length} unique members:');
      for (final member in familyMembers) {
        final isCurrentUser = member['user_id'] == currentUserId ? ' (👤 CURRENT USER)' : '';
        debugPrint('   - User: ${member['user_id']} - Role: ${member['role']}$isCurrentUser');
      }
      
      if (familyMembers.length == 1) {
        debugPrint('⚠️ [FAMILY_SYNC] 🚨 가족 그룹에 현재 사용자만 있습니다!');
        debugPrint('⚠️ [FAMILY_SYNC] 💡 가족 동기화를 위해서는:');
        debugPrint('⚠️ [FAMILY_SYNC] 1️⃣ 첫 번째 계정에서 가족 초대 코드 생성');
        debugPrint('⚠️ [FAMILY_SYNC] 2️⃣ 두 번째 계정에서 초대 코드 입력');
        debugPrint('⚠️ [FAMILY_SYNC] 3️⃣ 그 후에야 아기 데이터가 실시간 동기화됩니다');
      }
      
      // 2. 해당 아기의 baby_users 레코드 조회
      final babyUserRecords = await Supabase.instance.client
          .from('baby_users')
          .select('user_id, role, created_at')
          .eq('baby_id', babyId)
          .eq('family_group_id', _currentFamilyGroup!.id);
          
      debugPrint('🔍 [FAMILY_SYNC] Baby $babyId has ${babyUserRecords.length} baby_users records:');
      for (final record in babyUserRecords) {
        final isCurrent = record['user_id'] == currentUserId ? ' (CURRENT USER)' : '';
        debugPrint('   - User: ${record['user_id']}$isCurrent, Role: ${record['role']}, Created: ${record['created_at']}');
      }
      
      // 3. 동기화 상태 분석
      final memberUserIds = familyMembers.map((m) => m['user_id'] as String).toSet();
      final babyUserIds = babyUserRecords.map((r) => r['user_id'] as String).toSet();
      
      final missingUserIds = memberUserIds.difference(babyUserIds);
      final extraUserIds = babyUserIds.difference(memberUserIds);
      
      if (missingUserIds.isEmpty && extraUserIds.isEmpty) {
        debugPrint('✅ [FAMILY_SYNC] Perfect synchronization! All ${memberUserIds.length} family members have baby_users records');
      } else {
        if (missingUserIds.isNotEmpty) {
          debugPrint('⚠️ [FAMILY_SYNC] Missing baby_users records for users: $missingUserIds');
        }
        if (extraUserIds.isNotEmpty) {
          debugPrint('⚠️ [FAMILY_SYNC] Extra baby_users records for users: $extraUserIds');
        }
      }
      
    } catch (e) {
      debugPrint('❌ [FAMILY_SYNC] Error verifying family group synchronization: $e');
    }
  }

  /// 가족 그룹 동기화 검증 (삭제 후)
  Future<void> _verifyFamilyGroupDesynchronization(String babyId, String currentUserId) async {
    try {
      debugPrint('🔍 [FAMILY_SYNC] Verifying family group desynchronization for baby: $babyId');
      
      if (_currentFamilyGroup == null) {
        debugPrint('⚠️ [FAMILY_SYNC] No family group found for verification');
        return;
      }
      
      // 해당 아기의 baby_users 레코드 조회 (삭제 후이므로 0개여야 함)
      final remainingRecords = await Supabase.instance.client
          .from('baby_users')
          .select('user_id, role')
          .eq('baby_id', babyId);
          
      if (remainingRecords.isEmpty) {
        debugPrint('✅ [FAMILY_SYNC] Perfect desynchronization! No baby_users records remain for baby $babyId');
      } else {
        debugPrint('⚠️ [FAMILY_SYNC] Warning: ${remainingRecords.length} baby_users records still exist for baby $babyId:');
        for (final record in remainingRecords) {
          debugPrint('   - User: ${record['user_id']}, Role: ${record['role']}');
        }
      }
      
      // 아기 자체도 삭제되었는지 확인
      final babyExists = await Supabase.instance.client
          .from('babies')
          .select('id, name')
          .eq('id', babyId)
          .maybeSingle();
          
      if (babyExists == null) {
        debugPrint('✅ [FAMILY_SYNC] Baby record completely removed from babies table');
      } else {
        debugPrint('⚠️ [FAMILY_SYNC] Warning: Baby record still exists: ${babyExists['name']} ($babyId)');
      }
      
    } catch (e) {
      debugPrint('❌ [FAMILY_SYNC] Error verifying family group desynchronization: $e');
    }
  }

  /// 사용자 ID 가져오기 (개선된 로직 - 이메일 로그인 우선)
  Future<String?> _getUserId() async {
    try {
      debugPrint('🔑 [USER_AUTH] ===== GETTING USER ID =====');
      debugPrint('🔑 [USER_AUTH] Checking current authentication state...');
      
      // 🔐 1순위: Supabase 사용자 확인 (이메일 로그인)
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        debugPrint('✅ [USER_AUTH] ✅ EMAIL LOGIN DETECTED!');
        debugPrint('🔑 [USER_AUTH] Supabase user details:');
        debugPrint('🔑 [USER_AUTH]   - ID: ${supabaseUser.id}');
        debugPrint('🔑 [USER_AUTH]   - Email: ${supabaseUser.email}');
        debugPrint('🔑 [USER_AUTH]   - Phone: ${supabaseUser.phone}');
        debugPrint('🔑 [USER_AUTH]   - Created: ${supabaseUser.createdAt}');
        return supabaseUser.id;
      }
      
      debugPrint('🔍 [BABY_PROVIDER] No Supabase user, checking Kakao...');
      
      // 🥇 2순위: 카카오 로그인 (Fallback)
      try {
        final tokenInfo = await UserApi.instance.accessTokenInfo();
        if (tokenInfo != null) {
          final kakaoUser = await UserApi.instance.me();
          final kakaoUserId = kakaoUser.id.toString();
          debugPrint('✅ [BABY_PROVIDER] Kakao login - Kakao user ID: $kakaoUserId');
          return kakaoUserId;
        }
      } catch (kakaoError) {
        debugPrint('⚠️ [BABY_PROVIDER] Kakao API call failed: $kakaoError');
        // 카카오 에러는 무시하고 계속
      }
      
      debugPrint('❌ [BABY_PROVIDER] No valid user found (neither Supabase nor Kakao)');
      return null;
    } catch (e) {
      debugPrint('❌ [BABY_PROVIDER] Error getting user ID: $e');
      return null;
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // 빌드 중에 호출될 수 있으므로 안전하게 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// 아기 선택
  Future<void> selectBaby(String babyId) async {
    final baby = _babies.firstWhere(
      (b) => b.id == babyId,
      orElse: () => _babies.isNotEmpty ? _babies.first : throw Exception('No baby found'),
    );
    
    _selectedBaby = baby;
    // SharedPreferences 저장을 비동기로 분리 (블로킹 방지)
    _saveSelectedBabyId(babyId).catchError((e) {
      debugPrint('Error saving selected baby ID: $e');
    });
    
    debugPrint('✅ [BABY_PROVIDER] Selected baby: ${baby.name} (ID: $babyId)');
    notifyListeners();
  }

  /// 다음 아기 선택 (순환)
  Future<void> selectNextBaby() async {
    if (_babies.isEmpty) return;
    
    if (_selectedBaby == null) {
      await selectBaby(_babies.first.id);
      return;
    }
    
    final currentIndex = _babies.indexWhere((b) => b.id == _selectedBaby!.id);
    final nextIndex = (currentIndex + 1) % _babies.length;
    await selectBaby(_babies[nextIndex].id);
  }

  /// 수동 새로고침 (가족 동기화 테스트용)
  Future<void> refresh() async {
    debugPrint('🔄 [BABY_PROVIDER] Manual refresh requested');
    await loadBabyData();
  }

  /// 선택된 아기 ID SharedPreferences에 저장
  Future<void> _saveSelectedBabyId(String babyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedBabyIdKey, babyId);
    } catch (e) {
      debugPrint('Error saving selected baby ID: $e');
    }
  }

  /// 선택된 아기 ID SharedPreferences에서 복원
  Future<void> _restoreSelectedBaby() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBabyId = prefs.getString(_selectedBabyIdKey);
      
      if (savedBabyId != null) {
        // 저장된 아기 ID가 현재 babies 리스트에 있는지 확인
        try {
          final baby = _babies.firstWhere((b) => b.id == savedBabyId);
          _selectedBaby = baby;
          debugPrint('✅ [BABY_PROVIDER] Restored selected baby: ${baby.name} (ID: $savedBabyId)');
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('⚠️ [BABY_PROVIDER] Saved baby not found in current list');
        }
      }
      
      // 저장된 아기가 없거나 유효하지 않으면 첫 번째 아기 선택
      if (_babies.isNotEmpty) {
        _selectedBaby = _babies.first;
        // SharedPreferences 저장을 비동기로 분리 (블로킹 방지)
        _saveSelectedBabyId(_babies.first.id).catchError((e) {
          debugPrint('Error saving selected baby ID: $e');
        });
        debugPrint('✅ [BABY_PROVIDER] Selected first baby: ${_babies.first.name}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring selected baby: $e');
      // 오류 발생 시 첫 번째 아기 선택
      if (_babies.isNotEmpty) {
        _selectedBaby = _babies.first;
        notifyListeners();
      }
    }
  }

  /// 아기 데이터 초기화 (가족 그룹 포함)
  void _clearBabyData() {
    _babies.clear();
    _selectedBaby = null;
    _currentUserId = null;
    _currentFamilyGroup = null;
    notifyListeners();
  }


  /// Provider 초기화 (가족 그룹 포함)
  void clear() {
    _babies.clear();
    _selectedBaby = null;
    _currentUserId = null;
    _currentFamilyGroup = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 가족 구성원 자동 연결 (Service Role 사용)
  Future<void> _connectFamilyMembers(String newBabyId, String currentUserId) async {
    try {
      debugPrint('🔍 [FAMILY_CONNECT] Finding family members for user: $currentUserId');
      debugPrint('🔍 [FAMILY_CONNECT] New baby ID: $newBabyId');
      
      // 🔐 인증된 클라이언트 사용 (RLS 정책 적용)
      final client = SupabaseConfig.client;
      
      // 1. 현재 사용자의 가장 최근 아기 찾기 (새 아기 제외)
      final recentBabyResponse = await client
          .from('baby_users')
          .select('baby_id, created_at')
          .eq('user_id', currentUserId)
          .neq('baby_id', newBabyId)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (recentBabyResponse.isEmpty) {
        debugPrint('ℹ️ [FAMILY_CONNECT] No existing babies found - this might be the first baby');
        return;
      }
      
      final mostRecentBabyId = recentBabyResponse[0]['baby_id'] as String;
      debugPrint('🔍 [FAMILY_CONNECT] Most recent baby ID: $mostRecentBabyId');
      
      // 2. 가장 최근 아기를 기준으로 가족 구성원과 그들의 역할 찾기
      final familyMembersResponse = await client
          .from('baby_users')
          .select('user_id, role')
          .eq('baby_id', mostRecentBabyId)
          .neq('user_id', currentUserId); // 본인 제외
      
      debugPrint('🔍 [FAMILY_CONNECT] Found family members: ${familyMembersResponse.length}');
      
      if (familyMembersResponse.isEmpty) {
        debugPrint('ℹ️ [FAMILY_CONNECT] No family members to connect');
        return;
      }
      
      // 3. 가족 구성원들을 새 아기와 연결 (기존 역할 유지)
      final insertData = familyMembersResponse.map<Map<String, dynamic>>((record) {
        final memberId = record['user_id'] as String;
        final memberRole = record['role'] as String;
        
        debugPrint('🔗 [FAMILY_CONNECT] Connecting member $memberId with role $memberRole');
        
        return {
          'baby_id': newBabyId,
          'user_id': memberId,
          'role': memberRole, // ⭐ 기존 역할 유지 (owner는 owner로, parent는 parent로)
          'created_at': DateTime.now().toUtc().toIso8601String(),
        };
      }).toList();
      
      debugPrint('🔗 [FAMILY_CONNECT] Connecting ${insertData.length} family members to new baby');
      debugPrint('🔗 [FAMILY_CONNECT] Insert data: $insertData');
      
      // 배치로 한번에 삽입 (인증된 사용자로 RLS 정책 적용)
      final batchInsertResult = await client
          .from('baby_users')
          .insert(insertData);
      
      debugPrint('✅ [FAMILY_CONNECT] Successfully connected family members');
      debugPrint('✅ [FAMILY_CONNECT] Batch insert result: $batchInsertResult');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [FAMILY_CONNECT] Error connecting family members: $e');
      debugPrint('❌ [FAMILY_CONNECT] Stack trace: $stackTrace');
      // 가족 연결 실패해도 아기 등록 자체는 성공으로 처리
    }
  }
}