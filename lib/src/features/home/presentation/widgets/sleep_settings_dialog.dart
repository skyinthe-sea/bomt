import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SleepSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> currentDefaults;
  final Function(Map<String, dynamic>) onSave;

  const SleepSettingsDialog({
    super.key,
    required this.currentDefaults,
    required this.onSave,
  });

  @override
  State<SleepSettingsDialog> createState() => _SleepSettingsDialogState();
}

class _SleepSettingsDialogState extends State<SleepSettingsDialog>
    with TickerProviderStateMixin {
  late int _durationMinutes;
  late String _selectedQuality;
  late String _selectedLocation;

  late TextEditingController _durationController;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 현재 기본값으로 초기화
    _durationMinutes = widget.currentDefaults['durationMinutes'] ?? 120;
    _selectedQuality = widget.currentDefaults['quality'] ?? 'good';
    _selectedLocation = widget.currentDefaults['location'] ?? '침실';

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
    _durationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // 입력값 검증
    final duration = int.tryParse(_durationController.text) ?? _durationMinutes;

    if (duration <= 0 || duration > 720) {
      _showErrorSnackBar('수면 시간은 1~720분(12시간) 사이로 입력해주세요');
      return;
    }

    final settings = {
      'durationMinutes': duration,
      'quality': _selectedQuality,
      'location': _selectedLocation,
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
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bedtime,
                            color: Colors.purple[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '수면 기본 설정',
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
                    
                    // 수면 시간 설정
                    _buildSectionTitle('기본 수면 시간 (분)'),
                    const SizedBox(height: 12),
                    _buildDurationField(),
                    
                    const SizedBox(height: 24),
                    
                    // 수면 품질 설정
                    _buildSectionTitle('기본 수면 품질'),
                    const SizedBox(height: 12),
                    _buildQualitySelector(),
                    
                    const SizedBox(height: 24),
                    
                    // 수면 위치 설정
                    _buildSectionTitle('기본 수면 위치'),
                    const SizedBox(height: 12),
                    _buildLocationSelector(),
                    
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
                              backgroundColor: Colors.purple[600],
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
          hintText: '120',
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

  Widget _buildQualitySelector() {
    final qualities = [
      {'value': 'good', 'label': '좋음', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
      {'value': 'fair', 'label': '보통', 'icon': Icons.sentiment_neutral, 'color': Colors.orange},
      {'value': 'poor', 'label': '나쁨', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.red},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: qualities.map((quality) {
        final isSelected = _selectedQuality == quality['value'];
        final color = quality['color'] as Color;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedQuality = quality['value'] as String;
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
                  quality['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : color,
                ),
                const SizedBox(width: 8),
                Text(
                  quality['label'] as String,
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

  Widget _buildLocationSelector() {
    final locations = [
      {'value': '침실', 'icon': Icons.bed},
      {'value': '거실', 'icon': Icons.living},
      {'value': '유모차', 'icon': Icons.stroller},
      {'value': '차량', 'icon': Icons.car_rental},
      {'value': '야외', 'icon': Icons.park},
      {'value': '기타', 'icon': Icons.more_horiz},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: locations.map((location) {
        final isSelected = _selectedLocation == location['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLocation = location['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple[600]
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.purple[600]!
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  location['icon'] as IconData,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  location['value'] as String,
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