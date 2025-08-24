import 'package:supabase_flutter/supabase_flutter.dart';

/// 가족 동기화 테스트 및 상태 확인 스크립트
/// 실제 데이터베이스의 정확한 user_id들을 사용합니다
Future<void> main() async {
  // Supabase 초기화
  await Supabase.initialize(
    url: 'https://gowkatetjgcawxemuabm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo',
  );

  final client = Supabase.instance.client;
  
  // 실제 존재하는 사용자 ID들
  final testUsers = [
    'cf844c61-00b1-4333-a691-ed216475fbe9', // Account 1 (3개 아기, 13개 수유기록)
    'test-user-2',                           // Account 2 (2개 아기, 0개 수유기록)
    '10835e17-610a-42fe-b822-96dc0a9c33a2', // Account 3 (2개 아기, 24개 수유기록)
  ];

  print('🧪 [TEST] =========================');
  print('🧪 [TEST] 가족 동기화 상태 테스트 시작');  
  print('🧪 [TEST] =========================\n');

  try {
    // 1. 전체 가족 그룹 정보 확인
    print('📊 [TEST] 1. 가족 그룹 정보 확인...');
    final familyGroups = await client
        .from('family_groups')
        .select('*');
    print('📊 [TEST] 가족 그룹: $familyGroups\n');

    // 2. 각 사용자별 baby_users 현황
    print('👥 [TEST] 2. 사용자별 baby_users 현황...');
    for (int i = 0; i < testUsers.length; i++) {
      final userId = testUsers[i];
      final userBabies = await client
          .from('baby_users')
          .select('''
            baby_id,
            role,
            family_group_id,
            babies (
              id,
              name,
              birth_date
            )
          ''')
          .eq('user_id', userId);

      print('👥 [TEST] Account${i+1} ($userId):');
      print('👥 [TEST]   - ${userBabies.length}개 아기 연결');
      for (final baby in userBabies) {
        print('👥 [TEST]   - ${baby['babies']['name']} (${baby['baby_id']})');
      }
      print('');
    }

    // 3. 가족 그룹별 구성원 분석
    print('🏠 [TEST] 3. 가족 그룹별 구성원 분석...');
    final familyGroupId = '7bd7974b-eb36-45f2-bdd9-990b6c54c820';
    
    final allMembers = await client
        .from('baby_users')
        .select('user_id, family_group_id, role, created_at')
        .eq('family_group_id', familyGroupId);

    // 중복 제거하여 유니크 사용자 추출
    final uniqueMembers = <String, Map<String, dynamic>>{};
    for (final member in allMembers) {
      final userId = member['user_id'] as String;
      if (!uniqueMembers.containsKey(userId)) {
        uniqueMembers[userId] = member;
      }
    }

    print('🏠 [TEST] 가족 그룹 ($familyGroupId):');
    print('🏠 [TEST] 총 ${uniqueMembers.length}명의 구성원');
    uniqueMembers.forEach((userId, data) {
      final accountNum = testUsers.indexOf(userId) + 1;
      print('🏠 [TEST] - Account$accountNum: $userId (${data['role']})');
    });
    print('');

    // 4. 각 아기별 연결 상태
    print('👶 [TEST] 4. 각 아기별 연결 상태...');
    final allBabies = await client
        .from('babies')
        .select('id, name');

    for (final baby in allBabies) {
      final babyId = baby['id'];
      final babyName = baby['name'];
      
      final connections = await client
          .from('baby_users')
          .select('user_id, role')
          .eq('baby_id', babyId);

      print('👶 [TEST] $babyName ($babyId):');
      print('👶 [TEST]   - ${connections.length}명 연결');
      for (final conn in connections) {
        final accountNum = testUsers.indexOf(conn['user_id']) + 1;
        print('👶 [TEST]   - Account$accountNum (${conn['role']})');
      }
      print('');
    }

    // 5. 동기화 상태 결과 분석
    print('📋 [TEST] 5. 동기화 상태 분석...');
    
    bool allSynced = true;
    final expectedConnections = testUsers.length;
    
    for (final baby in allBabies) {
      final babyId = baby['id'];
      final babyName = baby['name'];
      
      final connections = await client
          .from('baby_users')
          .select('user_id')
          .eq('baby_id', babyId);

      if (connections.length != expectedConnections) {
        allSynced = false;
        print('❌ [TEST] $babyName: ${connections.length}/$expectedConnections 연결 (동기화 필요)');
      } else {
        print('✅ [TEST] $babyName: ${connections.length}/$expectedConnections 연결 (완전 동기화)');
      }
    }

    print('\n🧪 [TEST] =========================');
    if (allSynced) {
      print('🧪 [TEST] ✅ 모든 아기가 완전히 동기화됨');
      print('🧪 [TEST] 가족 동기화가 정상 작동 중');
    } else {
      print('🧪 [TEST] ❌ 일부 아기가 동기화되지 않음');
      print('🧪 [TEST] 앱에서 새 아기 추가 테스트 필요');
    }
    print('🧪 [TEST] =========================');

  } catch (e) {
    print('❌ [TEST] 테스트 실패: $e');
    print('❌ [TEST] 스택 트레이스: ${StackTrace.current}');
  }
}