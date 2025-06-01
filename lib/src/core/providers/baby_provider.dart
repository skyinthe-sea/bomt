import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/baby.dart';

class BabyProvider extends ChangeNotifier {
  Baby? _currentBaby;
  String? _currentUserId;
  bool _isLoading = false;

  Baby? get currentBaby => _currentBaby;
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;
  bool get hasBaby => _currentBaby != null;

  /// 아기 정보 로드
  Future<void> loadBabyData() async {
    try {
      _setLoading(true);
      
      // 카카오 로그인에서 받은 user_id 가져오기
      final userId = await _getUserId();
      
      if (userId == null) {
        _clearBabyData();
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
        _clearBabyData();
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
      
      _currentBaby = baby;
      _currentUserId = userId;
      
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
      _currentBaby = baby;
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
    if (_currentBaby == null) return false;
    
    try {
      _setLoading(true);
      
      await Supabase.instance.client
          .from('babies')
          .update({
            'profile_image_url': imageUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', _currentBaby!.id);
      
      _currentBaby = Baby(
        id: _currentBaby!.id,
        name: _currentBaby!.name,
        birthDate: _currentBaby!.birthDate,
        gender: _currentBaby!.gender,
        profileImageUrl: imageUrl,
        createdAt: _currentBaby!.createdAt,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 아기 등록
  Future<bool> registerBaby(Baby baby) async {
    try {
      _setLoading(true);
      
      final userId = await _getUserId();
      if (userId == null) return false;

      // 먼저 babies 테이블에 아기 정보 삽입
      final babyResponse = await Supabase.instance.client
          .from('babies')
          .insert({
            'id': baby.id,
            'name': baby.name,
            'birth_date': baby.birthDate.toIso8601String(),
            'gender': baby.gender,
            'profile_image_url': baby.profileImageUrl,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();

      // baby_users 테이블에 관계 설정
      await Supabase.instance.client
          .from('baby_users')
          .insert({
            'baby_id': baby.id,
            'user_id': userId,
            'role': 'parent',
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });

      _currentBaby = Baby.fromJson(babyResponse);
      _currentUserId = userId;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error registering baby: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 ID 가져오기
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 아기 데이터 초기화
  void _clearBabyData() {
    _currentBaby = null;
    _currentUserId = null;
    notifyListeners();
  }

  /// 아기 데이터 리프레시
  Future<void> refresh() async {
    await loadBabyData();
  }

  /// Provider 초기화
  void clear() {
    _currentBaby = null;
    _currentUserId = null;
    _isLoading = false;
    notifyListeners();
  }
}