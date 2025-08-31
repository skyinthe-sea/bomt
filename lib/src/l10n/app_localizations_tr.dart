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
    return 'Kullanıcı bilgileri yüklenemedi: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Bebek listesi yüklenirken hata: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Merhaba $userName!';
  }

  @override
  String get registerBaby => 'Bebek kaydet';

  @override
  String get noBabiesRegistered => 'Kayıtlı bebek yok';

  @override
  String get registerFirstBaby => 'İlk bebeğinizi kaydedin!';

  @override
  String get registerBabyButton => 'Bebek kaydet';

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
    return 'Cinsiyet';
  }

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kız';

  @override
  String get other => 'Diğer';

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
  String get enterBabyInfo => 'Bebek bilgilerini girin';

  @override
  String get babyName => 'Bebek adı';

  @override
  String get babyNameHint => 'örn: Elif';

  @override
  String get babyNameRequired => 'Bebek adını girin';

  @override
  String get babyNameMinLength => 'Ad en az 2 karakter olmalı';

  @override
  String get selectBirthdateButton => 'Doğum tarihini seç';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day.$month.$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'İptal';

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
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Bebek adını girin';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get darkMode => 'Karanlık mod';

  @override
  String get appearance => 'Görünüm';

  @override
  String get home => 'Home';

  @override
  String get timeline => 'Timeline';

  @override
  String get record => 'Record';

  @override
  String get statistics => 'Statistics';

  @override
  String get community => 'Community';

  @override
  String get comingSoon => 'Yakında';

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
  String get growthInfo => 'Büyüme Bilgisi';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Beslenme';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Uyku';

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
  String get diaper => 'Bez';

  @override
  String get solidFood => 'Katı Gıda';

  @override
  String get medication => 'İlaç';

  @override
  String get milkPumping => 'Süt Sağma';

  @override
  String get temperature => 'Sıcaklık';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Beslenme miktarı';

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
  String get sleepInProgress => 'In Progress';

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
  String get weight => 'Ağırlık';

  @override
  String get height => 'Boy';

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
  String get enterValidNumber => 'Lütfen geçerli bir sayı girin';

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
  String get writePost => 'Gönderi Yaz';

  @override
  String get post => 'Gönder';

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
  String get selectCategory => 'Kategori seç';

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
    return 'İçerik: $count/10000';
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
  String get refresh => 'Yenile';

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
  String get familyInvitation => 'Aile daveti';

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
  String get delete => 'Sil';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Onayla';

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
    return '$minutes dakika önce';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Bugün';

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
  String get medicationTime => 'İlaç';

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
    return '$months ay $days gün';
  }

  @override
  String get lastFeedingTime => 'Son beslenme zamanı';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours saat $minutes dakika önce';
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
  String get hoursUnit => 'hours';

  @override
  String get minutesUnit => 'minutes';

  @override
  String get viewDetails => 'Detayları Görüntüle';

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
  String get joinWithInviteCode => 'Davet koduyla katıl';

  @override
  String get loadingBabyInfo => 'Bebek bilgileri yükleniyor...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Ayarlara git';

  @override
  String get profilePhotoUpdated => 'Profil fotoğrafı güncellendi.';

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
  String get hourActivityPattern => '24 Saatlik Aktivite Deseni';

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
  String get todaysStory => 'Bugünün Hikayesi';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'İlk değerli anınızı kaydedin.\nKüçük günlük değişiklikler büyük bir büyüme oluşturur.';

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
  String get formula => 'Formül';

  @override
  String get breastMilk => 'Anne sütü';

  @override
  String get babyFood => 'Bebek maması';

  @override
  String get left => 'Sol';

  @override
  String get right => 'Sağ';

  @override
  String get both => 'Her ikisi';

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
  String get diaperChange => 'Diaper Change';

  @override
  String get oralMedication => 'Oral medication';

  @override
  String get topical => 'Cilde';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Ateş';

  @override
  String get lowFever => 'Düşük ateş';

  @override
  String get hypothermia => 'Hipotermi';

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
  String get periodSelection => 'Period Selection';

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
  String get detailedStatistics => 'Detaylı İstatistikler';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Genel Aktivite Özeti';

  @override
  String get totalActivities => 'Toplam Aktiviteler';

  @override
  String get activeCards => 'Aktif Kartlar';

  @override
  String get dailyAverage => 'Günlük Ortalama';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Tekrar dene';

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
  String get search => 'Ara';

  @override
  String get notification => 'Bildirim';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Ebeveynlik deneyimlerinizi ve değerli bilgileri diğer ebeveynlerle paylaşın';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Tümü';

  @override
  String get categoryPopular => 'Popüler';

  @override
  String get categoryClinical => 'Klinik';

  @override
  String get categoryInfoSharing => 'Bilgi paylaşımı';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Bebek maması';

  @override
  String get categoryDevelopment => 'Gelişim';

  @override
  String get categoryVaccination => 'Aşılama';

  @override
  String get categoryPostpartum => 'Doğum sonrası';

  @override
  String get sortByLikes => 'Beğeniye göre sırala';

  @override
  String get sortByLatest => 'En yeniye göre sırala';

  @override
  String get edited => '(düzenlendi)';

  @override
  String commentsCount(Object count) {
    return '$count yorum';
  }

  @override
  String get deletePost => 'Gönderisini sil';

  @override
  String get deletePostConfirm =>
      'Bu gönderiyi silmek istediğinizden emin misiniz?\\nSilinen gönderiler geri alınamaz.';

  @override
  String get deletePostSuccess => 'Gönderi silindi.';

  @override
  String deletePostError(Object error) {
    return 'Silme başarısız: $error';
  }

  @override
  String get postNotFound => 'Gönderi bulunamadı';

  @override
  String get shareFeatureComingSoon => 'Paylaşım özelliği yakında';

  @override
  String get loadingComments => 'Yorumlar yükleniyor...';

  @override
  String get loadMoreComments => 'Daha fazla yorum yükle';

  @override
  String get editComment => 'Yorumu düzenle';

  @override
  String get editCommentHint => 'Yorumunuzu düzenleyin...';

  @override
  String get editCommentSuccess => 'Yorum güncellendi.';

  @override
  String editCommentError(Object error) {
    return 'Düzenleme başarısız: $error';
  }

  @override
  String get deleteComment => 'Yorumu sil';

  @override
  String get deleteCommentConfirm =>
      'Bu yorumu silmek istediğinizden emin misiniz?\\nSilinen yorumlar geri alınamaz.';

  @override
  String get deleteCommentSuccess => 'Yorum silindi.';

  @override
  String get replySuccess => 'Yanıt gönderildi.';

  @override
  String get commentSuccess => 'Yorum gönderildi.';

  @override
  String get commentError => 'Yorum gönderilemedi.';

  @override
  String get titlePlaceholder => 'Başlık girin';

  @override
  String get contentPlaceholder =>
      'Düşüncelerinizi paylaşın...\\n\\nEbeveynlik deneyimleriniz hakkında özgürce yazın.';

  @override
  String imageSelectionError(Object error) {
    return 'Resim seçimi başarısız: $error';
  }

  @override
  String get userNotFoundError => 'Kullanıcı bilgileri bulunamadı.';

  @override
  String get postCreateSuccess => 'Gönderi başarıyla oluşturuldu!';

  @override
  String postCreateError(Object error) {
    return 'Gönderi oluşturulamadı: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Başlık: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Resimler: $count/5';
  }

  @override
  String get addImageTooltip => 'Resim ekle';

  @override
  String get allPostsChecked => 'Tüm gönderiler kontrol edildi! 👍';

  @override
  String get waitForNewPosts => 'Yeni gönderileri bekleyin';

  @override
  String get noPostsYet => 'Henüz gönderi yok';

  @override
  String get writeFirstPost => 'İlk gönderiyi yazın!';

  @override
  String get loadingNewPosts => 'Yeni gönderiler yükleniyor...';

  @override
  String get failedToLoadPosts => 'Gönderiler yüklenemedi';

  @override
  String get checkNetworkAndRetry =>
      'Bağlantınızı kontrol edin ve tekrar deneyin';

  @override
  String get categoryDailyLife => 'Günlük hayat';

  @override
  String get preparingTimeline => 'Zaman çizelgesi hazırlanıyor...';

  @override
  String get noRecordedMoments => 'Henüz kayıtlı anlar yok';

  @override
  String get loadingTimeline => 'Zaman çizelgesi yükleniyor...';

  @override
  String get noRecordsYet => 'Henüz kayıt yok';

  @override
  String noRecordsForDate(Object date) {
    return '$date için kayıt yok';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return '$date için $filter kaydı yok';
  }

  @override
  String get cannotRecordFuture => 'Gelecekteki aktiviteler henüz kaydedilemez';

  @override
  String get addFirstRecord => 'İlk kaydınızı ekleyin!';

  @override
  String get canAddPastRecord => 'Geçmiş kayıtları ekleyebilirsiniz';

  @override
  String get addRecord => 'Kayıt ekle';

  @override
  String get viewOtherDates => 'Diğer tarihleri görüntüle';

  @override
  String get goToToday => 'Bugüne git';

  @override
  String get quickRecordFromHome =>
      'Ana ekrandan hızlıca kayıt ekleyebilirsiniz';

  @override
  String detailViewComingSoon(String title) {
    return '$title detayları (Yakında)';
  }

  @override
  String get familyInvitationDescription =>
      'Davet kodları ile aile ile birlikte bebek bakımı kayıtlarını yönetin';

  @override
  String get babyManagement => 'Bebek yönetimi';

  @override
  String get addBaby => 'Bebek ekle';

  @override
  String get noBabiesMessage =>
      'Kayıtlı bebek yok.\\nLütfen bir bebek ekleyin.';

  @override
  String get switchToNextBaby => 'Sonraki bebeğe geç';

  @override
  String get birthDate => 'Doğum tarihi';

  @override
  String get registering => 'Kaydediliyor...';

  @override
  String get register => 'Kaydet';

  @override
  String careTogetherWith(String name) {
    return '$name ile birlikte bebek bakımı';
  }

  @override
  String get inviteFamilyDescription =>
      'Bebek bakımı kayıtlarını birlikte yönetmek için\\naile veya eşinizi davet edin';

  @override
  String get generateInviteCode => 'Davet kodu oluştur';

  @override
  String get generateInviteCodeDescription =>
      'Yeni davet kodu oluşturun ve kopyalayın';

  @override
  String get generateInviteCodeButton => 'Davet kodu oluştur';

  @override
  String get orText => 'Veya';

  @override
  String get enterInviteCodeDescription => 'Aldığınız davet kodunu girin';

  @override
  String get inviteCodePlaceholder => 'Davet kodu (6 haneli)';

  @override
  String get acceptInvite => 'Daveti kabul et';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name başarıyla kaydedildi';
  }

  @override
  String get babyRegistrationFailed => 'Bebek kaydı başarısız';

  @override
  String babyRegistrationError(String error) {
    return 'Hata oluştu: $error';
  }

  @override
  String babySelected(String name) {
    return '$name seçildi';
  }

  @override
  String get inviteCodeGenerated => 'Davet kodu oluşturuldu!';

  @override
  String remainingTime(String time) {
    return 'Kalan süre: $time';
  }

  @override
  String get validTime => 'Geçerlilik süresi: 5 dakika';

  @override
  String get generating => 'Oluşturuluyor...';

  @override
  String get joining => 'Katılıyor...';

  @override
  String get noBabyInfo => 'Bebek bilgisi yok';

  @override
  String get noBabyInfoDescription =>
      'Bebek bilgisi bulunamadı.\\nTest bebeği oluşturmak ister misiniz?';

  @override
  String get create => 'Oluştur';

  @override
  String get generateNewInviteCode => 'Yeni davet kodu oluştur';

  @override
  String get replaceExistingCode =>
      'Bu mevcut davet kodunu değiştirecek.\\nDevam etmek istiyor musunuz?';

  @override
  String get acceptInvitation => 'Daveti kabul et';

  @override
  String get acceptInvitationDescription =>
      'Daveti kabul edip aileye katılmak istiyor musunuz?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Mevcut bebek kayıtları silinecek ve davet edilen bebek ($babyName) ile değiştirilecek.\\n\\nDevam etmek istiyor musunuz?';
  }

  @override
  String get pleaseEnterInviteCode => 'Davet kodunu girin';

  @override
  String get inviteCodeMustBe6Digits => 'Davet kodu 6 haneli olmalı';

  @override
  String get pleaseLoginFirst =>
      'Giriş bilgileri bulunamadı. Lütfen önce giriş yapın.';

  @override
  String get copiedToClipboard => 'Davet kodu kopyalandı!';

  @override
  String get joinedSuccessfully => 'Başarıyla aileye katıldınız!';

  @override
  String get inviteCodeExpired => 'Davet kodu süresi dolmuş';

  @override
  String get invalidInviteCode => 'Geçersiz davet kodu';

  @override
  String get alreadyMember => 'Zaten bu ailenin üyesisiniz';

  @override
  String get cannotInviteSelf => 'Kendinizi davet edemezsiniz';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}dk ${seconds}sn';
  }

  @override
  String babyGuideTitle(String name) {
    return '$name\'in bakım rehberi';
  }

  @override
  String get babyGuide => 'Bebek rehberi';

  @override
  String get noAvailableGuides => 'Mevcut rehber yok';

  @override
  String get current => 'Mevcut';

  @override
  String get past => 'Geçmiş';

  @override
  String get upcoming => 'Gelecek';

  @override
  String babysGuide(String name) {
    return '$name\'in';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText rehberi';
  }

  @override
  String get feedingGuide => '💡 Beslenme rehberi';

  @override
  String get feedingFrequency => 'Beslenme sıklığı';

  @override
  String get singleFeedingAmount => 'Öğün başına miktar';

  @override
  String get dailyTotal => 'Günlük toplam';

  @override
  String get additionalTips => '📋 Ek ipuçları';

  @override
  String get understood => 'Anladım!';

  @override
  String get newborn => 'Yenidoğan';

  @override
  String weekNumber(int number) {
    return 'Hafta $number';
  }

  @override
  String get newbornWeek0 => 'Yenidoğan (Hafta 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Günde $min - $max kez';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Günde $min+ kez';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Günde en fazla $max kez';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml veya daha fazla';
  }

  @override
  String amountMaxML(int max) {
    return 'En fazla ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Dil Seçimi';

  @override
  String get selectLanguage => 'Bir dil seçin';

  @override
  String get currentLanguage => 'Mevcut dil';

  @override
  String get searchCommunityPosts => 'Topluluk gönderilerini ara';

  @override
  String get temperatureRecord => 'Sıcaklık kaydı';

  @override
  String get temperatureTrend => 'Sıcaklık Trendi';

  @override
  String get profilePhotoSetup => 'Profil fotoğrafı kurulumu';

  @override
  String get howToSelectPhoto => 'Fotoğrafı nasıl seçmek istiyorsunuz?';

  @override
  String get send => 'Gönder';

  @override
  String get emailVerificationRequired => 'E-posta doğrulaması gerekli';

  @override
  String get passwordReset => 'Şifre sıfırlama';

  @override
  String get enterEmailForReset =>
      'Kayıtlı e-posta adresinizi girin.\nSize şifre sıfırlama bağlantısı göndereceğiz.';

  @override
  String get accountWithdrawalComplete => 'Hesap silme işlemi tamamlandı';

  @override
  String get genderLabel => 'Cinsiyet: ';

  @override
  String get birthdateLabel => 'Doğum tarihi: ';

  @override
  String get maleGender => 'Erkek';

  @override
  String get femaleGender => 'Kız';

  @override
  String get joinWithInviteCodeButton => 'Davet koduyla katıl';

  @override
  String get temperatureRecorded => 'Sıcaklık kaydedildi';

  @override
  String recordFailed(String error) {
    return 'Kayıt başarısız: $error';
  }

  @override
  String get temperatureSettingsSaved => 'Sıcaklık ayarları kaydedildi';

  @override
  String get loadingUserInfo =>
      'Kullanıcı bilgileri yükleniyor. Lütfen bir süre sonra tekrar deneyin.';

  @override
  String get continueWithSeparateAccount => 'Ayrı hesapla devam et';

  @override
  String get linkWithExistingAccount => 'Mevcut hesapla bağla';

  @override
  String get linkAccount => 'Hesap bağla';

  @override
  String get accountLinkingComplete => 'Hesap bağlama tamamlandı';

  @override
  String get deleteConfirmation => 'Silme onayı';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get babyNameLabel => 'Bebek adı';

  @override
  String get weightInput => 'Ağırlık gir';

  @override
  String get heightInput => 'Boy gir';

  @override
  String get measurementNotes =>
      'Ölçüm koşullarını veya özel notları kaydet (isteğe bağlı)';

  @override
  String get urine => 'İdrar';

  @override
  String get stool => 'Dışkı';

  @override
  String get yellow => 'Sarı';

  @override
  String get brown => 'Kahverengi';

  @override
  String get green => 'Yeşil';

  @override
  String get bottle => 'Biberon';

  @override
  String get good => 'İyi';

  @override
  String get average => 'Orta';

  @override
  String get poor => 'Kötü';

  @override
  String get vaccination => 'Aşı';

  @override
  String get illness => 'Hastalık';

  @override
  String get highFever => 'Yüksek Ateş';

  @override
  String get oral => 'Ağızdan';

  @override
  String get inhalation => 'Soluma';

  @override
  String get injection => 'Enjeksiyon';

  @override
  String get tablet => 'Tablet';

  @override
  String get drops => 'Damla';

  @override
  String get teaspoon => 'Çay kaşığı';

  @override
  String get tablespoon => 'Yemek kaşığı';

  @override
  String get sleepQuality => 'Uyku';

  @override
  String get pumpingTime => 'Sağma';

  @override
  String get solidFoodTime => 'Katı gıda';

  @override
  String get totalFeedingAmount => 'Toplam beslenme miktarı';

  @override
  String get averageFeedingAmount => 'Ortalama beslenme miktarı';

  @override
  String get dailyAverageFeedingCount => 'Günlük ortalama beslenme sayısı';

  @override
  String get clinical => 'Klinik';

  @override
  String get infoSharing => 'Bilgi paylaşımı';

  @override
  String get sleepIssues => 'Uyku sorunları';

  @override
  String get babyFoodCategory => 'Bebek maması';

  @override
  String get developmentStage => 'Gelişim aşaması';

  @override
  String get vaccinationCategory => 'Aşı';

  @override
  String get postpartumRecovery => 'Doğum sonrası düzelme';

  @override
  String get dailyLife => 'Günlük hayat';

  @override
  String get likes => 'Beğeniler';

  @override
  String get comments => 'Yorumlar';

  @override
  String get anonymous => 'Anonim';

  @override
  String get minutes => 'Dakika';

  @override
  String get armpit => 'Koltuk altı';

  @override
  String get forehead => 'Alın';

  @override
  String get ear => 'Kulak';

  @override
  String get mouth => 'Ağız';

  @override
  String get rectal => 'Rektal';

  @override
  String get otherLocation => 'Diğer';

  @override
  String get searchError => 'Arama hatası';

  @override
  String get question => 'Soru';

  @override
  String get information => 'Bilgi';

  @override
  String get relevance => 'İlgililik';

  @override
  String get searchSuggestions => 'Arama önerileri';

  @override
  String get noSearchResults => 'Arama sonucu yok';

  @override
  String get tryDifferentSearchTerm => 'Farklı bir arama terimi deneyin';

  @override
  String get likeFeatureComingSoon => 'Beğeni özelliği yakında';

  @override
  String get popularSearchTerms => 'Popüler arama terimleri';

  @override
  String get recentSearches => 'Son aramalar';

  @override
  String get deleteAll => 'Tümünü sil';

  @override
  String get sortByComments => 'Yorumlara göre sırala';

  @override
  String get detailInformation => 'Detail Information';

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
  String get amount => 'Amount';

  @override
  String get duration => 'Duration';

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
  String get saveChanges => 'Save Changes';

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
    return '$hours hours $minutes minutes';
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
  String get longPressForDetails => 'Detaylar için uzun basın';

  @override
  String get todaysSummary => 'Bugünün Özeti';

  @override
  String get future => 'Gelecek';

  @override
  String get previousDate => 'Önceki tarih';

  @override
  String get nextDate => 'Sonraki tarih';

  @override
  String get selectDate => 'Tarih seçin';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'Lütfen önce bebeğinizi kaydedin';

  @override
  String get registerBabyToRecordMoments =>
      'Bebeğinizin değerli anlarını kaydetmek için,\nlütfen önce bebek bilgilerini kaydedin.';

  @override
  String get addBabyFromHome => 'Ana sayfadan bebek ekle';

  @override
  String get timesUnit => 'kez';

  @override
  String get itemsUnit => 'öğeler';

  @override
  String get timesPerDay => 'kez/gün';

  @override
  String get activityDistributionByCategory =>
      'Kategoriye Göre Aktivite Dağılımı';

  @override
  String itemsCount(int count) {
    return '$count öğeler';
  }

  @override
  String get totalCount => 'Toplam Sayı';

  @override
  String timesCount(int count) {
    return '$count kez';
  }

  @override
  String get noDetailedData => 'Detaylı veri yok';

  @override
  String get averageFeedingTime => 'Ortalama beslenme süresi';

  @override
  String get averageSleepTime => 'Ortalama uyku süresi';

  @override
  String get dailyAverageTotalSleepTime => 'Günlük ortalama toplam uyku süresi';

  @override
  String get dailyAverageSleepCount => 'Günlük ortalama uyku sayısı';

  @override
  String get dailyAverageChangeCount => 'Günlük ortalama değişim sayısı';

  @override
  String get sharingParentingStories => 'Ebeveynlik Hikayelerini Paylaşma';

  @override
  String get myActivity => 'Aktivitem';

  @override
  String get categories => 'Kategoriler';

  @override
  String get menu => 'Menü';

  @override
  String get seeMore => 'Daha Fazla Gör';

  @override
  String get midnight => 'Gece Yarısı';

  @override
  String get morning => 'Sabah';

  @override
  String get noon => 'Öğle';

  @override
  String get afternoon => 'Akşam';

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
    return '$name\'in Sıcaklık Kaydı';
  }

  @override
  String get adjustWithSlider => 'Kaydırıcı ile ayarla';

  @override
  String get measurementMethod => 'Ölçüm yöntemi';

  @override
  String get normalRange => 'Normal aralık';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Normal aralık ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Sıcaklık Kaydını Kaydet';

  @override
  String get enterTemperature => 'Lütfen sıcaklığı girin';

  @override
  String get temperatureRangeValidation =>
      'Sıcaklık 34,0°C ~ 42,0°C arasında olmalıdır';

  @override
  String get recordSymptomsHint =>
      'Lütfen belirtileri veya özel notları kaydedin';

  @override
  String get oralMethod => 'Ağızdan';

  @override
  String get analMethod => 'Anelden';

  @override
  String recentDaysTrend(int days) {
    return 'Son $days günün trendi';
  }

  @override
  String get days3 => '3 gün';

  @override
  String get days7 => '7 gün';

  @override
  String get weeks2 => '2 hafta';

  @override
  String get month1 => '1 ay';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Seçilen dönemde sıcaklık kaydı yok';

  @override
  String get temperatureChangeTrend => 'Sıcaklık Değişim Trendi';

  @override
  String get averageTemperature => 'Ortalama Sıcaklık';

  @override
  String get highestTemperature => 'En Yüksek Sıcaklık';

  @override
  String get lowestTemperature => 'En Düşük Sıcaklık';

  @override
  String get noteAvailableTapToView =>
      '📝 Not mevcut (görüntülemek için dokun)';

  @override
  String get temperatureRisingTrend => 'Sıcaklık yükselen bir trend gösteriyor';

  @override
  String get temperatureFallingTrend => 'Sıcaklık düşen bir trend gösteriyor';

  @override
  String get temperatureStableTrend => 'Sıcaklık stabil';

  @override
  String get trendAnalysis => 'Trend Analizi';

  @override
  String totalMeasurements(int count) {
    return 'Toplam $count ölçüm';
  }

  @override
  String get temperatureRecordMemo => 'Sıcaklık Kayıt Notu';
}
