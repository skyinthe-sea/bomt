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
  String get home => 'Accueil';

  @override
  String get timeline => 'Chronologie';

  @override
  String get record => 'Enregistrer';

  @override
  String get statistics => 'Statistiques';

  @override
  String get community => 'Communauté';

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
  String get growthInfo => 'Infos de croissance';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Allaitement';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Sommeil';

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
  String get diaper => 'Couche';

  @override
  String get solidFood => 'Alimentation Solide';

  @override
  String get medication => 'Médicament';

  @override
  String get milkPumping => 'Tire-lait';

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
  String get sleepInProgress => 'Endormi';

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
  String get weight => 'Poids';

  @override
  String get height => 'Taille';

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
  String get enterValidNumber => 'Veuillez saisir un nombre valide';

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
  String get today => 'Aujourd\'hui';

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
    return '$months mois $days jours';
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
  String get viewDetails => 'Voir les détails';

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
  String get hourActivityPattern => 'Modèle d\'Activité de 24 Heures';

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
  String get todaysStory => 'Histoire d\'Aujourd\'hui';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Enregistrez votre premier moment précieux.\nLes petits changements quotidiens s\'additionnent pour une grande croissance.';

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
  String get diaperChange => 'Changement de Couche';

  @override
  String get oralMedication => 'Médicament Oral';

  @override
  String get topical => 'Topique';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Mesure de Température';

  @override
  String get fever => 'Fièvre';

  @override
  String get lowFever => 'Fièvre légère';

  @override
  String get hypothermia => 'Hypothermie';

  @override
  String get normal => 'Normal';

  @override
  String get quality => 'Qualité';

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
  String get periodSelection => 'Sélection de période :';

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
  String get detailedStatistics => 'Statistiques détaillées';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview =>
      'Vue d\'ensemble de l\'activité globale';

  @override
  String get totalActivities => 'Activités totales';

  @override
  String get activeCards => 'Cartes actives';

  @override
  String get dailyAverage => 'Moyenne quotidienne';

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
  String get search => 'Rechercher';

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
  String get temperatureTrend => 'Tendance de Température';

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
  String get temperatureRecorded => 'Température enregistrée';

  @override
  String recordFailed(String error) {
    return 'Échec de l\'enregistrement';
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
  String get average => 'Moyenne';

  @override
  String get poor => 'Mauvais';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get illness => 'Maladie';

  @override
  String get highFever => 'Fièvre Élevée';

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
  String get sleepQuality => 'Qualité';

  @override
  String get pumpingTime => 'Tire-lait';

  @override
  String get solidFoodTime => 'Nourriture solide';

  @override
  String get totalFeedingAmount => 'Quantité totale d\'alimentation';

  @override
  String get averageFeedingAmount => 'Quantité d\'alimentation moyenne';

  @override
  String get dailyAverageFeedingCount =>
      'Nombre moyen d\'alimentations par jour';

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
  String get minutes => 'min';

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
  String get detailInformation => 'Informations Détaillées';

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
  String get amount => 'Quantité';

  @override
  String get duration => 'Durée';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'Côté';

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
  String get smartInsights => 'Aperçus Intelligents';

  @override
  String get analyzingPatterns => 'Analyse des modèles...';

  @override
  String insightsFound(int count) {
    return '$count aperçus trouvés';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'Confiance';

  @override
  String sleepProgressMinutes(int minutes) {
    return '$minutes minutes en cours';
  }

  @override
  String get sleepProgressTime => 'Temps de progression du sommeil';

  @override
  String get standardFeedingTimeNow =>
      'C\'est l\'heure standard d\'alimentation';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return 'Heure standard d\'alimentation bientôt ($minutes minutes)';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '$hours heures $minutes minutes avant l\'alimentation standard';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '$minutes minutes avant l\'alimentation standard';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      'Enregistrements d\'alimentation insuffisants (application de l\'intervalle standard)';

  @override
  String get standardFeedingTimeOverdue =>
      'L\'heure standard d\'alimentation est dépassée';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes minutes';
  }

  @override
  String personalPatternInfo(String interval) {
    return 'Motif personnel: $interval intervalle (à titre de référence)';
  }

  @override
  String get longPressForDetails => 'Appui long pour les détails';

  @override
  String get todaysSummary => 'Résumé d\'Aujourd\'hui';

  @override
  String get future => 'Futur';

  @override
  String get previousDate => 'Date précédente';

  @override
  String get nextDate => 'Date suivante';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get checkStandardFeedingInterval =>
      'Vérifier l\'intervalle d\'alimentation standard';

  @override
  String get registerBabyFirst => 'Veuillez d\'abord enregistrer votre bébé';

  @override
  String get registerBabyToRecordMoments =>
      'Pour enregistrer les précieux moments de votre bébé,\nveuillez d\'abord enregistrer les informations du bébé.';

  @override
  String get addBabyFromHome => 'Ajouter un bébé depuis l\'accueil';

  @override
  String get timesUnit => 'fois';

  @override
  String get itemsUnit => 'éléments';

  @override
  String get timesPerDay => 'fois/jour';

  @override
  String get activityDistributionByCategory =>
      'Distribution des activités par catégorie';

  @override
  String itemsCount(int count) {
    return '$count éléments';
  }

  @override
  String get totalCount => 'Nombre total';

  @override
  String timesCount(int count) {
    return '$count fois';
  }

  @override
  String get noDetailedData => 'Aucune donnée détaillée';

  @override
  String get averageFeedingTime => 'Durée d\'alimentation moyenne';

  @override
  String get averageSleepTime => 'Durée de sommeil moyenne';

  @override
  String get dailyAverageTotalSleepTime =>
      'Durée totale de sommeil moyenne par jour';

  @override
  String get dailyAverageSleepCount => 'Nombre moyen de sommeil par jour';

  @override
  String get dailyAverageChangeCount => 'Nombre moyen de changements par jour';

  @override
  String get sharingParentingStories => 'Partage d\'histoires parentales';

  @override
  String get myActivity => 'Mon activité';

  @override
  String get categories => 'Catégories';

  @override
  String get menu => 'Menu';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get midnight => 'Minuit';

  @override
  String get morning => 'Matin';

  @override
  String get noon => 'Midi';

  @override
  String get afternoon => 'Après-midi';

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
  String get averageFeedingDuration => 'Durée moyenne d\'alimentation';

  @override
  String get averageSleepDuration => 'Durée moyenne de sommeil';

  @override
  String get dailyTotalSleepDuration => 'Daily total sleep duration';

  @override
  String get dailyAverageDiaperChangeCount =>
      'Changements moyens quotidiens de couche';

  @override
  String get dailyAverageMedicationCount => 'Daily average medication count';

  @override
  String get medicationTypesUsed => 'Types de médicaments utilisés';

  @override
  String get totalPumpedAmount => 'Quantité totale tirée';

  @override
  String get averagePumpedAmount => 'Quantité moyenne tirée';

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
  String get averageLabel => 'Moyenne: ';

  @override
  String get dailyFeedingCountTitle => 'Daily feeding count';

  @override
  String get weekdaysSundayToSaturday => 'SunMonTueWedThuFriSat';

  @override
  String dayFormat(int day) {
    return '$day';
  }

  @override
  String get dailyFeedingCount => 'Nombre quotidien d\'alimentation';

  @override
  String get dailyFeedingAmount => 'Daily feeding amount';

  @override
  String get dailyFeedingDuration => 'Daily feeding duration';

  @override
  String get dailySleepCount => 'Nombre quotidien de sommeil';

  @override
  String get dailySleepDuration => 'Daily sleep duration';

  @override
  String get dailyDiaperChangeCount => 'Changements quotidiens de couche';

  @override
  String get dailyMedicationCount => 'Nombre quotidien de médicaments';

  @override
  String get dailyMilkPumpingCount => 'Nombre quotidien d\'extractions';

  @override
  String get dailyMilkPumpingAmount => 'Daily pumping amount';

  @override
  String get dailySolidFoodCount => 'Nombre quotidien d\'aliments solides';

  @override
  String get dailyAverageSolidFoodCount =>
      'Nombre moyen quotidien d\'aliments solides';

  @override
  String get triedFoodTypes => 'Types d\'aliments essayés';

  @override
  String babyTemperatureRecord(String name) {
    return 'Enregistrement de température de $name';
  }

  @override
  String get adjustWithSlider => 'Ajuster avec le curseur';

  @override
  String get measurementMethod => 'Méthode de mesure';

  @override
  String get normalRange => 'Plage normale';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Plage normale ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Enregistrer le relevé de température';

  @override
  String get enterTemperature => 'Veuillez saisir la température';

  @override
  String get temperatureRangeValidation =>
      'La température doit être entre 34,0°C ~ 42,0°C';

  @override
  String get recordSymptomsHint =>
      'Veuillez enregistrer les symptômes ou notes spéciales';

  @override
  String get oralMethod => 'Orale';

  @override
  String get analMethod => 'Anale';

  @override
  String recentDaysTrend(int days) {
    return 'Tendance des $days derniers jours';
  }

  @override
  String get days3 => '3 jours';

  @override
  String get days7 => '7 jours';

  @override
  String get weeks2 => '2 semaines';

  @override
  String get month1 => '1 mois';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Aucun enregistrement de température pendant la période sélectionnée';

  @override
  String get temperatureChangeTrend => 'Tendance de Changement de Température';

  @override
  String get averageTemperature => 'Température Moyenne';

  @override
  String get highestTemperature => 'Température la Plus Élevée';

  @override
  String get lowestTemperature => 'Température la Plus Basse';

  @override
  String get noteAvailableTapToView => '📝 Note disponible (toucher pour voir)';

  @override
  String get temperatureRisingTrend =>
      'La température montre une tendance à la hausse';

  @override
  String get temperatureFallingTrend =>
      'La température montre une tendance à la baisse';

  @override
  String get temperatureStableTrend => 'La température est stable';

  @override
  String get trendAnalysis => 'Analyse de Tendance';

  @override
  String totalMeasurements(int count) {
    return 'Total de $count mesures';
  }

  @override
  String get temperatureRecordMemo => 'Mémo du Relevé de Température';

  @override
  String babyGrowthChart(String name) {
    return 'Courbe de Croissance de $name';
  }

  @override
  String get noGrowthRecords => 'Aucun enregistrement de croissance';

  @override
  String get enterWeightAndHeightFromHome =>
      'Veuillez saisir le poids et la taille depuis l\'écran d\'accueil';

  @override
  String get all => 'Tout';

  @override
  String get growthInsights => 'Aperçus de Croissance';

  @override
  String get growthRate => 'Taux de Croissance';

  @override
  String get monthlyAverageGrowth => 'Croissance Moyenne Mensuelle';

  @override
  String get dataInsufficient => 'Données Insuffisantes';

  @override
  String get twoOrMoreRequired => '2 ou plus requis';

  @override
  String recentDaysBasis(int days) {
    return 'Basé sur les derniers $days jours';
  }

  @override
  String get entireBasis => 'Basé sur la période entière';

  @override
  String get oneMonthPrediction => 'Prévision 1 Mois';

  @override
  String get currentTrendBasis => 'Basé sur la tendance actuelle';

  @override
  String get predictionNotPossible => 'Prévision non possible';

  @override
  String get trendInsufficient => 'Tendance insuffisante';

  @override
  String get recordFrequency => 'Fréquence d\'Enregistrement';

  @override
  String get veryConsistent => 'Très Cohérent';

  @override
  String get consistent => 'Cohérent';

  @override
  String get irregular => 'Irrégulier';

  @override
  String averageDaysInterval(String days) {
    return 'Intervalle moyen de $days jours';
  }

  @override
  String get nextRecord => 'Prochain Enregistrement';

  @override
  String get now => 'Maintenant';

  @override
  String get soon => 'Bientôt';

  @override
  String daysLater(int days) {
    return '$days jours plus tard';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Enregistré il y a $days jours';
  }

  @override
  String get weeklyRecordRecommended =>
      'Enregistrement hebdomadaire recommandé';

  @override
  String get nextMilestone => 'Prochain Jalon';

  @override
  String targetValue(String value, String unit) {
    return 'Objectif de $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit restant ($progress% atteint)';
  }

  @override
  String get calculationNotPossible => 'Calcul non possible';

  @override
  String get periodInsufficient => 'Période insuffisante';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get weightRecordRequired => 'Enregistrement de poids requis';

  @override
  String get heightRecordRequired => 'Enregistrement de taille requis';

  @override
  String get currentRecordMissing => 'Enregistrement actuel manquant';

  @override
  String get noRecord => 'Aucun enregistrement';

  @override
  String get firstRecordStart => 'Commencer le premier enregistrement';

  @override
  String get oneRecord => '1 enregistrement';

  @override
  String get moreRecordsNeeded => 'Plus d\'enregistrements nécessaires';

  @override
  String get sameDayRecord => 'Enregistrement du même jour';

  @override
  String recordedTimes(int count) {
    return '$count fois enregistré';
  }

  @override
  String get storageMethod => 'Méthode de conservation';

  @override
  String get pumpingType => 'Type de pompage';

  @override
  String get foodName => 'Nom de l\'aliment';

  @override
  String get mealType => 'Type de repas';

  @override
  String get texture => 'Texture';

  @override
  String get reaction => 'Réaction';

  @override
  String get measurementLocation => 'Lieu de mesure';

  @override
  String get feverReducerGiven => 'Antipyrétique donné';

  @override
  String get given => 'Donné';

  @override
  String get hours => 'heures';

  @override
  String get refrigerator => 'Réfrigérateur';

  @override
  String get freezer => 'Congélateur';

  @override
  String get roomTemperature => 'Température ambiante';

  @override
  String get fedImmediately => 'Nourri immédiatement';

  @override
  String get breakfast => 'Petit-déjeuner';

  @override
  String get lunch => 'Déjeuner';

  @override
  String get dinner => 'Dîner';

  @override
  String get snack => 'Collation';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get weightChange => 'Changement de Poids';

  @override
  String get heightChange => 'Changement de Taille';

  @override
  String get totalRecords => 'Total des Enregistrements';

  @override
  String get totalChange => 'Changement Total';

  @override
  String get start => 'Début';

  @override
  String get memo => 'Mémo';

  @override
  String get weightDataEmpty => 'Aucune donnée de poids disponible';

  @override
  String get heightDataEmpty => 'Aucune donnée de taille disponible';

  @override
  String get undoAction => 'Annuler';

  @override
  String get feedingRecordDeleted => 'Enregistrement d\'alimentation supprimé';

  @override
  String get sleepRecordDeleted => 'Enregistrement de sommeil supprimé';

  @override
  String get diaperRecordDeleted => 'Enregistrement de couche supprimé';

  @override
  String get healthRecordDeleted => 'Enregistrement de santé supprimé';

  @override
  String get deletionError => 'Erreur lors de la suppression';

  @override
  String get duplicateInputDetected => 'Saisie en double détectée';

  @override
  String get solidFoodDuplicateConfirm =>
      'Vous venez d\'enregistrer la nourriture solide.\\nVoulez-vous vraiment l\'enregistrer à nouveau ?';

  @override
  String get cannotOpenSettings =>
      'Impossible d\'ouvrir l\'écran des paramètres';

  @override
  String get sleepQualityGood => 'Bon';

  @override
  String get sleepQualityFair => 'Moyen';

  @override
  String get sleepQualityPoor => 'Mauvais';

  @override
  String sleepInProgressDuration(Object minutes) {
    return 'Endormi - ${minutes}min écoulées';
  }

  @override
  String get wetOnly => 'Seulement Mouillé';

  @override
  String get dirtyOnly => 'Seulement Sale';

  @override
  String get wetAndDirty => 'Mouillé + Sale';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get consistencyLabel => 'Consistance';

  @override
  String get topicalMedication => 'Topique';

  @override
  String get inhaledMedication => 'Inhalé';

  @override
  String get milkPumpingInProgress => 'Tire-lait en cours';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return 'Tire-lait - ${minutes}min écoulées';
  }

  @override
  String get lowGradeFever => 'Fièvre Légère';

  @override
  String get normalTemperature => 'Normal';

  @override
  String get allActivities => 'Tout';

  @override
  String get temperatureFilter => 'Température';

  @override
  String get deleteRecordTitle => 'Supprimer l\'enregistrement';

  @override
  String get deleteRecordMessage =>
      'Êtes-vous sûr de vouloir supprimer cet enregistrement ?\nLes enregistrements supprimés ne peuvent pas être récupérés.';

  @override
  String get recordDeletedSuccess => 'L\'enregistrement a été supprimé';

  @override
  String get recordDeleteFailed =>
      'Échec de la suppression de l\'enregistrement';

  @override
  String get recordDeleteError =>
      'Une erreur s\'est produite lors de la suppression de l\'enregistrement';

  @override
  String get recordUpdatedSuccess => 'L\'enregistrement a été mis à jour';

  @override
  String get recordUpdateFailed =>
      'Échec de la mise à jour de l\'enregistrement';

  @override
  String get recordUpdateError =>
      'Une erreur s\'est produite lors de la mise à jour de l\'enregistrement';

  @override
  String noRecordsToday(Object recordType) {
    return 'Aucun enregistrement de $recordType aujourd\'hui';
  }

  @override
  String get healthRecordRestored => 'Les données de santé ont été restaurées';

  @override
  String get deleteTemperatureConfirm =>
      'Voulez-vous supprimer le relevé de température récent?';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get duplicateEntryDetected => 'Entrée en double détectée';

  @override
  String get feedingDuplicateConfirm =>
      'Vous venez d\'ajouter un enregistrement d\'alimentation.\\nVoulez-vous vraiment enregistrer à nouveau?';

  @override
  String get milkPumpingDuplicateConfirm =>
      'Vous venez d\'ajouter un enregistrement de pompage de lait.\\nVoulez-vous vraiment enregistrer à nouveau?';

  @override
  String get medicationDuplicateConfirm =>
      'Vous venez d\'enregistrer un médicament.\\nVoulez-vous vraiment enregistrer à nouveau?';

  @override
  String get diaperDuplicateConfirm =>
      'Vous venez d\'enregistrer un changement de couche.\\nVoulez-vous vraiment enregistrer à nouveau?';

  @override
  String get sleepStartDuplicateConfirm =>
      'Vous venez de manipuler le sommeil.\\nVoulez-vous vraiment commencer à dormir?';

  @override
  String get sleepEndDuplicateConfirm =>
      'Vous venez de manipuler le sommeil.\\nVoulez-vous vraiment arrêter de dormir?';

  @override
  String get recordAction => 'Enregistrer';

  @override
  String get end => 'Fin';

  @override
  String get whatTypeChanged => 'Quel type avez-vous changé?';

  @override
  String get poop => 'Caca';

  @override
  String get urinePoop => 'Urine+Caca';

  @override
  String get changeType => 'Type de Changement';

  @override
  String get colorWhenPoop => 'Couleur (Lors du Caca)';

  @override
  String get minutesShort => 'm';
}
