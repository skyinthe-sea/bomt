import 'package:flutter/material.dart';
import '../../presentation/providers/sleep_provider.dart';
import 'sleep_service.dart';

/// 수면 중단 관련 로직을 처리하는 서비스
class SleepInterruptionService {
  static SleepInterruptionService? _instance;
  static SleepInterruptionService get instance => _instance ??= SleepInterruptionService._();
  
  SleepInterruptionService._();
  
  /// 진행 중인 수면이 있을 때 다른 활동을 시작하기 전 확인 알림을 표시
  /// 
  /// [context] - 알림을 표시할 context
  /// [sleepProvider] - 수면 provider 인스턴스
  /// [activityName] - 시작하려는 활동명 (예: "수유", "기저귀 교체")
  /// [onProceed] - 수면 종료 후 실행할 콜백
  /// 
  /// Returns: true if user proceeded, false if cancelled
  Future<bool> showSleepInterruptionDialog({
    required BuildContext context,
    required SleepProvider sleepProvider,
    required String activityName,
    required VoidCallback onProceed,
  }) async {
    if (!sleepProvider.hasActiveSleep) {
      // 진행 중인 수면이 없으면 바로 진행
      onProceed();
      return true;
    }
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.bedtime,
                color: Colors.purple[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('수면 진행 중'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 수면이 진행 중입니다.\n${activityName}을(를) 기록하시겠습니까?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.purple[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '진행 중인 수면이 자동으로 종료됩니다.',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '${activityName} 기록',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      // 사용자가 진행을 선택한 경우 수면 종료
      final success = await sleepProvider.toggleSleep();
      if (success) {
        onProceed();
        return true;
      } else {
        // 수면 종료 실패 시 에러 메시지 표시
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('수면 종료에 실패했습니다'),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return false;
      }
    }
    
    return false;
  }
  
  /// 간단한 수면 중단 확인 (다이얼로그 없이)
  /// 
  /// [sleepProvider] - 수면 provider 인스턴스
  /// [onProceed] - 수면 종료 후 실행할 콜백
  /// 
  /// Returns: true if no active sleep or sleep ended successfully
  Future<bool> handleSleepInterruption({
    required SleepProvider sleepProvider,
    required VoidCallback onProceed,
  }) async {
    if (!sleepProvider.hasActiveSleep) {
      onProceed();
      return true;
    }
    
    final success = await sleepProvider.toggleSleep();
    if (success) {
      onProceed();
      return true;
    }
    
    return false;
  }
}