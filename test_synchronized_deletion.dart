import 'package:supabase_flutter/supabase_flutter.dart';

/// 동기화된 삭제 테스트 스크립트
/// 가족 구성원 중 한 명이 아기를 삭제하면 모든 가족 구성원에게서 제거되는지 확인
Future<void> main() async {
  // Supabase 초기화
  await Supabase.initialize(
    url: 'https://gowkatetjgcawxemuabm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo',
  );

  final client = Supabase.instance.client;
  
  // 테스트용 가족 구성원 계정들
  final testUsers = [
    'cf844c61-00b1-4333-a691-ed216475fbe9', // myclick90@gmail.com
    '10835e17-610a-42fe-b822-96dc0a9c33a2', // skyinthe_sea@naver.com
  ];

  print('🧪 [SYNC_DELETE_TEST] ================================');
  print('🧪 [SYNC_DELETE_TEST] 동기화된 삭제 테스트 시작');
  print('🧪 [SYNC_DELETE_TEST] ================================\n');

  try {
    // 1. 테스트 전 현재 아기 상태 확인
    print('📋 [TEST] 1. 삭제 전 가족별 아기 목록 확인...');
    
    final Map<String, List<Map<String, dynamic>>> beforeState = {};
    
    for (int i = 0; i < testUsers.length; i++) {
      final userId = testUsers[i];
      final userBabies = await client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            babies (
              id,
              name,
              birth_date
            )
          ''')
          .eq('user_id', userId);

      beforeState[userId] = userBabies;
      
      final accountName = i == 0 ? 'myclick90@gmail.com' : 'skyinthe_sea@naver.com';
      print('📋 [TEST] $accountName ($userId):');
      print('📋 [TEST]   - ${userBabies.length}개 아기');
      for (final baby in userBabies) {
        print('📋 [TEST]   - ${baby['babies']['name']} (${baby['baby_id']})');
      }
      print('');
    }

    // 2. 삭제할 아기 선택 (공통으로 가지고 있는 아기 중 하나)
    final commonBabies = <String, String>{};
    
    // 첫 번째 계정의 아기들을 기준으로 공통 아기 찾기
    for (final baby in beforeState[testUsers[0]]!) {
      final babyId = baby['baby_id'] as String;
      final babyName = baby['babies']['name'] as String;
      
      // 다른 모든 계정에서도 이 아기를 가지고 있는지 확인
      bool isCommon = true;
      for (int i = 1; i < testUsers.length; i++) {
        final otherUserBabies = beforeState[testUsers[i]]!;
        final hasThisBaby = otherUserBabies.any((b) => b['baby_id'] == babyId);
        if (!hasThisBaby) {
          isCommon = false;
          break;
        }
      }
      
      if (isCommon) {
        commonBabies[babyId] = babyName;
      }
    }

    print('👶 [TEST] 2. 공통 아기 목록:');
    if (commonBabies.isEmpty) {
      print('👶 [TEST] ❌ 공통 아기가 없습니다. 먼저 아기를 등록해주세요.');
      return;
    }
    
    commonBabies.forEach((babyId, babyName) {
      print('👶 [TEST] - $babyName ($babyId)');
    });

    // 3. 첫 번째 공통 아기를 삭제 대상으로 선택
    final targetBabyId = commonBabies.keys.first;
    final targetBabyName = commonBabies[targetBabyId]!;
    
    print('\n🗑️ [TEST] 3. 삭제 대상 아기: $targetBabyName ($targetBabyId)');
    print('🗑️ [TEST] RPC 함수를 사용한 동기화된 삭제 시작...\n');

    // 4. delete_baby_from_family_rpc 함수 호출로 동기화된 삭제 수행
    final deleteResult = await client.rpc('delete_baby_from_family_rpc', params: {
      'target_baby_id': targetBabyId,
    });

    print('🗑️ [TEST] RPC 삭제 결과: $deleteResult');

    if (deleteResult['success'] == true) {
      final deletedCount = deleteResult['deleted_count'] ?? 0;
      final familyMembersAffected = deleteResult['family_members_affected'] ?? 0;
      
      print('🗑️ [TEST] ✅ RPC 삭제 성공!');
      print('🗑️ [TEST] - 삭제된 baby_users 관계: ${deletedCount}개');
      print('🗑️ [TEST] - 영향받은 가족 구성원: ${familyMembersAffected}명');
    } else {
      print('🗑️ [TEST] ❌ RPC 삭제 실패: ${deleteResult['error']}');
      return;
    }

    // 5. 삭제 후 상태 확인
    print('\n📋 [TEST] 5. 삭제 후 가족별 아기 목록 확인...');
    
    bool deletionWorked = true;
    
    for (int i = 0; i < testUsers.length; i++) {
      final userId = testUsers[i];
      final userBabies = await client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            babies (
              id,
              name,
              birth_date
            )
          ''')
          .eq('user_id', userId);

      final accountName = i == 0 ? 'myclick90@gmail.com' : 'skyinthe_sea@naver.com';
      print('📋 [TEST] $accountName ($userId):');
      print('📋 [TEST]   - ${userBabies.length}개 아기');
      
      // 삭제된 아기가 여전히 있는지 확인
      final stillHasDeletedBaby = userBabies.any((baby) => baby['baby_id'] == targetBabyId);
      
      if (stillHasDeletedBaby) {
        print('📋 [TEST]   ❌ 삭제된 아기가 여전히 존재함: $targetBabyName');
        deletionWorked = false;
      } else {
        print('📋 [TEST]   ✅ 삭제된 아기가 올바르게 제거됨');
      }
      
      for (final baby in userBabies) {
        print('📋 [TEST]   - ${baby['babies']['name']} (${baby['baby_id']})');
      }
      print('');
    }

    // 6. 결과 분석
    print('🧪 [SYNC_DELETE_TEST] ================================');
    if (deletionWorked) {
      print('🧪 [SYNC_DELETE_TEST] ✅ 동기화된 삭제 성공!');
      print('🧪 [SYNC_DELETE_TEST] ✅ "$targetBabyName" 아기가 모든 가족 구성원에게서 제거됨');
      print('🧪 [SYNC_DELETE_TEST] ✅ 가족 동기화가 정상 작동함');
    } else {
      print('🧪 [SYNC_DELETE_TEST] ❌ 동기화된 삭제 실패');
      print('🧪 [SYNC_DELETE_TEST] ❌ 일부 가족 구성원에게서 아기가 제거되지 않음');
      print('🧪 [SYNC_DELETE_TEST] ❌ RPC 함수 또는 권한 문제 확인 필요');
    }
    print('🧪 [SYNC_DELETE_TEST] ================================');

  } catch (e, stackTrace) {
    print('❌ [TEST] 테스트 실패: $e');
    print('❌ [TEST] 스택 트레이스: $stackTrace');
  }
}