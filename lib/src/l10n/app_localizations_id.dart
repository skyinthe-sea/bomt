// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get user => 'Pengguna';

  @override
  String userInfoLoadFailed(String error) {
    return 'Failed to load user info: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'An error occurred while loading the baby list: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Welcome, $nickname! 🎉';
  }

  @override
  String get registerBaby => 'Daftar Bayi';

  @override
  String get noBabiesRegistered => 'Tidak babies registered';

  @override
  String get registerFirstBaby => 'Daftar your first baby!';

  @override
  String get registerBabyButton => 'Daftar Bayi';

  @override
  String birthday(int year, int month, int day) {
    return 'Ulang Tahun: $year/$month/$day';
  }

  @override
  String age(int days) {
    return 'Umur: $days days';
  }

  @override
  String gender(String gender) {
    return 'Jenis Kelamin';
  }

  @override
  String get male => 'Laki-laki';

  @override
  String get female => 'Perempuan';

  @override
  String get other => 'Other';

  @override
  String babyDetailScreen(String name) {
    return '$name Detail Screen (Coming Soon)';
  }

  @override
  String get selectBirthdate => 'Please select birthdate';

  @override
  String babyRegistered(String name) {
    return '$name has been registered!';
  }

  @override
  String registrationError(String error) {
    return 'An error occurred during registration: $error';
  }

  @override
  String get enterBabyInfo => 'Please enter baby information';

  @override
  String get babyName => 'Bayi Nama';

  @override
  String get babyNameHint => 'e.g. Emma';

  @override
  String get babyNameRequired => 'Please enter baby\'s name';

  @override
  String get babyNameMinLength => 'Nama must be at least 2 characters';

  @override
  String get selectBirthdateButton => 'Select Birthdate';

  @override
  String selectedDate(int year, int month, int day) {
    return '$year/$month/$day';
  }

  @override
  String get genderOptional => 'Jenis Kelamin (Optional)';

  @override
  String get cancel => 'Batal';

  @override
  String get loginFailed => 'Masuk failed';

  @override
  String loginError(String error) {
    return 'An error occurred during login: $error';
  }

  @override
  String get appTagline => 'Easily manage your baby\'s growth records';

  @override
  String get termsNotice =>
      'By logging in, you agree to our Terms of Service and Privacy Policy';

  @override
  String get loginWithKakao => 'Masuk with Kakao';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Language';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Please enter baby\'s name';

  @override
  String get nameMinLength => 'Nama must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get appearance => 'Appearance';

  @override
  String get home => 'Beranda';

  @override
  String get timeline => 'Timeline';

  @override
  String get record => 'Rekam';

  @override
  String get statistics => 'Statistik';

  @override
  String get community => 'Community';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get timelineUpdateMessage => 'Timeline feature will be updated soon';

  @override
  String get recordUpdateMessage => 'Rekam feature will be updated soon';

  @override
  String get statisticsUpdateMessage =>
      'Statistik feature will be updated soon';

  @override
  String get communityUpdateMessage => 'Community feature will be updated soon';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get growthInfo => 'Pertumbuhan Info';

  @override
  String get lastFeeding => 'Terakhir Pemberian Makan';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Pemberian Makan';

  @override
  String get totalFeeding => 'Total Pemberian Makan';

  @override
  String get sleep => 'Tidur';

  @override
  String get totalSleepTime => 'Total Tidur Waktu';

  @override
  String get cardSettings => 'Card Pengaturan';

  @override
  String get cardSettingsGuide => 'Card Pengaturan Guide';

  @override
  String get cardSettingsDescription =>
      '• Toggle switches to show/hide cards • Drag to change card order • Changes are previewed in real-time';

  @override
  String get cardVisible => 'Visible';

  @override
  String get cardHidden => 'Hidden';

  @override
  String get save => 'Simpan';

  @override
  String get cardSettingsSaved => 'Card settings saved';

  @override
  String get cardSettingsError => 'Kesalahan occurred while saving settings';

  @override
  String get discardChanges => 'Discard changes and return to previous state?';

  @override
  String get continueEditing => 'Continue Editing';

  @override
  String get discardChangesExit => 'Exit without saving changes?';

  @override
  String get exit => 'Exit';

  @override
  String get diaper => 'Popok';

  @override
  String get solidFood => 'Solid Makanan';

  @override
  String get medication => 'Medication';

  @override
  String get milkPumping => 'Milk Pumping';

  @override
  String get temperature => 'Suhu';

  @override
  String get growth => 'Pertumbuhan';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Pemberian Makan Jumlah';

  @override
  String get feedingRecordAdded => 'Pemberian Makan record added successfully';

  @override
  String get feedingRecordFailed => 'Failed to add feeding record';

  @override
  String get feedingRecordsLoadFailed => 'Failed to load feeding records';

  @override
  String get quickFeeding => 'Quick Pemberian Makan';

  @override
  String get feedingTime => 'Pemberian Makan Waktu';

  @override
  String get feedingType => 'Feeding Type';

  @override
  String get breastfeeding => 'Breastfeeding';

  @override
  String get bottleFeeding => 'Bottle Pemberian Makan';

  @override
  String get mixedFeeding => 'Mixed Pemberian Makan';

  @override
  String sleepCount(Object count) {
    return '$count times';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get sleepStarted => 'Tidur started';

  @override
  String get sleepEnded => 'Tidur ended';

  @override
  String get sleepInProgress => 'Sleeping';

  @override
  String get sleepRecordFailed => 'Failed to process sleep record';

  @override
  String get sleepRecordsLoadFailed => 'Failed to load sleep records';

  @override
  String get sleepTime => 'Tidur Waktu';

  @override
  String get wakeUpTime => 'Wake Up Waktu';

  @override
  String get sleepDurationLabel => 'Tidur Durasi';

  @override
  String get napTime => 'Nap Waktu';

  @override
  String get nightSleep => 'Night Tidur';

  @override
  String diaperCount(Object count) {
    return '$count times';
  }

  @override
  String get diaperChanged => 'Popok changed';

  @override
  String get diaperRecordAdded => 'Popok change record added successfully';

  @override
  String get diaperRecordFailed => 'Failed to add diaper record';

  @override
  String get diaperRecordsLoadFailed => 'Failed to load diaper records';

  @override
  String get wetDiaper => 'Wet';

  @override
  String get dirtyDiaper => 'Dirty';

  @override
  String get bothDiaper => 'Both';

  @override
  String wetCount(Object count) {
    return 'Wet $count';
  }

  @override
  String dirtyCount(Object count) {
    return 'Dirty $count';
  }

  @override
  String bothCount(Object count) {
    return 'Both $count';
  }

  @override
  String get diaperType => 'Popok Jenis';

  @override
  String get diaperChangeTime => 'Change Waktu';

  @override
  String get weight => 'Berat';

  @override
  String get height => 'Tinggi';

  @override
  String get growthRecord => 'Pertumbuhan Rekam';

  @override
  String get growthRecordAdded => 'Pertumbuhan record added';

  @override
  String get growthRecordFailed => 'Failed to save growth record';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => 'Measurement Jenis';

  @override
  String get measurementValue => 'Value';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get temperatureRange => 'Suhu must be between 30.0°C and 45.0°C';

  @override
  String get weightRange => 'Berat must be between 0.1kg and 50kg';

  @override
  String get heightRange => 'Tinggi must be between 1cm and 200cm';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get recordGrowthInfo => 'Rekam Pertumbuhan Informasi';

  @override
  String currentMeasurement(Object type) {
    return 'Enter current $type';
  }

  @override
  String get measurementSituation =>
      'Rekam measurement situation or special notes (optional)';

  @override
  String get communityTitle => 'Community';

  @override
  String get writePost => 'Write Post';

  @override
  String get post => 'Post';

  @override
  String get postTitle => 'Post Title';

  @override
  String get postContent => 'Post Content';

  @override
  String get postTitleHint => 'Enter title';

  @override
  String get postContentHint =>
      'Enter content... Feel free to share your story.';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get postCreated => 'Post created successfully!';

  @override
  String postCreateFailed(Object error) {
    return 'Failed to create post: $error';
  }

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameSetup => 'Set up nickname';

  @override
  String get nicknameChange => 'Change nickname';

  @override
  String get nicknameHint => 'Enter nickname';

  @override
  String get nicknameDescription =>
      'Buat a nickname to use in the community. It will be displayed to other users.';

  @override
  String get nicknameChangeDescription => 'You can change to a new nickname.';

  @override
  String get nicknameValidation =>
      'Korean, English, numbers, underscore (_) allowed (2-20 characters)';

  @override
  String get nicknameMinLength => 'Nickname must be at least 2 characters';

  @override
  String get nicknameMaxLength => 'Nickname must be 20 characters or less';

  @override
  String get nicknameInvalidChars =>
      'Only Korean, English, numbers, and underscore (_) are allowed';

  @override
  String get nicknameChanged => 'Nickname changed successfully!';

  @override
  String get startButton => 'Get Started';

  @override
  String get changeButton => 'Change';

  @override
  String characterCount(Object count) {
    return 'Title: $count/200';
  }

  @override
  String contentCharacterCount(Object count) {
    return 'Content: $count/10000';
  }

  @override
  String imageCount(Object count) {
    return 'Images: $count/5';
  }

  @override
  String get addImages => 'Tambah Images';

  @override
  String imageSelectFailed(Object error) {
    return 'Gambar selection failed: $error';
  }

  @override
  String get featureInDevelopment => 'Feature in development';

  @override
  String get liveQA => '🔥 Pediatrician Live Q&A';

  @override
  String get liveQADescription =>
      'Today at 7 PM! Our specialists will answer all your questions';

  @override
  String get likeOrder => 'Most Liked';

  @override
  String get latestOrder => 'Latest';

  @override
  String get userNotFound => 'Pengguna information not found';

  @override
  String get statisticsTitle => 'Statistik';

  @override
  String get noStatisticsData => 'Tidak Statistik Data';

  @override
  String statisticsDescription(Object period) {
    return 'Tidak activities recorded during $period. Mulai recording your baby\'s activities!';
  }

  @override
  String get recordActivity => 'Rekam Activity';

  @override
  String get viewOtherPeriod => 'Lihat Other Period';

  @override
  String get refresh => 'Segarkan';

  @override
  String get statisticsTips => 'To view statistics?';

  @override
  String get statisticsTip1 =>
      'Rekam activities like feeding, sleep, diaper changes';

  @override
  String get statisticsTip2 =>
      'At least one day of data is required for statistics';

  @override
  String get statisticsTip3 => 'You can record easily from the home screen';

  @override
  String get saveAsImage => 'Simpan as Gambar';

  @override
  String get saveAsImageDescription => 'Simpan statistics as image';

  @override
  String get shareAsText => 'Bagikan as Text';

  @override
  String get shareAsTextDescription => 'Bagikan statistics summary as text';

  @override
  String get statisticsEmptyState => 'Tidak statistics data';

  @override
  String get retryButton => 'Try Again';

  @override
  String get detailsButton => 'Details';

  @override
  String get goHomeButton => 'Go Beranda';

  @override
  String get applyButton => 'Terapkan';

  @override
  String get lastWeek => 'Terakhir Week';

  @override
  String get lastMonth => 'Terakhir Month';

  @override
  String get last3Months => 'Terakhir 3 Months';

  @override
  String get allTime => 'All Waktu';

  @override
  String get viewOtherPeriodTitle => 'Lihat Other Period';

  @override
  String get familyInvitation => 'Family Invitation';

  @override
  String get invitationDescription =>
      'Manage baby records together with your family using invitation codes';

  @override
  String get createInvitation => 'Buat Invitation';

  @override
  String get invitationCreated => 'Invitation created successfully';

  @override
  String invitationCreateFailed(Object error) {
    return 'Failed to create invitation: $error';
  }

  @override
  String get invitationRole => 'Role';

  @override
  String get invitationDuration => 'Validity Period';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleCaregiver => 'Caregiver';

  @override
  String get roleGuardian => 'Guardian';

  @override
  String get roleParentDesc => 'Can manage all records as baby\'s parent';

  @override
  String get roleCaregiverDesc => 'Can manage some records as caregiver';

  @override
  String get roleGuardianDesc => 'Can view records as baby\'s guardian';

  @override
  String get invitationGuide => 'Invitation Guide';

  @override
  String get invitationGuideDesc =>
      'You can invite family members to manage baby records together. The invited person can participate through the invitation link after installing the app.';

  @override
  String get shareInvitation => 'Bagikan Invitation';

  @override
  String get shareImmediately => 'Bagikan Now';

  @override
  String get invitationPreview => 'Invitation Preview';

  @override
  String invitationExpiry(Object duration) {
    return 'Expires in $duration';
  }

  @override
  String get joinWithCode => 'Join with Invitation Code';

  @override
  String get invitationValidity => 'Invitation Validity Period';

  @override
  String get testMode =>
      'Test Mode: Creating invitation with temporary user information';

  @override
  String get ok => 'OK';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Hapus';

  @override
  String get add => 'Tambah';

  @override
  String get remove => 'Hapus';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Kembali';

  @override
  String get next => 'Selanjutnya';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Berhasil';

  @override
  String get warning => 'Peringatan';

  @override
  String get info => 'Informasi';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get networkError => 'Network connection error';

  @override
  String get serverError => 'Server error occurred';

  @override
  String get validationError => 'Please check your input';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String get saveFailed => 'Simpan failed';

  @override
  String get loadFailed => 'Load failed';

  @override
  String updateFailed(String error) {
    return 'Perbarui failed: $error';
  }

  @override
  String deleteFailed(String error) {
    return 'Hapus failed: $error';
  }

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
    return '${minutes}m';
  }

  @override
  String durationHours(Object hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String minutesAgo(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationDose => 'Dose';

  @override
  String get medicationTime => 'Medication';

  @override
  String get medicationAdded => 'Medication record added';

  @override
  String get solidFoodType => 'Makanan Jenis';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => 'Solid food record added';

  @override
  String get milkPumpingAmount => 'Pumping Jumlah';

  @override
  String get milkPumpingTime => 'Pumping Waktu';

  @override
  String get milkPumpingAdded => 'Milk pumping record added';

  @override
  String get temperatureReading => 'Suhu Reading';

  @override
  String get temperatureNormal => 'Normal';

  @override
  String get temperatureHigh => 'Tinggi';

  @override
  String get temperatureLow => 'Rendah';

  @override
  String get profilePhoto => 'Profile Foto';

  @override
  String get profilePhotoUpdate => 'Perbarui Profile Foto';

  @override
  String get selectPhotoSource => 'How would you like to select a photo?';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get photoUpdated => 'Profile photo updated';

  @override
  String get photoUploadFailed => 'Profile photo update failed';

  @override
  String get photoUploading => 'Uploading photo...';

  @override
  String get cameraNotAvailable =>
      'Kamera not available on iOS simulator. Please try from gallery.';

  @override
  String get cameraAccessError =>
      'Kamera access error occurred. Please try from gallery.';

  @override
  String get addImage => 'Tambah Gambar';

  @override
  String get removeImage => 'Hapus Gambar';

  @override
  String maxImagesReached(Object count) {
    return 'Maximum $count images allowed';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$months months $days days';
  }

  @override
  String get lastFeedingTime => 'Terakhir feeding time';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours hours $minutes minutes ago';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return 'Selanjutnya feeding in about ${hours}h ${minutes}m';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return 'Selanjutnya feeding in about $minutes minutes';
  }

  @override
  String get feedingTimeNow => 'It\'s feeding time now 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'Pemberian Makan time soon ($minutes minutes)';
  }

  @override
  String get feedingTimeOverdue => 'Pemberian Makan time overdue';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return 'Pemberian Makan alarm in ${hours}h ${minutes}m';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return 'Pemberian Makan alarm in $minutes minutes';
  }

  @override
  String get times => 'times';

  @override
  String get meals => 'meals';

  @override
  String get kilograms => 'kg';

  @override
  String get centimeters => 'cm';

  @override
  String get milliliters => 'ml';

  @override
  String get grams => 'g';

  @override
  String get hoursUnit => 'hours';

  @override
  String get minutesUnit => 'minutes';

  @override
  String get viewDetails => 'Lihat Details';

  @override
  String get firstRecord => 'Pertama Rekam';

  @override
  String get noChange => 'Tidak Change';

  @override
  String get inProgress => 'In Progress';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get startBabyRecording => 'Daftar your baby and start tracking growth';

  @override
  String get registerBabyNow => 'Daftar Bayi';

  @override
  String get joinWithInviteCode => 'Join with Invitation Code';

  @override
  String get loadingBabyInfo => 'Loading baby information...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Go to Pengaturan';

  @override
  String get profilePhotoUpdated => 'Profile photo has been updated.';

  @override
  String get profilePhotoUpdateFailed => 'Failed to update profile photo';

  @override
  String diaperWetAndDirty(Object count) {
    return 'Wet+Dirty $count times';
  }

  @override
  String diaperWetAndDirtySeparate(Object dirtyCount, Object wetCount) {
    return 'Wet $wetCount, Dirty $dirtyCount';
  }

  @override
  String get sleepZeroHours => '0 hours';

  @override
  String solidFoodMeals(Object count) {
    return '$count meals';
  }

  @override
  String medicationScheduled(Object count) {
    return 'Tentang $count times';
  }

  @override
  String medicationTypes(Object vaccineCount, Object vitaminCount) {
    return 'Vitamins $vitaminCount, Vaccines $vaccineCount';
  }

  @override
  String get feedingRecordAddFailed => 'Failed to add feeding record';

  @override
  String get diaperRecordAddFailed => 'Failed to add diaper record';

  @override
  String get sleepRecordProcessFailed => 'Failed to process sleep record';

  @override
  String get hourActivityPattern => '24-Hour Activity Pattern';

  @override
  String get touchClockInstruction =>
      'Touch the clock to check activities by time period';

  @override
  String get touch => 'Touch';

  @override
  String get noActivitiesInTimeframe => 'Tidak activities during this time';

  @override
  String get activityPatternAnalysis => 'Activity Pattern Analysis';

  @override
  String get todaysStory => 'Today\'s Story';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Rekam your first precious moment. Small daily changes add up to great growth.';

  @override
  String get pattern => 'Pattern';

  @override
  String get qualityGood => 'Baik';

  @override
  String get qualityExcellent => 'Excellent';

  @override
  String get qualityFair => 'Fair';

  @override
  String get qualityPoor => 'Poor';

  @override
  String get timeSlot => 'o\'clock time slot';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get activityConcentrationTime =>
      'Times of concentrated activity throughout the day';

  @override
  String get formula => 'Formula';

  @override
  String get breastMilk => 'Breast Milk';

  @override
  String get babyFood => 'Bayi Makanan';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get both => 'Both';

  @override
  String get sleeping => 'Sleeping';

  @override
  String get hoursText => 'hours';

  @override
  String get minutesText => 'minutes';

  @override
  String get elapsed => 'elapsed';

  @override
  String get urineOnly => 'Urine only';

  @override
  String get stoolOnly => 'Stool only';

  @override
  String get urineAndStool => 'Urine + Stool';

  @override
  String get color => 'Color';

  @override
  String get consistency => 'Consistency';

  @override
  String get diaperChange => 'Popok Change';

  @override
  String get oralMedication => 'Oral Medication';

  @override
  String get topical => 'Topical';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Suhu Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Rendah Fever';

  @override
  String get hypothermia => 'Hypothermia';

  @override
  String get normal => 'Normal';

  @override
  String get quality => 'Quality';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get custom => 'Custom';

  @override
  String daysCount(Object count) {
    return '$count days';
  }

  @override
  String noActivitiesRecordedInPeriod(Object period) {
    return 'Tidak activities were recorded during $period.';
  }

  @override
  String get recordBabyActivities => 'Rekam your baby\'s activities!';

  @override
  String get howToViewStatistics => 'How to view statistics?';

  @override
  String get recordActivitiesLikeFeedingSleep =>
      'Rekam activities like feeding, sleep, diaper changes, etc.';

  @override
  String get atLeastOneDayDataRequired =>
      'At least one day of data is required to display statistics.';

  @override
  String get canRecordEasilyFromHome =>
      'You can easily record activities from the home screen.';

  @override
  String get updating => 'Updating...';

  @override
  String get lastUpdated => 'Terakhir updated:';

  @override
  String get periodSelection => 'Period selection:';

  @override
  String get daily => 'Daily';

  @override
  String get startDate => 'Mulai Tanggal';

  @override
  String get endDate => 'Selesai Tanggal';

  @override
  String get apply => 'Terapkan';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get detailedStatistics => 'Detailed Statistik';

  @override
  String get chartAnalysis => 'Bagan Analysis';

  @override
  String get overallActivityOverview => 'Overall Activity Overview';

  @override
  String get totalActivities => 'Total Activities';

  @override
  String get activeCards => 'Active Cards';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get details => 'Details';

  @override
  String get goToHome => 'Go to Beranda';

  @override
  String get troubleshootingMethods => 'Troubleshooting Methods';

  @override
  String get shareStatistics => 'Bagikan Statistik';

  @override
  String get communitySubtitle => 'Sharing Parenting Stories Together';

  @override
  String get search => 'Cari';

  @override
  String get notification => 'Notification';

  @override
  String get searchFeatureComingSoon => 'Cari feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Bagikan parenting experiences and valuable information with other parents';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryPopular => 'Popular';

  @override
  String get categoryClinical => 'Clinical';

  @override
  String get categoryInfoSharing => 'Info Sharing';

  @override
  String get categorySleepIssues => 'Tidur Issues';

  @override
  String get categoryBabyFood => 'Bayi Makanan';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categoryVaccination => 'Vaccination';

  @override
  String get categoryPostpartum => 'Postpartum';

  @override
  String get sortByLikes => 'Urutkan by Likes';

  @override
  String get sortByLatest => 'Urutkan by Latest';

  @override
  String get edited => '(edited)';

  @override
  String commentsCount(int count) {
    return '$count comments';
  }

  @override
  String get deletePost => 'Hapus Post';

  @override
  String get deletePostConfirm =>
      'Are you sure you want to delete this post? Deleted posts cannot be recovered.';

  @override
  String get deletePostSuccess => 'Post has been deleted.';

  @override
  String deletePostError(Object error) {
    return 'Hapus failed: $error';
  }

  @override
  String get postNotFound => 'Post not found';

  @override
  String get shareFeatureComingSoon => 'Bagikan feature coming soon';

  @override
  String get loadingComments => 'Loading comments...';

  @override
  String get loadMoreComments => 'Load More Comments';

  @override
  String get editComment => 'Edit Comment';

  @override
  String get editCommentHint => 'Edit your comment...';

  @override
  String get editCommentSuccess => 'Comment has been updated.';

  @override
  String editCommentError(Object error) {
    return 'Edit failed: $error';
  }

  @override
  String get deleteComment => 'Hapus Comment';

  @override
  String get deleteCommentConfirm =>
      'Are you sure you want to delete this comment? Deleted comments cannot be recovered.';

  @override
  String get deleteCommentSuccess => 'Comment has been deleted.';

  @override
  String get replySuccess => 'Reply has been posted.';

  @override
  String get commentSuccess => 'Comment has been posted.';

  @override
  String get commentError => 'Failed to post comment.';

  @override
  String get titlePlaceholder => 'Enter title';

  @override
  String get contentPlaceholder =>
      'Bagikan your thoughts... Feel free to write about your parenting experiences.';

  @override
  String imageSelectionError(Object error) {
    return 'Gambar selection failed: $error';
  }

  @override
  String get userNotFoundError => 'Pengguna information not found.';

  @override
  String get postCreateSuccess => 'Post has been created successfully!';

  @override
  String postCreateError(Object error) {
    return 'Post creation failed: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Title: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Images: $count/5';
  }

  @override
  String get addImageTooltip => 'Tambah Gambar';

  @override
  String get allPostsChecked => 'All posts have been checked! 👍';

  @override
  String get waitForNewPosts => 'Please wait until new posts are uploaded';

  @override
  String get noPostsYet => 'Tidak posts yet';

  @override
  String get writeFirstPost => 'Write the first post!';

  @override
  String get loadingNewPosts => 'Loading new posts...';

  @override
  String get failedToLoadPosts => 'Failed to load posts';

  @override
  String get checkNetworkAndRetry =>
      'Please check your network connection and try again';

  @override
  String get categoryDailyLife => 'Daily Life';

  @override
  String get preparingTimeline => 'Preparing timeline...';

  @override
  String get noRecordedMoments => 'Tidak recorded moments yet';

  @override
  String get loadingTimeline => 'Loading timeline...';

  @override
  String get noRecordsYet => 'Tidak records yet';

  @override
  String noRecordsForDate(Object date) {
    return 'Tidak records for $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Tidak $filter records for $date';
  }

  @override
  String get cannotRecordFuture => 'Cannot record future activities yet';

  @override
  String get addFirstRecord => 'Tambah your first record!';

  @override
  String get canAddPastRecord => 'You can add past records';

  @override
  String get addRecord => 'Tambah Rekam';

  @override
  String get viewOtherDates => 'Lihat Other Dates';

  @override
  String get goToToday => 'Go to Today';

  @override
  String get quickRecordFromHome =>
      'You can quickly add records from the home screen';

  @override
  String detailViewComingSoon(String title) {
    return '$title Details (Coming Soon)';
  }

  @override
  String get familyInvitationDescription =>
      'Manage baby care records together with family using invitation codes';

  @override
  String get babyManagement => 'Bayi Management';

  @override
  String get addBaby => 'Tambah Bayi';

  @override
  String get noBabiesMessage => 'Tidak babies registered. Please add a baby.';

  @override
  String get switchToNextBaby => 'Switch to Selanjutnya Bayi';

  @override
  String get birthDate => 'Birth Tanggal';

  @override
  String get registering => 'Registering...';

  @override
  String get register => 'Daftar';

  @override
  String careTogetherWith(String name) {
    return 'Take care of babies together with $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Invite family or partners to manage baby care records together';

  @override
  String get generateInviteCode => 'Generate Invitation Code';

  @override
  String get generateInviteCodeDescription =>
      'Generate a new invitation code and copy it';

  @override
  String get generateInviteCodeButton => 'Generate Invitation Code';

  @override
  String get orText => 'Or';

  @override
  String get enterInviteCodeDescription =>
      'Please enter the invitation code you received';

  @override
  String get inviteCodePlaceholder => 'Invitation Code (6 digits)';

  @override
  String get acceptInvite => 'Terima Invitation';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name has been registered successfully';
  }

  @override
  String get babyRegistrationFailed => 'Bayi registration failed';

  @override
  String babyRegistrationError(String error) {
    return 'Kesalahan occurred: $error';
  }

  @override
  String babySelected(String name) {
    return '$name has been selected';
  }

  @override
  String get inviteCodeGeneratedStatus => 'Invitation code generated!';

  @override
  String remainingTime(String time) {
    return 'Remaining time: $time';
  }

  @override
  String get validTime => 'Valid time: 5 minutes';

  @override
  String get generating => 'Generating...';

  @override
  String get joining => 'Joining...';

  @override
  String get noBabyInfo => 'Tidak Bayi Informasi';

  @override
  String get noBabyInfoDescription =>
      'Tidak baby information found. Would you like to create a test baby?';

  @override
  String get create => 'Buat';

  @override
  String get generateNewInviteCode => 'Generate New Invitation Code';

  @override
  String get replaceExistingCode =>
      'This will replace the existing invitation code. Do you want to continue?';

  @override
  String get acceptInvitation => 'Terima Invitation';

  @override
  String get acceptInvitationDescription =>
      'Do you want to accept the invitation and join the family?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Existing baby records will be deleted and replaced with the invited baby ($babyName). Do you want to continue?';
  }

  @override
  String get pleaseEnterInviteCode => 'Please enter the invitation code';

  @override
  String get inviteCodeMustBe6Digits => 'Invitation code must be 6 digits';

  @override
  String get pleaseLoginFirst =>
      'Tidak login information found. Please login first.';

  @override
  String get copiedToClipboard => 'Invitation code copied to clipboard!';

  @override
  String get joinedSuccessfully => 'Successfully joined the family!';

  @override
  String get inviteCodeExpired =>
      'The invitation code has expired. Please create a new one.';

  @override
  String get invalidInviteCode => 'Invalid invitation code';

  @override
  String get alreadyMember => 'You are already a member of this family';

  @override
  String get cannotInviteSelf => 'You cannot invite yourself';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return '$name\'s Bayi Care Guide';
  }

  @override
  String get babyGuide => 'Bayi Care Guide';

  @override
  String get noAvailableGuides => 'Tidak available guides';

  @override
  String get current => 'Current';

  @override
  String get past => 'Past';

  @override
  String get upcoming => 'Upcoming';

  @override
  String babysGuide(String name) {
    return '$name\'s';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText Guide';
  }

  @override
  String get feedingGuide => '💡 Pemberian Makan Guide';

  @override
  String get feedingFrequency => 'Pemberian Makan Frequency';

  @override
  String get singleFeedingAmount => 'Pemberian Makan Jumlah';

  @override
  String get dailyTotal => 'Daily Total';

  @override
  String get additionalTips => '📋 Additional Tips';

  @override
  String get understood => 'Got it!';

  @override
  String get newborn => 'Newborn';

  @override
  String weekNumber(int number) {
    return 'Week $number';
  }

  @override
  String get newbornWeek0 => 'Newborn (Week 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Daily $min - $max times';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Daily $min+ times';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Daily up to $max times';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml or more';
  }

  @override
  String amountMaxML(int max) {
    return 'Up to ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'Tidak recent feeding records';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get searchCommunityPosts => 'Cari community posts';

  @override
  String get temperatureRecord => 'Suhu Rekam';

  @override
  String get temperatureTrend => 'Suhu Trend';

  @override
  String get profilePhotoSetup => 'Profile Foto Setup';

  @override
  String get howToSelectPhoto => 'How would you like to select a photo?';

  @override
  String get send => 'Kirim';

  @override
  String get emailVerificationRequired => 'Email Verification Required';

  @override
  String get passwordReset => 'Kata Sandi Reset';

  @override
  String get enterEmailForReset =>
      'Enter your registered email address. We\'ll send you a password reset link.';

  @override
  String get accountWithdrawalComplete => 'Account Withdrawal Lengkap';

  @override
  String get genderLabel => 'Jenis Kelamin:';

  @override
  String get birthdateLabel => 'Birthdate:';

  @override
  String get maleGender => 'Laki-laki';

  @override
  String get femaleGender => 'Perempuan';

  @override
  String get joinWithInviteCodeButton => 'Join with Invite Code';

  @override
  String get temperatureRecorded => 'Suhu recorded';

  @override
  String recordFailed(String error) {
    return 'Rekam failed';
  }

  @override
  String get temperatureSettingsSaved => 'Temperature settings saved';

  @override
  String get loadingUserInfo =>
      'Loading user information. Please try again in a moment.';

  @override
  String get continueWithSeparateAccount => 'Continue with separate account';

  @override
  String get linkWithExistingAccount => 'Link with existing account';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get accountLinkingComplete => 'Account Linking Lengkap';

  @override
  String get deleteConfirmation => 'Hapus Confirmation';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Kata Sandi';

  @override
  String get babyNameLabel => 'Bayi Nama';

  @override
  String get weightInput => 'Enter weight';

  @override
  String get heightInput => 'Enter height';

  @override
  String get measurementNotes =>
      'Rekam measurement conditions or special notes (optional)';

  @override
  String get urine => 'Urine';

  @override
  String get stool => 'Stool';

  @override
  String get yellow => 'Yellow';

  @override
  String get brown => 'Brown';

  @override
  String get green => 'Green';

  @override
  String get bottle => 'Bottle';

  @override
  String get good => 'Baik';

  @override
  String get average => 'Average';

  @override
  String get poor => 'Poor';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get illness => 'Illness';

  @override
  String get highFever => 'Tinggi Fever';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhalation';

  @override
  String get injection => 'Injection';

  @override
  String get tablet => 'Tablet';

  @override
  String get drops => 'Drops';

  @override
  String get teaspoon => 'Teaspoon';

  @override
  String get tablespoon => 'Tablespoon';

  @override
  String get sleepQuality => 'Sleep Quality';

  @override
  String get pumpingTime => 'Pumping';

  @override
  String get solidFoodTime => 'Solid Makanan';

  @override
  String get totalFeedingAmount => 'Total feeding amount';

  @override
  String get averageFeedingAmount => 'Average feeding amount';

  @override
  String get dailyAverageFeedingCount => 'Daily average feeding count';

  @override
  String get clinical => 'Clinical';

  @override
  String get infoSharing => 'Info Sharing';

  @override
  String get sleepIssues => 'Tidur Issues';

  @override
  String get babyFoodCategory => 'Bayi Makanan';

  @override
  String get developmentStage => 'Development Stage';

  @override
  String get vaccinationCategory => 'Vaccination';

  @override
  String get postpartumRecovery => 'Postpartum Recovery';

  @override
  String get dailyLife => 'Daily Life';

  @override
  String get likes => 'Likes';

  @override
  String get comments => 'Comments';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get minutes => 'min';

  @override
  String get armpit => 'Armpit';

  @override
  String get forehead => 'Forehead';

  @override
  String get ear => 'Ear';

  @override
  String get mouth => 'Mouth';

  @override
  String get rectal => 'Rectal';

  @override
  String get otherLocation => 'Other';

  @override
  String get searchError => 'Cari error';

  @override
  String get question => 'Question';

  @override
  String get information => 'Informasi';

  @override
  String get relevance => 'Relevance';

  @override
  String get searchSuggestions => 'Cari suggestions';

  @override
  String get noSearchResults => 'Tidak search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get likeFeatureComingSoon => 'Like feature coming soon';

  @override
  String get popularSearchTerms => 'Popular search terms';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get deleteAll => 'Hapus All';

  @override
  String get sortByComments => 'Urutkan by comments';

  @override
  String get detailInformation => 'Detail Informasi';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recordAgain => 'Rekam Again';

  @override
  String get share => 'Bagikan';

  @override
  String get deleteRecord => 'Hapus Rekam';

  @override
  String get deleteRecordConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get recordDeleted => 'Rekam deleted';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get editRecord => 'Edit Rekam';

  @override
  String get dateTime => 'Tanggal & Waktu';

  @override
  String get date => 'Tanggal';

  @override
  String get time => 'Waktu';

  @override
  String get amount => 'Jumlah';

  @override
  String get duration => 'Durasi';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'Side';

  @override
  String get fair => 'Fair';

  @override
  String get wet => 'Wet';

  @override
  String get dirty => 'Dirty';

  @override
  String get location => 'Location';

  @override
  String get notesHint => 'Enter additional notes...';

  @override
  String get saveChanges => 'Simpan Changes';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get smartInsights => 'Smart Insights';

  @override
  String get analyzingPatterns => 'Analyzing patterns...';

  @override
  String insightsFound(int count) {
    return '$count insights found';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'Confidence';

  @override
  String sleepProgressMinutes(int minutes) {
    return '$minutes minutes in progress';
  }

  @override
  String get sleepProgressTime => 'Tidur Progress Waktu';

  @override
  String get standardFeedingTimeNow => 'It\'s standard feeding time';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return 'Standard feeding time coming soon ($minutes minutes)';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '$hours hours $minutes minutes until standard feeding';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '$minutes minutes until standard feeding';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      'Insufficient feeding records (applying standard interval)';

  @override
  String get standardFeedingTimeOverdue => 'Standard feeding time is overdue';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes minutes';
  }

  @override
  String personalPatternInfo(String interval) {
    return 'Personal pattern: $interval interval (for reference)';
  }

  @override
  String get longPressForDetails => 'Long press for details';

  @override
  String get todaysSummary => 'Today\'s Summary';

  @override
  String get future => 'Future';

  @override
  String get previousDate => 'Sebelumnya date';

  @override
  String get nextDate => 'Selanjutnya date';

  @override
  String get selectDate => 'Select date';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'Please register your baby';

  @override
  String get registerBabyToRecordMoments =>
      'To record your baby\'s precious moments, please register baby information first.';

  @override
  String get addBabyFromHome => 'Tambah baby from home';

  @override
  String get timesUnit => 'times';

  @override
  String get itemsUnit => 'items';

  @override
  String get timesPerDay => 'times/day';

  @override
  String get activityDistributionByCategory =>
      'Activity Distribution by Category';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get totalCount => 'Total count';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String get noDetailedData => 'Tidak detailed data';

  @override
  String get averageFeedingTime => 'Average feeding time';

  @override
  String get averageSleepTime => 'Average sleep time';

  @override
  String get dailyAverageTotalSleepTime => 'Daily average total sleep time';

  @override
  String get dailyAverageSleepCount => 'Daily average sleep count';

  @override
  String get dailyAverageChangeCount => 'Daily average change count';

  @override
  String get sharingParentingStories => 'Sharing Parenting Stories';

  @override
  String get myActivity => 'My Activity';

  @override
  String get categories => 'Categories';

  @override
  String get menu => 'Menu';

  @override
  String get seeMore => 'See More';

  @override
  String get midnight => 'Midnight';

  @override
  String get morning => 'AM';

  @override
  String get noon => 'Noon';

  @override
  String get afternoon => 'PM';

  @override
  String get quickSelection => 'Quick Selection';

  @override
  String get customSettings => 'Custom Pengaturan';

  @override
  String get selectDateRange => 'Select Tanggal Range';

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
  String get savingError => 'An error occurred while saving';

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
    return 'Do you want to join $familyName\'s family? Existing baby data will be moved to the new family group.';
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
  String get feedingTimeNotificationBody => 'Bayi might be hungry now.';

  @override
  String get feedingAlarmChannelName => 'Pemberian Makan Reminders';

  @override
  String get feedingAlarmChannelDescription =>
      'Pemberian Makan time reminder notifications';

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
  String get durationTab => 'Durasi';

  @override
  String get chartDataLoading => 'Loading chart data...';

  @override
  String get chartDataNotAvailable => 'Bagan data not available.';

  @override
  String get averageLabel => 'Average:';

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
    return '$name\'s Suhu Rekam';
  }

  @override
  String get adjustWithSlider => 'Adjust with slider';

  @override
  String get measurementMethod => 'Measurement method';

  @override
  String get normalRange => 'Normal range';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Normal range ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Simpan Suhu Rekam';

  @override
  String get enterTemperature => 'Please enter temperature';

  @override
  String get temperatureRangeValidation =>
      'Suhu must be between 34.0°C ~ 42.0°C';

  @override
  String get recordSymptomsHint => 'Please record symptoms or special notes';

  @override
  String get oralMethod => 'Oral';

  @override
  String get analMethod => 'Anal';

  @override
  String recentDaysTrend(int days) {
    return 'Recent $days days trend';
  }

  @override
  String get days3 => '3 days';

  @override
  String get days7 => '7 days';

  @override
  String get weeks2 => '2 weeks';

  @override
  String get month1 => '1 month';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Tidak temperature records in selected period';

  @override
  String get temperatureChangeTrend => 'Suhu Change Trend';

  @override
  String get averageTemperature => 'Average Suhu';

  @override
  String get highestTemperature => 'Highest Suhu';

  @override
  String get lowestTemperature => 'Lowest Suhu';

  @override
  String get noteAvailableTapToView => '📝 Note available (tap to view)';

  @override
  String get temperatureRisingTrend => 'Suhu is showing a rising trend';

  @override
  String get temperatureFallingTrend => 'Suhu is showing a falling trend';

  @override
  String get temperatureStableTrend => 'Suhu is stable';

  @override
  String get trendAnalysis => 'Trend Analysis';

  @override
  String totalMeasurements(int count) {
    return 'Total $count measurements';
  }

  @override
  String get temperatureRecordMemo => 'Suhu Rekam Memo';

  @override
  String babyGrowthChart(String name) {
    return '$name\'s Pertumbuhan Bagan';
  }

  @override
  String get noGrowthRecords => 'Tidak growth records';

  @override
  String get enterWeightAndHeightFromHome =>
      'Please enter weight and height from home screen';

  @override
  String get all => 'All';

  @override
  String get growthInsights => 'Pertumbuhan Insights';

  @override
  String get growthRate => 'Pertumbuhan Rate';

  @override
  String get monthlyAverageGrowth => 'Monthly Average Pertumbuhan';

  @override
  String get dataInsufficient => 'Data Insufficient';

  @override
  String get twoOrMoreRequired => '2 or more required';

  @override
  String recentDaysBasis(int days) {
    return 'Based on recent $days days';
  }

  @override
  String get entireBasis => 'Based on entire period';

  @override
  String get oneMonthPrediction => '1 Month Prediction';

  @override
  String get currentTrendBasis => 'Based on current trend';

  @override
  String get predictionNotPossible => 'Prediction not possible';

  @override
  String get trendInsufficient => 'Trend insufficient';

  @override
  String get recordFrequency => 'Rekam Frequency';

  @override
  String get veryConsistent => 'Very Consistent';

  @override
  String get consistent => 'Consistent';

  @override
  String get irregular => 'Irregular';

  @override
  String averageDaysInterval(String days) {
    return 'Average $days days interval';
  }

  @override
  String get nextRecord => 'Selanjutnya Rekam';

  @override
  String get now => 'Now';

  @override
  String get soon => 'Soon';

  @override
  String daysLater(int days) {
    return '$days days later';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Recorded $days days ago';
  }

  @override
  String get weeklyRecordRecommended => 'Weekly record recommended';

  @override
  String get nextMilestone => 'Selanjutnya Milestone';

  @override
  String targetValue(String value, String unit) {
    return '$value$unit target';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit remaining ($progress% achieved)';
  }

  @override
  String get calculationNotPossible => 'Calculation not possible';

  @override
  String get periodInsufficient => 'Period insufficient';

  @override
  String get noDataAvailable => 'Tidak data available';

  @override
  String get weightRecordRequired => 'Berat record required';

  @override
  String get heightRecordRequired => 'Tinggi record required';

  @override
  String get currentRecordMissing => 'Current record missing';

  @override
  String get noRecord => 'Tidak record';

  @override
  String get firstRecordStart => 'Mulai your first record';

  @override
  String get oneRecord => '1 record';

  @override
  String get moreRecordsNeeded => 'More records needed';

  @override
  String get sameDayRecord => 'Same day record';

  @override
  String recordedTimes(int count) {
    return '$count times recorded';
  }

  @override
  String get storageMethod => 'Storage Method';

  @override
  String get pumpingType => 'Pumping Jenis';

  @override
  String get foodName => 'Food Name';

  @override
  String get mealType => 'Meal Jenis';

  @override
  String get texture => 'Texture';

  @override
  String get reaction => 'Reaction';

  @override
  String get measurementLocation => 'Measurement Location';

  @override
  String get feverReducerGiven => 'Fever Reducer Given';

  @override
  String get given => 'Given';

  @override
  String get hours => 'hours';

  @override
  String get refrigerator => 'Refrigerator';

  @override
  String get freezer => 'Freezer';

  @override
  String get roomTemperature => 'Room Temperature';

  @override
  String get fedImmediately => 'Fed Immediately';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get on => 'Aktif';

  @override
  String get off => 'Nonaktif';

  @override
  String get weightChange => 'Berat Change';

  @override
  String get heightChange => 'Tinggi Change';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get totalChange => 'Total Change';

  @override
  String get start => 'Mulai';

  @override
  String get memo => 'Memo';

  @override
  String get weightDataEmpty => 'Tidak weight data available';

  @override
  String get heightDataEmpty => 'Tidak height data available';

  @override
  String get undoAction => 'Undo';

  @override
  String get feedingRecordDeleted => 'Pemberian Makan record deleted';

  @override
  String get sleepRecordDeleted => 'Tidur record deleted';

  @override
  String get diaperRecordDeleted => 'Popok record deleted';

  @override
  String get healthRecordDeleted => 'Health record deleted';

  @override
  String get deletionError => 'Kesalahan occurred during deletion';

  @override
  String get duplicateInputDetected => 'Duplicate input detected';

  @override
  String get solidFoodDuplicateConfirm =>
      'You just recorded solid food.\\nDo you really want to record it again?';

  @override
  String get cannotOpenSettings => 'Cannot open settings screen';

  @override
  String get sleepQualityGood => 'Good';

  @override
  String get sleepQualityFair => 'Fair';

  @override
  String get sleepQualityPoor => 'Poor';

  @override
  String sleepInProgressDuration(Object minutes) {
    return 'Sleeping - ${minutes}m elapsed';
  }

  @override
  String get wetOnly => 'Wet Only';

  @override
  String get dirtyOnly => 'Dirty Only';

  @override
  String get wetAndDirty => 'Wet + Dirty';

  @override
  String get colorLabel => 'Color';

  @override
  String get consistencyLabel => 'Consistency';

  @override
  String get topicalMedication => 'Topical';

  @override
  String get inhaledMedication => 'Inhaled';

  @override
  String get milkPumpingInProgress => 'Pumping';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return 'Pumping - ${minutes}m elapsed';
  }

  @override
  String get lowGradeFever => 'Rendah Grade Fever';

  @override
  String get normalTemperature => 'Temperature is normal';

  @override
  String get allActivities => 'All';

  @override
  String get temperatureFilter => 'Suhu';

  @override
  String get deleteRecordTitle => 'Hapus Rekam';

  @override
  String get deleteRecordMessage =>
      'Are you sure you want to delete this record? Deleted records cannot be recovered.';

  @override
  String get recordDeletedSuccess => 'Rekam has been deleted';

  @override
  String get recordDeleteFailed => 'Failed to delete record';

  @override
  String get recordDeleteError => 'An error occurred while deleting the record';

  @override
  String get recordUpdatedSuccess => 'Rekam has been updated';

  @override
  String get recordUpdateFailed => 'Failed to update record';

  @override
  String get recordUpdateError => 'An error occurred while updating the record';

  @override
  String noRecordsToday(Object recordType) {
    return 'Tidak $recordType records today';
  }

  @override
  String get healthRecordRestored => 'Health record has been restored';

  @override
  String get deleteTemperatureConfirm =>
      'Do you want to delete the recent temperature record?';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get duplicateEntryDetected => 'Duplicate Entry Detected';

  @override
  String get feedingDuplicateConfirm =>
      'You just added a feeding record.\\nDo you really want to record again?';

  @override
  String get milkPumpingDuplicateConfirm =>
      'You just added a milk pumping record.\\nDo you really want to record again?';

  @override
  String get medicationDuplicateConfirm =>
      'You just recorded medication.\\nDo you really want to record again?';

  @override
  String get diaperDuplicateConfirm =>
      'You just recorded a diaper change.\\nDo you really want to record again?';

  @override
  String get sleepStartDuplicateConfirm =>
      'You just manipulated sleep.\\nDo you really want to start sleeping?';

  @override
  String get sleepEndDuplicateConfirm =>
      'You just manipulated sleep.\\nDo you really want to end sleeping?';

  @override
  String get recordAction => 'Rekam';

  @override
  String get end => 'Selesai';

  @override
  String get whatTypeChanged => 'What type did you change?';

  @override
  String get poop => 'Poop';

  @override
  String get urinePoop => 'Urine+Poop';

  @override
  String get changeType => 'Change Jenis';

  @override
  String get colorWhenPoop => 'Color (When Poop)';

  @override
  String get minutesShort => 'm';

  @override
  String get totalFeedingDuration => 'Total feeding duration';

  @override
  String get maximumFeedingAmount => 'Maximum feeding amount';

  @override
  String get minimumFeedingAmount => 'Minimum feeding amount';

  @override
  String get totalSleepDuration => 'Total sleep duration';

  @override
  String get dailyTotalMilkPumpingAmount => 'Daily total pumped amount';

  @override
  String get maximumSleepDuration => 'Maximum sleep duration';

  @override
  String get minimumSleepDuration => 'Minimum sleep duration';

  @override
  String get allergicReactionCount => 'Allergic reaction count';

  @override
  String get dailyAverageMilkPumpingCount => 'Daily average milk pumping count';

  @override
  String get growthInfoRecord => 'Pertumbuhan Informasi Rekam';

  @override
  String get recordBabyCurrentWeight => 'Please record baby\'s current weight';

  @override
  String get recordBabyCurrentHeight => 'Please record baby\'s current height';

  @override
  String get measurementItems => 'Measurement Items';

  @override
  String get memoOptional => 'Memo (Optional)';

  @override
  String get enterWeight => 'Enter weight';

  @override
  String get enterHeight => 'Enter height';

  @override
  String get recordSpecialNotesWeight =>
      'Rekam special notes when measuring weight (optional)';

  @override
  String get recordSpecialNotesHeight =>
      'Rekam special notes when measuring height (optional)';

  @override
  String get weightInvalidNumber => 'Please enter a valid number for weight';

  @override
  String get weightRangeError => 'Berat should be between 0.1~50kg';

  @override
  String get heightInvalidNumber => 'Please enter a valid number for height';

  @override
  String get heightRangeError => 'Tinggi should be between 1~200cm';

  @override
  String get enterWeightOrHeight => 'Please enter weight or height';

  @override
  String get saveError => 'An error occurred while saving';

  @override
  String get sufficientFeedingAmount =>
      'You had a sufficient amount of feeding';

  @override
  String get expectedSatisfaction =>
      'This amount is expected to provide sufficient satisfaction for the baby.';

  @override
  String get nightFeedingTime => 'It\'s nighttime feeding time';

  @override
  String get nightFeedingImpact =>
      'Nighttime feeding helps baby\'s growth, but may affect parents\' sleep patterns.';

  @override
  String get nextExpectedFeedingTime => 'Next expected feeding time';

  @override
  String get nextFeedingIn2to3Hours =>
      'Generally, the next feeding may be needed in 2-3 hours.';

  @override
  String get longSleepDuration => 'It was a long sleep duration';

  @override
  String goodSleepForGrowth(String duration) {
    return 'Slept for $duration hours. This is a good sign for baby\'s growth and development.';
  }

  @override
  String get shortSleepDuration => 'It was a short sleep';

  @override
  String get checkSleepEnvironment =>
      'Check the environment so that short naps or sleep interruptions don\'t occur.';

  @override
  String get goodSleepQuality => 'It was good sleep quality';

  @override
  String get goodSleepBenefits =>
      'Good sleep helps baby\'s brain development and immune system improvement.';

  @override
  String get diaperChangeDirty => 'Dirty diaper change';

  @override
  String get normalDigestionSign =>
      'This is a good sign that baby\'s digestive function is working normally.';

  @override
  String get diaperChangeFrequency => 'Diaper change frequency';

  @override
  String goodDiaperChangeFrequency(int hours) {
    return 'It\'s been $hours hours since the last change. You\'re maintaining a good change frequency.';
  }

  @override
  String get medicationRecordComplete => 'Medication record completed';

  @override
  String medicationRecorded(String medicationName) {
    return '$medicationName medication has been recorded. Accurate recording helps improve treatment effectiveness.';
  }

  @override
  String get medicationRecordCompleteGeneric =>
      'Medication record has been completed.';

  @override
  String get morningMedicationTime => 'Morning medication time';

  @override
  String get morningMedicationBenefit =>
      'Morning medication helps maintain drug effectiveness throughout the day.';

  @override
  String get effectivePumping => 'It was effective pumping';

  @override
  String goodPumpingAmount(int amount) {
    return 'Pumped ${amount}ml. This is a good amount that helps with breast milk storage.';
  }

  @override
  String get pumpingImprovementTip => 'Pumping improvement tip';

  @override
  String get lowPumpingAdvice =>
      'The pumping amount is low. Adequate water intake and stress management can help.';

  @override
  String get morningPumpingTime => 'Morning pumping time';

  @override
  String get morningPumpingBenefit =>
      'Morning time is the best time for pumping due to high prolactin levels.';

  @override
  String get babyLikesFood => 'Baby likes the food';

  @override
  String goodFoodReaction(String foodName) {
    return 'Had a good reaction to $foodName. Consider adding this food to the diet.';
  }

  @override
  String get goodFoodReactionGeneric => 'Had a good reaction to the food.';

  @override
  String get lunchTimeSolidFood => 'Lunchtime solid food';

  @override
  String get lunchTimeFoodBenefit =>
      'Lunchtime solid food helps establish baby\'s eating habits.';

  @override
  String get nutritionalBalance => 'Nutritional balance management';

  @override
  String get varietyFoodBenefit =>
      'Alternating solid food made with various ingredients helps with nutritional balance.';

  @override
  String get highTemperature => 'Temperature is high';

  @override
  String highTemperatureWarning(String temperature) {
    return 'Temperature is $temperature°C, which is relatively high. Continuous observation is needed.';
  }

  @override
  String get lowTemperature => 'Temperature is low';

  @override
  String lowTemperatureWarning(String temperature) {
    return 'Temperature is $temperature°C, which is relatively low. Please pay attention to keeping warm.';
  }

  @override
  String normalTemperatureRange(String temperature) {
    return 'Temperature is $temperature°C, which is within the normal range.';
  }

  @override
  String get regularTemperatureCheck => 'Regular temperature check';

  @override
  String get regularTemperatureCheckBenefit =>
      'Regular temperature checks are recommended to monitor baby\'s health condition.';

  @override
  String get consistentRecording => 'Records are being kept consistently well';

  @override
  String get regularRecordingBenefit =>
      'Regular recording helps with baby health management.';

  @override
  String get diaperColorYellow => 'Yellow';

  @override
  String get diaperColorBrown => 'Brown';

  @override
  String get diaperColorGreen => 'Green';

  @override
  String get diaperColorBlack => 'Black';

  @override
  String get diaperColorOrange => 'Orange';

  @override
  String get diaperConsistencyNormal => 'Normal';

  @override
  String get diaperConsistencyLoose => 'Loose';

  @override
  String get diaperConsistencyHard => 'Hard';

  @override
  String get diaperConsistencyWatery => 'Watery';

  @override
  String get foodRicePorridge => 'Rice porridge';

  @override
  String get foodBabyRiceCereal => 'Rice cereal';

  @override
  String get foodBanana => 'Banana';

  @override
  String get foodApple => 'Apple';

  @override
  String get foodCarrot => 'Carrot';

  @override
  String get foodPumpkin => 'Pumpkin';

  @override
  String get foodSweetPotato => 'Sweet potato';

  @override
  String get medicationFeverReducer => 'Fever reducer';

  @override
  String get medicationColdMedicine => 'Cold medicine';

  @override
  String get medicationDigestiveAid => 'Digestive aid';

  @override
  String get medicationPainReliever => 'Pain reliever';

  @override
  String get medicationAntibiotics => 'Antibiotics';

  @override
  String get medicationVitamins => 'Vitamins';

  @override
  String get defaultValueSettings => 'Default Settings';

  @override
  String get setDefaultValuesForQuickRecording =>
      'Set default values for quick recording';

  @override
  String get formulaMilk => 'Formula';

  @override
  String get solidFoodFeeding => 'Solid Food';

  @override
  String get feedingAmountMl => 'Feeding Amount (ml)';

  @override
  String get feedingTimeMinutes => 'Feeding Time (minutes)';

  @override
  String get feedingPosition => 'Feeding Position';

  @override
  String get sleepTimeMinutes => 'Sleep Time (minutes)';

  @override
  String get sleepLocation => 'Sleep Location';

  @override
  String get bedroom => 'Bedroom';

  @override
  String get livingRoom => 'Living Room';

  @override
  String get stroller => 'Stroller';

  @override
  String get car => 'Car';

  @override
  String get outdoors => 'Outdoors';

  @override
  String get stoolColorWhenDirty => 'Color (when dirty)';

  @override
  String get stoolConsistencyWhenDirty => 'Consistency (when dirty)';

  @override
  String get diaperColorGreenish => 'Greenish';

  @override
  String get diaperColorWhite => 'White';

  @override
  String get diaperConsistencyLooseAlt => 'Loose';

  @override
  String get diaperConsistencyHardAlt => 'Hard';

  @override
  String get amountGrams => 'Amount (g)';

  @override
  String get allergicReaction => 'Allergic Reaction';

  @override
  String get allergicReactionNone => 'None';

  @override
  String get allergicReactionMild => 'Mild';

  @override
  String get allergicReactionModerate => 'Moderate';

  @override
  String get allergicReactionSevere => 'Severe';

  @override
  String get tablets => 'Tablets';

  @override
  String get administrationRoute => 'Administration Route';

  @override
  String get pumpingAmountMl => 'Pumping Amount (ml)';

  @override
  String get pumpingTimeMinutes => 'Pumping Time (minutes)';

  @override
  String get pumpingPosition => 'Pumping Position';

  @override
  String get storageLocation => 'Storage Location';

  @override
  String get useImmediately => 'Use Immediately';

  @override
  String cardSettingsSavePartialFailure(String failedCards) {
    return 'Failed to save some card settings: $failedCards';
  }

  @override
  String get feedingAmountValidationError =>
      'Please enter feeding amount between 1-1000ml';

  @override
  String get feedingDurationValidationError =>
      'Please enter feeding duration between 1-180 minutes';

  @override
  String inviteCreationError(String error) {
    return 'Error occurred while creating invitation: $error';
  }

  @override
  String get shareFailed => 'Sharing failed';

  @override
  String inviteCodeGenerationFailed(String error) {
    return 'Failed to generate invitation code: $error';
  }

  @override
  String get databaseSaveFailed =>
      'Failed to save to database. Please try again';

  @override
  String get growthRecordProcessingError =>
      'An error occurred while processing growth record';

  @override
  String get authenticationFailed => 'Authentication failed. Please try again.';

  @override
  String get verificationCodeResendFailed =>
      'Failed to resend verification code. Please try again later.';

  @override
  String get accountDeletionError => 'Error during account deletion';

  @override
  String babyInfoResetFailed(String babyName) {
    return 'Failed to reset $babyName information. Please try again.';
  }

  @override
  String babyInfoResetError(String error) {
    return 'An error occurred during information reset: $error';
  }

  @override
  String get accountDeletionSuccess =>
      'Account deletion completed successfully.\n\nYou can sign up again anytime.';

  @override
  String inviteCodeRenewed(String code) {
    return 'Previous code expired and new invitation code generated: $code';
  }

  @override
  String inviteCodeGenerated(String code) {
    return 'Invitation code generated: $code';
  }

  @override
  String get noStatisticsDataToShare => 'No statistics data to share';

  @override
  String get noBabySelected => 'No baby information selected';

  @override
  String get imageShareFeatureUnderDevelopment =>
      'Image sharing feature is under development. Please use text sharing.';

  @override
  String get logoutPartialError =>
      'Some errors occurred during logout but continuing.';

  @override
  String get testModeInviteWarning =>
      'Test mode: Creating invitation with temporary user information.';

  @override
  String get iosSimulatorCameraWarning =>
      'Camera cannot be used in iOS Simulator.\nPlease try again from gallery.';

  @override
  String get babyLongPressHint => 'Long press on baby to reset information';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get babyInfoReset => 'Baby Information Reset';

  @override
  String babyInfoResetting(String babyName) {
    return 'Resetting $babyName information...';
  }

  @override
  String get databaseUpdated =>
      '✅ Database has been updated!\n\nPlease restart the app and try again.';

  @override
  String get confirmDeletePost =>
      'Are you sure you want to delete this post? Deleted posts cannot be recovered.';

  @override
  String get postDeleted => 'Post has been deleted.';

  @override
  String get commentUpdated => 'Comment has been updated.';

  @override
  String get confirmDeleteComment =>
      'Are you sure you want to delete this comment? Deleted comments cannot be recovered.';

  @override
  String get commentDeleted => 'Comment has been deleted.';

  @override
  String get shareFeatureInDevelopment =>
      'Bagikan feature is under development';

  @override
  String get sortByRecent => 'Urutkan by Recent';

  @override
  String get replyCreated => 'Reply has been posted.';

  @override
  String get commentCreated => 'Comment has been posted.';

  @override
  String get commentCreationFailed => 'Failed to post comment.';

  @override
  String get reply => 'Reply';

  @override
  String replyTo(String nickname) {
    return 'Reply to $nickname';
  }

  @override
  String get writeReply => 'Write a reply...';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String moreReplies(int count) {
    return 'Lihat $count more replies';
  }

  @override
  String get copy => 'Copy';

  @override
  String get report => 'Laporan';

  @override
  String get commentCopied => 'Comment has been copied';

  @override
  String get reportComment => 'Laporan Comment';

  @override
  String get confirmReportComment =>
      'Do you want to report this comment? It will be reported as inappropriate content or spam.';

  @override
  String get reportSubmitted => 'Laporan has been submitted.';

  @override
  String get serviceInPreparation => '💝 Service in Preparation';

  @override
  String get upcomingServiceDescription =>
      'We will soon introduce useful parenting information and products';

  @override
  String get accountInfo => 'Account Informasi';

  @override
  String get userID => 'Pengguna ID';

  @override
  String get email => 'Email';

  @override
  String get loginMethod => 'Masuk Method';

  @override
  String get noEmail => 'Tidak email';

  @override
  String get accountDeletion => 'Account Deletion';

  @override
  String get allDataWillBePermanentlyDeleted =>
      'All data will be permanently deleted';

  @override
  String get accountDeletionWarning =>
      '⚠️ The following data will be permanently deleted when you delete your account:';

  @override
  String get userAccountInfo => '• Pengguna account information';

  @override
  String get allRegisteredBabyInfo => '• All registered baby information';

  @override
  String get allTimelineRecords => '• All timeline records';

  @override
  String get allCommunityPosts => '• All community posts and comments';

  @override
  String get allInvitationHistory => '• All invitation history';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get accountDeletionCompleted =>
      'Account deletion completed. (Forced completion due to long processing time)';

  @override
  String get accountDeletionCompletedSuccess =>
      'Account deletion successfully completed. You can sign up again at any time.';

  @override
  String get daysUnit => 'days';

  @override
  String get monthsUnit => 'months';

  @override
  String get yearsUnit => 'years';

  @override
  String get confirmButton => 'OK';

  @override
  String get accountDeletionCompleteTitle => 'Account Deletion Lengkap';

  @override
  String get resetBaby => 'Reset';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get birthDateLabel => 'Birth Tanggal:';

  @override
  String get genderColon => 'Jenis Kelamin:';

  @override
  String babyInfoResetQuestion(Object babyName) {
    return 'Do you want to reset $babyName information from the beginning?';
  }

  @override
  String get recordsWillBeReset => 'The following records will be reset';

  @override
  String get feedingSleepDiaperRecords =>
      'Pemberian Makan, sleep, diaper records';

  @override
  String get growthInfoAndPhotos => 'Pertumbuhan information and photos';

  @override
  String get allBabyRelatedData => 'All baby-related data';

  @override
  String allRecordsWillBeDeleted(Object babyName) {
    return 'All records of $babyName will be completely removed';
  }

  @override
  String babyResetSuccessMessage(Object babyName) {
    return '$babyName information has been successfully reset.';
  }

  @override
  String get kakaoProvider => 'KakaoTalk';

  @override
  String get googleProvider => 'Google';

  @override
  String get appleProvider => 'Apple';

  @override
  String get emailProvider => 'Email';

  @override
  String get unknownProvider => 'Unknown';

  @override
  String get accountDeletionPartialErrorMessage =>
      'Some processing encountered issues but logout is completed. Redirecting to login screen.';
}
