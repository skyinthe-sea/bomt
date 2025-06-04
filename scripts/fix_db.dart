import 'dart:io';
import 'dart:convert';

const supabaseUrl = 'https://gowkatetjgcawxemuabm.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo';

Future<dynamic> makeRequest(String table, String method, {Map<String, dynamic>? body, String? query}) async {
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
  client.close();

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return responseBody.isNotEmpty ? json.decode(responseBody) : null;
  } else {
    throw Exception('Request failed: ${response.statusCode} $responseBody');
  }
}

Future<void> main() async {
  final userId = '4271061560';

  try {
    print('🔍 [CHECK] Checking database state for user: $userId');
    
    // Check baby_users relationship
    final babyUsers = await makeRequest(
      'baby_users',
      'GET',
      query: '?user_id=eq.$userId&select=baby_id,role,babies(id,name)',
    );
    
    print('🔍 [CHECK] baby_users: $babyUsers');
    
    // Check feedings
    final feedings = await makeRequest(
      'feedings',
      'GET',
      query: '?user_id=eq.$userId&select=user_id,baby_id,started_at&limit=3',
    );
    
    print('🔍 [CHECK] feedings: $feedings');
    
    if ((babyUsers as List).isEmpty && (feedings as List).isNotEmpty) {
      print('❌ [ISSUE] User has feedings but no baby_users relationship!');
      print('📋 [SOLUTION] Need to create baby and baby_users records');
      
      // Generate simple UUID
      final babyId = 'baby-${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toUtc().toIso8601String();
      
      print('🔧 [FIX] Creating baby: $babyId');
      final baby = await makeRequest(
        'babies',
        'POST',
        body: {
          'id': babyId,
          'name': '임지서',
          'birth_date': '2024-10-15',
          'gender': 'male',
          'created_at': now,
          'updated_at': now,
        },
      );
      print('✅ Created baby: $baby');
      
      print('🔧 [FIX] Creating baby_users relationship');
      final babyUser = await makeRequest(
        'baby_users',
        'POST',
        body: {
          'baby_id': babyId,
          'user_id': userId,
          'role': 'parent',
          'created_at': now,
        },
      );
      print('✅ Created baby_users: $babyUser');
      
      print('🔧 [FIX] Updating feedings with baby_id');
      final updatedFeedings = await makeRequest(
        'feedings',
        'PATCH',
        query: '?user_id=eq.$userId&baby_id=is.null',
        body: {'baby_id': babyId},
      );
      print('✅ Updated feedings: $updatedFeedings');
      
    } else if ((babyUsers as List).isNotEmpty) {
      print('✅ [OK] Baby_users relationship exists');
    } else {
      print('⚠️ [WARN] No feedings found');
    }
    
  } catch (e) {
    print('❌ [ERROR] $e');
  }
}