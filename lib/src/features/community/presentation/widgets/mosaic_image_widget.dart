import 'package:flutter/material.dart';

class MosaicImageWidget extends StatefulWidget {
  final String originalImageUrl;
  final String? mosaicImageUrl;
  final bool hasMosaic;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MosaicImageWidget({
    super.key,
    required this.originalImageUrl,
    this.mosaicImageUrl,
    required this.hasMosaic,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<MosaicImageWidget> createState() => _MosaicImageWidgetState();
}

class _MosaicImageWidgetState extends State<MosaicImageWidget> {
  bool _showBlurred = true; // 기본적으로 블러/딤 상태로 시작

  @override
  void initState() {
    super.initState();
    _showBlurred = widget.hasMosaic; // 모자이크(딤 처리)가 있으면 블러 상태로 시작
  }

  void _toggleBlur() {
    if (widget.hasMosaic) {
      setState(() {
        _showBlurred = !_showBlurred;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.hasMosaic ? _toggleBlur : null,
      child: Stack(
        children: [
          // 메인 이미지 (항상 원본)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              image: DecorationImage(
                image: NetworkImage(widget.originalImageUrl),
                fit: widget.fit,
              ),
            ),
          ),
          
          // 딤 처리 오버레이 (모자이크 대신)
          if (widget.hasMosaic && _showBlurred)
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: Colors.black.withOpacity(0.98), // 98% 딤 처리 (거의 완전히 가림)
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_off,
                      color: Colors.white, // 완전히 흰색으로
                      size: widget.width != null && widget.width! < 100 ? 20 : 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '민감한 이미지',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white, // 완전히 흰색으로
                        fontSize: widget.width != null && widget.width! < 100 ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '탭하여 보기',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9), // 조금 더 선명하게
                        fontSize: widget.width != null && widget.width! < 100 ? 8 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 상태 표시 (모자이크가 있는 경우만)
          if (widget.hasMosaic && !_showBlurred)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '원본',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}