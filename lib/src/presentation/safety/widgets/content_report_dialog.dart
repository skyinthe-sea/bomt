import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/content_report.dart';
import '../../../domain/models/user_profile.dart';
import '../../../services/safety/content_report_service.dart';

/// 콘텐츠 신고 다이얼로그
/// App Store Guideline 1.2 준수를 위한 신고 시스템 UI
class ContentReportDialog extends StatefulWidget {
  final String reporterUserId;
  final String reportedUserId;
  final ContentType contentType;
  final String contentId;
  final UserProfile? reportedUser;
  final VoidCallback? onReported;

  const ContentReportDialog({
    Key? key,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.contentType,
    required this.contentId,
    this.reportedUser,
    this.onReported,
  }) : super(key: key);

  @override
  State<ContentReportDialog> createState() => _ContentReportDialogState();
}

class _ContentReportDialogState extends State<ContentReportDialog> {
  final ContentReportService _reportService = ContentReportService();
  final TextEditingController _descriptionController = TextEditingController();
  
  ReportReason? _selectedReason;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleReport() async {
    if (_selectedReason == null || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await _reportService.reportContent(
        reporterUserId: widget.reporterUserId,
        reportedUserId: widget.reportedUserId,
        contentType: widget.contentType,
        contentId: widget.contentId,
        reportReason: _selectedReason!,
        reportDescription: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onReported?.call();
        
        // 신고 완료 스낵바
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('신고가 접수되었습니다. 검토 후 처리하겠습니다.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
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
                  Icons.report_outlined,
                  color: theme.colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.contentType.getDisplayName(l10n.localeName)} 신고',
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

            // 신고 대상 정보
            if (widget.reportedUser != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.reportedUser!.profileImageUrl != null
                          ? NetworkImage(widget.reportedUser!.profileImageUrl!)
                          : null,
                      child: widget.reportedUser!.profileImageUrl == null
                          ? Text(
                              widget.reportedUser!.nickname.isNotEmpty
                                  ? widget.reportedUser!.nickname[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.reportedUser!.nickname}님의 ${widget.contentType.getDisplayName(l10n.localeName)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 신고 이유 선택
            Text(
              '신고 이유를 선택해주세요',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  children: ReportReason.values.map((reason) {
                    return RadioListTile<ReportReason>(
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
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 상세 설명 (선택사항)
            Text(
              '상세 설명 (선택사항)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '신고 이유에 대한 추가 설명을 입력해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '신고는 익명으로 처리되며, 관리팀에서 검토 후 적절한 조치를 취합니다. 허위 신고 시 제재를 받을 수 있습니다.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_selectedReason != null && !_isProcessing)
                        ? _handleReport
                        : null,
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
                        : const Text('신고하기'),
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

/// 콘텐츠 신고 다이얼로그 표시 헬퍼 함수
Future<bool?> showContentReportDialog(
  BuildContext context, {
  required String reporterUserId,
  required String reportedUserId,
  required ContentType contentType,
  required String contentId,
  UserProfile? reportedUser,
  VoidCallback? onReported,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ContentReportDialog(
      reporterUserId: reporterUserId,
      reportedUserId: reportedUserId,
      contentType: contentType,
      contentId: contentId,
      reportedUser: reportedUser,
      onReported: onReported,
    ),
  );
}