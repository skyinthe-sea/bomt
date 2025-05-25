import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mfugdpufeqfqzmwlkqne.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mdWdkcHVmZXFmcXptd2xrcW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0OTM1NDgsImV4cCI6MjA1MzA2OTU0OH0.OqAVs-nfx3Cp3Bw4sT38vKcLOGV0LZpBIlYLQbiJG5g',
  );

  final supabase = Supabase.instance.client;
  final userId = '4271061560';

  try {
    // 1. First, check if baby already exists
    final existingBabies = await supabase
        .from('babies')
        .select()
        .eq('user_id', userId)
        .eq('name', '임지서');

    String babyId;
    
    if (existingBabies.isEmpty) {
      // Create baby if not exists
      final babyResponse = await supabase
          .from('babies')
          .insert({
            'user_id': userId,
            'name': '임지서',
            'birth_date': '2024-10-15',
            'gender': 'male',
          })
          .select()
          .single();
      
      babyId = babyResponse['id'];
      print('Created baby: $babyId');
    } else {
      babyId = existingBabies[0]['id'];
      print('Using existing baby: $babyId');
    }

    // 2. Insert feeding records for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Clear existing data for today (optional)
    await supabase.from('feedings').delete()
        .eq('baby_id', babyId)
        .gte('feed_time', today.toIso8601String());
    
    // Insert feeding records
    final feedingTimes = [
      today.add(Duration(hours: 6, minutes: 30)),
      today.add(Duration(hours: 9, minutes: 15)),
      today.add(Duration(hours: 12, minutes: 0)),
      today.add(Duration(hours: 15, minutes: 30)),
      today.add(Duration(hours: 18, minutes: 45)),
    ];

    for (var feedTime in feedingTimes) {
      await supabase.from('feedings').insert({
        'baby_id': babyId,
        'feed_type': 'bottle',
        'amount': 150 + (DateTime.now().millisecond % 50),
        'unit': 'ml',
        'feed_time': feedTime.toIso8601String(),
        'duration': 15 + (DateTime.now().millisecond % 10),
      });
    }
    print('Inserted ${feedingTimes.length} feeding records');

    // 3. Insert sleep records
    await supabase.from('sleeps').delete()
        .eq('baby_id', babyId)
        .gte('start_time', today.toIso8601String());
    
    final sleepSessions = [
      {
        'start': today.add(Duration(hours: 0, minutes: 30)),
        'end': today.add(Duration(hours: 6, minutes: 0)),
      },
      {
        'start': today.add(Duration(hours: 10, minutes: 0)),
        'end': today.add(Duration(hours: 11, minutes: 30)),
      },
      {
        'start': today.add(Duration(hours: 13, minutes: 0)),
        'end': today.add(Duration(hours: 14, minutes: 30)),
      },
    ];

    for (var session in sleepSessions) {
      await supabase.from('sleeps').insert({
        'baby_id': babyId,
        'start_time': session['start']!.toIso8601String(),
        'end_time': session['end']!.toIso8601String(),
        'quality': 'good',
      });
    }
    print('Inserted ${sleepSessions.length} sleep records');

    // 4. Insert diaper records
    await supabase.from('diapers').delete()
        .eq('baby_id', babyId)
        .gte('change_time', today.toIso8601String());
    
    final diaperChanges = [
      {'time': today.add(Duration(hours: 6, minutes: 15)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 8, minutes: 30)), 'type': 'dirty'},
      {'time': today.add(Duration(hours: 11, minutes: 0)), 'type': 'mixed'},
      {'time': today.add(Duration(hours: 14, minutes: 0)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 16, minutes: 30)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 19, minutes: 0)), 'type': 'dirty'},
    ];

    for (var change in diaperChanges) {
      await supabase.from('diapers').insert({
        'baby_id': babyId,
        'change_time': (change['time'] as DateTime).toIso8601String(),
        'diaper_type': change['type'],
      });
    }
    print('Inserted ${diaperChanges.length} diaper records');

    // 5. Insert temperature records
    await supabase.from('health_records').delete()
        .eq('baby_id', babyId)
        .eq('record_type', 'temperature')
        .gte('record_time', today.toIso8601String());
    
    final tempReadings = [
      {'time': today.add(Duration(hours: 7)), 'temp': 36.5},
      {'time': today.add(Duration(hours: 13)), 'temp': 36.8},
      {'time': today.add(Duration(hours: 19)), 'temp': 37.2},
    ];

    for (var reading in tempReadings) {
      await supabase.from('health_records').insert({
        'baby_id': babyId,
        'record_type': 'temperature',
        'record_time': (reading['time'] as DateTime).toIso8601String(),
        'temperature': reading['temp'],
      });
    }
    print('Inserted ${tempReadings.length} temperature records');

    // 6. Insert growth records
    // Check for existing growth records
    final existingGrowth = await supabase
        .from('growth_records')
        .select()
        .eq('baby_id', babyId)
        .order('measurement_date', ascending: false)
        .limit(1);
    
    // Insert today's measurement
    await supabase.from('growth_records').insert({
      'baby_id': babyId,
      'weight': 7.8,
      'height': 68.5,
      'measurement_date': today.toIso8601String(),
    });
    
    // Insert a previous measurement if none exists
    if (existingGrowth.isEmpty) {
      await supabase.from('growth_records').insert({
        'baby_id': babyId,
        'weight': 7.5,
        'height': 67.0,
        'measurement_date': today.subtract(Duration(days: 14)).toIso8601String(),
      });
    }
    print('Inserted growth records');

    print('\nSample data insertion completed successfully!');
    print('Baby ID: $babyId');
    
  } catch (e) {
    print('Error inserting sample data: $e');
  }
}