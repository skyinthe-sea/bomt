import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../domain/models/community_post.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../../../../services/image/image_service.dart';
import '../widgets/community_write_app_bar.dart';
import '../widgets/community_category_selector.dart';
import '../widgets/community_image_picker.dart';

class CommunityEditScreen extends StatefulWidget {
  final CommunityPost post;

  const CommunityEditScreen({
    super.key,
    required this.post,
  });

  @override
  State<CommunityEditScreen> createState() => _CommunityEditScreenState();
}

class _CommunityEditScreenState extends State<CommunityEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  
  CommunityCategory? _selectedCategory;
  bool _isUpdating = false;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final ImageService _imageService = ImageService.instance;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _existingImageUrls = List.from(widget.post.images);
    
    // 게시글의 카테고리를 선택된 카테고리로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CommunityProvider>();
      if (provider.categories.isNotEmpty) {
        CommunityCategory? category;
        try {
          category = provider.categories.firstWhere(
            (cat) => cat.id == widget.post.category?.id,
          );
        } catch (e) {
          // 해당 카테고리를 찾지 못하면 첫 번째 카테고리를 선택
          category = provider.categories.first;
        }
        setState(() {
          _selectedCategory = category;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  bool get _canUpdate {
    return _titleController.text.trim().isNotEmpty &&
           _contentController.text.trim().isNotEmpty &&
           _selectedCategory != null &&
           !_isUpdating;
  }

  Future<void> _handleAddImages() async {
    try {
      final totalImages = _existingImageUrls.length + _selectedImages.length;
      final remainingSlots = 5 - totalImages;
      
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('최대 5개의 이미지만 업로드할 수 있습니다.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final newImages = await _imageService.pickMultipleImages(
        maxImages: remainingSlots,
      );
      
      if (newImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 실패: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleRemoveImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleRemoveExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _handleUpdate() async {
    if (!_canUpdate) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final provider = context.read<CommunityProvider>();
      
      // 현재 사용자 ID 가져오기
      final currentUser = provider.currentUserProfile;
      if (currentUser == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 새로운 이미지 업로드
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        newImageUrls = await _imageService.uploadCommunityImages(
          _selectedImages, 
          currentUser.userId,
        );
      }

      // 기존 이미지 + 새로운 이미지 합치기
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      final updatedPost = await provider.updatePost(
        postId: widget.post.id,
        categoryId: _selectedCategory!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        images: allImageUrls,
      );

      if (updatedPost != null && mounted) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('게시글이 성공적으로 수정되었습니다!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // 이전 화면으로 돌아가기
        Navigator.of(context).pop(updatedPost);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 수정 실패: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommunityWriteAppBar(
        canPost: _canUpdate,
        isPosting: _isUpdating,
        onPost: _handleUpdate,
        title: '게시글 수정',
        actionText: '수정',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 카테고리 선택
              CommunityCategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              
              // 제목 입력
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _titleFocus.hasFocus 
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : theme.colorScheme.outline.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요',
                        hintStyle: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 200,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ),
              
              // 내용 입력
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _contentFocus.hasFocus 
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.outline.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        decoration: InputDecoration(
                          hintText: '내용을 입력하세요...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        maxLength: 10000,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 기존 이미지 표시
              if (_existingImageUrls.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.image,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '기존 이미지',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              scrollDirection: Axis.horizontal,
                              itemCount: _existingImageUrls.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final imageUrl = _existingImageUrls[index];
                                
                                return Stack(
                                  children: [
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.shadow.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _handleRemoveExistingImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.error.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.error.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 새로 선택된 이미지 표시
              if (_selectedImages.isNotEmpty)
                CommunityImagePicker(
                  selectedImages: _selectedImages,
                  onAddImages: _handleAddImages,
                  onRemoveImage: _handleRemoveImage,
                  maxImages: 5,
                ),
              
              // 하단 도구 모음
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.95),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 이미지 추가 버튼
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: (_existingImageUrls.length + _selectedImages.length) < 5 
                            ? _handleAddImages 
                            : null,
                        icon: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: '이미지 추가',
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 글자 수 카운터
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '제목: ${_titleController.text.length}/200',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '내용: ${_contentController.text.length}/10000',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '이미지: ${_existingImageUrls.length + _selectedImages.length}/5',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}