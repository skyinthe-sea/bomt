import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

class CommunityWriteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool canPost;
  final bool isPosting;
  final VoidCallback? onPost;
  final String? title;
  final String? actionText;

  const CommunityWriteAppBar({
    super.key,
    required this.canPost,
    required this.isPosting,
    this.onPost,
    this.title,
    this.actionText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withOpacity(0.95),
            theme.colorScheme.surface.withOpacity(0.9),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            title: Text(
              title ?? l10n.writePost,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            actions: [
              // 게시 버튼
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: canPost && !isPosting ? () {
                      print('DEBUG: Post button tapped! canPost=$canPost, isPosting=$isPosting');
                      onPost?.call();
                    } : null,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: canPost
                            ? LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              )
                            : null,
                        color: canPost 
                            ? null 
                            : theme.colorScheme.outline.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: canPost
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isPosting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              actionText ?? l10n.post,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: canPost
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}