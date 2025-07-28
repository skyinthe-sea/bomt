import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_database.dart';

/// 🚀 범용 캐싱 서비스 (2024년 최적화 버전)
/// 
/// 특징:
/// - 메모리 + 디스크 + SQLite 3단계 캐싱
/// - 타입 안전한 캐싱
/// - 스마트 만료 시간 관리
/// - 백그라운드 정리
/// - 오프라인 우선 지원
class UniversalCacheService {
  static UniversalCacheService? _instance;
  static UniversalCacheService get instance => _instance ??= UniversalCacheService._();
  
  UniversalCacheService._();

  // 메모리 캐시 (가장 빠름)
  final Map<String, CacheEntry> _memoryCache = {};
  
  // 디스크 캐시 (중간 속도)
  SharedPreferences? _prefs;
  
  // 오프라인 DB (가장 안정적)
  OfflineDatabase? _database;

  // 캐시 전략 정의
  static const Map<CacheStrategy, Duration> _strategyDurations = {
    CacheStrategy.ultraShort: Duration(minutes: 1),     // 실시간 데이터
    CacheStrategy.short: Duration(minutes: 5),          // 자주 변하는 데이터
    CacheStrategy.medium: Duration(minutes: 30),        // 일반 데이터
    CacheStrategy.long: Duration(hours: 6),             // 안정적인 데이터
    CacheStrategy.persistent: Duration(days: 30),       // 정적 데이터
  };

  /// 초기화
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _database = await OfflineDatabase.instance;
      await _cleanupExpiredCache();
      
