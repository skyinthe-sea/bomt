import 'package:flutter/foundation.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class TabControllerProvider extends ChangeNotifier {
  PersistentTabController? _controller;

  PersistentTabController? get controller => _controller;

  void setController(PersistentTabController controller) {
    _controller = controller;
    notifyListeners();
  }

  /// 홈 탭으로 이동 (인덱스 0)
  void navigateToHome() {
    if (_controller != null) {
      _controller!.jumpToTab(0);
    }
  }

  /// 타임라인 탭으로 이동 (인덱스 1)
  void navigateToTimeline() {
    if (_controller != null) {
      _controller!.jumpToTab(1);
    }
  }

  /// 통계 탭으로 이동 (인덱스 2)
  void navigateToStatistics() {
    if (_controller != null) {
      _controller!.jumpToTab(2);
    }
  }

  /// 커뮤니티 탭으로 이동 (인덱스 3)
  void navigateToCommunity() {
    if (_controller != null) {
      _controller!.jumpToTab(3);
    }
  }

  /// 특정 탭으로 이동
  void navigateToTab(int index) {
    if (_controller != null) {
      _controller!.jumpToTab(index);
    }
  }
}