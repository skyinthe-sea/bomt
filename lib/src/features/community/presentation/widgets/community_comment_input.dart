import 'dart:ui';
import 'package:flutter/material.dart';

class CommunityCommentInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmit;
  final String? replyToNickname;
  final VoidCallback? onCancelReply;
  final bool isSubmitting;

  const CommunityCommentInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    this.replyToNickname,
    this.onCancelReply,
    this.isSubmitting = false,
  });


  @override
  State<CommunityCommentInput> createState() => _CommunityCommentInputState();
}

class _CommunityCommentInputState extends State<CommunityCommentInput> {
  bool _isSubmitting = false;

  bool get _canSubmit {
    return widget.controller.text.trim().isNotEmpty && !_isSubmitting && !widget.isSubmitting;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    final content = widget.controller.text.trim();
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(content);
      widget.controller.clear();
      widget.focusNode.unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('댓글 작성 실패: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 답글 표시
                if (widget.replyToNickname != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.replyToNickname}님에게 답글',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.onCancelReply,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 댓글 입력창
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 프로필 이미지
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 입력 필드
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 44,
                          maxHeight: 120,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: widget.focusNode.hasFocus
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          decoration: InputDecoration(
                            hintText: widget.replyToNickname != null 
                                ? '답글을 입력하세요...'
                                : '댓글을 입력하세요...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: theme.textTheme.bodyMedium,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) {
                            if (_canSubmit) {
                              _handleSubmit();
                            }
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // 전송 버튼
                    GestureDetector(
                      onTap: _canSubmit ? _handleSubmit : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: _canSubmit
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: _canSubmit 
                              ? null 
                              : theme.colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: _canSubmit
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: (_isSubmitting || widget.isSubmitting)
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                size: 20,
                                color: _canSubmit
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}