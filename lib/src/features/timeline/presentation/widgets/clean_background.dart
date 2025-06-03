import 'package:flutter/material.dart';

/// 홈스크린처럼 깔끔한 백그라운드 위젯
class CleanBackground extends StatelessWidget {
  final Widget child;

  const CleanBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
      ),
      child: child,
    );
  }
}