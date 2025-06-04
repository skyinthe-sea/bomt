import 'dart:io';
import 'dart:convert';

const supabaseUrl = 'https://gowkatetjgcawxemuabm.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo';

Future<dynamic> supabaseRequest(String table, String method, {Map<String, dynamic>? body, String? query}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/$table${query ?? ''}');
  final headers = {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  final client = HttpClient();
  HttpClientRequest request;
  
  switch (method) {
    case 'GET':
      request = await client.getUrl(uri);
      break;
    case 'POST':
      request = await client.postUrl(uri);
      break;
    case 'PATCH':
      request = await client.patchUrl(uri);
      break;
    default:
      throw Exception('Unsupported method: $method');
  }

  headers.forEach((key, value) {
    request.headers.set(key, value);
  });

  if (body != null) {
    request.write(json.encode(body));
  }

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return responseBody.isNotEmpty ? json.decode(responseBody) : null;
  } else {
    throw Exception('Request failed: ${response.statusCode} $responseBody');
  }
}

String generateUuid() {
  var rng = DateTime.now().millisecondsSinceEpoch;
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(RegExp(r'[xy]'), (match) {
    var r = (rng + (rng / 16).floor()) % 16;
    rng = (rng / 16).floor();
    var v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
    return v.toRadixString(16);
  });
}

Future<void> main() async {
  final userId = '4271061560';

  try {
    print('🔍 [CHECK] Checking current database state for user: $userId');
    
    // 1. Check if baby_users relationship exists
    final existingBabyUsers = await supabaseRequest(
      'baby_users',
      'GET',
      query: '?user_id=eq.$userId&select=baby_id,role,babies(id,name,birth_date,gender)',
    );
    
    print('🔍 [CHECK] Existing baby_users: $existingBabyUsers');
    
    // 2. Check feedings for this user
    final existingFeedings = await supabaseRequest(
      'feedings',
      'GET',
      query: '?user_id=eq.$userId&select=user_id,baby_id,started_at&limit=5',
    );
    
    print('🔍 [CHECK] Existing feedings: $existingFeedings');
    
    if ((existingBabyUsers as List).isEmpty && (existingFeedings as List).isNotEmpty) {
      print('🔧 [FIX] User has feedings but no baby_users relationship. Creating...');
      
      // Generate new baby ID
      final babyId = generateUuid();
      final now = DateTime.now().toUtc().toIso8601String();
      
      // 3. Create baby record
      print('🔧 [FIX] Creating baby record...');
      final babyResponse = await supabaseRequest(
        'babies',
        'POST',
        body: {
          'id': babyId,
          'name': '테스트 베이비',
          'birth_date': '2024-01-01',
          'gender': 'unknown',
          'created_at': now,
          'updated_at': now,
        },
      );
      
      print('✅ [FIX] Created baby: $babyResponse');
      
      // 4. Create baby_users relationship
      print('🔧 [FIX] Creating baby_users relationship...');
      final babyUserResponse = await supabaseRequest(
        'baby_users',
        'POST',
        body: {
          'baby_id': babyId,
          'user_id': userId,
          'role': 'parent',
          'created_at': now,
        },
      );
      
      print('✅ [FIX] Created baby_users relationship: $babyUserResponse');
      
      // 5. Update existing feedings to use this baby_id (if they don't have one)
      final feedingsWithoutBaby = (existingFeedings as List)
          .where((f) => f['baby_id'] == null)
          .length;
      
      if (feedingsWithoutBaby > 0) {
        print('🔧 [FIX] Updating feedings without baby_id...');
        final updateResponse = await supabaseRequest(
          'feedings',
          'PATCH',
          query: '?user_id=eq.$userId&baby_id=is.null',
          body: {'baby_id': babyId},
        );
        
        print('✅ [FIX] Updated feedings: $updateResponse');
      }
      
      // 6. Verify the fix
      print('🔍 [VERIFY] Verifying the fix...');
      final verifyResponse = await supabaseRequest(
        'baby_users',
        'GET',
        query: '?user_id=eq.$userId&select=user_id,baby_id,babies(id,name)',
      );
      
      print('✅ [VERIFY] Final baby_users relationship: $verifyResponse');
      
      // 7. Check if feedings now have baby_id
      final verifyFeedings = await supabaseRequest(
        'feedings',
        'GET',
        query: '?user_id=eq.$userId&baby_id=eq.$babyId&select=user_id,baby_id,started_at&limit=3',
      );
      
      print('✅ [VERIFY] Feedings with baby_id: $verifyFeedings');
      
    } else if ((existingBabyUsers as List).isNotEmpty) {
      print('✅ [OK] Baby_users relationship already exists');
    } else {
      print('⚠️ [WARN] No feedings found for this user');
    }
    
  } catch (e) {
    print('❌ [ERROR] Failed to check/fix database: $e');
  }
}