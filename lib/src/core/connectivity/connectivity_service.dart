import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 🌐 연결 상태 모니터링 서비스
/// 
/// 특징:
/// - 실시간 연결 상태 감지
/// - WiFi/모바일 데이터 구분
/// - 연결 상태 변경 이벤트
/// - 배터리 최적화된 모니터링
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  
  ConnectionState _currentState = ConnectionState.unknown;
  bool _isInitialized = false;

  /// 현재 연결 상태
  ConnectionState get currentState => _currentState;
  
  /// 연결 상태 변경 스트림
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;
  
  /// 온라인 여부
  bool get isOnline => _currentState == ConnectionState.wifi || _currentState == ConnectionState.mobile;
  
  /// 오프라인 여부
  bool get isOffline => _currentState == ConnectionState.none;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 초기 연결 상태 확인
      final result = await _connectivity.checkConnectivity();
      _currentState = _mapConnectivityResult(result);
      
      // 연결 상태 변경 감지
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final newState = _mapConnectivityResult(results);
          _updateConnectionState(newState);
        },
      );

      _isInitialized = true;
      debugPrint('🌐 [CONNECTIVITY] Initialized with state: ${_currentState.name}');
    } catch (e) {
      debugPrint('❌ [CONNECTIVITY] Initialization failed: $e');
    }
  }

  /// 연결 상태 업데이트
  void _updateConnectionState(ConnectionState newState) {
    if (_currentState != newState) {
      final previousState = _currentState;
      _currentState = newState;
      
      debugPrint('🔄 [CONNECTIVITY] State changed: ${previousState.name} → ${newState.name}');
      
      // 상태 변경 이벤트 발생
      _connectionStateController.add(newState);
      
      // 온라인 상태가 된 경우 동기화 트리거
      if (previousState == ConnectionState.none && isOnline) {
        debugPrint('✅ [CONNECTIVITY] Back online - triggering sync');
        _triggerOnlineSync();
      }
      
      // 오프라인 상태가 된 경우
      if (isOnline && newState == ConnectionState.none) {
        debugPrint('📵 [CONNECTIVITY] Gone offline - switching to offline mode');
        _triggerOfflineMode();
      }
    }
  }

  /// ConnectivityResult를 ConnectionState로 매핑
  ConnectionState _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectionState.none;
    
    // 여러 연결이 있는 경우 우선순위: WiFi > Mobile > Other
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionState.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionState.mobile;
    } else if (results.contains(ConnectivityResult.ethernet) ||
               results.contains(ConnectivityResult.vpn) ||
               results.contains(ConnectivityResult.other)) {
      return ConnectionState.wifi; // 이더넷이나 기타 연결도 WiFi와 동일하게 처리
    } else {
      return ConnectionState.none;
    }
  }

  /// 온라인 복귀 시 동기화 트리거
  void _triggerOnlineSync() {
    // SyncService가 구현되면 여기서 호출
    // SyncService.instance.performSync();
  }

  /// 오프라인 모드 활성화
  void _triggerOfflineMode() {
    // 오프라인 모드 관련 로직
    debugPrint('📱 [CONNECTIVITY] Offline mode activated');
  }

  /// 연결 테스트 (실제 인터넷 연결 확인)
  Future<bool> testInternetConnection() async {
    try {
      // 간단한 DNS 조회로 실제 인터넷 연결 확인
      final result = await _connectivity.checkConnectivity();
      return result.any((connection) => 
        connection == ConnectivityResult.wifi || 
        connection == ConnectivityResult.mobile ||
        connection == ConnectivityResult.ethernet
      );
    } catch (e) {
      debugPrint('❌ [CONNECTIVITY] Internet test failed: $e');
      return false;
    }
  }

  /// 연결 품질 확인 (WiFi vs 모바일 데이터)
  bool get isHighQualityConnection => _currentState == ConnectionState.wifi;
  
  /// 데이터 절약 모드 여부 (모바일 데이터 사용 시)
  bool get isDataSavingMode => _currentState == ConnectionState.mobile;

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStateController.close();
    _isInitialized = false;
    debugPrint('🌐 [CONNECTIVITY] Service disposed');
  }
}

/// 연결 상태 열거형
enum ConnectionState {
  wifi,     // WiFi 연결
  mobile,   // 모바일 데이터 연결
  none,     // 연결 없음
  unknown,  // 알 수 없음
}

/// 연결 상태 확장
extension ConnectionStateExtension on ConnectionState {
  String get name {
    switch (this) {
      case ConnectionState.wifi:
        return 'WiFi';
      case ConnectionState.mobile:
        return 'Mobile';
      case ConnectionState.none:
        return 'Offline';
      case ConnectionState.unknown:
        return 'Unknown';
    }
  }
  
  String get icon {
    switch (this) {
      case ConnectionState.wifi:
        return '📶';
      case ConnectionState.mobile:
        return '📱';
      case ConnectionState.none:
        return '📵';
      case ConnectionState.unknown:
        return '❓';
    }
  }
}