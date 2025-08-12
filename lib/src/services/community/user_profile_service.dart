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
      print('DEBUG: getUserProfile called with userId: $userId');
      print('DEBUG: Executing Supabase query: user_profiles.select().eq("user_id", "$userId").maybeSingle()');
      
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      print('DEBUG: Supabase response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');
      print('DEBUG: Response is null: ${response == null}');

      if (response == null) {
        print('DEBUG: No profile found for user_id: $userId');
        return null;
      }
      
      final profile = UserProfile.fromJson(response);
      print('DEBUG: Successfully created UserProfile: $profile');
      return profile;
    } catch (e) {
      print('DEBUG: getUserProfile error: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  // 사용자 프로필 생성
  Future<UserProfile> createUserProfile({
    required String userId,
    required String nickname,
    String? profileImageUrl,
    String? bio,
    String? email,
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
            'email': email,
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

  // 현재 사용자의 프로필 조회 또는 생성 (Supabase + 카카오 통합 버전)
  Future<UserProfile?> getOrCreateCurrentUserProfile({
    String? defaultNickname,
  }) async {
    print('DEBUG: getOrCreateCurrentUserProfile called');
    
    try {
      String? userId;
      String? userEmail;
      
      // 🔐 1순위: Supabase 사용자 확인
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser != null) {
        userId = supabaseUser.id;
        userEmail = supabaseUser.email;
        print('DEBUG: Supabase user found: $userId (email: $userEmail)');
      } else {
        print('DEBUG: No Supabase user found, checking Kakao...');
        
        // 🥇 2순위: 카카오 로그인 사용자 정보 가져오기
        final prefs = await SharedPreferences.getInstance();
        final authService = AuthService(prefs);
        final kakaoUser = await authService.getCurrentUser();
        
        if (kakaoUser == null) {
          print('DEBUG: No Kakao user found either');
          return null;
        }
        
        userId = kakaoUser.id.toString();
        print('DEBUG: Kakao user found: $userId');
      }

      // 기존 프로필 조회
      var profile = await getUserProfile(userId);
      print('DEBUG: Existing profile by user_id: $profile');
      print('DEBUG: Profile found: ${profile != null}');
      print('DEBUG: Profile details: ${profile?.toJson()}');
      
      // 🔍 Supabase 사용자의 경우 이메일로도 기존 프로필 찾기
      if (profile == null && userEmail != null) {
        print('DEBUG: Searching profile by email: $userEmail');
        try {
          final emailResponse = await _supabase
              .from('user_profiles')
              .select()
              .eq('email', userEmail)
              .maybeSingle();
          
          if (emailResponse != null) {
            print('DEBUG: Found existing profile by email: $emailResponse');
            // 🔄 user_id 업데이트 (이메일로 찾은 프로필을 현재 사용자 ID와 연결)
            final updatedResponse = await _supabase
                .from('user_profiles')
                .update({'user_id': userId})
                .eq('email', userEmail)
                .select()
                .single();
            
            profile = UserProfile.fromJson(updatedResponse);
            print('DEBUG: Updated profile with new user_id: $profile');
          }
        } catch (e) {
          print('DEBUG: Email search error: $e');
        }
      }
      
      if (profile == null) {
        print('DEBUG: No existing profile found');
        
        // defaultNickname이 명시적으로 제공된 경우에만 프로필 생성 (닉네임 설정 화면에서 호출)
        if (defaultNickname != null) {
          print('DEBUG: Creating profile with provided nickname: $defaultNickname');
          try {
            profile = await createUserProfile(
              userId: userId,
              nickname: defaultNickname,
              email: userEmail,
            );
            print('DEBUG: Created new profile: $profile');
          } catch (createError) {
            print('DEBUG: Create profile with email failed, trying without email: $createError');
            // 이메일 필드 에러 시 이메일 없이 재시도
            try {
              profile = await createUserProfile(
                userId: userId,
                nickname: defaultNickname,
              );
              print('DEBUG: Created new profile without email: $profile');
            } catch (retryError) {
              print('DEBUG: Failed to create profile even without email: $retryError');
              throw Exception('프로필 생성에 실패했습니다: $retryError');
            }
          }
        } else {
          print('DEBUG: No defaultNickname provided and no existing profile found');
          print('DEBUG: This will cause the nickname setup screen to appear');
          return null;
        }
      } else {
        print('DEBUG: Found existing profile, returning it directly');
        print('DEBUG: Profile nickname: ${profile.nickname}');
        // ✅ 기존 프로필이 있으면 defaultNickname과 관계없이 바로 반환
      }

      print('DEBUG: Final profile to return: $profile');
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