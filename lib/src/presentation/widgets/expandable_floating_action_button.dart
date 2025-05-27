import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExpandableFloatingActionButton extends StatefulWidget {
  const ExpandableFloatingActionButton({super.key});

  @override
  State<ExpandableFloatingActionButton> createState() => _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState extends State<ExpandableFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _backgroundAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _backgroundAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
      _rotationController.forward();
    } else {
      _animationController.reverse();
      _rotationController.reverse();
    }
  }

  Widget _buildSubButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double right,
    required double bottom,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final scale = _expandAnimation.value.clamp(0.0, 1.0);
        
        return AnimatedPositioned(
          duration: Duration(milliseconds: (300 + (right * 2)).toInt()),
          curve: Curves.easeOutBack,
          right: 16 + (right * scale),
          bottom: 16 + (bottom * scale),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: scale,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      onTap();
                      _toggleExpanded();
                    },
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // 배경 오버레이 (애니메이션과 동기화)
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: GestureDetector(
                onTap: _isExpanded ? _toggleExpanded : null,
                child: Container(
                  color: Colors.black.withOpacity(0.3 * _backgroundAnimation.value),
                ),
              ),
            );
          },
        ),
        
        // 수유 버튼 - 위쪽
        _buildSubButton(
          icon: Icons.local_drink,
          label: '수유',
          color: const Color(0xFF4CAF50),
          right: 0,
          bottom: 100,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('수유 기록 기능 개발 중입니다')),
            );
          },
        ),
        
        // 수면 버튼 - 왼쪽 위 대각선
        _buildSubButton(
          icon: Icons.bedtime,
          label: '수면',
          color: const Color(0xFF673AB7),
          right: 70,
          bottom: 70,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('수면 기록 기능 개발 중입니다')),
            );
          },
        ),
        
        // 기저귀 버튼 - 왼쪽
        _buildSubButton(
          icon: Icons.child_care,
          label: '기저귀',
          color: const Color(0xFFFF9800),
          right: 100,
          bottom: 0,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('기저귀 기록 기능 개발 중입니다')),
            );
          },
        ),
        
        // 체온 버튼 - 왼쪽 아래 대각선
        _buildSubButton(
          icon: Icons.thermostat,
          label: '체온',
          color: const Color(0xFFF44336),
          right: 70,
          bottom: -30,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('체온 기록 기능 개발 중입니다')),
            );
          },
        ),
        
        // 메인 플로팅 액션 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.primary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: _toggleExpanded,
                      child: Icon(
                        _isExpanded ? Icons.close : Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}