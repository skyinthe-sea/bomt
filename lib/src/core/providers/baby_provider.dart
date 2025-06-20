import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/baby.dart';

class BabyProvider extends ChangeNotifier {
  List<Baby> _babies = [];
  Baby? _selectedBaby;
  String? _currentUserId;
  bool _isLoading = false;

  static const String _selectedBabyIdKey = 'selected_baby_id';

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _selectedBaby;
  Baby? get selectedBaby => _selectedBaby;
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;
  bool get hasBaby => _selectedBaby != null;
  bool get hasMultipleBabies => _babies.length > 1;

  /// 아기 정보 로드
  Future<void> loadBabyData() async {
    try {
      debugPrint('👶 [BABY_PROVIDER] Starting loadBabyData...');
      _setLoading(true);
      
      // 카카오 로그인에서 받은 user_id 가져오기
      final userId = await _getUserId();
      debugPrint('👶 [BABY_PROVIDER] Retrieved user_id: $userId');
      
      if (userId == null) {
        debugPrint('❌ [BABY_PROVIDER] No user_id found, clearing baby data');
        _clearBabyData();
        return;
      }
      
      // 해당 user_id와 연결된 모든 아기 정보 조회
      debugPrint('👶 [BABY_PROVIDER] Querying baby_users table...');
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
      
      debugPrint('👶 [BABY_PROVIDER] Query response: $response');
      debugPrint('👶 [BABY_PROVIDER] Response length: ${response.length}');
      
      if (response.isEmpty) {
        // 등록된 아기가 없는 경우
        debugPrint('❌ [BABY_PROVIDER] No babies found for user_id: $userId');
        _clearBabyData();
        return;
      }
      
      // 모든 아기 데이터를 파싱
      final babies = <Baby>[];
      for (final item in response) {
        if (item['babies'] != null) {
          final babyData = item['babies'];
          final baby = Baby.fromJson({
            'id': babyData['id'],
            'name': babyData['name'], 
            'birth_date': babyData['birth_date'],
            'gender': babyData['gender'],
            'profile_image_url': babyData['profile_image_url'],
            'created_at': babyData['created_at'],
            'updated_at': babyData['updated_at'],
          });
          babies.add(baby);
        }
      }
      
      _babies = babies;
      _currentUserId = userId;
      
      debugPrint('✅ [BABY_PROVIDER] ${babies.length} babies loaded');
      
      // 선택된 아기 복원 또는 첫 번째 아기 선택
      await _restoreSelectedBaby();
      
    } catch (e) {
      debugPrint('Error loading baby data: $e');
      _clearBabyData();
    } finally {
      _setLoading(false);
    }
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

  /// 아기 등록 (단순화 버전)
  Future<bool> registerBaby(Baby baby) async {
    debugPrint('=== BABY REGISTRATION DEBUG START ===');
    debugPrint('🔄 [BABY_PROVIDER] Starting baby registration');
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

      debugPrint('📝 [BABY_PROVIDER] Step 2: Inserting baby data to babies table...');
      final babyInsertData = {
        'id': baby.id,
        'name': baby.name,
        'birth_date': baby.birthDate.toIso8601String(),
        'gender': baby.gender,
        'profile_image_url': baby.profileImageUrl,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      debugPrint('📄 [BABY_PROVIDER] Baby insert data: $babyInsertData');
      
      final babyInsertResult = await Supabase.instance.client
          .from('babies')
          .insert(babyInsertData);
      debugPrint('✅ [BABY_PROVIDER] Baby insert completed. Result: $babyInsertResult');

      debugPrint('👨‍👩‍👧‍👦 [BABY_PROVIDER] Step 3: Inserting baby_users relation...');
      final relationInsertData = {
        'baby_id': baby.id,
        'user_id': userId,
        'role': 'owner',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
      debugPrint('📄 [BABY_PROVIDER] Relation insert data: $relationInsertData');
      
      final relationInsertResult = await Supabase.instance.client
          .from('baby_users')
          .insert(relationInsertData);
      debugPrint('✅ [BABY_PROVIDER] Baby_users insert completed. Result: $relationInsertResult');

      debugPrint('👨‍👩‍👧‍👦 [BABY_PROVIDER] Step 3: Finding and connecting family members...');
      await _connectFamilyMembers(baby.id, userId);

      debugPrint('📦 [BABY_PROVIDER] Step 4: Updating local state...');
      _babies.add(baby);
      if (_babies.length == 1 || _selectedBaby == null) {
        _selectedBaby = baby;
        // SharedPreferences 저장을 비동기로 분리 (블로킹 방지)
        _saveSelectedBabyId(baby.id).catchError((e) {
          debugPrint('Error saving selected baby ID: $e');
        });
      }
      notifyListeners();

      debugPrint('🎉 [BABY_PROVIDER] Baby registered successfully: ${baby.name}');
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

  /// 사용자 ID 가져오기 (실시간 카카오 API 호출)
  Future<String?> _getUserId() async {
    try {
      debugPrint('🔍 [BABY_PROVIDER] Getting user ID from Kakao API...');
      
      // 카카오 토큰 유효성 검사 및 사용자 정보 가져오기
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      if (tokenInfo != null) {
        // 현재 로그인된 카카오 사용자 정보 가져오기
        final kakaoUser = await UserApi.instance.me();
        final kakaoUserId = kakaoUser.id.toString();
        
        debugPrint('✅ [BABY_PROVIDER] Retrieved Kakao user ID: $kakaoUserId');
        return kakaoUserId;
      } else {
        debugPrint('❌ [BABY_PROVIDER] Invalid Kakao token');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [BABY_PROVIDER] Kakao API error: $e');
      return null;
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
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

  /// 아기 데이터 초기화
  void _clearBabyData() {
    _babies.clear();
    _selectedBaby = null;
    _currentUserId = null;
    notifyListeners();
  }

  /// 아기 데이터 리프레시
  Future<void> refresh() async {
    await loadBabyData();
  }

  /// Provider 초기화
  void clear() {
    _babies.clear();
    _selectedBaby = null;
    _currentUserId = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 가족 구성원 자동 연결
  Future<void> _connectFamilyMembers(String newBabyId, String currentUserId) async {
    try {
      debugPrint('🔍 [FAMILY_CONNECT] Finding family members for user: $currentUserId');
      debugPrint('🔍 [FAMILY_CONNECT] New baby ID: $newBabyId');
      
      // 1. 현재 사용자의 가장 최근 아기 찾기 (새 아기 제외)
      final recentBabyResponse = await Supabase.instance.client
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
      final familyMembersResponse = await Supabase.instance.client
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
      
      // 배치로 한번에 삽입 (최적화)
      final batchInsertResult = await Supabase.instance.client
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