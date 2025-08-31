// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get user => '사용자';

  @override
  String userInfoLoadFailed(String error) {
    return '사용자 정보 로드 실패: $error';
  }

  @override
  String babyListLoadError(String error) {
    return '아기 목록 로드 중 오류가 발생했습니다: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return '$nickname님 환영합니다! 🎉';
  }

  @override
  String get registerBaby => '아기 등록';

  @override
  String get noBabiesRegistered => '등록된 아기가 없습니다';

  @override
  String get registerFirstBaby => '첫 번째 아기를 등록해보세요!';

  @override
  String get registerBabyButton => '아기 등록하기';

  @override
  String birthday(int year, int month, int day) {
    return '생일: $year년 $month월 $day일';
  }

  @override
  String age(int days) {
    return '나이: $days일';
  }

  @override
  String gender(String gender) {
    return '성별';
  }

  @override
  String get male => '남자';

  @override
  String get female => '여자';

  @override
  String get other => '기타';

  @override
  String babyDetailScreen(String name) {
    return '$name 상세 화면 (추후 구현)';
  }

  @override
  String get selectBirthdate => '생년월일을 선택해주세요';

  @override
  String babyRegistered(String name) {
    return '$name 아기가 등록되었습니다!';
  }

  @override
  String registrationError(String error) {
    return '등록 중 오류가 발생했습니다: $error';
  }

  @override
  String get enterBabyInfo => '아기 정보를 입력해주세요';

  @override
  String get babyName => '아기 이름';

  @override
  String get babyNameHint => '예: 지민이';

  @override
  String get babyNameRequired => '아기 이름을 입력해주세요';

  @override
  String get babyNameMinLength => '이름은 2글자 이상 입력해주세요';

  @override
  String get selectBirthdateButton => '생년월일 선택';

  @override
  String selectedDate(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String get genderOptional => '성별 (선택사항)';

  @override
  String get cancel => '취소';

  @override
  String get loginFailed => '로그인에 실패했습니다';

  @override
  String loginError(String error) {
    return '로그인 중 오류가 발생했습니다: $error';
  }

  @override
  String get appTagline => '아기 성장 기록을 손쉽게 관리하세요';

  @override
  String get termsNotice => '로그인하면 서비스 이용약관 및 개인정보 처리방침에 동의하게 됩니다';

  @override
  String get loginWithKakao => '카카오로 로그인';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get selectBirthDate => '생년월일 선택';

  @override
  String get pleasSelectBirthDate => '생년월일을 선택해주세요';

  @override
  String get pleaseEnterBabyName => '아기 이름을 입력해주세요';

  @override
  String get nameMinLength => '이름은 2글자 이상 입력해주세요';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year년 $month월 $day일';
  }

  @override
  String get autoLogin => '자동 로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '정말 로그아웃 하시겠습니까?';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get darkMode => '다크 모드';

  @override
  String get appearance => '화면 설정';

  @override
  String get home => '홈';

  @override
  String get timeline => '타임라인';

  @override
  String get record => '기록하기';

  @override
  String get statistics => '통계';

  @override
  String get community => '커뮤니티';

  @override
  String get comingSoon => '출시 예정';

  @override
  String get timelineUpdateMessage => '타임라인 기능이 곧 업데이트 될 예정입니다';

  @override
  String get recordUpdateMessage => '기록 기능이 곧 업데이트 될 예정입니다';

  @override
  String get statisticsUpdateMessage => '통계 기능이 곧 업데이트 될 예정입니다';

  @override
  String get communityUpdateMessage => '커뮤니티 기능이 곧 업데이트 될 예정입니다';

  @override
  String get todaySummary => '오늘의 요약';

  @override
  String get growthInfo => '성장 정보';

  @override
  String get lastFeeding => '마지막 수유';

  @override
  String get healthy => '건강';

  @override
  String get feeding => '수유';

  @override
  String get totalFeeding => '총 수유량';

  @override
  String get sleep => '수면';

  @override
  String get totalSleepTime => '총 수면시간';

  @override
  String get cardSettings => '카드 설정';

  @override
  String get cardSettingsGuide => '카드 설정 가이드';

  @override
  String get cardSettingsDescription =>
      '• 토글 스위치로 카드 표시/숨김을 설정하세요\n• 드래그하여 카드 순서를 변경하세요\n• 변경사항은 실시간으로 미리보기됩니다';

  @override
  String get cardVisible => '표시됨';

  @override
  String get cardHidden => '숨김';

  @override
  String get save => '저장';

  @override
  String get cardSettingsSaved => '카드 설정이 저장되었습니다';

  @override
  String get cardSettingsError => '설정 저장 중 오류가 발생했습니다';

  @override
  String get discardChanges => '변경된 설정을 취소하고 이전 상태로 돌아가시겠습니까?';

  @override
  String get continueEditing => '계속 편집';

  @override
  String get discardChangesExit => '변경된 설정을 저장하지 않고 나가시겠습니까?';

  @override
  String get exit => '나가기';

  @override
  String get diaper => '기저귀';

  @override
  String get solidFood => '이유식';

  @override
  String get medication => '투약';

  @override
  String get milkPumping => '유축';

  @override
  String get temperature => '체온';

  @override
  String get growth => '성장';

  @override
  String get health => '건강';

  @override
  String feedingCount(Object count) {
    return '$count회';
  }

  @override
  String get feedingAmount => '수유량';

  @override
  String get feedingRecordAdded => '수유 기록이 추가되었습니다';

  @override
  String get feedingRecordFailed => '수유 기록 추가에 실패했습니다';

  @override
  String get feedingRecordsLoadFailed => '수유 기록을 불러오는데 실패했습니다';

  @override
  String get quickFeeding => '빠른 수유';

  @override
  String get feedingTime => '수유 시간';

  @override
  String get feedingType => '수유 방법';

  @override
  String get breastfeeding => '모유 수유';

  @override
  String get bottleFeeding => '분유 수유';

  @override
  String get mixedFeeding => '혼합 수유';

  @override
  String sleepCount(Object count) {
    return '$count회';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get sleepStarted => '수면을 시작했습니다';

  @override
  String get sleepEnded => '수면이 종료되었습니다';

  @override
  String get sleepInProgress => '수면 중';

  @override
  String get sleepRecordFailed => '수면 기록 처리에 실패했습니다';

  @override
  String get sleepRecordsLoadFailed => '수면 기록을 불러오는데 실패했습니다';

  @override
  String get sleepTime => '잠든 시간';

  @override
  String get wakeUpTime => '깬 시간';

  @override
  String get sleepDurationLabel => '수면 시간';

  @override
  String get napTime => '낮잠';

  @override
  String get nightSleep => '밤잠';

  @override
  String diaperCount(Object count) {
    return '$count회';
  }

  @override
  String get diaperChanged => '기저귀 교체';

  @override
  String get diaperRecordAdded => '기저귀 교체 기록이 추가되었습니다';

  @override
  String get diaperRecordFailed => '기저귀 기록 추가에 실패했습니다';

  @override
  String get diaperRecordsLoadFailed => '기저귀 기록을 불러오는데 실패했습니다';

  @override
  String get wetDiaper => '소변';

  @override
  String get dirtyDiaper => '대변';

  @override
  String get bothDiaper => '대소변';

  @override
  String wetCount(Object count) {
    return '소변 $count회';
  }

  @override
  String dirtyCount(Object count) {
    return '대변 $count회';
  }

  @override
  String bothCount(Object count) {
    return '대소변 $count회';
  }

  @override
  String get diaperType => '기저귀 종류';

  @override
  String get diaperChangeTime => '교체 시간';

  @override
  String get weight => '체중';

  @override
  String get height => '키';

  @override
  String get growthRecord => '성장 기록';

  @override
  String get growthRecordAdded => '성장 기록이 추가되었습니다';

  @override
  String get growthRecordFailed => '성장 기록 저장에 실패했습니다';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => '측정 항목';

  @override
  String get measurementValue => '측정값';

  @override
  String get notes => '메모';

  @override
  String get notesOptional => '메모 (선택사항)';

  @override
  String get temperatureRange => '체온은 30.0°C ~ 45.0°C 사이여야 합니다';

  @override
  String get weightRange => '체중은 0.1kg ~ 50kg 사이여야 합니다';

  @override
  String get heightRange => '키는 1cm ~ 200cm 사이여야 합니다';

  @override
  String get enterValidNumber => '올바른 숫자를 입력해주세요';

  @override
  String get recordGrowthInfo => '성장 정보 기록';

  @override
  String currentMeasurement(Object type) {
    return '현재 $type 입력';
  }

  @override
  String get measurementSituation => '측정 상황이나 특이사항을 기록해주세요 (선택사항)';

  @override
  String get communityTitle => '커뮤니티';

  @override
  String get writePost => '글쓰기';

  @override
  String get post => '게시';

  @override
  String get postTitle => '제목';

  @override
  String get postContent => '내용';

  @override
  String get postTitleHint => '제목을 입력하세요';

  @override
  String get postContentHint => '내용을 입력하세요...\n\n자유롭게 이야기를 나눠보세요.';

  @override
  String get selectCategory => '카테고리 선택';

  @override
  String get postCreated => '게시글이 성공적으로 작성되었습니다!';

  @override
  String postCreateFailed(Object error) {
    return '게시글 작성에 실패했습니다: $error';
  }

  @override
  String get nickname => '닉네임';

  @override
  String get nicknameSetup => '닉네임 설정';

  @override
  String get nicknameChange => '닉네임 변경';

  @override
  String get nicknameHint => '닉네임을 입력하세요';

  @override
  String get nicknameDescription => '커뮤니티에서 사용할 닉네임을 만들어주세요.\n다른 사용자들에게 표시됩니다.';

  @override
  String get nicknameChangeDescription => '새로운 닉네임으로 변경할 수 있습니다.';

  @override
  String get nicknameValidation => '한글, 영어, 숫자, 밑줄(_) 허용 (2-20자)';

  @override
  String get nicknameMinLength => '닉네임은 2글자 이상이어야 합니다';

  @override
  String get nicknameMaxLength => '닉네임은 20글자 이하여야 합니다';

  @override
  String get nicknameInvalidChars => '한글, 영어, 숫자, 밑줄(_)만 사용 가능합니다';

  @override
  String get nicknameChanged => '닉네임이 성공적으로 변경되었습니다!';

  @override
  String get startButton => '시작하기';

  @override
  String get changeButton => '변경';

  @override
  String characterCount(Object count) {
    return '제목: $count/200';
  }

  @override
  String contentCharacterCount(Object count) {
    return '내용: $count/10000';
  }

  @override
  String imageCount(Object count) {
    return '이미지: $count/5';
  }

  @override
  String get addImages => '이미지 추가';

  @override
  String imageSelectFailed(Object error) {
    return '이미지 선택에 실패했습니다: $error';
  }

  @override
  String get featureInDevelopment => '기능 개발 중';

  @override
  String get liveQA => '🔥 소아과 라이브 Q&A';

  @override
  String get liveQADescription => '오늘 오후 7시! 궁금했던 모든 질문에 전문의가 답변해드려요';

  @override
  String get likeOrder => '좋아요순';

  @override
  String get latestOrder => '최신순';

  @override
  String get userNotFound => '사용자 정보를 찾을 수 없습니다';

  @override
  String get statisticsTitle => '통계';

  @override
  String get noStatisticsData => '통계 데이터가 없습니다';

  @override
  String statisticsDescription(Object period) {
    return '$period 동안 기록된 활동이 없습니다.\n아기의 활동을 기록해보세요!';
  }

  @override
  String get recordActivity => '활동 기록하기';

  @override
  String get viewOtherPeriod => '다른 기간 보기';

  @override
  String get refresh => '새로고침';

  @override
  String get statisticsTips => '통계를 보려면?';

  @override
  String get statisticsTip1 => '수유, 수면, 기저귀 등의 활동을 기록하세요';

  @override
  String get statisticsTip2 => '통계를 위해서는 최소 하루의 데이터가 필요합니다';

  @override
  String get statisticsTip3 => '홈 화면에서 간편하게 기록할 수 있습니다';

  @override
  String get saveAsImage => '이미지로 저장';

  @override
  String get saveAsImageDescription => '통계를 이미지로 저장';

  @override
  String get shareAsText => '텍스트로 공유';

  @override
  String get shareAsTextDescription => '통계 요약을 텍스트로 공유';

  @override
  String get statisticsEmptyState => '통계 데이터 없음';

  @override
  String get retryButton => '다시 시도';

  @override
  String get detailsButton => '상세보기';

  @override
  String get goHomeButton => '홈으로';

  @override
  String get applyButton => '적용';

  @override
  String get lastWeek => '지난 주';

  @override
  String get lastMonth => '지난 달';

  @override
  String get last3Months => '최근 3개월';

  @override
  String get allTime => '전체';

  @override
  String get viewOtherPeriodTitle => '다른 기간 보기';

  @override
  String get familyInvitation => '가족 초대';

  @override
  String get invitationDescription => '초대 코드를 사용하여 가족과 함께 아기 기록을 관리하세요';

  @override
  String get createInvitation => '초대장 만들기';

  @override
  String get invitationCreated => '초대장이 성공적으로 생성되었습니다';

  @override
  String invitationCreateFailed(Object error) {
    return '초대장 생성에 실패했습니다: $error';
  }

  @override
  String get invitationRole => '역할';

  @override
  String get invitationDuration => '유효 기간';

  @override
  String get roleParent => '부모';

  @override
  String get roleCaregiver => '양육자';

  @override
  String get roleGuardian => '보호자';

  @override
  String get roleParentDesc => '아기의 부모로서 모든 기록을 관리할 수 있습니다';

  @override
  String get roleCaregiverDesc => '양육자로서 일부 기록을 관리할 수 있습니다';

  @override
  String get roleGuardianDesc => '아기의 보호자로서 기록을 조회할 수 있습니다';

  @override
  String get invitationGuide => '초대장 가이드';

  @override
  String get invitationGuideDesc =>
      '가족 구성원을 초대하여 함께 아기 기록을 관리할 수 있습니다. 초대받은 분은 앱 설치 후 초대 링크를 통해 참여하실 수 있습니다.';

  @override
  String get shareInvitation => '초대장 공유';

  @override
  String get shareImmediately => '지금 공유하기';

  @override
  String get invitationPreview => '초대장 미리보기';

  @override
  String invitationExpiry(Object duration) {
    return '$duration 후 만료';
  }

  @override
  String get joinWithCode => '초대 코드로 참여';

  @override
  String get invitationValidity => '초대장 유효 기간';

  @override
  String get testMode => '테스트 모드: 임시 사용자 정보로 초대장을 생성합니다';

  @override
  String get ok => '확인';

  @override
  String get edit => '편집';

  @override
  String get delete => '삭제';

  @override
  String get add => '추가';

  @override
  String get remove => '제거';

  @override
  String get confirm => '확인';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '다시 시도';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  @override
  String errorOccurred(Object error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get networkError => '네트워크 연결 오류';

  @override
  String get serverError => '서버 오류가 발생했습니다';

  @override
  String get validationError => '입력 내용을 확인해주세요';

  @override
  String get requiredField => '필수 입력 항목입니다';

  @override
  String get invalidInput => '잘못된 입력입니다';

  @override
  String get saveFailed => '저장에 실패했습니다';

  @override
  String get loadFailed => '로드에 실패했습니다';

  @override
  String get updateFailed => '업데이트에 실패했습니다';

  @override
  String get deleteFailed => '삭제에 실패했습니다';

  @override
  String timeFormat(Object hour, Object minute) {
    return '$hour:$minute';
  }

  @override
  String dateTimeFormat(
    Object day,
    Object hour,
    Object minute,
    Object month,
    Object year,
  ) {
    return '$year-$month-$day $hour:$minute';
  }

  @override
  String durationMinutes(Object minutes) {
    return '$minutes분';
  }

  @override
  String durationHours(Object hours) {
    return '$hours시간';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String daysAgo(Object days) {
    return '$days일 전';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours시간 전';
  }

  @override
  String minutesAgo(Object minutes) {
    return '$minutes분 전';
  }

  @override
  String get justNow => '방금 전';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get thisWeek => '이번 주';

  @override
  String get thisMonth => '이번 달';

  @override
  String get medicationName => '약품명';

  @override
  String get medicationDose => '용량';

  @override
  String get medicationTime => '투약';

  @override
  String get medicationAdded => '투약 기록이 추가되었습니다';

  @override
  String get solidFoodType => '이유식 종류';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => '이유식 기록이 추가되었습니다';

  @override
  String get milkPumpingAmount => '유축량';

  @override
  String get milkPumpingTime => '유축 시간';

  @override
  String get milkPumpingAdded => '유축 기록이 추가되었습니다';

  @override
  String get temperatureReading => '체온 측정';

  @override
  String get temperatureNormal => '정상';

  @override
  String get temperatureHigh => '고열';

  @override
  String get temperatureLow => '저체온';

  @override
  String get profilePhoto => '프로필 사진';

  @override
  String get profilePhotoUpdate => '프로필 사진 업데이트';

  @override
  String get selectPhotoSource => '사진을 어떻게 선택하시겠습니까?';

  @override
  String get camera => '카메라';

  @override
  String get gallery => '갤러리';

  @override
  String get photoUpdated => '프로필 사진이 업데이트되었습니다';

  @override
  String get photoUploadFailed => '프로필 사진 업데이트에 실패했습니다';

  @override
  String get photoUploading => '사진 업로드 중...';

  @override
  String get cameraNotAvailable =>
      'iOS 시뮬레이터에서는 카메라를 사용할 수 없습니다.\n갤러리에서 선택해주세요.';

  @override
  String get cameraAccessError => '카메라 접근 오류가 발생했습니다.\n갤러리에서 선택해주세요.';

  @override
  String get addImage => '이미지 추가';

  @override
  String get removeImage => '이미지 제거';

  @override
  String maxImagesReached(Object count) {
    return '최대 $count개의 이미지만 허용됩니다';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$months개월 $days일';
  }

  @override
  String get lastFeedingTime => '마지막 수유 시간';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours시간 $minutes분 전';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return '약 $hours시간 $minutes분 후 수유 예정';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return '약 $minutes분 후 수유 예정';
  }

  @override
  String get feedingTimeNow => '지금 수유 시간입니다 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return '곧 수유 시간입니다 ($minutes분 후)';
  }

  @override
  String get feedingTimeOverdue => '수유 시간이 지났습니다';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return '$hours시간 $minutes분 후 수유 알람';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return '$minutes분 후 수유 알람';
  }

  @override
  String get times => '회';

  @override
  String get meals => '끼';

  @override
  String get kilograms => 'kg';

  @override
  String get centimeters => 'cm';

  @override
  String get milliliters => 'ml';

  @override
  String get grams => 'g';

  @override
  String get hoursUnit => '시간';

  @override
  String get minutesUnit => '분';

  @override
  String get viewDetails => '상세보기';

  @override
  String get firstRecord => '첫 기록';

  @override
  String get noChange => '변화 없음';

  @override
  String get inProgress => '진행 중';

  @override
  String get scheduled => '예정';

  @override
  String get startBabyRecording => '아기를 등록하고 육아 기록을 시작해보세요';

  @override
  String get registerBabyNow => '아기 등록하기';

  @override
  String get joinWithInviteCode => '초대 코드로 참여';

  @override
  String get loadingBabyInfo => '아기 정보를 불러오는 중...';

  @override
  String get pleaseRegisterBaby => '설정에서 아기를 등록해주세요';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get profilePhotoUpdated => '프로필 사진이 업데이트되었습니다.';

  @override
  String get profilePhotoUpdateFailed => '프로필 사진 업데이트에 실패했습니다';

  @override
  String diaperWetAndDirty(Object count) {
    return '소+대 $count회';
  }

  @override
  String diaperWetAndDirtySeparate(Object dirtyCount, Object wetCount) {
    return '소$wetCount, 대$dirtyCount';
  }

  @override
  String get sleepZeroHours => '0시간';

  @override
  String solidFoodMeals(Object count) {
    return '$count끼';
  }

  @override
  String medicationScheduled(Object count) {
    return '약 $count회';
  }

  @override
  String medicationTypes(Object vaccineCount, Object vitaminCount) {
    return '영양제$vitaminCount, 백신$vaccineCount';
  }

  @override
  String get feedingRecordAddFailed => '수유 기록 추가에 실패했습니다';

  @override
  String get diaperRecordAddFailed => '기저귀 기록 추가에 실패했습니다';

  @override
  String get sleepRecordProcessFailed => '수면 기록 처리에 실패했습니다';

  @override
  String get hourActivityPattern => '24시간 활동 패턴';

  @override
  String get touchClockInstruction => '시계를 터치해서 시간대별 활동을 확인하세요';

  @override
  String get touch => '터치';

  @override
  String get noActivitiesInTimeframe => '이 시간대에는 활동이 없었어요';

  @override
  String get activityPatternAnalysis => '활동 패턴 분석';

  @override
  String get todaysStory => '오늘의 스토리';

  @override
  String preciousMoments(Object count) {
    return '$count개의 소중한 순간들';
  }

  @override
  String get firstMomentMessage =>
      '첫 번째 소중한 순간을 기록해보세요.\n매일의 작은 변화들이 모여 큰 성장이 됩니다.';

  @override
  String get pattern => '패턴';

  @override
  String get qualityGood => '좋음';

  @override
  String get qualityExcellent => '매우 좋음';

  @override
  String get qualityFair => '보통';

  @override
  String get qualityPoor => '나쁨';

  @override
  String get timeSlot => '시간대';

  @override
  String get am => '오전';

  @override
  String get pm => '오후';

  @override
  String get activityConcentrationTime => '하루 중 활동이 집중된 시간대';

  @override
  String get formula => '분유';

  @override
  String get breastMilk => '모유';

  @override
  String get babyFood => '이유식';

  @override
  String get left => '왼쪽';

  @override
  String get right => '오른쪽';

  @override
  String get both => '양쪽';

  @override
  String get sleeping => '수면 중';

  @override
  String get hoursText => '시간';

  @override
  String get minutesText => '분';

  @override
  String get elapsed => '경과';

  @override
  String get urineOnly => '소변만';

  @override
  String get stoolOnly => '대변만';

  @override
  String get urineAndStool => '소변 + 대변';

  @override
  String get color => '색깔';

  @override
  String get consistency => '농도';

  @override
  String get diaperChange => '기저귀 교체';

  @override
  String get oralMedication => '경구 투약';

  @override
  String get topical => '외용';

  @override
  String get inhaled => '흡입';

  @override
  String get pumping => '유축 중';

  @override
  String get temperatureMeasurement => '체온 측정';

  @override
  String get fever => '발열';

  @override
  String get lowFever => '미열';

  @override
  String get hypothermia => '저체온';

  @override
  String get normal => '정상';

  @override
  String get quality => '품질';

  @override
  String get weekly => '주간';

  @override
  String get monthly => '월간';

  @override
  String get custom => '커스텀';

  @override
  String daysCount(Object count) {
    return '$count일간';
  }

  @override
  String noActivitiesRecordedInPeriod(Object period) {
    return '$period 기간 동안 기록된 활동이 없습니다.';
  }

  @override
  String get recordBabyActivities => '아기의 활동을 기록해보세요!';

  @override
  String get howToViewStatistics => '통계를 보려면?';

  @override
  String get recordActivitiesLikeFeedingSleep => '수유, 수면, 기저귀 등의 활동을 기록하세요';

  @override
  String get atLeastOneDayDataRequired => '최소 하루 이상의 데이터가 있어야 통계가 표시됩니다';

  @override
  String get canRecordEasilyFromHome => '홈 화면에서 간편하게 기록할 수 있습니다';

  @override
  String get updating => '업데이트 중...';

  @override
  String get lastUpdated => '마지막 업데이트:';

  @override
  String get periodSelection => '기간 선택:';

  @override
  String get daily => '일간';

  @override
  String get startDate => '시작일';

  @override
  String get endDate => '종료일';

  @override
  String get apply => '적용';

  @override
  String get pleaseSelectDate => '날짜를 선택하세요';

  @override
  String get detailedStatistics => '상세 통계';

  @override
  String get chartAnalysis => '차트 분석';

  @override
  String get overallActivityOverview => '전체 활동 개요';

  @override
  String get totalActivities => '총 활동';

  @override
  String get activeCards => '활성 카드';

  @override
  String get dailyAverage => '일평균';

  @override
  String get activityDistributionByCard => '카드별 활동 분포';

  @override
  String get cannotLoadData => '데이터를 불러올 수 없습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get details => '자세히';

  @override
  String get goToHome => '홈으로';

  @override
  String get troubleshootingMethods => '문제 해결 방법';

  @override
  String get shareStatistics => '통계 공유';

  @override
  String get communitySubtitle => '함께 나누는 육아 이야기';

  @override
  String get search => '검색';

  @override
  String get notification => '알림';

  @override
  String get searchFeatureComingSoon => '검색 기능 준비 중입니다';

  @override
  String get communityWelcome => '💕 육아 커뮤니티';

  @override
  String get communityWelcomeDescription =>
      '다른 부모님들과 육아 경험을 나누고 소중한 정보를 공유해보세요';

  @override
  String get categorySelection => '카테고리 선택';

  @override
  String get categoryAll => '전체';

  @override
  String get categoryPopular => '인기';

  @override
  String get categoryClinical => '임상';

  @override
  String get categoryInfoSharing => '정보공유';

  @override
  String get categorySleepIssues => '수면문제';

  @override
  String get categoryBabyFood => '이유식';

  @override
  String get categoryDevelopment => '발달단계';

  @override
  String get categoryVaccination => '예방접종';

  @override
  String get categoryPostpartum => '산후회복';

  @override
  String get sortByLikes => '좋아요순';

  @override
  String get sortByLatest => '최신순';

  @override
  String get edited => '(수정됨)';

  @override
  String commentsCount(Object count) {
    return '댓글 $count개';
  }

  @override
  String get deletePost => '게시글 삭제';

  @override
  String get deletePostConfirm => '정말로 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.';

  @override
  String get deletePostSuccess => '게시글이 삭제되었습니다.';

  @override
  String deletePostError(Object error) {
    return '삭제 실패: $error';
  }

  @override
  String get postNotFound => '게시글을 찾을 수 없습니다';

  @override
  String get shareFeatureComingSoon => '공유 기능 준비 중입니다';

  @override
  String get loadingComments => '댓글 불러오는 중...';

  @override
  String get loadMoreComments => '더 많은 댓글 보기';

  @override
  String get editComment => '댓글 수정';

  @override
  String get editCommentHint => '댓글을 수정하세요...';

  @override
  String get editCommentSuccess => '댓글이 수정되었습니다.';

  @override
  String editCommentError(Object error) {
    return '수정 실패: $error';
  }

  @override
  String get deleteComment => '댓글 삭제';

  @override
  String get deleteCommentConfirm => '정말로 이 댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.';

  @override
  String get deleteCommentSuccess => '댓글이 삭제되었습니다.';

  @override
  String get replySuccess => '답글이 작성되었습니다.';

  @override
  String get commentSuccess => '댓글이 작성되었습니다.';

  @override
  String get commentError => '댓글 작성에 실패했습니다.';

  @override
  String get titlePlaceholder => '제목을 입력하세요';

  @override
  String get contentPlaceholder =>
      '내용을 입력하세요...\n\n함께 나누고 싶은 이야기를 자유롭게 작성해보세요.';

  @override
  String imageSelectionError(Object error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get userNotFoundError => '사용자 정보를 찾을 수 없습니다.';

  @override
  String get postCreateSuccess => '게시글이 성공적으로 작성되었습니다!';

  @override
  String postCreateError(Object error) {
    return '게시글 작성 실패: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return '제목: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return '이미지: $count/5';
  }

  @override
  String get addImageTooltip => '이미지 추가';

  @override
  String get allPostsChecked => '모든 게시글을 확인했어요! 👍';

  @override
  String get waitForNewPosts => '새로운 게시글이 올라올 때까지 잠시 기다려주세요';

  @override
  String get noPostsYet => '아직 게시글이 없어요';

  @override
  String get writeFirstPost => '첫 번째 게시글을 작성해보세요!';

  @override
  String get loadingNewPosts => '새로운 게시글을 불러오는 중...';

  @override
  String get failedToLoadPosts => '게시글을 불러오는데 실패했어요';

  @override
  String get checkNetworkAndRetry => '네트워크 연결을 확인하고 다시 시도해주세요';

  @override
  String get categoryDailyLife => '일상';

  @override
  String get preparingTimeline => '타임라인을 준비하고 있어요...';

  @override
  String get noRecordedMoments => '아직 기록된 순간이 없어요';

  @override
  String get loadingTimeline => '타임라인을 불러오고 있어요...';

  @override
  String get noRecordsYet => '아직 기록이 없어요';

  @override
  String noRecordsForDate(Object date) {
    return '$date은 아직 기록이 없습니다';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return '$date은 $filter 기록이 없습니다';
  }

  @override
  String get cannotRecordFuture => '미래의 기록은 아직 작성할 수 없습니다';

  @override
  String get addFirstRecord => '첫 번째 기록을 추가해보세요!';

  @override
  String get canAddPastRecord => '과거의 기록을 추가할 수 있습니다';

  @override
  String get addRecord => '기록 추가하기';

  @override
  String get viewOtherDates => '다른 날짜 보기';

  @override
  String get goToToday => '오늘로 가기';

  @override
  String get quickRecordFromHome => '홈 화면에서 빠르게 기록을 추가할 수 있습니다';

  @override
  String detailViewComingSoon(String title) {
    return '$title 상세보기 (개발 예정)';
  }

  @override
  String get familyInvitationDescription => '초대 코드로 가족과 함께 육아 기록을 관리하세요';

  @override
  String get babyManagement => '아기 관리';

  @override
  String get addBaby => '아기 추가';

  @override
  String get noBabiesMessage => '등록된 아기가 없습니다.\n아기를 추가해주세요.';

  @override
  String get switchToNextBaby => '다음 아기로 전환';

  @override
  String get birthDate => '생년월일';

  @override
  String get registering => '등록 중...';

  @override
  String get register => '등록';

  @override
  String careTogetherWith(String name) {
    return '$name과 함께 육아해요';
  }

  @override
  String get inviteFamilyDescription => '가족이나 파트너를 초대해서\n함께 육아 기록을 관리하세요';

  @override
  String get generateInviteCode => '초대 코드 생성';

  @override
  String get generateInviteCodeDescription => '새로운 초대 코드를 생성하고 복사하세요';

  @override
  String get generateInviteCodeButton => '초대 코드 생성';

  @override
  String get orText => '또는';

  @override
  String get enterInviteCodeDescription => '받은 초대 코드를 입력해주세요';

  @override
  String get inviteCodePlaceholder => '초대 코드 (6자리)';

  @override
  String get acceptInvite => '초대 수락';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name이(가) 성공적으로 등록되었습니다';
  }

  @override
  String get babyRegistrationFailed => '아기 등록에 실패했습니다';

  @override
  String babyRegistrationError(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String babySelected(String name) {
    return '$name이(가) 선택되었습니다';
  }

  @override
  String get inviteCodeGenerated => '초대 코드 생성 완료!';

  @override
  String remainingTime(String time) {
    return '남은 시간: $time';
  }

  @override
  String get validTime => '유효 시간: 5분';

  @override
  String get generating => '생성 중...';

  @override
  String get joining => '참여 중...';

  @override
  String get noBabyInfo => '아기 정보 없음';

  @override
  String get noBabyInfoDescription => '아기 정보가 없습니다.\n테스트용 아기를 생성하시겠습니까?';

  @override
  String get create => '생성';

  @override
  String get generateNewInviteCode => '새로운 초대 코드 생성';

  @override
  String get replaceExistingCode => '기존 초대 코드를 대체합니다.\n계속하시겠습니까?';

  @override
  String get acceptInvitation => '초대 수락';

  @override
  String get acceptInvitationDescription => '초대를 수락하고 가족에 참여하시겠습니까?';

  @override
  String acceptInvitationWarning(String babyName) {
    return '기존에 등록된 아기 기록은 사라지고,\n초대받은 아기($babyName)로 변경됩니다.\n\n계속하시겠습니까?';
  }

  @override
  String get pleaseEnterInviteCode => '초대 코드를 입력해주세요';

  @override
  String get inviteCodeMustBe6Digits => '초대 코드는 6자리입니다';

  @override
  String get pleaseLoginFirst => '로그인 정보가 없습니다. 먼저 로그인해주세요.';

  @override
  String get copiedToClipboard => '초대 코드가 클립보드에 복사되었습니다!';

  @override
  String get joinedSuccessfully => '가족에 성공적으로 참여했습니다!';

  @override
  String get inviteCodeExpired => '초대 코드가 만료되었습니다';

  @override
  String get invalidInviteCode => '잘못된 초대 코드입니다';

  @override
  String get alreadyMember => '이미 이 가족의 구성원입니다';

  @override
  String get cannotInviteSelf => '자기 자신을 초대할 수 없습니다';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String babyGuideTitle(String name) {
    return '$name의 육아 가이드';
  }

  @override
  String get babyGuide => '육아 가이드';

  @override
  String get noAvailableGuides => '사용 가능한 가이드가 없습니다';

  @override
  String get current => '현재';

  @override
  String get past => '지남';

  @override
  String get upcoming => '예정';

  @override
  String babysGuide(String name) {
    return '$name의';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText 가이드';
  }

  @override
  String get feedingGuide => '💡 수유 가이드';

  @override
  String get feedingFrequency => '수유 횟수';

  @override
  String get singleFeedingAmount => '1회 수유량';

  @override
  String get dailyTotal => '일일 총량';

  @override
  String get additionalTips => '📋 추가 팁';

  @override
  String get understood => '확인했어요';

  @override
  String get newborn => '신생아';

  @override
  String weekNumber(int number) {
    return '$number주차';
  }

  @override
  String get newbornWeek0 => '신생아 (0주차)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return '하루 $min - $max회';
  }

  @override
  String dailyFrequencyMin(int min) {
    return '하루 $min회 이상';
  }

  @override
  String dailyFrequencyMax(int max) {
    return '하루 $max회 이하';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml 이상';
  }

  @override
  String amountMaxML(int max) {
    return '${max}ml 이하';
  }

  @override
  String get insufficientFeedingRecords => '계속 수유를 기록해주세요';

  @override
  String get noRecentFeeding => '최근 수유 기록이 없습니다';

  @override
  String get languageSelection => '언어 선택';

  @override
  String get selectLanguage => '언어를 선택하세요';

  @override
  String get currentLanguage => '현재 언어';

  @override
  String get searchCommunityPosts => '커뮤니티 게시글 검색';

  @override
  String get temperatureRecord => '체온 기록';

  @override
  String get temperatureTrend => '체온 추이';

  @override
  String get profilePhotoSetup => '프로필 사진 설정';

  @override
  String get howToSelectPhoto => '사진을 어떻게 선택하시겠습니까?';

  @override
  String get send => '전송';

  @override
  String get emailVerificationRequired => '이메일 인증 필요';

  @override
  String get passwordReset => '비밀번호 재설정';

  @override
  String get enterEmailForReset => '가입하신 이메일 주소를 입력하세요.\n비밀번호 재설정 링크를 보내드립니다.';

  @override
  String get accountWithdrawalComplete => '탈퇴 완료';

  @override
  String get genderLabel => '성별: ';

  @override
  String get birthdateLabel => '생년월일: ';

  @override
  String get maleGender => '남자';

  @override
  String get femaleGender => '여자';

  @override
  String get joinWithInviteCodeButton => '초대 코드로 참여하기';

  @override
  String get temperatureRecorded => '체온이 기록되었습니다';

  @override
  String recordFailed(String error) {
    return '기록 실패';
  }

  @override
  String get temperatureSettingsSaved => '체온 설정이 저장되었습니다';

  @override
  String get loadingUserInfo => '사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.';

  @override
  String get continueWithSeparateAccount => '별도 계정으로 계속';

  @override
  String get linkWithExistingAccount => '기존 계정과 연결';

  @override
  String get linkAccount => '연결하기';

  @override
  String get accountLinkingComplete => '계정 연결 완료';

  @override
  String get deleteConfirmation => '삭제 확인';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get babyNameLabel => '아기 이름';

  @override
  String get weightInput => '체중 입력';

  @override
  String get heightInput => '키 입력';

  @override
  String get measurementNotes => '측정 상황이나 특이사항을 기록해주세요 (선택사항)';

  @override
  String get urine => '소변';

  @override
  String get stool => '대변';

  @override
  String get yellow => '노란색';

  @override
  String get brown => '갈색';

  @override
  String get green => '녹색';

  @override
  String get bottle => '젖병';

  @override
  String get good => '좋음';

  @override
  String get average => '평균';

  @override
  String get poor => '나쁨';

  @override
  String get vaccination => '예방접종';

  @override
  String get illness => '질병';

  @override
  String get highFever => '고열';

  @override
  String get oral => '경구';

  @override
  String get inhalation => '흡입';

  @override
  String get injection => '주사';

  @override
  String get tablet => '정';

  @override
  String get drops => '방울';

  @override
  String get teaspoon => '티스푼';

  @override
  String get tablespoon => '큰술';

  @override
  String get sleepQuality => '품질';

  @override
  String get pumpingTime => '유축';

  @override
  String get solidFoodTime => '이유식';

  @override
  String get totalFeedingAmount => '총 수유량';

  @override
  String get averageFeedingAmount => '평균 수유량';

  @override
  String get dailyAverageFeedingCount => '하루 평균 수유 횟수';

  @override
  String get clinical => '임상';

  @override
  String get infoSharing => '정보공유';

  @override
  String get sleepIssues => '수면문제';

  @override
  String get babyFoodCategory => '이유식';

  @override
  String get developmentStage => '발달단계';

  @override
  String get vaccinationCategory => '예방접종';

  @override
  String get postpartumRecovery => '산후회복';

  @override
  String get dailyLife => '일상';

  @override
  String get likes => '좋아요';

  @override
  String get comments => '댓글';

  @override
  String get anonymous => '익명';

  @override
  String get minutes => '분';

  @override
  String get armpit => '겨드랑이';

  @override
  String get forehead => '이마';

  @override
  String get ear => '귀';

  @override
  String get mouth => '입';

  @override
  String get rectal => '직장';

  @override
  String get otherLocation => '기타';

  @override
  String get searchError => '검색 오류';

  @override
  String get question => '질문';

  @override
  String get information => '정보';

  @override
  String get relevance => '관련도';

  @override
  String get searchSuggestions => '검색 제안';

  @override
  String get noSearchResults => '검색 결과가 없습니다';

  @override
  String get tryDifferentSearchTerm => '다른 검색어를 시도해보세요';

  @override
  String get likeFeatureComingSoon => '좋아요 기능 준비 중';

  @override
  String get popularSearchTerms => '인기 검색어';

  @override
  String get recentSearches => '최근 검색어';

  @override
  String get deleteAll => '전체삭제';

  @override
  String get sortByComments => '댓글순';

  @override
  String get detailInformation => '상세 정보';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get recordAgain => '다시 기록';

  @override
  String get share => '공유';

  @override
  String get deleteRecord => '기록 삭제';

  @override
  String get deleteRecordConfirmation => '이 기록을 정말 삭제하시겠습니까?';

  @override
  String get recordDeleted => '기록이 삭제되었습니다';

  @override
  String get featureComingSoon => '곧 출시될 기능입니다';

  @override
  String get editRecord => '기록 편집';

  @override
  String get dateTime => '날짜 및 시간';

  @override
  String get date => '날짜';

  @override
  String get time => '시간';

  @override
  String get amount => '양';

  @override
  String get duration => '시간';

  @override
  String get dosage => '용량';

  @override
  String get unit => '단위';

  @override
  String get side => '쪽';

  @override
  String get fair => '보통';

  @override
  String get wet => '젖음';

  @override
  String get dirty => '더러움';

  @override
  String get location => '위치';

  @override
  String get notesHint => '추가 메모를 입력하세요...';

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String get changesSaved => '변경사항이 저장되었습니다';

  @override
  String get smartInsights => '스마트 인사이트';

  @override
  String get analyzingPatterns => '패턴 분석 중...';

  @override
  String insightsFound(int count) {
    return '$count개의 인사이트 발견';
  }

  @override
  String get noInsightsYet => '아직 분석할 패턴이 충분하지 않습니다';

  @override
  String get confidence => '신뢰도';

  @override
  String sleepProgressMinutes(int minutes) {
    return '$minutes분 진행 중';
  }

  @override
  String get sleepProgressTime => '수면 진행 시간';

  @override
  String get standardFeedingTimeNow => '표준 수유 시간입니다';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return '곧 표준 수유 시간입니다 ($minutes분 후)';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '표준 수유까지 $hours시간 $minutes분';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '표준 수유까지 $minutes분';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      '수유 기록이 부족합니다 (표준 간격 적용)';

  @override
  String get standardFeedingTimeOverdue => '표준 수유 시간이 지났습니다';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes분';
  }

  @override
  String personalPatternInfo(String interval) {
    return '개인 패턴: $interval 간격 (참고용)';
  }

  @override
  String get longPressForDetails => '길게 눌러 상세보기';

  @override
  String get todaysSummary => '오늘의 요약';

  @override
  String get future => '미래';

  @override
  String get previousDate => '이전 날짜';

  @override
  String get nextDate => '다음 날짜';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get checkStandardFeedingInterval => '표준 수유 간격을 확인하세요';

  @override
  String get registerBabyFirst => '아기를 등록해주세요';

  @override
  String get registerBabyToRecordMoments =>
      '아기의 소중한 순간들을 기록하기 위해\n먼저 아기 정보를 등록해주세요.';

  @override
  String get addBabyFromHome => '홈에서 아기 추가하기';

  @override
  String get timesUnit => '회';

  @override
  String get itemsUnit => '개';

  @override
  String get timesPerDay => '회/일';

  @override
  String get activityDistributionByCategory => '카드별 활동 분포';

  @override
  String itemsCount(int count) {
    return '$count개 항목';
  }

  @override
  String get totalCount => '총 횟수';

  @override
  String timesCount(int count) {
    return '$count회';
  }

  @override
  String get noDetailedData => '상세 데이터 없음';

  @override
  String get averageFeedingTime => '평균 수유 시간';

  @override
  String get averageSleepTime => '평균 수면 시간';

  @override
  String get dailyAverageTotalSleepTime => '하루 평균 총 수면 시간';

  @override
  String get dailyAverageSleepCount => '하루 평균 수면 횟수';

  @override
  String get dailyAverageChangeCount => '하루 평균 교체 횟수';

  @override
  String get sharingParentingStories => '함께 나누는 육아 이야기';

  @override
  String get myActivity => '내 활동';

  @override
  String get categories => '카테고리';

  @override
  String get menu => '메뉴';

  @override
  String get seeMore => '더 보기';

  @override
  String get midnight => '자정';

  @override
  String get morning => '오전';

  @override
  String get noon => '정오';

  @override
  String get afternoon => '오후';

  @override
  String get quickSelection => 'Quick Selection';

  @override
  String get customSettings => 'Custom Settings';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get recent7Days => 'Recent 7 Days';

  @override
  String get recent14Days => 'Recent 14 Days';

  @override
  String get recent30Days => 'Recent 30 Days';

  @override
  String get selectPeriodForAnalysis => 'Please select the period for analysis';

  @override
  String get cardSettingsInstructions =>
      '• Toggle switches to show/hide cards\n• Drag to change card order\n• Changes are previewed in real time';

  @override
  String get visible => 'Visible';

  @override
  String get hidden => 'Hidden';

  @override
  String get touchToSetDefault => 'Touch to set default values';

  @override
  String get unsavedChangesMessage =>
      'Do you want to cancel changes and return to previous state?';

  @override
  String get unsavedChangesExitMessage =>
      'Do you want to exit without saving changes?';

  @override
  String get exitWithoutSaving => 'Exit';

  @override
  String get savingError =>
      'An error occurred while saving settings. Please try again.';

  @override
  String get familyMembers => 'Family Members';

  @override
  String get cannotLoadFamilyMembersInfo =>
      'Cannot load family member information';

  @override
  String get administrator => 'Administrator';

  @override
  String get member => 'Member';

  @override
  String joinDate(String date) {
    return 'Join date: $date';
  }

  @override
  String get inviteFamilyMembersDescription =>
      'Invite family members to manage baby records together';

  @override
  String joinFamilyGroupWarning(String familyName) {
    return 'Do you want to join $familyName\'s family?\n\nExisting baby data will be moved to the new family group.';
  }

  @override
  String get familyInvitationAccepted =>
      'Family invitation accepted! Now you can manage baby records together.';

  @override
  String careTogetherWithFamily(String familyName) {
    return 'Caring for baby together with $familyName';
  }

  @override
  String get feedingTimeNotificationTitle => 'It\'s feeding time! 🍼';

  @override
  String get feedingTimeNotificationBody => 'Baby might be hungry now.';

  @override
  String get feedingAlarmChannelName => 'Feeding Reminders';

  @override
  String get feedingAlarmChannelDescription =>
      'Feeding time reminder notifications';

  @override
  String get averageFeedingDuration => 'Average feeding duration';

  @override
  String get averageSleepDuration => 'Average sleep duration';

  @override
  String get dailyTotalSleepDuration => 'Daily total sleep duration';

  @override
  String get dailyAverageDiaperChangeCount => 'Daily average diaper changes';

  @override
  String get dailyAverageMedicationCount => 'Daily average medication count';

  @override
  String get medicationTypesUsed => 'Types of medication used';

  @override
  String get totalPumpedAmount => 'Total pumped amount';

  @override
  String get averagePumpedAmount => 'Average pumped amount';

  @override
  String get countTab => 'Count';

  @override
  String get amountTimeTab => 'Amount/Time';

  @override
  String get durationTab => 'Duration';

  @override
  String get chartDataLoading => 'Loading chart data...';

  @override
  String get chartDataNotAvailable => 'Chart data not available.';

  @override
  String get averageLabel => 'Average: ';

  @override
  String get dailyFeedingCountTitle => 'Daily feeding count';

  @override
  String get weekdaysSundayToSaturday => 'SunMonTueWedThuFriSat';

  @override
  String dayFormat(int day) {
    return '$day';
  }

  @override
  String get dailyFeedingCount => 'Daily feeding count';

  @override
  String get dailyFeedingAmount => 'Daily feeding amount';

  @override
  String get dailyFeedingDuration => 'Daily feeding duration';

  @override
  String get dailySleepCount => 'Daily sleep count';

  @override
  String get dailySleepDuration => 'Daily sleep duration';

  @override
  String get dailyDiaperChangeCount => 'Daily diaper changes';

  @override
  String get dailyMedicationCount => 'Daily medication count';

  @override
  String get dailyMilkPumpingCount => 'Daily pumping count';

  @override
  String get dailyMilkPumpingAmount => 'Daily pumping amount';

  @override
  String get dailySolidFoodCount => 'Daily solid food count';

  @override
  String get dailyAverageSolidFoodCount => 'Daily average solid food count';

  @override
  String get triedFoodTypes => 'Types of food tried';

  @override
  String babyTemperatureRecord(String name) {
    return '$name의 체온 기록';
  }

  @override
  String get adjustWithSlider => '슬라이더로 조정';

  @override
  String get measurementMethod => '측정 방법';

  @override
  String get normalRange => '정상 범위';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return '정상 범위 ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => '체온 기록 저장';

  @override
  String get enterTemperature => '체온을 입력해주세요';

  @override
  String get temperatureRangeValidation => '체온은 34.0°C ~ 42.0°C 범위여야 합니다';

  @override
  String get recordSymptomsHint => '증상이나 특이사항을 기록해주세요';

  @override
  String get oralMethod => '구강';

  @override
  String get analMethod => '항문';

  @override
  String recentDaysTrend(int days) {
    return '최근 $days일간 추이';
  }

  @override
  String get days3 => '3일';

  @override
  String get days7 => '7일';

  @override
  String get weeks2 => '2주';

  @override
  String get month1 => '한달';

  @override
  String get noTemperatureRecordsInPeriod => '선택한 기간에 체온 기록이 없습니다';

  @override
  String get temperatureChangeTrend => '체온 변화 추이';

  @override
  String get averageTemperature => '평균 체온';

  @override
  String get highestTemperature => '최고 체온';

  @override
  String get lowestTemperature => '최저 체온';

  @override
  String get noteAvailableTapToView => '📝 메모 있음 (탭하여 보기)';

  @override
  String get temperatureRisingTrend => '체온이 상승하는 추세입니다';

  @override
  String get temperatureFallingTrend => '체온이 하강하는 추세입니다';

  @override
  String get temperatureStableTrend => '체온이 안정적입니다';

  @override
  String get trendAnalysis => '추세 분석';

  @override
  String totalMeasurements(int count) {
    return '총 $count회 측정됨';
  }

  @override
  String get temperatureRecordMemo => '체온 기록 메모';

  @override
  String babyGrowthChart(String name) {
    return '$name의 성장곡선';
  }

  @override
  String get noGrowthRecords => '성장 기록이 없습니다';

  @override
  String get enterWeightAndHeightFromHome => '홈 화면에서 체중과 키를 입력해보세요';

  @override
  String get all => '전체';

  @override
  String get growthInsights => '성장 인사이트';

  @override
  String get growthRate => '성장 속도';

  @override
  String get monthlyAverageGrowth => '월평균 성장';

  @override
  String get dataInsufficient => '데이터 부족';

  @override
  String get twoOrMoreRequired => '2개 이상 필요';

  @override
  String recentDaysBasis(int days) {
    return '최근 $days일 기준';
  }

  @override
  String get entireBasis => '전체 기준';

  @override
  String get oneMonthPrediction => '1개월 후 예상';

  @override
  String get currentTrendBasis => '현재 트렌드 기준';

  @override
  String get predictionNotPossible => '예측 불가';

  @override
  String get trendInsufficient => '트렌드 부족';

  @override
  String get recordFrequency => '기록 빈도';

  @override
  String get veryConsistent => '매우 꾸준함';

  @override
  String get consistent => '꾸준함';

  @override
  String get irregular => '불규칙';

  @override
  String averageDaysInterval(String days) {
    return '평균 $days일 간격';
  }

  @override
  String get nextRecord => '다음 기록';

  @override
  String get now => '지금';

  @override
  String get soon => '곧';

  @override
  String daysLater(int days) {
    return '$days일 후';
  }

  @override
  String daysAgoRecorded(int days) {
    return '$days일 전 기록됨';
  }

  @override
  String get weeklyRecordRecommended => '주간 기록 권장';

  @override
  String get nextMilestone => '다음 마일스톤';

  @override
  String targetValue(String value, String unit) {
    return '$value$unit 목표';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit 남음 ($progress% 달성)';
  }

  @override
  String get calculationNotPossible => '계산 불가';

  @override
  String get periodInsufficient => '기간 부족';

  @override
  String get noDataAvailable => '데이터 없음';

  @override
  String get weightRecordRequired => '체중 기록 필요';

  @override
  String get heightRecordRequired => '키 기록 필요';

  @override
  String get currentRecordMissing => '현재 기록 없음';

  @override
  String get noRecord => '기록 없음';

  @override
  String get firstRecordStart => '첫 기록을 시작하세요';

  @override
  String get oneRecord => '1회';

  @override
  String get moreRecordsNeeded => '더 많은 기록 필요';

  @override
  String get sameDayRecord => '당일 기록';

  @override
  String recordedTimes(int count) {
    return '$count회 기록';
  }

  @override
  String get storageMethod => '보관 방법';

  @override
  String get pumpingType => '유축 방식';

  @override
  String get foodName => '음식명';

  @override
  String get mealType => '식사 유형';

  @override
  String get texture => '질감';

  @override
  String get reaction => '반응';

  @override
  String get measurementLocation => '측정 부위';

  @override
  String get feverReducerGiven => '해열제 투약';

  @override
  String get given => '투약함';

  @override
  String get hours => '시간';

  @override
  String get refrigerator => '냉장고';

  @override
  String get freezer => '냉동고';

  @override
  String get roomTemperature => '실온';

  @override
  String get fedImmediately => '즉시 수유';

  @override
  String get breakfast => '아침';

  @override
  String get lunch => '점심';

  @override
  String get dinner => '저녁';

  @override
  String get snack => '간식';

  @override
  String get monday => '월요일';

  @override
  String get tuesday => '화요일';

  @override
  String get wednesday => '수요일';

  @override
  String get thursday => '목요일';

  @override
  String get friday => '금요일';

  @override
  String get saturday => '토요일';

  @override
  String get sunday => '일요일';

  @override
  String get on => '켬';

  @override
  String get off => '끔';

  @override
  String get weightChange => '체중 변화';

  @override
  String get heightChange => '키 변화';

  @override
  String get totalRecords => '총 기록';

  @override
  String get totalChange => '총 변화';

  @override
  String get start => '시작';

  @override
  String get memo => '메모';

  @override
  String get weightDataEmpty => '체중 데이터가 없습니다';

  @override
  String get heightDataEmpty => '키 데이터가 없습니다';

  @override
  String get undoAction => '실행 취소';

  @override
  String get feedingRecordDeleted => '수유 기록이 삭제되었습니다';

  @override
  String get sleepRecordDeleted => '수면 기록이 삭제되었습니다';

  @override
  String get diaperRecordDeleted => '기저귀 기록이 삭제되었습니다';

  @override
  String get healthRecordDeleted => '건강 기록이 삭제되었습니다';

  @override
  String get deletionError => '삭제 중 오류가 발생했습니다';

  @override
  String get duplicateInputDetected => '중복 입력 감지';

  @override
  String get solidFoodDuplicateConfirm =>
      '방금 전에 이유식을 기록하셨습니다.\\n정말로 다시 기록하시겠습니까?';

  @override
  String get cannotOpenSettings => '설정 화면을 열 수 없습니다';

  @override
  String get sleepQualityGood => '좋음';

  @override
  String get sleepQualityFair => '보통';

  @override
  String get sleepQualityPoor => '나쁨';

  @override
  String sleepInProgressDuration(Object minutes) {
    return '수면 중 - $minutes분 경과';
  }

  @override
  String get wetOnly => '소변만';

  @override
  String get dirtyOnly => '대변만';

  @override
  String get wetAndDirty => '소변 + 대변';

  @override
  String get colorLabel => '색상';

  @override
  String get consistencyLabel => '농도';

  @override
  String get topicalMedication => '외용';

  @override
  String get inhaledMedication => '흡입';

  @override
  String get milkPumpingInProgress => '유축 중';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return '유축 중 - $minutes분 경과';
  }

  @override
  String get lowGradeFever => '미열';

  @override
  String get normalTemperature => '정상';

  @override
  String get allActivities => '전체';

  @override
  String get temperatureFilter => '체온';

  @override
  String get deleteRecordTitle => '기록 삭제';

  @override
  String get deleteRecordMessage => '이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.';

  @override
  String get recordDeletedSuccess => '기록이 삭제되었습니다';

  @override
  String get recordDeleteFailed => '기록 삭제에 실패했습니다';

  @override
  String get recordDeleteError => '기록 삭제 중 오류가 발생했습니다';

  @override
  String get recordUpdatedSuccess => '기록이 수정되었습니다';

  @override
  String get recordUpdateFailed => '기록 수정에 실패했습니다';

  @override
  String get recordUpdateError => '기록 수정 중 오류가 발생했습니다';

  @override
  String noRecordsToday(Object recordType) {
    return '오늘 $recordType 기록이 없습니다';
  }

  @override
  String get healthRecordRestored => '건강 기록이 복원되었습니다';

  @override
  String get deleteTemperatureConfirm => '최근 체온 기록을 삭제하시겠습니까?';

  @override
  String get minimum => '최저';

  @override
  String get maximum => '최고';

  @override
  String get duplicateEntryDetected => '중복 입력 감지';

  @override
  String get feedingDuplicateConfirm =>
      '방금 전에 수유 기록을 추가하셨습니다.\\n정말로 다시 기록하시겠습니까?';

  @override
  String get milkPumpingDuplicateConfirm =>
      '방금 전에 유축 기록을 추가하셨습니다.\\n정말로 다시 기록하시겠습니까?';

  @override
  String get medicationDuplicateConfirm =>
      '방금 전에 투약을 기록하셨습니다.\\n정말로 다시 기록하시겠습니까?';

  @override
  String get diaperDuplicateConfirm =>
      '방금 전에 기저귀 교체를 기록하셨습니다.\\n정말로 다시 기록하시겠습니까?';

  @override
  String get sleepStartDuplicateConfirm =>
      '방금 전에 수면을 조작하셨습니다.\\n정말로 수면을 시작하시겠습니까?';

  @override
  String get sleepEndDuplicateConfirm =>
      '방금 전에 수면을 조작하셨습니다.\\n정말로 수면을 종료하시겠습니까?';

  @override
  String get recordAction => '기록하기';

  @override
  String get end => '종료';

  @override
  String get minutesShort => '분';
}
