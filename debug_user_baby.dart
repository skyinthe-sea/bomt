import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://sqykxfemyjzpcaqrdqkl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxeWt4ZmVteWp6cGNhcXJkcWtsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzMTQ0MjksImV4cCI6MjA0Njg5MDQyOX0.t6W6xRdKWUmZAMdMllqfaL5e41M-Rn9qYLqnfmIdgYw',
  );

  final client = Supabase.instance.client;
  final userId = '4271061560'; // From debug logs

  print('🔍 [DEBUG] Checking user and baby data for user_id: $userId');

  try {
    // Check baby_users table
    print('\n📊 [DEBUG] Querying baby_users table...');
    final babyUsersResponse = await client
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
    
    print('📊 [DEBUG] baby_users response: $babyUsersResponse');
    
    if (babyUsersResponse.isEmpty) {
      print('❌ [DEBUG] No baby found for user_id: $userId');
      
      // Check if this user_id exists in any other table
      print('\n🔍 [DEBUG] Checking if user exists in feedings table...');
      final feedingsCheck = await client
          .from('feedings')
          .select('user_id, baby_id, started_at')
          .eq('user_id', userId)
          .limit(5);
      print('🔍 [DEBUG] Feedings for this user: $feedingsCheck');
      
      // Check all baby_users to see what's available
      print('\n🔍 [DEBUG] Checking all baby_users...');
      final allBabyUsers = await client
          .from('baby_users')
          .select('user_id, baby_id')
          .limit(10);
      print('🔍 [DEBUG] All baby_users: $allBabyUsers');
      
    } else {
      final babyData = babyUsersResponse.first;
      final babyId = babyData['baby_id'];
      print('✅ [DEBUG] Found baby: ${babyData['babies']}');
      
      // Check feedings for this user and baby
      print('\n🍼 [DEBUG] Checking feedings for user: $userId, baby: $babyId');
      final feedingsResponse = await client
          .from('feedings')
          .select('started_at, amount_ml, duration_minutes')
          .eq('user_id', userId)
          .eq('baby_id', babyId)
          .order('started_at', ascending: false)
          .limit(10);
      
      print('🍼 [DEBUG] Recent feedings: $feedingsResponse');
      
      // Check date range for this week
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
      
      print('\n📅 [DEBUG] Weekly date range: $startDate to $endDate');
      
      final weeklyFeedings = await client
          .from('feedings')
          .select('started_at, amount_ml')
          .eq('user_id', userId)
          .eq('baby_id', babyId)
          .gte('started_at', startDate.toUtc().toIso8601String())
          .lte('started_at', endDate.toUtc().toIso8601String());
      
      print('🍼 [DEBUG] Feedings in this week: $weeklyFeedings');
      
      // Check user_card_settings
      print('\n🃏 [DEBUG] Checking user_card_settings...');
      final cardSettings = await client
          .from('user_card_settings')
          .select('card_type, is_visible')
          .eq('user_id', userId);
      
      print('🃏 [DEBUG] Card settings: $cardSettings');
      
      final visibleCards = cardSettings.where((setting) => setting['is_visible'] == true).toList();
      print('🃏 [DEBUG] Visible cards: $visibleCards');
    }
    
  } catch (e) {
    print('❌ [DEBUG] Error: $e');
    print('❌ [DEBUG] Stack trace: ${StackTrace.current}');
  }
}