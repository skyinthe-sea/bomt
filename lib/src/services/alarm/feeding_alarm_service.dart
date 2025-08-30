import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FeedingAlarmService {
  static FeedingAlarmService? _instance;
  static FeedingAlarmService get instance => _instance ??= FeedingAlarmService._();
  
  FeedingAlarmService._();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // SharedPreferences 키
  static const String _feedingIntervalKey = 'feeding_interval_hours';
  static const String _alarmSoundKey = 'alarm_sound_enabled';
  static const String _alarmVibrateKey = 'alarm_vibrate_enabled';
  static const String _activeAlarmIdKey = 'active_feeding_alarm_id';
  
  // 기본 수유 간격 (시간)
  static const int _defaultFeedingIntervalHours = 3;
  
  /// 수유 간격 설정 저장
  Future<void> setFeedingInterval(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_feedingIntervalKey, hours);
  }
  
  /// 수유 간격 설정 불러오기
  Future<int> getFeedingInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_feedingIntervalKey) ?? _defaultFeedingIntervalHours;
  }
  
  /// 알람 사운드 설정 저장
  Future<void> setAlarmSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmSoundKey, enabled);
  }
  
  /// 알람 사운드 설정 불러오기
  Future<bool> getAlarmSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alarmSoundKey) ?? true;
  }
  
  /// 알람 진동 설정 저장
  Future<void> setAlarmVibrateEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmVibrateKey, enabled);
  }
  
  /// 알람 진동 설정 불러오기
  Future<bool> getAlarmVibrateEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alarmVibrateKey) ?? true;
  }
  
  /// 활성 알람 ID 저장
  Future<void> _setActiveAlarmId(int? alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    if (alarmId != null) {
      await prefs.setInt(_activeAlarmIdKey, alarmId);
    } else {
      await prefs.remove(_activeAlarmIdKey);
    }
  }
  
  /// 활성 알람 ID 불러오기
  Future<int?> _getActiveAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeAlarmIdKey);
  }
  
  /// 다음 수유 시간 계산
  Future<DateTime> calculateNextFeedingTime(DateTime lastFeedingTime) async {
    final intervalHours = await getFeedingInterval();
    return lastFeedingTime.add(Duration(hours: intervalHours));
  }
  
  /// 알림 초기화
  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );
      
      await _notificationsPlugin.initialize(initializationSettings);
      debugPrint('알림 서비스 초기화 완료');
    } catch (e) {
      debugPrint('알림 서비스 초기화 실패: $e');
      // 초기화 실패해도 앱이 크래시되지 않도록 함
    }
  }
  
  /// 수유 알람 설정
  Future<bool> scheduleNextFeedingAlarm(
    DateTime lastFeedingTime, {
    String? notificationTitle,
    String? notificationBody,
    String? channelName,
    String? channelDescription,
  }) async {
    try {
      // 기존 알람이 있으면 취소
      await cancelFeedingAlarm();
      
      final nextFeedingTime = await calculateNextFeedingTime(lastFeedingTime);
      final now = DateTime.now();
      
      // 다음 수유 시간이 이미 지났으면 알람 설정하지 않음
      if (nextFeedingTime.isBefore(now)) {
        debugPrint('다음 수유 시간이 이미 지났습니다. 알람을 설정하지 않습니다.');
        return false;
      }
      
      // 로컬라이즈된 텍스트 가져오기 (파라미터가 제공되지 않은 경우)
      final localizedTexts = await _getLocalizedNotificationTexts();
      
      final alarmId = _generateAlarmId();
      
      await _notificationsPlugin.zonedSchedule(
        alarmId,
        notificationTitle ?? localizedTexts['title']!,
        notificationBody ?? localizedTexts['body']!,
        tz.TZDateTime.from(nextFeedingTime, tz.getLocation('Asia/Seoul')),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'feeding_alarm',
            channelName ?? localizedTexts['channelName']!,
            channelDescription: channelDescription ?? localizedTexts['channelDescription']!,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      final success = true;
      
      if (success) {
        await _setActiveAlarmId(alarmId);
        debugPrint('수유 알람이 ${nextFeedingTime.toString()}에 설정되었습니다. (ID: $alarmId)');
      } else {
        debugPrint('수유 알람 설정에 실패했습니다.');
      }
      
      return success;
    } catch (e) {
      debugPrint('수유 알람 설정 중 오류 발생: $e');
      return false;
    }
  }
  
  /// 수유 알람 취소
  Future<bool> cancelFeedingAlarm() async {
    try {
      final activeAlarmId = await _getActiveAlarmId();
      
      if (activeAlarmId != null) {
        await _notificationsPlugin.cancel(activeAlarmId);
        await _setActiveAlarmId(null);
        debugPrint('수유 알람이 취소되었습니다. (ID: $activeAlarmId)');
        return true;
      }
      
      return true; // 활성 알람이 없으면 성공으로 간주
    } catch (e) {
      debugPrint('수유 알람 취소 중 오류 발생: $e');
      return false;
    }
  }
  
  /// 현재 활성 알람이 있는지 확인
  Future<bool> hasActiveAlarm() async {
    final activeAlarmId = await _getActiveAlarmId();
    
    if (activeAlarmId == null) {
      return false;
    }
    
    // 현재 설정된 알림 목록 확인
    final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.any((notification) => notification.id == activeAlarmId);
  }
  
  /// 다음 수유 예정 시간 가져오기
  Future<DateTime?> getNextFeedingTime() async {
    final activeAlarmId = await _getActiveAlarmId();
    
    if (activeAlarmId == null) {
      return null;
    }
    
    // flutter_local_notifications는 예정 시간을 직접 제공하지 않음
    // 마지막 수유 시간 + 간격으로 계산
    final lastFeedingMinutes = await _getLastFeedingMinutes();
    if (lastFeedingMinutes != null) {
      final intervalHours = await getFeedingInterval();
      final lastFeedingTime = DateTime.now().subtract(Duration(minutes: lastFeedingMinutes));
      return lastFeedingTime.add(Duration(hours: intervalHours));
    }
    return null;
  }
  
  /// 다음 수유까지 남은 시간 (분 단위)
  Future<int?> getMinutesUntilNextFeeding() async {
    final nextFeedingTime = await getNextFeedingTime();
    
    if (nextFeedingTime == null) {
      return null;
    }
    
    final now = DateTime.now();
    final difference = nextFeedingTime.difference(now);
    
    return difference.inMinutes;
  }
  
  /// 현재 언어 설정에 따른 알림 텍스트 가져오기
  Future<Map<String, String>> _getLocalizedNotificationTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ko';
    
    switch (languageCode) {
      case 'en':
        return {
          'title': 'It\'s feeding time! 🍼',
          'body': 'Baby might be hungry now.',
          'channelName': 'Feeding Reminders',
          'channelDescription': 'Feeding time reminder notifications',
        };
      case 'th':
        return {
          'title': 'ถึงเวลาให้นมแล้ว! 🍼',
          'body': 'ลูกอาจจะหิวแล้วนะ',
          'channelName': 'การแจ้งเตือนการให้นม',
          'channelDescription': 'การแจ้งเตือนเวลาให้นมลูก',
        };
      case 'ko':
      default:
        return {
          'title': '수유 시간이에요! 🍼',
          'body': '아기가 배고파할 시간입니다.',
          'channelName': '수유 알림',
          'channelDescription': '수유 시간 알림',
        };
    }
  }

  /// 알람 ID 생성 (타임스탬프 기반)
  int _generateAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % 2147483647; // int 최댓값 내에서
  }
  
  /// 마지막 수유까지 지난 시간 (분 단위) - 임시 구현
  Future<int?> _getLastFeedingMinutes() async {
    // 실제로는 feeding summary에서 가져와야 함
    return null;
  }
  
  /// 모든 수유 알람 정리 (앱 재시작 시 사용)
  Future<void> cleanupAlarms() async {
    try {
      await _notificationsPlugin.cancelAll();
      await _setActiveAlarmId(null);
      debugPrint('모든 수유 알람이 정리되었습니다.');
    } catch (e) {
      debugPrint('알람 정리 중 오류 발생: $e');
    }
  }
}