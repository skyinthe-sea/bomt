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
    return 'Geburtstag: $year/$month/$day';
  }

  @override
  String age(int days) {
    return 'Alter: $days days';
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
  String get genderOptional => 'Geschlecht (Optional)';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get loginFailed => 'Anmelden failed';

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
  String get loginWithKakao => 'Anmelden with Kakao';

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
  String get home => 'Startseite';

  @override
  String get timeline => 'Zeitachse';

  @override
  String get record => 'Aufzeichnen';

  @override
  String get statistics => 'Statistiken';

  @override
  String get community => 'Gemeinschaft';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get timelineUpdateMessage => 'Timeline feature will be updated soon';

  @override
  String get recordUpdateMessage => 'Aufnehmen feature will be updated soon';

  @override
  String get statisticsUpdateMessage =>
      'Statistiken feature will be updated soon';

  @override
  String get communityUpdateMessage => 'Community feature will be updated soon';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get growthInfo => 'Wachstumsinfo';

  @override
  String get lastFeeding => 'Letzte Fütterung';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Füttern';

  @override
  String get totalFeeding => 'Total Fütterung';

  @override
  String get sleep => 'Schlaf';

  @override
  String get totalSleepTime => 'Total Schlaf Zeit';

  @override
  String get cardSettings => 'Card Einstellungen';

  @override
  String get cardSettingsGuide => 'Card Einstellungen Guide';

  @override
  String get cardSettingsDescription =>
      '• Toggle switches to show/hide cards • Drag to change card order • Changes are previewed in real-time';

  @override
  String get cardVisible => 'Visible';

  @override
  String get cardHidden => 'Hidden';

  @override
  String get save => 'Speichern';

  @override
  String get cardSettingsSaved => 'Card settings saved';

  @override
  String get cardSettingsError => 'Fehler occurred while saving settings';

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
  String get milkPumping => 'Milch abpumpen';

  @override
  String get temperature => 'Temperatur';

  @override
  String get growth => 'Wachstum';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Fütterungsmenge';

  @override
  String get feedingRecordAdded => 'Fütterung record added successfully';

  @override
  String get feedingRecordFailed => 'Failed to add feeding record';

  @override
  String get feedingRecordsLoadFailed => 'Failed to load feeding records';

  @override
  String get quickFeeding => 'Quick Fütterung';

  @override
  String get feedingTime => 'Fütterung Zeit';

  @override
  String get feedingType => 'Feeding Type';

  @override
  String get breastfeeding => 'Breastfeeding';

  @override
  String get bottleFeeding => 'Bottle Fütterung';

  @override
  String get mixedFeeding => 'Mixed Fütterung';

  @override
  String sleepCount(Object count) {
    return '$count times';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get sleepStarted => 'Schlaf started';

  @override
  String get sleepEnded => 'Schlaf ended';

  @override
  String get sleepInProgress => 'Schläft';

  @override
  String get sleepRecordFailed => 'Failed to process sleep record';

  @override
  String get sleepRecordsLoadFailed => 'Failed to load sleep records';

  @override
  String get sleepTime => 'Schlaf Zeit';

  @override
  String get wakeUpTime => 'Wake Up Zeit';

  @override
  String get sleepDurationLabel => 'Schlaf Dauer';

  @override
  String get napTime => 'Nap Zeit';

  @override
  String get nightSleep => 'Night Schlaf';

  @override
  String diaperCount(Object count) {
    return '$count times';
  }

  @override
  String get diaperChanged => 'Windel changed';

  @override
  String get diaperRecordAdded => 'Windel change record added successfully';

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
  String get diaperType => 'Windel Typ';

  @override
  String get diaperChangeTime => 'Change Zeit';

  @override
  String get weight => 'Gewicht';

  @override
  String get height => 'Größe';

  @override
  String get growthRecord => 'Wachstum Aufnehmen';

  @override
  String get growthRecordAdded => 'Wachstum record added';

  @override
  String get growthRecordFailed => 'Failed to save growth record';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => 'Measurement Typ';

  @override
  String get measurementValue => 'Value';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get temperatureRange => 'Temperatur must be between 30.0°C and 45.0°C';

  @override
  String get weightRange => 'Gewicht must be between 0.1kg and 50kg';

  @override
  String get heightRange => 'Größe must be between 1cm and 200cm';

  @override
  String get enterValidNumber => 'Bitte gültige Zahl eingeben';

  @override
  String get recordGrowthInfo => 'Aufnehmen Wachstum Information';

  @override
  String currentMeasurement(Object type) {
    return 'Enter current $type';
  }

  @override
  String get measurementSituation =>
      'Aufnehmen measurement situation or special notes (optional)';

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
      'Enter content... Feel free to share your story.';

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
      'Erstellen a nickname to use in the community. It will be displayed to other users.';

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
  String get addImages => 'Hinzufügen Images';

  @override
  String imageSelectFailed(Object error) {
    return 'Bild selection failed: $error';
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
  String get userNotFound => 'Benutzer information not found';

  @override
  String get statisticsTitle => 'Statistiken';

  @override
  String get noStatisticsData => 'Nein Statistiken Data';

  @override
  String statisticsDescription(Object period) {
    return 'Nein activities recorded during $period. Starten recording your baby\'s activities!';
  }

  @override
  String get recordActivity => 'Aufnehmen Activity';

  @override
  String get viewOtherPeriod => 'Ansicht Other Period';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get statisticsTips => 'To view statistics?';

  @override
  String get statisticsTip1 =>
      'Aufnehmen activities like feeding, sleep, diaper changes';

  @override
  String get statisticsTip2 =>
      'At least one day of data is required for statistics';

  @override
  String get statisticsTip3 => 'You can record easily from the home screen';

  @override
  String get saveAsImage => 'Speichern as Bild';

  @override
  String get saveAsImageDescription => 'Speichern statistics as image';

  @override
  String get shareAsText => 'Teilen as Text';

  @override
  String get shareAsTextDescription => 'Teilen statistics summary as text';

  @override
  String get statisticsEmptyState => 'Nein statistics data';

  @override
  String get retryButton => 'Try Again';

  @override
  String get detailsButton => 'Details';

  @override
  String get goHomeButton => 'Go Startseite';

  @override
  String get applyButton => 'Anwenden';

  @override
  String get lastWeek => 'Letzte Week';

  @override
  String get lastMonth => 'Letzte Month';

  @override
  String get last3Months => 'Letzte 3 Months';

  @override
  String get allTime => 'All Zeit';

  @override
  String get viewOtherPeriodTitle => 'Ansicht Other Period';

  @override
  String get familyInvitation => 'Familieneinladung';

  @override
  String get invitationDescription =>
      'Manage baby records together with your family using invitation codes';

  @override
  String get createInvitation => 'Erstellen Invitation';

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
  String get shareInvitation => 'Teilen Invitation';

  @override
  String get shareImmediately => 'Teilen Now';

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
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get warning => 'Warnung';

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
  String get saveFailed => 'Speichern failed';

  @override
  String get loadFailed => 'Load failed';

  @override
  String updateFailed(String error) {
    return 'Aktualisieren failed: $error';
  }

  @override
  String deleteFailed(String error) {
    return 'Löschen failed: $error';
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
  String get solidFoodType => 'Essen Typ';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => 'Solid food record added';

  @override
  String get milkPumpingAmount => 'Pumping Menge';

  @override
  String get milkPumpingTime => 'Pumping Zeit';

  @override
  String get milkPumpingAdded => 'Milk pumping record added';

  @override
  String get temperatureReading => 'Temperatur Reading';

  @override
  String get temperatureNormal => 'Normal';

  @override
  String get temperatureHigh => 'Hoch';

  @override
  String get temperatureLow => 'Niedrig';

  @override
  String get profilePhoto => 'Profile Foto';

  @override
  String get profilePhotoUpdate => 'Aktualisieren Profile Foto';

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
      'Kamera not available on iOS simulator. Please try from gallery.';

  @override
  String get cameraAccessError =>
      'Kamera access error occurred. Please try from gallery.';

  @override
  String get addImage => 'Hinzufügen Bild';

  @override
  String get removeImage => 'Entfernen Bild';

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
    return 'Weiter feeding in about ${hours}h ${minutes}m';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return 'Weiter feeding in about $minutes minutes';
  }

  @override
  String get feedingTimeNow => 'It\'s feeding time now 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'Fütterung time soon ($minutes minutes)';
  }

  @override
  String get feedingTimeOverdue => 'Fütterung time overdue';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return 'Fütterung alarm in ${hours}h ${minutes}m';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return 'Fütterung alarm in $minutes minutes';
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
  String get hoursUnit => 'Stunden';

  @override
  String get minutesUnit => 'minutes';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get firstRecord => 'Erste Aufnehmen';

  @override
  String get noChange => 'Nein Change';

  @override
  String get inProgress => 'In Progress';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get startBabyRecording =>
      'Registrieren your baby and start tracking growth';

  @override
  String get registerBabyNow => 'Registrieren Baby';

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
    return 'Über $count times';
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
  String get noActivitiesInTimeframe => 'Nein activities during this time';

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
  String get qualityGood => 'Gut';

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
  String get breastMilk => 'Breast Milk';

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
  String get diaperChange => 'Windelwechsel';

  @override
  String get oralMedication => 'Orale Medikation';

  @override
  String get topical => 'Topical';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperaturmessung';

  @override
  String get fever => 'Fieber';

  @override
  String get lowFever => 'Leichtes Fieber';

  @override
  String get hypothermia => 'Unterkühlung';

  @override
  String get normal => 'Normal';

  @override
  String get quality => 'Qualität';

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
    return 'Nein activities were recorded during $period.';
  }

  @override
  String get recordBabyActivities => 'Aufnehmen your baby\'s activities!';

  @override
  String get howToViewStatistics => 'How to view statistics?';

  @override
  String get recordActivitiesLikeFeedingSleep =>
      'Aufnehmen activities like feeding, sleep, diaper changes, etc.';

  @override
  String get atLeastOneDayDataRequired =>
      'At least one day of data is required to display statistics.';

  @override
  String get canRecordEasilyFromHome =>
      'You can easily record activities from the home screen.';

  @override
  String get updating => 'Updating...';

  @override
  String get lastUpdated => 'Letzte updated:';

  @override
  String get periodSelection => 'Zeitraumauswahl:';

  @override
  String get daily => 'Daily';

  @override
  String get startDate => 'Starten Datum';

  @override
  String get endDate => 'Ende Datum';

  @override
  String get apply => 'Anwenden';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get detailedStatistics => 'Detaillierte Statistiken';

  @override
  String get chartAnalysis => 'Diagramm Analysis';

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
  String get goToHome => 'Go to Startseite';

  @override
  String get troubleshootingMethods => 'Troubleshooting Methods';

  @override
  String get shareStatistics => 'Teilen Statistiken';

  @override
  String get communitySubtitle => 'Sharing Parenting Stories Together';

  @override
  String get search => 'Suchen';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String get searchFeatureComingSoon => 'Suchen feature coming soon';

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
  String get categorySleepIssues => 'Schlaf Issues';

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
  String commentsCount(int count) {
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
  String get inviteCodeGeneratedStatus => 'Invitation code generated!';

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
  String get inviteCodeExpired =>
      'The invitation code has expired. Please create a new one.';

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
  String get noRecentFeeding => 'Nein recent feeding records';

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
  String get temperatureRecorded => 'Temperatur aufgezeichnet';

  @override
  String recordFailed(String error) {
    return 'Aufzeichnung fehlgeschlagen';
  }

  @override
  String get temperatureSettingsSaved => 'Temperature settings saved';

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
  String get bottle => 'Bottle';

  @override
  String get good => 'Gut';

  @override
  String get average => 'Durchschnitt';

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
  String get drops => 'Drops';

  @override
  String get teaspoon => 'Teelöffel';

  @override
  String get tablespoon => 'Esslöffel';

  @override
  String get sleepQuality => 'Sleep Quality';

  @override
  String get pumpingTime => 'Abpumpen';

  @override
  String get solidFoodTime => 'Feste Nahrung';

  @override
  String get totalFeedingAmount => 'Gesamtstillmenge';

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
  String get minutes => 'Min';

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
  String get detailInformation => 'Detaillierte Informationen';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recordAgain => 'Aufnehmen Again';

  @override
  String get share => 'Teilen';

  @override
  String get deleteRecord => 'Löschen Aufnehmen';

  @override
  String get deleteRecordConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get recordDeleted => 'Aufnehmen deleted';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get editRecord => 'Bearbeiten Aufnehmen';

  @override
  String get dateTime => 'Datum & Zeit';

  @override
  String get date => 'Datum';

  @override
  String get time => 'Zeit';

  @override
  String get amount => 'Menge';

  @override
  String get duration => 'Dauer';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'Seite';

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
  String get saveChanges => 'Speichern Changes';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get smartInsights => 'Intelligente Einblicke';

  @override
  String get analyzingPatterns => 'Muster analysieren...';

  @override
  String insightsFound(int count) {
    return '$count Einblicke gefunden';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'Vertrauen';

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
    return '${hours}h ${minutes}min';
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
  String get customSettings => 'Custom Einstellungen';

  @override
  String get selectDateRange => 'Select Datum Range';

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
  String get feedingTimeNotificationBody => 'Baby might be hungry now.';

  @override
  String get feedingAlarmChannelName => 'Fütterung Reminders';

  @override
  String get feedingAlarmChannelDescription =>
      'Fütterung time reminder notifications';

  @override
  String get averageFeedingDuration => 'Durchschnittliche Stillzeit';

  @override
  String get averageSleepDuration => 'Durchschnittliche Schlafdauer';

  @override
  String get dailyTotalSleepDuration => 'Daily total sleep duration';

  @override
  String get dailyAverageDiaperChangeCount =>
      'Tägliche durchschnittliche Windelwechsel';

  @override
  String get dailyAverageMedicationCount =>
      'Tägliche durchschnittliche Medikamentenanzahl';

  @override
  String get medicationTypesUsed => 'Verwendete Medikamentenarten';

  @override
  String get totalPumpedAmount => 'Gesamtmenge abgepumpt';

  @override
  String get averagePumpedAmount => 'Durchschnittlich abgepumpte Menge';

  @override
  String get countTab => 'Count';

  @override
  String get amountTimeTab => 'Amount/Time';

  @override
  String get durationTab => 'Dauer';

  @override
  String get chartDataLoading => 'Loading chart data...';

  @override
  String get chartDataNotAvailable => 'Diagramm data not available.';

  @override
  String get averageLabel => 'Durchschnitt: ';

  @override
  String get dailyFeedingCountTitle => 'Daily feeding count';

  @override
  String get weekdaysSundayToSaturday => 'SunMonTueWedThuFriSat';

  @override
  String dayFormat(int day) {
    return '$day';
  }

  @override
  String get dailyFeedingCount => 'Tägliche Stillanzahl';

  @override
  String get dailyFeedingAmount => 'Daily feeding amount';

  @override
  String get dailyFeedingDuration => 'Daily feeding duration';

  @override
  String get dailySleepCount => 'Tägliche Schlafanzahl';

  @override
  String get dailySleepDuration => 'Daily sleep duration';

  @override
  String get dailyDiaperChangeCount => 'Tägliche Windelwechsel';

  @override
  String get dailyMedicationCount => 'Tägliche Medikamentenanzahl';

  @override
  String get dailyMilkPumpingCount => 'Tägliche Abpumpanzahl';

  @override
  String get dailyMilkPumpingAmount => 'Daily pumping amount';

  @override
  String get dailySolidFoodCount => 'Tägliche Beikostanzahl';

  @override
  String get dailyAverageSolidFoodCount =>
      'Tägliche durchschnittliche Beikostanzahl';

  @override
  String get triedFoodTypes => 'Arten der probierten Nahrung';

  @override
  String babyTemperatureRecord(String name) {
    return '${name}s Temperaturprotokoll';
  }

  @override
  String get adjustWithSlider => 'Mit Schieberegler anpassen';

  @override
  String get measurementMethod => 'Messmethode';

  @override
  String get normalRange => 'Normalbereich';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Normalbereich ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Temperaturprotokoll speichern';

  @override
  String get enterTemperature => 'Bitte Temperatur eingeben';

  @override
  String get temperatureRangeValidation =>
      'Temperatur muss zwischen 34,0°C ~ 42,0°C liegen';

  @override
  String get recordSymptomsHint =>
      'Bitte Symptome oder besondere Hinweise aufzeichnen';

  @override
  String get oralMethod => 'Oral';

  @override
  String get analMethod => 'Anal';

  @override
  String recentDaysTrend(int days) {
    return 'Trend der letzten $days Tage';
  }

  @override
  String get days3 => '3 Tage';

  @override
  String get days7 => '7 Tage';

  @override
  String get weeks2 => '2 Wochen';

  @override
  String get month1 => '1 Monat';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Keine Temperaturaufzeichnungen im gewählten Zeitraum';

  @override
  String get temperatureChangeTrend => 'Temperaturveränderungstrend';

  @override
  String get averageTemperature => 'Durchschnittstemperatur';

  @override
  String get highestTemperature => 'Höchsttemperatur';

  @override
  String get lowestTemperature => 'Niedrigsttemperatur';

  @override
  String get noteAvailableTapToView =>
      '📝 Notiz verfügbar (tippen zum Anzeigen)';

  @override
  String get temperatureRisingTrend =>
      'Die Temperatur zeigt einen steigenden Trend';

  @override
  String get temperatureFallingTrend =>
      'Die Temperatur zeigt einen fallenden Trend';

  @override
  String get temperatureStableTrend => 'Die Temperatur ist stabil';

  @override
  String get trendAnalysis => 'Trendanalyse';

  @override
  String totalMeasurements(int count) {
    return 'Insgesamt $count Messungen';
  }

  @override
  String get temperatureRecordMemo => 'Temperaturprotokoll Notiz';

  @override
  String babyGrowthChart(String name) {
    return '${name}s Wachstumsdiagramm';
  }

  @override
  String get noGrowthRecords => 'Keine Wachstumsaufzeichnungen';

  @override
  String get enterWeightAndHeightFromHome =>
      'Bitte geben Sie Gewicht und Größe über den Startbildschirm ein';

  @override
  String get all => 'Alle';

  @override
  String get growthInsights => 'Wachstumseinblicke';

  @override
  String get growthRate => 'Wachstumsrate';

  @override
  String get monthlyAverageGrowth => 'Monatliches Durchschnittswachstum';

  @override
  String get dataInsufficient => 'Daten unzureichend';

  @override
  String get twoOrMoreRequired => '2 oder mehr erforderlich';

  @override
  String recentDaysBasis(int days) {
    return 'Basierend auf den letzten $days Tagen';
  }

  @override
  String get entireBasis => 'Basierend auf gesamten Zeitraum';

  @override
  String get oneMonthPrediction => '1-Monats-Vorhersage';

  @override
  String get currentTrendBasis => 'Basierend auf aktuellem Trend';

  @override
  String get predictionNotPossible => 'Vorhersage nicht möglich';

  @override
  String get trendInsufficient => 'Trend unzureichend';

  @override
  String get recordFrequency => 'Aufzeichnungshäufigkeit';

  @override
  String get veryConsistent => 'Sehr konstant';

  @override
  String get consistent => 'Konstant';

  @override
  String get irregular => 'Unregelmäßig';

  @override
  String averageDaysInterval(String days) {
    return 'Durchschnittlich $days Tage Intervall';
  }

  @override
  String get nextRecord => 'Nächste Aufzeichnung';

  @override
  String get now => 'Jetzt';

  @override
  String get soon => 'Bald';

  @override
  String daysLater(int days) {
    return '$days Tage später';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Vor $days Tagen aufgezeichnet';
  }

  @override
  String get weeklyRecordRecommended => 'Wöchentliche Aufzeichnung empfohlen';

  @override
  String get nextMilestone => 'Nächster Meilenstein';

  @override
  String targetValue(String value, String unit) {
    return '$value$unit Ziel';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit verbleibend ($progress% erreicht)';
  }

  @override
  String get calculationNotPossible => 'Berechnung nicht möglich';

  @override
  String get periodInsufficient => 'Zeitraum unzureichend';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get weightRecordRequired => 'Gewichtsaufzeichnung erforderlich';

  @override
  String get heightRecordRequired => 'Größenaufzeichnung erforderlich';

  @override
  String get currentRecordMissing => 'Aktuelle Aufzeichnung fehlt';

  @override
  String get noRecord => 'Keine Aufzeichnung';

  @override
  String get firstRecordStart => 'Erste Aufzeichnung starten';

  @override
  String get oneRecord => '1 Aufzeichnung';

  @override
  String get moreRecordsNeeded => 'Weitere Aufzeichnungen erforderlich';

  @override
  String get sameDayRecord => 'Aufzeichnung am selben Tag';

  @override
  String recordedTimes(int count) {
    return '$count mal aufgezeichnet';
  }

  @override
  String get storageMethod => 'Aufbewahrungsmethode';

  @override
  String get pumpingType => 'Pump-Art';

  @override
  String get foodName => 'Food Name';

  @override
  String get mealType => 'Mahlzeittyp';

  @override
  String get texture => 'Textur';

  @override
  String get reaction => 'Reaktion';

  @override
  String get measurementLocation => 'Messort';

  @override
  String get feverReducerGiven => 'Fiebermittel gegeben';

  @override
  String get given => 'Gegeben';

  @override
  String get hours => 'Stunden';

  @override
  String get refrigerator => 'Refrigerator';

  @override
  String get freezer => 'Freezer';

  @override
  String get roomTemperature => 'Room Temperature';

  @override
  String get fedImmediately => 'Sofort gefüttert';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get snack => 'Snack';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get on => 'Ein';

  @override
  String get off => 'Aus';

  @override
  String get weightChange => 'Gewichtsveränderung';

  @override
  String get heightChange => 'Größenveränderung';

  @override
  String get totalRecords => 'Gesamtaufzeichnungen';

  @override
  String get totalChange => 'Gesamtveränderung';

  @override
  String get start => 'Start';

  @override
  String get memo => 'Notiz';

  @override
  String get weightDataEmpty => 'Keine Gewichtsdaten verfügbar';

  @override
  String get heightDataEmpty => 'Keine Größendaten verfügbar';

  @override
  String get undoAction => 'Rückgängig machen';

  @override
  String get feedingRecordDeleted => 'Fütterungsaufzeichnung gelöscht';

  @override
  String get sleepRecordDeleted => 'Schlafaufzeichnung gelöscht';

  @override
  String get diaperRecordDeleted => 'Windelaufzeichnung gelöscht';

  @override
  String get healthRecordDeleted => 'Gesundheitsaufzeichnung gelöscht';

  @override
  String get deletionError => 'Fehler beim Löschen aufgetreten';

  @override
  String get duplicateInputDetected => 'Doppelte Eingabe erkannt';

  @override
  String get solidFoodDuplicateConfirm =>
      'Sie haben gerade Beikost aufgezeichnet.\\nMöchten Sie wirklich erneut aufzeichnen?';

  @override
  String get cannotOpenSettings =>
      'Einstellungsbildschirm kann nicht geöffnet werden';

  @override
  String get sleepQualityGood => 'Good';

  @override
  String get sleepQualityFair => 'Fair';

  @override
  String get sleepQualityPoor => 'Poor';

  @override
  String sleepInProgressDuration(Object minutes) {
    return 'Schläft - ${minutes}min vergangen';
  }

  @override
  String get wetOnly => 'Nur nass';

  @override
  String get dirtyOnly => 'Nur verschmutzt';

  @override
  String get wetAndDirty => 'Nass + verschmutzt';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get consistencyLabel => 'Konsistenz';

  @override
  String get topicalMedication => 'Äußerlich';

  @override
  String get inhaledMedication => 'Inhaliert';

  @override
  String get milkPumpingInProgress => 'Pumpt ab';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return 'Pumpt ab - ${minutes}min vergangen';
  }

  @override
  String get lowGradeFever => 'Leichtes Fieber';

  @override
  String get normalTemperature => 'Temperature is normal';

  @override
  String get allActivities => 'Alle';

  @override
  String get temperatureFilter => 'Temperatur';

  @override
  String get deleteRecordTitle => 'Eintrag löschen';

  @override
  String get deleteRecordMessage =>
      'Sind Sie sicher, dass Sie diesen Eintrag löschen möchten?\nGelöschte Einträge können nicht wiederhergestellt werden.';

  @override
  String get recordDeletedSuccess => 'Eintrag wurde gelöscht';

  @override
  String get recordDeleteFailed => 'Löschen des Eintrags fehlgeschlagen';

  @override
  String get recordDeleteError => 'Fehler beim Löschen des Eintrags';

  @override
  String get recordUpdatedSuccess => 'Eintrag wurde aktualisiert';

  @override
  String get recordUpdateFailed => 'Aktualisierung des Eintrags fehlgeschlagen';

  @override
  String get recordUpdateError => 'Fehler beim Aktualisieren des Eintrags';

  @override
  String noRecordsToday(Object recordType) {
    return 'Heute keine $recordType-Einträge';
  }

  @override
  String get healthRecordRestored =>
      'Gesundheitsdaten wurden wiederhergestellt';

  @override
  String get deleteTemperatureConfirm =>
      'Möchten Sie den letzten Temperaturwert löschen?';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get duplicateEntryDetected => 'Doppelte Eingabe erkannt';

  @override
  String get feedingDuplicateConfirm =>
      'Sie haben gerade einen Fütterungseintrag hinzugefügt.\\nMöchten Sie wirklich noch einmal aufzeichnen?';

  @override
  String get milkPumpingDuplicateConfirm =>
      'Sie haben gerade einen Milchpump-Eintrag hinzugefügt.\\nMöchten Sie wirklich noch einmal aufzeichnen?';

  @override
  String get medicationDuplicateConfirm =>
      'Sie haben gerade eine Medikation aufgezeichnet.\\nMöchten Sie wirklich noch einmal aufzeichnen?';

  @override
  String get diaperDuplicateConfirm =>
      'Sie haben gerade einen Windelwechsel aufgezeichnet.\\nMöchten Sie wirklich noch einmal aufzeichnen?';

  @override
  String get sleepStartDuplicateConfirm =>
      'Sie haben gerade den Schlaf manipuliert.\\nMöchten Sie wirklich mit dem Schlafen beginnen?';

  @override
  String get sleepEndDuplicateConfirm =>
      'Sie haben gerade den Schlaf manipuliert.\\nMöchten Sie wirklich das Schlafen beenden?';

  @override
  String get recordAction => 'Aufzeichnen';

  @override
  String get end => 'Ende';

  @override
  String get whatTypeChanged => 'Welchen Typ haben Sie gewechselt?';

  @override
  String get poop => 'Stuhl';

  @override
  String get urinePoop => 'Urin+Stuhl';

  @override
  String get changeType => 'Wechseltyp';

  @override
  String get colorWhenPoop => 'Farbe (Bei Stuhlgang)';

  @override
  String get minutesShort => 'm';

  @override
  String get totalFeedingDuration => 'Gesamtstillzeit';

  @override
  String get maximumFeedingAmount => 'Maximale Stillmenge';

  @override
  String get minimumFeedingAmount => 'Minimale Stillmenge';

  @override
  String get totalSleepDuration => 'Gesamtschlafdauer';

  @override
  String get dailyTotalMilkPumpingAmount => 'Tägliche Gesamtabpumpmenge';

  @override
  String get maximumSleepDuration => 'Maximale Schlafdauer';

  @override
  String get minimumSleepDuration => 'Minimale Schlafdauer';

  @override
  String get allergicReactionCount => 'Anzahl allergischer Reaktionen';

  @override
  String get dailyAverageMilkPumpingCount =>
      'Tägliche durchschnittliche Abpumpanzahl';

  @override
  String get growthInfoRecord => 'Wachstumsinformationen aufzeichnen';

  @override
  String get recordBabyCurrentWeight =>
      'Bitte das aktuelle Gewicht des Babys aufzeichnen';

  @override
  String get recordBabyCurrentHeight =>
      'Bitte die aktuelle Körpergröße des Babys aufzeichnen';

  @override
  String get measurementItems => 'Messelemente';

  @override
  String get memoOptional => 'Notiz (optional)';

  @override
  String get enterWeight => 'Gewicht eingeben';

  @override
  String get enterHeight => 'Körpergröße eingeben';

  @override
  String get recordSpecialNotesWeight =>
      'Besonderheiten bei der Gewichtsmessung aufzeichnen (optional)';

  @override
  String get recordSpecialNotesHeight =>
      'Besonderheiten bei der Körpergrößenmessung aufzeichnen (optional)';

  @override
  String get weightInvalidNumber =>
      'Bitte eine gültige Zahl für das Gewicht eingeben';

  @override
  String get weightRangeError => 'Gewicht sollte zwischen 0,1-50kg liegen';

  @override
  String get heightInvalidNumber =>
      'Bitte eine gültige Zahl für die Körpergröße eingeben';

  @override
  String get heightRangeError => 'Körpergröße sollte zwischen 1-200cm liegen';

  @override
  String get enterWeightOrHeight => 'Bitte Gewicht oder Körpergröße eingeben';

  @override
  String get saveError => 'Fehler beim Speichern aufgetreten';

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
  String get shareFeatureInDevelopment => 'Teilen feature is under development';

  @override
  String get sortByRecent => 'Sortieren by Recent';

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
    return 'Ansicht $count more replies';
  }

  @override
  String get copy => 'Copy';

  @override
  String get report => 'Bericht';

  @override
  String get commentCopied => 'Comment has been copied';

  @override
  String get reportComment => 'Bericht Comment';

  @override
  String get confirmReportComment =>
      'Do you want to report this comment? It will be reported as inappropriate content or spam.';

  @override
  String get reportSubmitted => 'Bericht has been submitted.';

  @override
  String get serviceInPreparation => '💝 Service in Preparation';

  @override
  String get upcomingServiceDescription =>
      'We will soon introduce useful parenting information and products';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get userID => 'Benutzer ID';

  @override
  String get email => 'E-Mail';

  @override
  String get loginMethod => 'Anmelden Method';

  @override
  String get noEmail => 'Nein email';

  @override
  String get accountDeletion => 'Account Deletion';

  @override
  String get allDataWillBePermanentlyDeleted =>
      'All data will be permanently deleted';

  @override
  String get accountDeletionWarning =>
      '⚠️ The following data will be permanently deleted when you delete your account:';

  @override
  String get userAccountInfo => '• Benutzer account information';

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
  String get accountDeletionCompleteTitle => 'Account Deletion Vollständig';

  @override
  String get resetBaby => 'Zurücksetzen';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get birthDateLabel => 'Birth Datum:';

  @override
  String get genderColon => 'Geschlecht:';

  @override
  String babyInfoResetQuestion(Object babyName) {
    return 'Do you want to reset $babyName information from the beginning?';
  }

  @override
  String get recordsWillBeReset => 'The following records will be reset';

  @override
  String get feedingSleepDiaperRecords => 'Fütterung, sleep, diaper records';

  @override
  String get growthInfoAndPhotos => 'Wachstum information and photos';

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
  String get emailProvider => 'E-Mail';

  @override
  String get unknownProvider => 'Unknown';

  @override
  String get accountDeletionPartialErrorMessage =>
      'Some processing encountered issues but logout is completed. Redirecting to login screen.';
}