      debugPrint('🚀 [UNIVERSAL_CACHE] Initialized successfully');
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Initialization failed: $e');
    }
  }

  /// 📝 데이터 캐싱 (범용)
  Future<void> set<T>({
    required String key,
    required T data,
    CacheStrategy strategy = CacheStrategy.medium,
    String? category,
  }) async {
    try {
      final duration = _strategyDurations[strategy]!;
      final serializedData = _serialize(data);
      
      // 1. 메모리 캐시
      _setInMemory(key, serializedData, duration);
      
      // 2. 디스크 캐시 (중요하지 않은 데이터)
      if (strategy != CacheStrategy.persistent) {
        await _setInDisk(key, serializedData, duration);
      }
      
      // 3. 오프라인 DB (중요한 데이터)
      if (strategy == CacheStrategy.long || strategy == CacheStrategy.persistent) {
        await _setInDatabase(key, serializedData, duration, category);
      }
      
      debugPrint('💾 [UNIVERSAL_CACHE] Cached: $key (${strategy.name})');
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Set failed for $key: $e');
    }
  }

  /// 📖 데이터 조회 (범용)
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    try {
      // 1. 메모리 캐시 확인 (가장 빠름)
      final memoryResult = _getFromMemory(key);
      if (memoryResult != null) {
        debugPrint('⚡ [UNIVERSAL_CACHE] Memory hit: $key');
        return _deserialize<T>(memoryResult, fromJson);
      }

      // 2. 디스크 캐시 확인
      final diskResult = await _getFromDisk(key);
      if (diskResult != null) {
        debugPrint('💿 [UNIVERSAL_CACHE] Disk hit: $key');
        // 메모리에도 캐시
        _setInMemory(key, diskResult, const Duration(minutes: 5));
        return _deserialize<T>(diskResult, fromJson);
      }

      // 3. 오프라인 DB 확인
      final dbResult = await _getFromDatabase(key);
      if (dbResult != null) {
        debugPrint('🗄️ [UNIVERSAL_CACHE] Database hit: $key');
        // 상위 캐시에도 저장
        _setInMemory(key, dbResult, const Duration(minutes: 5));
        await _setInDisk(key, dbResult, const Duration(minutes: 30));
        return _deserialize<T>(dbResult, fromJson);
      }

      debugPrint('❌ [UNIVERSAL_CACHE] Cache miss: $key');
      return null;
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Get failed for $key: $e');
      return null;
    }
  }

  /// 🗑️ 캐시 삭제
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      await _prefs?.remove('cache_$key');
      await _database?.deleteCache(key);
      
      debugPrint('🗑️ [UNIVERSAL_CACHE] Removed: $key');
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Remove failed for $key: $e');
    }
  }

  /// 🧹 카테고리별 캐시 삭제
  Future<void> removeCategory(String category) async {
    try {
      // 메모리 캐시에서 카테고리별 삭제
      final keysToRemove = _memoryCache.keys
          .where((key) => key.startsWith('${category}_'))
          .toList();
      
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }

      // 디스크 캐시에서 카테고리별 삭제
      if (_prefs != null) {
        final diskKeys = _prefs!.getKeys()
            .where((key) => key.startsWith('cache_${category}_'))
            .toList();
        
        for (final key in diskKeys) {
          await _prefs!.remove(key);
        }
      }

      // DB에서 카테고리별 삭제
      await _database?.deleteCacheByCategory(category);
      
      debugPrint('🧹 [UNIVERSAL_CACHE] Removed category: $category');
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Remove category failed for $category: $e');
    }
  }

  /// 🔄 캐시 새로고침 (기존 캐시 삭제 후 새 데이터로 교체)
  Future<void> refresh<T>({
    required String key,
    required T data,
    CacheStrategy strategy = CacheStrategy.medium,
    String? category,
  }) async {
    await remove(key);
    await set(key: key, data: data, strategy: strategy, category: category);
  }

  /// 📊 캐시 통계
  Map<String, dynamic> getStats() {
    return {
      'memoryKeys': _memoryCache.length,
      'diskKeys': _prefs?.getKeys().where((k) => k.startsWith('cache_')).length ?? 0,
      'memorySize': _calculateMemorySize(),
      'lastCleanup': DateTime.now().toString(),
    };
  }

  /// ⚡ 메모리 캐시 관련 메서드들
  void _setInMemory(String key, Map<String, dynamic> data, Duration duration) {
    _memoryCache[key] = CacheEntry(
      data: data,
      expiryTime: DateTime.now().add(duration),
    );
  }

  Map<String, dynamic>? _getFromMemory(String key) {
    final entry = _memoryCache[key];
    if (entry != null && entry.isValid) {
      return entry.data;
    }
    
    if (entry != null) {
      _memoryCache.remove(key); // 만료된 캐시 제거
    }
    
    return null;
  }

  /// 💿 디스크 캐시 관련 메서드들
  Future<void> _setInDisk(String key, Map<String, dynamic> data, Duration duration) async {
    if (_prefs == null) return;
    
    final cacheData = {
      'data': data,
      'expiry': DateTime.now().add(duration).millisecondsSinceEpoch,
    };
    
    await _prefs!.setString('cache_$key', jsonEncode(cacheData));
  }

  Future<Map<String, dynamic>?> _getFromDisk(String key) async {
    if (_prefs == null) return null;
    
    final cacheString = _prefs!.getString('cache_$key');
    if (cacheString == null) return null;
    
    try {
      final cacheData = jsonDecode(cacheString);
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
      
      if (DateTime.now().isAfter(expiryTime)) {
        await _prefs!.remove('cache_$key');
        return null;
      }
      
      return Map<String, dynamic>.from(cacheData['data']);
    } catch (e) {
      await _prefs!.remove('cache_$key');
      return null;
    }
  }

  /// 🗄️ 오프라인 DB 관련 메서드들
  Future<void> _setInDatabase(String key, Map<String, dynamic> data, Duration duration, String? category) async {
    if (_database == null) return;
    
    await _database!.setCache(
      key: key,
      data: data,
      expiryTime: DateTime.now().add(duration),
      category: category,
    );
  }

  Future<Map<String, dynamic>?> _getFromDatabase(String key) async {
    if (_database == null) return null;
    return await _database!.getCache(key);
  }

  /// 🔧 유틸리티 메서드들
  Map<String, dynamic> _serialize<T>(T data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is List) {
      return {'_list': data};
    } else if (data is String || data is num || data is bool) {
      return {'_primitive': data};
    } else {
      // 커스텀 객체는 toJson() 메서드가 있다고 가정
      try {
        return (data as dynamic).toJson();
      } catch (e) {
        return {'_string': data.toString()};
      }
    }
  }

  T? _deserialize<T>(Map<String, dynamic> data, T Function(Map<String, dynamic>)? fromJson) {
    try {
      if (data.containsKey('_list')) {
        return data['_list'] as T;
      } else if (data.containsKey('_primitive')) {
        return data['_primitive'] as T;
      } else if (data.containsKey('_string')) {
        return data['_string'] as T;
      } else if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Deserialization failed: $e');
      return null;
    }
  }

  int _calculateMemorySize() {
    int size = 0;
    for (final entry in _memoryCache.values) {
      size += entry.data.toString().length;
    }
    return size;
  }

  /// 🧹 만료된 캐시 정리
  Future<void> _cleanupExpiredCache() async {
    try {
      // 메모리 캐시 정리
      _memoryCache.removeWhere((key, entry) => !entry.isValid);
      
      // 디스크 캐시 정리
      if (_prefs != null) {
        final keys = _prefs!.getKeys()
            .where((key) => key.startsWith('cache_'))
            .toList();
        
        for (final key in keys) {
          await _getFromDisk(key.substring(6)); // 'cache_' 제거
        }
      }
      
      // DB 캐시 정리
      await _database?.cleanupExpiredCache();
      
      debugPrint('🧹 [UNIVERSAL_CACHE] Cleanup completed');
    } catch (e) {
      debugPrint('❌ [UNIVERSAL_CACHE] Cleanup failed: $e');
    }
  }
}

/// 📋 캐시 전략 열거형
enum CacheStrategy {
  ultraShort,  // 1분 - 실시간 데이터
  short,       // 5분 - 자주 변하는 데이터  
  medium,      // 30분 - 일반 데이터
  long,        // 6시간 - 안정적인 데이터
  persistent,  // 30일 - 정적 데이터
}

/// 📦 캐시 엔트리 클래스
class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiryTime;

  CacheEntry({
    required this.data,
    required this.expiryTime,
  });

  bool get isValid => DateTime.now().isBefore(expiryTime);

  @override
  String toString() {
    return 'CacheEntry(keys: ${data.keys.length}, expires: $expiryTime, valid: $isValid)';
  }
}