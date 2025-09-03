import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

class FeedingSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> currentDefaults;
  final Function(Map<String, dynamic>) onSave;

  const FeedingSettingsDialog({
    super.key,
    required this.currentDefaults,
    required this.onSave,
  });

  @override
  State<FeedingSettingsDialog> createState() => _FeedingSettingsDialogState();
}

class _FeedingSettingsDialogState extends State<FeedingSettingsDialog>
    with TickerProviderStateMixin {
  late String _selectedType;
  late int _amountMl;
  late int _durationMinutes;
  late String _selectedSide;

  late TextEditingController _amountController;
  late TextEditingController _durationController;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 현재 기본값으로 초기화
    _selectedType = widget.currentDefaults['type'] ?? 'bottle';
    _amountMl = widget.currentDefaults['amountMl'] ?? 120;
    _durationMinutes = widget.currentDefaults['durationMinutes'] ?? 15;
    _selectedSide = widget.currentDefaults['side'] ?? 'both';

    _amountController = TextEditingController(text: _amountMl.toString());
    _durationController = TextEditingController(text: _durationMinutes.toString());

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
    _amountController.dispose();
    _durationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // 입력값 검증
    final amount = int.tryParse(_amountController.text) ?? _amountMl;
    final duration = int.tryParse(_durationController.text) ?? _durationMinutes;

    if (amount <= 0 || amount > 1000) {
      _showErrorSnackBar(AppLocalizations.of(context)!.feedingAmountValidationError);
      return;
    }

    if (duration <= 0 || duration > 180) {
      _showErrorSnackBar(AppLocalizations.of(context)!.feedingDurationValidationError);
      return;
    }

    final settings = {
      'type': _selectedType,
      'amountMl': amount,
      'durationMinutes': duration,
      'side': _selectedSide,
    };

    widget.onSave(settings);
    Navigator.of(context).pop();
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
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '수유 기본 설정',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '버튼을 눌렀을 때 기록될 기본값을 설정해주세요',
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
                    
                    // 수유 타입 선택
                    _buildSectionTitle('수유 타입'),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // 수유량 설정
                    _buildSectionTitle('수유량 (ml)'),
                    const SizedBox(height: 12),
                    _buildAmountField(),
                    
                    const SizedBox(height: 24),
                    
                    // 수유 시간 설정
                    _buildSectionTitle('수유 시간 (분)'),
                    const SizedBox(height: 12),
                    _buildDurationField(),
                    
                    // 모유 수유인 경우 사이드 선택
                    if (_selectedType == 'breast') ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('수유 위치'),
                      const SizedBox(height: 12),
                      _buildSideSelector(),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                            onPressed: _handleSave,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
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
      {'value': 'breast', 'label': '모유', 'icon': Icons.child_care},
      {'value': 'bottle', 'label': '젖병', 'icon': Icons.local_drink},
      {'value': 'formula', 'label': '분유', 'icon': Icons.science},
      {'value': 'solid', 'label': '이유식', 'icon': Icons.restaurant},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue[600]
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.blue[600]!
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: '120',
          suffixText: 'ml',
          suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onChanged: (value) {
          final amount = int.tryParse(value);
          if (amount != null) {
            _amountMl = amount;
          }
        },
      ),
    );
  }

  Widget _buildDurationField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: '15',
          suffixText: '분',
          suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onChanged: (value) {
          final duration = int.tryParse(value);
          if (duration != null) {
            _durationMinutes = duration;
          }
        },
      ),
    );
  }

  Widget _buildSideSelector() {
    final sides = [
      {'value': 'left', 'label': '왼쪽'},
      {'value': 'right', 'label': '오른쪽'},
      {'value': 'both', 'label': '양쪽'},
    ];

    return Wrap(
      spacing: 8,
      children: sides.map((side) {
        final isSelected = _selectedSide == side['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSide = side['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue[600]
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.blue[600]!
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              side['label'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}