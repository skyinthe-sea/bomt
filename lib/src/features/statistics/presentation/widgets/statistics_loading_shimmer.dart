import 'package:flutter/material.dart';

class StatisticsLoadingShimmer extends StatefulWidget {
  const StatisticsLoadingShimmer({super.key});

  @override
  State<StatisticsLoadingShimmer> createState() => _StatisticsLoadingShimmerState();
}

class _StatisticsLoadingShimmerState extends State<StatisticsLoadingShimmer>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 개요 카드 시뮬러
          _buildShimmerCard(
            theme: theme,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          
          // 카드 그리드 시뮬러
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildShimmerCard(
                theme: theme,
                height: null,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 차트 섹션 시뮬러
          _buildShimmerCard(
            theme: theme,
            height: 150,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          _buildShimmerCard(
            theme: theme,
            height: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({
    required ThemeData theme,
    double? height,
    EdgeInsets? margin,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // 기본 배경
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                // 시머 효과
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                      _shimmerAnimation.value * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            theme.colorScheme.onSurface.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // 콘텐츠 플레이스홀더
                if (height != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(
                          theme: theme,
                          width: 150,
                          height: 20,
                        ),
                        const SizedBox(height: 8),
                        _buildShimmerBox(
                          theme: theme,
                          width: 100,
                          height: 14,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildShimmerBox(
                                theme: theme,
                                width: double.infinity,
                                height: 60,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildShimmerBox(
                                theme: theme,
                                width: double.infinity,
                                height: 60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildShimmerBox(
                              theme: theme,
                              width: 32,
                              height: 32,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildShimmerBox(
                                theme: theme,
                                width: double.infinity,
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildShimmerBox(
                          theme: theme,
                          width: double.infinity,
                          height: 50,
                        ),
                        const SizedBox(height: 12),
                        _buildShimmerBox(
                          theme: theme,
                          width: 80,
                          height: 12,
                        ),
                        const SizedBox(height: 6),
                        _buildShimmerBox(
                          theme: theme,
                          width: 120,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required ThemeData theme,
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}