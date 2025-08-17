// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get user => 'Utilisateur';

  @override
  String userInfoLoadFailed(String error) {
    return 'Échec du chargement des informations utilisateur : $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Erreur lors du chargement de la liste des bébés : $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Bonjour, $userName !';
  }

  @override
  String get registerBaby => 'Enregistrer bébé';

  @override
  String get noBabiesRegistered => 'Aucun bébé enregistré';

  @override
  String get registerFirstBaby => 'Enregistrez votre premier bébé !';

  @override
  String get registerBabyButton => 'Enregistrer le bébé';

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
    return 'Sexe';
  }

  @override
  String get male => 'Garçon';

  @override
  String get female => 'Fille';

  @override
  String get other => 'Autre';

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
  String get enterBabyInfo => 'Veuillez saisir les informations du bébé';

  @override
  String get babyName => 'Nom du bébé';

  @override
  String get babyNameHint => 'ex : Emma';

  @override
  String get babyNameRequired => 'Veuillez saisir le nom du bébé';

  @override
  String get babyNameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get selectBirthdateButton => 'Sélectionner la date de naissance';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Annuler';

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
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Veuillez saisir le nom du bébé';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get appearance => 'Apparence';

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
  String get comingSoon => 'Bientôt disponible';

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
  String get diaper => 'Couche';

  @override
  String get solidFood => 'Solid Food';

  @override
  String get medication => 'Médicament';

  @override
  String get milkPumping => 'Milk Pumping';

  @override
  String get temperature => 'Température';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Quantité d\'alimentation';

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
  String get writePost => 'Écrire un post';

  @override
  String get post => 'Publier';

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
  String get selectCategory => 'Sélectionner une catégorie';

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
    return 'Contenu : $count/10000';
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
  String get refresh => 'Actualiser';

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
  String get familyInvitation => 'Invitation familiale';

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
  String get delete => 'Supprimer';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirmer';

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
    return 'il y a $minutes minutes';
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
  String get medicationTime => 'Médicament';

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
  String get camera => 'Appareil photo';

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
    return '$months months $days days';
  }

  @override
  String get lastFeedingTime => 'Dernière heure d\'alimentation';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return 'il y a $hours heures $minutes minutes';
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
  String get joinWithInviteCode => 'Rejoindre avec un code d\'invitation';

  @override
  String get loadingBabyInfo => 'Chargement des informations du bébé...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Aller aux paramètres';

  @override
  String get profilePhotoUpdated => 'La photo de profil a été mise à jour.';

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
  String get formula => 'Lait artificiel';

  @override
  String get breastMilk => 'Lait maternel';

  @override
  String get babyFood => 'Nourriture pour bébé';

  @override
  String get left => 'Gauche';

  @override
  String get right => 'Droite';

  @override
  String get both => 'Les deux';

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
  String get topical => 'Topique';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Fever';

  @override
  String get lowFever => 'Fièvre légère';

  @override
  String get hypothermia => 'Hypothermie';

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
  String get tryAgain => 'Réessayer';

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
      'Partagez vos expériences parentales et des informations précieuses avec d\'autres parents';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Tout';

  @override
  String get categoryPopular => 'Populaire';

  @override
  String get categoryClinical => 'Clinique';

  @override
  String get categoryInfoSharing => 'Partage d\'infos';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Alimentation bébé';

  @override
  String get categoryDevelopment => 'Développement';

  @override
  String get categoryVaccination => 'Vaccination';

  @override
  String get categoryPostpartum => 'Post-partum';

  @override
  String get sortByLikes => 'Trier par J\'aime';

  @override
  String get sortByLatest => 'Trier par plus récents';

  @override
  String get edited => '(modifié)';

  @override
  String commentsCount(Object count) {
    return '$count commentaires';
  }

  @override
  String get deletePost => 'Supprimer le post';

  @override
  String get deletePostConfirm =>
      'Êtes-vous sûr de vouloir supprimer ce post ?\\nLes posts supprimés ne peuvent pas être récupérés.';

  @override
  String get deletePostSuccess => 'Post supprimé.';

  @override
  String deletePostError(Object error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String get postNotFound => 'Post non trouvé';

  @override
  String get shareFeatureComingSoon => 'Fonction de partage bientôt disponible';

  @override
  String get loadingComments => 'Chargement des commentaires...';

  @override
  String get loadMoreComments => 'Charger plus de commentaires';

  @override
  String get editComment => 'Modifier le commentaire';

  @override
  String get editCommentHint => 'Modifiez votre commentaire...';

  @override
  String get editCommentSuccess => 'Commentaire mis à jour.';

  @override
  String editCommentError(Object error) {
    return 'Échec de la modification : $error';
  }

  @override
  String get deleteComment => 'Supprimer le commentaire';

  @override
  String get deleteCommentConfirm =>
      'Êtes-vous sûr de vouloir supprimer ce commentaire ?\\nLes commentaires supprimés ne peuvent pas être récupérés.';

  @override
  String get deleteCommentSuccess => 'Commentaire supprimé.';

  @override
  String get replySuccess => 'Réponse publiée.';

  @override
  String get commentSuccess => 'Commentaire publié.';

  @override
  String get commentError => 'Échec de la publication du commentaire.';

  @override
  String get titlePlaceholder => 'Saisir le titre';

  @override
  String get contentPlaceholder =>
      'Partagez vos pensées...\\n\\nÉcrivez librement sur vos expériences parentales.';

  @override
  String imageSelectionError(Object error) {
    return 'Échec de la sélection d\'image : $error';
  }

  @override
  String get userNotFoundError => 'Informations utilisateur non trouvées.';

  @override
  String get postCreateSuccess => 'Post créé avec succès !';

  @override
  String postCreateError(Object error) {
    return 'Échec de la création du post : $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Titre : $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Images : $count/5';
  }

  @override
  String get addImageTooltip => 'Ajouter une image';

  @override
  String get allPostsChecked => 'Tous les posts ont été vérifiés ! 👍';

  @override
  String get waitForNewPosts => 'Attendez de nouveaux posts';

  @override
  String get noPostsYet => 'Aucun post pour le moment';

  @override
  String get writeFirstPost => 'Écrivez le premier post !';

  @override
  String get loadingNewPosts => 'Chargement de nouveaux posts...';

  @override
  String get failedToLoadPosts => 'Échec du chargement des posts';

  @override
  String get checkNetworkAndRetry => 'Vérifiez votre connexion et réessayez';

  @override
  String get categoryDailyLife => 'Vie quotidienne';

  @override
  String get preparingTimeline => 'Préparation de la timeline...';

  @override
  String get noRecordedMoments => 'Aucun moment enregistré pour le moment';

  @override
  String get loadingTimeline => 'Chargement de la timeline...';

  @override
  String get noRecordsYet => 'Aucun enregistrement pour le moment';

  @override
  String noRecordsForDate(Object date) {
    return 'Aucun enregistrement pour $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Aucun enregistrement $filter pour $date';
  }

  @override
  String get cannotRecordFuture =>
      'Il n\'est pas encore possible d\'enregistrer des activités futures';

  @override
  String get addFirstRecord => 'Ajoutez votre premier enregistrement !';

  @override
  String get canAddPastRecord =>
      'Vous pouvez ajouter des enregistrements passés';

  @override
  String get addRecord => 'Ajouter un enregistrement';

  @override
  String get viewOtherDates => 'Voir d\'autres dates';

  @override
  String get goToToday => 'Aller à aujourd\'hui';

  @override
  String get quickRecordFromHome =>
      'Vous pouvez ajouter rapidement des enregistrements depuis l\'écran d\'accueil';

  @override
  String detailViewComingSoon(String title) {
    return 'Détails de $title (Bientôt disponible)';
  }

  @override
  String get familyInvitationDescription =>
      'Gérez les enregistrements de soins de bébé avec la famille via des codes d\'invitation';

  @override
  String get babyManagement => 'Gestion du bébé';

  @override
  String get addBaby => 'Ajouter un bébé';

  @override
  String get noBabiesMessage =>
      'Aucun bébé enregistré.\\nVeuillez ajouter un bébé.';

  @override
  String get switchToNextBaby => 'Passer au bébé suivant';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get registering => 'Enregistrement...';

  @override
  String get register => 'Enregistrer';

  @override
  String careTogetherWith(String name) {
    return 'Prendre soin du bébé avec $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Invitez la famille ou votre partenaire\\npour gérer ensemble les enregistrements de soins du bébé';

  @override
  String get generateInviteCode => 'Générer un code d\'invitation';

  @override
  String get generateInviteCodeDescription =>
      'Générez un nouveau code d\'invitation et copiez-le';

  @override
  String get generateInviteCodeButton => 'Générer un code d\'invitation';

  @override
  String get orText => 'Ou';

  @override
  String get enterInviteCodeDescription =>
      'Veuillez saisir le code d\'invitation reçu';

  @override
  String get inviteCodePlaceholder => 'Code d\'invitation (6 chiffres)';

  @override
  String get acceptInvite => 'Accepter l\'invitation';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name a été enregistré avec succès';
  }

  @override
  String get babyRegistrationFailed => 'Échec de l\'enregistrement du bébé';

  @override
  String babyRegistrationError(String error) {
    return 'Erreur survenue : $error';
  }

  @override
  String babySelected(String name) {
    return '$name a été sélectionné';
  }

  @override
  String get inviteCodeGenerated => 'Code d\'invitation généré !';

  @override
  String remainingTime(String time) {
    return 'Temps restant : $time';
  }

  @override
  String get validTime => 'Durée de validité : 5 minutes';

  @override
  String get generating => 'Génération...';

  @override
  String get joining => 'Connexion...';

  @override
  String get noBabyInfo => 'Aucune information de bébé';

  @override
  String get noBabyInfoDescription =>
      'Aucune information de bébé trouvée.\\nVoulez-vous créer un bébé de test ?';

  @override
  String get create => 'Créer';

  @override
  String get generateNewInviteCode => 'Générer un nouveau code d\'invitation';

  @override
  String get replaceExistingCode =>
      'Cela remplacera le code d\'invitation existant.\\nVoulez-vous continuer ?';

  @override
  String get acceptInvitation => 'Accepter l\'invitation';

  @override
  String get acceptInvitationDescription =>
      'Voulez-vous accepter l\'invitation et rejoindre la famille ?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Les enregistrements existants du bébé seront supprimés et remplacés par le bébé invité ($babyName).\\n\\nVoulez-vous continuer ?';
  }

  @override
  String get pleaseEnterInviteCode => 'Veuillez saisir le code d\'invitation';

  @override
  String get inviteCodeMustBe6Digits =>
      'Le code d\'invitation doit contenir 6 chiffres';

  @override
  String get pleaseLoginFirst =>
      'Informations de connexion non trouvées. Veuillez vous connecter d\'abord.';

  @override
  String get copiedToClipboard => 'Code d\'invitation copié !';

  @override
  String get joinedSuccessfully => 'Vous avez rejoint la famille avec succès !';

  @override
  String get inviteCodeExpired => 'Code d\'invitation expiré';

  @override
  String get invalidInviteCode => 'Code d\'invitation invalide';

  @override
  String get alreadyMember => 'Vous êtes déjà membre de cette famille';

  @override
  String get cannotInviteSelf => 'Vous ne pouvez pas vous inviter vous-même';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Guide de soins de $name';
  }

  @override
  String get babyGuide => 'Guide bébé';

  @override
  String get noAvailableGuides => 'Aucun guide disponible';

  @override
  String get current => 'Actuel';

  @override
  String get past => 'Passé';

  @override
  String get upcoming => 'À venir';

  @override
  String babysGuide(String name) {
    return 'de $name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Guide de la $weekText';
  }

  @override
  String get feedingGuide => '💡 Guide d\'alimentation';

  @override
  String get feedingFrequency => 'Fréquence d\'alimentation';

  @override
  String get singleFeedingAmount => 'Quantité par tétée';

  @override
  String get dailyTotal => 'Total quotidien';

  @override
  String get additionalTips => '📋 Conseils supplémentaires';

  @override
  String get understood => 'Compris !';

  @override
  String get newborn => 'Nouveau-né';

  @override
  String weekNumber(int number) {
    return 'Semaine $number';
  }

  @override
  String get newbornWeek0 => 'Nouveau-né (Semaine 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Quotidiennement $min - $max fois';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Quotidiennement $min+ fois';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Quotidiennement jusqu\'à $max fois';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml ou plus';
  }

  @override
  String amountMaxML(int max) {
    return 'Jusqu\'à ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Sélection de langue';

  @override
  String get selectLanguage => 'Sélectionnez une langue';

  @override
  String get currentLanguage => 'Langue actuelle';

  @override
  String get searchCommunityPosts =>
      'Rechercher des publications communautaires';

  @override
  String get temperatureRecord => 'Enregistrement de température';

  @override
  String get temperatureTrend => 'Tendance de température';

  @override
  String get profilePhotoSetup => 'Configuration de la photo de profil';

  @override
  String get howToSelectPhoto =>
      'Comment souhaitez-vous sélectionner une photo ?';

  @override
  String get send => 'Envoyer';

  @override
  String get emailVerificationRequired => 'Vérification de l\'email requise';

  @override
  String get passwordReset => 'Réinitialisation du mot de passe';

  @override
  String get enterEmailForReset =>
      'Entrez votre adresse email enregistrée.\nNous vous enverrons un lien de réinitialisation du mot de passe.';

  @override
  String get accountWithdrawalComplete => 'Suppression de compte terminée';

  @override
  String get genderLabel => 'Genre : ';

  @override
  String get birthdateLabel => 'Date de naissance : ';

  @override
  String get maleGender => 'Masculin';

  @override
  String get femaleGender => 'Féminin';

  @override
  String get joinWithInviteCodeButton => 'Rejoindre avec le code d\'invitation';

  @override
  String get temperatureRecorded => 'La température a été enregistrée';

  @override
  String recordFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'Les paramètres de température ont été sauvegardés';

  @override
  String get loadingUserInfo =>
      'Chargement des informations utilisateur. Veuillez réessayer dans un moment.';

  @override
  String get continueWithSeparateAccount => 'Continuer avec un compte séparé';

  @override
  String get linkWithExistingAccount => 'Lier avec un compte existant';

  @override
  String get linkAccount => 'Lier le compte';

  @override
  String get accountLinkingComplete => 'Liaison de compte terminée';

  @override
  String get deleteConfirmation => 'Confirmation de suppression';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get babyNameLabel => 'Nom du bébé';

  @override
  String get weightInput => 'Saisir le poids';

  @override
  String get heightInput => 'Saisir la taille';

  @override
  String get measurementNotes =>
      'Enregistrer les conditions de mesure ou des notes spéciales (optionnel)';

  @override
  String get urine => 'Urine';

  @override
  String get stool => 'Selle';

  @override
  String get yellow => 'Jaune';

  @override
  String get brown => 'Marron';

  @override
  String get green => 'Vert';

  @override
  String get bottle => 'Biberon';

  @override
  String get good => 'Bon';

  @override
  String get average => 'Moyen';

  @override
  String get poor => 'Mauvais';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get illness => 'Maladie';

  @override
  String get highFever => 'Fièvre élevée';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhalation';

  @override
  String get injection => 'Injection';

  @override
  String get tablet => 'Comprimé';

  @override
  String get drops => 'Gouttes';

  @override
  String get teaspoon => 'Cuillère à café';

  @override
  String get tablespoon => 'Cuillère à soupe';

  @override
  String get sleepQuality => 'Sommeil';

  @override
  String get pumpingTime => 'Tire-lait';

  @override
  String get solidFoodTime => 'Nourriture solide';

  @override
  String get totalFeedingAmount => 'Quantité totale d\'alimentation';

  @override
  String get averageFeedingAmount => 'Quantité moyenne d\'alimentation';

  @override
  String get dailyAverageFeedingCount =>
      'Nombre moyen quotidien d\'alimentations';

  @override
  String get clinical => 'Clinique';

  @override
  String get infoSharing => 'Partage d\'informations';

  @override
  String get sleepIssues => 'Problèmes de sommeil';

  @override
  String get babyFoodCategory => 'Nourriture pour bébé';

  @override
  String get developmentStage => 'Étape de développement';

  @override
  String get vaccinationCategory => 'Vaccination';

  @override
  String get postpartumRecovery => 'Récupération post-partum';

  @override
  String get dailyLife => 'Vie quotidienne';

  @override
  String get likes => 'J\'aime';

  @override
  String get comments => 'Commentaires';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get minutes => 'Minutes';

  @override
  String get armpit => 'Aisselle';

  @override
  String get forehead => 'Front';

  @override
  String get ear => 'Oreille';

  @override
  String get mouth => 'Bouche';

  @override
  String get rectal => 'Rectal';

  @override
  String get otherLocation => 'Autre';

  @override
  String get searchError => 'Erreur de recherche';

  @override
  String get question => 'Question';

  @override
  String get information => 'Information';

  @override
  String get relevance => 'Pertinence';

  @override
  String get searchSuggestions => 'Suggestions de recherche';

  @override
  String get noSearchResults => 'Aucun résultat de recherche';

  @override
  String get tryDifferentSearchTerm =>
      'Essayez un terme de recherche différent';

  @override
  String get likeFeatureComingSoon => 'Fonction j\'aime bientôt disponible';

  @override
  String get popularSearchTerms => 'Termes de recherche populaires';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get sortByComments => 'Trier par commentaires';

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
