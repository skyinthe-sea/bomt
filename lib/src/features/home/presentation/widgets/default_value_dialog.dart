import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

/// 카드별 기본값 설정 다이얼로그
/// 
/// 각 카드 타입별로 다른 설정 옵션들을 제공합니다:
/// - feeding: 수유량, 수유 타입, 수유 시간, 수유 위치
/// - sleep: 수면 시간, 수면 품질, 수면 장소
/// - diaper: 기저귀 타입, 색상, 농도
/// - solid_food: 음식 이름, 양, 알레르기 반응
/// - medication: 약물 이름, 용량, 단위, 투여 경로
/// - milk_pumping: 유축량, 유축 시간, 유축 위치, 보관 위치
class DefaultValueDialog extends StatefulWidget {
  final String cardType;
  final Color cardColor;
  final String cardName;
  final Map<String, dynamic> currentSettings;
  final Function(Map<String, dynamic>) onSave;

  const DefaultValueDialog({
    super.key,
    required this.cardType,
    required this.cardColor,
    required this.cardName,
    required this.currentSettings,
    required this.onSave,
  });

  @override
  State<DefaultValueDialog> createState() => _DefaultValueDialogState();
}

class _DefaultValueDialogState extends State<DefaultValueDialog> {
  late Map<String, dynamic> _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.currentSettings);
    _initializeDefaultValues();
  }
  
  /// 카드 타입별 기본값 초기화
  void _initializeDefaultValues() {
    switch (widget.cardType) {
      case 'feeding':
        _settings.putIfAbsent('type', () => 'bottle');
        _settings.putIfAbsent('amount_ml', () => 120);
        _settings.putIfAbsent('duration_minutes', () => 15);
        _settings.putIfAbsent('side', () => 'both');
        break;
      case 'sleep':
        _settings.putIfAbsent('duration_minutes', () => 120);
        _settings.putIfAbsent('quality', () => 'good');
        _settings.putIfAbsent('location', () => 'bedroom');
        break;
      case 'diaper':
        _settings.putIfAbsent('type', () => 'wet');
        _settings.putIfAbsent('color', () => 'yellow');
        _settings.putIfAbsent('consistency', () => 'normal');
        break;
      case 'solid_food':
        _settings.putIfAbsent('food_name', () => '미음');
        _settings.putIfAbsent('amount_grams', () => 50);
        _settings.putIfAbsent('allergic_reaction', () => 'none');
        break;
      case 'medication':
        _settings.putIfAbsent('medication_name', () => '해열제');
        _settings.putIfAbsent('dosage', () => '2.5');
        _settings.putIfAbsent('unit', () => 'ml');
        _settings.putIfAbsent('route', () => 'oral');
        break;
      case 'milk_pumping':
        _settings.putIfAbsent('amount_ml', () => 100);
        _settings.putIfAbsent('duration_minutes', () => 20);
        _settings.putIfAbsent('side', () => 'both');
        _settings.putIfAbsent('storage_location', () => 'refrigerator');
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.cardColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCardIcon(widget.cardType),
                      color: widget.cardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getLocalizedCardName(context)} ${l10n.defaultValueSettings}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.setDefaultValuesForQuickRecording,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // 설정 내용
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildSettingsContent(theme),
              ),
            ),
            
            // 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.cardColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 카드 타입별 설정 내용 빌드
  Widget _buildSettingsContent(ThemeData theme) {
    switch (widget.cardType) {
      case 'feeding':
        return _buildFeedingSettings(theme);
      case 'sleep':
        return _buildSleepSettings(theme);
      case 'diaper':
        return _buildDiaperSettings(theme);
      case 'solid_food':
        return _buildSolidFoodSettings(theme);
      case 'medication':
        return _buildMedicationSettings(theme);
      case 'milk_pumping':
        return _buildMilkPumpingSettings(theme);
      default:
        return const SizedBox();
    }
  }
  
  /// 수유 설정
  Widget _buildFeedingSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          theme: theme,
          label: l10n.feedingType,
          value: _settings['type'],
          items: [
            ('breast', l10n.breastMilk),
            ('bottle', l10n.bottle),
            ('formula', l10n.formulaMilk),
            ('solid', l10n.solidFoodFeeding),
          ],
          onChanged: (value) => setState(() => _settings['type'] = value),
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          theme: theme,
          label: l10n.feedingAmountMl,
          value: _settings['amount_ml'],
          onChanged: (value) => setState(() => _settings['amount_ml'] = value),
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          theme: theme,
          label: l10n.feedingTimeMinutes,
          value: _settings['duration_minutes'],
          onChanged: (value) => setState(() => _settings['duration_minutes'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.feedingPosition,
          value: _settings['side'],
          items: [
            ('left', l10n.left),
            ('right', l10n.right),
            ('both', l10n.both),
          ],
          onChanged: (value) => setState(() => _settings['side'] = value),
        ),
      ],
    );
  }
  
  /// 수면 설정
  Widget _buildSleepSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberField(
          theme: theme,
          label: l10n.sleepTimeMinutes,
          value: _settings['duration_minutes'],
          onChanged: (value) => setState(() => _settings['duration_minutes'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.sleepQuality,
          value: _settings['quality'],
          items: [
            ('good', l10n.sleepQualityGood),
            ('fair', l10n.sleepQualityFair),
            ('poor', l10n.sleepQualityPoor),
          ],
          onChanged: (value) => setState(() => _settings['quality'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.sleepLocation,
          value: _settings['location'],
          items: [
            ('bedroom', l10n.bedroom),
            ('living_room', l10n.livingRoom),
            ('stroller', l10n.stroller),
            ('car', l10n.car),
            ('outdoors', l10n.outdoors),
            ('other', l10n.other),
          ],
          onChanged: (value) => setState(() => _settings['location'] = value),
        ),
      ],
    );
  }
  
  /// 기저귀 설정
  Widget _buildDiaperSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          theme: theme,
          label: AppLocalizations.of(context)!.diaperType,
          value: _settings['type'],
          items: [
            ('wet', AppLocalizations.of(context)!.urine),
            ('dirty', AppLocalizations.of(context)!.poop),
            ('both', AppLocalizations.of(context)!.urinePoop),
          ],
          onChanged: (value) => setState(() => _settings['type'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.stoolColorWhenDirty,
          value: _settings['color'],
          items: [
            ('yellow', l10n.diaperColorYellow),
            ('brown', l10n.diaperColorBrown),
            ('green', l10n.diaperColorGreenish),
            ('orange', l10n.diaperColorOrange),
            ('black', l10n.diaperColorBlack),
            ('white', l10n.diaperColorWhite),
          ],
          onChanged: (value) => setState(() => _settings['color'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.stoolConsistencyWhenDirty,
          value: _settings['consistency'],
          items: [
            ('loose', l10n.diaperConsistencyLooseAlt),
            ('normal', l10n.diaperConsistencyNormal),
            ('hard', l10n.diaperConsistencyHardAlt),
          ],
          onChanged: (value) => setState(() => _settings['consistency'] = value),
        ),
      ],
    );
  }
  
  /// 이유식 설정
  Widget _buildSolidFoodSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          theme: theme,
          label: l10n.foodName,
          value: _settings['food_name'],
          onChanged: (value) => setState(() => _settings['food_name'] = value),
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          theme: theme,
          label: l10n.amountGrams,
          value: _settings['amount_grams'],
          onChanged: (value) => setState(() => _settings['amount_grams'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.allergicReaction,
          value: _settings['allergic_reaction'],
          items: [
            ('none', l10n.allergicReactionNone),
            ('mild', l10n.allergicReactionMild),
            ('moderate', l10n.allergicReactionModerate),
            ('severe', l10n.allergicReactionSevere),
          ],
          onChanged: (value) => setState(() => _settings['allergic_reaction'] = value),
        ),
      ],
    );
  }
  
  /// 투약 설정
  Widget _buildMedicationSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          theme: theme,
          label: l10n.medicationName,
          value: _settings['medication_name'],
          onChanged: (value) => setState(() => _settings['medication_name'] = value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          theme: theme,
          label: l10n.dosage,
          value: _settings['dosage'],
          onChanged: (value) => setState(() => _settings['dosage'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.unit,
          value: _settings['unit'],
          items: [
            ('ml', 'ml'),
            ('mg', 'mg'),
            ('tablets', l10n.tablets),
            ('drops', l10n.drops),
          ],
          onChanged: (value) => setState(() => _settings['unit'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.administrationRoute,
          value: _settings['route'],
          items: [
            ('oral', l10n.oral),
            ('topical', l10n.topical),
            ('inhaled', l10n.inhaled),
          ],
          onChanged: (value) => setState(() => _settings['route'] = value),
        ),
      ],
    );
  }
  
  /// 유축 설정
  Widget _buildMilkPumpingSettings(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberField(
          theme: theme,
          label: l10n.pumpingAmountMl,
          value: _settings['amount_ml'],
          onChanged: (value) => setState(() => _settings['amount_ml'] = value),
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          theme: theme,
          label: l10n.pumpingTimeMinutes,
          value: _settings['duration_minutes'],
          onChanged: (value) => setState(() => _settings['duration_minutes'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.pumpingPosition,
          value: _settings['side'],
          items: [
            ('left', l10n.left),
            ('right', l10n.right),
            ('both', l10n.both),
          ],
          onChanged: (value) => setState(() => _settings['side'] = value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          theme: theme,
          label: l10n.storageLocation,
          value: _settings['storage_location'],
          items: [
            ('refrigerator', l10n.refrigerator),
            ('freezer', l10n.freezer),
            ('room_temp', l10n.roomTemperature),
            ('fed_immediately', l10n.useImmediately),
          ],
          onChanged: (value) => setState(() => _settings['storage_location'] = value),
        ),
      ],
    );
  }
  
  /// 드롭다운 필드 빌드
  Widget _buildDropdownField({
    required ThemeData theme,
    required String label,
    required dynamic value,
    required List<(String, String)> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value?.toString(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item.$1,
                child: Text(item.$2),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
  
  /// 숫자 입력 필드 빌드
  Widget _buildNumberField({
    required ThemeData theme,
    required String label,
    required dynamic value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            initialValue: value.toString(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (newValue) {
              final intValue = int.tryParse(newValue) ?? 0;
              onChanged(intValue);
            },
          ),
        ),
      ],
    );
  }
  
  /// 텍스트 입력 필드 빌드
  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required dynamic value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            initialValue: value?.toString() ?? '',
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  /// 설정 저장
  void _saveSettings() {
    widget.onSave(_settings);
    Navigator.of(context).pop();
  }
  
  /// 카드 이름 로열라이제이션
  String _getLocalizedCardName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.cardName) {
      case '수유':
        return l10n.feeding;
      case '수면':
        return l10n.sleep;
      case '기저귀':
        return l10n.diaperChange;
      case '이유식':
        return l10n.solidFood;
      case '투약':
        return l10n.medication;
      case '유축':
        return l10n.milkPumping;
      default:
        return widget.cardName;
    }
  }
  
  /// 카드 타입별 아이콘 반환
  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'feeding':
        return Icons.local_drink;
      case 'sleep':
        return Icons.bedtime;
      case 'diaper':
        return Icons.child_care;
      case 'solid_food':
        return Icons.restaurant;
      case 'medication':
        return Icons.medical_services;
      case 'milk_pumping':
        return Icons.baby_changing_station;
      default:
        return Icons.settings;
    }
  }
}