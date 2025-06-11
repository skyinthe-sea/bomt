import 'package:flutter/material.dart';

class CommunityLoadingShimmer extends StatefulWidget {
  const CommunityLoadingShimmer({super.key});

  @override
  State<CommunityLoadingShimmer> createState() => _CommunityLoadingShimmerState();
}

class _CommunityLoadingShimmerState extends State<CommunityLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 100), // AppBar 공간
          
          // 배너 스켈레톤
          _ShimmerContainer(
            animation: _animation,
            height: 80,
            borderRadius: 20,
          ),
          
          const SizedBox(height: 20),
          
          // 카테고리 탭 스켈레톤
          Row(
            children: List.generate(4, (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                child: _ShimmerContainer(
                  animation: _animation,
                  height: 40,
                  borderRadius: 20,
                ),
              ),
            )),
          ),
          
          const SizedBox(height: 20),
          
          // 게시글 카드 스켈레톤들
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PostCardSkeleton(animation: _animation),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  final Animation<double> animation;

  const _PostCardSkeleton({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보 스켈레톤
          Row(
            children: [
              _ShimmerContainer(
                animation: animation,
                width: 60,
                height: 20,
                borderRadius: 8,
              ),
              const SizedBox(width: 12),
              _ShimmerContainer(
                animation: animation,
                width: 20,
                height: 20,
                borderRadius: 10,
              ),
              const SizedBox(width: 8),
              _ShimmerContainer(
                animation: animation,
                width: 80,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 제목 스켈레톤
          _ShimmerContainer(
            animation: animation,
            height: 20,
            borderRadius: 4,
          ),
          
          const SizedBox(height: 8),
          
          // 내용 스켈레톤
          _ShimmerContainer(
            animation: animation,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          _ShimmerContainer(
            animation: animation,
            width: 200,
            height: 16,
            borderRadius: 4,
          ),
          
          const SizedBox(height: 16),
          
          // 하단 버튼들 스켈레톤
          Row(
            children: [
              _ShimmerContainer(
                animation: animation,
                width: 60,
                height: 24,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              _ShimmerContainer(
                animation: animation,
                width: 60,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerContainer extends StatelessWidget {
  final Animation<double> animation;
  final double? width;
  final double height;
  final double borderRadius;

  const _ShimmerContainer({
    required this.animation,
    this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(animation.value - 1, 0),
              end: Alignment(animation.value, 0),
              colors: [
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}