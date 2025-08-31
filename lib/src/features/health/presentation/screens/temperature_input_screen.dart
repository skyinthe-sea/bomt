import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/baby.dart';
import '../../../../domain/models/temperature_guideline.dart';
import '../../../../services/health/health_service.dart';
import '../../../../services/health/temperature_feedback_service.dart';
import '../../../../services/auth/supabase_auth_service.dart';
import '../widgets/temperature_feedback_dialog.dart';
import 'temperature_chart_screen.dart';

// 온도 입력 포맷터 클래스
class TemperatureInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 빈 문자열인 경우 허용
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 정규식: 34-42 범위의 숫자, 소수점 첫 번째 자리까지만 허용
    final regex = RegExp(r'^(3[4-9]|4[0-2])(\.[0-9])?$');
    
    // 입력이 유효한 패턴인지 확인
    if (regex.hasMatch(newValue.text)) {
      final value = double.tryParse(newValue.text);
      if (value != null && value >= 34.0 && value <= 42.0) {
        return newValue;
      }
    }
    
    // 유효하지 않은 경우 이전 값 유지
    return oldValue;
  }
}

// 아기 연령별 체온 기준 클래스 (WHO 및 소아과 가이드라인 기준)
class TemperatureStandards {
  static Map<String, dynamic> getStandardsForAge(int ageInDays) {
    if (ageInDays <= 365) {
      // 1세 이하 (신생아/영아) - WHO 기준
      return {
        'normalMin': 36.5,  // WHO 정상 체온 하한
        'normalMax': 37.5,  // WHO 정상 체온 상한
        'mildFever': 37.5,  // 미열 시작점
        'fever': 38.0,      // 발열 시작점
        'highFever': 39.0,  // 고열 시작점
        'hypothermia': 36.5, // 저체온 기준 (이 값 미만)
        'ageGroup': '신생아/영아',
        'description': '1세 이하',
      };
    } else if (ageInDays <= 1095) {
      // 1-3세
      return {
        'normalMin': 36.5,
        'normalMax': 37.5,
        'mildFever': 37.5,
        'fever': 38.0,
        'highFever': 39.0,
        'hypothermia': 36.5,
        'ageGroup': '유아',
        'description': '1-3세',
      };
    } else if (ageInDays <= 1825) {
      // 3-5세
      return {
        'normalMin': 36.5,
        'normalMax': 37.5,
        'mildFever': 37.5,
        'fever': 38.0,
        'highFever': 39.0,
        'hypothermia': 36.5,
        'ageGroup': '유아',
        'description': '3-5세',
      };
    } else {
      // 5세 이상
      return {
        'normalMin': 36.5,
        'normalMax': 37.5,
        'mildFever': 37.5,
        'fever': 38.0,
        'highFever': 39.0,
        'hypothermia': 36.5,
        'ageGroup': '소아',
        'description': '5세 이상',
      };
    }
  }
}

class TemperatureInputScreen extends StatefulWidget {
  final Baby baby;

  const TemperatureInputScreen({
    super.key,
    required this.baby,
  });

  @override
  State<TemperatureInputScreen> createState() => _TemperatureInputScreenState();
}

