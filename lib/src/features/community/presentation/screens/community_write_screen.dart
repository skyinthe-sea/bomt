import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/community_category.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../../../../services/image/image_service.dart';
import '../widgets/community_write_app_bar.dart';
import '../widgets/community_category_selector.dart';
import '../widgets/community_image_picker.dart';

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  
  CommunityCategory? _selectedCategory;
  bool _isPosting = false;
  List<File> _selectedImages = [];
  final ImageService _imageService = ImageService.instance;

  @override
  void initState() {
    super.initState();
    // 첫 번째 카테고리(인기, 전체 제외)를 기본값으로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CommunityProvider>();
      if (provider.categories.isNotEmpty) {
        final writableCategories = provider.categories
            .where((cat) => cat.slug != 'popular' && cat.slug != 'all')
            .toList();
        if (writableCategories.isNotEmpty) {
          setState(() {
            _selectedCategory = writableCategories.first;
          });
        }
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

  bool get _canPost {
    return _titleController.text.trim().isNotEmpty &&
           _contentController.text.trim().isNotEmpty &&
           _selectedCategory != null &&
           !_isPosting;
  }

  Future<void> _handleAddImages() async {
    try {
      final newImages = await _imageService.pickMultipleImages(
        maxImages: 5 - _selectedImages.length,
      );
      
      if (newImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageSelectionError(e.toString())),
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

  Future<void> _handlePost() async {
    print('DEBUG: _handlePost called');
    print('DEBUG: _canPost = $_canPost');
    print('DEBUG: title = "${_titleController.text.trim()}"');
    print('DEBUG: content = "${_contentController.text.trim()}"');
    print('DEBUG: selectedCategory = $_selectedCategory');
    print('DEBUG: isPosting = $_isPosting');
    
    if (!_canPost) {
      print('DEBUG: _canPost is false, returning early');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      print('DEBUG: Getting CommunityProvider...');
      final provider = context.read<CommunityProvider>();
      
      // 현재 사용자 ID 가져오기
      final currentUser = provider.currentUserProfile;
      print('DEBUG: currentUser = $currentUser');
      print('DEBUG: currentUserId = ${provider.currentUserId}');
      
      if (currentUser == null) {
        final l10n = AppLocalizations.of(context)!;
        throw Exception(l10n.userNotFoundError);
      }

      // 이미지 업로드
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        print('DEBUG: Uploading ${_selectedImages.length} images...');
        imageUrls = await _imageService.uploadCommunityImages(
          _selectedImages, 
          currentUser.userId,
        );
        print('DEBUG: Images uploaded: $imageUrls');
      }

      print('DEBUG: Creating post...');
      final post = await provider.createPost(
        categoryId: _selectedCategory!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        images: imageUrls,
      );
      print('DEBUG: Post created: $post');

      if (post != null && mounted) {
        // 성공 메시지
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postCreateSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postCreateError(e.toString())),
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
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // 디버그: 현재 상태 출력
    print('DEBUG: Build - _canPost = $_canPost');
    print('DEBUG: Build - title: "${_titleController.text.trim()}"');
    print('DEBUG: Build - content: "${_contentController.text.trim()}"');
    print('DEBUG: Build - selectedCategory: $_selectedCategory');
    print('DEBUG: Build - isPosting: $_isPosting');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommunityWriteAppBar(
        canPost: _canPost,
        isPosting: _isPosting,
        onPost: _handlePost,
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
                        hintText: l10n.titlePlaceholder,
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
                          hintText: l10n.contentPlaceholder,
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
              
              // 선택된 이미지 표시
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
                        onPressed: _selectedImages.length < 5 ? _handleAddImages : null,
                        icon: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: l10n.addImageTooltip,
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
                            l10n.titleCharacterCount(_titleController.text.length),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            l10n.contentCharacterCount(_contentController.text.length),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          if (_selectedImages.isNotEmpty)
                            Text(
                              l10n.imageCountDisplay(_selectedImages.length),
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