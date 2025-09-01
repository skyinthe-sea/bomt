import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';

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
  // 타입별 설정
  late Map<String, Map<String, String>> _typeSettings;
  String _selectedTab = 'dirty'; // 기본적으로 대변 탭을 보여줌 (소변은 설정할 게 없음)

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 타입별 기본값으로 초기화
    _typeSettings = {
      'wet': {
        'color': widget.currentDefaults['wet']?['color'] ?? '투명',
        'consistency': widget.currentDefaults['wet']?['consistency'] ?? '액체',
      },
      'dirty': {
        'color': widget.currentDefaults['dirty']?['color'] ?? '노란색',
        'consistency': widget.currentDefaults['dirty']?['consistency'] ?? '보통',
      },
      'both': {
        'color': widget.currentDefaults['both']?['color'] ?? '노란색',
        'consistency': widget.currentDefaults['both']?['consistency'] ?? '보통',
      },
    };

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
    widget.onSave(_typeSettings);
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
                constraints: const BoxConstraints(maxWidth: 450),
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
                                '기저귀 기본값 설정',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '빠른 기록을 위한 기본값을 설정하세요',
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
                    
                    // 타입별 설정 탭
                    _buildTypeTabs(),
                    
                    const SizedBox(height: 24),
                    
                    // 선택된 타입의 설정
                    _buildTypeSettings(),
                    
                    const SizedBox(height: 24),
                    
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

  Widget _buildTypeTabs() {
    final types = [
      {'value': 'dirty', 'label': AppLocalizations.of(context)!.poop, 'icon': Icons.eco, 'color': Colors.brown},
      {'value': 'both', 'label': AppLocalizations.of(context)!.urinePoop, 'icon': Icons.child_care, 'color': Colors.purple},
    ];

    return Row(
      children: types.map((type) {
        final isSelected = _selectedTab == type['value'];
        final color = type['color'] as Color;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = type['value'] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 색상 설정
        _buildSectionTitle(AppLocalizations.of(context)!.colorWhenPoop),
        const SizedBox(height: 12),
        _buildColorSelector(),
        
        const SizedBox(height: 24),
        
        // 농도 설정
        _buildSectionTitle('농도/상태'),
        const SizedBox(height: 12),
        _buildConsistencySelector(),
      ],
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
        final isSelected = _typeSettings[_selectedTab]!['color'] == colorItem['value'];
        final color = colorItem['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _typeSettings[_selectedTab]!['color'] = colorItem['value'] as String;
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
        final isSelected = _typeSettings[_selectedTab]!['consistency'] == consistency['value'];
        final color = consistency['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _typeSettings[_selectedTab]!['consistency'] = consistency['value'] as String;
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