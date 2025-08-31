import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';
import '../widgets/timeline_item_pattern_analysis.dart';
import '../widgets/timeline_item_edit_dialog.dart';

class TimelineItemDetailScreen extends StatefulWidget {
  final TimelineItem item;
  final String heroTag;

  const TimelineItemDetailScreen({
    super.key,
    required this.item,
    required this.heroTag,
  });

  @override
  State<TimelineItemDetailScreen> createState() => _TimelineItemDetailScreenState();
}

class _TimelineItemDetailScreenState extends State<TimelineItemDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;

  bool _isDeleting = false;
  TimelineItem? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scrollController = ScrollController();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      body: Stack(
        children: [
          // 백그라운드 블러 효과
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          // 메인 콘텐츠
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // 커스텀 앱바
                  _buildCustomAppBar(theme, localizations),
                  
                  // 스크롤 가능한 콘텐츠
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildScrollableContent(theme, localizations),
                      ),
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

  Widget _buildCustomAppBar(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 타이틀과 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemTypeDisplayName(_currentItem!.type, localizations),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formatDateTime(_currentItem!.timestamp),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // 액션 버튼들
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 편집 버튼
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: _showEditDialog,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 삭제 버튼
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  onPressed: _showDeleteConfirmation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(ThemeData theme, AppLocalizations localizations) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero 카드
          _buildHeroCard(theme, localizations),
          
          const SizedBox(height: 20),
          
          // 상세 정보
          _buildDetailCard(theme, localizations),
          
          const SizedBox(height: 20),
          
          // 스마트 패턴 분석
          TimelineItemPatternAnalysis(
            item: _currentItem!,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme, AppLocalizations localizations) {
    return Hero(
      tag: widget.heroTag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getItemTypeColor(_currentItem!.type).withOpacity(0.8),
                _getItemTypeColor(_currentItem!.type).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getItemTypeColor(_currentItem!.type).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getItemTypeIcon(_currentItem!.type),
                  size: 32,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentItem!.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_currentItem!.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _currentItem!.subtitle!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatDetailedDateTime(_currentItem!.timestamp, localizations),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.detailInformation,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._buildTypeSpecificDetails(theme, localizations),
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificDetails(ThemeData theme, AppLocalizations localizations) {
    final data = _currentItem!.data;
    final widgets = <Widget>[];

    switch (_currentItem!.type) {
      case TimelineItemType.feeding:
        if (data.containsKey('amount_ml')) {
          widgets.add(_buildDetailRow(
            localizations.amount,
            '${data['amount_ml']} ml',
            Icons.local_drink_rounded,
            theme,
          ));
        }
        if (data.containsKey('duration_minutes')) {
          widgets.add(_buildDetailRow(
            localizations.duration,
            '${data['duration_minutes']} ${localizations.minutes}',
            Icons.timer_rounded,
            theme,
          ));
        }
        if (data.containsKey('type')) {
          widgets.add(_buildDetailRow(
            localizations.feedingType,
            _getFeedingTypeDisplayName(data['type'], localizations),
            Icons.category_rounded,
            theme,
          ));
        }
        if (data.containsKey('side')) {
          widgets.add(_buildDetailRow(
            localizations.side,
            _getSideDisplayName(data['side'], localizations),
            Icons.baby_changing_station_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.sleep:
        if (data.containsKey('duration_minutes')) {
          widgets.add(_buildDetailRow(
            localizations.duration,
            _formatDuration(data['duration_minutes'], localizations),
            Icons.timer_rounded,
            theme,
          ));
        }
        if (data.containsKey('quality')) {
          widgets.add(_buildDetailRow(
            localizations.sleepQuality,
            _getQualityDisplayName(data['quality'], localizations),
            Icons.sentiment_satisfied_rounded,
            theme,
          ));
        }
        if (data.containsKey('location')) {
          widgets.add(_buildDetailRow(
            localizations.location,
            data['location'].toString(),
            Icons.location_on_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.diaper:
        if (data.containsKey('type')) {
          widgets.add(_buildDetailRow(
            localizations.diaperType,
            _getDiaperTypeDisplayName(data['type'], localizations),
            Icons.baby_changing_station_rounded,
            theme,
          ));
        }
        if (data.containsKey('color')) {
          widgets.add(_buildDetailRow(
            localizations.color,
            data['color'].toString(),
            Icons.palette_rounded,
            theme,
          ));
        }
        if (data.containsKey('consistency')) {
          widgets.add(_buildDetailRow(
            localizations.consistency,
            data['consistency'].toString(),
            Icons.texture_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.medication:
        if (data.containsKey('medication_name')) {
          widgets.add(_buildDetailRow(
            localizations.medicationName,
            data['medication_name'].toString(),
            Icons.medication_rounded,
            theme,
          ));
        }
        if (data.containsKey('dosage')) {
          widgets.add(_buildDetailRow(
            localizations.dosage,
            data['dosage'].toString(),
            Icons.local_pharmacy_rounded,
            theme,
          ));
        }
        if (data.containsKey('unit')) {
          widgets.add(_buildDetailRow(
            localizations.unit,
            data['unit'].toString(),
            Icons.straighten_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.milkPumping:
        if (data.containsKey('amount_ml')) {
          widgets.add(_buildDetailRow(
            localizations.amount,
            '${data['amount_ml']} ml',
            Icons.local_drink_rounded,
            theme,
          ));
        }
        if (data.containsKey('duration_minutes')) {
          widgets.add(_buildDetailRow(
            localizations.duration,
            _formatDuration(data['duration_minutes'], localizations),
            Icons.timer_rounded,
            theme,
          ));
        }
        if (data.containsKey('side')) {
          widgets.add(_buildDetailRow(
            localizations.side,
            _getSideDisplayName(data['side'], localizations),
            Icons.baby_changing_station_rounded,
            theme,
          ));
        }
        if (data.containsKey('storage_method')) {
          widgets.add(_buildDetailRow(
            localizations.storageMethod,
            _getStorageMethodDisplayName(data['storage_method'], localizations),
            Icons.storage_rounded,
            theme,
          ));
        }
        if (data.containsKey('pumping_type')) {
          widgets.add(_buildDetailRow(
            localizations.pumpingType,
            data['pumping_type'].toString(),
            Icons.category_rounded,
            theme,
          ));
        }
        if (data.containsKey('quality')) {
          widgets.add(_buildDetailRow(
            localizations.quality,
            _getQualityDisplayName(data['quality'], localizations),
            Icons.sentiment_satisfied_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.solidFood:
        if (data.containsKey('food_name')) {
          widgets.add(_buildDetailRow(
            localizations.foodName,
            data['food_name'].toString(),
            Icons.restaurant_rounded,
            theme,
          ));
        }
        if (data.containsKey('amount')) {
          widgets.add(_buildDetailRow(
            localizations.amount,
            data['amount'].toString(),
            Icons.local_drink_rounded,
            theme,
          ));
        }
        if (data.containsKey('meal_type')) {
          widgets.add(_buildDetailRow(
            localizations.mealType,
            _getMealTypeDisplayName(data['meal_type'], localizations),
            Icons.category_rounded,
            theme,
          ));
        }
        if (data.containsKey('texture')) {
          widgets.add(_buildDetailRow(
            localizations.texture,
            data['texture'].toString(),
            Icons.texture_rounded,
            theme,
          ));
        }
        if (data.containsKey('reaction')) {
          widgets.add(_buildDetailRow(
            localizations.reaction,
            data['reaction'].toString(),
            Icons.sentiment_satisfied_rounded,
            theme,
          ));
        }
        break;

      case TimelineItemType.temperature:
        if (data.containsKey('temperature')) {
          widgets.add(_buildDetailRow(
            localizations.temperature,
            '${data['temperature']}°C',
            Icons.thermostat_rounded,
            theme,
          ));
        }
        if (data.containsKey('measurement_location')) {
          widgets.add(_buildDetailRow(
            localizations.measurementLocation,
            data['measurement_location'].toString(),
            Icons.location_on_rounded,
            theme,
          ));
        }
        if (data.containsKey('fever_reducer_given')) {
          if (data['fever_reducer_given'] == true) {
            widgets.add(_buildDetailRow(
              localizations.feverReducerGiven,
              localizations.given,
              Icons.medication_rounded,
              theme,
            ));
          }
        }
        break;
    }

    // 메모 추가
    if (data.containsKey('notes') && data['notes'] != null && data['notes'].toString().isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(_buildNotesSection(data['notes'].toString(), theme, localizations));
    }

    return widgets;
  }

  Widget _buildDetailRow(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes, ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.notes,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }



  void _showEditDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimelineItemEditDialog(
        item: _currentItem!,
        onSaved: (updatedItem) {
          setState(() {
            _currentItem = updatedItem;
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteRecord),
        content: Text(AppLocalizations.of(context)!.deleteRecordConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: _deleteRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord() async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });

    try {
      // TODO: 실제 삭제 로직 구현
      Navigator.of(context).pop(); // 다이얼로그 닫기
      Navigator.of(context).pop(); // 상세화면 닫기
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recordDeleted),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deleteFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }



  // 헬퍼 메서드들
  String _getItemTypeDisplayName(TimelineItemType type, AppLocalizations localizations) {
    switch (type) {
      case TimelineItemType.feeding:
        return localizations.feeding;
      case TimelineItemType.sleep:
        return localizations.sleep;
      case TimelineItemType.diaper:
        return localizations.diaper;
      case TimelineItemType.medication:
        return localizations.medication;
      case TimelineItemType.milkPumping:
        return localizations.milkPumping;
      case TimelineItemType.solidFood:
        return localizations.solidFood;
      case TimelineItemType.temperature:
        return localizations.temperature;
    }
  }

  IconData _getItemTypeIcon(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.feeding:
        return Icons.local_drink_rounded;
      case TimelineItemType.sleep:
        return Icons.bedtime_rounded;
      case TimelineItemType.diaper:
        return Icons.baby_changing_station_rounded;
      case TimelineItemType.medication:
        return Icons.medication_rounded;
      case TimelineItemType.milkPumping:
        return Icons.water_drop_rounded;
      case TimelineItemType.solidFood:
        return Icons.restaurant_rounded;
      case TimelineItemType.temperature:
        return Icons.thermostat_rounded;
    }
  }

  Color _getItemTypeColor(TimelineItemType type) {
    // 이모티콘 색상과 일치하는 색상 사용
    switch (type) {
      case TimelineItemType.feeding:
        return const Color(0xFF3B82F6); // Blue 500 - 수유 🍼
      case TimelineItemType.sleep:
        return const Color(0xFF8B5FBF); // Purple - 수면 🌙
      case TimelineItemType.diaper:
        return const Color(0xFFFFB020); // Orange - 기저귀
      case TimelineItemType.medication:
        return const Color(0xFFEF4444); // Red 500 - 투약 💊
      case TimelineItemType.milkPumping:
        return const Color(0xFF06B6D4); // Cyan 500 - 유축 🥛
      case TimelineItemType.solidFood:
        return const Color(0xFF10B981); // Emerald 500 - 이유식 🍽️
      case TimelineItemType.temperature:
        return const Color(0xFFEC4899); // Pink 500 - 체온
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDetailedDateTime(DateTime dateTime, AppLocalizations localizations) {
    final weekdays = [localizations.monday, localizations.tuesday, localizations.wednesday, localizations.thursday, localizations.friday, localizations.saturday, localizations.sunday];
    final weekday = weekdays[dateTime.weekday - 1];
    return '${dateTime.month}월 ${dateTime.day}일 ($weekday) ${_formatDateTime(dateTime)}';
  }

  String _formatDuration(int? minutes, AppLocalizations localizations) {
    if (minutes == null) return '-';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}${localizations.hours} ${mins}${localizations.minutes}';
    }
    return '${mins}${localizations.minutes}';
  }

  String _getFeedingTypeDisplayName(String type, AppLocalizations localizations) {
    switch (type) {
      case 'breast':
        return localizations.breastMilk;
      case 'bottle':
        return localizations.bottle;
      case 'formula':
        return localizations.formula;
      default:
        return type;
    }
  }

  String _getSideDisplayName(String side, AppLocalizations localizations) {
    switch (side) {
      case 'left':
        return localizations.left;
      case 'right':
        return localizations.right;
      case 'both':
        return localizations.both;
      default:
        return side;
    }
  }

  String _getQualityDisplayName(String quality, AppLocalizations localizations) {
    switch (quality) {
      case 'good':
        return localizations.good;
      case 'fair':
        return localizations.fair;
      case 'poor':
        return localizations.poor;
      default:
        return quality;
    }
  }

  String _getDiaperTypeDisplayName(String type, AppLocalizations localizations) {
    switch (type) {
      case 'wet':
        return localizations.wet;
      case 'dirty':
        return localizations.dirty;
      case 'both':
        return localizations.both;
      default:
        return type;
    }
  }

  String _getStorageMethodDisplayName(String method, AppLocalizations localizations) {
    switch (method) {
      case 'refrigerator':
        return localizations.refrigerator;
      case 'freezer':
        return localizations.freezer;
      case 'room_temp':
        return localizations.roomTemperature;
      case 'fed_immediately':
        return localizations.fedImmediately;
      default:
        return method;
    }
  }

  String _getMealTypeDisplayName(String type, AppLocalizations localizations) {
    switch (type) {
      case 'breakfast':
        return localizations.breakfast;
      case 'lunch':
        return localizations.lunch;
      case 'dinner':
        return localizations.dinner;
      case 'snack':
        return localizations.snack;
      default:
        return type;
    }
  }

}