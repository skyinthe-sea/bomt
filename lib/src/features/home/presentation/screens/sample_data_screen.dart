import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SampleDataScreen extends StatefulWidget {
  const SampleDataScreen({super.key});

  @override
  State<SampleDataScreen> createState() => _SampleDataScreenState();
}

class _SampleDataScreenState extends State<SampleDataScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _message = '';

  Future<void> _insertSampleData() async {
    setState(() {
      _isLoading = true;
      _message = 'Inserting sample data...';
    });

    final userId = '4271061560';
    
    try {
      // 1. Check if baby exists
      final existingBabies = await _supabase
          .from('babies')
          .select()
          .eq('user_id', userId)
          .eq('name', '임지서');

      String babyId;
      
      if (existingBabies.isEmpty) {
        // Create baby
        final babyResponse = await _supabase
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
        _updateMessage('Created baby: $babyId');
      } else {
        babyId = existingBabies[0]['id'];
        _updateMessage('Using existing baby: $babyId');
      }

      // 2. Insert feeding records
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      await _supabase.from('feedings').delete()
          .eq('baby_id', babyId)
          .gte('feed_time', today.toIso8601String());
      
      final feedingTimes = [
        today.add(Duration(hours: 6, minutes: 30)),
        today.add(Duration(hours: 9, minutes: 15)),
        today.add(Duration(hours: 12, minutes: 0)),
        today.add(Duration(hours: 15, minutes: 30)),
        today.add(Duration(hours: 18, minutes: 45)),
      ];

      for (var feedTime in feedingTimes) {
        await _supabase.from('feedings').insert({
          'baby_id': babyId,
          'feed_type': 'bottle',
          'amount': 150 + (DateTime.now().millisecond % 50),
          'unit': 'ml',
          'feed_time': feedTime.toIso8601String(),
          'duration': 15 + (DateTime.now().millisecond % 10),
        });
      }
      _updateMessage('Inserted ${feedingTimes.length} feeding records');

      // 3. Insert sleep records
      await _supabase.from('sleeps').delete()
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
        await _supabase.from('sleeps').insert({
          'baby_id': babyId,
          'start_time': session['start']!.toIso8601String(),
          'end_time': session['end']!.toIso8601String(),
          'quality': 'good',
        });
      }
      _updateMessage('Inserted ${sleepSessions.length} sleep records');

      // 4. Insert diaper records
      await _supabase.from('diapers').delete()
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
        await _supabase.from('diapers').insert({
          'baby_id': babyId,
          'change_time': (change['time'] as DateTime).toIso8601String(),
          'diaper_type': change['type'],
        });
      }
      _updateMessage('Inserted ${diaperChanges.length} diaper records');

      // 5. Insert temperature records
      await _supabase.from('health_records').delete()
          .eq('baby_id', babyId)
          .eq('record_type', 'temperature')
          .gte('record_time', today.toIso8601String());
      
      final tempReadings = [
        {'time': today.add(Duration(hours: 7)), 'temp': 36.5},
        {'time': today.add(Duration(hours: 13)), 'temp': 36.8},
        {'time': today.add(Duration(hours: 19)), 'temp': 37.2},
      ];

      for (var reading in tempReadings) {
        await _supabase.from('health_records').insert({
          'baby_id': babyId,
          'record_type': 'temperature',
          'record_time': (reading['time'] as DateTime).toIso8601String(),
          'temperature': reading['temp'],
        });
      }
      _updateMessage('Inserted ${tempReadings.length} temperature records');

      // 6. Insert growth records
      await _supabase.from('growth_records').insert({
        'baby_id': babyId,
        'weight': 7.8,
        'height': 68.5,
        'measurement_date': today.toIso8601String(),
      });
      
      // Insert a previous measurement
      await _supabase.from('growth_records').insert({
        'baby_id': babyId,
        'weight': 7.5,
        'height': 67.0,
        'measurement_date': today.subtract(Duration(days: 14)).toIso8601String(),
      });
      _updateMessage('Inserted growth records');

      setState(() {
        _isLoading = false;
        _message = '✅ Sample data inserted successfully!\nBaby ID: $babyId';
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '❌ Error: $e';
      });
    }
  }

  void _updateMessage(String msg) {
    setState(() {
      _message += '\n$msg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert Sample Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _insertSampleData,
                  child: const Text('Insert Sample Data for 임지서'),
                ),
              const SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}