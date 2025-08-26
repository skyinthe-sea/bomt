import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 🗄️ 오프라인 데이터베이스 (SQLite 기반)
/// 
/// 특징:
/// - 앱이 종료되어도 데이터 보존
/// - 빠른 쿼리 성능
/// - 카테고리별 관리
/// - 자동 만료 처리
/// - 백그라운드 정리
class OfflineDatabase {
  static OfflineDatabase? _instance;
  static OfflineDatabase get instance => _instance ??= OfflineDatabase._();
  
  OfflineDatabase._();

  Database? _database;
  bool _isInitialized = false;

  /// 데이터베이스 테이블 정의
  static const String _tableName = 'cache_data';
  static const String _createTableSql = '''
    CREATE TABLE $_tableName (
      cache_key TEXT PRIMARY KEY,
      data TEXT NOT NULL,
      expiry_time INTEGER NOT NULL,
      category TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'bomt_cache.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(_createTableSql);
          
          // 인덱스 생성으로 성능 최적화
          await db.execute('CREATE INDEX idx_expiry_time ON $_tableName (expiry_time)');
          await db.execute('CREATE INDEX idx_category ON $_tableName (category)');
          
          debugPrint('🗄️ [OFFLINE_DB] Database created with indexes');
        },
      );

      _isInitialized = true;
      debugPrint('🗄️ [OFFLINE_DB] Initialized successfully');
      
      // 초기화 후 만료된 캐시 정리
      await cleanupExpiredCache();
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Initialization failed: $e');
    }
  }

  /// 📝 캐시 저장
  Future<void> setCache({
    required String key,
    required Map<String, dynamic> data,
    required DateTime expiryTime,
    String? category,
  }) async {
    if (_database == null) {
      debugPrint('❌ [OFFLINE_DB] Database not initialized');
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await _database!.insert(
        _tableName,
        {
          'cache_key': key,
          'data': jsonEncode(data),
          'expiry_time': expiryTime.millisecondsSinceEpoch,
          'category': category,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('💾 [OFFLINE_DB] Cached: $key (expires: $expiryTime)');
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Set cache failed for $key: $e');
    }
  }

  /// 📖 캐시 조회
  Future<Map<String, dynamic>?> getCache(String key) async {
    if (_database == null) return null;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final result = await _database!.query(
        _tableName,
        where: 'cache_key = ? AND expiry_time > ?',
        whereArgs: [key, now],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final dataString = row['data'] as String;
        final data = jsonDecode(dataString) as Map<String, dynamic>;
        
        debugPrint('🗄️ [OFFLINE_DB] Cache hit: $key');
        return data;
      }

      // 만료된 캐시가 있다면 삭제
      await _deleteExpiredCache(key);
      return null;
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Get cache failed for $key: $e');
      return null;
    }
  }

  /// 🔍 패턴 기반 캐시 삭제
  Future<void> deleteCacheByPattern(String pattern) async {
    if (_database == null) {
      debugPrint('❌ [OFFLINE_DB] Database not initialized');
      return;
    }

    try {
      // SQLite LIKE 연산자를 위해 * 를 %로 변환
      final likePattern = pattern.replaceAll('*', '%');
      
      final deletedCount = await _database!.delete(
        _tableName,
        where: 'cache_key LIKE ?',
        whereArgs: [likePattern],
      );

      debugPrint('🗺️ [OFFLINE_DB] Deleted by pattern: $pattern ($deletedCount entries)');
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Delete by pattern failed for $pattern: $e');
    }
  }

  /// 🗑️ 캐시 삭제
  Future<void> deleteCache(String key) async {
    if (_database == null) return;

    try {
      final deletedCount = await _database!.delete(
        _tableName,
        where: 'cache_key = ?',
        whereArgs: [key],
      );

      if (deletedCount > 0) {
        debugPrint('🗑️ [OFFLINE_DB] Deleted cache: $key');
      }
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Delete cache failed for $key: $e');
    }
  }

  /// 🧹 카테고리별 캐시 삭제
  Future<void> deleteCacheByCategory(String category) async {
    if (_database == null) return;

    try {
      final deletedCount = await _database!.delete(
        _tableName,
        where: 'category = ?',
        whereArgs: [category],
      );

      debugPrint('🧹 [OFFLINE_DB] Deleted $deletedCount cache entries for category: $category');
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Delete cache by category failed for $category: $e');
    }
  }

  /// ⏰ 만료된 캐시 정리
  Future<void> cleanupExpiredCache() async {
    if (_database == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final deletedCount = await _database!.delete(
        _tableName,
        where: 'expiry_time <= ?',
        whereArgs: [now],
      );

      if (deletedCount > 0) {
        debugPrint('🧹 [OFFLINE_DB] Cleaned up $deletedCount expired cache entries');
      }

      // 데이터베이스 최적화 (VACUUM) - 매주 1회
      await _performMaintenanceIfNeeded();
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Cleanup failed: $e');
    }
  }

  /// 📊 캐시 통계
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_database == null) {
      return {
        'totalEntries': 0,
        'expiredEntries': 0,
        'categories': <String>[],
        'oldestEntry': null,
        'newestEntry': null,
      };
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 전체 엔트리 수
      final totalResult = await _database!.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      final totalEntries = totalResult.first['count'] as int;

      // 만료된 엔트리 수
      final expiredResult = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE expiry_time <= ?',
        [now],
      );
      final expiredEntries = expiredResult.first['count'] as int;

      // 카테고리 목록
      final categoryResult = await _database!.rawQuery(
        'SELECT DISTINCT category FROM $_tableName WHERE category IS NOT NULL',
      );
      final categories = categoryResult.map((row) => row['category'] as String).toList();

      // 가장 오래된/최신 엔트리
      final oldestResult = await _database!.rawQuery(
        'SELECT MIN(created_at) as oldest FROM $_tableName',
      );
      final newestResult = await _database!.rawQuery(
        'SELECT MAX(created_at) as newest FROM $_tableName',
      );

      final oldestTimestamp = oldestResult.first['oldest'] as int?;
      final newestTimestamp = newestResult.first['newest'] as int?;

      return {
        'totalEntries': totalEntries,
        'expiredEntries': expiredEntries,
        'validEntries': totalEntries - expiredEntries,
        'categories': categories,
        'categoriesCount': categories.length,
        'oldestEntry': oldestTimestamp != null 
            ? DateTime.fromMillisecondsSinceEpoch(oldestTimestamp).toIso8601String()
            : null,
        'newestEntry': newestTimestamp != null 
            ? DateTime.fromMillisecondsSinceEpoch(newestTimestamp).toIso8601String()
            : null,
      };
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Get cache stats failed: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔧 특정 키의 만료된 캐시 삭제
  Future<void> _deleteExpiredCache(String key) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database!.delete(
        _tableName,
        where: 'cache_key = ? AND expiry_time <= ?',
        whereArgs: [key, now],
      );
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Delete expired cache failed for $key: $e');
    }
  }

  /// 🔧 데이터베이스 유지보수
  Future<void> _performMaintenanceIfNeeded() async {
    try {
      // SharedPreferences를 사용하여 마지막 유지보수 시간 확인
      const lastMaintenanceKey = 'last_db_maintenance';
      final now = DateTime.now().millisecondsSinceEpoch;
      const weekInMs = 7 * 24 * 60 * 60 * 1000; // 1주일

      // 간단한 인메모리 체크 (앱 세션 동안만)
      if (_lastMaintenanceTime != null && 
          (now - _lastMaintenanceTime!) < weekInMs) {
        return;
      }

      // VACUUM 실행 (데이터베이스 최적화)
      await _database!.execute('VACUUM');
      _lastMaintenanceTime = now;
      
      debugPrint('🔧 [OFFLINE_DB] Database maintenance completed');
    } catch (e) {
      debugPrint('❌ [OFFLINE_DB] Maintenance failed: $e');
    }
  }

  static int? _lastMaintenanceTime;

  /// 🗄️ 데이터베이스 닫기
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
      debugPrint('🗄️ [OFFLINE_DB] Database closed');
    }
  }
}