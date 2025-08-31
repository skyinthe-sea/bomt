// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get user => 'ผู้ใช้';

  @override
  String userInfoLoadFailed(String error) {
    return 'โหลดข้อมูลผู้ใช้ไม่สำเร็จ: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'ข้อผิดพลาดในการโหลดรายการลูก: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'สวัสดี $userName!';
  }

  @override
  String get registerBaby => 'ลงทะเบียนลูก';

  @override
  String get noBabiesRegistered => 'ยังไม่มีลูกที่ลงทะเบียน';

  @override
  String get registerFirstBaby => 'ลงทะเบียนลูกคนแรกของคุณ!';

  @override
  String get registerBabyButton => 'ลงทะเบียนเด็ก';

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
    return 'เพศ';
  }

  @override
  String get male => 'ชาย';

  @override
  String get female => 'หญิง';

  @override
  String get other => 'อื่นๆ';

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
  String get enterBabyInfo => 'กรุณากรอกข้อมูลลูก';

  @override
  String get babyName => 'ชื่อลูก';

  @override
  String get babyNameHint => 'เช่น: น้องมิ้น';

  @override
  String get babyNameRequired => 'กรุณากรอกชื่อลูก';

  @override
  String get babyNameMinLength => 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';

  @override
  String get selectBirthdateButton => 'เลือกวันเกิด';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'ยกเลิก';

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
  String get settings => 'การตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'กรุณากรอกชื่อลูก';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'ออกจากระบบ';

  @override
  String get logoutConfirm => 'คุณแน่ใจว่าต้องการออกจากระบบ?';

  @override
  String get yes => 'ใช่';

  @override
  String get no => 'ไม่';

  @override
  String get darkMode => 'โหมดมืด';

  @override
  String get appearance => 'รูปลักษณ์';

  @override
  String get home => 'หน้าหลัก';

  @override
  String get timeline => 'ไทม์ไลน์';

  @override
  String get record => 'บันทึก';

  @override
  String get statistics => 'สถิติ';

  @override
  String get community => 'ชุมชน';

  @override
  String get comingSoon => 'เร็วๆ นี้';

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
  String get growthInfo => 'ข้อมูลการเจริญเติบโต';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'ให้นม';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'นอน';

  @override
  String get totalSleepTime => 'Total Sleep Time';

  @override
  String get cardSettings => 'การตั้งค่าการ์ด';

  @override
  String get cardSettingsGuide => 'คู่มือการตั้งค่าการ์ด';

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
  String get continueEditing => 'แก้ไขต่อ';

  @override
  String get discardChangesExit => 'Exit without saving changes?';

  @override
  String get exit => 'Exit';

  @override
  String get diaper => 'ผ้าอ้อม';

  @override
  String get solidFood => 'อาหารแข็ง';

  @override
  String get medication => 'ยา';

  @override
  String get milkPumping => 'ปั๊มนม';

  @override
  String get temperature => 'อุณหภูมิ';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'ปริมาณการให้อาหาร';

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
  String get weight => 'น้ำหนัก';

  @override
  String get height => 'ส่วนสูง';

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
  String get enterValidNumber => 'กรุณากรอกตัวเลขที่ถูกต้อง';

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
  String get writePost => 'เขียนโพสต์';

  @override
  String get post => 'โพสต์';

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
  String get selectCategory => 'เลือกหมวดหมู่';

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
    return 'เนื้อหา: $count/10000';
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
  String get refresh => 'รีเฟรช';

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
  String get familyInvitation => 'การเชิญครอบครัว';

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
  String get delete => 'ลบ';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'ลองใหม่';

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
    return '$minutes นาทีที่แล้ว';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'วันนี้';

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
  String get medicationTime => 'ยา';

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
  String get camera => 'กล้อง';

  @override
  String get gallery => 'แกลเลอรี';

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
    return '$months เดือน $days วัน';
  }

  @override
  String get lastFeedingTime => 'เวลาการให้อาหารครั้งสุดท้าย';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours ชั่วโมง $minutes นาทีที่แล้ว';
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
  String get viewDetails => 'ดูรายละเอียด';

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
  String get joinWithInviteCode => 'เข้าร่วมด้วยรหัสเชิญ';

  @override
  String get loadingBabyInfo => 'กำลังโหลดข้อมูลลูก...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'ไปที่การตั้งค่า';

  @override
  String get profilePhotoUpdated => 'ภาพโปรไฟล์ได้รับการอัปเดตแล้ว';

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
  String get hourActivityPattern => 'รูปแบบกิจกรรม 24 ชั่วโมง';

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
  String get todaysStory => 'เรื่องราวของวันนี้';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'บันทึกช่วงเวลาอันบริชุดแรกของคุณ\nการเปลี่ยนแปลงเล็กๆ ในแต่ละวันจะรวมกันเป็นการเติบโตอย่างยิ่งใหญ่';

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
  String get formula => 'นมผง';

  @override
  String get breastMilk => 'น้ำนมแม่';

  @override
  String get babyFood => 'อาหารเด็ก';

  @override
  String get left => 'ซ้าย';

  @override
  String get right => 'ขวา';

  @override
  String get both => 'ทั้งสอง';

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
  String get topical => 'ทางผิวหนัง';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'มีไข้';

  @override
  String get lowFever => 'ไข้เล็กน้อย';

  @override
  String get hypothermia => 'อุณหภูมิกายต่ำ';

  @override
  String get normal => 'ปกติ';

  @override
  String get quality => 'คุณภาพ';

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
  String get periodSelection => 'การเลือกช่วงเวลา:';

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
  String get detailedStatistics => 'สถิติรายละเอียด';

  @override
  String get chartAnalysis => 'การวิเคราะห์แผนภูมิ';

  @override
  String get overallActivityOverview => 'ภาพรวมกิจกรรมทั้งหมด';

  @override
  String get totalActivities => 'กิจกรรมทั้งหมด';

  @override
  String get activeCards => 'การ์ดที่ใช้งานอยู่';

  @override
  String get dailyAverage => 'เฉลี่ยต่อวัน';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'ลองใหม่';

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
  String get search => 'ค้นหา';

  @override
  String get notification => 'การแจ้งเตือน';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'แบ่งปันประสบการณ์การเลี้ยงดูลูกและข้อมูลที่มีค่ากับพ่อแม่คนอื่น';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'ทั้งหมด';

  @override
  String get categoryPopular => 'ยอดนิยม';

  @override
  String get categoryClinical => 'คลินิก';

  @override
  String get categoryInfoSharing => 'แบ่งปันข้อมูล';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'อาหารเด็ก';

  @override
  String get categoryDevelopment => 'พัฒนาการ';

  @override
  String get categoryVaccination => 'การฉีดวัคซีน';

  @override
  String get categoryPostpartum => 'หลังคลอด';

  @override
  String get sortByLikes => 'เรียงตามไลค์';

  @override
  String get sortByLatest => 'เรียงตามล่าสุด';

  @override
  String get edited => '(แก้ไขแล้ว)';

  @override
  String commentsCount(Object count) {
    return '$count ความคิดเห็น';
  }

  @override
  String get deletePost => 'ลบโพสต์';

  @override
  String get deletePostConfirm =>
      'คุณแน่ใจว่าต้องการลบโพสต์นี้?\\nโพสต์ที่ลบแล้วไม่สามารถกู้คืนได้';

  @override
  String get deletePostSuccess => 'ลบโพสต์แล้ว';

  @override
  String deletePostError(Object error) {
    return 'ลบไม่สำเร็จ: $error';
  }

  @override
  String get postNotFound => 'ไม่พบโพสต์';

  @override
  String get shareFeatureComingSoon => 'ฟีเจอร์แชร์เร็วๆ นี้';

  @override
  String get loadingComments => 'กำลังโหลดความคิดเห็น...';

  @override
  String get loadMoreComments => 'โหลดความคิดเห็นเพิ่มเติม';

  @override
  String get editComment => 'แก้ไขความคิดเห็น';

  @override
  String get editCommentHint => 'แก้ไขความคิดเห็นของคุณ...';

  @override
  String get editCommentSuccess => 'อัปเดตความคิดเห็นแล้ว';

  @override
  String editCommentError(Object error) {
    return 'แก้ไขไม่สำเร็จ: $error';
  }

  @override
  String get deleteComment => 'ลบความคิดเห็น';

  @override
  String get deleteCommentConfirm =>
      'คุณแน่ใจว่าต้องการลบความคิดเห็นนี้?\\nความคิดเห็นที่ลบแล้วไม่สามารถกู้คืนได้';

  @override
  String get deleteCommentSuccess => 'ลบความคิดเห็นแล้ว';

  @override
  String get replySuccess => 'โพสต์การตอบกลับแล้ว';

  @override
  String get commentSuccess => 'โพสต์ความคิดเห็นแล้ว';

  @override
  String get commentError => 'โพสต์ความคิดเห็นไม่สำเร็จ';

  @override
  String get titlePlaceholder => 'กรอกหัวข้อ';

  @override
  String get contentPlaceholder =>
      'แบ่งปันความคิดของคุณ...\\n\\nเขียนเกี่ยวกับประสบการณ์การเป็นพ่อแม่ได้อย่างอิสระ';

  @override
  String imageSelectionError(Object error) {
    return 'เลือกรูปภาพไม่สำเร็จ: $error';
  }

  @override
  String get userNotFoundError => 'ไม่พบข้อมูลผู้ใช้';

  @override
  String get postCreateSuccess => 'สร้างโพสต์สำเร็จ!';

  @override
  String postCreateError(Object error) {
    return 'สร้างโพสต์ไม่สำเร็จ: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'หัวข้อ: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'รูปภาพ: $count/5';
  }

  @override
  String get addImageTooltip => 'เพิ่มรูปภาพ';

  @override
  String get allPostsChecked => 'ตรวจสอบโพสต์ทั้งหมดแล้ว! 👍';

  @override
  String get waitForNewPosts => 'รอโพสต์ใหม่';

  @override
  String get noPostsYet => 'ยังไม่มีโพสต์';

  @override
  String get writeFirstPost => 'เขียนโพสต์แรก!';

  @override
  String get loadingNewPosts => 'กำลังโหลดโพสต์ใหม่...';

  @override
  String get failedToLoadPosts => 'โหลดโพสต์ไม่สำเร็จ';

  @override
  String get checkNetworkAndRetry => 'ตรวจสอบการเชื่อมต่อและลองใหม่';

  @override
  String get categoryDailyLife => 'ชีวิตประจำวัน';

  @override
  String get preparingTimeline => 'กำลังเตรียมไทม์ไลน์...';

  @override
  String get noRecordedMoments => 'ยังไม่มีช่วงเวลาที่บันทึกไว้';

  @override
  String get loadingTimeline => 'กำลังโหลดไทม์ไลน์...';

  @override
  String get noRecordsYet => 'ยังไม่มีบันทึก';

  @override
  String noRecordsForDate(Object date) {
    return 'ไม่มีบันทึกสำหรับ $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'ไม่มีบันทึก $filter สำหรับ $date';
  }

  @override
  String get cannotRecordFuture => 'ยังไม่สามารถบันทึกกิจกรรมอนาคตได้';

  @override
  String get addFirstRecord => 'เพิ่มบันทึกแรกของคุณ!';

  @override
  String get canAddPastRecord => 'คุณสามารถเพิ่มบันทึกในอดีตได้';

  @override
  String get addRecord => 'เพิ่มบันทึก';

  @override
  String get viewOtherDates => 'ดูวันที่อื่น';

  @override
  String get goToToday => 'ไปยังวันนี้';

  @override
  String get quickRecordFromHome =>
      'คุณสามารถเพิ่มบันทึกได้อย่างรวดเร็วจากหน้าหลัก';

  @override
  String detailViewComingSoon(String title) {
    return 'รายละเอียด $title (เร็วๆ นี้)';
  }

  @override
  String get familyInvitationDescription =>
      'จัดการบันทึกการดูแลลูกร่วมกับครอบครัวผ่านรหัสเชิญ';

  @override
  String get babyManagement => 'การจัดการลูก';

  @override
  String get addBaby => 'เพิ่มเด็ก';

  @override
  String get noBabiesMessage => 'ยังไม่มีลูกที่ลงทะเบียน\\nกรุณาเพิ่มลูก';

  @override
  String get switchToNextBaby => 'เปลี่ยนไปลูกคนต่อไป';

  @override
  String get birthDate => 'วันเกิด';

  @override
  String get registering => 'กำลังลงทะเบียน...';

  @override
  String get register => 'ลงทะเบียน';

  @override
  String careTogetherWith(String name) {
    return 'ดูแลลูกร่วมกับ $name';
  }

  @override
  String get inviteFamilyDescription =>
      'เชิญครอบครัวหรือคู่ครอง\\nเพื่อจัดการบันทึกการดูแลลูกร่วมกัน';

  @override
  String get generateInviteCode => 'สร้างรหัสเชิญ';

  @override
  String get generateInviteCodeDescription => 'สร้างรหัสเชิญใหม่และคัดลอก';

  @override
  String get generateInviteCodeButton => 'สร้างรหัสเชิญ';

  @override
  String get orText => 'หรือ';

  @override
  String get enterInviteCodeDescription => 'กรุณากรอกรหัสเชิญที่ได้รับ';

  @override
  String get inviteCodePlaceholder => 'รหัสเชิญ (6 หลัก)';

  @override
  String get acceptInvite => 'ยอมรับคำเชิญ';

  @override
  String babyRegistrationSuccess(String name) {
    return 'ลงทะเบียน $name สำเร็จแล้ว';
  }

  @override
  String get babyRegistrationFailed => 'ลงทะเบียนลูกไม่สำเร็จ';

  @override
  String babyRegistrationError(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String babySelected(String name) {
    return 'เลือก $name แล้ว';
  }

  @override
  String get inviteCodeGenerated => 'สร้างรหัสเชิญแล้ว!';

  @override
  String remainingTime(String time) {
    return 'เวลาที่เหลือ: $time';
  }

  @override
  String get validTime => 'เวลาที่ใช้ได้: 5 นาที';

  @override
  String get generating => 'กำลังสร้าง...';

  @override
  String get joining => 'กำลังเข้าร่วม...';

  @override
  String get noBabyInfo => 'ไม่มีข้อมูลลูก';

  @override
  String get noBabyInfoDescription =>
      'ไม่พบข้อมูลลูก\\nต้องการสร้างลูกทดสอบหรือไม่?';

  @override
  String get create => 'สร้าง';

  @override
  String get generateNewInviteCode => 'สร้างรหัสเชิญใหม่';

  @override
  String get replaceExistingCode =>
      'นี่จะแทนที่รหัสเชิญที่มีอยู่\\nต้องการดำเนินการต่อหรือไม่?';

  @override
  String get acceptInvitation => 'ยอมรับคำเชิญ';

  @override
  String get acceptInvitationDescription =>
      'ต้องการยอมรับคำเชิญและเข้าร่วมครอบครัวหรือไม่?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'บันทึกลูกที่มีอยู่จะถูกลบและแทนที่ด้วยลูกที่เชิญ ($babyName)\\n\\nต้องการดำเนินการต่อหรือไม่?';
  }

  @override
  String get pleaseEnterInviteCode => 'กรุณากรอกรหัสเชิญ';

  @override
  String get inviteCodeMustBe6Digits => 'รหัสเชิญต้องมี 6 หลัก';

  @override
  String get pleaseLoginFirst =>
      'ไม่พบข้อมูลการเข้าสู่ระบบ กรุณาเข้าสู่ระบบก่อน';

  @override
  String get copiedToClipboard => 'คัดลอกรหัสเชิญแล้ว!';

  @override
  String get joinedSuccessfully => 'เข้าร่วมครอบครัวสำเร็จ!';

  @override
  String get inviteCodeExpired => 'รหัสเชิญหมดอายุแล้ว';

  @override
  String get invalidInviteCode => 'รหัสเชิญไม่ถูกต้อง';

  @override
  String get alreadyMember => 'คุณเป็นสมาชิกของครอบครัวนี้แล้ว';

  @override
  String get cannotInviteSelf => 'คุณไม่สามารถเชิญตัวเองได้';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutesนาที $secondsวินาที';
  }

  @override
  String babyGuideTitle(String name) {
    return 'คู่มือการดูแล $name';
  }

  @override
  String get babyGuide => 'คู่มือลูก';

  @override
  String get noAvailableGuides => 'ไม่มีคู่มือที่พร้อมใช้งาน';

  @override
  String get current => 'ปัจจุบัน';

  @override
  String get past => 'ผ่านมาแล้ว';

  @override
  String get upcoming => 'กำลังจะมาถึง';

  @override
  String babysGuide(String name) {
    return 'ของ $name';
  }

  @override
  String weekGuide(String weekText) {
    return 'คู่มือ $weekText';
  }

  @override
  String get feedingGuide => '💡 คู่มือการให้นม';

  @override
  String get feedingFrequency => 'ความถี่ในการให้นม';

  @override
  String get singleFeedingAmount => 'ปริมาณต่อมื้อ';

  @override
  String get dailyTotal => 'รวมต่อวัน';

  @override
  String get additionalTips => '📋 เคล็ดลับเพิ่มเติม';

  @override
  String get understood => 'เข้าใจแล้ว!';

  @override
  String get newborn => 'ทารกแรกเกิด';

  @override
  String weekNumber(int number) {
    return 'สัปดาห์ที่ $number';
  }

  @override
  String get newbornWeek0 => 'ทารกแรกเกิด (สัปดาห์ที่ 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'วันละ $min - $max ครั้ง';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'วันละ $min+ ครั้ง';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'วันละสูงสุด $max ครั้ง';
  }

  @override
  String amountRangeML(int min, int max) {
    return '$minมล. - $maxมล.';
  }

  @override
  String amountMinML(int min) {
    return '$minมล. หรือมากกว่า';
  }

  @override
  String amountMaxML(int max) {
    return 'สูงสุด $maxมล.';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'การเลือกภาษา';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get currentLanguage => 'ภาษาปัจจุบัน';

  @override
  String get searchCommunityPosts => 'ค้นหาโพสต์ชุมชน';

  @override
  String get temperatureRecord => 'บันทึกอุณหภูมิ';

  @override
  String get temperatureTrend => 'แนวโน้มอุณหภูมิ';

  @override
  String get profilePhotoSetup => 'การตั้งค่าภาพโปรไฟล์';

  @override
  String get howToSelectPhoto => 'คุณต้องการเลือกภาพอย่างไร?';

  @override
  String get send => 'ส่ง';

  @override
  String get emailVerificationRequired => 'ต้องการการยืนยันอีเมล';

  @override
  String get passwordReset => 'รีเซ็ตรหัสผ่าน';

  @override
  String get enterEmailForReset =>
      'ป้อนที่อยู่อีเมลที่ลงทะเบียนของคุณ\nเราจะส่งลิงค์รีเซ็ตรหัสผ่านให้คุณ';

  @override
  String get accountWithdrawalComplete => 'การยกเลิกบัญชีเสร็จสิ้น';

  @override
  String get genderLabel => 'เพศ: ';

  @override
  String get birthdateLabel => 'วันเกิด: ';

  @override
  String get maleGender => 'ชาย';

  @override
  String get femaleGender => 'หญิง';

  @override
  String get joinWithInviteCodeButton => 'เข้าร่วมด้วยรหัสเชิญ';

  @override
  String get temperatureRecorded => 'อุณหภูมิได้รับการบันทึกแล้ว';

  @override
  String recordFailed(String error) {
    return 'การบันทึกล้มเหลว: $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'การตั้งค่าอุณหภูมิได้รับการบันทึกแล้ว';

  @override
  String get loadingUserInfo =>
      'กำลังโหลดข้อมูลผู้ใช้ กรุณาลองใหม่อีกครั้งในภายหลัง';

  @override
  String get continueWithSeparateAccount => 'ดำเนินการต่อด้วยบัญชีแยกต่างหาก';

  @override
  String get linkWithExistingAccount => 'เชื่อมโยงกับบัญชีที่มีอยู่';

  @override
  String get linkAccount => 'เชื่อมโยงบัญชี';

  @override
  String get accountLinkingComplete => 'การเชื่อมโยงบัญชีเสร็จสิ้น';

  @override
  String get deleteConfirmation => 'การยืนยันการลบ';

  @override
  String get emailLabel => 'อีเมล';

  @override
  String get passwordLabel => 'รหัสผ่าน';

  @override
  String get babyNameLabel => 'ชื่อเด็ก';

  @override
  String get weightInput => 'ป้อนน้ำหนัก';

  @override
  String get heightInput => 'ป้อนส่วนสูง';

  @override
  String get measurementNotes =>
      'บันทึกเงื่อนไขการวัดหรือหมายเหตุพิเศษ (ไม่บังคับ)';

  @override
  String get urine => 'ปัสสาวะ';

  @override
  String get stool => 'อุจจาระ';

  @override
  String get yellow => 'เหลือง';

  @override
  String get brown => 'น้ำตาล';

  @override
  String get green => 'เขียว';

  @override
  String get bottle => 'ขวดนม';

  @override
  String get good => 'ดี';

  @override
  String get average => 'เฉลี่ย';

  @override
  String get poor => 'แย่';

  @override
  String get vaccination => 'การฉีดวัคซีน';

  @override
  String get illness => 'การเจ็บป่วย';

  @override
  String get highFever => 'ไข้สูง';

  @override
  String get oral => 'ทางปาก';

  @override
  String get inhalation => 'ทางการหายใจ';

  @override
  String get injection => 'ฉีด';

  @override
  String get tablet => 'เม็ด';

  @override
  String get drops => 'หยด';

  @override
  String get teaspoon => 'ช้อนชา';

  @override
  String get tablespoon => 'ช้อนโต๊ะ';

  @override
  String get sleepQuality => 'การนอน';

  @override
  String get pumpingTime => 'การปั๊มนม';

  @override
  String get solidFoodTime => 'อาหารแข็ง';

  @override
  String get totalFeedingAmount => 'ปริมาณการให้อาหารทั้งหมด';

  @override
  String get averageFeedingAmount => 'ปริมาณนมเฉลี่ย';

  @override
  String get dailyAverageFeedingCount => 'จำนวนครั้งการให้นมเฉลี่ยต่อวัน';

  @override
  String get clinical => 'ทางคลินิก';

  @override
  String get infoSharing => 'การแบ่งปันข้อมูล';

  @override
  String get sleepIssues => 'ปัญหาการนอน';

  @override
  String get babyFoodCategory => 'อาหารเด็ก';

  @override
  String get developmentStage => 'ขั้นตอนการพัฒนา';

  @override
  String get vaccinationCategory => 'การฉีดวัคซีน';

  @override
  String get postpartumRecovery => 'การฟื้นตัวหลังคลอด';

  @override
  String get dailyLife => 'ชีวิตประจำวัน';

  @override
  String get likes => 'ไลค์';

  @override
  String get comments => 'ความคิดเห็น';

  @override
  String get anonymous => 'นิรนาม';

  @override
  String get minutes => 'นาที';

  @override
  String get armpit => 'รักแร้';

  @override
  String get forehead => 'หน้าผาก';

  @override
  String get ear => 'หู';

  @override
  String get mouth => 'ปาก';

  @override
  String get rectal => 'ทางทวารหนัก';

  @override
  String get otherLocation => 'อื่นๆ';

  @override
  String get searchError => 'ข้อผิดพลาดในการค้นหา';

  @override
  String get question => 'คำถาม';

  @override
  String get information => 'ข้อมูล';

  @override
  String get relevance => 'ความเกี่ยวข้อง';

  @override
  String get searchSuggestions => 'คำแนะนำการค้นหา';

  @override
  String get noSearchResults => 'ไม่มีผลการค้นหา';

  @override
  String get tryDifferentSearchTerm => 'ลองคำค้นหาอื่น';

  @override
  String get likeFeatureComingSoon => 'ฟีเจอร์ไลค์เร็วๆ นี้';

  @override
  String get popularSearchTerms => 'คำค้นหายอดนิยม';

  @override
  String get recentSearches => 'การค้นหาล่าสุด';

  @override
  String get deleteAll => 'ลบทั้งหมด';

  @override
  String get sortByComments => 'เรียงตามความคิดเห็น';

  @override
  String get detailInformation => 'ข้อมูลรายละเอียด';

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
  String get amount => 'จำนวน';

  @override
  String get duration => 'ระยะเวลา';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'ข้าง';

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
  String get smartInsights => 'ข้อมูลเชิงลึกอัจฉริยะ';

  @override
  String get analyzingPatterns => 'กำลังวิเคราะห์รูปแบบ...';

  @override
  String insightsFound(int count) {
    return 'พบข้อมูลเชิงลึก $count รายการ';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'ความเชื่อมั่น';

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
  String get longPressForDetails => 'กดค้างไว้เพื่อดูรายละเอียด';

  @override
  String get todaysSummary => 'สรุปวันนี้';

  @override
  String get future => 'อนาคต';

  @override
  String get previousDate => 'วันที่ผ่านมา';

  @override
  String get nextDate => 'วันถัดไป';

  @override
  String get selectDate => 'เลือกวันที่';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'กรุณาลงทะเบียนลูกก่อน';

  @override
  String get registerBabyToRecordMoments =>
      'เพื่อบันทึกช่วงเวลาล้ำค่าของลูก\nกรุณาลงทะเบียนข้อมูลลูกก่อน';

  @override
  String get addBabyFromHome => 'เพิ่มลูกจากหน้าหลัก';

  @override
  String get timesUnit => 'ครั้ง';

  @override
  String get itemsUnit => 'รายการ';

  @override
  String get timesPerDay => 'ครั้ง/วัน';

  @override
  String get activityDistributionByCategory => 'การกระจายกิจกรรมตามหมวดหมู่';

  @override
  String itemsCount(int count) {
    return '$count รายการ';
  }

  @override
  String get totalCount => 'จำนวนทั้งหมด';

  @override
  String timesCount(int count) {
    return '$count ครั้ง';
  }

  @override
  String get noDetailedData => 'ไม่มีข้อมูลรายละเอียด';

  @override
  String get averageFeedingTime => 'เวลาการให้อาหารเฉลี่ย';

  @override
  String get averageSleepTime => 'เวลานอนเฉลี่ย';

  @override
  String get dailyAverageTotalSleepTime => 'เวลานอนรวมเฉลี่ยต่อวัน';

  @override
  String get dailyAverageSleepCount => 'จำนวนครั้งการนอนเฉลี่ยต่อวัน';

  @override
  String get dailyAverageChangeCount => 'จำนวนการเปลี่ยนเฉลี่ยต่อวัน';

  @override
  String get sharingParentingStories => 'แบ่งปันเรื่องราวการเลี้ยงลูก';

  @override
  String get myActivity => 'กิจกรรมของฉัน';

  @override
  String get categories => 'หมวดหมู่';

  @override
  String get menu => 'เมนู';

  @override
  String get seeMore => 'ดูเพิ่มเติม';

  @override
  String get midnight => 'เที่ยงคืน';

  @override
  String get morning => 'เช้า';

  @override
  String get noon => 'เที่ยงวัน';

  @override
  String get afternoon => 'บ่าย';

  @override
  String get quickSelection => 'การเลือกด่วน';

  @override
  String get customSettings => 'การตั้งค่าเอง';

  @override
  String get selectDateRange => 'เลือกช่วงวันที่';

  @override
  String get recent7Days => '7 วันที่ผ่านมา';

  @override
  String get recent14Days => '14 วันที่ผ่านมา';

  @override
  String get recent30Days => '30 วันที่ผ่านมา';

  @override
  String get selectPeriodForAnalysis => 'กรุณาเลือกช่วงเวลาสำหรับการวิเคราะห์';

  @override
  String get cardSettingsInstructions =>
      '• ใช้สวิตช์เปิด/ปิดเพื่อแสดง/ซ่อนการ์ด\n• ลากเพื่อเปลี่ยนลำดับการ์ด\n• การเปลี่ยนแปลงจะแสดงตัวอย่างแบบเรียลไทม์';

  @override
  String get visible => 'แสดง';

  @override
  String get hidden => 'ซ่อน';

  @override
  String get touchToSetDefault => 'แตะเพื่อตั้งค่าเริ่มต้น';

  @override
  String get unsavedChangesMessage =>
      'คุณต้องการยกเลิกการเปลี่ยนแปลงและกลับไปสู่สถานะเดิมหรือไม่?';

  @override
  String get unsavedChangesExitMessage =>
      'คุณต้องการออกโดยไม่บันทึกการเปลี่ยนแปลงหรือไม่?';

  @override
  String get exitWithoutSaving => 'ออก';

  @override
  String get savingError =>
      'เกิดข้อผิดพลาดขณะบันทึกการตั้งค่า กรุณาลองใหม่อีกครั้ง';

  @override
  String get familyMembers => 'สมาชิกครอบครัว';

  @override
  String get cannotLoadFamilyMembersInfo =>
      'ไม่สามารถโหลดข้อมูลสมาชิกครอบครัวได้';

  @override
  String get administrator => 'ผู้ดูแล';

  @override
  String get member => 'สมาชิก';

  @override
  String joinDate(String date) {
    return 'วันที่เข้าร่วม: $date';
  }

  @override
  String get inviteFamilyMembersDescription =>
      'เชิญสมาชิกครอบครัวมาจัดการบันทึกของลูกด้วยกัน';

  @override
  String joinFamilyGroupWarning(String familyName) {
    return 'คุณต้องการเข้าร่วมครอบครัวของ $familyName หรือไม่?\n\nข้อมูลลูกที่มีอยู่จะถูกย้ายไปยังกลุ่มครอบครัวใหม่';
  }

  @override
  String get familyInvitationAccepted =>
      'ได้รับการเชิญเข้าร่วมครอบครัว! ตอนนี้คุณสามารถจัดการบันทึกของลูกร่วมกันได้แล้ว';

  @override
  String careTogetherWithFamily(String familyName) {
    return 'เลี้ยงลูกร่วมกับ $familyName';
  }

  @override
  String get feedingTimeNotificationTitle => 'ถึงเวลาให้นมแล้ว! 🍼';

  @override
  String get feedingTimeNotificationBody => 'ลูกอาจจะหิวแล้วนะ';

  @override
  String get feedingAlarmChannelName => 'การแจ้งเตือนการให้นม';

  @override
  String get feedingAlarmChannelDescription => 'การแจ้งเตือนเวลาให้นมลูก';

  @override
  String get averageFeedingDuration => 'ระยะเวลาให้นมเฉลี่ย';

  @override
  String get averageSleepDuration => 'ระยะเวลานอนเฉลี่ย';

  @override
  String get dailyTotalSleepDuration => 'ระยะเวลานอนรวมต่อวัน';

  @override
  String get dailyAverageDiaperChangeCount =>
      'จำนวนครั้งการเปลี่ยนผ้าอ้อมเฉลี่ยต่อวัน';

  @override
  String get dailyAverageMedicationCount => 'จำนวนครั้งการให้ยาเฉลี่ยต่อวัน';

  @override
  String get medicationTypesUsed => 'ประเภทยาที่ใช้';

  @override
  String get totalPumpedAmount => 'ปริมาณนมปั๊มรวม';

  @override
  String get averagePumpedAmount => 'ปริมาณนมปั๊มเฉลี่ย';

  @override
  String get countTab => 'จำนวนครั้ง';

  @override
  String get amountTimeTab => 'ปริมาณ/เวลา';

  @override
  String get durationTab => 'ระยะเวลา';

  @override
  String get chartDataLoading => 'กำลังโหลดข้อมูลแผนภูมิ...';

  @override
  String get chartDataNotAvailable => 'ไม่มีข้อมูลแผนภูมิ';

  @override
  String get averageLabel => 'เฉลี่ย: ';

  @override
  String get dailyFeedingCountTitle => 'จำนวนครั้งการให้นมต่อวัน';

  @override
  String get weekdaysSundayToSaturday => 'อาทิพาอังเสาร์พฤหัศุก';

  @override
  String dayFormat(int day) {
    return '$day';
  }

  @override
  String get dailyFeedingCount => 'จำนวนครั้งการให้นมต่อวัน';

  @override
  String get dailyFeedingAmount => 'ปริมาณนมต่อวัน';

  @override
  String get dailyFeedingDuration => 'ระยะเวลาให้นมต่อวัน';

  @override
  String get dailySleepCount => 'จำนวนครั้งการนอนต่อวัน';

  @override
  String get dailySleepDuration => 'ระยะเวลานอนต่อวัน';

  @override
  String get dailyDiaperChangeCount => 'จำนวนครั้งการเปลี่ยนผ้าอ้อมต่อวัน';

  @override
  String get dailyMedicationCount => 'จำนวนครั้งการให้ยาต่อวัน';

  @override
  String get dailyMilkPumpingCount => 'จำนวนครั้งการปั๊มนมต่อวัน';

  @override
  String get dailyMilkPumpingAmount => 'ปริมาณนมปั๊มต่อวัน';

  @override
  String get dailySolidFoodCount => 'จำนวนครั้งการให้อาหารแข็งต่อวัน';

  @override
  String get dailyAverageSolidFoodCount =>
      'จำนวนครั้งการให้อาหารแข็งเฉลี่ยต่อวัน';

  @override
  String get triedFoodTypes => 'ประเภทอาหารที่ลอง';

  @override
  String babyTemperatureRecord(String name) {
    return 'บันทึกอุณหภูมิของ$name';
  }

  @override
  String get adjustWithSlider => 'ปรับด้วยแถบเลื่อน';

  @override
  String get measurementMethod => 'วิธีการวัด';

  @override
  String get normalRange => 'ช่วงปกติ';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'ช่วงปกติ ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'บันทึกข้อมูลอุณหภูมิ';

  @override
  String get enterTemperature => 'กรุณากรอกอุณหภูมิ';

  @override
  String get temperatureRangeValidation =>
      'อุณหภูมิต้องอยู่ระหว่าง 34.0°C ~ 42.0°C';

  @override
  String get recordSymptomsHint => 'กรุณาบันทึกอาการหรือหมายเหตุพิเศษ';

  @override
  String get oralMethod => 'ทางปาก';

  @override
  String get analMethod => 'ทางทวารหนัก';

  @override
  String recentDaysTrend(int days) {
    return 'แนวโน้ม $days วันที่ผ่านมา';
  }

  @override
  String get days3 => '3 วัน';

  @override
  String get days7 => '7 วัน';

  @override
  String get weeks2 => '2 สัปดาห์';

  @override
  String get month1 => '1 เดือน';

  @override
  String get noTemperatureRecordsInPeriod =>
      'ไม่มีบันทึกอุณหภูมิในช่วงเวลาที่เลือก';

  @override
  String get temperatureChangeTrend => 'แนวโน้มการเปลี่ยนแปลงอุณหภูมิ';

  @override
  String get averageTemperature => 'อุณหภูมิเฉลี่ย';

  @override
  String get highestTemperature => 'อุณหภูมิสูงสุด';

  @override
  String get lowestTemperature => 'อุณหภูมิต่ำสุด';

  @override
  String get noteAvailableTapToView => '📝 มีหมายเหตุ (แตะเพื่อดู)';

  @override
  String get temperatureRisingTrend => 'อุณหภูมิมีแนวโน้มสูงขึ้น';

  @override
  String get temperatureFallingTrend => 'อุณหภูมิมีแนวโน้มลดลง';

  @override
  String get temperatureStableTrend => 'อุณหภูมิคงที่';

  @override
  String get trendAnalysis => 'การวิเคราะห์แนวโน้ม';

  @override
  String totalMeasurements(int count) {
    return 'รวม $count ครั้งการวัด';
  }

  @override
  String get temperatureRecordMemo => 'บันทึกหมายเหตุอุณหภูมิ';

  @override
  String babyGrowthChart(String name) {
    return 'แผนภูมิการเจริญเติบโตของ $name';
  }

  @override
  String get noGrowthRecords => 'ไม่มีบันทึกการเจริญเติบโต';

  @override
  String get enterWeightAndHeightFromHome =>
      'กรุณาบันทึกน้ำหนักและส่วนสูงจากหน้าจอหลัก';

  @override
  String get all => 'ทั้งหมด';

  @override
  String get growthInsights => 'ข้อมูลเชิงลึกการเจริญเติบโต';

  @override
  String get growthRate => 'อัตราการเจริญเติบโต';

  @override
  String get monthlyAverageGrowth => 'การเจริญเติบโตเฉลี่ยต่อเดือน';

  @override
  String get dataInsufficient => 'ข้อมูลไม่เพียงพอ';

  @override
  String get twoOrMoreRequired => 'ต้องการ 2 รายการขึ้นไป';

  @override
  String recentDaysBasis(int days) {
    return 'อิงจาก $days วันที่ผ่านมา';
  }

  @override
  String get entireBasis => 'อิงจากช่วงเวลาทั้งหมด';

  @override
  String get oneMonthPrediction => 'คาดการณ์ 1 เดือน';

  @override
  String get currentTrendBasis => 'อิงจากแนวโน้มปัจจุบัน';

  @override
  String get predictionNotPossible => 'ไม่สามารถคาดการณ์ได้';

  @override
  String get trendInsufficient => 'แนวโน้มไม่เพียงพอ';

  @override
  String get recordFrequency => 'ความถี่ในการบันทึก';

  @override
  String get veryConsistent => 'สม่ำเสมอมาก';

  @override
  String get consistent => 'สม่ำเสมอ';

  @override
  String get irregular => 'ไม่สม่ำเสมอ';

  @override
  String averageDaysInterval(String days) {
    return 'ช่วงห่างเฉลี่ย $days วัน';
  }

  @override
  String get nextRecord => 'การบันทึกครั้งต่อไป';

  @override
  String get now => 'ตอนนี้';

  @override
  String get soon => 'เร็วๆ นี้';

  @override
  String daysLater(int days) {
    return '$days วันต่อมา';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'บันทึกเมื่อ $days วันที่แล้ว';
  }

  @override
  String get weeklyRecordRecommended => 'แนะนำให้บันทึกรายสัปดาห์';

  @override
  String get nextMilestone => 'เป้าหมายหลักถัดไป';

  @override
  String targetValue(String value, String unit) {
    return 'เป้าหมาย $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return 'เหลือ $remaining$unit ($progress% บรรลุ)';
  }

  @override
  String get calculationNotPossible => 'ไม่สามารถคำนวณได้';

  @override
  String get periodInsufficient => 'ช่วงเวลาไม่เพียงพอ';

  @override
  String get noDataAvailable => 'ไม่มีข้อมูล';

  @override
  String get weightRecordRequired => 'ต้องการบันทึกน้ำหนัก';

  @override
  String get heightRecordRequired => 'ต้องการบันทึกส่วนสูง';

  @override
  String get currentRecordMissing => 'ไม่มีบันทึกปัจจุบัน';

  @override
  String get noRecord => 'ไม่มีบันทึก';

  @override
  String get firstRecordStart => 'เริ่มบันทึกครั้งแรก';

  @override
  String get oneRecord => '1 บันทึก';

  @override
  String get moreRecordsNeeded => 'ต้องการบันทึกเพิ่มเติม';

  @override
  String get sameDayRecord => 'บันทึกวันเดียวกัน';

  @override
  String recordedTimes(int count) {
    return 'บันทึกแล้ว $count ครั้ง';
  }

  @override
  String get storageMethod => 'วิธีเก็บรักษา';

  @override
  String get pumpingType => 'ประเภทการปั๊มนม';

  @override
  String get foodName => 'ชื่ออาหาร';

  @override
  String get mealType => 'ประเภทอาหาร';

  @override
  String get texture => 'เนื้อสัมผัส';

  @override
  String get reaction => 'ปฏิกิริยา';

  @override
  String get measurementLocation => 'ตำแหน่งการวัด';

  @override
  String get feverReducerGiven => 'ให้ยาลดไข้แล้ว';

  @override
  String get given => 'ให้แล้ว';

  @override
  String get hours => 'ชั่วโมง';

  @override
  String get refrigerator => 'ตู้เย็น';

  @override
  String get freezer => 'ตู้แช่แข็ง';

  @override
  String get roomTemperature => 'อุณหภูมิห้อง';

  @override
  String get fedImmediately => 'ให้ทันที';

  @override
  String get breakfast => 'อาหารเช้า';

  @override
  String get lunch => 'อาหารกลางวัน';

  @override
  String get dinner => 'อาหารเย็น';

  @override
  String get snack => 'ของว่าง';

  @override
  String get monday => 'วันจันทร์';

  @override
  String get tuesday => 'วันอังคาร';

  @override
  String get wednesday => 'วันพุธ';

  @override
  String get thursday => 'วันพฤหัสบดี';

  @override
  String get friday => 'วันศุกร์';

  @override
  String get saturday => 'วันเสาร์';

  @override
  String get sunday => 'วันอาทิตย์';

  @override
  String get on => 'เปิด';

  @override
  String get off => 'ปิด';

  @override
  String get weightChange => 'การเปลี่ยนแปลงน้ำหนัก';

  @override
  String get heightChange => 'การเปลี่ยนแปลงส่วนสูง';

  @override
  String get totalRecords => 'บันทึกทั้งหมด';

  @override
  String get totalChange => 'การเปลี่ยนแปลงทั้งหมด';

  @override
  String get start => 'เริ่มต้น';

  @override
  String get memo => 'บันทึก';

  @override
  String get weightDataEmpty => 'ไม่มีข้อมูลน้ำหนัก';

  @override
  String get heightDataEmpty => 'ไม่มีข้อมูลส่วนสูง';
}
