import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import 'record_detail_overlay.dart';

class EditRecordDialog extends StatefulWidget {
  final RecordType recordType;
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>) onSave;

  const EditRecordDialog({
    super.key,
    required this.recordType,
    required this.record,
    required this.onSave,
  });

  @override
  State<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  late Map<String, dynamic> _editedRecord;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editedRecord = Map.from(widget.record);
  }

  String _getRecordTitle() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return '수유';
      case RecordType.sleep:
        return '수면';
      case RecordType.diaper:
        return '기저귀';
      case RecordType.milkPumping:
        return '유축';
      case RecordType.solidFood:
        return '이유식';
      case RecordType.medication:
        return '투약';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getPrimaryColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getRecordIcon(),
                    color: _getPrimaryColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_getRecordTitle()} 기록 수정',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildFormContent(),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPrimaryColor(),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return _buildFeedingForm();
      case RecordType.sleep:
        return _buildSleepForm();
      case RecordType.diaper:
        return _buildDiaperForm();
      case RecordType.milkPumping:
        return _buildMilkPumpingForm();
      case RecordType.solidFood:
        return _buildSolidFoodForm();
      case RecordType.medication:
        return _buildMedicationForm();
    }
  }

  Widget _buildFeedingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '수유 시작 시간',
          value: DateTime.parse(_editedRecord['started_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['started_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),
        
        if (_editedRecord['ended_at'] != null) ...[
          _buildDateTimeField(
            label: '수유 종료 시간',
            value: DateTime.parse(_editedRecord['ended_at']).toLocal(),
            onChanged: (dateTime) {
              setState(() {
                _editedRecord['ended_at'] = dateTime.toIso8601String();
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        _buildDropdownField(
          label: '수유 타입',
          value: _editedRecord['type'] ?? 'bottle',
          items: const [
            {'value': 'breast', 'label': '모유수유'},
            {'value': 'bottle', 'label': '젖병'},
            {'value': 'formula', 'label': '분유'},
            {'value': 'solid', 'label': '이유식'},
          ],
          onChanged: (value) {
            setState(() {
              _editedRecord['type'] = value;
            });
          },
        ),
        const SizedBox(height: 20),

        if (_editedRecord['amount_ml'] != null) ...[
          _buildNumberField(
            label: '수유량 (ml)',
            value: _editedRecord['amount_ml'],
            onChanged: (value) {
              setState(() {
                _editedRecord['amount_ml'] = value;
              });
            },
            min: 0,
            max: 500,
            step: 10,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['duration_minutes'] != null) ...[
          _buildNumberField(
            label: '수유 시간 (분)',
            value: _editedRecord['duration_minutes'],
            onChanged: (value) {
              setState(() {
                _editedRecord['duration_minutes'] = value;
              });
            },
            min: 1,
            max: 120,
            step: 1,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['side'] != null) ...[
          _buildDropdownField(
            label: '수유 부위',
            value: _editedRecord['side'] ?? 'both',
            items: const [
              {'value': 'left', 'label': '왼쪽'},
              {'value': 'right', 'label': '오른쪽'},
              {'value': 'both', 'label': '양쪽'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['side'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        _buildTextField(
          label: '메모',
          value: _editedRecord['notes'] ?? '',
          onChanged: (value) {
            setState(() {
              _editedRecord['notes'] = value.isEmpty ? null : value;
            });
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSleepForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '수면 시작 시간',
          value: DateTime.parse(_editedRecord['started_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['started_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),
        
        if (_editedRecord['ended_at'] != null) ...[
          _buildDateTimeField(
            label: '수면 종료 시간',
            value: DateTime.parse(_editedRecord['ended_at']).toLocal(),
            onChanged: (dateTime) {
              setState(() {
                _editedRecord['ended_at'] = dateTime.toIso8601String();
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['duration_minutes'] != null) ...[
          _buildNumberField(
            label: '수면 시간 (분)',
            value: _editedRecord['duration_minutes'],
            onChanged: (value) {
              setState(() {
                _editedRecord['duration_minutes'] = value;
              });
            },
            min: 1,
            max: 720,
            step: 5,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['quality'] != null) ...[
          _buildDropdownField(
            label: '수면 품질',
            value: _editedRecord['quality'] ?? 'good',
            items: const [
              {'value': 'good', 'label': '좋음'},
              {'value': 'fair', 'label': '보통'},
              {'value': 'poor', 'label': '나쁨'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['quality'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        _buildTextField(
          label: '장소',
          value: _editedRecord['location'] ?? '',
          onChanged: (value) {
            setState(() {
              _editedRecord['location'] = value.isEmpty ? null : value;
            });
          },
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: '메모',
          value: _editedRecord['notes'] ?? '',
          onChanged: (value) {
            setState(() {
              _editedRecord['notes'] = value.isEmpty ? null : value;
            });
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDiaperForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '교체 시간',
          value: DateTime.parse(_editedRecord['changed_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['changed_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),

        _buildDropdownField(
          label: AppLocalizations.of(context)!.changeType,
          value: _editedRecord['type'] ?? 'wet',
          items: [
            {'value': 'wet', 'label': AppLocalizations.of(context)!.urine},
            {'value': 'dirty', 'label': AppLocalizations.of(context)!.poop},
            {'value': 'both', 'label': AppLocalizations.of(context)!.urinePoop},
          ],
          onChanged: (value) {
            setState(() {
              _editedRecord['type'] = value;
            });
          },
        ),
        const SizedBox(height: 20),

        if (_editedRecord['color'] != null) ...[
          _buildTextField(
            label: '색상',
            value: _editedRecord['color'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['color'] = value.isEmpty ? null : value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['consistency'] != null) ...[
          _buildTextField(
            label: '농도/질감',
            value: _editedRecord['consistency'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['consistency'] = value.isEmpty ? null : value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        _buildTextField(
          label: '메모',
          value: _editedRecord['notes'] ?? '',
          onChanged: (value) {
            setState(() {
              _editedRecord['notes'] = value.isEmpty ? null : value;
            });
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(value, onChanged),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: _getPrimaryColor(),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
    required int step,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - step) : null,
                icon: const Icon(Icons.remove),
                color: _getPrimaryColor(),
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + step) : null,
                icon: const Icon(Icons.add),
                color: _getPrimaryColor(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _selectDateTime(DateTime currentTime, Function(DateTime) onChanged) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _getPrimaryColor(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final DateTime newDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      onChanged(newDateTime);
    }
  }

  Color _getPrimaryColor() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return Colors.blue;
      case RecordType.sleep:
        return Colors.purple;
      case RecordType.diaper:
        return Colors.amber;
      case RecordType.milkPumping:
        return Colors.teal;
      case RecordType.solidFood:
        return Colors.green;
      case RecordType.medication:
        return Colors.pink;
    }
  }

  IconData _getRecordIcon() {
    switch (widget.recordType) {
      case RecordType.feeding:
        return Icons.local_drink;
      case RecordType.sleep:
        return Icons.bedtime;
      case RecordType.diaper:
        return Icons.child_care;
      case RecordType.milkPumping:
        return Icons.opacity;
      case RecordType.solidFood:
        return Icons.restaurant;
      case RecordType.medication:
        return Icons.medical_services;
    }
  }

  void _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add updated timestamp
      _editedRecord['updated_at'] = DateTime.now().toIso8601String();
      
      widget.onSave(_editedRecord);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving record: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.savingError),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildMilkPumpingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '유축 시작 시간',
          value: DateTime.parse(_editedRecord['started_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['started_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),
        
        if (_editedRecord['ended_at'] != null) ...[
          _buildDateTimeField(
            label: '유축 종료 시간',
            value: DateTime.parse(_editedRecord['ended_at']).toLocal(),
            onChanged: (dateTime) {
              setState(() {
                _editedRecord['ended_at'] = dateTime.toIso8601String();
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['amount_ml'] != null) ...[
          _buildNumberField(
            label: '유축량 (ml)',
            value: _editedRecord['amount_ml'] ?? 0,
            onChanged: (value) {
              setState(() {
                _editedRecord['amount_ml'] = value;
              });
            },
            min: 0,
            max: 500,
            step: 10,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['duration_minutes'] != null) ...[
          _buildNumberField(
            label: '유축 시간 (분)',
            value: _editedRecord['duration_minutes'] ?? 0,
            onChanged: (value) {
              setState(() {
                _editedRecord['duration_minutes'] = value;
              });
            },
            min: 1,
            max: 120,
            step: 1,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['side'] != null) ...[
          _buildDropdownField(
            label: '유축 위치',
            value: _editedRecord['side'] ?? 'both',
            items: const [
              {'value': 'left', 'label': '왼쪽'},
              {'value': 'right', 'label': '오른쪽'},
              {'value': 'both', 'label': '양쪽'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['side'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['storage_method'] != null) ...[
          _buildDropdownField(
            label: '저장 방법',
            value: _editedRecord['storage_method'] ?? 'refrigerator',
            items: const [
              {'value': 'refrigerator', 'label': '냉장고'},
              {'value': 'freezer', 'label': '냉동실'},
              {'value': 'room_temp', 'label': '실온'},
              {'value': 'fed_immediately', 'label': '즉시 사용'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['storage_method'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['notes'] != null) ...[
          _buildTextField(
            label: '메모',
            value: _editedRecord['notes'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['notes'] = value.isEmpty ? null : value;
              });
            },
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSolidFoodForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '이유식 시작 시간',
          value: DateTime.parse(_editedRecord['started_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['started_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),
        
        if (_editedRecord['ended_at'] != null) ...[
          _buildDateTimeField(
            label: '이유식 종료 시간',
            value: DateTime.parse(_editedRecord['ended_at']).toLocal(),
            onChanged: (dateTime) {
              setState(() {
                _editedRecord['ended_at'] = dateTime.toIso8601String();
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['food_name'] != null) ...[
          _buildTextField(
            label: '음식명',
            value: _editedRecord['food_name'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['food_name'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['amount'] != null) ...[
          _buildNumberField(
            label: '양 (g)',
            value: _editedRecord['amount'] ?? 0,
            onChanged: (value) {
              setState(() {
                _editedRecord['amount'] = value;
              });
            },
            min: 0,
            max: 1000,
            step: 5,
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['reaction'] != null) ...[
          _buildDropdownField(
            label: '알레르기 반응',
            value: _editedRecord['reaction'] ?? 'none',
            items: const [
              {'value': 'none', 'label': '없음'},
              {'value': 'mild', 'label': '경미'},
              {'value': 'moderate', 'label': '보통'},
              {'value': 'severe', 'label': '심각'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['reaction'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['notes'] != null) ...[
          _buildTextField(
            label: '메모',
            value: _editedRecord['notes'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['notes'] = value.isEmpty ? null : value;
              });
            },
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildMedicationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeField(
          label: '투약 시간',
          value: DateTime.parse(_editedRecord['administered_at']).toLocal(),
          onChanged: (dateTime) {
            setState(() {
              _editedRecord['administered_at'] = dateTime.toIso8601String();
            });
          },
        ),
        const SizedBox(height: 20),

        if (_editedRecord['medication_name'] != null) ...[
          _buildTextField(
            label: '약물명',
            value: _editedRecord['medication_name'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['medication_name'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        Row(
          children: [
            if (_editedRecord['dosage'] != null) ...[
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: '복용량',
                  value: _editedRecord['dosage'] ?? '',
                  onChanged: (value) {
                    setState(() {
                      _editedRecord['dosage'] = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (_editedRecord['unit'] != null) ...[
              Expanded(
                child: _buildDropdownField(
                  label: '단위',
                  value: _editedRecord['unit'] ?? 'ml',
                  items: const [
                    {'value': 'ml', 'label': 'ml'},
                    {'value': 'mg', 'label': 'mg'},
                    {'value': 'g', 'label': 'g'},
                    {'value': '정', 'label': '정'},
                    {'value': '캡슐', 'label': '캡슐'},
                    {'value': '방울', 'label': '방울'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _editedRecord['unit'] = value;
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        if (_editedRecord['medication_type'] != null) ...[
          _buildDropdownField(
            label: '투약 경로',
            value: _editedRecord['medication_type'] ?? 'oral',
            items: const [
              {'value': 'oral', 'label': '경구'},
              {'value': 'topical', 'label': '국소'},
              {'value': 'inhaled', 'label': '흡입'},
              {'value': 'injection', 'label': '주사'},
              {'value': 'eye_drops', 'label': '점안액'},
              {'value': 'nasal', 'label': '비강'},
            ],
            onChanged: (value) {
              setState(() {
                _editedRecord['medication_type'] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],

        if (_editedRecord['notes'] != null) ...[
          _buildTextField(
            label: '메모',
            value: _editedRecord['notes'] ?? '',
            onChanged: (value) {
              setState(() {
                _editedRecord['notes'] = value.isEmpty ? null : value;
              });
            },
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}