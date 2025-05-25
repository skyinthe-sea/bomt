import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

const supabaseUrl = 'https://mfugdpufeqfqzmwlkqne.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mdWdkcHVmZXFmcXptd2xrcW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0OTM1NDgsImV4cCI6MjA1MzA2OTU0OH0.OqAVs-nfx3Cp3Bw4sT38vKcLOGV0LZpBIlYLQbiJG5g';

Future<dynamic> supabaseRequest(String table, String method, {Map<String, dynamic>? body, String? query}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/$table${query ?? ''}');
  final headers = {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  http.Response response;
  switch (method) {
    case 'GET':
      response = await http.get(uri, headers: headers);
      break;
    case 'POST':
      response = await http.post(uri, headers: headers, body: json.encode(body));
      break;
    case 'DELETE':
      response = await http.delete(uri, headers: headers);
      break;
    default:
      throw Exception('Unsupported method: $method');
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response.body.isNotEmpty ? json.decode(response.body) : null;
  } else {
    throw Exception('Request failed: ${response.statusCode} ${response.body}');
  }
}

Future<void> main() async {
  final userId = '4271061560';
  
  try {
    // 1. Check if baby exists
    print('Checking for existing baby...');
    final existingBabies = await supabaseRequest(
      'babies',
      'GET',
      query: '?user_id=eq.$userId&name=eq.임지서',
    );

    String babyId;
    
    if ((existingBabies as List).isEmpty) {
      // Create baby
      print('Creating new baby...');
      final babyResponse = await supabaseRequest(
        'babies',
        'POST',
        body: {
          'user_id': userId,
          'name': '임지서',
          'birth_date': '2024-10-15',
          'gender': 'male',
        },
      );
      babyId = babyResponse[0]['id'];
      print('Created baby: $babyId');
    } else {
      babyId = existingBabies[0]['id'];
      print('Using existing baby: $babyId');
    }

    // 2. Insert feeding records
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    print('Clearing existing feeding records for today...');
    await supabaseRequest(
      'feedings',
      'DELETE',
      query: '?baby_id=eq.$babyId&feed_time=gte.${today.toIso8601String()}',
    );
    
    print('Inserting feeding records...');
    final feedingTimes = [
      today.add(Duration(hours: 6, minutes: 30)),
      today.add(Duration(hours: 9, minutes: 15)),
      today.add(Duration(hours: 12, minutes: 0)),
      today.add(Duration(hours: 15, minutes: 30)),
      today.add(Duration(hours: 18, minutes: 45)),
    ];

    for (var feedTime in feedingTimes) {
      await supabaseRequest('feedings', 'POST', body: {
        'baby_id': babyId,
        'feed_type': 'bottle',
        'amount': 150 + (now.millisecond % 50),
        'unit': 'ml',
        'feed_time': feedTime.toIso8601String(),
        'duration': 15 + (now.millisecond % 10),
      });
    }
    print('Inserted ${feedingTimes.length} feeding records');

    // 3. Insert sleep records
    print('Clearing existing sleep records for today...');
    await supabaseRequest(
      'sleeps',
      'DELETE',
      query: '?baby_id=eq.$babyId&start_time=gte.${today.toIso8601String()}',
    );
    
    print('Inserting sleep records...');
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
      await supabaseRequest('sleeps', 'POST', body: {
        'baby_id': babyId,
        'start_time': session['start']!.toIso8601String(),
        'end_time': session['end']!.toIso8601String(),
        'quality': 'good',
      });
    }
    print('Inserted ${sleepSessions.length} sleep records');

    // 4. Insert diaper records
    print('Clearing existing diaper records for today...');
    await supabaseRequest(
      'diapers',
      'DELETE',
      query: '?baby_id=eq.$babyId&change_time=gte.${today.toIso8601String()}',
    );
    
    print('Inserting diaper records...');
    final diaperChanges = [
      {'time': today.add(Duration(hours: 6, minutes: 15)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 8, minutes: 30)), 'type': 'dirty'},
      {'time': today.add(Duration(hours: 11, minutes: 0)), 'type': 'mixed'},
      {'time': today.add(Duration(hours: 14, minutes: 0)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 16, minutes: 30)), 'type': 'wet'},
      {'time': today.add(Duration(hours: 19, minutes: 0)), 'type': 'dirty'},
    ];

    for (var change in diaperChanges) {
      await supabaseRequest('diapers', 'POST', body: {
        'baby_id': babyId,
        'change_time': (change['time'] as DateTime).toIso8601String(),
        'diaper_type': change['type'],
      });
    }
    print('Inserted ${diaperChanges.length} diaper records');

    // 5. Insert temperature records
    print('Clearing existing temperature records for today...');
    await supabaseRequest(
      'health_records',
      'DELETE',
      query: '?baby_id=eq.$babyId&record_type=eq.temperature&record_time=gte.${today.toIso8601String()}',
    );
    
    print('Inserting temperature records...');
    final tempReadings = [
      {'time': today.add(Duration(hours: 7)), 'temp': 36.5},
      {'time': today.add(Duration(hours: 13)), 'temp': 36.8},
      {'time': today.add(Duration(hours: 19)), 'temp': 37.2},
    ];

    for (var reading in tempReadings) {
      await supabaseRequest('health_records', 'POST', body: {
        'baby_id': babyId,
        'record_type': 'temperature',
        'record_time': (reading['time'] as DateTime).toIso8601String(),
        'temperature': reading['temp'],
      });
    }
    print('Inserted ${tempReadings.length} temperature records');

    // 6. Insert growth records
    print('Checking existing growth records...');
    final existingGrowth = await supabaseRequest(
      'growth_records',
      'GET',
      query: '?baby_id=eq.$babyId&order=measurement_date.desc&limit=1',
    );
    
    print('Inserting growth records...');
    await supabaseRequest('growth_records', 'POST', body: {
      'baby_id': babyId,
      'weight': 7.8,
      'height': 68.5,
      'measurement_date': today.toIso8601String(),
    });
    
    if ((existingGrowth as List).isEmpty) {
      await supabaseRequest('growth_records', 'POST', body: {
        'baby_id': babyId,
        'weight': 7.5,
        'height': 67.0,
        'measurement_date': today.subtract(Duration(days: 14)).toIso8601String(),
      });
    }
    print('Inserted growth records');

    print('\n✅ Sample data insertion completed successfully!');
    print('Baby ID: $babyId');
    
  } catch (e) {
    print('❌ Error inserting sample data: $e');
  }
}