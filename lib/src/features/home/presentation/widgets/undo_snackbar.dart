import 'package:flutter/material.dart';

class UndoSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? actionColor,
  }) {
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: '실행 취소',
        textColor: actionColor ?? Colors.yellow[300],
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          onUndo();
        },
      ),
      backgroundColor: backgroundColor ?? Colors.grey[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      onVisible: () {
        // 스낵바가 표시될 때의 콜백
      },
    );
    
    final controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    // 스낵바가 자동으로 사라지거나 닫힐 때의 처리
    controller.closed.then((reason) {
      if (reason == SnackBarClosedReason.timeout || 
          reason == SnackBarClosedReason.dismiss ||
          reason == SnackBarClosedReason.swipe) {
        onDismissed?.call();
      }
    });
  }

  /// 수유 기록 삭제 전용 스낵바
  static void showFeedingDeleted({
    required BuildContext context,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
  }) {
    show(
      context: context,
      message: '수유 기록이 삭제되었습니다',
      onUndo: onUndo,
      onDismissed: onDismissed,
      backgroundColor: Colors.blue[700],
      actionColor: Colors.blue[100],
    );
  }

  /// 수면 기록 삭제 전용 스낵바
  static void showSleepDeleted({
    required BuildContext context,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
  }) {
    show(
      context: context,
      message: '수면 기록이 삭제되었습니다',
      onUndo: onUndo,
      onDismissed: onDismissed,
      backgroundColor: Colors.purple[700],
      actionColor: Colors.purple[100],
    );
  }

  /// 기저귀 기록 삭제 전용 스낵바
  static void showDiaperDeleted({
    required BuildContext context,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
  }) {
    show(
      context: context,
      message: '기저귀 기록이 삭제되었습니다',
      onUndo: onUndo,
      onDismissed: onDismissed,
      backgroundColor: Colors.amber[700],
      actionColor: Colors.amber[100],
    );
  }

  /// 건강 기록 삭제 전용 스낵바
  static void showHealthDeleted({
    required BuildContext context,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
  }) {
    show(
      context: context,
      message: '건강 기록이 삭제되었습니다',
      onUndo: onUndo,
      onDismissed: onDismissed,
      backgroundColor: Colors.orange[700],
      actionColor: Colors.orange[100],
    );
  }

  /// 언두 성공 스낵바
  static void showUndoSuccess({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.undo,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 8,
      ),
    );
  }

  /// 삭제 실패 스낵바
  static void showDeleteError({
    required BuildContext context,
    String? customMessage,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage ?? '삭제 중 오류가 발생했습니다',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 8,
      ),
    );
  }
}