// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get user => 'Kullanıcı';

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
  String get registerBaby => 'Kayıt Ol Bebek';

  @override
  String get noBabiesRegistered => 'Hayır babies registered';

  @override
  String get registerFirstBaby => 'Kayıt Ol your first baby!';

  @override
  String get registerBabyButton => 'Kayıt Ol Bebek';

  @override
  String birthday(int year, int month, int day) {
    return 'Doğum Günü: $year/$month/$day';
  }

  @override
  String age(int days) {
    return 'Yaş: $days days';
  }

  @override
  String gender(String gender) {
    return 'Cinsiyet';
  }

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

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
  String get babyName => 'Bebek İsim';

  @override
  String get babyNameHint => 'e.g. Emma';

  @override
  String get babyNameRequired => 'Please enter baby\'s name';

  @override
  String get babyNameMinLength => 'İsim must be at least 2 characters';

  @override
  String get selectBirthdateButton => 'Select Birthdate';

  @override
  String selectedDate(int year, int month, int day) {
    return '$year/$month/$day';
  }

  @override
  String get genderOptional => 'Cinsiyet (Optional)';

  @override
  String get cancel => 'İptal';

  @override
  String get loginFailed => 'Giriş Yap failed';

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
  String get loginWithKakao => 'Giriş Yap with Kakao';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Language';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Please enter baby\'s name';

  @override
  String get nameMinLength => 'İsim must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get appearance => 'Appearance';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get timeline => 'Timeline';

  @override
  String get record => 'Kayıt';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get community => 'Community';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get timelineUpdateMessage => 'Timeline feature will be updated soon';

  @override
  String get recordUpdateMessage => 'Kayıt feature will be updated soon';

  @override
  String get statisticsUpdateMessage =>
      'İstatistikler feature will be updated soon';

  @override
  String get communityUpdateMessage => 'Community feature will be updated soon';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get growthInfo => 'Büyüme Info';

  @override
  String get lastFeeding => 'Son Beslenme';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Beslenme';

  @override
  String get totalFeeding => 'Total Beslenme';

  @override
  String get sleep => 'Uyku';

  @override
  String get totalSleepTime => 'Total Uyku Zaman';

  @override
  String get cardSettings => 'Card Ayarlar';

  @override
  String get cardSettingsGuide => 'Card Ayarlar Guide';

  @override
  String get cardSettingsDescription =>
      '• Toggle switches to show/hide cards • Drag to change card order • Changes are previewed in real-time';

  @override
  String get cardVisible => 'Visible';

  @override
  String get cardHidden => 'Hidden';

  @override
  String get save => 'Kaydet';

  @override
  String get cardSettingsSaved => 'Card settings saved';

  @override
  String get cardSettingsError => 'Hata occurred while saving settings';

  @override
  String get discardChanges => 'Discard changes and return to previous state?';

  @override
  String get continueEditing => 'Continue Editing';

  @override
  String get discardChangesExit => 'Exit without saving changes?';

  @override
  String get exit => 'Exit';

  @override
  String get diaper => 'Bez';

  @override
  String get solidFood => 'Solid Yemek';

  @override
  String get medication => 'Medication';

  @override
  String get milkPumping => 'Milk Pumping';

  @override
  String get temperature => 'Sıcaklık';

  @override
  String get growth => 'Büyüme';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Beslenme Miktar';

  @override
  String get feedingRecordAdded => 'Beslenme record added successfully';

  @override
  String get feedingRecordFailed => 'Failed to add feeding record';

  @override
  String get feedingRecordsLoadFailed => 'Failed to load feeding records';

  @override
  String get quickFeeding => 'Quick Beslenme';

  @override
  String get feedingTime => 'Beslenme Zaman';

  @override
  String get feedingType => 'Feeding Type';

  @override
  String get breastfeeding => 'Breastfeeding';

  @override
  String get bottleFeeding => 'Bottle Beslenme';

  @override
  String get mixedFeeding => 'Mixed Beslenme';

  @override
  String sleepCount(Object count) {
    return '$count times';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get sleepStarted => 'Uyku started';

  @override
  String get sleepEnded => 'Uyku ended';

  @override
  String get sleepInProgress => 'Sleeping';

  @override
  String get sleepRecordFailed => 'Failed to process sleep record';

  @override
  String get sleepRecordsLoadFailed => 'Failed to load sleep records';

  @override
  String get sleepTime => 'Uyku Zaman';

  @override
  String get wakeUpTime => 'Wake Up Zaman';

  @override
  String get sleepDurationLabel => 'Uyku Süre';

  @override
  String get napTime => 'Nap Zaman';

  @override
  String get nightSleep => 'Night Uyku';

  @override
  String diaperCount(Object count) {
    return '$count times';
  }

  @override
  String get diaperChanged => 'Bez changed';

  @override
  String get diaperRecordAdded => 'Bez change record added successfully';

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
  String get diaperType => 'Bez Tür';

  @override
  String get diaperChangeTime => 'Change Zaman';

  @override
  String get weight => 'Ağırlık';

  @override
  String get height => 'Boy';

  @override
  String get growthRecord => 'Büyüme Kayıt';

  @override
  String get growthRecordAdded => 'Büyüme record added';

  @override
  String get growthRecordFailed => 'Failed to save growth record';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => 'Measurement Tür';

  @override
  String get measurementValue => 'Value';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get temperatureRange => 'Sıcaklık must be between 30.0°C and 45.0°C';

  @override
  String get weightRange => 'Ağırlık must be between 0.1kg and 50kg';

  @override
  String get heightRange => 'Boy must be between 1cm and 200cm';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get recordGrowthInfo => 'Kayıt Büyüme Bilgi';

  @override
  String currentMeasurement(Object type) {
    return 'Enter current $type';
  }

  @override
  String get measurementSituation =>
      'Kayıt measurement situation or special notes (optional)';

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
      'Oluştur a nickname to use in the community. It will be displayed to other users.';

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
  String get addImages => 'Ekle Images';

  @override
  String imageSelectFailed(Object error) {
    return 'Resim selection failed: $error';
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
  String get userNotFound => 'Kullanıcı information not found';

  @override
  String get statisticsTitle => 'İstatistikler';

  @override
  String get noStatisticsData => 'Hayır İstatistikler Data';

  @override
  String statisticsDescription(Object period) {
    return 'Hayır activities recorded during $period. Başlat recording your baby\'s activities!';
  }

  @override
  String get recordActivity => 'Kayıt Activity';

  @override
  String get viewOtherPeriod => 'Görüntüle Other Period';

  @override
  String get refresh => 'Yenile';

  @override
  String get statisticsTips => 'To view statistics?';

  @override
  String get statisticsTip1 =>
      'Kayıt activities like feeding, sleep, diaper changes';

  @override
  String get statisticsTip2 =>
      'At least one day of data is required for statistics';

  @override
  String get statisticsTip3 => 'You can record easily from the home screen';

  @override
  String get saveAsImage => 'Kaydet as Resim';

  @override
  String get saveAsImageDescription => 'Kaydet statistics as image';

  @override
  String get shareAsText => 'Paylaş as Text';

  @override
  String get shareAsTextDescription => 'Paylaş statistics summary as text';

  @override
  String get statisticsEmptyState => 'Hayır statistics data';

  @override
  String get retryButton => 'Try Again';

  @override
  String get detailsButton => 'Details';

  @override
  String get goHomeButton => 'Go Ana Sayfa';

  @override
  String get applyButton => 'Uygula';

  @override
  String get lastWeek => 'Son Week';

  @override
  String get lastMonth => 'Son Month';

  @override
  String get last3Months => 'Son 3 Months';

  @override
  String get allTime => 'All Zaman';

  @override
  String get viewOtherPeriodTitle => 'Görüntüle Other Period';

  @override
  String get familyInvitation => 'Family Invitation';

  @override
  String get invitationDescription =>
      'Manage baby records together with your family using invitation codes';

  @override
  String get createInvitation => 'Oluştur Invitation';

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
  String get shareInvitation => 'Paylaş Invitation';

  @override
  String get shareImmediately => 'Paylaş Now';

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
  String get ok => 'Tamam';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get add => 'Ekle';

  @override
  String get remove => 'Kaldır';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Geri';

  @override
  String get next => 'Sonraki';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarı';

  @override
  String get warning => 'Uyarı';

  @override
  String get info => 'Bilgi';

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
  String get saveFailed => 'Kaydet failed';

  @override
  String get loadFailed => 'Load failed';

  @override
  String updateFailed(String error) {
    return 'Güncelle failed: $error';
  }

  @override
  String deleteFailed(String error) {
    return 'Sil failed: $error';
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
  String get solidFoodType => 'Yemek Tür';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => 'Solid food record added';

  @override
  String get milkPumpingAmount => 'Pumping Miktar';

  @override
  String get milkPumpingTime => 'Pumping Zaman';

  @override
  String get milkPumpingAdded => 'Milk pumping record added';

  @override
  String get temperatureReading => 'Sıcaklık Reading';

  @override
  String get temperatureNormal => 'Normal';

  @override
  String get temperatureHigh => 'Yüksek';

  @override
  String get temperatureLow => 'Düşük';

  @override
  String get profilePhoto => 'Profile Fotoğraf';

  @override
  String get profilePhotoUpdate => 'Güncelle Profile Fotoğraf';

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
  String get addImage => 'Ekle Resim';

  @override
  String get removeImage => 'Kaldır Resim';

  @override
  String maxImagesReached(Object count) {
    return 'Maximum $count images allowed';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$months months $days days';
  }

  @override
  String get lastFeedingTime => 'Son feeding time';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours hours $minutes minutes ago';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return 'Sonraki feeding in about ${hours}h ${minutes}m';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return 'Sonraki feeding in about $minutes minutes';
  }

  @override
  String get feedingTimeNow => 'It\'s feeding time now 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'Beslenme time soon ($minutes minutes)';
  }

  @override
  String get feedingTimeOverdue => 'Beslenme time overdue';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return 'Beslenme alarm in ${hours}h ${minutes}m';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return 'Beslenme alarm in $minutes minutes';
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
  String get viewDetails => 'Görüntüle Details';

  @override
  String get firstRecord => 'İlk Kayıt';

  @override
  String get noChange => 'Hayır Change';

  @override
  String get inProgress => 'In Progress';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get startBabyRecording =>
      'Kayıt Ol your baby and start tracking growth';

  @override
  String get registerBabyNow => 'Kayıt Ol Bebek';

  @override
  String get joinWithInviteCode => 'Join with Invitation Code';

  @override
  String get loadingBabyInfo => 'Loading baby information...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Go to Ayarlar';

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
    return 'Hakkında $count times';
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
  String get noActivitiesInTimeframe => 'Hayır activities during this time';

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
      'Kayıt your first precious moment. Small daily changes add up to great growth.';

  @override
  String get pattern => 'Pattern';

  @override
  String get qualityGood => 'İyi';

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
  String get babyFood => 'Bebek Yemek';

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
  String get diaperChange => 'Bez Change';

  @override
  String get oralMedication => 'Oral Medication';

  @override
  String get topical => 'Topical';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Sıcaklık Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Düşük Fever';

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
    return 'Hayır activities were recorded during $period.';
  }

  @override
  String get recordBabyActivities => 'Kayıt your baby\'s activities!';

  @override
  String get howToViewStatistics => 'How to view statistics?';

  @override
  String get recordActivitiesLikeFeedingSleep =>
      'Kayıt activities like feeding, sleep, diaper changes, etc.';

  @override
  String get atLeastOneDayDataRequired =>
      'At least one day of data is required to display statistics.';

  @override
  String get canRecordEasilyFromHome =>
      'You can easily record activities from the home screen.';

  @override
  String get updating => 'Updating...';

  @override
  String get lastUpdated => 'Son updated:';

  @override
  String get periodSelection => 'Period selection:';

  @override
  String get daily => 'Daily';

  @override
  String get startDate => 'Başlat Tarih';

  @override
  String get endDate => 'Son Tarih';

  @override
  String get apply => 'Uygula';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get detailedStatistics => 'Detailed İstatistikler';

  @override
  String get chartAnalysis => 'Grafik Analysis';

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
  String get goToHome => 'Go to Ana Sayfa';

  @override
  String get troubleshootingMethods => 'Troubleshooting Methods';

  @override
  String get shareStatistics => 'Paylaş İstatistikler';

  @override
  String get communitySubtitle => 'Sharing Parenting Stories Together';

  @override
  String get search => 'Ara';

  @override
  String get notification => 'Notification';

  @override
  String get searchFeatureComingSoon => 'Ara feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Paylaş parenting experiences and valuable information with other parents';

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
  String get categorySleepIssues => 'Uyku Issues';

  @override
  String get categoryBabyFood => 'Bebek Yemek';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categoryVaccination => 'Vaccination';

  @override
  String get categoryPostpartum => 'Postpartum';

  @override
  String get sortByLikes => 'Sırala by Likes';

  @override
  String get sortByLatest => 'Sırala by Latest';

  @override
  String get edited => '(edited)';

  @override
  String commentsCount(int count) {
    return '$count comments';
  }

  @override
  String get deletePost => 'Sil Post';

  @override
  String get deletePostConfirm =>
      'Are you sure you want to delete this post? Deleted posts cannot be recovered.';

  @override
  String get deletePostSuccess => 'Post has been deleted.';

  @override
  String deletePostError(Object error) {
    return 'Sil failed: $error';
  }

  @override
  String get postNotFound => 'Post not found';

  @override
  String get shareFeatureComingSoon => 'Paylaş feature coming soon';

  @override
  String get loadingComments => 'Loading comments...';

  @override
  String get loadMoreComments => 'Load More Comments';

  @override
  String get editComment => 'Düzenle Comment';

  @override
  String get editCommentHint => 'Düzenle your comment...';

  @override
  String get editCommentSuccess => 'Comment has been updated.';

  @override
  String editCommentError(Object error) {
    return 'Düzenle failed: $error';
  }

  @override
  String get deleteComment => 'Sil Comment';

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
      'Paylaş your thoughts... Feel free to write about your parenting experiences.';

  @override
  String imageSelectionError(Object error) {
    return 'Resim selection failed: $error';
  }

  @override
  String get userNotFoundError => 'Kullanıcı information not found.';

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
  String get addImageTooltip => 'Ekle Resim';

  @override
  String get allPostsChecked => 'All posts have been checked! 👍';

  @override
  String get waitForNewPosts => 'Please wait until new posts are uploaded';

  @override
  String get noPostsYet => 'Hayır posts yet';

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
  String get noRecordedMoments => 'Hayır recorded moments yet';

  @override
  String get loadingTimeline => 'Loading timeline...';

  @override
  String get noRecordsYet => 'Hayır records yet';

  @override
  String noRecordsForDate(Object date) {
    return 'Hayır records for $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Hayır $filter records for $date';
  }

  @override
  String get cannotRecordFuture => 'Cannot record future activities yet';

  @override
  String get addFirstRecord => 'Ekle your first record!';

  @override
  String get canAddPastRecord => 'You can add past records';

  @override
  String get addRecord => 'Ekle Kayıt';

  @override
  String get viewOtherDates => 'Görüntüle Other Dates';

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
  String get babyManagement => 'Bebek Management';

  @override
  String get addBaby => 'Ekle Bebek';

  @override
  String get noBabiesMessage => 'Hayır babies registered. Please add a baby.';

  @override
  String get switchToNextBaby => 'Switch to Sonraki Bebek';

  @override
  String get birthDate => 'Birth Tarih';

  @override
  String get registering => 'Registering...';

  @override
  String get register => 'Kayıt Ol';

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
  String get acceptInvite => 'Kabul Et Invitation';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name has been registered successfully';
  }

  @override
  String get babyRegistrationFailed => 'Bebek registration failed';

  @override
  String babyRegistrationError(String error) {
    return 'Hata occurred: $error';
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
  String get noBabyInfo => 'Hayır Bebek Bilgi';

  @override
  String get noBabyInfoDescription =>
      'Hayır baby information found. Would you like to create a test baby?';

  @override
  String get create => 'Oluştur';

  @override
  String get generateNewInviteCode => 'Generate New Invitation Code';

  @override
  String get replaceExistingCode =>
      'This will replace the existing invitation code. Do you want to continue?';

  @override
  String get acceptInvitation => 'Kabul Et Invitation';

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
      'Hayır login information found. Please login first.';

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
    return '$name\'s Bebek Care Guide';
  }

  @override
  String get babyGuide => 'Bebek Care Guide';

  @override
  String get noAvailableGuides => 'Hayır available guides';

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
  String get feedingGuide => '💡 Beslenme Guide';

  @override
  String get feedingFrequency => 'Beslenme Frequency';

  @override
  String get singleFeedingAmount => 'Beslenme Miktar';

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
  String get noRecentFeeding => 'Hayır recent feeding records';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get searchCommunityPosts => 'Ara community posts';

  @override
  String get temperatureRecord => 'Sıcaklık Kayıt';

  @override
  String get temperatureTrend => 'Sıcaklık Trend';

  @override
  String get profilePhotoSetup => 'Profile Fotoğraf Setup';

  @override
  String get howToSelectPhoto => 'How would you like to select a photo?';

  @override
  String get send => 'Gönder';

  @override
  String get emailVerificationRequired => 'E-posta Verification Required';

  @override
  String get passwordReset => 'Şifre Sıfırla';

  @override
  String get enterEmailForReset =>
      'Enter your registered email address. We\'ll send you a password reset link.';

  @override
  String get accountWithdrawalComplete => 'Account Withdrawal Tamamla';

  @override
  String get genderLabel => 'Cinsiyet:';

  @override
  String get birthdateLabel => 'Birthdate:';

  @override
  String get maleGender => 'Erkek';

  @override
  String get femaleGender => 'Kadın';

  @override
  String get joinWithInviteCodeButton => 'Join with Invite Code';

  @override
  String get temperatureRecorded => 'Sıcaklık recorded';

  @override
  String recordFailed(String error) {
    return 'Kayıt failed';
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
  String get accountLinkingComplete => 'Account Linking Tamamla';

  @override
  String get deleteConfirmation => 'Sil Confirmation';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get babyNameLabel => 'Bebek İsim';

  @override
  String get weightInput => 'Enter weight';

  @override
  String get heightInput => 'Enter height';

  @override
  String get measurementNotes =>
      'Kayıt measurement conditions or special notes (optional)';

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
  String get good => 'İyi';

  @override
  String get average => 'Average';

  @override
  String get poor => 'Poor';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get illness => 'Illness';

  @override
  String get highFever => 'Yüksek Fever';

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
  String get solidFoodTime => 'Solid Yemek';

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
  String get sleepIssues => 'Uyku Issues';

  @override
  String get babyFoodCategory => 'Bebek Yemek';

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
  String get searchError => 'Ara error';

  @override
  String get question => 'Question';

  @override
  String get information => 'Bilgi';

  @override
  String get relevance => 'Relevance';

  @override
  String get searchSuggestions => 'Ara suggestions';

  @override
  String get noSearchResults => 'Hayır search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get likeFeatureComingSoon => 'Like feature coming soon';

  @override
  String get popularSearchTerms => 'Popular search terms';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get deleteAll => 'Sil All';

  @override
  String get sortByComments => 'Sırala by comments';

  @override
  String get detailInformation => 'Detail Bilgi';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recordAgain => 'Kayıt Again';

  @override
  String get share => 'Paylaş';

  @override
  String get deleteRecord => 'Sil Kayıt';

  @override
  String get deleteRecordConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get recordDeleted => 'Kayıt deleted';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get editRecord => 'Düzenle Kayıt';

  @override
  String get dateTime => 'Tarih & Zaman';

  @override
  String get date => 'Tarih';

  @override
  String get time => 'Zaman';

  @override
  String get amount => 'Miktar';

  @override
  String get duration => 'Süre';

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
  String get saveChanges => 'Kaydet Changes';

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
  String get sleepProgressTime => 'Uyku Progress Zaman';

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
  String get previousDate => 'Önceki date';

  @override
  String get nextDate => 'Sonraki date';

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
  String get addBabyFromHome => 'Ekle baby from home';

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
  String get noDetailedData => 'Hayır detailed data';

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
  String get customSettings => 'Custom Ayarlar';

  @override
  String get selectDateRange => 'Select Tarih Range';

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
  String get feedingTimeNotificationBody => 'Bebek might be hungry now.';

  @override
  String get feedingAlarmChannelName => 'Beslenme Reminders';

  @override
  String get feedingAlarmChannelDescription =>
      'Beslenme time reminder notifications';

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
  String get durationTab => 'Süre';

  @override
  String get chartDataLoading => 'Loading chart data...';

  @override
  String get chartDataNotAvailable => 'Grafik data not available.';

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
    return '$name\'s Sıcaklık Kayıt';
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
  String get saveTemperatureRecord => 'Kaydet Sıcaklık Kayıt';

  @override
  String get enterTemperature => 'Please enter temperature';

  @override
  String get temperatureRangeValidation =>
      'Sıcaklık must be between 34.0°C ~ 42.0°C';

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
      'Hayır temperature records in selected period';

  @override
  String get temperatureChangeTrend => 'Sıcaklık Change Trend';

  @override
  String get averageTemperature => 'Average Sıcaklık';

  @override
  String get highestTemperature => 'Highest Sıcaklık';

  @override
  String get lowestTemperature => 'Lowest Sıcaklık';

  @override
  String get noteAvailableTapToView => '📝 Note available (tap to view)';

  @override
  String get temperatureRisingTrend => 'Sıcaklık is showing a rising trend';

  @override
  String get temperatureFallingTrend => 'Sıcaklık is showing a falling trend';

  @override
  String get temperatureStableTrend => 'Sıcaklık is stable';

  @override
  String get trendAnalysis => 'Trend Analysis';

  @override
  String totalMeasurements(int count) {
    return 'Total $count measurements';
  }

  @override
  String get temperatureRecordMemo => 'Sıcaklık Kayıt Memo';

  @override
  String babyGrowthChart(String name) {
    return '$name\'s Büyüme Grafik';
  }

  @override
  String get noGrowthRecords => 'Hayır growth records';

  @override
  String get enterWeightAndHeightFromHome =>
      'Please enter weight and height from home screen';

  @override
  String get all => 'All';

  @override
  String get growthInsights => 'Büyüme Insights';

  @override
  String get growthRate => 'Büyüme Rate';

  @override
  String get monthlyAverageGrowth => 'Monthly Average Büyüme';

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
  String get recordFrequency => 'Kayıt Frequency';

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
  String get nextRecord => 'Sonraki Kayıt';

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
  String get nextMilestone => 'Sonraki Milestone';

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
  String get noDataAvailable => 'Hayır data available';

  @override
  String get weightRecordRequired => 'Ağırlık record required';

  @override
  String get heightRecordRequired => 'Boy record required';

  @override
  String get currentRecordMissing => 'Current record missing';

  @override
  String get noRecord => 'Hayır record';

  @override
  String get firstRecordStart => 'Başlat your first record';

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
  String get pumpingType => 'Pumping Tür';

  @override
  String get foodName => 'Food Name';

  @override
  String get mealType => 'Meal Tür';

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
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get weightChange => 'Ağırlık Change';

  @override
  String get heightChange => 'Boy Change';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get totalChange => 'Total Change';

  @override
  String get start => 'Başlat';

  @override
  String get memo => 'Memo';

  @override
  String get weightDataEmpty => 'Hayır weight data available';

  @override
  String get heightDataEmpty => 'Hayır height data available';

  @override
  String get undoAction => 'Undo';

  @override
  String get feedingRecordDeleted => 'Beslenme record deleted';

  @override
  String get sleepRecordDeleted => 'Uyku record deleted';

  @override
  String get diaperRecordDeleted => 'Bez record deleted';

  @override
  String get healthRecordDeleted => 'Health record deleted';

  @override
  String get deletionError => 'Hata occurred during deletion';

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
  String get lowGradeFever => 'Düşük Grade Fever';

  @override
  String get normalTemperature => 'Temperature is normal';

  @override
  String get allActivities => 'All';

  @override
  String get temperatureFilter => 'Sıcaklık';

  @override
  String get deleteRecordTitle => 'Sil Kayıt';

  @override
  String get deleteRecordMessage =>
      'Are you sure you want to delete this record? Deleted records cannot be recovered.';

  @override
  String get recordDeletedSuccess => 'Kayıt has been deleted';

  @override
  String get recordDeleteFailed => 'Failed to delete record';

  @override
  String get recordDeleteError => 'An error occurred while deleting the record';

  @override
  String get recordUpdatedSuccess => 'Kayıt has been updated';

  @override
  String get recordUpdateFailed => 'Failed to update record';

  @override
  String get recordUpdateError => 'An error occurred while updating the record';

  @override
  String noRecordsToday(Object recordType) {
    return 'Hayır $recordType records today';
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
  String get recordAction => 'Kayıt';

  @override
  String get end => 'Son';

  @override
  String get whatTypeChanged => 'What type did you change?';

  @override
  String get poop => 'Poop';

  @override
  String get urinePoop => 'Urine+Poop';

  @override
  String get changeType => 'Change Tür';

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
  String get growthInfoRecord => 'Büyüme Bilgi Kayıt';

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
      'Kayıt special notes when measuring weight (optional)';

  @override
  String get recordSpecialNotesHeight =>
      'Kayıt special notes when measuring height (optional)';

  @override
  String get weightInvalidNumber => 'Please enter a valid number for weight';

  @override
  String get weightRangeError => 'Ağırlık should be between 0.1~50kg';

  @override
  String get heightInvalidNumber => 'Please enter a valid number for height';

  @override
  String get heightRangeError => 'Boy should be between 1~200cm';

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
  String get shareFeatureInDevelopment => 'Paylaş feature is under development';

  @override
  String get sortByRecent => 'Sırala by Recent';

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
    return 'Görüntüle $count more replies';
  }

  @override
  String get copy => 'Copy';

  @override
  String get report => 'Rapor';

  @override
  String get commentCopied => 'Comment has been copied';

  @override
  String get reportComment => 'Rapor Comment';

  @override
  String get confirmReportComment =>
      'Do you want to report this comment? It will be reported as inappropriate content or spam.';

  @override
  String get reportSubmitted => 'Rapor has been submitted.';

  @override
  String get serviceInPreparation => '💝 Service in Preparation';

  @override
  String get upcomingServiceDescription =>
      'We will soon introduce useful parenting information and products';

  @override
  String get accountInfo => 'Account Bilgi';

  @override
  String get userID => 'Kullanıcı ID';

  @override
  String get email => 'E-posta';

  @override
  String get loginMethod => 'Giriş Yap Method';

  @override
  String get noEmail => 'Hayır email';

  @override
  String get accountDeletion => 'Account Deletion';

  @override
  String get allDataWillBePermanentlyDeleted =>
      'All data will be permanently deleted';

  @override
  String get accountDeletionWarning =>
      '⚠️ The following data will be permanently deleted when you delete your account:';

  @override
  String get userAccountInfo => '• Kullanıcı account information';

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
  String get confirmButton => 'Tamam';

  @override
  String get accountDeletionCompleteTitle => 'Account Deletion Tamamla';

  @override
  String get resetBaby => 'Sıfırla';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get birthDateLabel => 'Birth Tarih:';

  @override
  String get genderColon => 'Cinsiyet:';

  @override
  String babyInfoResetQuestion(Object babyName) {
    return 'Do you want to reset $babyName information from the beginning?';
  }

  @override
  String get recordsWillBeReset => 'The following records will be reset';

  @override
  String get feedingSleepDiaperRecords => 'Beslenme, sleep, diaper records';

  @override
  String get growthInfoAndPhotos => 'Büyüme information and photos';

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
  String get emailProvider => 'E-posta';

  @override
  String get unknownProvider => 'Unknown';

  @override
  String get accountDeletionPartialErrorMessage =>
      'Some processing encountered issues but logout is completed. Redirecting to login screen.';
}
