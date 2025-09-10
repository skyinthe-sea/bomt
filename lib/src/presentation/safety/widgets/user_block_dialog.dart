import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/user_block.dart';
import '../../../domain/models/user_profile.dart';
import '../../../services/safety/user_block_service.dart';

/// 사용자 차단 다이얼로그
/// App Store Guideline 1.2 준수를 위한 사용자 차단 UI
class UserBlockDialog extends StatefulWidget {
  final String currentUserId;
  final UserProfile targetUser;
  final VoidCallback? onBlocked;

  const UserBlockDialog({
    Key? key,
    required this.currentUserId,
    required this.targetUser,
    this.onBlocked,
  }) : super(key: key);

  @override
  State<UserBlockDialog> createState() => _UserBlockDialogState();
}

class _UserBlockDialogState extends State<UserBlockDialog> {
  final UserBlockService _blockService = UserBlockService();
  
  BlockReason? _selectedReason;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _handleBlock() async {
    if (_selectedReason == null || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await _blockService.blockUser(
        blockerUserId: widget.currentUserId,
        blockedUserId: widget.targetUser.userId,
        reason: _selectedReason!.value,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onBlocked?.call();
        
        // 차단 완료 스낵바
        final l10nContext = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nContext.blockSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: l10nContext.cancel,
              textColor: Colors.white,
              onPressed: () => _handleUnblock(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleUnblock() async {
    try {
      await _blockService.unblockUser(
        blockerUserId: widget.currentUserId,
        blockedUserId: widget.targetUser.userId,
      );
      
      if (mounted) {
        final l10nContext = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nContext.unblockSuccess),
          ),
        );
      }
    } catch (e) {
      print('차단 해제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  color: theme.colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.blockUserTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 사용자 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: widget.targetUser.profileImageUrl != null
                        ? NetworkImage(widget.targetUser.profileImageUrl!)
                        : null,
                    child: widget.targetUser.profileImageUrl == null
                        ? Text(
                            widget.targetUser.nickname.isNotEmpty
                                ? widget.targetUser.nickname[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.targetUser.nickname,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.targetUser.bio != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.targetUser.bio!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 설명 텍스트
            Text(
              l10n.blockUserConfirm,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.blockUserDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // 차단 이유 선택
            Text(
              l10n.blockReason,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...BlockReason.values.map((reason) {
              return RadioListTile<BlockReason>(
                title: Text(
                  reason.getDisplayName(l10n.localeName),
                  style: theme.textTheme.bodyMedium,
                ),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }),

            // 에러 메시지
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleBlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.blockAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용자 차단 다이얼로그 표시 헬퍼 함수
Future<bool?> showUserBlockDialog(
  BuildContext context, {
  required String currentUserId,
  required UserProfile targetUser,
  VoidCallback? onBlocked,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => UserBlockDialog(
      currentUserId: currentUserId,
      targetUser: targetUser,
      onBlocked: onBlocked,
    ),
  );
}