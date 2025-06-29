import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpdateCheckService {
  static final UpdateCheckService _instance = UpdateCheckService._internal();
  factory UpdateCheckService() => _instance;
  UpdateCheckService._internal();

  late Upgrader _upgrader;

  void initialize() {
    _upgrader = Upgrader(
      debugLogging: false,
      debugDisplayAlways: false,
      debugDisplayOnce: false,
      durationUntilAlertAgain: const Duration(hours: 24),
      countryCode: 'KR',
      languageCode: 'ko',
      minAppVersion: '1.0.0',
    );
  }

  bool get isUpdateAvailable {
    return _upgrader.isUpdateAvailable();
  }

  String? get currentVersion {
    return _upgrader.currentAppStoreVersion;
  }

  String? get installedVersion {
    return _upgrader.currentInstalledVersion;
  }

  Future<bool> checkForUpdate() async {
    try {
      await _upgrader.initialize();
      return _upgrader.isUpdateAvailable();
    } catch (e) {
      debugPrint('Update check failed: $e');
      return false;
    }
  }

  Future<void> showUpdateDialog(
    BuildContext context, {
    String? title,
    String? message,
    String? updateButtonText,
    String? laterButtonText,
    VoidCallback? onUpdate,
    VoidCallback? onLater,
  }) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? '업데이트 알림'),
        content: Text(
          message ?? '새로운 버전이 출시되었습니다.\n업데이트를 진행하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLater?.call();
            },
            child: Text(laterButtonText ?? '나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onUpdate != null) {
                onUpdate();
              } else {
                _upgrader.sendUserToAppStore();
              }
            },
            child: Text(updateButtonText ?? '업데이트'),
          ),
        ],
      ),
    );
  }

  Widget wrapWithUpdateCheck(Widget child) {
    return UpgradeAlert(
      upgrader: _upgrader,
      child: child,
    );
  }
}