class _TemperatureInputScreenState extends State<TemperatureInputScreen>
    with TickerProviderStateMixin {
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TemperatureMeasurementMethod _selectedMethod = TemperatureMeasurementMethod.axillary;
  bool _isLoading = false;
  double _sliderValue = 36.5;
  Map<String, dynamic> _temperatureStandards = {};
  String _currentTemperatureStatus = 'normal';
  String _previousTemperatureStatus = 'normal';
  
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late AnimationController _statusChangeController;
  late AnimationController _colorTransitionController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _statusChangeAnimation;
  late Animation<double> _colorTransitionAnimation;

  @override
  void initState() {
    super.initState();
    
    // 아기 연령에 따른 체온 기준 설정
    final ageInDays = DateTime.now().difference(widget.baby.birthDate).inDays;
    _temperatureStandards = TemperatureStandards.getStandardsForAge(ageInDays);
    
    // 연령에 맞는 기본 체온값 설정
    _sliderValue = (_temperatureStandards['normalMin'] + _temperatureStandards['normalMax']) / 2;
    
    // 애니메이션 컨트롤러 초기화
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _statusChangeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _colorTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _statusChangeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statusChangeController,
      curve: Curves.elasticOut,
    ));
    
    _colorTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorTransitionController,
      curve: Curves.easeInOut,
    ));
    
    // 초기값 설정
    _temperatureController.text = _sliderValue.toStringAsFixed(1);
    _currentTemperatureStatus = _getTemperatureStatus(_sliderValue);
    _previousTemperatureStatus = _currentTemperatureStatus;
    
    // 텍스트 컨트롤러 리스너 추가
    _temperatureController.addListener(_onTemperatureChanged);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    _statusChangeController.dispose();
    _colorTransitionController.dispose();
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _onTemperatureChanged() {
    final text = _temperatureController.text;
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null && value >= 34.0 && value <= 42.0) {
        final newStatus = _getTemperatureStatus(value);
        final statusChanged = newStatus != _currentTemperatureStatus;
        
        setState(() {
          _sliderValue = value;
          _previousTemperatureStatus = _currentTemperatureStatus;
          _currentTemperatureStatus = newStatus;
        });
        
        // 체온 상태 변화 시 애니메이션 효과
        if (statusChanged) {
          _statusChangeController.forward().then((_) {
            _statusChangeController.reset();
          });
          _colorTransitionController.forward().then((_) {
            _colorTransitionController.reset();
          });
          HapticFeedback.mediumImpact();
        }
        
        // 비정상 온도 시 지속적인 글로우 효과
        final normalMin = _temperatureStandards['normalMin'] ?? 35.0;
        final normalMax = _temperatureStandards['normalMax'] ?? 37.2;
        if (value < normalMin || value > normalMax) {
          _glowController.repeat(reverse: true);
        } else {
          _glowController.stop();
          _glowController.reset();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.temperatureRecord),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아기 정보 카드
              _buildBabyInfoCard(theme, l10n),
              
              const SizedBox(height: 24),
              
              // 체온 입력 섹션
              _buildTemperatureInputSection(theme, l10n),
              
              const SizedBox(height: 24),
              
              // 측정 방법 선택
              _buildMeasurementMethodSection(theme, l10n),
              
              const SizedBox(height: 24),
              
              // 메모 입력
              _buildNotesSection(theme, l10n),
              
              const SizedBox(height: 32),
              
              // 저장 버튼
              _buildSaveButton(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBabyInfoCard(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TemperatureChartScreen(baby: widget.baby),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아기 아바타
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.thermostat,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // 아기 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.babyTemperatureRecord(widget.baby.name),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.baby.ageInMonthsAndDays,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 그래프 아이콘 힌트
            Icon(
              Icons.bar_chart_rounded,
              color: theme.colorScheme.primary.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureInputSection(ThemeData theme, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getTemperatureColor(_sliderValue).withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 20 + (10 * _glowAnimation.value),
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _getTemperatureColor(_sliderValue).withOpacity(0.3),
                width: 1 + _glowAnimation.value,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더와 온도 상태 표시
                Row(
                  children: [
                    Icon(
                      Icons.thermostat_rounded,
                      color: _getTemperatureColor(_sliderValue),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.temperature,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTemperatureColor(_sliderValue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getLocalizedTemperatureStatus(_getTemperatureStatus(_sliderValue)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTemperatureColor(_sliderValue),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 큰 온도 표시
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sliderValue.toStringAsFixed(1),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getTemperatureColor(_sliderValue),
                              fontSize: 72,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              '°C',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getTemperatureColor(_sliderValue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 정상 범위 표시 (연령별)
                      Text(
                        l10n.normalRangeForAgeGroup(
                          _temperatureStandards['ageGroup'] ?? '',
                          (_temperatureStandards['normalMin'] ?? 35.0).toStringAsFixed(1),
                          (_temperatureStandards['normalMax'] ?? 37.2).toStringAsFixed(1),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 텍스트 입력 필드
                TextFormField(
                  controller: _temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    TemperatureInputFormatter(),
                  ],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTemperatureColor(_sliderValue),
                  ),
                  decoration: InputDecoration(
                    hintText: '36.5',
                    hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _getTemperatureColor(_sliderValue).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _getTemperatureColor(_sliderValue),
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _getTemperatureColor(_sliderValue).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: _getTemperatureColor(_sliderValue).withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterTemperature;
                    }
                    final temp = double.tryParse(value);
                    if (temp == null) {
                      return l10n.enterValidNumber;
                    }
                    if (temp < 34.0 || temp > 42.0) {
                      return l10n.temperatureRangeValidation;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final temp = double.tryParse(value);
                    if (temp != null && temp >= 34.0 && temp <= 42.0) {
                      setState(() {
                        _sliderValue = temp;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 슬라이더
                Column(
                  children: [
                    Text(
                      l10n.adjustWithSlider,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getTemperatureColor(_sliderValue),
                        inactiveTrackColor: _getTemperatureColor(_sliderValue).withOpacity(0.3),
                        thumbColor: _getTemperatureColor(_sliderValue),
                        overlayColor: _getTemperatureColor(_sliderValue).withOpacity(0.2),
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _sliderValue,
                        min: 34.0,
                        max: 42.0,
                        divisions: 80, // 0.1도 단위
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = double.parse(value.toStringAsFixed(1));
                            _temperatureController.text = _sliderValue.toStringAsFixed(1);
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '34.0°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '42.0°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
  
  
  Color _getTemperatureColor(double temperature) {
    final normalMin = _temperatureStandards['normalMin'] ?? 36.5;
    final normalMax = _temperatureStandards['normalMax'] ?? 37.5;
    final mildFever = _temperatureStandards['mildFever'] ?? 37.5;
    final fever = _temperatureStandards['fever'] ?? 38.0;
    
    if (temperature < normalMin) {
      return Colors.cyan;  // 저체온 (청록색으로 구분)
    } else if (temperature >= normalMin && temperature <= normalMax) {
      return Colors.green; // 정상
    } else if (temperature > normalMax && temperature < fever) {
      return Colors.orange; // 미열
    } else {
      return Colors.red; // 고열
    }
  }
  
  String _getTemperatureStatus(double temperature) {
    final normalMin = _temperatureStandards['normalMin'] ?? 36.5;
    final normalMax = _temperatureStandards['normalMax'] ?? 37.5;
    final mildFever = _temperatureStandards['mildFever'] ?? 37.5;
    final fever = _temperatureStandards['fever'] ?? 38.0;
    
    if (temperature < normalMin) {
      return 'hypothermia';
    } else if (temperature >= normalMin && temperature <= normalMax) {
      return 'normal';
    } else if (temperature > normalMax && temperature < fever) {
      return 'lowFever';
    } else {
      return 'highFever';
    }
  }
  
  String _getLocalizedTemperatureStatus(String statusKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (statusKey) {
      case 'hypothermia':
        return l10n.hypothermia;
      case 'normal':
        return l10n.normal;
      case 'lowFever':
        return l10n.lowFever;
      case 'highFever':
        return l10n.highFever;
      default:
        return l10n.normal;
    }
  }

  Widget _buildMeasurementMethodSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.measurementMethod,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TemperatureMeasurementMethod.values.map((method) {
              final isSelected = _selectedMethod == method;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethod = method;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMethodIcon(method),
                        size: 18,
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getMethodName(method),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notesOptional,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.recordSymptomsHint,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTemperature,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.saveTemperatureRecord,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  IconData _getMethodIcon(TemperatureMeasurementMethod method) {
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        return Icons.thermostat;
      case TemperatureMeasurementMethod.oral:
        return Icons.face;
      case TemperatureMeasurementMethod.axillary:
        return Icons.accessibility_new;
      case TemperatureMeasurementMethod.ear:
        return Icons.hearing;
      case TemperatureMeasurementMethod.forehead:
        return Icons.face_retouching_natural;
    }
  }

  String _getMethodName(TemperatureMeasurementMethod method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        return l10n.analMethod;
      case TemperatureMeasurementMethod.oral:
        return l10n.oralMethod;
      case TemperatureMeasurementMethod.axillary:
        return l10n.armpit;
      case TemperatureMeasurementMethod.ear:
        return l10n.ear;
      case TemperatureMeasurementMethod.forehead:
        return l10n.forehead;
    }
  }

  Future<void> _saveTemperature() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: 체온 기록 저장 시작');
      final temperature = double.parse(_temperatureController.text);
      print('DEBUG: 파싱된 온도: $temperature');
      
      // 현재 사용자 ID 가져오기 (Supabase 인증 시스템 사용)
      print('DEBUG: Supabase 사용자 인증 확인 시작');
      final supabaseAuthService = SupabaseAuthService.instance;
      final currentUser = supabaseAuthService.currentUser;
      print('DEBUG: Supabase 현재 사용자: ${currentUser?.id}');
      print('DEBUG: 사용자 이메일: ${currentUser?.email}');
      print('DEBUG: 로그인 상태: ${supabaseAuthService.isLoggedIn}');
      
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다. 다시 로그인해주세요.');
      }
      
      final userId = currentUser.id;
      
      // 체온 기록 저장
      print('DEBUG: HealthService 호출 시작');
      final healthRecord = await HealthService.instance.addHealthRecord(
        babyId: widget.baby.id,
        userId: userId,
        type: 'temperature',
        temperature: temperature,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        recordedAt: DateTime.now(),
      );
      print('DEBUG: 체온 기록 저장 완료: $healthRecord');
      
      if (healthRecord != null && mounted) {
        // 체온 피드백 생성
        final feedback = TemperatureFeedbackService.instance.generateFeedback(
          widget.baby,
          temperature,
          _selectedMethod,
        );
        
        // 피드백 다이얼로그 표시
        await showDialog(
          context: context,
          builder: (context) => TemperatureFeedbackDialog(
            temperature: temperature,
            feedback: feedback,
          ),
        );
        
        if (mounted) {
          Navigator.of(context).pop(true); // 성공 시 true 반환
        }
      } else {
        throw Exception('체온 기록 저장에 실패했습니다');
      }
    } catch (e) {
      print('DEBUG: 에러 발생: $e');
      print('DEBUG: 에러 타입: ${e.runtimeType}');
      
      String errorMessage = '체온 기록 중 오류가 발생했습니다.';
      
      if (e.toString().contains('로그인이 필요합니다')) {
        errorMessage = '로그인이 만료되었습니다. 앱을 다시 시작하거나 로그인해주세요.';
      } else if (e.toString().contains('KakaoClientException')) {
        print('DEBUG: 카카오 인증 토큰 문제 감지');
        errorMessage = '카카오 로그인에 문제가 있습니다. 앱을 다시 시작해주세요.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}