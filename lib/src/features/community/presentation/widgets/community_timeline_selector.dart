import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../../../core/providers/baby_provider.dart';
import '../../../../services/timeline/timeline_service.dart';
import '../../../../domain/models/timeline_item.dart';
import '../../../../domain/models/baby.dart';
import '../../../baby/data/repositories/supabase_baby_repository.dart';
import 'compact_timeline_chart.dart';

class CommunityTimelineSelector extends StatefulWidget {
  final DateTime? selectedDate;
  final Map<String, dynamic>? timelineData;
  final void Function(DateTime? date, Map<String, dynamic>? data)? onTimelineChanged;

  const CommunityTimelineSelector({
    super.key,
    this.selectedDate,
    this.timelineData,
    this.onTimelineChanged,
  });

  @override
  State<CommunityTimelineSelector> createState() => _CommunityTimelineSelectorState();
}

class _CommunityTimelineSelectorState extends State<CommunityTimelineSelector> {
  DateTime? _selectedDate;
  Map<String, dynamic>? _timelineData;
  List<TimelineItem> _timelineItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _timelineData = widget.timelineData;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    // 현재 날짜를 기본값으로 사용 (실제 데이터는 2025년에 있음)
    final defaultDate = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: defaultDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: now,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });

      await _loadTimelineData(picked);
    }
  }

  // 타임라인 페이지와 동일한 방식으로 User ID 가져오기 (직접 Kakao API 사용)
  Future<String?> _getUserId() async {
    try {
      final user = await UserApi.instance.me();
      final userId = user.id.toString();
      print('DEBUG: Kakao userId: $userId');
      return userId;
    } catch (e) {
      print('DEBUG: Error getting user ID: $e');
      return null;
    }
  }

  Future<Baby?> _getCurrentBaby(String userId) async {
    try {
      final babyRepository = SupabaseBabyRepository();
      final babyEntities = await babyRepository.getBabiesByUserId(userId);
      
      print('DEBUG: Found ${babyEntities.length} babies for user $userId');
      
      if (babyEntities.isEmpty) {
        print('DEBUG: No babies found for user');
        return null;
      }

      final babyEntity = babyEntities.first;
      print('DEBUG: Using baby: ${babyEntity.id} - ${babyEntity.name}');
      
      return Baby(
        id: babyEntity.id,
        name: babyEntity.name,
        birthDate: babyEntity.birthDate,
        gender: babyEntity.gender,
        profileImageUrl: babyEntity.profileImageUrl,
        createdAt: babyEntity.createdAt,
        updatedAt: babyEntity.updatedAt,
      );
    } catch (e) {
      print('DEBUG: Error getting current baby: $e');
      return null;
    }
  }

  Future<void> _loadTimelineData(DateTime date) async {
    try {
      print('DEBUG: _loadTimelineData called with date: $date');
      
      // 1. 타임라인 페이지와 동일한 방식으로 Baby ID 가져오기
      final userId = await _getUserId();
      if (userId == null) {
        print('DEBUG: Failed to get user ID');
        return;
      }
      
      final currentBaby = await _getCurrentBaby(userId);
      if (currentBaby == null) {
        print('DEBUG: Failed to get current baby');
        return;
      }
      
      print('DEBUG: Using baby from direct query: ${currentBaby.id} - ${currentBaby.name}');

      // 2. TimelineService를 사용해서 데이터 가져오기
      final timelineService = TimelineService.instance;
      final timelineItems = await timelineService.getTimelineItemsForDate(currentBaby.id, date);
      
      print('DEBUG: TimelineService returned ${timelineItems.length} items');
      for (var item in timelineItems.take(3)) {
        print('DEBUG: ${item.type} - ${item.title} - ${item.subtitle} - ${item.timestamp}');
      }

      // 호환성을 위한 기존 형태의 데이터 구조 생성
      final timelineData = _convertTimelineItemsToLegacyFormat(timelineItems, date);
      
      // 게시글 저장용 완전한 타임라인 데이터 생성 (성능 최적화)
      final completeTimelineData = {
        'date': date.toIso8601String(),
        'activities': _convertTimelineItemsToLegacyFormat(timelineItems, date)['activities'],
        'timelineItems': timelineItems.map((item) => {
          'id': item.id,
          'type': item.type.name,
          'timestamp': item.timestamp.toIso8601String(),
          'title': item.title,
          'subtitle': item.subtitle,
          'data': item.data,
          'isOngoing': item.isOngoing,
          'colorCode': item.colorCode,
        }).toList(),
      };

      setState(() {
        _timelineData = completeTimelineData;
        _timelineItems = timelineItems;
        _isLoading = false;
      });

      widget.onTimelineChanged?.call(_selectedDate, _timelineData);
    } catch (e) {
      print('DEBUG: Error in _loadTimelineData: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('타임라인 데이터 로드 실패: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // TimelineItem들을 기존 형태의 데이터 구조로 변환 (호환성 유지)
  Map<String, dynamic> _convertTimelineItemsToLegacyFormat(List<TimelineItem> items, DateTime date) {
    final activities = <String, List<Map<String, dynamic>>>{
      'feedings': [],
      'sleeps': [],
      'diapers': [],
    };

    for (var item in items) {
      switch (item.type) {
        case TimelineItemType.feeding:
          activities['feedings']!.add({
            'type': item.data['type'] ?? 'bottle',
            'startedAt': item.timestamp.toIso8601String(),
            'endedAt': item.data['endedAt'],
            'amountMl': item.data['amountMl'] ?? 0,
            'durationMinutes': item.data['durationMinutes'] ?? 0,
          });
          break;
        case TimelineItemType.sleep:
          activities['sleeps']!.add({
            'startedAt': item.timestamp.toIso8601String(),
            'endedAt': item.data['endedAt'],
            'durationMinutes': item.data['durationMinutes'],
            'quality': item.data['quality'],
          });
          break;
        case TimelineItemType.diaper:
          activities['diapers']!.add({
            'changedAt': item.timestamp.toIso8601String(),
            'type': item.data['type'] ?? 'wet',
            'color': item.data['color'],
            'consistency': item.data['consistency'],
          });
          break;
        default:
          // 다른 타입들은 무시 (feeding, sleep, diaper만 지원)
          break;
      }
    }

    return {
      'date': date.toIso8601String(),
      'activities': activities,
    };
  }


  void _removeTimeline() {
    setState(() {
      _selectedDate = null;
      _timelineData = null;
    });
    widget.onTimelineChanged?.call(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '24시간 활동 패턴',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (_selectedDate != null)
                  IconButton(
                    onPressed: _removeTimeline,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
              ],
            ),
          ),

          // 내용
          if (_selectedDate == null)
            // 날짜 선택 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '날짜를 선택하여 타임라인 추가',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // 선택된 날짜 및 타임라인 미리보기
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택된 날짜
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedDate!.month}월 ${_selectedDate!.day}일',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(
                          '변경',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 타임라인 미리보기
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_timelineItems.isNotEmpty && _selectedDate != null)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CompactTimelineChart(
                          timelineItems: _timelineItems,
                          selectedDate: _selectedDate!,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '해당 날짜에 기록된 활동이 없습니다',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}