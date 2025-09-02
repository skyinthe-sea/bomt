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
    return 'Gagal memuat informasi pengguna: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Error saat memuat daftar bayi: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Halo, $userName!';
  }

  @override
  String get registerBaby => 'Daftarkan bayi';

  @override
  String get noBabiesRegistered => 'Belum ada bayi terdaftar';

  @override
  String get registerFirstBaby => 'Daftarkan bayi pertama Anda!';

  @override
  String get registerBabyButton => 'Daftarkan bayi';

  @override
  String birthday(int year, int month, int day) {
    return 'Birthday: $year/$month/$day';
  }

  @override
  String age(int days) {
    return 'Age: $days days';
  }

  @override
  String gender(String gender) {
    return 'Jenis kelamin';
  }

  @override
  String get male => 'Laki-laki';

  @override
  String get female => 'Perempuan';

  @override
  String get other => 'Lainnya';

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
  String get enterBabyInfo => 'Masukkan informasi bayi';

  @override
  String get babyName => 'Nama bayi';

  @override
  String get babyNameHint => 'contoh: Sari';

  @override
  String get babyNameRequired => 'Masukkan nama bayi';

  @override
  String get babyNameMinLength => 'Nama harus minimal 2 karakter';

  @override
  String get selectBirthdateButton => 'Pilih tanggal lahir';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Batal';

  @override
  String get loginFailed => 'Login failed';

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
  String get loginWithKakao => 'Login with Kakao';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Masukkan nama bayi';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutConfirm => 'Yakin ingin keluar?';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get darkMode => 'Mode gelap';

  @override
  String get appearance => 'Tampilan';

  @override
  String get home => 'Beranda';

  @override
  String get timeline => 'Timeline';

  @override
  String get record => 'Catat';

  @override
  String get statistics => 'Statistik';

  @override
  String get community => 'Komunitas';

  @override
  String get comingSoon => 'Segera hadir';

  @override
  String get timelineUpdateMessage => 'Timeline feature will be updated soon';

  @override
  String get recordUpdateMessage => 'Record feature will be updated soon';

  @override
  String get statisticsUpdateMessage =>
      'Statistics feature will be updated soon';

  @override
  String get communityUpdateMessage => 'Community feature will be updated soon';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get growthInfo => 'Info Pertumbuhan';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Menyusui';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Tidur';

  @override
  String get totalSleepTime => 'Total Sleep Time';

  @override
  String get cardSettings => 'Card Settings';

  @override
  String get cardSettingsGuide => 'Card Settings Guide';

  @override
  String get cardSettingsDescription =>
      '• Toggle switches to show/hide cards\n• Drag to change card order\n• Changes are previewed in real-time';

  @override
  String get cardVisible => 'Visible';

  @override
  String get cardHidden => 'Hidden';

  @override
  String get save => 'Save';

  @override
  String get cardSettingsSaved => 'Card settings saved';

  @override
  String get cardSettingsError => 'Error occurred while saving settings';

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
  String get solidFood => 'Makanan Padat';

  @override
  String get medication => 'Obat';

  @override
  String get milkPumping => 'Memompa ASI';

  @override
  String get temperature => 'Suhu';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Jumlah pemberian makan';

  @override
  String get feedingRecordAdded => 'Feeding record added successfully';

  @override
  String get feedingRecordFailed => 'Failed to add feeding record';

  @override
  String get feedingRecordsLoadFailed => 'Failed to load feeding records';

  @override
  String get quickFeeding => 'Quick Feeding';

  @override
  String get feedingTime => 'Feeding Time';

  @override
  String get feedingType => 'Feeding Type';

  @override
  String get breastfeeding => 'Breastfeeding';

  @override
  String get bottleFeeding => 'Bottle Feeding';

  @override
  String get mixedFeeding => 'Mixed Feeding';

  @override
  String sleepCount(Object count) {
    return '$count times';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get sleepStarted => 'Sleep started';

  @override
  String get sleepEnded => 'Sleep ended';

  @override
  String get sleepInProgress => 'Sedang Tidur';

  @override
  String get sleepRecordFailed => 'Failed to process sleep record';

  @override
  String get sleepRecordsLoadFailed => 'Failed to load sleep records';

  @override
  String get sleepTime => 'Sleep Time';

  @override
  String get wakeUpTime => 'Wake Up Time';

  @override
  String get sleepDurationLabel => 'Sleep Duration';

  @override
  String get napTime => 'Nap Time';

  @override
  String get nightSleep => 'Night Sleep';

  @override
  String diaperCount(Object count) {
    return '$count times';
  }

  @override
  String get diaperChanged => 'Diaper changed';

  @override
  String get diaperRecordAdded => 'Diaper change record added successfully';

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
  String get diaperType => 'Diaper Type';

  @override
  String get diaperChangeTime => 'Change Time';

  @override
  String get weight => 'Berat';

  @override
  String get height => 'Tinggi';

  @override
  String get growthRecord => 'Growth Record';

  @override
  String get growthRecordAdded => 'Growth record added';

  @override
  String get growthRecordFailed => 'Failed to save growth record';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => 'Measurement Type';

  @override
  String get measurementValue => 'Value';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get temperatureRange =>
      'Temperature must be between 30.0°C and 45.0°C';

  @override
  String get weightRange => 'Weight must be between 0.1kg and 50kg';

  @override
  String get heightRange => 'Height must be between 1cm and 200cm';

  @override
  String get enterValidNumber => 'Silakan masukkan angka yang valid';

  @override
  String get recordGrowthInfo => 'Record Growth Information';

  @override
  String currentMeasurement(Object type) {
    return 'Enter current $type';
  }

  @override
  String get measurementSituation =>
      'Record measurement situation or special notes (optional)';

  @override
  String get communityTitle => 'Community';

  @override
  String get writePost => 'Tulis Postingan';

  @override
  String get post => 'Posting';

  @override
  String get postTitle => 'Post Title';

  @override
  String get postContent => 'Post Content';

  @override
  String get postTitleHint => 'Enter title';

  @override
  String get postContentHint =>
      'Enter content...\n\nFeel free to share your story.';

  @override
  String get selectCategory => 'Pilih kategori';

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
      'Create a nickname to use in the community.\nIt will be displayed to other users.';

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
    return 'Konten: $count/10000';
  }

  @override
  String imageCount(Object count) {
    return 'Images: $count/5';
  }

  @override
  String get addImages => 'Add Images';

  @override
  String imageSelectFailed(Object error) {
    return 'Image selection failed: $error';
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
  String get userNotFound => 'User information not found';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get noStatisticsData => 'No Statistics Data';

  @override
  String statisticsDescription(Object period) {
    return 'No activities recorded during $period.\nStart recording your baby\'s activities!';
  }

  @override
  String get recordActivity => 'Record Activity';

  @override
  String get viewOtherPeriod => 'View Other Period';

  @override
  String get refresh => 'Segarkan';

  @override
  String get statisticsTips => 'To view statistics?';

  @override
  String get statisticsTip1 =>
      'Record activities like feeding, sleep, diaper changes';

  @override
  String get statisticsTip2 =>
      'At least one day of data is required for statistics';

  @override
  String get statisticsTip3 => 'You can record easily from the home screen';

  @override
  String get saveAsImage => 'Save as Image';

  @override
  String get saveAsImageDescription => 'Save statistics as image';

  @override
  String get shareAsText => 'Share as Text';

  @override
  String get shareAsTextDescription => 'Share statistics summary as text';

  @override
  String get statisticsEmptyState => 'No statistics data';

  @override
  String get retryButton => 'Try Again';

  @override
  String get detailsButton => 'Details';

  @override
  String get goHomeButton => 'Go Home';

  @override
  String get applyButton => 'Apply';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get last3Months => 'Last 3 Months';

  @override
  String get allTime => 'All Time';

  @override
  String get viewOtherPeriodTitle => 'View Other Period';

  @override
  String get familyInvitation => 'Undangan keluarga';

  @override
  String get invitationDescription =>
      'Manage baby records together with your family using invitation codes';

  @override
  String get createInvitation => 'Create Invitation';

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
  String get shareInvitation => 'Share Invitation';

  @override
  String get shareImmediately => 'Share Now';

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
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

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
  String get saveFailed => 'Save failed';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get deleteFailed => 'Delete failed';

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
    return '$minutes menit yang lalu';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Hari Ini';

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
  String get medicationTime => 'Obat';

  @override
  String get medicationAdded => 'Medication record added';

  @override
  String get solidFoodType => 'Food Type';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => 'Solid food record added';

  @override
  String get milkPumpingAmount => 'Pumping Amount';

  @override
  String get milkPumpingTime => 'Pumping Time';

  @override
  String get milkPumpingAdded => 'Milk pumping record added';

  @override
  String get temperatureReading => 'Temperature Reading';

  @override
  String get temperatureNormal => 'Normal';

  @override
  String get temperatureHigh => 'High';

  @override
  String get temperatureLow => 'Low';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get profilePhotoUpdate => 'Update Profile Photo';

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
      'Camera not available on iOS simulator.\nPlease try from gallery.';

  @override
  String get cameraAccessError =>
      'Camera access error occurred.\nPlease try from gallery.';

  @override
  String get addImage => 'Add Image';

  @override
  String get removeImage => 'Remove Image';

  @override
  String maxImagesReached(Object count) {
    return 'Maximum $count images allowed';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$months bulan $days hari';
  }

  @override
  String get lastFeedingTime => 'Waktu menyusui terakhir';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours jam $minutes menit yang lalu';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return 'Next feeding in about ${hours}h ${minutes}m';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return 'Next feeding in about $minutes minutes';
  }

  @override
  String get feedingTimeNow => 'It\'s feeding time now 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'Feeding time soon ($minutes minutes)';
  }

  @override
  String get feedingTimeOverdue => 'Feeding time overdue';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return 'Feeding alarm in ${hours}h ${minutes}m';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return 'Feeding alarm in $minutes minutes';
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
  String get hoursUnit => 'jam';

  @override
  String get minutesUnit => 'minutes';

  @override
  String get viewDetails => 'Lihat Detail';

  @override
  String get firstRecord => 'First Record';

  @override
  String get noChange => 'No Change';

  @override
  String get inProgress => 'In Progress';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get startBabyRecording =>
      'Register your baby and start tracking growth';

  @override
  String get registerBabyNow => 'Register Baby';

  @override
  String get joinWithInviteCode => 'Bergabung dengan kode undangan';

  @override
  String get loadingBabyInfo => 'Memuat informasi bayi...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Pergi ke pengaturan';

  @override
  String get profilePhotoUpdated => 'Foto profil telah diperbarui.';

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
    return 'About $count times';
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
  String get hourActivityPattern => 'Pola Aktivitas 24 Jam';

  @override
  String get touchClockInstruction =>
      'Touch the clock to check activities by time period';

  @override
  String get touch => 'Touch';

  @override
  String get noActivitiesInTimeframe => 'No activities during this time';

  @override
  String get activityPatternAnalysis => 'Activity Pattern Analysis';

  @override
  String get todaysStory => 'Cerita Hari Ini';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Catat momen berharga pertama Anda.\nPerubahan kecil setiap hari akan menghasilkan pertumbuhan yang besar.';

  @override
  String get pattern => 'Pattern';

  @override
  String get qualityGood => 'Good';

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
  String get formula => 'Susu formula';

  @override
  String get breastMilk => 'ASI';

  @override
  String get babyFood => 'Makanan bayi';

  @override
  String get left => 'Kiri';

  @override
  String get right => 'Kanan';

  @override
  String get both => 'Keduanya';

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
  String get diaperChange => 'Ganti Popok';

  @override
  String get oralMedication => 'Obat Oral';

  @override
  String get topical => 'Topikal';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Pengukuran Suhu';

  @override
  String get fever => 'Demam';

  @override
  String get lowFever => 'Demam ringan';

  @override
  String get hypothermia => 'Hipotermia';

  @override
  String get normal => 'Normal';

  @override
  String get quality => 'Kualitas';

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
    return 'No activities were recorded during $period.';
  }

  @override
  String get recordBabyActivities => 'Record your baby\'s activities!';

  @override
  String get howToViewStatistics => 'How to view statistics?';

  @override
  String get recordActivitiesLikeFeedingSleep =>
      'Record activities like feeding, sleep, diaper changes, etc.';

  @override
  String get atLeastOneDayDataRequired =>
      'At least one day of data is required to display statistics.';

  @override
  String get canRecordEasilyFromHome =>
      'You can easily record activities from the home screen.';

  @override
  String get updating => 'Updating...';

  @override
  String get lastUpdated => 'Last updated:';

  @override
  String get periodSelection => 'Pemilihan periode:';

  @override
  String get daily => 'Daily';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get apply => 'Apply';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get detailedStatistics => 'Statistik Terperinci';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Tinjauan Aktivitas Keseluruhan';

  @override
  String get totalActivities => 'Total Aktivitas';

  @override
  String get activeCards => 'Kartu Aktif';

  @override
  String get dailyAverage => 'Rata-rata Harian';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get details => 'Details';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get troubleshootingMethods => 'Troubleshooting Methods';

  @override
  String get shareStatistics => 'Share Statistics';

  @override
  String get communitySubtitle => 'Sharing Parenting Stories Together';

  @override
  String get search => 'Cari';

  @override
  String get notification => 'Notifikasi';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Bagikan pengalaman mengasuh anak dan informasi berharga dengan orang tua lain';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Semua';

  @override
  String get categoryPopular => 'Populer';

  @override
  String get categoryClinical => 'Klinis';

  @override
  String get categoryInfoSharing => 'Berbagi info';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Makanan bayi';

  @override
  String get categoryDevelopment => 'Perkembangan';

  @override
  String get categoryVaccination => 'Vaksinasi';

  @override
  String get categoryPostpartum => 'Pasca melahirkan';

  @override
  String get sortByLikes => 'Urutkan berdasarkan like';

  @override
  String get sortByLatest => 'Urutkan berdasarkan terbaru';

  @override
  String get edited => '(diedit)';

  @override
  String commentsCount(Object count) {
    return '$count komentar';
  }

  @override
  String get deletePost => 'Hapus postingan';

  @override
  String get deletePostConfirm =>
      'Yakin ingin menghapus postingan ini?\\nPostingan yang dihapus tidak dapat dikembalikan.';

  @override
  String get deletePostSuccess => 'Postingan dihapus.';

  @override
  String deletePostError(Object error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String get postNotFound => 'Postingan tidak ditemukan';

  @override
  String get shareFeatureComingSoon => 'Fitur berbagi segera hadir';

  @override
  String get loadingComments => 'Memuat komentar...';

  @override
  String get loadMoreComments => 'Muat lebih banyak komentar';

  @override
  String get editComment => 'Edit komentar';

  @override
  String get editCommentHint => 'Edit komentar Anda...';

  @override
  String get editCommentSuccess => 'Komentar diperbarui.';

  @override
  String editCommentError(Object error) {
    return 'Gagal mengedit: $error';
  }

  @override
  String get deleteComment => 'Hapus komentar';

  @override
  String get deleteCommentConfirm =>
      'Yakin ingin menghapus komentar ini?\\nKomentar yang dihapus tidak dapat dikembalikan.';

  @override
  String get deleteCommentSuccess => 'Komentar dihapus.';

  @override
  String get replySuccess => 'Balasan diposting.';

  @override
  String get commentSuccess => 'Komentar diposting.';

  @override
  String get commentError => 'Gagal memposting komentar.';

  @override
  String get titlePlaceholder => 'Masukkan judul';

  @override
  String get contentPlaceholder =>
      'Bagikan pemikiran Anda...\\n\\nTulis dengan bebas tentang pengalaman sebagai orang tua.';

  @override
  String imageSelectionError(Object error) {
    return 'Gagal memilih gambar: $error';
  }

  @override
  String get userNotFoundError => 'Informasi pengguna tidak ditemukan.';

  @override
  String get postCreateSuccess => 'Postingan berhasil dibuat!';

  @override
  String postCreateError(Object error) {
    return 'Gagal membuat postingan: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Judul: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Gambar: $count/5';
  }

  @override
  String get addImageTooltip => 'Tambahkan gambar';

  @override
  String get allPostsChecked => 'Semua postingan sudah diperiksa! 👍';

  @override
  String get waitForNewPosts => 'Tunggu postingan baru';

  @override
  String get noPostsYet => 'Belum ada postingan';

  @override
  String get writeFirstPost => 'Tulis postingan pertama!';

  @override
  String get loadingNewPosts => 'Memuat postingan baru...';

  @override
  String get failedToLoadPosts => 'Gagal memuat postingan';

  @override
  String get checkNetworkAndRetry => 'Periksa koneksi dan coba lagi';

  @override
  String get categoryDailyLife => 'Kehidupan sehari-hari';

  @override
  String get preparingTimeline => 'Menyiapkan timeline...';

  @override
  String get noRecordedMoments => 'Belum ada momen yang direkam';

  @override
  String get loadingTimeline => 'Memuat timeline...';

  @override
  String get noRecordsYet => 'Belum ada catatan';

  @override
  String noRecordsForDate(Object date) {
    return 'Tidak ada catatan untuk $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Tidak ada catatan $filter untuk $date';
  }

  @override
  String get cannotRecordFuture => 'Belum bisa mencatat aktivitas masa depan';

  @override
  String get addFirstRecord => 'Tambahkan catatan pertama Anda!';

  @override
  String get canAddPastRecord => 'Anda bisa menambahkan catatan masa lalu';

  @override
  String get addRecord => 'Tambahkan catatan';

  @override
  String get viewOtherDates => 'Lihat tanggal lain';

  @override
  String get goToToday => 'Pergi ke hari ini';

  @override
  String get quickRecordFromHome =>
      'Anda bisa menambahkan catatan dengan cepat dari layar utama';

  @override
  String detailViewComingSoon(String title) {
    return 'Detail $title (Segera hadir)';
  }

  @override
  String get familyInvitationDescription =>
      'Kelola catatan perawatan bayi bersama keluarga melalui kode undangan';

  @override
  String get babyManagement => 'Manajemen bayi';

  @override
  String get addBaby => 'Tambah bayi';

  @override
  String get noBabiesMessage =>
      'Belum ada bayi terdaftar.\\nSilakan tambahkan bayi.';

  @override
  String get switchToNextBaby => 'Beralih ke bayi berikutnya';

  @override
  String get birthDate => 'Tanggal lahir';

  @override
  String get registering => 'Mendaftar...';

  @override
  String get register => 'Daftar';

  @override
  String careTogetherWith(String name) {
    return 'Merawat bayi bersama $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Undang keluarga atau pasangan\\nuntuk mengelola catatan perawatan bayi bersama';

  @override
  String get generateInviteCode => 'Buat kode undangan';

  @override
  String get generateInviteCodeDescription =>
      'Buat kode undangan baru dan salin';

  @override
  String get generateInviteCodeButton => 'Buat kode undangan';

  @override
  String get orText => 'Atau';

  @override
  String get enterInviteCodeDescription =>
      'Masukkan kode undangan yang diterima';

  @override
  String get inviteCodePlaceholder => 'Kode undangan (6 digit)';

  @override
  String get acceptInvite => 'Terima undangan';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name berhasil didaftarkan';
  }

  @override
  String get babyRegistrationFailed => 'Gagal mendaftarkan bayi';

  @override
  String babyRegistrationError(String error) {
    return 'Terjadi kesalahan: $error';
  }

  @override
  String babySelected(String name) {
    return '$name telah dipilih';
  }

  @override
  String get inviteCodeGenerated => 'Kode undangan dibuat!';

  @override
  String remainingTime(String time) {
    return 'Waktu tersisa: $time';
  }

  @override
  String get validTime => 'Waktu berlaku: 5 menit';

  @override
  String get generating => 'Membuat...';

  @override
  String get joining => 'Bergabung...';

  @override
  String get noBabyInfo => 'Tidak ada info bayi';

  @override
  String get noBabyInfoDescription =>
      'Informasi bayi tidak ditemukan.\\nIngin membuat bayi percobaan?';

  @override
  String get create => 'Buat';

  @override
  String get generateNewInviteCode => 'Buat kode undangan baru';

  @override
  String get replaceExistingCode =>
      'Ini akan mengganti kode undangan yang ada.\\nIngin lanjutkan?';

  @override
  String get acceptInvitation => 'Terima undangan';

  @override
  String get acceptInvitationDescription =>
      'Ingin menerima undangan dan bergabung dengan keluarga?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Catatan bayi yang ada akan dihapus dan diganti dengan bayi yang diundang ($babyName).\\n\\nIngin lanjutkan?';
  }

  @override
  String get pleaseEnterInviteCode => 'Masukkan kode undangan';

  @override
  String get inviteCodeMustBe6Digits => 'Kode undangan harus 6 digit';

  @override
  String get pleaseLoginFirst =>
      'Informasi login tidak ditemukan. Silakan login terlebih dahulu.';

  @override
  String get copiedToClipboard => 'Kode undangan disalin!';

  @override
  String get joinedSuccessfully => 'Berhasil bergabung dengan keluarga!';

  @override
  String get inviteCodeExpired => 'Kode undangan kedaluwarsa';

  @override
  String get invalidInviteCode => 'Kode undangan tidak valid';

  @override
  String get alreadyMember => 'Anda sudah menjadi anggota keluarga ini';

  @override
  String get cannotInviteSelf => 'Anda tidak bisa mengundang diri sendiri';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}mnt ${seconds}dtk';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Panduan perawatan $name';
  }

  @override
  String get babyGuide => 'Panduan bayi';

  @override
  String get noAvailableGuides => 'Tidak ada panduan tersedia';

  @override
  String get current => 'Saat ini';

  @override
  String get past => 'Sudah lewat';

  @override
  String get upcoming => 'Akan datang';

  @override
  String babysGuide(String name) {
    return '$name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Panduan $weekText';
  }

  @override
  String get feedingGuide => '💡 Panduan menyusui';

  @override
  String get feedingFrequency => 'Frekuensi menyusui';

  @override
  String get singleFeedingAmount => 'Jumlah per menyusui';

  @override
  String get dailyTotal => 'Total harian';

  @override
  String get additionalTips => '📋 Tips tambahan';

  @override
  String get understood => 'Mengerti!';

  @override
  String get newborn => 'Bayi baru lahir';

  @override
  String weekNumber(int number) {
    return 'Minggu $number';
  }

  @override
  String get newbornWeek0 => 'Bayi baru lahir (Minggu 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Harian $min - $max kali';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Harian $min+ kali';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Harian sampai $max kali';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml atau lebih';
  }

  @override
  String amountMaxML(int max) {
    return 'Sampai ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Pilihan Bahasa';

  @override
  String get selectLanguage => 'Pilih bahasa';

  @override
  String get currentLanguage => 'Bahasa saat ini';

  @override
  String get searchCommunityPosts => 'Cari postingan komunitas';

  @override
  String get temperatureRecord => 'Catatan suhu';

  @override
  String get temperatureTrend => 'Tren Suhu';

  @override
  String get profilePhotoSetup => 'Pengaturan foto profil';

  @override
  String get howToSelectPhoto => 'Bagaimana Anda ingin memilih foto?';

  @override
  String get send => 'Kirim';

  @override
  String get emailVerificationRequired => 'Verifikasi email diperlukan';

  @override
  String get passwordReset => 'Reset kata sandi';

  @override
  String get enterEmailForReset =>
      'Masukkan alamat email terdaftar Anda.\nKami akan mengirimkan tautan reset kata sandi.';

  @override
  String get accountWithdrawalComplete => 'Penghapusan akun selesai';

  @override
  String get genderLabel => 'Jenis kelamin: ';

  @override
  String get birthdateLabel => 'Tanggal lahir: ';

  @override
  String get maleGender => 'Laki-laki';

  @override
  String get femaleGender => 'Perempuan';

  @override
  String get joinWithInviteCodeButton => 'Bergabung dengan kode undangan';

  @override
  String get temperatureRecorded => 'Suhu tubuh dicatat';

  @override
  String recordFailed(String error) {
    return 'Pencatatan gagal';
  }

  @override
  String get temperatureSettingsSaved => 'Pengaturan suhu telah disimpan';

  @override
  String get loadingUserInfo =>
      'Memuat informasi pengguna. Silakan coba lagi dalam beberapa saat.';

  @override
  String get continueWithSeparateAccount => 'Lanjutkan dengan akun terpisah';

  @override
  String get linkWithExistingAccount => 'Hubungkan dengan akun yang ada';

  @override
  String get linkAccount => 'Hubungkan akun';

  @override
  String get accountLinkingComplete => 'Penghubungan akun selesai';

  @override
  String get deleteConfirmation => 'Konfirmasi penghapusan';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Kata sandi';

  @override
  String get babyNameLabel => 'Nama bayi';

  @override
  String get weightInput => 'Masukkan berat badan';

  @override
  String get heightInput => 'Masukkan tinggi badan';

  @override
  String get measurementNotes =>
      'Catat kondisi pengukuran atau catatan khusus (opsional)';

  @override
  String get urine => 'Urin';

  @override
  String get stool => 'Tinja';

  @override
  String get yellow => 'Kuning';

  @override
  String get brown => 'Coklat';

  @override
  String get green => 'Hijau';

  @override
  String get bottle => 'Botol';

  @override
  String get good => 'Baik';

  @override
  String get average => 'Rata-rata';

  @override
  String get poor => 'Buruk';

  @override
  String get vaccination => 'Vaksinasi';

  @override
  String get illness => 'Penyakit';

  @override
  String get highFever => 'Demam Tinggi';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhalasi';

  @override
  String get injection => 'Suntikan';

  @override
  String get tablet => 'Tablet';

  @override
  String get drops => 'Tetes';

  @override
  String get teaspoon => 'Sendok teh';

  @override
  String get tablespoon => 'Sendok makan';

  @override
  String get sleepQuality => 'Kualitas';

  @override
  String get pumpingTime => 'Memompa';

  @override
  String get solidFoodTime => 'Makanan padat';

  @override
  String get totalFeedingAmount => 'Total jumlah menyusui';

  @override
  String get averageFeedingAmount => 'Jumlah rata-rata pemberian makan';

  @override
  String get dailyAverageFeedingCount =>
      'Jumlah rata-rata harian pemberian makan';

  @override
  String get clinical => 'Klinis';

  @override
  String get infoSharing => 'Berbagi informasi';

  @override
  String get sleepIssues => 'Masalah tidur';

  @override
  String get babyFoodCategory => 'Makanan bayi';

  @override
  String get developmentStage => 'Tahap perkembangan';

  @override
  String get vaccinationCategory => 'Vaksinasi';

  @override
  String get postpartumRecovery => 'Pemulihan pasca melahirkan';

  @override
  String get dailyLife => 'Kehidupan sehari-hari';

  @override
  String get likes => 'Suka';

  @override
  String get comments => 'Komentar';

  @override
  String get anonymous => 'Anonim';

  @override
  String get minutes => 'mnt';

  @override
  String get armpit => 'Ketiak';

  @override
  String get forehead => 'Dahi';

  @override
  String get ear => 'Telinga';

  @override
  String get mouth => 'Mulut';

  @override
  String get rectal => 'Rektal';

  @override
  String get otherLocation => 'Lainnya';

  @override
  String get searchError => 'Kesalahan pencarian';

  @override
  String get question => 'Pertanyaan';

  @override
  String get information => 'Informasi';

  @override
  String get relevance => 'Relevansi';

  @override
  String get searchSuggestions => 'Saran pencarian';

  @override
  String get noSearchResults => 'Tidak ada hasil pencarian';

  @override
  String get tryDifferentSearchTerm => 'Coba kata kunci pencarian yang berbeda';

  @override
  String get likeFeatureComingSoon => 'Fitur suka segera hadir';

  @override
  String get popularSearchTerms => 'Kata kunci pencarian populer';

  @override
  String get recentSearches => 'Pencarian terbaru';

  @override
  String get deleteAll => 'Hapus semua';

  @override
  String get sortByComments => 'Urutkan berdasarkan komentar';

  @override
  String get detailInformation => 'Informasi Detail';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recordAgain => 'Record Again';

  @override
  String get share => 'Share';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get deleteRecordConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get amount => 'Jumlah';

  @override
  String get duration => 'Durasi';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'Sisi';

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
  String get saveChanges => 'Save Changes';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get smartInsights => 'Wawasan Cerdas';

  @override
  String get analyzingPatterns => 'Menganalisis pola...';

  @override
  String insightsFound(int count) {
    return '$count wawasan ditemukan';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'Kepercayaan';

  @override
  String sleepProgressMinutes(int minutes) {
    return '$minutes minutes in progress';
  }

  @override
  String get sleepProgressTime => 'Sleep Progress Time';

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
    return '${hours}j ${minutes}m';
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
  String get longPressForDetails => 'Tekan lama untuk detail';

  @override
  String get todaysSummary => 'Ringkasan Hari Ini';

  @override
  String get future => 'Masa Depan';

  @override
  String get previousDate => 'Tanggal sebelumnya';

  @override
  String get nextDate => 'Tanggal berikutnya';

  @override
  String get selectDate => 'Pilih tanggal';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'Silakan daftarkan bayi Anda terlebih dahulu';

  @override
  String get registerBabyToRecordMoments =>
      'Untuk merekam momen-momen berharga bayi Anda,\nsilakan daftarkan informasi bayi terlebih dahulu.';

  @override
  String get addBabyFromHome => 'Tambah bayi dari beranda';

  @override
  String get timesUnit => 'kali';

  @override
  String get itemsUnit => 'item';

  @override
  String get timesPerDay => 'kali/hari';

  @override
  String get activityDistributionByCategory =>
      'Distribusi Aktivitas berdasarkan Kategori';

  @override
  String itemsCount(int count) {
    return '$count item';
  }

  @override
  String get totalCount => 'Jumlah Total';

  @override
  String timesCount(int count) {
    return '$count kali';
  }

  @override
  String get noDetailedData => 'Tidak ada data terperinci';

  @override
  String get averageFeedingTime => 'Waktu rata-rata pemberian makan';

  @override
  String get averageSleepTime => 'Waktu rata-rata tidur';

  @override
  String get dailyAverageTotalSleepTime => 'Total waktu rata-rata harian tidur';

  @override
  String get dailyAverageSleepCount => 'Jumlah rata-rata harian tidur';

  @override
  String get dailyAverageChangeCount => 'Jumlah rata-rata harian penggantian';

  @override
  String get sharingParentingStories => 'Berbagi Cerita Parenting';

  @override
  String get myActivity => 'Aktivitas Saya';

  @override
  String get categories => 'Kategori';

  @override
  String get menu => 'Menu';

  @override
  String get seeMore => 'Lihat Selengkapnya';

  @override
  String get midnight => 'Tengah Malam';

  @override
  String get morning => 'Pagi';

  @override
  String get noon => 'Siang';

  @override
  String get afternoon => 'Sore';

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
  String get averageFeedingDuration => 'Durasi menyusui rata-rata';

  @override
  String get averageSleepDuration => 'Durasi tidur rata-rata';

  @override
  String get dailyTotalSleepDuration => 'Daily total sleep duration';

  @override
  String get dailyAverageDiaperChangeCount =>
      'Rata-rata perubahan popok harian';

  @override
  String get dailyAverageMedicationCount => 'Rata-rata jumlah obat harian';

  @override
  String get medicationTypesUsed => 'Jenis obat yang digunakan';

  @override
  String get totalPumpedAmount => 'Total jumlah yang dipompa';

  @override
  String get averagePumpedAmount => 'Rata-rata jumlah yang dipompa';

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
  String get averageLabel => 'Rata-rata: ';

  @override
  String get dailyFeedingCountTitle => 'Daily feeding count';

  @override
  String get weekdaysSundayToSaturday => 'SunMonTueWedThuFriSat';

  @override
  String dayFormat(int day) {
    return '$day';
  }

  @override
  String get dailyFeedingCount => 'Jumlah menyusui harian';

  @override
  String get dailyFeedingAmount => 'Daily feeding amount';

  @override
  String get dailyFeedingDuration => 'Daily feeding duration';

  @override
  String get dailySleepCount => 'Jumlah tidur harian';

  @override
  String get dailySleepDuration => 'Daily sleep duration';

  @override
  String get dailyDiaperChangeCount => 'Perubahan popok harian';

  @override
  String get dailyMedicationCount => 'Jumlah obat harian';

  @override
  String get dailyMilkPumpingCount => 'Jumlah pompa ASI harian';

  @override
  String get dailyMilkPumpingAmount => 'Daily pumping amount';

  @override
  String get dailySolidFoodCount => 'Jumlah makanan padat harian';

  @override
  String get dailyAverageSolidFoodCount =>
      'Rata-rata jumlah makanan padat harian';

  @override
  String get triedFoodTypes => 'Jenis makanan yang dicoba';

  @override
  String babyTemperatureRecord(String name) {
    return 'Catatan Suhu $name';
  }

  @override
  String get adjustWithSlider => 'Sesuaikan dengan slider';

  @override
  String get measurementMethod => 'Metode pengukuran';

  @override
  String get normalRange => 'Rentang normal';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Rentang normal ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Simpan catatan suhu';

  @override
  String get enterTemperature => 'Silakan masukkan suhu';

  @override
  String get temperatureRangeValidation => 'Suhu harus antara 34,0°C ~ 42,0°C';

  @override
  String get recordSymptomsHint => 'Silakan catat gejala atau catatan khusus';

  @override
  String get oralMethod => 'Oral';

  @override
  String get analMethod => 'Anal';

  @override
  String recentDaysTrend(int days) {
    return 'Tren $days hari terakhir';
  }

  @override
  String get days3 => '3 hari';

  @override
  String get days7 => '7 hari';

  @override
  String get weeks2 => '2 minggu';

  @override
  String get month1 => '1 bulan';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Tidak ada catatan suhu dalam periode yang dipilih';

  @override
  String get temperatureChangeTrend => 'Tren Perubahan Suhu';

  @override
  String get averageTemperature => 'Suhu Rata-rata';

  @override
  String get highestTemperature => 'Suhu Tertinggi';

  @override
  String get lowestTemperature => 'Suhu Terendah';

  @override
  String get noteAvailableTapToView =>
      '📝 Catatan tersedia (ketuk untuk melihat)';

  @override
  String get temperatureRisingTrend => 'Suhu menunjukkan tren meningkat';

  @override
  String get temperatureFallingTrend => 'Suhu menunjukkan tren menurun';

  @override
  String get temperatureStableTrend => 'Suhu stabil';

  @override
  String get trendAnalysis => 'Analisis Tren';

  @override
  String totalMeasurements(int count) {
    return 'Total $count pengukuran';
  }

  @override
  String get temperatureRecordMemo => 'Memo Catatan Suhu';

  @override
  String babyGrowthChart(String name) {
    return 'Grafik Pertumbuhan $name';
  }

  @override
  String get noGrowthRecords => 'Tidak ada catatan pertumbuhan';

  @override
  String get enterWeightAndHeightFromHome =>
      'Silakan masukkan berat dan tinggi badan dari layar beranda';

  @override
  String get all => 'Semua';

  @override
  String get growthInsights => 'Wawasan Pertumbuhan';

  @override
  String get growthRate => 'Tingkat Pertumbuhan';

  @override
  String get monthlyAverageGrowth => 'Pertumbuhan Rata-rata Bulanan';

  @override
  String get dataInsufficient => 'Data Tidak Mencukupi';

  @override
  String get twoOrMoreRequired => '2 atau lebih diperlukan';

  @override
  String recentDaysBasis(int days) {
    return 'Berdasarkan $days hari terakhir';
  }

  @override
  String get entireBasis => 'Berdasarkan seluruh periode';

  @override
  String get oneMonthPrediction => 'Prediksi 1 Bulan';

  @override
  String get currentTrendBasis => 'Berdasarkan tren saat ini';

  @override
  String get predictionNotPossible => 'Prediksi tidak dapat dilakukan';

  @override
  String get trendInsufficient => 'Tren tidak mencukupi';

  @override
  String get recordFrequency => 'Frekuensi Catatan';

  @override
  String get veryConsistent => 'Sangat Konsisten';

  @override
  String get consistent => 'Konsisten';

  @override
  String get irregular => 'Tidak teratur';

  @override
  String averageDaysInterval(String days) {
    return 'Rata-rata interval $days hari';
  }

  @override
  String get nextRecord => 'Catatan Berikutnya';

  @override
  String get now => 'Sekarang';

  @override
  String get soon => 'Segera';

  @override
  String daysLater(int days) {
    return '$days hari kemudian';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Dicatat $days hari yang lalu';
  }

  @override
  String get weeklyRecordRecommended => 'Pencatatan mingguan direkomendasikan';

  @override
  String get nextMilestone => 'Pencapaian Berikutnya';

  @override
  String targetValue(String value, String unit) {
    return 'Target $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return 'Tersisa $remaining$unit ($progress% tercapai)';
  }

  @override
  String get calculationNotPossible => 'Perhitungan tidak dapat dilakukan';

  @override
  String get periodInsufficient => 'Periode tidak mencukupi';

  @override
  String get noDataAvailable => 'Tidak ada data yang tersedia';

  @override
  String get weightRecordRequired => 'Catatan berat diperlukan';

  @override
  String get heightRecordRequired => 'Catatan tinggi diperlukan';

  @override
  String get currentRecordMissing => 'Catatan saat ini hilang';

  @override
  String get noRecord => 'Tidak ada catatan';

  @override
  String get firstRecordStart => 'Mulai catatan pertama';

  @override
  String get oneRecord => '1 catatan';

  @override
  String get moreRecordsNeeded => 'Memerlukan lebih banyak catatan';

  @override
  String get sameDayRecord => 'Catatan hari yang sama';

  @override
  String recordedTimes(int count) {
    return 'Tercatat $count kali';
  }

  @override
  String get storageMethod => 'Metode penyimpanan';

  @override
  String get pumpingType => 'Jenis pompa';

  @override
  String get foodName => 'Nama makanan';

  @override
  String get mealType => 'Jenis makanan';

  @override
  String get texture => 'Tekstur';

  @override
  String get reaction => 'Reaksi';

  @override
  String get measurementLocation => 'Lokasi pengukuran';

  @override
  String get feverReducerGiven => 'Pemberian penurun demam';

  @override
  String get given => 'Diberikan';

  @override
  String get hours => 'jam';

  @override
  String get refrigerator => 'Kulkas';

  @override
  String get freezer => 'Freezer';

  @override
  String get roomTemperature => 'Suhu ruang';

  @override
  String get fedImmediately => 'Langsung diberikan';

  @override
  String get breakfast => 'Sarapan';

  @override
  String get lunch => 'Makan siang';

  @override
  String get dinner => 'Makan malam';

  @override
  String get snack => 'Camilan';

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sunday => 'Minggu';

  @override
  String get on => 'Hidup';

  @override
  String get off => 'Mati';

  @override
  String get weightChange => 'Perubahan Berat Badan';

  @override
  String get heightChange => 'Perubahan Tinggi Badan';

  @override
  String get totalRecords => 'Total Catatan';

  @override
  String get totalChange => 'Perubahan Total';

  @override
  String get start => 'Mulai';

  @override
  String get memo => 'Memo';

  @override
  String get weightDataEmpty => 'Tidak ada data berat badan tersedia';

  @override
  String get heightDataEmpty => 'Tidak ada data tinggi badan tersedia';

  @override
  String get undoAction => 'Batalkan';

  @override
  String get feedingRecordDeleted => 'Catatan pemberian makan dihapus';

  @override
  String get sleepRecordDeleted => 'Catatan tidur dihapus';

  @override
  String get diaperRecordDeleted => 'Catatan popok dihapus';

  @override
  String get healthRecordDeleted => 'Catatan kesehatan dihapus';

  @override
  String get deletionError => 'Terjadi kesalahan saat menghapus';

  @override
  String get duplicateInputDetected => 'Input duplikat terdeteksi';

  @override
  String get solidFoodDuplicateConfirm =>
      'Anda baru saja mencatat makanan padat.\\nApakah Anda benar-benar ingin mencatatnya lagi?';

  @override
  String get cannotOpenSettings => 'Tidak dapat membuka layar pengaturan';

  @override
  String get sleepQualityGood => 'Baik';

  @override
  String get sleepQualityFair => 'Sedang';

  @override
  String get sleepQualityPoor => 'Buruk';

  @override
  String sleepInProgressDuration(Object minutes) {
    return 'Sedang Tidur - ${minutes}m berlalu';
  }

  @override
  String get wetOnly => 'Hanya Basah';

  @override
  String get dirtyOnly => 'Hanya Kotor';

  @override
  String get wetAndDirty => 'Basah + Kotor';

  @override
  String get colorLabel => 'Warna';

  @override
  String get consistencyLabel => 'Konsistensi';

  @override
  String get topicalMedication => 'Topikal';

  @override
  String get inhaledMedication => 'Inhalasi';

  @override
  String get milkPumpingInProgress => 'Memompa';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return 'Memompa - ${minutes}m berlalu';
  }

  @override
  String get lowGradeFever => 'Demam Ringan';

  @override
  String get normalTemperature => 'Normal';

  @override
  String get allActivities => 'Semua';

  @override
  String get temperatureFilter => 'Suhu';

  @override
  String get deleteRecordTitle => 'Hapus Catatan';

  @override
  String get deleteRecordMessage =>
      'Apakah Anda yakin ingin menghapus catatan ini?\nCatatan yang dihapus tidak dapat dipulihkan.';

  @override
  String get recordDeletedSuccess => 'Catatan telah dihapus';

  @override
  String get recordDeleteFailed => 'Gagal menghapus catatan';

  @override
  String get recordDeleteError => 'Terjadi kesalahan saat menghapus catatan';

  @override
  String get recordUpdatedSuccess => 'Catatan telah diperbarui';

  @override
  String get recordUpdateFailed => 'Gagal memperbarui catatan';

  @override
  String get recordUpdateError => 'Terjadi kesalahan saat memperbarui catatan';

  @override
  String noRecordsToday(Object recordType) {
    return 'Tidak ada catatan $recordType hari ini';
  }

  @override
  String get healthRecordRestored => 'Catatan kesehatan telah dipulihkan';

  @override
  String get deleteTemperatureConfirm =>
      'Apakah Anda ingin menghapus catatan suhu terbaru?';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maksimum';

  @override
  String get duplicateEntryDetected => 'Entri duplikat terdeteksi';

  @override
  String get feedingDuplicateConfirm =>
      'Anda baru saja menambahkan catatan menyusui.\\nApakah Anda benar-benar ingin mencatat lagi?';

  @override
  String get milkPumpingDuplicateConfirm =>
      'Anda baru saja menambahkan catatan memompa ASI.\\nApakah Anda benar-benar ingin mencatat lagi?';

  @override
  String get medicationDuplicateConfirm =>
      'Anda baru saja mencatat obat.\\nApakah Anda benar-benar ingin mencatat lagi?';

  @override
  String get diaperDuplicateConfirm =>
      'Anda baru saja mencatat penggantian popok.\\nApakah Anda benar-benar ingin mencatat lagi?';

  @override
  String get sleepStartDuplicateConfirm =>
      'Anda baru saja memanipulasi tidur.\\nApakah Anda benar-benar ingin memulai tidur?';

  @override
  String get sleepEndDuplicateConfirm =>
      'Anda baru saja memanipulasi tidur.\\nApakah Anda benar-benar ingin mengakhiri tidur?';

  @override
  String get recordAction => 'Catat';

  @override
  String get end => 'Selesai';

  @override
  String get whatTypeChanged => 'Jenis apa yang Anda ganti?';

  @override
  String get poop => 'Tinja';

  @override
  String get urinePoop => 'Urin+Tinja';

  @override
  String get changeType => 'Jenis Penggantian';

  @override
  String get colorWhenPoop => 'Warna (Saat Buang Air Besar)';

  @override
  String get minutesShort => 'm';

  @override
  String get totalFeedingDuration => 'Total durasi menyusui';

  @override
  String get maximumFeedingAmount => 'Jumlah menyusui maksimum';

  @override
  String get minimumFeedingAmount => 'Jumlah menyusui minimum';

  @override
  String get totalSleepDuration => 'Total durasi tidur';

  @override
  String get dailyTotalMilkPumpingAmount => 'Total jumlah harian yang dipompa';

  @override
  String get maximumSleepDuration => 'Durasi tidur maksimum';

  @override
  String get minimumSleepDuration => 'Durasi tidur minimum';

  @override
  String get allergicReactionCount => 'Jumlah reaksi alergi';

  @override
  String get dailyAverageMilkPumpingCount =>
      'Rata-rata jumlah pompa ASI harian';

  @override
  String get growthInfoRecord => 'Catatan Informasi Pertumbuhan';

  @override
  String get recordBabyCurrentWeight =>
      'Silakan catat berat badan bayi saat ini';

  @override
  String get recordBabyCurrentHeight =>
      'Silakan catat tinggi badan bayi saat ini';

  @override
  String get measurementItems => 'Item Pengukuran';

  @override
  String get memoOptional => 'Catatan (Opsional)';

  @override
  String get enterWeight => 'Masukkan berat badan';

  @override
  String get enterHeight => 'Masukkan tinggi badan';

  @override
  String get recordSpecialNotesWeight =>
      'Catat catatan khusus saat mengukur berat badan (opsional)';

  @override
  String get recordSpecialNotesHeight =>
      'Catat catatan khusus saat mengukur tinggi badan (opsional)';

  @override
  String get weightInvalidNumber =>
      'Silakan masukkan angka yang valid untuk berat badan';

  @override
  String get weightRangeError => 'Berat badan harus antara 0,1-50kg';

  @override
  String get heightInvalidNumber =>
      'Silakan masukkan angka yang valid untuk tinggi badan';

  @override
  String get heightRangeError => 'Tinggi badan harus antara 1-200cm';

  @override
  String get enterWeightOrHeight =>
      'Silakan masukkan berat badan atau tinggi badan';

  @override
  String get saveError => 'Terjadi kesalahan saat menyimpan';
}
