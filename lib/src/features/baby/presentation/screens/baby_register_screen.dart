import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../data/repositories/supabase_baby_repository.dart';
import '../../../../core/config/supabase_config.dart';

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
    print('🍼 [BABY_REGISTER] ======= 아기 등록 시작 =======');
    
    if (!_formKey.currentState!.validate()) {
      print('🍼 [BABY_REGISTER] 폼 유효성 검사 실패');
      return;
    }
    
    if (_selectedBirthDate == null) {
      print('🍼 [BABY_REGISTER] 생년월일이 선택되지 않음');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleasSelectBirthDate)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 로그인한 Supabase 사용자 정보 가져오기
      print('🍼 [BABY_REGISTER] Supabase 사용자 정보 가져오는 중...');
      final supabase = SupabaseConfig.client;
      final session = supabase.auth.currentSession;
      
      if (session == null || session.user == null) {
        throw Exception('로그인 세션이 없습니다. 다시 로그인해주세요.');
      }
      
      final userId = session.user!.id;
      print('🍼 [BABY_REGISTER] 사용자 ID: $userId');
      print('🍼 [BABY_REGISTER] 사용자 이메일: ${session.user!.email}');

      // 아기 등록 시도
      print('🍼 [BABY_REGISTER] 아기 정보 등록 시도...');
      print('🍼 [BABY_REGISTER] 아기 이름: ${_nameController.text.trim()}');
      print('🍼 [BABY_REGISTER] 생년월일: $_selectedBirthDate');
      print('🍼 [BABY_REGISTER] 성별: $_selectedGender');
      
      final baby = await _repository.createBaby(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender,
        userId: userId,
      );

      print('🍼 [BABY_REGISTER] 아기 등록 성공! 아기 ID: ${baby.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.babyRegistered(baby.name))),
        );

        print('🍼 [BABY_REGISTER] 홈 화면으로 이동 중...');
        // 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('🍼 [BABY_REGISTER] ❌ 오류 발생: $e');
      print('🍼 [BABY_REGISTER] 오류 타입: ${e.runtimeType}');
      
      // 더 구체적인 에러 정보 확인
      if (e.toString().contains('Invalid API key') || e.toString().contains('authentication')) {
        print('🍼 [BABY_REGISTER] 인증 관련 오류 감지');
      } else if (e.toString().contains('permission') || e.toString().contains('RLS') || e.toString().contains('policy')) {
        print('🍼 [BABY_REGISTER] 데이터베이스 권한 오류 감지');
      } else if (e.toString().contains('violates') || e.toString().contains('constraint')) {
        print('🍼 [BABY_REGISTER] 데이터베이스 제약 조건 오류 감지');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registrationError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      print('🍼 [BABY_REGISTER] 아기 등록 프로세스 완료');
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