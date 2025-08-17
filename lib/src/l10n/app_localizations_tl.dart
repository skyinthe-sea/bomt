// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get user => 'User';

  @override
  String userInfoLoadFailed(String error) {
    return 'Hindi na-load ang user info: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Error sa pag-load ng baby list: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Kumusta, $userName!';
  }

  @override
  String get registerBaby => 'I-register ang baby';

  @override
  String get noBabiesRegistered => 'Walang baby na naka-register';

  @override
  String get registerFirstBaby => 'I-register ang inyong unang baby!';

  @override
  String get registerBabyButton => 'Irehistro ang sanggol';

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
    return 'Kasarian';
  }

  @override
  String get male => 'Lalaki';

  @override
  String get female => 'Babae';

  @override
  String get other => 'Iba pa';

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
  String get enterBabyInfo => 'I-enter ang baby info';

  @override
  String get babyName => 'Pangalan ng baby';

  @override
  String get babyNameHint => 'halimbawa: Maria';

  @override
  String get babyNameRequired => 'I-enter ang pangalan ng baby';

  @override
  String get babyNameMinLength =>
      'Ang pangalan ay dapat may 2 characters o higit pa';

  @override
  String get selectBirthdateButton => 'Piliin ang kaarawan';

  @override
  String selectedDate(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Ikansela';

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
  String get settings => 'Settings';

  @override
  String get language => 'Wika';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'I-enter ang pangalan ng baby';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Mag-logout';

  @override
  String get logoutConfirm => 'Sigurado ka bang mag-logout?';

  @override
  String get yes => 'Oo';

  @override
  String get no => 'Hindi';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get appearance => 'Hitsura';

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
  String get comingSoon => 'Malapit na';

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
  String get growthInfo => 'Growth Info';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Feeding';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Sleep';

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
  String get continueEditing => 'Continue editing';

  @override
  String get discardChangesExit => 'Exit without saving changes?';

  @override
  String get exit => 'Exit';

  @override
  String get diaper => 'Diaper';

  @override
  String get solidFood => 'Solid Food';

  @override
  String get medication => 'Gamot';

  @override
  String get milkPumping => 'Milk Pumping';

  @override
  String get temperature => 'Temperatura';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Dami ng pagpapakain';

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
  String get weight => 'Weight';

  @override
  String get height => 'Height';

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
  String get enterValidNumber => 'Please enter a valid number';

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
  String get writePost => 'Sumulat ng post';

  @override
  String get post => 'I-post';

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
  String get selectCategory => 'Pumili ng category';

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
    return 'Content: $count/10000';
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
  String get refresh => 'I-refresh';

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
  String get familyInvitation => 'Family invitation';

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
  String get delete => 'Burahin';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Kumpirmahin';

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
    return '$minutes minuto na ang nakakaraan';
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
  String get medicationTime => 'Gamot';

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
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

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
    return '$months months $days days';
  }

  @override
  String get lastFeedingTime => 'Huling oras ng pagpapakain';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours oras $minutes minuto na ang nakakaraan';
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
  String get viewDetails => 'View Details';

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
  String get joinWithInviteCode => 'Sumali gamit ang invite code';

  @override
  String get loadingBabyInfo => 'Nilo-load ang baby info...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Pumunta sa Settings';

  @override
  String get profilePhotoUpdated => 'Na-update na ang profile photo.';

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
  String get hourActivityPattern => '24-Hour Activity Pattern';

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
  String get todaysStory => 'Today\'s Story';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Record your first precious moment.\nSmall daily changes add up to great growth.';

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
  String get formula => 'Formula';

  @override
  String get breastMilk => 'Gatas ng ina';

  @override
  String get babyFood => 'Pagkain ng sanggol';

  @override
  String get left => 'Kaliwa';

  @override
  String get right => 'Kanan';

  @override
  String get both => 'Pareho';

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
  String get topical => 'Pantapat sa balat';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Mababang lagnat';

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
  String get detailedStatistics => 'Detailed Statistics';

  @override
  String get chartAnalysis => 'Chart Analysis';

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
  String get tryAgain => 'Subukan ulit';

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
  String get search => 'Search';

  @override
  String get notification => 'Notification';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Magbahagi ng mga karanasan sa pagpapalaki ng anak at mahalagang impormasyon sa ibang mga magulang';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Lahat';

  @override
  String get categoryPopular => 'Sikat';

  @override
  String get categoryClinical => 'Clinical';

  @override
  String get categoryInfoSharing => 'Pagbabahagi ng info';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Pagkain ng baby';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categoryVaccination => 'Bakuna';

  @override
  String get categoryPostpartum => 'Pagkatapos manganak';

  @override
  String get sortByLikes => 'I-sort ayon sa likes';

  @override
  String get sortByLatest => 'I-sort ayon sa pinakabago';

  @override
  String get edited => '(na-edit)';

  @override
  String commentsCount(Object count) {
    return '$count comments';
  }

  @override
  String get deletePost => 'I-delete ang post';

  @override
  String get deletePostConfirm =>
      'Sigurado ka bang i-delete ang post na ito?\\nHindi na maibabalik ang na-delete na posts.';

  @override
  String get deletePostSuccess => 'Na-delete ang post.';

  @override
  String deletePostError(Object error) {
    return 'Hindi na-delete: $error';
  }

  @override
  String get postNotFound => 'Hindi nahanap ang post';

  @override
  String get shareFeatureComingSoon => 'Share feature ay malapit na';

  @override
  String get loadingComments => 'Nilo-load ang comments...';

  @override
  String get loadMoreComments => 'Mag-load ng higit pang comments';

  @override
  String get editComment => 'I-edit ang comment';

  @override
  String get editCommentHint => 'I-edit ang inyong comment...';

  @override
  String get editCommentSuccess => 'Na-update ang comment.';

  @override
  String editCommentError(Object error) {
    return 'Hindi na-edit: $error';
  }

  @override
  String get deleteComment => 'I-delete ang comment';

  @override
  String get deleteCommentConfirm =>
      'Sigurado ka bang i-delete ang comment na ito?\\nHindi na maibabalik ang na-delete na comments.';

  @override
  String get deleteCommentSuccess => 'Na-delete ang comment.';

  @override
  String get replySuccess => 'Na-post ang reply.';

  @override
  String get commentSuccess => 'Na-post ang comment.';

  @override
  String get commentError => 'Hindi na-post ang comment.';

  @override
  String get titlePlaceholder => 'I-enter ang title';

  @override
  String get contentPlaceholder =>
      'I-share ang inyong mga iniisip...\\n\\nSumulat nang malaya tungkol sa inyong mga karanasan bilang magulang.';

  @override
  String imageSelectionError(Object error) {
    return 'Hindi napili ang larawan: $error';
  }

  @override
  String get userNotFoundError => 'Hindi nahanap ang user info.';

  @override
  String get postCreateSuccess => 'Matagumpay na nagawa ang post!';

  @override
  String postCreateError(Object error) {
    return 'Hindi nagawa ang post: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Title: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Mga larawan: $count/5';
  }

  @override
  String get addImageTooltip => 'Magdagdag ng larawan';

  @override
  String get allPostsChecked => 'Lahat ng posts ay na-check na! 👍';

  @override
  String get waitForNewPosts => 'Maghintay ng mga bagong posts';

  @override
  String get noPostsYet => 'Wala pang posts';

  @override
  String get writeFirstPost => 'Magsulat ng unang post!';

  @override
  String get loadingNewPosts => 'Nilo-load ang mga bagong posts...';

  @override
  String get failedToLoadPosts => 'Hindi na-load ang mga posts';

  @override
  String get checkNetworkAndRetry => 'I-check ang connection at subukan ulit';

  @override
  String get categoryDailyLife => 'Araw-araw na buhay';

  @override
  String get preparingTimeline => 'Inihahanda ang timeline...';

  @override
  String get noRecordedMoments => 'Wala pang naka-record na moments';

  @override
  String get loadingTimeline => 'Nilo-load ang timeline...';

  @override
  String get noRecordsYet => 'Wala pang records';

  @override
  String noRecordsForDate(Object date) {
    return 'Walang records para sa $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Walang $filter records para sa $date';
  }

  @override
  String get cannotRecordFuture =>
      'Hindi pa pwedeng mag-record ng future activities';

  @override
  String get addFirstRecord => 'Magdagdag ng unang record!';

  @override
  String get canAddPastRecord => 'Pwede kayong magdagdag ng past records';

  @override
  String get addRecord => 'Magdagdag ng record';

  @override
  String get viewOtherDates => 'Tingnan ang ibang dates';

  @override
  String get goToToday => 'Pumunta sa ngayon';

  @override
  String get quickRecordFromHome =>
      'Mabilis kayong makapag-add ng records sa home screen';

  @override
  String detailViewComingSoon(String title) {
    return '$title details (Malapit na)';
  }

  @override
  String get familyInvitationDescription =>
      'Pamahalaan ang baby care records kasama ang pamilya gamit ang invitation codes';

  @override
  String get babyManagement => 'Baby management';

  @override
  String get addBaby => 'Magdagdag ng sanggol';

  @override
  String get noBabiesMessage =>
      'Walang baby na naka-register.\\nPakidagdag ang baby.';

  @override
  String get switchToNextBaby => 'Lumipat sa susunod na baby';

  @override
  String get birthDate => 'Kaarawan';

  @override
  String get registering => 'Nire-register...';

  @override
  String get register => 'Register';

  @override
  String careTogetherWith(String name) {
    return 'Alagaan ang baby kasama si $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Anyayahan ang pamilya o partner\\npara pamahalaan ang baby care records';

  @override
  String get generateInviteCode => 'Gumawa ng invite code';

  @override
  String get generateInviteCodeDescription =>
      'Gumawa ng bagong invite code at i-copy';

  @override
  String get generateInviteCodeButton => 'Gumawa ng invite code';

  @override
  String get orText => 'O';

  @override
  String get enterInviteCodeDescription =>
      'I-enter ang natanggap na invite code';

  @override
  String get inviteCodePlaceholder => 'Invite code (6 digits)';

  @override
  String get acceptInvite => 'Tanggapin ang invitation';

  @override
  String babyRegistrationSuccess(String name) {
    return 'Matagumpay na na-register si $name';
  }

  @override
  String get babyRegistrationFailed => 'Hindi na-register ang baby';

  @override
  String babyRegistrationError(String error) {
    return 'May nangyaring error: $error';
  }

  @override
  String babySelected(String name) {
    return 'Napili si $name';
  }

  @override
  String get inviteCodeGenerated => 'Nagawa ang invite code!';

  @override
  String remainingTime(String time) {
    return 'Natitirang oras: $time';
  }

  @override
  String get validTime => 'Valid na oras: 5 minuto';

  @override
  String get generating => 'Ginagawa...';

  @override
  String get joining => 'Sumasali...';

  @override
  String get noBabyInfo => 'Walang baby info';

  @override
  String get noBabyInfoDescription =>
      'Hindi nahanap ang baby info.\\nGusto ba ninyong gumawa ng test baby?';

  @override
  String get create => 'Gumawa';

  @override
  String get generateNewInviteCode => 'Gumawa ng bagong invite code';

  @override
  String get replaceExistingCode =>
      'Papalitan nito ang existing invite code.\\nGusto ba ninyong magpatuloy?';

  @override
  String get acceptInvitation => 'Tanggapin ang invitation';

  @override
  String get acceptInvitationDescription =>
      'Gusto ba ninyong tanggapin ang invitation at sumali sa pamilya?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Ang existing baby records ay matatanggal at papalitan ng invited baby ($babyName).\\n\\nGusto ba ninyong magpatuloy?';
  }

  @override
  String get pleaseEnterInviteCode => 'I-enter ang invite code';

  @override
  String get inviteCodeMustBe6Digits => 'Ang invite code ay dapat 6 digits';

  @override
  String get pleaseLoginFirst =>
      'Hindi nahanap ang login info. Mag-login muna.';

  @override
  String get copiedToClipboard => 'Na-copy ang invite code!';

  @override
  String get joinedSuccessfully => 'Matagumpay na sumali sa pamilya!';

  @override
  String get inviteCodeExpired => 'Nag-expire ang invite code';

  @override
  String get invalidInviteCode => 'Hindi valid ang invite code';

  @override
  String get alreadyMember => 'Member ka na ng pamilyang ito';

  @override
  String get cannotInviteSelf => 'Hindi mo pwedeng anyayahan ang sarili mo';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Baby care guide ni $name';
  }

  @override
  String get babyGuide => 'Baby guide';

  @override
  String get noAvailableGuides => 'Walang available na guides';

  @override
  String get current => 'Kasalukuyan';

  @override
  String get past => 'Nakaraan';

  @override
  String get upcoming => 'Paparating';

  @override
  String babysGuide(String name) {
    return 'ni $name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Guide sa $weekText';
  }

  @override
  String get feedingGuide => '💡 Feeding guide';

  @override
  String get feedingFrequency => 'Feeding frequency';

  @override
  String get singleFeedingAmount => 'Dami bawat feeding';

  @override
  String get dailyTotal => 'Kabuuang araw-araw';

  @override
  String get additionalTips => '📋 Karagdagang tips';

  @override
  String get understood => 'Naiintindihan!';

  @override
  String get newborn => 'Bagong silang';

  @override
  String weekNumber(int number) {
    return 'Linggo $number';
  }

  @override
  String get newbornWeek0 => 'Bagong silang (Linggo 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Araw-araw $min - $max beses';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Araw-araw $min+ beses';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Araw-araw hanggang $max beses';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml o higit pa';
  }

  @override
  String amountMaxML(int max) {
    return 'Hanggang ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Pagpili ng Wika';

  @override
  String get selectLanguage => 'Pumili ng wika';

  @override
  String get currentLanguage => 'Kasalukuyang wika';

  @override
  String get searchCommunityPosts => 'Maghanap ng mga post sa komunidad';

  @override
  String get temperatureRecord => 'Tala ng temperatura';

  @override
  String get temperatureTrend => 'Trend ng temperatura';

  @override
  String get profilePhotoSetup => 'Pag-setup ng profile photo';

  @override
  String get howToSelectPhoto => 'Paano mo gustong pumili ng larawan?';

  @override
  String get send => 'Ipadala';

  @override
  String get emailVerificationRequired => 'Kailangan ng email verification';

  @override
  String get passwordReset => 'I-reset ang password';

  @override
  String get enterEmailForReset =>
      'Ilagay ang inyong registered email address.\nMagpapadala kami ng password reset link.';

  @override
  String get accountWithdrawalComplete =>
      'Kumpleto na ang pag-cancel ng account';

  @override
  String get genderLabel => 'Kasarian: ';

  @override
  String get birthdateLabel => 'Petsa ng kapanganakan: ';

  @override
  String get maleGender => 'Lalaki';

  @override
  String get femaleGender => 'Babae';

  @override
  String get joinWithInviteCodeButton => 'Sumali gamit ang invite code';

  @override
  String get temperatureRecorded => 'Naitala na ang temperatura';

  @override
  String recordFailed(String error) {
    return 'Nabigo ang pagtala: $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'Na-save na ang mga setting ng temperatura';

  @override
  String get loadingUserInfo =>
      'Nilo-load ang user information. Subukan ulit mamaya.';

  @override
  String get continueWithSeparateAccount => 'Magpatuloy sa hiwalay na account';

  @override
  String get linkWithExistingAccount => 'I-link sa existing account';

  @override
  String get linkAccount => 'I-link ang account';

  @override
  String get accountLinkingComplete => 'Kumpleto na ang pag-link ng account';

  @override
  String get deleteConfirmation => 'Pagkumpirma ng pagbura';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get babyNameLabel => 'Pangalan ng sanggol';

  @override
  String get weightInput => 'Ilagay ang timbang';

  @override
  String get heightInput => 'Ilagay ang taas';

  @override
  String get measurementNotes =>
      'Itala ang mga kondisyon ng pagsukat o mga espesyal na tala (opsyonal)';

  @override
  String get urine => 'Ihi';

  @override
  String get stool => 'Tae';

  @override
  String get yellow => 'Dilaw';

  @override
  String get brown => 'Kayumanggi';

  @override
  String get green => 'Berde';

  @override
  String get bottle => 'Bote';

  @override
  String get good => 'Mabuti';

  @override
  String get average => 'Katamtaman';

  @override
  String get poor => 'Masama';

  @override
  String get vaccination => 'Bakuna';

  @override
  String get illness => 'Sakit';

  @override
  String get highFever => 'Mataas na lagnat';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhinyahan';

  @override
  String get injection => 'Iniksyon';

  @override
  String get tablet => 'Tableta';

  @override
  String get drops => 'Patak';

  @override
  String get teaspoon => 'Kutsarita';

  @override
  String get tablespoon => 'Kutsara';

  @override
  String get sleepQuality => 'Tulog';

  @override
  String get pumpingTime => 'Pag-extract';

  @override
  String get solidFoodTime => 'Solid na pagkain';

  @override
  String get totalFeedingAmount => 'Kabuuang dami ng pagpapakain';

  @override
  String get averageFeedingAmount => 'Average na dami ng pagpapakain';

  @override
  String get dailyAverageFeedingCount =>
      'Araw-araw na average na bilang ng pagpapakain';

  @override
  String get clinical => 'Clinical';

  @override
  String get infoSharing => 'Pagbabahagi ng impormasyon';

  @override
  String get sleepIssues => 'Mga problema sa tulog';

  @override
  String get babyFoodCategory => 'Pagkain ng sanggol';

  @override
  String get developmentStage => 'Yugto ng pag-unlad';

  @override
  String get vaccinationCategory => 'Bakuna';

  @override
  String get postpartumRecovery => 'Pagbangon pagkatapos manganak';

  @override
  String get dailyLife => 'Pang-araw-araw na buhay';

  @override
  String get likes => 'Mga like';

  @override
  String get comments => 'Mga komento';

  @override
  String get anonymous => 'Hindi kilala';

  @override
  String get minutes => 'Mga minuto';

  @override
  String get armpit => 'Kilikili';

  @override
  String get forehead => 'Noo';

  @override
  String get ear => 'Tainga';

  @override
  String get mouth => 'Bibig';

  @override
  String get rectal => 'Rectal';

  @override
  String get otherLocation => 'Iba pa';

  @override
  String get searchError => 'Error sa paghahanap';

  @override
  String get question => 'Tanong';

  @override
  String get information => 'Impormasyon';

  @override
  String get relevance => 'Kaugnayan';

  @override
  String get searchSuggestions => 'Mga mungkahi sa paghahanap';

  @override
  String get noSearchResults => 'Walang resulta ng paghahanap';

  @override
  String get tryDifferentSearchTerm => 'Subukan ang ibang search term';

  @override
  String get likeFeatureComingSoon => 'Like feature ay malapit na';

  @override
  String get popularSearchTerms => 'Sikat na search terms';

  @override
  String get recentSearches => 'Kamakailang paghahanap';

  @override
  String get deleteAll => 'Tanggalin lahat';

  @override
  String get sortByComments => 'Ayusin ayon sa mga komento';

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
}
