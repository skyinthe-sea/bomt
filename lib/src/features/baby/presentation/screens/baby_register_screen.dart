import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../data/repositories/supabase_baby_repository.dart';

class BabyRegisterScreen extends StatefulWidget {
  const BabyRegisterScreen({super.key});

  @override
  State<BabyRegisterScreen> createState() => _BabyRegisterScreenState();
}

class _BabyRegisterScreenState extends State<BabyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repository = SupabaseBabyRepository();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['male', 'female', 'other'];
  Map<String, String> _genderLabels(BuildContext context) => {
    'male': AppLocalizations.of(context)!.male,
    'female': AppLocalizations.of(context)!.female,
    'other': AppLocalizations.of(context)!.other,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _registerBaby() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleasSelectBirthDate)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 로그인한 카카오 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      final userId = user.id.toString();

      // 아기 등록
      final baby = await _repository.createBaby(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender,
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.babyRegistered(baby.name))),
        );

        // 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registrationError(e.toString()))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerBaby),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 아기 아이콘
                const Icon(
                  Icons.child_care,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // 제목
                Text(
                  AppLocalizations.of(context)!.enterBabyInfo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 아기 이름 입력
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.babyName,
                    hintText: AppLocalizations.of(context)!.babyNameHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.baby_changing_station),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterBabyName;
                    }
                    if (value.trim().length < 2) {
                      return AppLocalizations.of(context)!.nameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 생년월일 선택
                InkWell(
                  onTap: _selectBirthDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          _selectedBirthDate == null
                              ? AppLocalizations.of(context)!.selectBirthDate
                              : AppLocalizations.of(context)!.dateFormat(
                                  _selectedBirthDate!.year.toString(),
                                  _selectedBirthDate!.month.toString(),
                                  _selectedBirthDate!.day.toString(),
                                ),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedBirthDate == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 성별 선택
                Text(
                  AppLocalizations.of(context)!.genderOptional,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _genderOptions.map((gender) {
                    final isSelected = _selectedGender == gender;
                    return FilterChip(
                      label: Text(_genderLabels(context)[gender]!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGender = selected ? gender : null;
                        });
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.3),
                      checkmarkColor: Colors.blue,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // 등록 버튼
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerBaby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      AppLocalizations.of(context)!.registerBaby,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 취소 버튼
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}