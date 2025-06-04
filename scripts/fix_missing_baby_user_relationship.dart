import 'dart:io';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  print('🔧 [FIX] Creating missing baby_users relationship for user 4271061560');
  
  // SQL commands to fix the missing relationship
  final userId = '4271061560';
  final babyId = const Uuid().v4();
  final now = DateTime.now().toUtc().toIso8601String();
  
  print('''
📋 [FIX] Execute these SQL commands in Supabase SQL Editor:

-- 1. Create a baby record
INSERT INTO babies (id, name, birth_date, gender, created_at, updated_at)
VALUES (
  '$babyId',
  '테스트 베이비',
  '2024-01-01',
  'unknown',
  '$now',
  '$now'
);

-- 2. Create baby_users relationship
INSERT INTO baby_users (baby_id, user_id, role, created_at)
VALUES (
  '$babyId',
  '$userId',
  'parent',
  '$now'
);

-- 3. Update existing feedings to use this baby_id
UPDATE feedings 
SET baby_id = '$babyId'
WHERE user_id = '$userId' AND baby_id IS NULL;

-- 4. Verify the fix
SELECT 
  bu.user_id,
  bu.baby_id,
  b.name as baby_name,
  COUNT(f.id) as feeding_count
FROM baby_users bu
JOIN babies b ON bu.baby_id = b.id
LEFT JOIN feedings f ON f.user_id = bu.user_id AND f.baby_id = bu.baby_id
WHERE bu.user_id = '$userId'
GROUP BY bu.user_id, bu.baby_id, b.name;
''');

  print('✅ [FIX] Run these commands in Supabase to fix the missing relationship');
}