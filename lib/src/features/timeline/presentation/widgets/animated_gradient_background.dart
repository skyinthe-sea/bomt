import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // 2024 트렌드 레트로-퓨처리스틱 파스텔 색상들
  final List<List<Color>> _gradientSets = [
    // Coral Pink & Lavender Purple
    [
      const Color(0xFFFFB7C5), // Coral Pink
      const Color(0xFFE6E6FA), // Lavender
      const Color(0xFFFFF0F5), // Lavender Blush
      const Color(0xFFFFB6C1), // Light Pink
    ],
    
    // Mint Green & Soft Blue
    [
      const Color(0xFF98FB98), // Pale Green
      const Color(0xFFE0FFFF), // Light Cyan
      const Color(0xFFAFEEEE), // Pale Turquoise
      const Color(0xFFE6F3FF), // Alice Blue
    ],
    
    // Mustard Yellow & Faded Turquoise
    [
      const Color(0xFFFFF8DC), // Cornsilk
      const Color(0xFFFFE4B5), // Moccasin
      const Color(0xFFAFEEEE), // Pale Turquoise
      const Color(0xFFE0FFFF), // Light Cyan
    ],
    
    // Soft Peach & Mint
    [
      const Color(0xFFFFE4E1), // Misty Rose
      const Color(0xFFFFF0F5), // Lavender Blush
      const Color(0xFFF0FFF0), // Honeydew
      const Color(0xFFE6FFE6), // Very Light Green
    ],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildAnimatedGradient(),
          ),
          child: widget.child,
        );
      },
    );
  }

  LinearGradient _buildAnimatedGradient() {
    final progress = _animation.value;
    final currentSetIndex = (progress * _gradientSets.length).floor() % _gradientSets.length;
    final nextSetIndex = (currentSetIndex + 1) % _gradientSets.length;
    final localProgress = (progress * _gradientSets.length) % 1.0;

    final currentSet = _gradientSets[currentSetIndex];
    final nextSet = _gradientSets[nextSetIndex];

    // 현재 세트와 다음 세트 사이를 보간
    final interpolatedColors = List.generate(4, (index) {
      return Color.lerp(
        currentSet[index],
        nextSet[index],
        localProgress,
      )!;
    });

    // 복잡한 그라디언트를 위한 다중 색상 포인트
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.3, 0.7, 1.0],
      colors: interpolatedColors,
    );
  }
}

// 부유하는 파티클 효과를 위한 위젯
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Duration animationDuration;

  const FloatingParticles({
    Key? key,
    this.particleCount = 20,
    this.animationDuration = const Duration(seconds: 15),
  }) : super(key: key);

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Color> _particleColors;
  late List<double> _particleSizes;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = Random();
    _controllers = [];
    _animations = [];
    _particleColors = [];
    _particleSizes = [];

    // 파스텔 색상 팔레트
    final colors = [
      const Color(0xFFFFB7C5).withOpacity(0.3), // Coral Pink
      const Color(0xFFE6E6FA).withOpacity(0.3), // Lavender
      const Color(0xFF98FB98).withOpacity(0.3), // Pale Green
      const Color(0xFFFFE4B5).withOpacity(0.3), // Moccasin
      const Color(0xFFAFEEEE).withOpacity(0.3), // Pale Turquoise
    ];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 10000 + random.nextInt(10000), // 10-20초
        ),
        vsync: this,
      );

      final startX = random.nextDouble() * 2 - 1; // -1 to 1
      final startY = random.nextDouble() * 2 - 1; // -1 to 1
      final endX = random.nextDouble() * 2 - 1;
      final endY = random.nextDouble() * 2 - 1;

      final animation = Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(endX, endY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutSine,
      ));

      _controllers.add(controller);
      _animations.add(animation);
      _particleColors.add(colors[random.nextInt(colors.length)]);
      _particleSizes.add(2.0 + random.nextDouble() * 4.0); // 2-6 크기

      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(widget.particleCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            final position = _animations[index].value;
            
            return Positioned(
              left: (position.dx + 1) * size.width / 2,
              top: (position.dy + 1) * size.height / 2,
              child: Container(
                width: _particleSizes[index],
                height: _particleSizes[index],
                decoration: BoxDecoration(
                  color: _particleColors[index],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _particleColors[index],
                      blurRadius: _particleSizes[index] * 2,
                      spreadRadius: _particleSizes[index],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      ),
    );
  }
}

// 모던한 그라디언트 오버레이
class ModernGradientOverlay extends StatelessWidget {
  final Widget child;

  const ModernGradientOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 메인 콘텐츠
        child,
        
        // 상단 그라디언트 오버레이
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x40FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // 하단 그라디언트 오버레이
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 50,
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x20FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}