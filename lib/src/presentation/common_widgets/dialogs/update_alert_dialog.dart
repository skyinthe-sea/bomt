import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class UpdateAlertDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? currentVersion;
  final String? newVersion;
  final String? updateButtonText;
  final String? laterButtonText;
  final VoidCallback? onUpdate;
  final VoidCallback? onLater;
  final bool canDismiss;

  const UpdateAlertDialog({
    super.key,
    this.title,
    this.message,
    this.currentVersion,
    this.newVersion,
    this.updateButtonText,
    this.laterButtonText,
    this.onUpdate,
    this.onLater,
    this.canDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return PopScope(
      canPop: canDismiss,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: theme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title ?? '업데이트 알림',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ?? '새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.',
              style: theme.textTheme.bodyMedium,
            ),
            if (currentVersion != null || newVersion != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentVersion != null)
                      Row(
                        children: [
                          Text(
                            '현재 버전: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            currentVersion!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    if (newVersion != null && currentVersion != null)
                      const SizedBox(height: 4),
                    if (newVersion != null)
                      Row(
                        children: [
                          Text(
                            '새 버전: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            newVersion!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (canDismiss)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLater?.call();
              },
              child: Text(
                laterButtonText ?? '나중에',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpdate?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(updateButtonText ?? '업데이트'),
          ),
        ],
      ),
    );
  }
}

class UpdateBottomSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final String? currentVersion;
  final String? newVersion;
  final String? updateButtonText;
  final String? laterButtonText;
  final VoidCallback? onUpdate;
  final VoidCallback? onLater;
  final bool canDismiss;

  const UpdateBottomSheet({
    super.key,
    this.title,
    this.message,
    this.currentVersion,
    this.newVersion,
    this.updateButtonText,
    this.laterButtonText,
    this.onUpdate,
    this.onLater,
    this.canDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: canDismiss,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title ?? '업데이트 알림',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              message ?? '새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.',
              style: theme.textTheme.bodyMedium,
            ),
            if (currentVersion != null || newVersion != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentVersion != null)
                      _buildVersionRow(
                        context,
                        '현재 버전',
                        currentVersion!,
                        null,
                      ),
                    if (newVersion != null && currentVersion != null)
                      const SizedBox(height: 8),
                    if (newVersion != null)
                      _buildVersionRow(
                        context,
                        '새 버전',
                        newVersion!,
                        theme.primaryColor,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (canDismiss)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onLater?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(laterButtonText ?? '나중에'),
                    ),
                  ),
                if (canDismiss) const SizedBox(width: 12),
                Expanded(
                  flex: canDismiss ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onUpdate?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(updateButtonText ?? '업데이트'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(
    BuildContext context,
    String label,
    String version,
    Color? versionColor,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        Text(
          version,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: versionColor,
          ),
        ),
      ],
    );
  }
}