import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/user_agreement_version.dart';
import '../../../services/safety/user_agreement_service.dart';
import '../../common_widgets/dialogs/update_alert_dialog.dart';

/// EULA 동의 다이얼로그
/// App Store Guideline 1.2 준수를 위한 이용약관 동의 UI
class EulaAgreementDialog extends StatefulWidget {
  final String userId;
  final VoidCallback? onAgreementCompleted;
  final bool canDismiss;

  const EulaAgreementDialog({
    Key? key,
    required this.userId,
    this.onAgreementCompleted,
    this.canDismiss = false,
  }) : super(key: key);

  @override
  State<EulaAgreementDialog> createState() => _EulaAgreementDialogState();
}

class _EulaAgreementDialogState extends State<EulaAgreementDialog> {
  final UserAgreementService _agreementService = UserAgreementService();
  
  List<UserAgreementVersion> _agreements = [];
  Map<String, bool> _consentStates = {};
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgreements();
  }

  Future<void> _loadAgreements() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final agreements = await _agreementService.getActiveAgreementVersions();
      
      // 필수 약관만 필터링 (선택 약관은 별도 처리)
      final mandatoryAgreements = agreements.where((a) => a.isMandatory).toList();
      
      setState(() {
        _agreements = mandatoryAgreements;
        _consentStates = {
          for (var agreement in mandatoryAgreements) agreement.id: false
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '약관을 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAgreement() async {
    if (!_allAgreed || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      final agreedVersionIds = _consentStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // 모든 약관에 동의 처리
      await _agreementService.createMultipleConsents(
        userId: widget.userId,
        agreementVersionIds: agreedVersionIds,
        ipAddress: null, // 필요시 구현
        userAgent: null, // 필요시 구현
      );

      // 성공 처리
      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onAgreementCompleted?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '동의 처리 중 오류가 발생했습니다: $e';
        _isProcessing = false;
      });
    }
  }

  bool get _allAgreed => _consentStates.values.every((agreed) => agreed);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => widget.canDismiss,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.gavel_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '서비스 이용약관 동의',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.canDismiss)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'BabyMom은 안전한 커뮤니티 환경을 위해 사용자 생성 콘텐츠에 대한 무관용 정책을 적용합니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 로딩 또는 약관 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _agreements.isEmpty
                        ? Center(
                            child: Text(
                              '약관을 불러올 수 없습니다',
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _agreements.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final agreement = _agreements[index];
                              return _buildAgreementCard(agreement);
                            },
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

              // 버튼
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.canDismiss) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_allAgreed && !_isProcessing)
                          ? _handleAgreement
                          : null,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('동의하고 계속'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCard(UserAgreementVersion agreement) {
    final theme = Theme.of(context);
    final isAgreed = _consentStates[agreement.id] ?? false;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAgreed 
              ? theme.primaryColor.withOpacity(0.3)
              : theme.dividerColor,
          width: isAgreed ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약관 제목과 체크박스
            Row(
              children: [
                Expanded(
                  child: Text(
                    agreement.getLocalizedTitle(languageCode),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Checkbox(
                  value: isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _consentStates[agreement.id] = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 약관 내용 (축약)
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SingleChildScrollView(
                child: Text(
                  agreement.getLocalizedContent(languageCode),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // 전문 보기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showFullAgreement(agreement),
                icon: const Icon(Icons.article_outlined, size: 16),
                label: const Text('전문 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullAgreement(UserAgreementVersion agreement) {
    final languageCode = Localizations.localeOf(context).languageCode;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  Expanded(
                    child: Text(
                      agreement.getLocalizedTitle(languageCode),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              
              // 내용
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    agreement.getLocalizedContent(languageCode),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              
              // 닫기 버튼
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EULA 동의 다이얼로그 표시 헬퍼 함수
Future<bool?> showEulaAgreementDialog(
  BuildContext context, {
  required String userId,
  VoidCallback? onAgreementCompleted,
  bool canDismiss = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: canDismiss,
    builder: (context) => EulaAgreementDialog(
      userId: userId,
      onAgreementCompleted: onAgreementCompleted,
      canDismiss: canDismiss,
    ),
  );
}