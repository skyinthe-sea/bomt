import 'package:supabase_flutter/supabase_flutter.dart';

/// 잘못된 수면 기간 데이터를 수정하는 스크립트
/// 
/// 실행 방법:
/// dart run scripts/fix_sleep_durations.dart
/// 
/// 이 스크립트는 다음을 수행합니다:
/// 1. 음수 duration_minutes를 가진 수면 기록 찾기
/// 2. started_at과 ended_at 시간차를 이용해 올바른 duration 계산
/// 3. 1분 미만의 매우 짧은 수면은 1분으로 설정
Future<void> main() async {
  try {
    print('수면 기간 데이터 수정을 시작합니다...');
    
    // Supabase 초기화 (실제 프로젝트에서는 설정값 사용)
    await Supabase.initialize(
      url: 'https://gowkatetjgcawxemuabm.supabase.co',
      anonKey: 'your-anon-key', // 실제 키로 교체 필요
    );
    
    final supabase = Supabase.instance.client;
    
    // 1. 문제가 있는 수면 기록 조회 (음수 duration 또는 매우 큰 값)
    final problematicSleeps = await supabase
        .from('sleeps')
        .select('id, started_at, ended_at, duration_minutes')
        .or('duration_minutes.lt.0,duration_minutes.gt.1440') // 음수이거나 24시간 초과
        .neq('ended_at', null);
    
    print('문제가 있는 수면 기록 ${problematicSleeps.length}개 발견');
    
    // 2. 각 기록의 duration을 올바르게 계산하고 업데이트
    for (var sleep in problematicSleeps) {
      try {
        final startedAt = DateTime.parse(sleep['started_at']).toUtc();
        final endedAt = DateTime.parse(sleep['ended_at']).toUtc();
        final calculatedMinutes = endedAt.difference(startedAt).inMinutes;
        
        // 최소 1분, 최대 24시간으로 제한
        final correctedMinutes = calculatedMinutes < 1 
            ? 1 
            : (calculatedMinutes > 1440 ? 1440 : calculatedMinutes);
        
        await supabase
            .from('sleeps')
            .update({'duration_minutes': correctedMinutes})
            .eq('id', sleep['id']);
        
        print('수면 기록 ${sleep['id']} 수정: ${sleep['duration_minutes']}분 → $correctedMinutes분');
      } catch (e) {
        print('수면 기록 ${sleep['id']} 수정 실패: $e');
      }
    }
    
    // 3. 수정 결과 확인
    final updatedSleeps = await supabase
        .from('sleeps')
        .select('id, duration_minutes')
        .or('duration_minutes.lt.0,duration_minutes.gt.1440');
    
    if (updatedSleeps.isEmpty) {
      print('✅ 모든 수면 기간 데이터가 올바르게 수정되었습니다.');
    } else {
      print('⚠️  아직 ${updatedSleeps.length}개의 문제가 있는 기록이 남아있습니다.');
    }
    
    // 4. 오늘의 수면 통계 출력
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final todaySleeps = await supabase
        .from('sleeps')
        .select('duration_minutes')
        .gte('started_at', startOfDay.toIso8601String())
        .gt('duration_minutes', 0);
    
    final totalMinutes = todaySleeps.fold<int>(
        0, (sum, sleep) => sum + (sleep['duration_minutes'] as int));
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    
    print('📊 오늘의 수면 통계:');
    print('   - 수면 횟수: ${todaySleeps.length}회');
    print('   - 총 수면시간: ${totalHours}시간 ${remainingMinutes}분');
    
  } catch (e) {
    print('❌ 오류 발생: $e');
  }
}