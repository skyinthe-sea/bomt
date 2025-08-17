import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';

class TimelineItemEditDialog extends StatefulWidget {
  final TimelineItem item;
  final Function(TimelineItem) onSaved;

  const TimelineItemEditDialog({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  State<TimelineItemEditDialog> createState() => _TimelineItemEditDialogState();
}

class _TimelineItemEditDialogState extends State<TimelineItemEditDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TextEditingController _notesController;
  late DateTime _selectedDateTime;
  late Map<String, dynamic> _editedData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _initializeData() {
    _selectedDateTime = widget.item.timestamp;
    _editedData = Map<String, dynamic>.from(widget.item.data);
    _notesController = TextEditingController(
      text: _editedData['notes']?.toString() ?? '',
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 핸들과 헤더
                    _buildHeader(theme, localizations),
                    
                    // 스크롤 가능한 콘텐츠
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 시간 편집
                            _buildDateTimeSection(theme, localizations),
                            
                            const SizedBox(height: 24),
                            
                            // 타입별 특정 필드들
                            ..._buildTypeSpecificFields(theme, localizations),
                            
                            const SizedBox(height: 24),
                            
                            // 메모 편집
                            _buildNotesSection(theme, localizations),
                            
                            const SizedBox(height: 32),
                            
                            // 저장 버튼
                            _buildSaveButton(theme, localizations),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 헤더 타이틀
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getItemTypeColor(widget.item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getItemTypeIcon(widget.item.type),
                  color: _getItemTypeColor(widget.item.type),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.editRecord,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getItemTypeDisplayName(widget.item.type, localizations),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 닫기 버튼
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
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
                Icons.schedule_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.dateTime,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // 날짜 선택
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDateTime.month}/${_selectedDateTime.day}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 시간 선택
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields(ThemeData theme, AppLocalizations localizations) {
    final widgets = <Widget>[];

    switch (widget.item.type) {
      case TimelineItemType.feeding:
        widgets.addAll([
          _buildNumberField(
            localizations.amount,
            'amount_ml',
            'ml',
            Icons.local_drink_rounded,
            theme,
            localizations,
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            localizations.duration,
            'duration_minutes',
            localizations.minutes,
            Icons.timer_rounded,
            theme,
            localizations,
          ),
        ]);
        break;

      case TimelineItemType.sleep:
        widgets.addAll([
          _buildNumberField(
            localizations.duration,
            'duration_minutes',
            localizations.minutes,
            Icons.timer_rounded,
            theme,
            localizations,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            localizations.sleepQuality,
            'quality',
            ['good', 'fair', 'poor'],
            (value) => _getQualityDisplayName(value, localizations),
            Icons.sentiment_satisfied_rounded,
            theme,
            localizations,
          ),
        ]);
        break;

      case TimelineItemType.medication:
        widgets.addAll([
          _buildTextField(
            localizations.medicationName,
            'medication_name',
            Icons.medication_rounded,
            theme,
            localizations,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            localizations.dosage,
            'dosage',
            Icons.local_pharmacy_rounded,
            theme,
            localizations,
          ),
        ]);
        break;

      case TimelineItemType.milkPumping:
        widgets.addAll([
          _buildNumberField(
            localizations.amount,
            'amount_ml',
            'ml',
            Icons.water_drop_rounded,
            theme,
            localizations,
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            localizations.duration,
            'duration_minutes',
            localizations.minutes,
            Icons.timer_rounded,
            theme,
            localizations,
          ),
        ]);
        break;

      default:
        // 기본 필드들
        break;
    }

    return widgets;
  }

  Widget _buildNumberField(
    String label,
    String key,
    String unit,
    IconData icon,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final controller = TextEditingController(
      text: _editedData[key]?.toString() ?? '',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    final intValue = int.tryParse(value);
                    _editedData[key] = intValue;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String key,
    IconData icon,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final controller = TextEditingController(
      text: _editedData[key]?.toString() ?? '',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: controller,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _editedData[key] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String key,
    List<String> options,
    String Function(String) displayNameGetter,
    IconData icon,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final currentValue = _editedData[key]?.toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: options.contains(currentValue) ? currentValue : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(displayNameGetter(option)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _editedData[key] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                color: theme.colorScheme.primary,
                size: 20,
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
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: localizations.notesHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              _editedData['notes'] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              )
            : Text(
                localizations.saveChanges,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (selectedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 업데이트된 아이템 생성
      final updatedItem = widget.item.copyWith(
        timestamp: _selectedDateTime,
        data: _editedData,
      );

      // TODO: 실제 저장 로직 구현
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onSaved(updatedItem);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.changesSaved),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
    switch (type) {
      case TimelineItemType.feeding:
        return const Color(0xFF10B981);
      case TimelineItemType.sleep:
        return const Color(0xFF8B5FBF);
      case TimelineItemType.diaper:
        return const Color(0xFFFFB020);
      case TimelineItemType.medication:
        return const Color(0xFFEF4444);
      case TimelineItemType.milkPumping:
        return const Color(0xFF06B6D4);
      case TimelineItemType.solidFood:
        return const Color(0xFFF59E0B);
      case TimelineItemType.temperature:
        return const Color(0xFFEC4899);
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
}