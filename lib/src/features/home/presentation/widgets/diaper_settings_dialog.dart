import 'package:flutter/material.dart';

class DiaperSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> currentDefaults;
  final Function(Map<String, dynamic>) onSave;

  const DiaperSettingsDialog({
    super.key,
    required this.currentDefaults,
    required this.onSave,
  });

  @override
  State<DiaperSettingsDialog> createState() => _DiaperSettingsDialogState();
}

class _DiaperSettingsDialogState extends State<DiaperSettingsDialog>
    with TickerProviderStateMixin {
  late String _selectedType;
  late String _selectedColor;
  late String _selectedConsistency;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 현재 기본값으로 초기화
    _selectedType = widget.currentDefaults['type'] ?? 'wet';
    _selectedColor = widget.currentDefaults['color'] ?? '노란색';
    _selectedConsistency = widget.currentDefaults['consistency'] ?? '보통';

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
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final settings = {
      'type': _selectedType,
      'color': _selectedColor,
      'consistency': _selectedConsistency,
    };

    widget.onSave(settings);
    Navigator.of(context).pop();
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
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.child_care,
                            color: Colors.amber[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '기저귀 기본 설정',
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
                    
                    // 기저귀 타입 선택
                    _buildSectionTitle('기저귀 타입'),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // 색상 선택 (대변인 경우에만)
                    if (_selectedType == 'dirty' || _selectedType == 'both') ...[
                      _buildSectionTitle('색상'),
                      const SizedBox(height: 12),
                      _buildColorSelector(),
                      const SizedBox(height: 24),
                    ],
                    
                    // 농도 선택 (대변인 경우에만)
                    if (_selectedType == 'dirty' || _selectedType == 'both') ...[
                      _buildSectionTitle('농도/상태'),
                      const SizedBox(height: 12),
                      _buildConsistencySelector(),
                      const SizedBox(height: 24),
                    ],
                    
                    const SizedBox(height: 8),
                    
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
                              backgroundColor: Colors.amber[600],
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
      {'value': 'wet', 'label': '소변', 'icon': Icons.opacity, 'color': Colors.blue},
      {'value': 'dirty', 'label': '대변', 'icon': Icons.eco, 'color': Colors.brown},
      {'value': 'both', 'label': '소변+대변', 'icon': Icons.child_care, 'color': Colors.purple},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type['value'];
        final color = type['color'] as Color;
        
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
                  ? color
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
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
                      : color,
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

  Widget _buildColorSelector() {
    final colors = [
      {'value': '노란색', 'color': Colors.yellow[700]!},
      {'value': '갈색', 'color': Colors.brown},
      {'value': '녹색', 'color': Colors.green},
      {'value': '주황색', 'color': Colors.orange},
      {'value': '검은색', 'color': Colors.black87},
      {'value': '하얀색', 'color': Colors.grey[300]!},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorItem) {
        final isSelected = _selectedColor == colorItem['value'];
        final color = colorItem['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorItem['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  colorItem['value'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (color == Colors.yellow[700] || color == Colors.grey[300] 
                            ? Colors.black87 
                            : Colors.white)
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

  Widget _buildConsistencySelector() {
    final consistencies = [
      {'value': '묽음', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'value': '보통', 'icon': Icons.circle, 'color': Colors.amber[600]!},
      {'value': '딱딱함', 'icon': Icons.square, 'color': Colors.brown},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: consistencies.map((consistency) {
        final isSelected = _selectedConsistency == consistency['value'];
        final color = consistency['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedConsistency = consistency['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  consistency['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : color,
                ),
                const SizedBox(width: 8),
                Text(
                  consistency['value'] as String,
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
}