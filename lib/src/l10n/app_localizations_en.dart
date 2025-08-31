// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get user => 'User';

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
  String get registerBaby => 'Register Baby';

  @override
  String get noBabiesRegistered => 'No babies registered';

  @override
  String get registerFirstBaby => 'Register your first baby!';

  @override
  String get registerBabyButton => 'Register Baby';

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
    return 'Gender';
  }

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

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
  String get babyName => 'Baby Name';

  @override
  String get babyNameHint => 'e.g. Emma';

  @override
  String get babyNameRequired => 'Please enter baby\'s name';

  @override
  String get babyNameMinLength => 'Name must be at least 2 characters';

  @override
  String get selectBirthdateButton => 'Select Birthdate';

  @override
  String selectedDate(int year, int month, int day) {
    return '$year/$month/$day';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Cancel';

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
  String get language => 'Language';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Please enter baby\'s name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get appearance => 'Appearance';

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
  String get comingSoon => 'Coming Soon';

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
  String get continueEditing => 'Continue Editing';

  @override
  String get discardChangesExit => 'Exit without saving changes?';

  @override
  String get exit => 'Exit';

  @override
  String get diaper => 'Diaper';

  @override
  String get solidFood => 'Solid Food';

  @override
  String get medication => 'Medication';

  @override
  String get milkPumping => 'Milk Pumping';

  @override
  String get temperature => 'Temperature';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Feeding Amount';

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
  String get sleepInProgress => 'Sleeping';

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
      'Enter content...\n\nFeel free to share your story.';

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
  String get refresh => 'Refresh';

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
  String get familyInvitation => 'Family Invitation';

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
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

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
  String get lastFeedingTime => 'Last feeding time';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours hours $minutes minutes ago';
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
  String get joinWithInviteCode => 'Join with Invitation Code';

  @override
  String get loadingBabyInfo => 'Loading baby information...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Go to Settings';

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
  String get breastMilk => 'Breast Milk';

  @override
  String get babyFood => 'Baby Food';

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
  String get diaperChange => 'Diaper Change';

  @override
  String get oralMedication => 'Oral Medication';

  @override
  String get topical => 'Topical';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Low Fever';

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
  String get periodSelection => 'Period selection:';

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
  String get tryAgain => 'Try Again';

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
      'Share parenting experiences and valuable information with other parents';

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
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Baby Food';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categoryVaccination => 'Vaccination';

  @override
  String get categoryPostpartum => 'Postpartum';

  @override
  String get sortByLikes => 'Sort by Likes';

  @override
  String get sortByLatest => 'Sort by Latest';

  @override
  String get edited => '(edited)';

  @override
  String commentsCount(Object count) {
    return '$count comments';
  }

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deletePostConfirm =>
      'Are you sure you want to delete this post?\nDeleted posts cannot be recovered.';

  @override
  String get deletePostSuccess => 'Post has been deleted.';

  @override
  String deletePostError(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get postNotFound => 'Post not found';

  @override
  String get shareFeatureComingSoon => 'Share feature coming soon';

  @override
  String get loadingComments => 'Loading comments...';

  @override
  String get loadMoreComments => 'Load more comments';

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
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteCommentConfirm =>
      'Are you sure you want to delete this comment?\nDeleted comments cannot be recovered.';

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
      'Share your thoughts...\n\nFeel free to write about your parenting experiences.';

  @override
  String imageSelectionError(Object error) {
    return 'Image selection failed: $error';
  }

  @override
  String get userNotFoundError => 'User information not found.';

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
  String get addImageTooltip => 'Add Image';

  @override
  String get allPostsChecked => 'All posts have been checked! 👍';

  @override
  String get waitForNewPosts => 'Please wait until new posts are uploaded';

  @override
  String get noPostsYet => 'No posts yet';

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
  String get noRecordedMoments => 'No recorded moments yet';

  @override
  String get loadingTimeline => 'Loading timeline...';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String noRecordsForDate(Object date) {
    return 'No records for $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'No $filter records for $date';
  }

  @override
  String get cannotRecordFuture => 'Cannot record future activities yet';

  @override
  String get addFirstRecord => 'Add your first record!';

  @override
  String get canAddPastRecord => 'You can add past records';

  @override
  String get addRecord => 'Add Record';

  @override
  String get viewOtherDates => 'View Other Dates';

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
  String get babyManagement => 'Baby Management';

  @override
  String get addBaby => 'Add Baby';

  @override
  String get noBabiesMessage => 'No babies registered.\nPlease add a baby.';

  @override
  String get switchToNextBaby => 'Switch to Next Baby';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get registering => 'Registering...';

  @override
  String get register => 'Register';

  @override
  String careTogetherWith(String name) {
    return 'Take care of babies together with $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Invite family or partners to\nmanage baby care records together';

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
  String get acceptInvite => 'Accept Invitation';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name has been registered successfully';
  }

  @override
  String get babyRegistrationFailed => 'Baby registration failed';

  @override
  String babyRegistrationError(String error) {
    return 'Error occurred: $error';
  }

  @override
  String babySelected(String name) {
    return '$name has been selected';
  }

  @override
  String get inviteCodeGenerated => 'Invitation code generated successfully!';

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
  String get noBabyInfo => 'No Baby Information';

  @override
  String get noBabyInfoDescription =>
      'No baby information found.\nWould you like to create a test baby?';

  @override
  String get create => 'Create';

  @override
  String get generateNewInviteCode => 'Generate New Invitation Code';

  @override
  String get replaceExistingCode =>
      'This will replace the existing invitation code.\nDo you want to continue?';

  @override
  String get acceptInvitation => 'Accept Invitation';

  @override
  String get acceptInvitationDescription =>
      'Do you want to accept the invitation and join the family?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Existing baby records will be deleted and replaced with the invited baby ($babyName).\n\nDo you want to continue?';
  }

  @override
  String get pleaseEnterInviteCode => 'Please enter the invitation code';

  @override
  String get inviteCodeMustBe6Digits => 'Invitation code must be 6 digits';

  @override
  String get pleaseLoginFirst =>
      'No login information found. Please login first.';

  @override
  String get copiedToClipboard => 'Invitation code copied to clipboard!';

  @override
  String get joinedSuccessfully => 'Successfully joined the family!';

  @override
  String get inviteCodeExpired => 'Invitation code has expired';

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
    return '$name\'s Baby Care Guide';
  }

  @override
  String get babyGuide => 'Baby Care Guide';

  @override
  String get noAvailableGuides => 'No available guides';

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
  String get feedingGuide => '💡 Feeding Guide';

  @override
  String get feedingFrequency => 'Feeding Frequency';

  @override
  String get singleFeedingAmount => 'Feeding Amount';

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
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get searchCommunityPosts => 'Search community posts';

  @override
  String get temperatureRecord => 'Temperature Record';

  @override
  String get temperatureTrend => 'Temperature Trend';

  @override
  String get profilePhotoSetup => 'Profile Photo Setup';

  @override
  String get howToSelectPhoto => 'How would you like to select a photo?';

  @override
  String get send => 'Send';

  @override
  String get emailVerificationRequired => 'Email Verification Required';

  @override
  String get passwordReset => 'Password Reset';

  @override
  String get enterEmailForReset =>
      'Enter your registered email address.\nWe\'ll send you a password reset link.';

  @override
  String get accountWithdrawalComplete => 'Account Withdrawal Complete';

  @override
  String get genderLabel => 'Gender: ';

  @override
  String get birthdateLabel => 'Birthdate: ';

  @override
  String get maleGender => 'Male';

  @override
  String get femaleGender => 'Female';

  @override
  String get joinWithInviteCodeButton => 'Join with Invite Code';

  @override
  String get temperatureRecorded => 'Temperature recorded';

  @override
  String recordFailed(String error) {
    return 'Record failed';
  }

  @override
  String get temperatureSettingsSaved => 'Temperature settings have been saved';

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
  String get accountLinkingComplete => 'Account Linking Complete';

  @override
  String get deleteConfirmation => 'Delete Confirmation';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get babyNameLabel => 'Baby Name';

  @override
  String get weightInput => 'Enter weight';

  @override
  String get heightInput => 'Enter height';

  @override
  String get measurementNotes =>
      'Record measurement conditions or special notes (optional)';

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
  String get good => 'Good';

  @override
  String get average => 'Average';

  @override
  String get poor => 'Poor';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get illness => 'Illness';

  @override
  String get highFever => 'High Fever';

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
  String get sleepQuality => 'Quality';

  @override
  String get pumpingTime => 'Pumping';

  @override
  String get solidFoodTime => 'Solid Food';

  @override
  String get totalFeedingAmount => 'Total Feeding Amount';

  @override
  String get averageFeedingAmount => 'Average feeding amount';

  @override
  String get dailyAverageFeedingCount => 'Daily average feeding count';

  @override
  String get clinical => 'Clinical';

  @override
  String get infoSharing => 'Info Sharing';

  @override
  String get sleepIssues => 'Sleep Issues';

  @override
  String get babyFoodCategory => 'Baby Food';

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
  String get searchError => 'Search error';

  @override
  String get question => 'Question';

  @override
  String get information => 'Information';

  @override
  String get relevance => 'Relevance';

  @override
  String get searchSuggestions => 'Search suggestions';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get likeFeatureComingSoon => 'Like feature coming soon';

  @override
  String get popularSearchTerms => 'Popular search terms';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get sortByComments => 'Sort by comments';

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
  String get previousDate => 'Previous date';

  @override
  String get nextDate => 'Next date';

  @override
  String get selectDate => 'Select date';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'Please register your baby';

  @override
  String get registerBabyToRecordMoments =>
      'To record your baby\'s precious moments,\nplease register baby information first.';

  @override
  String get addBabyFromHome => 'Add baby from home';

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
  String get noDetailedData => 'No detailed data';

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
    return '$name\'s Temperature Record';
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
  String get saveTemperatureRecord => 'Save Temperature Record';

  @override
  String get enterTemperature => 'Please enter temperature';

  @override
  String get temperatureRangeValidation =>
      'Temperature must be between 34.0°C ~ 42.0°C';

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
      'No temperature records in selected period';

  @override
  String get temperatureChangeTrend => 'Temperature Change Trend';

  @override
  String get averageTemperature => 'Average Temperature';

  @override
  String get highestTemperature => 'Highest Temperature';

  @override
  String get lowestTemperature => 'Lowest Temperature';

  @override
  String get noteAvailableTapToView => '📝 Note available (tap to view)';

  @override
  String get temperatureRisingTrend => 'Temperature is showing a rising trend';

  @override
  String get temperatureFallingTrend =>
      'Temperature is showing a falling trend';

  @override
  String get temperatureStableTrend => 'Temperature is stable';

  @override
  String get trendAnalysis => 'Trend Analysis';

  @override
  String totalMeasurements(int count) {
    return 'Total $count measurements';
  }

  @override
  String get temperatureRecordMemo => 'Temperature Record Memo';

  @override
  String babyGrowthChart(String name) {
    return '$name\'s Growth Chart';
  }

  @override
  String get noGrowthRecords => 'No growth records';

  @override
  String get enterWeightAndHeightFromHome =>
      'Please enter weight and height from home screen';

  @override
  String get all => 'All';

  @override
  String get growthInsights => 'Growth Insights';

  @override
  String get growthRate => 'Growth Rate';

  @override
  String get monthlyAverageGrowth => 'Monthly Average Growth';

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
  String get recordFrequency => 'Record Frequency';

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
  String get nextRecord => 'Next Record';

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
  String get nextMilestone => 'Next Milestone';

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
  String get noDataAvailable => 'No data available';

  @override
  String get weightRecordRequired => 'Weight record required';

  @override
  String get heightRecordRequired => 'Height record required';

  @override
  String get currentRecordMissing => 'Current record missing';

  @override
  String get noRecord => 'No record';

  @override
  String get firstRecordStart => 'Start your first record';

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
  String get pumpingType => 'Pumping Type';

  @override
  String get foodName => 'Food Name';

  @override
  String get mealType => 'Meal Type';

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
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get weightChange => 'Weight Change';

  @override
  String get heightChange => 'Height Change';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get totalChange => 'Total Change';

  @override
  String get start => 'Start';

  @override
  String get memo => 'Memo';

  @override
  String get weightDataEmpty => 'No weight data available';

  @override
  String get heightDataEmpty => 'No height data available';

  @override
  String get undoAction => 'Undo';

  @override
  String get feedingRecordDeleted => 'Feeding record deleted';

  @override
  String get sleepRecordDeleted => 'Sleep record deleted';

  @override
  String get diaperRecordDeleted => 'Diaper record deleted';

  @override
  String get healthRecordDeleted => 'Health record deleted';

  @override
  String get deletionError => 'Error occurred during deletion';

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
  String get lowGradeFever => 'Low Grade Fever';

  @override
  String get normalTemperature => 'Normal';

  @override
  String get allActivities => 'All';

  @override
  String get temperatureFilter => 'Temperature';

  @override
  String get deleteRecordTitle => 'Delete Record';

  @override
  String get deleteRecordMessage =>
      'Are you sure you want to delete this record?\nDeleted records cannot be recovered.';

  @override
  String get recordDeletedSuccess => 'Record has been deleted';

  @override
  String get recordDeleteFailed => 'Failed to delete record';

  @override
  String get recordDeleteError => 'An error occurred while deleting the record';

  @override
  String get recordUpdatedSuccess => 'Record has been updated';

  @override
  String get recordUpdateFailed => 'Failed to update record';

  @override
  String get recordUpdateError => 'An error occurred while updating the record';

  @override
  String noRecordsToday(Object recordType) {
    return 'No $recordType records today';
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
  String get recordAction => 'Record';

  @override
  String get end => 'End';

  @override
  String get minutesShort => 'm';
}
