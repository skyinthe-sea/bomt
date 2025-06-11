import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/user_profile.dart';
import '../../services/auth/auth_service.dart';

class UserProfileService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  // 사용자 프로필 생성
  Future<UserProfile> createUserProfile({
    required String userId,
    required String nickname,
    String? profileImageUrl,
    String? bio,
  }) async {
    try {
      // 닉네임 중복 확인
      final existingProfile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('nickname', nickname)
          .maybeSingle();

      if (existingProfile != null) {
        throw Exception('이미 사용 중인 닉네임입니다.');
      }

      final response = await _supabase
          .from('user_profiles')
          .insert({
            'user_id': userId,
            'nickname': nickname,
            'profile_image_url': profileImageUrl,
            'bio': bio,
          })
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate')) {
        throw Exception('이미 프로필이 존재합니다.');
      }
      throw Exception('사용자 프로필 생성 실패: $e');
    }
  }

  // 사용자 프로필 업데이트
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? nickname,
    String? profileImageUrl,
    String? bio,
  }) async {
    print('DEBUG: UserProfileService.updateUserProfile called');
    print('DEBUG: userId = $userId, nickname = $nickname');
    
    try {
      final updates = <String, dynamic>{};
      
      if (nickname != null) {
        print('DEBUG: Checking nickname availability...');
        // 닉네임 중복 확인 (자신 제외)
        final existingProfile = await _supabase
            .from('user_profiles')
            .select('id')
            .eq('nickname', nickname)
            .neq('user_id', userId)
            .maybeSingle();

        print('DEBUG: Existing profile with nickname: $existingProfile');
        
        if (existingProfile != null) {
          throw Exception('이미 사용 중인 닉네임입니다.');
        }
        updates['nickname'] = nickname;
        print('DEBUG: Nickname is available');
      }
      
      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }
      
      if (bio != null) {
        updates['bio'] = bio;
      }

      if (updates.isEmpty) {
        throw Exception('업데이트할 정보가 없습니다.');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();
      print('DEBUG: Updates to apply: $updates');

      print('DEBUG: Calling database update...');
      
      // 먼저 기존 프로필이 있는지 확인
      final existingProfile = await getUserProfile(userId);
      
      if (existingProfile == null) {
        print('DEBUG: No existing profile found, creating new profile...');
        // 프로필이 없으면 새로 생성
        return await createUserProfile(
          userId: userId,
          nickname: nickname!,
          profileImageUrl: profileImageUrl,
          bio: bio,
        );
      } else {
        print('DEBUG: Updating existing profile...');
        // 기존 프로필 업데이트
        final response = await _supabase
            .from('user_profiles')
            .update(updates)
            .eq('user_id', userId)
            .select()
            .single();

        print('DEBUG: Database update response: $response');
        final profile = UserProfile.fromJson(response);
        print('DEBUG: Updated UserProfile: $profile');
        return profile;
      }
    } catch (e) {
      print('DEBUG: UserProfileService error: $e');
      throw Exception('사용자 프로필 업데이트 실패: $e');
    }
  }

  // 닉네임 중복 확인
  Future<bool> isNicknameAvailable(String nickname, {String? excludeUserId}) async {
    try {
      var query = _supabase
          .from('user_profiles')
          .select('id')
          .eq('nickname', nickname);

      if (excludeUserId != null) {
        query = query.neq('user_id', excludeUserId);
      }

      final response = await query.maybeSingle();
      return response == null;
    } catch (e) {
      throw Exception('닉네임 중복 확인 실패: $e');
    }
  }

  // 현재 사용자의 프로필 조회 또는 생성 (카카오 로그인 버전)
  Future<UserProfile?> getOrCreateCurrentUserProfile({
    String? defaultNickname,
  }) async {
    print('DEBUG: getOrCreateCurrentUserProfile called');
    
    try {
      // 카카오 로그인 사용자 정보 가져오기
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService(prefs);
      final kakaoUser = await authService.getCurrentUser();
      
      if (kakaoUser == null) {
        print('DEBUG: No Kakao user found');
        return null;
      }
      
      final userId = kakaoUser.id.toString();
      print('DEBUG: Kakao user found: $userId');

      // 기존 프로필 조회
      var profile = await getUserProfile(userId);
      print('DEBUG: Existing profile: $profile');
      
      if (profile == null) {
        print('DEBUG: No existing profile, creating new one...');
        // 프로필이 없으면 기본 프로필 생성
        final nickname = defaultNickname ?? 
            '사용자${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        
        profile = await createUserProfile(
          userId: userId,
          nickname: nickname,
        );
        print('DEBUG: Created new profile: $profile');
      }

      return profile;
    } catch (e) {
      print('DEBUG: getOrCreateCurrentUserProfile error: $e');
      // 에러가 발생해도 null 반환 (앱이 크래시되지 않도록)
      return null;
    }
  }

  // 사용자 프로필 삭제
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase
          .from('user_profiles')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('사용자 프로필 삭제 실패: $e');
    }
  }

  // 닉네임으로 사용자 검색
  Future<List<UserProfile>> searchUsersByNickname(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .ilike('nickname', '%$query%')
          .limit(limit);

      return (response as List)
          .map((item) => UserProfile.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('사용자 검색 실패: $e');
    }
  }
}