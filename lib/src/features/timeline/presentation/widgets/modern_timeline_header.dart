import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class ModernTimelineHeader extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onDatePicker;
  final bool isFuture;

  const ModernTimelineHeader({
    Key? key,
    required this.selectedDate,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onDatePicker,
    required this.isFuture,
  }) : super(key: key);

  @override
  State<ModernTimelineHeader> createState() => _ModernTimelineHeaderState();
}

class _ModernTimelineHeaderState extends State<ModernTimelineHeader>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: const Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 메인 헤더
          Row(
            children: [
              // 뒤로가기 버튼
              _buildGlassmorphicButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPreviousDay();
                },
              ),
              
              // 날짜 섹션
              Expanded(
                child: _buildDateSection(),
              ),
              
              // 앞으로가기 버튼
              _buildGlassmorphicButton(
                icon: Icons.chevron_right_rounded,
                onTap: widget.isFuture ? null : () {
                  HapticFeedback.lightImpact();
                  widget.onNextDay();
                },
                isDisabled: widget.isFuture,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 부제목과 데이터 요약
          _buildSubtitleSection(),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : () {
        debugPrint('🔥 [HEADER] Button tapped: $icon');
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.all(2), // 터치 영역 확장
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDisabled
                ? [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(isDisabled ? 0.1 : 0.4),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(
          icon,
          color: isDisabled 
              ? const Color(0xFF9CA3AF) 
              : const Color(0xFF374151),
          size: 26,
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final dateFormat = DateFormat('M월 d일', 'ko_KR');
    final dayFormat = DateFormat('EEEE', 'ko_KR');
    final formattedDate = dateFormat.format(widget.selectedDate);
    final formattedDay = dayFormat.format(widget.selectedDate);
    
    final isToday = DateTime.now().day == widget.selectedDate.day &&
                   DateTime.now().month == widget.selectedDate.month &&
                   DateTime.now().year == widget.selectedDate.year;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onDatePicker();
      },
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF10B981).withOpacity(0.15),
                  const Color(0xFF34D399).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 쉬머 효과
                if (isToday)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [
                              _shimmerAnimation.value - 0.3,
                              _shimmerAnimation.value,
                              _shimmerAnimation.value + 0.3,
                            ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // 날짜 콘텐츠
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '오늘',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          formattedDay,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubtitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // 타임라인 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5FBF),
                  Color(0xFFB794F6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5FBF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 설명 텍스트
          const Expanded(
            child: Text(
              '하루의 모든 순간을 기록해보세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          
          // 인사이트 아이콘
          Icon(
            Icons.insights_rounded,
            color: const Color(0xFF8B5FBF).withOpacity(0.6),
            size: 20,
          ),
        ],
      ),
    );
  }
}