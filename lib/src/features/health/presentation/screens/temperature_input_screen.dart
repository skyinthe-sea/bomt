import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../../../domain/models/baby.dart';
import '../../../../domain/models/temperature_guideline.dart';
import '../../../../services/health/health_service.dart';
import '../../../../services/health/temperature_feedback_service.dart';
import '../widgets/temperature_feedback_dialog.dart';

class TemperatureInputScreen extends StatefulWidget {
  final Baby baby;

  const TemperatureInputScreen({
    super.key,
    required this.baby,
  });

  @override
  State<TemperatureInputScreen> createState() => _TemperatureInputScreenState();
}

class _TemperatureInputScreenState extends State<TemperatureInputScreen> {
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TemperatureMeasurementMethod _selectedMethod = TemperatureMeasurementMethod.axillary;
  bool _isLoading = false;

  @override
  void dispose() {
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('체온 기록'),
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
    return Container(
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
                  '${widget.baby.name}의 체온 기록',
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
        ],
      ),
    );
  }

  Widget _buildTemperatureInputSection(ThemeData theme, AppLocalizations l10n) {
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
            '체온',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '36.5',
                    hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
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
                      vertical: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '체온을 입력해주세요';
                    }
                    final temp = double.tryParse(value);
                    if (temp == null) {
                      return '올바른 숫자를 입력해주세요';
                    }
                    if (temp < 30.0 || temp > 45.0) {
                      return '체온은 30.0°C ~ 45.0°C 범위여야 합니다';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '°C',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            '측정 방법',
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
            '메모 (선택사항)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '증상이나 특이사항을 기록해주세요',
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
                '체온 기록 저장',
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
    switch (method) {
      case TemperatureMeasurementMethod.rectal:
        return '항문';
      case TemperatureMeasurementMethod.oral:
        return '구강';
      case TemperatureMeasurementMethod.axillary:
        return '겨드랑이';
      case TemperatureMeasurementMethod.ear:
        return '귀';
      case TemperatureMeasurementMethod.forehead:
        return '이마';
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
      final temperature = double.parse(_temperatureController.text);
      
      // 현재 사용자 ID 가져오기
      final user = await UserApi.instance.me();
      final userId = user.id.toString();
      
      // 체온 기록 저장
      final healthRecord = await HealthService.instance.addHealthRecord(
        babyId: widget.baby.id,
        userId: userId,
        type: 'temperature',
        temperature: temperature,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        recordedAt: DateTime.now(),
      );
      
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('체온 기록 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
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