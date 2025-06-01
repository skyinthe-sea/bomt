import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String get _typeLabel {
    return _selectedType == 'weight' ? '체중' : '키';
  }

  String get _unit {
    return _selectedType == 'weight' ? 'kg' : 'cm';
  }

  Color get _primaryColor {
    return _selectedType == 'weight' 
        ? const Color(0xFFAB47BC) // 라벤더 파스텔 (더 진한 버전)
        : const Color(0xFF66BB6A); // 민트 파스텔 (더 진한 버전)
  }
  
  Color get _lightColor {
    return _selectedType == 'weight' 
        ? const Color(0xFFE1BEE7) // 연한 라벤더 파스텔 
        : const Color(0xFFC8E6C9); // 연한 민트 파스텔
  }

  IconData get _typeIcon {
    return _selectedType == 'weight' ? Icons.monitor_weight : Icons.height;
  }

  void _saveCurrentValue() {
    final currentValue = _valueController.text.trim();
    if (_selectedType == 'weight') {
      _weightValue = currentValue.isEmpty ? null : currentValue;
    } else {
      _heightValue = currentValue.isEmpty ? null : currentValue;
    }
  }

  void _loadCurrentValue() {
    if (_selectedType == 'weight') {
      _valueController.text = _weightValue ?? '';
    } else {
      _valueController.text = _heightValue ?? '';
    }
  }

  void _handleSave() async {
    // 현재 입력값 저장
    _saveCurrentValue();
    
    // 입력된 값들을 체크
    Map<String, double> measurements = {};
    
    // 체중 검증 및 추가
    if (_weightValue != null && _weightValue!.isNotEmpty) {
      final weight = double.tryParse(_weightValue!);
      if (weight == null) {
        _showErrorSnackBar('체중은 올바른 숫자를 입력해주세요');
        return;
      }
      if (weight <= 0 || weight > 50) {
        _showErrorSnackBar('체중은 0.1~50kg 사이로 입력해주세요');
        return;
      }
      measurements['weight'] = weight;
    }
    
    // 키 검증 및 추가
    if (_heightValue != null && _heightValue!.isNotEmpty) {
      final height = double.tryParse(_heightValue!);
      if (height == null) {
        _showErrorSnackBar('키는 올바른 숫자를 입력해주세요');
        return;
      }
      if (height <= 0 || height > 200) {
        _showErrorSnackBar('키는 1~200cm 사이로 입력해주세요');
        return;
      }
      measurements['height'] = height;
    }
    
    // 입력된 값이 없으면 에러
    if (measurements.isEmpty) {
      _showErrorSnackBar('체중 또는 키를 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notes = _notesController.text.trim();
      
      // 여러 값이 입력된 경우 Map으로 전달, 하나만 입력된 경우 개별 전달
      if (measurements.length > 1) {
        // 동시 입력: Map으로 전달
        await widget.onSave(
          measurements,
          notes.isEmpty ? null : notes,
        );
      } else {
        // 단일 입력: 개별 전달 (기존 방식과 호환)
        final entry = measurements.entries.first;
        await widget.onSave(
          {'type': entry.key, 'value': entry.value},
          notes.isEmpty ? null : notes,
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving growth record: $e');
      _showErrorSnackBar('저장 중 오류가 발생했습니다');
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
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _lightColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
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
                                '성장 정보 기록',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '아기의 현재 ${_typeLabel}을 기록해주세요',
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
                    _buildSectionTitle('측정 항목'),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // 값 입력
                    _buildSectionTitle('$_typeLabel ($_unit)'),
                    const SizedBox(height: 12),
                    _buildValueField(),
                    
                    const SizedBox(height: 24),
                    
                    // 메모 입력
                    _buildSectionTitle('메모 (선택사항)'),
                    const SizedBox(height: 12),
                    _buildNotesField(),
                    
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
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    '저장',
                                    style: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildTypeSelector() {
    final types = [
      {
        'value': 'weight', 
        'label': '체중', 
        'icon': Icons.monitor_weight, 
        'color': const Color(0xFFAB47BC),
        'lightColor': const Color(0xFFE1BEE7)
      },
      {
        'value': 'height', 
        'label': '키', 
        'icon': Icons.height, 
        'color': const Color(0xFF66BB6A),
        'lightColor': const Color(0xFFC8E6C9)
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
                color: isSelected
                    ? (type['lightColor'] as Color)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (type['color'] as Color)
                      : Colors.transparent,
                  width: 2,
                ),
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

  Widget _buildValueField() {
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
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: _selectedType == 'weight' ? '체중 입력' : '키 입력',
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

  Widget _buildNotesField() {
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
          hintText: '측정 상황이나 특이사항을 기록해주세요 (선택사항)',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

}