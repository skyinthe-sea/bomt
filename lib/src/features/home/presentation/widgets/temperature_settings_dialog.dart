import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TemperatureSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> currentDefaults;
  final Function(Map<String, dynamic>) onSave;

  const TemperatureSettingsDialog({
    super.key,
    required this.currentDefaults,
    required this.onSave,
  });

  @override
  State<TemperatureSettingsDialog> createState() => _TemperatureSettingsDialogState();
}

class _TemperatureSettingsDialogState extends State<TemperatureSettingsDialog>
    with TickerProviderStateMixin {
  late double _defaultTemperature;
  late String _temperatureUnit;
  late String _measurementLocation;

  late TextEditingController _temperatureController;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 현재 기본값으로 초기화
    _defaultTemperature = widget.currentDefaults['defaultTemperature']?.toDouble() ?? 36.5;
    _temperatureUnit = widget.currentDefaults['temperatureUnit'] ?? '°C';
    _measurementLocation = widget.currentDefaults['measurementLocation'] ?? '겨드랑이';

    _temperatureController = TextEditingController(text: _defaultTemperature.toStringAsFixed(1));

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
    _temperatureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // 입력값 검증
    final temperature = double.tryParse(_temperatureController.text) ?? _defaultTemperature;

    if (temperature < 30.0 || temperature > 45.0) {
      _showErrorSnackBar('체온은 30.0°C~45.0°C 사이로 입력해주세요');
      return;
    }

    final settings = {
      'defaultTemperature': temperature,
      'temperatureUnit': _temperatureUnit,
      'measurementLocation': _measurementLocation,
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
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.device_thermostat,
                            color: Colors.red[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '체온 기본 설정',
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
                    
                    // 기본 체온 설정
                    _buildSectionTitle('기본 체온'),
                    const SizedBox(height: 12),
                    _buildTemperatureField(),
                    
                    const SizedBox(height: 24),
                    
                    // 측정 위치 설정
                    _buildSectionTitle('측정 위치'),
                    const SizedBox(height: 12),
                    _buildLocationSelector(),
                    
                    const SizedBox(height: 32),
                    
                    // 온도 범위 안내
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, 
                                color: Colors.blue[700], 
                                size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '체온 기준',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 정상: 36.0~37.5°C\n• 미열: 37.6~38.5°C\n• 고열: 38.6°C 이상',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
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
                              backgroundColor: Colors.red[600],
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

  Widget _buildTemperatureField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _temperatureController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: '36.5',
          suffixText: '°C',
          suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onChanged: (value) {
          final temperature = double.tryParse(value);
          if (temperature != null) {
            _defaultTemperature = temperature;
          }
        },
      ),
    );
  }

  Widget _buildLocationSelector() {
    final locations = [
      {'value': '겨드랑이', 'icon': Icons.accessibility},
      {'value': '이마', 'icon': Icons.face},
      {'value': '귀', 'icon': Icons.hearing},
      {'value': '입', 'icon': Icons.emoji_emotions},
      {'value': '직장', 'icon': Icons.child_care},
      {'value': '기타', 'icon': Icons.more_horiz},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: locations.map((location) {
        final isSelected = _measurementLocation == location['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _measurementLocation = location['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.red[600]
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.red[600]!
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