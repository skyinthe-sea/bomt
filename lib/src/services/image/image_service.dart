import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../core/config/supabase_config.dart';

class ImageService {
  static ImageService? _instance;
  static ImageService get instance => _instance ??= ImageService._();
  
  ImageService._();
  
  final _picker = ImagePicker();
  final _supabase = SupabaseConfig.client;
  
  // Storage 버킷 이름
  static const String _bucketName = 'baby-profiles';
  static const String _communityBucketName = 'community-images';
  
  /// 이미지 선택 (갤러리 또는 카메라)
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('Platform exception in image picker: ${e.code} - ${e.message}');
      
      // iOS 시뮬레이터 채널 에러 처리
      if (e.code == 'channel-error' && e.message?.contains('Unable to establish connection') == true) {
        debugPrint('iOS simulator camera access issue detected');
        rethrow; // 상위에서 적절히 처리하도록 다시 던짐
      }
      
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
  
  /// 이미지 압축 및 리사이징
  Future<File?> compressImage(File imageFile, {int quality = 80, int maxSize = 512}) async {
    try {
      // 이미지 읽기
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // 정사각형으로 자르기 (중앙 크롭)
      final size = image.width < image.height ? image.width : image.height;
      image = img.copyCrop(
        image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size,
      );
      
      // 리사이징
      image = img.copyResize(image, width: maxSize, height: maxSize);
      
      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedBytes = img.encodeJpg(image, quality: quality);
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }
  
  /// Supabase Storage에 이미지 업로드
  Future<String?> uploadImage(File imageFile, String babyId, {String? oldImageUrl}) async {
    try {
      // 이미지 압축
      final compressedFile = await compressImage(imageFile);
      if (compressedFile == null) return null;
      
      // 앱 레벨에서 카카오 인증 확인 (간단한 접근법)
      try {
        final kakaoUser = await UserApi.instance.me();
        debugPrint('App authenticated user: Kakao ID ${kakaoUser.id}');
        debugPrint('Uploading to bucket: $_bucketName');
      } catch (e) {
        debugPrint('App authentication check failed: $e');
        throw Exception('업로드하려면 로그인이 필요합니다. 카카오 로그인을 확인해주세요.');
      }
      
      // 기존 이미지가 있다면 삭제
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        debugPrint('Deleting old profile image: $oldImageUrl');
        await deleteImage(oldImageUrl);
      }
      
      // 파일명 생성
      final fileName = '${babyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Supabase Storage에 업로드
      await _supabase.storage
          .from(_bucketName)
          .upload(fileName, compressedFile);
      
      // 공개 URL 가져오기
      final imageUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
      
      // 임시 파일 삭제
      await compressedFile.delete();
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
  
  /// Storage 버킷이 존재하는지 확인
  Future<void> _checkBucketExists() async {
    try {
      // 버킷 목록 가져오기
      final buckets = await _supabase.storage.listBuckets();
      
      // 'baby-profiles' 버킷이 있는지 확인
      bool bucketExists = buckets.any((bucket) => bucket.name == _bucketName);
      
      if (!bucketExists) {
        throw Exception('Storage bucket "$_bucketName" not found. Please create it in Supabase dashboard.');
      }
      
      debugPrint('Storage bucket "$_bucketName" found successfully');
    } catch (e) {
      debugPrint('Error checking bucket: $e');
      rethrow;
    }
  }

  /// 커뮤니티 Storage 버킷이 존재하는지 확인하고 없으면 생성
  Future<void> _checkCommunityBucketExists() async {
    try {
      // 버킷 목록 가져오기
      final buckets = await _supabase.storage.listBuckets();
      
      // 'community-images' 버킷이 있는지 확인 (id 또는 name으로 체크)
      bool bucketExists = buckets.any((bucket) => 
          bucket.id == _communityBucketName || bucket.name == _communityBucketName);
      
      if (!bucketExists) {
        // 버킷이 없으면 자동 생성
        await _supabase.storage.createBucket(
          _communityBucketName,
          const BucketOptions(public: true),
        );
        debugPrint('Created community images bucket: $_communityBucketName');
      } else {
        debugPrint('Storage bucket "$_communityBucketName" found successfully');
      }
    } catch (e) {
      debugPrint('Error checking/creating community bucket: $e');
      // 버킷이 이미 존재하는 경우 등의 오류는 무시하고 계속 진행
    }
  }
  
  /// 기존 이미지 삭제
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // URL에서 파일명 추출
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      
      await _supabase.storage
          .from(_bucketName)
          .remove([fileName]);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
  
  /// 이미지 선택 다이얼로그 표시 옵션
  Future<File?> showImagePickerDialog() async {
    // 갤러리에서 선택 (기본값)
    return await pickImage(source: ImageSource.gallery);
  }
  
  /// 전체 프로세스: 이미지 선택 → 압축 → 업로드
  Future<String?> pickAndUploadImage(String babyId, {ImageSource source = ImageSource.gallery, String? oldImageUrl}) async {
    try {
      // 1. 이미지 선택
      final pickedFile = await pickImage(source: source);
      if (pickedFile == null) return null;
      
      // 2. 업로드 (기존 이미지 삭제 포함)
      final imageUrl = await uploadImage(pickedFile, babyId, oldImageUrl: oldImageUrl);
      
      // 3. 원본 파일 삭제
      await pickedFile.delete();
      
      return imageUrl;
    } on PlatformException catch (e) {
      debugPrint('Platform exception in pick and upload: ${e.code} - ${e.message}');
      rethrow; // HomeScreen에서 처리하도록 다시 던짐
    } catch (e) {
      debugPrint('Error in pick and upload process: $e');
      return null;
    }
  }

  /// 커뮤니티용 다중 이미지 선택
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      // 최대 개수 제한
      final limitedFiles = pickedFiles.take(maxImages).toList();
      
      return limitedFiles.map((file) => File(file.path)).toList();
    } on PlatformException catch (e) {
      debugPrint('Platform exception in multiple image picker: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// 커뮤니티용 이미지 압축 (원본 비율 유지)
  Future<File?> compressCommunityImage(File imageFile, {int quality = 75, int maxWidth = 1200}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // 원본 비율 유지하면서 리사이징
      if (image.width > maxWidth) {
        final ratio = maxWidth / image.width;
        final newHeight = (image.height * ratio).round();
        image = img.copyResize(image, width: maxWidth, height: newHeight);
      }
      
      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/community_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedBytes = img.encodeJpg(image, quality: quality);
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing community image: $e');
      return null;
    }
  }

  /// 커뮤니티 이미지 Supabase Storage에 업로드
  Future<String?> uploadCommunityImage(File imageFile, String userId) async {
    try {
      debugPrint('🔍 [UPLOAD] Starting upload for user: $userId, file: ${imageFile.path}');
      
      // 버킷 존재 확인
      debugPrint('🔍 [UPLOAD] Checking bucket exists...');
      await _checkCommunityBucketExists();
      
      // 이미지 압축
      debugPrint('🔍 [UPLOAD] Compressing image...');
      final compressedFile = await compressCommunityImage(imageFile);
      if (compressedFile == null) {
        debugPrint('❌ [UPLOAD] Image compression failed');
        return null;
      }
      debugPrint('✅ [UPLOAD] Image compressed successfully: ${compressedFile.path}');
      
      // 파일명 생성 (사용자ID_타임스탬프_랜덤값)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
      final fileName = 'posts/${userId}_${timestamp}_$random.jpg';
      debugPrint('🔍 [UPLOAD] Generated filename: $fileName');
      
      // Supabase Storage에 업로드
      debugPrint('🔍 [UPLOAD] Uploading to Supabase Storage...');
      await _supabase.storage
          .from(_communityBucketName)
          .upload(fileName, compressedFile);
      debugPrint('✅ [UPLOAD] File uploaded successfully to Storage');
      
      // 공개 URL 가져오기
      final imageUrl = _supabase.storage
          .from(_communityBucketName)
          .getPublicUrl(fileName);
      debugPrint('✅ [UPLOAD] Public URL generated: $imageUrl');
      
      // 임시 파일 삭제
      await compressedFile.delete();
      debugPrint('🗑️ [UPLOAD] Temporary file deleted');
      
      return imageUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ [UPLOAD] Error uploading community image: $e');
      debugPrint('❌ [UPLOAD] Stack trace: $stackTrace');
      return null;
    }
  }

  /// 커뮤니티용 다중 이미지 업로드
  Future<List<String>> uploadCommunityImages(List<File> imageFiles, String userId) async {
    debugPrint('🖼️ [IMAGE_UPLOAD] Starting upload of ${imageFiles.length} images for user: $userId');
    final List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final imageFile = imageFiles[i];
      try {
        debugPrint('🖼️ [IMAGE_UPLOAD] Uploading image ${i + 1}/${imageFiles.length}: ${imageFile.path}');
        final url = await uploadCommunityImage(imageFile, userId);
        if (url != null) {
          uploadedUrls.add(url);
          debugPrint('✅ [IMAGE_UPLOAD] Successfully uploaded image ${i + 1}: $url');
        } else {
          debugPrint('❌ [IMAGE_UPLOAD] Failed to upload image ${i + 1}: URL is null');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ [IMAGE_UPLOAD] Error uploading image ${i + 1} (${imageFile.path}): $e');
        debugPrint('❌ [IMAGE_UPLOAD] Stack trace: $stackTrace');
        // 개별 이미지 업로드 실패는 무시하고 계속 진행
      }
    }
    
    debugPrint('🖼️ [IMAGE_UPLOAD] Upload completed. ${uploadedUrls.length}/${imageFiles.length} images uploaded successfully');
    debugPrint('🖼️ [IMAGE_UPLOAD] Uploaded URLs: $uploadedUrls');
    return uploadedUrls;
  }

  /// 이미지 모자이크 처리 - 간단한 픽셀화 방식
  Future<File?> applyMosaicEffect(File imageFile, {int blockSize = 40}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // 방법 1: 간단한 축소-확대 방식 (더 강한 모자이크)
      final originalWidth = image.width;
      final originalHeight = image.height;
      
      // 1/8 크기로 축소 (더 강한 모자이크를 위해)
      final smallWidth = (originalWidth / 8).round();
      final smallHeight = (originalHeight / 8).round();
      
      // 축소
      final smallImage = img.copyResize(
        image, 
        width: smallWidth, 
        height: smallHeight,
        interpolation: img.Interpolation.nearest, // 보간 없이 날카롭게
      );
      
      // 다시 원래 크기로 확대 (보간 없이)
      final mosaicImage = img.copyResize(
        smallImage,
        width: originalWidth,
        height: originalHeight,
        interpolation: img.Interpolation.nearest, // 보간 없이 블록화
      );
      
      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/mosaic_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final mosaicBytes = img.encodeJpg(mosaicImage, quality: 85);
      final mosaicFile = File(tempPath);
      await mosaicFile.writeAsBytes(mosaicBytes);
      
      return mosaicFile;
    } catch (e) {
      debugPrint('Error applying mosaic effect: $e');
      return null;
    }
  }
  
  /// 모자이크 이미지 생성 (픽셀 블록화)
  img.Image _createMosaicImage(img.Image originalImage, int blockSize) {
    final width = originalImage.width;
    final height = originalImage.height;
    final mosaicImage = img.Image(width: width, height: height);
    
    // 블록 단위로 처리
    for (int y = 0; y < height; y += blockSize) {
      for (int x = 0; x < width; x += blockSize) {
        // 현재 블록의 경계 계산
        final blockWidth = (x + blockSize > width) ? width - x : blockSize;
        final blockHeight = (y + blockSize > height) ? height - y : blockSize;
        
        // 블록 내 픽셀들의 평균 색상 계산
        double totalR = 0, totalG = 0, totalB = 0, totalA = 0;
        int pixelCount = 0;
        
        for (int by = y; by < y + blockHeight; by++) {
          for (int bx = x; bx < x + blockWidth; bx++) {
            final pixel = originalImage.getPixel(bx, by);
            totalR += pixel.r;
            totalG += pixel.g;
            totalB += pixel.b;
            totalA += pixel.a;
            pixelCount++;
          }
        }
        
        // 평균 색상
        final avgR = (totalR / pixelCount).round();
        final avgG = (totalG / pixelCount).round();
        final avgB = (totalB / pixelCount).round();
        final avgA = (totalA / pixelCount).round();
        final avgColor = img.ColorRgba8(avgR, avgG, avgB, avgA);
        
        // 블록 전체를 평균 색상으로 채우기
        for (int by = y; by < y + blockHeight; by++) {
          for (int bx = x; bx < x + blockWidth; bx++) {
            mosaicImage.setPixel(bx, by, avgColor);
          }
        }
      }
    }
    
    return mosaicImage;
  }

  /// 커뮤니티 이미지 삭제
  Future<bool> deleteCommunityImage(String imageUrl) async {
    try {
      // URL에서 파일명 추출
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      
      await _supabase.storage
          .from(_communityBucketName)
          .remove(['posts/$fileName']);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting community image: $e');
      return false;
    }
  }

}