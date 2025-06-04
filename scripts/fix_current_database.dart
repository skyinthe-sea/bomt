import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  // Initialize Supabase with current config
  await Supabase.initialize(
    url: 'https://gowkatetjgcawxemuabm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo',
  );

  final supabase = Supabase.instance.client;
  final userId = '4271061560';

  try {
    print('🔍 [CHECK] Checking current database state for user: $userId');
    
    // 1. Check if baby_users relationship exists
    final existingBabyUsers = await supabase
        .from('baby_users')
        .select('''
          baby_id,
          role,
          babies (
            id,
            name,
            birth_date,
            gender
          )
        ''')
        .eq('user_id', userId);
    
    print('🔍 [CHECK] Existing baby_users: $existingBabyUsers');
    
    // 2. Check feedings for this user
    final existingFeedings = await supabase
        .from('feedings')
        .select('user_id, baby_id, started_at')
        .eq('user_id', userId)
        .limit(5);
    
    print('🔍 [CHECK] Existing feedings: $existingFeedings');
    
    if (existingBabyUsers.isEmpty && existingFeedings.isNotEmpty) {
      print('🔧 [FIX] User has feedings but no baby_users relationship. Creating...');
      
      // Generate new baby ID
      final babyId = const Uuid().v4();
      final now = DateTime.now().toUtc().toIso8601String();
      
      // 3. Create baby record
      final babyResponse = await supabase
          .from('babies')
          .insert({
            'id': babyId,
            'name': '테스트 베이비',
            'birth_date': '2024-01-01',
            'gender': 'unknown',
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();
      
      print('✅ [FIX] Created baby: $babyResponse');
      
      // 4. Create baby_users relationship
      final babyUserResponse = await supabase
          .from('baby_users')
          .insert({
            'baby_id': babyId,
            'user_id': userId,
            'role': 'parent',
            'created_at': now,
          })
          .select()
          .single();
      
      print('✅ [FIX] Created baby_users relationship: $babyUserResponse');
      
      // 5. Update existing feedings to use this baby_id (if they don't have one)
      final feedingsToUpdate = existingFeedings.where((f) => f['baby_id'] == null).toList();
      if (feedingsToUpdate.isNotEmpty) {
        await supabase
            .from('feedings')
            .update({'baby_id': babyId})
            .eq('user_id', userId)
            .isFilter('baby_id', null);
        
        print('✅ [FIX] Updated ${feedingsToUpdate.length} feeding records with baby_id');
      }
      
      // 6. Verify the fix
      final verifyResponse = await supabase
          .from('baby_users')
          .select('''
            user_id,
            baby_id,
            babies (
              id,
              name
            )
          ''')
          .eq('user_id', userId);
      
      print('✅ [VERIFY] Final baby_users relationship: $verifyResponse');
      
      // 7. Check if feedings now have baby_id
      final verifyFeedings = await supabase
          .from('feedings')
          .select('user_id, baby_id, started_at')
          .eq('user_id', userId)
          .eq('baby_id', babyId)
          .limit(3);
      
      print('✅ [VERIFY] Feedings with baby_id: $verifyFeedings');
      
    } else if (existingBabyUsers.isNotEmpty) {
      print('✅ [OK] Baby_users relationship already exists');
    } else {
      print('⚠️ [WARN] No feedings found for this user');
    }
    
  } catch (e) {
    print('❌ [ERROR] Failed to fix database: $e');
    print('❌ [ERROR] Stack trace: ${StackTrace.current}');
  }
}