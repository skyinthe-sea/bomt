import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/community_comment.dart';
import '../../../../presentation/providers/community_post_provider.dart';
import '../../../../presentation/providers/community_provider.dart';
import '../widgets/community_post_detail_card.dart';
import '../widgets/community_comment_list.dart';
import '../widgets/community_comment_input.dart';
import 'community_edit_screen.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final String postId;

  const CommunityPostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  late ScrollController _scrollController;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  // 답글 관련 상태
  String? _replyToCommentId;
  String? _replyToNickname;
  // 댓글 작성 로딩 상태
  bool _isSubmittingComment = false;
  // 새로 작성된 댓글 하이라이트
  String? _highlightedCommentId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 인피니티 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _handleEditPost(BuildContext context, CommunityPostProvider postProvider) async {
    if (postProvider.post == null) return;
    
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (context) => CommunityEditScreen(post: postProvider.post!),
      ),
    );
    
    // 게시글이 수정되었으면 다시 로드
    if (result != null) {
      postProvider.loadPost(widget.postId);
    }
  }

  Future<void> _handleDeletePost(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        final communityProvider = context.read<CommunityProvider>();
        final success = await communityProvider.deletePost(widget.postId);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('게시글이 삭제되었습니다.'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop(); // 상세 화면 닫기
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  bool _isCurrentUserAuthor(CommunityPostProvider postProvider) {
    final communityProvider = context.read<CommunityProvider>();
    final currentUserId = communityProvider.currentUserId;
    final authorId = postProvider.post?.author?.userId;
    
    return currentUserId != null && authorId != null && currentUserId == authorId;
  }

  void _handleReplyToComment(String commentId, String nickname) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToNickname = nickname;
    });
    _commentFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToNickname = null;
    });
    _commentFocus.unfocus();
  }

  // 새 댓글 위치로 스크롤 및 하이라이트 (최상단)
  Future<void> _scrollToNewComment(String commentId, {bool isReply = false}) async {
    // 하이라이트 설정
    setState(() {
      _highlightedCommentId = commentId;
    });

    // Widget 빌드 완료 후 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // UI 업데이트 대기
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 최상단으로 스크롤 (새 댓글이 최상단에 생성되므로)
      if (mounted && _scrollController.hasClients) {
        try {
          await _scrollController.animateTo(
            0, // 최상단으로 이동
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          );
        } catch (e) {
          // 스크롤 실패 시 대체 방법 없음
        }
      }
    });

    // 하이라이트 효과 지연 후 제거 (1초로 단축)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _highlightedCommentId = null;
        });
      }
    });
  }
  
  // 인피니티 스크롤 비활성화 (더 많은 댓글보기 버튼으로 대체)
  void _onScroll() {
    // 인피니티 스크롤 기능 제거 - "더 많은 댓글보기" 버튼으로 대체
  }



  // 게시글 작성자명 클릭 시 일반 댓글에 태그 추가
  void _handlePostAuthorNameTap(String nickname) {
    final currentText = _commentController.text;
    final cursorPosition = _commentController.selection.baseOffset;
    
    // 현재 커서 위치에 @태그 삽입
    final beforeCursor = currentText.substring(0, cursorPosition >= 0 ? cursorPosition : currentText.length);
    final afterCursor = currentText.substring(cursorPosition >= 0 ? cursorPosition : currentText.length);
    
    // 텍스트 앞에 공백이 필요한지 확인
    final needsSpace = beforeCursor.isNotEmpty && !beforeCursor.endsWith(' ') && !beforeCursor.endsWith('\n');
    final prefix = needsSpace ? ' ' : '';
    
    final newText = '$beforeCursor$prefix@$nickname $afterCursor';
    _commentController.text = newText;
    
    // 커서를 태그 뒤로 이동
    final newPosition = beforeCursor.length + prefix.length + nickname.length + 2;
    _commentController.selection = TextSelection.collapsed(offset: newPosition);
    
    // 포커스 활성화
    _commentFocus.requestFocus();
    
    // 답글 모드 해제 (게시글 작성자 태그는 일반 댓글)
    if (_replyToCommentId != null) {
      _cancelReply();
    }
  }

  // 댓글 작성자명 클릭 시 답글 모드 + 태그 추가
  void _handleCommentAuthorNameTap(String commentId, String nickname, CommunityPostProvider provider) {
    // 해당 댓글이 답글인지 확인하고 최상위 댓글 ID 찾기
    String targetCommentId = commentId;
    
    // 모든 댓글(답글 포함)에서 해당 commentId 찾기
    CommunityComment? clickedComment;
    for (final comment in provider.comments) {
      if (comment.id == commentId) {
        clickedComment = comment;
        break;
      }
      // 답글에서 찾기
      if (comment.replies != null) {
        for (final reply in comment.replies!) {
          if (reply.id == commentId) {
            clickedComment = reply;
            // 답글이면 최상위 댓글 ID 사용
            targetCommentId = comment.id;
            break;
          }
        }
      }
      if (clickedComment != null) break;
    }
    
    // 답글 모드 활성화
    setState(() {
      _replyToCommentId = targetCommentId;
      _replyToNickname = nickname;
    });
    
    // 댓글 입력창에 @태그 추가
    final currentText = _commentController.text;
    final cursorPosition = _commentController.selection.baseOffset;
    
    // 현재 커서 위치에 @태그 삽입
    final beforeCursor = currentText.substring(0, cursorPosition >= 0 ? cursorPosition : currentText.length);
    final afterCursor = currentText.substring(cursorPosition >= 0 ? cursorPosition : currentText.length);
    
    // 텍스트 앞에 공백이 필요한지 확인
    final needsSpace = beforeCursor.isNotEmpty && !beforeCursor.endsWith(' ') && !beforeCursor.endsWith('\n');
    final prefix = needsSpace ? ' ' : '';
    
    final newText = '$beforeCursor$prefix@$nickname $afterCursor';
    _commentController.text = newText;
    
    // 커서를 태그 뒤로 이동
    final newPosition = beforeCursor.length + prefix.length + nickname.length + 2;
    _commentController.selection = TextSelection.collapsed(offset: newPosition);
    
    // 포커스 활성화
    _commentFocus.requestFocus();
  }

  // 댓글 수정 다이얼로그 표시 (Provider 접근 없이)
  void _showEditCommentDialog(String commentId, String currentContent, BuildContext providerContext) {
    final controller = TextEditingController(text: currentContent);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '댓글을 수정하세요...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(dialogContext).pop();
                try {
                  // Provider Context를 사용해서 Provider에 접근
                  final provider = providerContext.read<CommunityPostProvider>();
                  await provider.updateComment(
                    commentId: commentId,
                    content: controller.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('댓글이 수정되었습니다.'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('수정 실패: ${e.toString()}'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
              controller.dispose();
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  // 댓글 삭제 다이얼로그 표시 (Provider 접근 없이)
  Future<void> _showDeleteCommentDialog(String commentId, BuildContext providerContext) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        // Provider Context를 사용해서 Provider에 접근
        final provider = providerContext.read<CommunityPostProvider>();
        await provider.deleteComment(commentId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('댓글이 삭제되었습니다.'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<CommunityPostProvider>(
      create: (context) {
        final provider = CommunityPostProvider();
        // Provider 생성 후 바로 초기화
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.initialize(widget.postId);
        });
        return provider;
      },
      child: Consumer<CommunityPostProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.post == null) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (provider.post == null) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '게시글을 찾을 수 없습니다',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              actions: _isCurrentUserAuthor(provider) 
                  ? [
                      // 수정 버튼 (작성자만)
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _handleEditPost(context, provider),
                          icon: Icon(
                            Icons.edit,
                            color: theme.colorScheme.primary,
                          ),
                          tooltip: '수정',
                        ),
                      ),
                      // 삭제 버튼 (작성자만)
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _handleDeletePost(context),
                          icon: Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: '삭제',
                        ),
                      ),
                    ]
                  : [
                      // 공유 버튼 (작성자가 아닐 때)
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: 공유 기능
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('공유 기능 준비 중입니다')),
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: theme.colorScheme.onSurface,
                          ),
                          tooltip: '공유',
                        ),
                      ),
                    ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.02),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.2],
                ),
              ),
              child: Column(
                children: [
                  // 게시글 및 댓글 목록
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // 상단 여백
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 16,
                          ),
                        ),
                        
                        // 게시글 상세 카드
                        SliverToBoxAdapter(
                          child: CommunityPostDetailCard(
                            post: provider.post!,
                            onLike: provider.togglePostLike,
                            onAuthorNameTap: _handlePostAuthorNameTap,
                          ),
                        ),
                        
                        // 댓글 구분선 및 정렬 버튼
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              children: [
                                // 댓글 수 구분선
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: theme.colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '댓글 ${provider.totalCommentsCount}개',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: theme.colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // 댓글 정렬 버튼
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: theme.colorScheme.outline.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // 좋아요순 버튼
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  provider.changeCommentSortOrder(widget.postId, 'like_count');
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: provider.commentSortOrder == 'like_count'
                                                        ? theme.colorScheme.primary
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.favorite,
                                                        size: 14,
                                                        color: provider.commentSortOrder == 'like_count'
                                                            ? Colors.white
                                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '좋아요순',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: provider.commentSortOrder == 'like_count'
                                                              ? Colors.white
                                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                                          fontWeight: provider.commentSortOrder == 'like_count'
                                                              ? FontWeight.w600
                                                              : FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // 최신순 버튼
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  provider.changeCommentSortOrder(widget.postId, 'created_at');
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: provider.commentSortOrder == 'created_at'
                                                        ? theme.colorScheme.primary
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.schedule,
                                                        size: 14,
                                                        color: provider.commentSortOrder == 'created_at'
                                                            ? Colors.white
                                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '최신순',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: provider.commentSortOrder == 'created_at'
                                                              ? Colors.white
                                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                                          fontWeight: provider.commentSortOrder == 'created_at'
                                                              ? FontWeight.w600
                                                              : FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 댓글 목록
                        CommunityCommentList(
                          comments: provider.comments,
                          onCommentLike: provider.toggleCommentLike,
                          onReply: _handleReplyToComment,
                          onCommentEdit: (commentId) {
                            // Provider context에서 댓글 찾기
                            final comment = provider.comments
                                .expand((c) => [c, ...?c.replies])
                                .firstWhere((c) => c.id == commentId);
                            _showEditCommentDialog(commentId, comment.content, context);
                          },
                          onCommentDelete: (commentId) {
                            _showDeleteCommentDialog(commentId, context);
                          },
                          onAuthorNameTap: (commentId, nickname) => _handleCommentAuthorNameTap(commentId, nickname, provider),
                          isCommentAuthor: provider.isCommentAuthor,
                          isLoading: provider.isCommentsLoading,
                          highlightedCommentId: _highlightedCommentId,
                          postAuthorId: provider.post?.authorId,
                        ),
                        
                        // 더 많은 댓글 로딩 인디케이터
                        if (provider.isLoadingMoreComments)
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '댓글 불러오는 중...',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // 더 보기 버튼 (infinity scroll 대안)
                        if (provider.hasMoreComments && !provider.isLoadingMoreComments && !provider.isCommentsLoading)
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    provider.loadMoreComments(widget.postId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
                                    foregroundColor: theme.colorScheme.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  icon: Icon(
                                    Icons.expand_more,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  label: Text(
                                    '더 많은 댓글 보기',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // 하단 여백
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  ),
                  
                  // 댓글 입력창
                  CommunityCommentInput(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    replyToNickname: _replyToNickname,
                    onCancelReply: _cancelReply,
                    isSubmitting: _isSubmittingComment,
                    onSubmit: (content) async {
                      setState(() {
                        _isSubmittingComment = true;
                      });
                      
                      try {
                        final newComment = await provider.createComment(
                          content: content,
                          parentCommentId: _replyToCommentId,
                        );
                      
                        if (newComment != null) {
                          final isReply = _replyToCommentId != null;
                          
                          // 입력창 정리
                          _commentController.clear();
                          _commentFocus.unfocus();
                          
                          // 답글 모드 해제
                          if (_replyToCommentId != null) {
                            _cancelReply();
                          }
                          
                          // 성공 피드백 효과
                          if (mounted) {
                            HapticFeedback.lightImpact();
                            
                            // 새 댓글 위치로 스크롤 애니메이션
                            _scrollToNewComment(newComment.id, isReply: isReply);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isReply ? '답글이 작성되었습니다.' : '댓글이 작성되었습니다.'),
                                  ],
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // 에러 발생 시 피드백
                        if (mounted) {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('댓글 작성에 실패했습니다.'),
                                ],
                              ),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSubmittingComment = false;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}