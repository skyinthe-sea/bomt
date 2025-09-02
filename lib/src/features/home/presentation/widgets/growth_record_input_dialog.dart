import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

class GrowthRecordInputDialog extends StatefulWidget {
  final String? initialType; // 'weight' 또는 'height'
  final double? initialValue;
  final double? initialWeightValue; // 기존 체중 값
  final double? initialHeightValue; // 기존 키 값
  final Function(dynamic data, String? notes) onSave; // data는 String type + double value 또는 Map<String, double>

  const GrowthRecordInputDialog({
    super.key,
    this.initialType,
    this.initialValue,
    this.initialWeightValue,
    this.initialHeightValue,
    required this.onSave,
  });

  @override
  State<GrowthRecordInputDialog> createState() => _GrowthRecordInputDialogState();
}

class _GrowthRecordInputDialogState extends State<GrowthRecordInputDialog>
    with TickerProviderStateMixin {
  late String _selectedType;
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  bool _isLoading = false;
  
  // 탭 전환 시 입력값 유지를 위한 변수들
  String? _weightValue;
  String? _heightValue;
  String? _weightNotes;
  String? _heightNotes;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _selectedType = widget.initialType ?? 'weight';
    _valueController = TextEditingController();
    _notesController = TextEditingController();
    
    // 기존 체중/키 값들을 설정
    if (widget.initialWeightValue != null && widget.initialWeightValue! > 0) {
      _weightValue = widget.initialWeightValue!.toStringAsFixed(1);
    }
    if (widget.initialHeightValue != null && widget.initialHeightValue! > 0) {
      _heightValue = widget.initialHeightValue!.toStringAsFixed(1);
    }
    
    // 현재 선택된 타입의 값을 컨트롤러에 설정
    if (_selectedType == 'weight' && _weightValue != null) {
      _valueController.text = _weightValue!;
    } else if (_selectedType == 'height' && _heightValue != null) {
      _valueController.text = _heightValue!;
    }
    
    // 초기값이 있고 타입이 일치하며 0이 아닌 경우에만 설정 (기존 로직과 호환성 유지)
    if (widget.initialValue != null && 
        widget.initialType != null && 
        widget.initialValue! > 0) {
      _valueController.text = widget.initialValue!.toStringAsFixed(1);
      // 해당 타입의 값도 저장
      if (widget.initialType == 'weight') {
        _weightValue = widget.initialValue!.toStringAsFixed(1);
      } else {
        _heightValue = widget.initialValue!.toStringAsFixed(1);
      }
    }

    // 애니메이션 설정
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _typeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _selectedType == 'weight' ? l10n.weight : l10n.height;
  }

  String get _unit {
    return _selectedType == 'weight' ? 'kg' : 'cm';
  }

  Color get _primaryColor {
    return _selectedType == 'weight' 
        ? const Color(0xFF8B7EC8) // 소프트 퍼플
        : const Color(0xFF6B8BB5); // 소프트 블루
  }
  
  Color get _lightColor {
    return _selectedType == 'weight' 
        ? const Color(0xFFE8E4F6) // 연한 퍼플
        : const Color(0xFFE3E9F3); // 연한 블루
  }
  
  LinearGradient get _primaryGradient {
    return _selectedType == 'weight'
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9B8CE8), Color(0xFF7B6FD1)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A9BC8), Color(0xFF5B7FA8)],
          );
  }
  
  LinearGradient get _lightGradient {
    return _selectedType == 'weight'
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lightColor.withOpacity(0.4), _lightColor.withOpacity(0.2)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lightColor.withOpacity(0.4), _lightColor.withOpacity(0.2)],
          );
  }

  IconData get _typeIcon {
    return _selectedType == 'weight' ? Icons.monitor_weight : Icons.height;
  }

  void _saveCurrentValue() {
    final currentValue = _valueController.text.trim();
    final currentNotes = _notesController.text.trim();
    
    if (_selectedType == 'weight') {
      _weightValue = currentValue.isEmpty ? null : currentValue;
      _weightNotes = currentNotes.isEmpty ? null : currentNotes;
    } else {
      _heightValue = currentValue.isEmpty ? null : currentValue;
      _heightNotes = currentNotes.isEmpty ? null : currentNotes;
    }
  }

  void _loadCurrentValue() {
    if (_selectedType == 'weight') {
      _valueController.text = _weightValue ?? '';
      _notesController.text = _weightNotes ?? '';
    } else {
      _valueController.text = _heightValue ?? '';
      _notesController.text = _heightNotes ?? '';
    }
  }

  void _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 현재 입력값 저장
    _saveCurrentValue();
    
    // 입력된 값들을 체크
    Map<String, double> measurements = {};
    
    // 체중 검증 및 추가
    if (_weightValue != null && _weightValue!.isNotEmpty) {
      final weight = double.tryParse(_weightValue!);
      if (weight == null) {
        _showErrorSnackBar(l10n.weightInvalidNumber);
        return;
      }
      if (weight <= 0 || weight > 50) {
        _showErrorSnackBar(l10n.weightRangeError);
        return;
      }
      measurements['weight'] = weight;
    }
    
    // 키 검증 및 추가
    if (_heightValue != null && _heightValue!.isNotEmpty) {
      final height = double.tryParse(_heightValue!);
      if (height == null) {
        _showErrorSnackBar(l10n.heightInvalidNumber);
        return;
      }
      if (height <= 0 || height > 200) {
        _showErrorSnackBar(l10n.heightRangeError);
        return;
      }
      measurements['height'] = height;
    }
    
    // 입력된 값이 없으면 에러
    if (measurements.isEmpty) {
      _showErrorSnackBar(l10n.enterWeightOrHeight);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 여러 값이 입력된 경우 Map으로 전달, 하나만 입력된 경우 개별 전달
      if (measurements.length > 1) {
        // 동시 입력: 각각의 메모를 별도로 전달
        await widget.onSave(
          {
            ...measurements,
            'weightNotes': _weightNotes,
            'heightNotes': _heightNotes,
          },
          null, // 기존 notes 필드는 null로 전달
        );
      } else {
        // 단일 입력: 개별 전달 (기존 방식과 호환)
        final entry = measurements.entries.first;
        final typeNotes = entry.key == 'weight' ? _weightNotes : _heightNotes;
        
        await widget.onSave(
          {'type': entry.key, 'value': entry.value},
          typeNotes,
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving growth record: $e');
      _showErrorSnackBar(l10n.saveError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _lightGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _typeIcon,
                            color: _primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.growthInfoRecord,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedType == 'weight' 
                                    ? l10n.recordBabyCurrentWeight
                                    : l10n.recordBabyCurrentHeight,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 타입 선택
                    _buildSectionTitle(l10n.measurementItems),
                    const SizedBox(height: 12),
                    _buildTypeSelector(context),
                    
                    const SizedBox(height: 24),
                    
                    // 값 입력
                    _buildSectionTitle('${_typeLabel(context)} ($_unit)'),
                    const SizedBox(height: 12),
                    _buildValueField(context),
                    
                    const SizedBox(height: 24),
                    
                    // 메모 입력
                    _buildSectionTitle(l10n.memoOptional),
                    const SizedBox(height: 12),
                    _buildNotesField(context),
                    
                    const SizedBox(height: 32),
                    
                    // 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleSave,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          l10n.save,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      {
        'value': 'weight', 
        'label': l10n.weight, 
        'icon': Icons.monitor_weight, 
        'color': const Color(0xFF8B7EC8),
        'lightColor': const Color(0xFFE8E4F6),
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B8CE8), Color(0xFF7B6FD1)],
        ),
        'lightGradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8E4F6), Color(0xFFDDD6F0)],
        )
      },
      {
        'value': 'height', 
        'label': l10n.height, 
        'icon': Icons.height, 
        'color': const Color(0xFF6B8BB5),
        'lightColor': const Color(0xFFE3E9F3),
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A9BC8), Color(0xFF5B7FA8)],
        ),
        'lightGradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3E9F3), Color(0xFFD6E2ED)],
        )
      },
    ];

    return Row(
      children: types.map((type) {
        final isSelected = _selectedType == type['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                // 현재 입력값을 저장
                _saveCurrentValue();
                
                // 타입 변경
                _selectedType = type['value'] as String;
                
                // 새 타입의 기존 값을 불러오기
                _loadCurrentValue();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? (type['lightGradient'] as LinearGradient)
                    : LinearGradient(
                        colors: [Theme.of(context).colorScheme.surfaceVariant, Theme.of(context).colorScheme.surfaceVariant],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (type['color'] as Color)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: (type['color'] as Color).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Column(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    size: 24,
                    color: isSelected
                        ? (type['color'] as Color)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type['label'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (type['color'] as Color)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValueField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _valueController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          // 소수점 한자리까지만 허용
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue;
            
            final parts = newValue.text.split('.');
            if (parts.length > 2) return oldValue; // 소수점이 2개 이상이면 이전 값 유지
            
            if (parts.length == 2 && parts[1].length > 1) {
              // 소수점 이하가 2자리 이상이면 1자리로 자르기
              final trimmed = '${parts[0]}.${parts[1].substring(0, 1)}';
              return TextEditingValue(
                text: trimmed,
                selection: TextSelection.collapsed(offset: trimmed.length),
              );
            }
            
            return newValue;
          }),
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: _selectedType == 'weight' ? l10n.enterWeight : l10n.enterHeight,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          suffixText: _unit,
          suffixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _primaryColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            _typeIcon,
            color: _primaryColor,
          ),
        ),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: _selectedType == 'weight' 
              ? l10n.recordSpecialNotesWeight
              : l10n.recordSpecialNotesHeight,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

}