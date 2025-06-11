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

  /// 커뮤니티 Storage 버킷이 존재하는지 확인
  Future<void> _checkCommunityBucketExists() async {
    try {
      // 버킷 목록 가져오기
      final buckets = await _supabase.storage.listBuckets();
      
      // 'community-images' 버킷이 있는지 확인
      bool bucketExists = buckets.any((bucket) => bucket.name == _communityBucketName);
      
      if (!bucketExists) {
        throw Exception(
          'Storage bucket "$_communityBucketName" not found.\n\n'
          'Please create it by running the SQL script in:\n'
          'scripts/create_community_storage_bucket.sql\n\n'
          'Or manually create the bucket in Supabase Dashboard:\n'
          '1. Go to Storage section\n'
          '2. Create new bucket named "community-images"\n'
          '3. Make it public\n'
          '4. Set up appropriate RLS policies'
        );
      }
      
      debugPrint('Storage bucket "$_communityBucketName" found successfully');
    } catch (e) {
      debugPrint('Error checking community bucket: $e');
      rethrow;
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
      // 버킷 존재 확인
      await _checkCommunityBucketExists();
      
      // 이미지 압축
      final compressedFile = await compressCommunityImage(imageFile);
      if (compressedFile == null) return null;
      
      // 파일명 생성 (사용자ID_타임스탬프_랜덤값)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
      final fileName = 'posts/${userId}_${timestamp}_$random.jpg';
      
      // Supabase Storage에 업로드
      await _supabase.storage
          .from(_communityBucketName)
          .upload(fileName, compressedFile);
      
      // 공개 URL 가져오기
      final imageUrl = _supabase.storage
          .from(_communityBucketName)
          .getPublicUrl(fileName);
      
      // 임시 파일 삭제
      await compressedFile.delete();
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading community image: $e');
      return null;
    }
  }

  /// 커뮤니티용 다중 이미지 업로드
  Future<List<String>> uploadCommunityImages(List<File> imageFiles, String userId) async {
    final List<String> uploadedUrls = [];
    
    for (final imageFile in imageFiles) {
      try {
        final url = await uploadCommunityImage(imageFile, userId);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        debugPrint('Error uploading image ${imageFile.path}: $e');
        // 개별 이미지 업로드 실패는 무시하고 계속 진행
      }
    }
    
    return uploadedUrls;
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