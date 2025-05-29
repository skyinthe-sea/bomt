import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final String deleteConfirmMessage;
  final bool isDeletable;
  final Color deleteButtonColor;
  final IconData deleteIcon;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onDelete,
    this.deleteConfirmMessage = '이 기록을 삭제하시겠습니까?',
    this.isDeletable = true,
    this.deleteButtonColor = Colors.red,
    this.deleteIcon = Icons.delete_outline,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _deleteController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _deleteAnimation;
  
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isDeleting = false;
  bool _hasTriggeredHaptic = false;

  static const double _deleteThreshold = 80.0;
  static const double _maxSlide = 120.0;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _deleteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_maxSlide, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _deleteAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _deleteController,
      curve: Curves.easeInBack,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.isDeletable) return;
    
    setState(() {
      _isDragging = true;
      _hasTriggeredHaptic = false;
    });
    _slideController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.isDeletable || _isDeleting) return;
    
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-_maxSlide, 0.0);
    });
    
    // 임계값 도달 시 햅틱 피드백
    if (_dragOffset.abs() >= _deleteThreshold && !_hasTriggeredHaptic) {
      HapticFeedback.mediumImpact();
      setState(() {
        _hasTriggeredHaptic = true;
      });
    } else if (_dragOffset.abs() < _deleteThreshold && _hasTriggeredHaptic) {
      setState(() {
        _hasTriggeredHaptic = false;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.isDeletable || _isDeleting) return;
    
    // 현재 드래그 위치를 슬라이드 컨트롤러 값으로 변환
    final currentSlideValue = _dragOffset.abs() / _maxSlide;
    
    // 깜빡임 방지: 현재 위치에서 애니메이션 시작
    _slideController.value = currentSlideValue;
    
    setState(() {
      _isDragging = false;
    });
    
    // 임계값을 넘었다면 삭제 버튼 표시 상태 유지
    if (_dragOffset.abs() >= _deleteThreshold) {
      _slideController.animateTo(1.0);
    } else {
      _resetPosition();
    }
  }

  void _resetPosition() {
    setState(() {
      _dragOffset = 0.0;
      _isDragging = false;
      _isDeleting = false;
      _hasTriggeredHaptic = false;
    });
    _slideController.reset(); // animateTo(0.0) 대신 즉시 초기화
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null) return;
    
    HapticFeedback.mediumImpact();
    
    // 삭제 확인 다이얼로그 표시
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      _resetPosition();
      return;
    }
    
    // 삭제 애니메이션 실행
    setState(() {
      _isDeleting = true;
    });
    
    await _deleteController.forward();
    
    // 삭제 콜백 실행
    widget.onDelete!();
    
    // 삭제 후 애니메이션 복구 (카드를 다시 보이게 함)
    await _deleteController.reverse();
    
    // 스와이프 위치도 원래대로 복구
    _resetPosition();
    
    setState(() {
      _isDeleting = false;
    });
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text(widget.deleteConfirmMessage),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: widget.deleteButtonColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _deleteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _deleteAnimation.value,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // 삭제 버튼 배경
                Positioned.fill(
                  child: Container(
                    color: widget.deleteButtonColor,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: _maxSlide,
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.deleteIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '삭제',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 메인 카드
                GestureDetector(
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  onTap: () {
                    if (_slideController.value > 0) {
                      _resetPosition();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      final currentOffset = _isDragging 
                          ? Offset(_dragOffset, 0) 
                          : _slideAnimation.value;
                      
                      return Transform.translate(
                        offset: currentOffset,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isDragging || _slideController.value > 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(-2, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: widget.child,
                        ),
                      );
                    },
                  ),
                ),
                
                // 삭제 버튼 터치 영역
                if (_slideController.value > 0 || _dragOffset.abs() >= _deleteThreshold)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: _maxSlide,
                    child: GestureDetector(
                      onTap: _handleDelete,
                      child: Container(
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: _maxSlide,
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.deleteIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '삭제',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}