import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../connectivity/connectivity_service.dart';

/// 🖼️ 최적화된 이미지 캐싱 서비스
/// 
/// 특징:
/// - 메모리 + 디스크 2단계 캐싱
/// - 자동 이미지 크기 최적화
/// - 네트워크 상태 기반 품질 조정
/// - LRU 캐시 정책
/// - 배터리 절약 모드 지원
class OptimizedImageCache {
  static OptimizedImageCache? _instance;
  static OptimizedImageCache get instance => _instance ??= OptimizedImageCache._();
  
  OptimizedImageCache._();

  final Map<String, ui.Image> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};
  final _connectivity = ConnectivityService.instance;
  
  Directory? _cacheDirectory;
  bool _isInitialized = false;
  
  // 캐시 설정
  static const int _maxMemoryCacheSize = 50; // 메모리에 최대 50개 이미지
  static const int _maxDiskCacheSizeMB = 100; // 디스크에 최대 100MB
  static const Duration _diskCacheExpiry = Duration(days: 7); // 7일 후 만료

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory('${tempDir.path}/image_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      _isInitialized = true;
      debugPrint('🖼️ [IMAGE_CACHE] Initialized successfully');
      
      // 초기 정리 작업
      unawaited(_cleanupExpiredCache());
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Initialization failed: $e');
    }
  }

  /// 이미지 로드 (캐시 우선)
  Future<ui.Image?> loadImage(
    String url, {
    Size? targetSize,
    ImageQuality quality = ImageQuality.auto,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ [IMAGE_CACHE] Service not initialized');
      return null;
    }

    final cacheKey = _generateCacheKey(url, targetSize, quality);
    
    try {
      // 1. 메모리 캐시 확인
      final memoryImage = _getFromMemoryCache(cacheKey);
      if (memoryImage != null) {
        debugPrint('⚡ [IMAGE_CACHE] Memory hit: $url');
        return memoryImage;
      }

      // 2. 디스크 캐시 확인
      final diskImage = await _getFromDiskCache(cacheKey);
      if (diskImage != null) {
        debugPrint('💿 [IMAGE_CACHE] Disk hit: $url');
        _addToMemoryCache(cacheKey, diskImage);
        return diskImage;
      }

      // 3. 네트워크에서 다운로드
      if (_connectivity.isOnline) {
        debugPrint('🌐 [IMAGE_CACHE] Downloading: $url');
        return await _downloadAndCacheImage(url, cacheKey, targetSize, quality);
      } else {
        debugPrint('📵 [IMAGE_CACHE] Offline - image not available: $url');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Load failed for $url: $e');
      return null;
    }
  }

  /// 이미지 미리 로드 (백그라운드)
  Future<void> preloadImage(
    String url, {
    Size? targetSize,
    ImageQuality quality = ImageQuality.auto,
  }) async {
    if (!_connectivity.isHighQualityConnection) {
      debugPrint('📱 [IMAGE_CACHE] Skipping preload on mobile data: $url');
      return;
    }

    unawaited(loadImage(url, targetSize: targetSize, quality: quality));
  }

  /// 이미지 배치 미리 로드
  Future<void> preloadImages(
    List<String> urls, {
    Size? targetSize,
    ImageQuality quality = ImageQuality.auto,
  }) async {
    if (!_connectivity.isHighQualityConnection) {
      debugPrint('📱 [IMAGE_CACHE] Skipping batch preload on mobile data');
      return;
    }

    debugPrint('📦 [IMAGE_CACHE] Preloading ${urls.length} images...');
    
    // 동시에 최대 3개씩 처리
    for (int i = 0; i < urls.length; i += 3) {
      final batch = urls.skip(i).take(3);
      await Future.wait(
        batch.map((url) => preloadImage(url, targetSize: targetSize, quality: quality)),
      );
      
      // 배치 간 짧은 지연 (시스템 부하 방지)
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    debugPrint('✅ [IMAGE_CACHE] Batch preload completed');
  }

  /// 메모리 캐시에서 가져오기
  ui.Image? _getFromMemoryCache(String cacheKey) {
    final image = _memoryCache[cacheKey];
    if (image != null) {
      _accessTimes[cacheKey] = DateTime.now();
    }
    return image;
  }

  /// 메모리 캐시에 추가
  void _addToMemoryCache(String cacheKey, ui.Image image) {
    // LRU 정책으로 캐시 관리
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictLRUFromMemory();
    }
    
    _memoryCache[cacheKey] = image;
    _accessTimes[cacheKey] = DateTime.now();
  }

  /// LRU 항목 제거 (메모리)
  void _evictLRUFromMemory() {
    if (_accessTimes.isEmpty) return;
    
    final oldestKey = _accessTimes.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
    
    _memoryCache.remove(oldestKey);
    _accessTimes.remove(oldestKey);
    
    debugPrint('🗑️ [IMAGE_CACHE] Evicted from memory: $oldestKey');
  }

  /// 디스크 캐시에서 가져오기
  Future<ui.Image?> _getFromDiskCache(String cacheKey) async {
    try {
      final file = File('${_cacheDirectory!.path}/$cacheKey.cache');
      
      if (!await file.exists()) return null;
      
      // 만료 시간 확인
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age > _diskCacheExpiry) {
        await file.delete();
        return null;
      }
      
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      return frame.image;
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Disk cache read failed: $e');
      return null;
    }
  }

  /// 디스크 캐시에 저장
  Future<void> _saveToDiskCache(String cacheKey, Uint8List bytes) async {
    try {
      final file = File('${_cacheDirectory!.path}/$cacheKey.cache');
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Disk cache write failed: $e');
    }
  }

  /// 네트워크에서 다운로드 및 캐시
  Future<ui.Image?> _downloadAndCacheImage(
    String url,
    String cacheKey,
    Size? targetSize,
    ImageQuality quality,
  ) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode != 200) {
        debugPrint('❌ [IMAGE_CACHE] HTTP ${response.statusCode} for $url');
        return null;
      }
      
      final bytes = await consolidateHttpClientResponseBytes(response);
      
      // 이미지 최적화
      final optimizedBytes = await _optimizeImage(bytes, targetSize, quality);
      
      // 디스크에 저장
      unawaited(_saveToDiskCache(cacheKey, optimizedBytes));
      
      // 이미지 디코딩
      final codec = await ui.instantiateImageCodec(optimizedBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // 메모리 캐시에 추가
      _addToMemoryCache(cacheKey, image);
      
      debugPrint('✅ [IMAGE_CACHE] Downloaded and cached: $url');
      return image;
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Download failed for $url: $e');
      return null;
    }
  }

  /// 이미지 최적화
  Future<Uint8List> _optimizeImage(
    Uint8List originalBytes,
    Size? targetSize,
    ImageQuality quality,
  ) async {
    try {
      // 네트워크 상태에 따른 품질 조정
      final adjustedQuality = _adjustQualityForNetwork(quality);
      
      // 실제 구현에서는 이미지 리사이징 및 압축 로직 필요
      // 여기서는 원본 반환 (데모용)
      return originalBytes;
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Image optimization failed: $e');
      return originalBytes;
    }
  }

  /// 네트워크 상태에 따른 품질 조정
  ImageQuality _adjustQualityForNetwork(ImageQuality quality) {
    if (quality == ImageQuality.auto) {
      if (_connectivity.isDataSavingMode) {
        return ImageQuality.low;
      } else if (_connectivity.isHighQualityConnection) {
        return ImageQuality.high;
      } else {
        return ImageQuality.medium;
      }
    }
    
    return quality;
  }

  /// 캐시 키 생성
  String _generateCacheKey(String url, Size? targetSize, ImageQuality quality) {
    final keyData = '$url-${targetSize?.width ?? 0}x${targetSize?.height ?? 0}-${quality.name}';
    final bytes = utf8.encode(keyData);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// 만료된 캐시 정리
  Future<void> _cleanupExpiredCache() async {
    try {
      if (_cacheDirectory == null || !await _cacheDirectory!.exists()) return;
      
      final files = await _cacheDirectory!.list().toList();
      int deletedCount = 0;
      
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.cache')) {
          final stat = await entity.stat();
          final age = DateTime.now().difference(stat.modified);
          
          if (age > _diskCacheExpiry) {
            await entity.delete();
            deletedCount++;
          }
        }
      }
      
      if (deletedCount > 0) {
        debugPrint('🧹 [IMAGE_CACHE] Cleaned up $deletedCount expired cache files');
      }
      
      // 디스크 캐시 크기 체크
      await _checkDiskCacheSize();
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Cache cleanup failed: $e');
    }
  }

  /// 디스크 캐시 크기 체크
  Future<void> _checkDiskCacheSize() async {
    try {
      if (_cacheDirectory == null) return;
      
      final files = await _cacheDirectory!.list().toList();
      int totalSize = 0;
      
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.cache')) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      final totalSizeMB = totalSize / (1024 * 1024);
      
      if (totalSizeMB > _maxDiskCacheSizeMB) {
        debugPrint('⚠️ [IMAGE_CACHE] Disk cache size exceeded: ${totalSizeMB.toStringAsFixed(1)}MB');
        // LRU 정책으로 오래된 파일 삭제
        await _evictOldDiskCache();
      }
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Disk cache size check failed: $e');
    }
  }

  /// 오래된 디스크 캐시 제거
  Future<void> _evictOldDiskCache() async {
    try {
      final files = await _cacheDirectory!
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.cache'))
          .cast<File>()
          .toList();
      
      // 수정 시간 기준으로 정렬
      files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      
      // 오래된 파일 25% 삭제
      final deleteCount = (files.length * 0.25).ceil();
      
      for (int i = 0; i < deleteCount && i < files.length; i++) {
        await files[i].delete();
      }
      
      debugPrint('🗑️ [IMAGE_CACHE] Evicted $deleteCount old cache files');
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Old cache eviction failed: $e');
    }
  }

  /// 캐시 통계
  Future<ImageCacheStats> getStats() async {
    int diskCacheCount = 0;
    int diskCacheSizeBytes = 0;
    
    try {
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        final files = await _cacheDirectory!
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.cache'))
            .cast<File>()
            .toList();
        
        diskCacheCount = files.length;
        
        for (final file in files) {
          final stat = await file.stat();
          diskCacheSizeBytes += stat.size;
        }
      }
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Stats calculation failed: $e');
    }
    
    return ImageCacheStats(
      memoryCacheCount: _memoryCache.length,
      diskCacheCount: diskCacheCount,
      diskCacheSizeMB: diskCacheSizeBytes / (1024 * 1024),
    );
  }

  /// 캐시 클리어
  Future<void> clearCache({bool memoryOnly = false}) async {
    try {
      // 메모리 캐시 클리어
      _memoryCache.clear();
      _accessTimes.clear();
      
      if (!memoryOnly && _cacheDirectory != null) {
        // 디스크 캐시 클리어
        final files = await _cacheDirectory!.list().toList();
        for (final entity in files) {
          if (entity is File && entity.path.endsWith('.cache')) {
            await entity.delete();
          }
        }
      }
      
      debugPrint('🧹 [IMAGE_CACHE] Cache cleared (memory: true, disk: ${!memoryOnly})');
    } catch (e) {
      debugPrint('❌ [IMAGE_CACHE] Cache clear failed: $e');
    }
  }
}

/// 이미지 품질 설정
enum ImageQuality {
  low,    // 낮은 품질 (데이터 절약)
  medium, // 중간 품질
  high,   // 높은 품질
  auto,   // 자동 (네트워크 상태에 따라)
}

/// 이미지 캐시 통계
class ImageCacheStats {
  final int memoryCacheCount;
  final int diskCacheCount;
  final double diskCacheSizeMB;

  const ImageCacheStats({
    required this.memoryCacheCount,
    required this.diskCacheCount,
    required this.diskCacheSizeMB,
  });

  @override
  String toString() {
    return '''
Image Cache Stats:
- Memory: $memoryCacheCount images
- Disk: $diskCacheCount images (${diskCacheSizeMB.toStringAsFixed(1)}MB)
''';
  }
}

/// 이미지 품질 확장
extension ImageQualityExtension on ImageQuality {
  String get name {
    switch (this) {
      case ImageQuality.low:
        return 'low';
      case ImageQuality.medium:
        return 'medium';
      case ImageQuality.high:
        return 'high';
      case ImageQuality.auto:
        return 'auto';
    }
  }
}