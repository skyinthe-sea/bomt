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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.primaryContainer.withOpacity(0.1),
          ],
        ),
      ),
      child: child,
    );
  }
}