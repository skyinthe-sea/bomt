// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get user => 'Benutzer';

  @override
  String userInfoLoadFailed(String error) {
    return 'Laden der Benutzerinformationen fehlgeschlagen: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Fehler beim Laden der Babyliste: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Hallo, $userName!';
  }

  @override
  String get registerBaby => 'Baby registrieren';

  @override
  String get noBabiesRegistered => 'Keine Babys registriert';

  @override
  String get registerFirstBaby => 'Registrieren Sie Ihr erstes Baby!';

  @override
  String get registerBabyButton => 'Baby registrieren';

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
    return 'Geschlecht';
  }

  @override
  String get male => 'Junge';

  @override
  String get female => 'Mädchen';

  @override
  String get other => 'Andere';

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
  String get enterBabyInfo => 'Bitte geben Sie die Baby-Informationen ein';

  @override
  String get babyName => 'Baby-Name';

  @override
  String get babyNameHint => 'z.B. Emma';

  @override
  String get babyNameRequired => 'Bitte geben Sie den Namen des Babys ein';

  @override
  String get babyNameMinLength => 'Der Name muss mindestens 2 Zeichen haben';

  @override
  String get selectBirthdateButton => 'Geburtsdatum auswählen';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day.$month.$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Abbrechen';

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
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Bitte geben Sie den Namen des Babys ein';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirm =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get appearance => 'Darstellung';

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
  String get comingSoon => 'Bald verfügbar';

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
  String get growthInfo => 'Wachstumsinfo';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Füttern';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Schlaf';

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
  String get diaper => 'Windel';

  @override
  String get solidFood => 'Feste Nahrung';

  @override
  String get medication => 'Medikament';

  @override
  String get milkPumping => 'Milchpumpe';

  @override
  String get temperature => 'Temperatur';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Fütterungsmenge';

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
  String get weight => 'Gewicht';

  @override
  String get height => 'Größe';

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
  String get writePost => 'Beitrag schreiben';

  @override
  String get post => 'Posten';

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
  String get selectCategory => 'Kategorie auswählen';

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
    return 'Inhalt: $count/10000';
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
  String get refresh => 'Aktualisieren';

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
  String get familyInvitation => 'Familieneinladung';

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
  String get delete => 'Löschen';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Bestätigen';

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
    return '$minutes Minuten her';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Heute';

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
  String get medicationTime => 'Medikament';

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
  String get gallery => 'Galerie';

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
    return '$months Monate $days Tage';
  }

  @override
  String get lastFeedingTime => 'Letzte Stillzeit';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours Stunden $minutes Minuten her';
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
  String get viewDetails => 'Details anzeigen';

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
  String get joinWithInviteCode => 'Mit Einladungscode beitreten';

  @override
  String get loadingBabyInfo => 'Baby-Informationen werden geladen...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Zu Einstellungen';

  @override
  String get profilePhotoUpdated => 'Profilbild wurde aktualisiert.';

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
  String get hourActivityPattern => '24-Stunden-Aktivitätsmuster';

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
  String get todaysStory => 'Heutige Geschichte';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Erfassen Sie Ihren ersten kostbaren Moment.\nKleine tägliche Veränderungen fügen sich zu großem Wachstum zusammen.';

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
  String get formula => 'Säuglingsmilch';

  @override
  String get breastMilk => 'Muttermilch';

  @override
  String get babyFood => 'Babynahrung';

  @override
  String get left => 'Links';

  @override
  String get right => 'Rechts';

  @override
  String get both => 'Beide';

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
  String get topical => 'Äußerlich';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Leichtes Fieber';

  @override
  String get hypothermia => 'Unterkühlung';

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
  String get detailedStatistics => 'Detaillierte Statistiken';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Gesamtaktivitätsübersicht';

  @override
  String get totalActivities => 'Gesamtaktivitäten';

  @override
  String get activeCards => 'Aktive Karten';

  @override
  String get dailyAverage => 'Tagesdurchschnitt';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Erneut versuchen';

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
  String get search => 'Suchen';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Teilen Sie Ihre Elternerfahrungen und wertvolle Informationen mit anderen Eltern';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryPopular => 'Beliebt';

  @override
  String get categoryClinical => 'Klinisch';

  @override
  String get categoryInfoSharing => 'Informationsaustausch';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Babynahrung';

  @override
  String get categoryDevelopment => 'Entwicklungsstufe';

  @override
  String get categoryVaccination => 'Impfung';

  @override
  String get categoryPostpartum => 'Wochenbett';

  @override
  String get sortByLikes => 'Nach Likes sortieren';

  @override
  String get sortByLatest => 'Nach Neueste sortieren';

  @override
  String get edited => '(bearbeitet)';

  @override
  String commentsCount(Object count) {
    return '$count Kommentare';
  }

  @override
  String get deletePost => 'Beitrag löschen';

  @override
  String get deletePostConfirm =>
      'Sind Sie sicher, dass Sie diesen Beitrag löschen möchten?\nGelöschte Beiträge können nicht wiederhergestellt werden.';

  @override
  String get deletePostSuccess => 'Beitrag wurde gelöscht.';

  @override
  String deletePostError(Object error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get postNotFound => 'Beitrag nicht gefunden';

  @override
  String get shareFeatureComingSoon => 'Teilen-Funktion bald verfügbar';

  @override
  String get loadingComments => 'Kommentare werden geladen...';

  @override
  String get loadMoreComments => 'Mehr Kommentare laden';

  @override
  String get editComment => 'Kommentar bearbeiten';

  @override
  String get editCommentHint => 'Bearbeiten Sie Ihren Kommentar...';

  @override
  String get editCommentSuccess => 'Kommentar wurde aktualisiert.';

  @override
  String editCommentError(Object error) {
    return 'Bearbeitung fehlgeschlagen: $error';
  }

  @override
  String get deleteComment => 'Kommentar löschen';

  @override
  String get deleteCommentConfirm =>
      'Sind Sie sicher, dass Sie diesen Kommentar löschen möchten?\nGelöschte Kommentare können nicht wiederhergestellt werden.';

  @override
  String get deleteCommentSuccess => 'Kommentar wurde gelöscht.';

  @override
  String get replySuccess => 'Antwort wurde gepostet.';

  @override
  String get commentSuccess => 'Kommentar wurde gepostet.';

  @override
  String get commentError => 'Kommentar konnte nicht gepostet werden.';

  @override
  String get titlePlaceholder => 'Titel eingeben';

  @override
  String get contentPlaceholder =>
      'Teilen Sie Ihre Gedanken...\n\nSchreiben Sie gerne über Ihre Erfahrungen als Eltern.';

  @override
  String imageSelectionError(Object error) {
    return 'Bildauswahl fehlgeschlagen: $error';
  }

  @override
  String get userNotFoundError => 'Benutzerinformationen nicht gefunden.';

  @override
  String get postCreateSuccess => 'Beitrag wurde erfolgreich erstellt!';

  @override
  String postCreateError(Object error) {
    return 'Beitrag-Erstellung fehlgeschlagen: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Titel: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Bilder: $count/5';
  }

  @override
  String get addImageTooltip => 'Bild hinzufügen';

  @override
  String get allPostsChecked => 'Alle Beiträge wurden überprüft! 👍';

  @override
  String get waitForNewPosts =>
      'Bitte warten Sie, bis neue Beiträge hochgeladen werden';

  @override
  String get noPostsYet => 'Noch keine Beiträge';

  @override
  String get writeFirstPost => 'Schreiben Sie den ersten Beitrag!';

  @override
  String get loadingNewPosts => 'Neue Beiträge werden geladen...';

  @override
  String get failedToLoadPosts => 'Beiträge konnten nicht geladen werden';

  @override
  String get checkNetworkAndRetry =>
      'Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut';

  @override
  String get categoryDailyLife => 'Alltag';

  @override
  String get preparingTimeline => 'Timeline wird vorbereitet...';

  @override
  String get noRecordedMoments => 'Noch keine aufgezeichneten Momente';

  @override
  String get loadingTimeline => 'Timeline wird geladen...';

  @override
  String get noRecordsYet => 'Noch keine Aufzeichnungen';

  @override
  String noRecordsForDate(Object date) {
    return 'Keine Aufzeichnungen für $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Keine $filter Aufzeichnungen für $date';
  }

  @override
  String get cannotRecordFuture =>
      'Zukünftige Aktivitäten können noch nicht aufgezeichnet werden';

  @override
  String get addFirstRecord => 'Fügen Sie Ihre erste Aufzeichnung hinzu!';

  @override
  String get canAddPastRecord =>
      'Sie können vergangene Aufzeichnungen hinzufügen';

  @override
  String get addRecord => 'Aufzeichnung hinzufügen';

  @override
  String get viewOtherDates => 'Andere Daten anzeigen';

  @override
  String get goToToday => 'Zu heute gehen';

  @override
  String get quickRecordFromHome =>
      'Sie können schnell Aufzeichnungen vom Startbildschirm hinzufügen';

  @override
  String detailViewComingSoon(String title) {
    return '$title Details (Bald verfügbar)';
  }

  @override
  String get familyInvitationDescription =>
      'Verwalten Sie Babybetreuungsaufzeichnungen gemeinsam mit der Familie über Einladungscodes';

  @override
  String get babyManagement => 'Baby-Verwaltung';

  @override
  String get addBaby => 'Baby hinzufügen';

  @override
  String get noBabiesMessage =>
      'Keine Babys registriert.\nBitte fügen Sie ein Baby hinzu.';

  @override
  String get switchToNextBaby => 'Zum nächsten Baby wechseln';

  @override
  String get birthDate => 'Geburtsdatum';

  @override
  String get registering => 'Registrierung läuft...';

  @override
  String get register => 'Registrieren';

  @override
  String careTogetherWith(String name) {
    return 'Betreuen Sie Babys gemeinsam mit $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Laden Sie Familie oder Partner ein,\num gemeinsam Babybetreuungsaufzeichnungen zu verwalten';

  @override
  String get generateInviteCode => 'Einladungscode generieren';

  @override
  String get generateInviteCodeDescription =>
      'Generieren Sie einen neuen Einladungscode und kopieren Sie ihn';

  @override
  String get generateInviteCodeButton => 'Einladungscode generieren';

  @override
  String get orText => 'Oder';

  @override
  String get enterInviteCodeDescription =>
      'Bitte geben Sie den erhaltenen Einladungscode ein';

  @override
  String get inviteCodePlaceholder => 'Einladungscode (6 Stellen)';

  @override
  String get acceptInvite => 'Einladung annehmen';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name wurde erfolgreich registriert';
  }

  @override
  String get babyRegistrationFailed => 'Baby-Registrierung fehlgeschlagen';

  @override
  String babyRegistrationError(String error) {
    return 'Fehler aufgetreten: $error';
  }

  @override
  String babySelected(String name) {
    return '$name wurde ausgewählt';
  }

  @override
  String get inviteCodeGenerated => 'Einladungscode generiert!';

  @override
  String remainingTime(String time) {
    return 'Verbleibende Zeit: $time';
  }

  @override
  String get validTime => 'Gültigkeitsdauer: 5 Minuten';

  @override
  String get generating => 'Generierung läuft...';

  @override
  String get joining => 'Beitritt läuft...';

  @override
  String get noBabyInfo => 'Keine Baby-Informationen';

  @override
  String get noBabyInfoDescription =>
      'Keine Baby-Informationen gefunden.\nMöchten Sie ein Test-Baby erstellen?';

  @override
  String get create => 'Erstellen';

  @override
  String get generateNewInviteCode => 'Neuen Einladungscode generieren';

  @override
  String get replaceExistingCode =>
      'Dies ersetzt den bestehenden Einladungscode.\nMöchten Sie fortfahren?';

  @override
  String get acceptInvitation => 'Einladung annehmen';

  @override
  String get acceptInvitationDescription =>
      'Möchten Sie die Einladung annehmen und der Familie beitreten?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Bestehende Baby-Aufzeichnungen werden gelöscht und durch das eingeladene Baby ($babyName) ersetzt.\n\nMöchten Sie fortfahren?';
  }

  @override
  String get pleaseEnterInviteCode => 'Bitte geben Sie den Einladungscode ein';

  @override
  String get inviteCodeMustBe6Digits => 'Einladungscode muss 6 Stellen haben';

  @override
  String get pleaseLoginFirst =>
      'Keine Anmeldeinformationen gefunden. Bitte melden Sie sich zuerst an.';

  @override
  String get copiedToClipboard =>
      'Einladungscode in die Zwischenablage kopiert!';

  @override
  String get joinedSuccessfully => 'Erfolgreich der Familie beigetreten!';

  @override
  String get inviteCodeExpired => 'Einladungscode ist abgelaufen';

  @override
  String get invalidInviteCode => 'Ungültiger Einladungscode';

  @override
  String get alreadyMember => 'Sie sind bereits Mitglied dieser Familie';

  @override
  String get cannotInviteSelf => 'Sie können sich nicht selbst einladen';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return '${name}s Babypflege-Leitfaden';
  }

  @override
  String get babyGuide => 'Babypflege-Leitfaden';

  @override
  String get noAvailableGuides => 'Keine verfügbaren Leitfäden';

  @override
  String get current => 'Aktuell';

  @override
  String get past => 'Vergangen';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String babysGuide(String name) {
    return '${name}s';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText Leitfaden';
  }

  @override
  String get feedingGuide => '💡 Fütterungs-Leitfaden';

  @override
  String get feedingFrequency => 'Fütterungshäufigkeit';

  @override
  String get singleFeedingAmount => 'Fütterungsmenge';

  @override
  String get dailyTotal => 'Tägliche Gesamtmenge';

  @override
  String get additionalTips => '📋 Zusätzliche Tipps';

  @override
  String get understood => 'Verstanden!';

  @override
  String get newborn => 'Neugeborenes';

  @override
  String weekNumber(int number) {
    return 'Woche $number';
  }

  @override
  String get newbornWeek0 => 'Neugeborenes (Woche 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Täglich $min - $max Mal';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Täglich $min+ Mal';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Täglich bis zu $max Mal';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml oder mehr';
  }

  @override
  String amountMaxML(int max) {
    return 'Bis zu ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Sprachauswahl';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get currentLanguage => 'Aktuelle Sprache';

  @override
  String get searchCommunityPosts => 'Community-Beiträge durchsuchen';

  @override
  String get temperatureRecord => 'Temperatur-Aufzeichnung';

  @override
  String get temperatureTrend => 'Temperaturtrend';

  @override
  String get profilePhotoSetup => 'Profilbild einrichten';

  @override
  String get howToSelectPhoto => 'Wie möchten Sie ein Foto auswählen?';

  @override
  String get send => 'Senden';

  @override
  String get emailVerificationRequired => 'E-Mail-Verifizierung erforderlich';

  @override
  String get passwordReset => 'Passwort zurücksetzen';

  @override
  String get enterEmailForReset =>
      'Geben Sie Ihre registrierte E-Mail-Adresse ein.\nWir senden Ihnen einen Link zum Zurücksetzen des Passworts.';

  @override
  String get accountWithdrawalComplete => 'Konto-Kündigung abgeschlossen';

  @override
  String get genderLabel => 'Geschlecht: ';

  @override
  String get birthdateLabel => 'Geburtsdatum: ';

  @override
  String get maleGender => 'Männlich';

  @override
  String get femaleGender => 'Weiblich';

  @override
  String get joinWithInviteCodeButton => 'Mit Einladungscode beitreten';

  @override
  String get temperatureRecorded => 'Temperatur wurde aufgezeichnet';

  @override
  String recordFailed(String error) {
    return 'Aufzeichnung fehlgeschlagen: $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'Temperatur-Einstellungen wurden gespeichert';

  @override
  String get loadingUserInfo =>
      'Benutzerinformationen werden geladen. Bitte versuchen Sie es in einem Moment erneut.';

  @override
  String get continueWithSeparateAccount => 'Mit separatem Konto fortfahren';

  @override
  String get linkWithExistingAccount => 'Mit vorhandenem Konto verknüpfen';

  @override
  String get linkAccount => 'Konto verknüpfen';

  @override
  String get accountLinkingComplete => 'Konto-Verknüpfung abgeschlossen';

  @override
  String get deleteConfirmation => 'Löschbestätigung';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get babyNameLabel => 'Baby-Name';

  @override
  String get weightInput => 'Gewicht eingeben';

  @override
  String get heightInput => 'Größe eingeben';

  @override
  String get measurementNotes =>
      'Messbedingungen oder besondere Notizen aufzeichnen (optional)';

  @override
  String get urine => 'Urin';

  @override
  String get stool => 'Stuhl';

  @override
  String get yellow => 'Gelb';

  @override
  String get brown => 'Braun';

  @override
  String get green => 'Grün';

  @override
  String get bottle => 'Fläschchen';

  @override
  String get good => 'Gut';

  @override
  String get average => 'Durchschnittlich';

  @override
  String get poor => 'Schlecht';

  @override
  String get vaccination => 'Impfung';

  @override
  String get illness => 'Krankheit';

  @override
  String get highFever => 'Hohes Fieber';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhalation';

  @override
  String get injection => 'Injektion';

  @override
  String get tablet => 'Tablette';

  @override
  String get drops => 'Tropfen';

  @override
  String get teaspoon => 'Teelöffel';

  @override
  String get tablespoon => 'Esslöffel';

  @override
  String get sleepQuality => 'Schlaf';

  @override
  String get pumpingTime => 'Abpumpen';

  @override
  String get solidFoodTime => 'Feste Nahrung';

  @override
  String get totalFeedingAmount => 'Gesamte Fütterungsmenge';

  @override
  String get averageFeedingAmount => 'Durchschnittliche Fütterungsmenge';

  @override
  String get dailyAverageFeedingCount =>
      'Tägliche durchschnittliche Fütterungsanzahl';

  @override
  String get clinical => 'Klinisch';

  @override
  String get infoSharing => 'Informationsaustausch';

  @override
  String get sleepIssues => 'Schlafprobleme';

  @override
  String get babyFoodCategory => 'Babynahrung';

  @override
  String get developmentStage => 'Entwicklungsstadium';

  @override
  String get vaccinationCategory => 'Impfung';

  @override
  String get postpartumRecovery => 'Wochenbett-Erholung';

  @override
  String get dailyLife => 'Alltag';

  @override
  String get likes => 'Gefällt mir';

  @override
  String get comments => 'Kommentare';

  @override
  String get anonymous => 'Anonym';

  @override
  String get minutes => 'Minuten';

  @override
  String get armpit => 'Achselhöhle';

  @override
  String get forehead => 'Stirn';

  @override
  String get ear => 'Ohr';

  @override
  String get mouth => 'Mund';

  @override
  String get rectal => 'Rektal';

  @override
  String get otherLocation => 'Andere';

  @override
  String get searchError => 'Suchfehler';

  @override
  String get question => 'Frage';

  @override
  String get information => 'Information';

  @override
  String get relevance => 'Relevanz';

  @override
  String get searchSuggestions => 'Suchvorschläge';

  @override
  String get noSearchResults => 'Keine Suchergebnisse';

  @override
  String get tryDifferentSearchTerm =>
      'Versuchen Sie einen anderen Suchbegriff';

  @override
  String get likeFeatureComingSoon => 'Like-Funktion kommt bald';

  @override
  String get popularSearchTerms => 'Beliebte Suchbegriffe';

  @override
  String get recentSearches => 'Neueste Suchen';

  @override
  String get deleteAll => 'Alle löschen';

  @override
  String get sortByComments => 'Nach Kommentaren sortieren';

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
    return '$minutes Minuten im Gange';
  }

  @override
  String get sleepProgressTime => 'Schlaffortschritt';

  @override
  String get standardFeedingTimeNow => 'Es ist Standard-Fütterungszeit';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return 'Standard-Fütterungszeit kommt bald ($minutes Minuten)';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '$hours Stunden $minutes Minuten bis zur Standard-Fütterung';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '$minutes Minuten bis zur Standard-Fütterung';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      'Unzureichende Fütterungsaufzeichnungen (Standard-Intervall anwenden)';

  @override
  String get standardFeedingTimeOverdue =>
      'Standard-Fütterungszeit ist überfällig';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours Stunden $minutes Minuten';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes Minuten';
  }

  @override
  String personalPatternInfo(String interval) {
    return 'Persönliches Muster: $interval Intervall (zur Referenz)';
  }

  @override
  String get longPressForDetails => 'Lang drücken für Details';

  @override
  String get todaysSummary => 'Heutiger Überblick';

  @override
  String get future => 'Zukunft';

  @override
  String get previousDate => 'Vorheriges Datum';

  @override
  String get nextDate => 'Nächstes Datum';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get checkStandardFeedingInterval =>
      'Standard-Fütterungsintervall prüfen';

  @override
  String get registerBabyFirst => 'Bitte registrieren Sie Ihr Baby';

  @override
  String get registerBabyToRecordMoments =>
      'Um die kostbaren Momente Ihres Babys festzuhalten,\nregistrieren Sie bitte zuerst die Baby-Informationen.';

  @override
  String get addBabyFromHome => 'Baby vom Startbildschirm hinzufügen';

  @override
  String get timesUnit => 'Mal';

  @override
  String get itemsUnit => 'Artikel';

  @override
  String get timesPerDay => 'Mal/Tag';

  @override
  String get activityDistributionByCategory =>
      'Aktivitätsverteilung nach Kategorie';

  @override
  String itemsCount(int count) {
    return '$count Artikel';
  }

  @override
  String get totalCount => 'Gesamtanzahl';

  @override
  String timesCount(int count) {
    return '$count Mal';
  }

  @override
  String get noDetailedData => 'Keine detaillierten Daten';

  @override
  String get averageFeedingTime => 'Durchschnittliche Fütterungszeit';

  @override
  String get averageSleepTime => 'Durchschnittliche Schlafzeit';

  @override
  String get dailyAverageTotalSleepTime =>
      'Tägliche durchschnittliche Gesamtschlafzeit';

  @override
  String get dailyAverageSleepCount =>
      'Tägliche durchschnittliche Schlafanzahl';

  @override
  String get dailyAverageChangeCount =>
      'Tägliche durchschnittliche Wechselanzahl';

  @override
  String get sharingParentingStories => 'Austausch von Elterngeschichten';

  @override
  String get myActivity => 'Meine Aktivität';

  @override
  String get categories => 'Kategorien';

  @override
  String get menu => 'Menü';

  @override
  String get seeMore => 'Mehr sehen';

  @override
  String get midnight => 'Mitternacht';

  @override
  String get morning => 'Morgens';

  @override
  String get noon => 'Mittag';

  @override
  String get afternoon => 'Nachmittags';

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
}
