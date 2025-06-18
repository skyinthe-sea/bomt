import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/invitation.dart';

class InvitationCacheService {
  static final InvitationCacheService _instance = InvitationCacheService._internal();
  factory InvitationCacheService() => _instance;
  InvitationCacheService._internal();

  static InvitationCacheService get instance => _instance;

  SharedPreferences? _prefs;
  final Map<String, CacheEntry<List<Invitation>>> _memoryCache = {};
  final Map<String, CacheEntry<Invitation>> _singleCache = {};
  
  // 캐시 만료 시간 (기본 5분)
  static const Duration _defaultCacheDuration = Duration(minutes: 5);
  static const Duration _shortCacheDuration = Duration(minutes: 1);
  static const Duration _longCacheDuration = Duration(minutes: 30);

  /// 캐시 서비스 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanupExpiredCache();
  }

  // === 초대 목록 캐싱 ===

  /// 사용자별 보낸 초대 목록 캐시
  Future<void> cacheSentInvitations(String userId, List<Invitation> invitations) async {
    final key = 'sent_invitations_$userId';
    _cacheInMemory(key, invitations, _defaultCacheDuration);
    await _cacheToDisk(key, invitations.map((i) => i.toJson()).toList());
  }

  Future<List<Invitation>?> getCachedSentInvitations(String userId) async {
    final key = 'sent_invitations_$userId';
    
    // 메모리 캐시 확인
    final memoryResult = _getFromMemory<List<Invitation>>(key);
    if (memoryResult != null) return memoryResult;
    
    // 디스크 캐시 확인
    final diskResult = await _getFromDisk(key);
    if (diskResult != null) {
      try {
        final jsonList = List<Map<String, dynamic>>.from(diskResult);
        final invitations = jsonList.map((json) => Invitation.fromJson(json)).toList();
        
        // 메모리에도 캐시
        _cacheInMemory(key, invitations, _shortCacheDuration);
        return invitations;
      } catch (e) {
        debugPrint('디스크 캐시 파싱 오류: $e');
        await _removeFromDisk(key);
      }
    }
    
    return null;
  }

  /// 사용자별 받은 초대 목록 캐시
  Future<void> cacheReceivedInvitations(String userId, List<Invitation> invitations) async {
    final key = 'received_invitations_$userId';
    _cacheInMemory(key, invitations, _longCacheDuration);
    await _cacheToDisk(key, invitations.map((i) => i.toJson()).toList());
  }

  Future<List<Invitation>?> getCachedReceivedInvitations(String userId) async {
    final key = 'received_invitations_$userId';
    return await _getCachedInvitationList(key);
  }

  /// 아기별 활성 초대 목록 캐시
  Future<void> cacheBabyActiveInvitations(String babyId, List<Invitation> invitations) async {
    final key = 'baby_active_invitations_$babyId';
    _cacheInMemory(key, invitations, _shortCacheDuration); // 짧은 캐시 시간
    // 활성 초대는 자주 변경되므로 디스크 캐시 안함
  }

  Future<List<Invitation>?> getCachedBabyActiveInvitations(String babyId) async {
    final key = 'baby_active_invitations_$babyId';
    return _getFromMemory<List<Invitation>>(key);
  }

  // === 단일 초대 캐싱 ===

  /// 토큰별 초대 캐시
  void cacheInvitationByToken(String token, Invitation invitation) {
    final key = 'invitation_token_$token';
    _cacheSingleInMemory(key, invitation, _defaultCacheDuration);
  }

  Invitation? getCachedInvitationByToken(String token) {
    final key = 'invitation_token_$token';
    return _getSingleFromMemory(key);
  }

  /// ID별 초대 캐시
  void cacheInvitationById(String id, Invitation invitation) {
    final key = 'invitation_id_$id';
    _cacheSingleInMemory(key, invitation, _defaultCacheDuration);
  }

  Invitation? getCachedInvitationById(String id) {
    final key = 'invitation_id_$id';
    return _getSingleFromMemory(key);
  }

  // === 통계 캐싱 ===

  Future<void> cacheInvitationStats(String userId, Map<String, int> stats) async {
    final key = 'invitation_stats_$userId';
    await _cacheToDisk(key, stats, duration: _longCacheDuration);
  }

  Future<Map<String, int>?> getCachedInvitationStats(String userId) async {
    final key = 'invitation_stats_$userId';
    final result = await _getFromDisk(key);
    return result != null ? Map<String, int>.from(result) : null;
  }

  // === 캐시 무효화 ===

  /// 사용자 관련 캐시 모두 무효화
  Future<void> invalidateUserCache(String userId) async {
    final keys = [
      'sent_invitations_$userId',
      'received_invitations_$userId',
      'invitation_stats_$userId',
    ];
    
    for (final key in keys) {
      _memoryCache.remove(key);
      await _removeFromDisk(key);
    }
  }

  /// 아기 관련 캐시 무효화
  void invalidateBabyCache(String babyId) {
    _memoryCache.remove('baby_active_invitations_$babyId');
  }

  /// 특정 초대 캐시 무효화
  void invalidateInvitationCache(String invitationId, String? token) {
    _singleCache.remove('invitation_id_$invitationId');
    if (token != null) {
      _singleCache.remove('invitation_token_$token');
    }
  }

  /// 모든 캐시 클리어
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    _singleCache.clear();
    
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('invitation_')).toList();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  // === 내부 유틸리티 메서드 ===

  void _cacheInMemory<T>(String key, T data, Duration duration) {
    _memoryCache[key] = CacheEntry<List<Invitation>>(
      data as List<Invitation>,
      DateTime.now().add(duration),
    );
  }

  void _cacheSingleInMemory(String key, Invitation data, Duration duration) {
    _singleCache[key] = CacheEntry<Invitation>(
      data,
      DateTime.now().add(duration),
    );
  }

  T? _getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry != null && entry.isValid) {
      return entry.data as T;
    }
    
    if (entry != null) {
      _memoryCache.remove(key); // 만료된 캐시 제거
    }
    
    return null;
  }

  Invitation? _getSingleFromMemory(String key) {
    final entry = _singleCache[key];
    if (entry != null && entry.isValid) {
      return entry.data;
    }
    
    if (entry != null) {
      _singleCache.remove(key); // 만료된 캐시 제거
    }
    
    return null;
  }

  Future<void> _cacheToDisk(String key, dynamic data, {Duration? duration}) async {
    if (_prefs == null) return;
    
    final expiryTime = DateTime.now().add(duration ?? _defaultCacheDuration);
    final cacheData = {
      'data': data,
      'expiry': expiryTime.millisecondsSinceEpoch,
    };
    
    await _prefs!.setString(key, jsonEncode(cacheData));
  }

  Future<dynamic> _getFromDisk(String key) async {
    if (_prefs == null) return null;
    
    final cacheString = _prefs!.getString(key);
    if (cacheString == null) return null;
    
    try {
      final cacheData = jsonDecode(cacheString);
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
      
      if (DateTime.now().isAfter(expiryTime)) {
        await _removeFromDisk(key);
        return null;
      }
      
      return cacheData['data'];
    } catch (e) {
      debugPrint('디스크 캐시 읽기 오류: $e');
      await _removeFromDisk(key);
      return null;
    }
  }

  Future<void> _removeFromDisk(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }

  Future<List<Invitation>?> _getCachedInvitationList(String key) async {
    // 메모리 캐시 확인
    final memoryResult = _getFromMemory<List<Invitation>>(key);
    if (memoryResult != null) return memoryResult;
    
    // 디스크 캐시 확인
    final diskResult = await _getFromDisk(key);
    if (diskResult != null) {
      try {
        final jsonList = List<Map<String, dynamic>>.from(diskResult);
        final invitations = jsonList.map((json) => Invitation.fromJson(json)).toList();
        
        // 메모리에도 캐시
        _cacheInMemory(key, invitations, _shortCacheDuration);
        return invitations;
      } catch (e) {
        debugPrint('디스크 캐시 파싱 오류: $e');
        await _removeFromDisk(key);
      }
    }
    
    return null;
  }

  /// 만료된 캐시 정리
  Future<void> _cleanupExpiredCache() async {
    // 메모리 캐시 정리
    _memoryCache.removeWhere((key, entry) => !entry.isValid);
    _singleCache.removeWhere((key, entry) => !entry.isValid);
    
    // 디스크 캐시 정리 (비동기로 백그라운드에서 실행)
    _cleanupExpiredDiskCache();
  }

  Future<void> _cleanupExpiredDiskCache() async {
    if (_prefs == null) return;
    
    final keys = _prefs!.getKeys().where((key) => key.startsWith('invitation_')).toList();
    
    for (final key in keys) {
      final result = await _getFromDisk(key);
      // _getFromDisk 내부에서 만료된 캐시는 자동으로 제거됨
    }
  }
}

/// 캐시 엔트리 클래스
class CacheEntry<T> {
  final T data;
  final DateTime expiryTime;

  CacheEntry(this.data, this.expiryTime);

  bool get isValid => DateTime.now().isBefore(expiryTime);

  @override
  String toString() {
    return 'CacheEntry(data: $data, expires: $expiryTime, valid: $isValid)';
  }
}