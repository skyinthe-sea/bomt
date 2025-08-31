// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get user => 'Usuario';

  @override
  String userInfoLoadFailed(String error) {
    return 'Error al cargar información del usuario: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Error al cargar lista de bebés: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return '¡Hola, $userName!';
  }

  @override
  String get registerBaby => 'Registrar bebé';

  @override
  String get noBabiesRegistered => 'No hay bebés registrados';

  @override
  String get registerFirstBaby => '¡Registra tu primer bebé!';

  @override
  String get registerBabyButton => 'Registrar bebé';

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
    return 'Género';
  }

  @override
  String get male => 'Niño';

  @override
  String get female => 'Niña';

  @override
  String get other => 'Otro';

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
  String get enterBabyInfo => 'Ingresa la información del bebé';

  @override
  String get babyName => 'Nombre del bebé';

  @override
  String get babyNameHint => 'ej: Sofía';

  @override
  String get babyNameRequired => 'Ingresa el nombre del bebé';

  @override
  String get babyNameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get selectBirthdateButton => 'Seleccionar fecha de nacimiento';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Cancelar';

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
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Ingresa el nombre del bebé';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get appearance => 'Apariencia';

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
  String get comingSoon => 'Próximamente';

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
  String get growthInfo => 'Información de Crecimiento';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Alimentación';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Sueño';

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
  String get diaper => 'Pañal';

  @override
  String get solidFood => 'Comida Sólida';

  @override
  String get medication => 'Medicación';

  @override
  String get milkPumping => 'Extracción de Leche';

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
  String get feedingAmount => 'Cantidad de alimentación';

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
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

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
  String get enterValidNumber => 'Por favor ingrese un número válido';

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
  String get writePost => 'Escribir Post';

  @override
  String get post => 'Publicar';

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
  String get selectCategory => 'Seleccionar categoría';

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
    return 'Contenido: $count/10000';
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
  String get refresh => 'Actualizar';

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
  String get familyInvitation => 'Invitación familiar';

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
  String get delete => 'Eliminar';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirmar';

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
    return 'hace $minutes minutos';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Hoy';

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
  String get medicationTime => 'Medicación';

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
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

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
    return '$months meses $days días';
  }

  @override
  String get lastFeedingTime => 'Última hora de alimentación';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return 'hace $hours horas $minutes minutos';
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
  String get viewDetails => 'Ver Detalles';

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
  String get joinWithInviteCode => 'Unirse con código de invitación';

  @override
  String get loadingBabyInfo => 'Cargando información del bebé...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Ir a configuración';

  @override
  String get profilePhotoUpdated => 'La foto de perfil ha sido actualizada.';

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
  String get hourActivityPattern => 'Patrón de Actividad de 24 Horas';

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
  String get todaysStory => 'Historia de Hoy';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Registra tu primer momento precioso.\nLos pequeños cambios diarios se suman a un gran crecimiento.';

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
  String get formula => 'Fórmula';

  @override
  String get breastMilk => 'Leche materna';

  @override
  String get babyFood => 'Comida para bebé';

  @override
  String get left => 'Izquierda';

  @override
  String get right => 'Derecha';

  @override
  String get both => 'Ambos';

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
  String get topical => 'Tópico';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Temperature Measurement';

  @override
  String get fever => 'Fiebre';

  @override
  String get lowFever => 'Fiebre baja';

  @override
  String get hypothermia => 'Hipotermia';

  @override
  String get normal => 'Normal';

  @override
  String get quality => 'Calidad';

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
  String get periodSelection => 'Selección de período:';

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
  String get detailedStatistics => 'Estadísticas Detalladas';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Resumen General de Actividades';

  @override
  String get totalActivities => 'Actividades Totales';

  @override
  String get activeCards => 'Tarjetas Activas';

  @override
  String get dailyAverage => 'Promedio Diario';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Intentar de nuevo';

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
  String get search => 'Buscar';

  @override
  String get notification => 'Notificación';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Comparte experiencias de crianza e información valiosa con otros padres';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Todo';

  @override
  String get categoryPopular => 'Popular';

  @override
  String get categoryClinical => 'Clínico';

  @override
  String get categoryInfoSharing => 'Compartir info';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Comida de bebé';

  @override
  String get categoryDevelopment => 'Desarrollo';

  @override
  String get categoryVaccination => 'Vacunación';

  @override
  String get categoryPostpartum => 'Posparto';

  @override
  String get sortByLikes => 'Ordenar por me gusta';

  @override
  String get sortByLatest => 'Ordenar por más recientes';

  @override
  String get edited => '(editado)';

  @override
  String commentsCount(Object count) {
    return '$count comentarios';
  }

  @override
  String get deletePost => 'Eliminar publicación';

  @override
  String get deletePostConfirm =>
      '¿Estás seguro de que quieres eliminar esta publicación?\\nLas publicaciones eliminadas no se pueden recuperar.';

  @override
  String get deletePostSuccess => 'Publicación eliminada.';

  @override
  String deletePostError(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get postNotFound => 'Publicación no encontrada';

  @override
  String get shareFeatureComingSoon => 'Función de compartir próximamente';

  @override
  String get loadingComments => 'Cargando comentarios...';

  @override
  String get loadMoreComments => 'Cargar más comentarios';

  @override
  String get editComment => 'Editar comentario';

  @override
  String get editCommentHint => 'Edita tu comentario...';

  @override
  String get editCommentSuccess => 'Comentario actualizado.';

  @override
  String editCommentError(Object error) {
    return 'Error al editar: $error';
  }

  @override
  String get deleteComment => 'Eliminar comentario';

  @override
  String get deleteCommentConfirm =>
      '¿Estás seguro de que quieres eliminar este comentario?\\nLos comentarios eliminados no se pueden recuperar.';

  @override
  String get deleteCommentSuccess => 'Comentario eliminado.';

  @override
  String get replySuccess => 'Respuesta publicada.';

  @override
  String get commentSuccess => 'Comentario publicado.';

  @override
  String get commentError => 'Error al publicar comentario.';

  @override
  String get titlePlaceholder => 'Ingresa el título';

  @override
  String get contentPlaceholder =>
      'Comparte tus pensamientos...\\n\\nEscribe libremente sobre tus experiencias como padre/madre.';

  @override
  String imageSelectionError(Object error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get userNotFoundError => 'Información del usuario no encontrada.';

  @override
  String get postCreateSuccess => '¡Publicación creada exitosamente!';

  @override
  String postCreateError(Object error) {
    return 'Error al crear publicación: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Título: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Imágenes: $count/5';
  }

  @override
  String get addImageTooltip => 'Agregar imagen';

  @override
  String get allPostsChecked =>
      '¡Todas las publicaciones han sido revisadas! 👍';

  @override
  String get waitForNewPosts => 'Espera nuevas publicaciones';

  @override
  String get noPostsYet => 'Aún no hay publicaciones';

  @override
  String get writeFirstPost => '¡Escribe la primera publicación!';

  @override
  String get loadingNewPosts => 'Cargando nuevas publicaciones...';

  @override
  String get failedToLoadPosts => 'Error al cargar publicaciones';

  @override
  String get checkNetworkAndRetry =>
      'Verifica tu conexión e inténtalo de nuevo';

  @override
  String get categoryDailyLife => 'Vida diaria';

  @override
  String get preparingTimeline => 'Preparando cronología...';

  @override
  String get noRecordedMoments => 'Aún no hay momentos registrados';

  @override
  String get loadingTimeline => 'Cargando cronología...';

  @override
  String get noRecordsYet => 'Aún no hay registros';

  @override
  String noRecordsForDate(Object date) {
    return 'No hay registros para $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'No hay registros de $filter para $date';
  }

  @override
  String get cannotRecordFuture =>
      'Aún no se pueden registrar actividades futuras';

  @override
  String get addFirstRecord => '¡Agrega tu primer registro!';

  @override
  String get canAddPastRecord => 'Puedes agregar registros pasados';

  @override
  String get addRecord => 'Agregar registro';

  @override
  String get viewOtherDates => 'Ver otras fechas';

  @override
  String get goToToday => 'Ir a hoy';

  @override
  String get quickRecordFromHome =>
      'Puedes agregar registros rápidamente desde la pantalla principal';

  @override
  String detailViewComingSoon(String title) {
    return 'Detalles de $title (Próximamente)';
  }

  @override
  String get familyInvitationDescription =>
      'Gestiona registros de cuidado del bebé junto con la familia a través de códigos de invitación';

  @override
  String get babyManagement => 'Gestión del bebé';

  @override
  String get addBaby => 'Agregar bebé';

  @override
  String get noBabiesMessage =>
      'No hay bebés registrados.\\nPor favor agrega un bebé.';

  @override
  String get switchToNextBaby => 'Cambiar al siguiente bebé';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get registering => 'Registrando...';

  @override
  String get register => 'Registrar';

  @override
  String careTogetherWith(String name) {
    return 'Cuidar al bebé junto con $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Invita a la familia o pareja\\npara gestionar juntos los registros de cuidado del bebé';

  @override
  String get generateInviteCode => 'Generar código de invitación';

  @override
  String get generateInviteCodeDescription =>
      'Genera un nuevo código de invitación y cópialo';

  @override
  String get generateInviteCodeButton => 'Generar código de invitación';

  @override
  String get orText => 'O';

  @override
  String get enterInviteCodeDescription =>
      'Ingresa el código de invitación recibido';

  @override
  String get inviteCodePlaceholder => 'Código de invitación (6 dígitos)';

  @override
  String get acceptInvite => 'Aceptar invitación';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name ha sido registrado exitosamente';
  }

  @override
  String get babyRegistrationFailed => 'Error al registrar bebé';

  @override
  String babyRegistrationError(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String babySelected(String name) {
    return '$name ha sido seleccionado';
  }

  @override
  String get inviteCodeGenerated => '¡Código de invitación generado!';

  @override
  String remainingTime(String time) {
    return 'Tiempo restante: $time';
  }

  @override
  String get validTime => 'Tiempo válido: 5 minutos';

  @override
  String get generating => 'Generando...';

  @override
  String get joining => 'Uniéndose...';

  @override
  String get noBabyInfo => 'Sin información del bebé';

  @override
  String get noBabyInfoDescription =>
      'No se encontró información del bebé.\\n¿Quieres crear un bebé de prueba?';

  @override
  String get create => 'Crear';

  @override
  String get generateNewInviteCode => 'Generar nuevo código de invitación';

  @override
  String get replaceExistingCode =>
      'Esto reemplazará el código de invitación existente.\\n¿Quieres continuar?';

  @override
  String get acceptInvitation => 'Aceptar invitación';

  @override
  String get acceptInvitationDescription =>
      '¿Quieres aceptar la invitación y unirte a la familia?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Los registros existentes del bebé serán eliminados y reemplazados por el bebé invitado ($babyName).\\n\\n¿Quieres continuar?';
  }

  @override
  String get pleaseEnterInviteCode => 'Ingresa el código de invitación';

  @override
  String get inviteCodeMustBe6Digits =>
      'El código de invitación debe tener 6 dígitos';

  @override
  String get pleaseLoginFirst =>
      'Información de inicio de sesión no encontrada. Por favor inicia sesión primero.';

  @override
  String get copiedToClipboard => '¡Código de invitación copiado!';

  @override
  String get joinedSuccessfully => '¡Te has unido a la familia exitosamente!';

  @override
  String get inviteCodeExpired => 'Código de invitación expirado';

  @override
  String get invalidInviteCode => 'Código de invitación inválido';

  @override
  String get alreadyMember => 'Ya eres miembro de esta familia';

  @override
  String get cannotInviteSelf => 'No puedes invitarte a ti mismo';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Guía de cuidados de $name';
  }

  @override
  String get babyGuide => 'Guía del bebé';

  @override
  String get noAvailableGuides => 'No hay guías disponibles';

  @override
  String get current => 'Actual';

  @override
  String get past => 'Pasado';

  @override
  String get upcoming => 'Próximo';

  @override
  String babysGuide(String name) {
    return 'de $name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Guía de la $weekText';
  }

  @override
  String get feedingGuide => '💡 Guía de alimentación';

  @override
  String get feedingFrequency => 'Frecuencia de alimentación';

  @override
  String get singleFeedingAmount => 'Cantidad por toma';

  @override
  String get dailyTotal => 'Total diario';

  @override
  String get additionalTips => '📋 Consejos adicionales';

  @override
  String get understood => '¡Entendido!';

  @override
  String get newborn => 'Recién nacido';

  @override
  String weekNumber(int number) {
    return 'Semana $number';
  }

  @override
  String get newbornWeek0 => 'Recién nacido (Semana 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Diariamente $min - $max veces';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Diariamente $min+ veces';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Diariamente hasta $max veces';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml o más';
  }

  @override
  String amountMaxML(int max) {
    return 'Hasta ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Selección de idioma';

  @override
  String get selectLanguage => 'Selecciona un idioma';

  @override
  String get currentLanguage => 'Idioma actual';

  @override
  String get searchCommunityPosts => 'Buscar publicaciones de la comunidad';

  @override
  String get temperatureRecord => 'Registro de temperatura';

  @override
  String get temperatureTrend => 'Tendencia de Temperatura';

  @override
  String get profilePhotoSetup => 'Configuración de foto de perfil';

  @override
  String get howToSelectPhoto => '¿Cómo te gustaría seleccionar una foto?';

  @override
  String get send => 'Enviar';

  @override
  String get emailVerificationRequired =>
      'Verificación de correo electrónico requerida';

  @override
  String get passwordReset => 'Restablecer contraseña';

  @override
  String get enterEmailForReset =>
      'Ingresa tu dirección de correo electrónico registrada.\nTe enviaremos un enlace para restablecer la contraseña.';

  @override
  String get accountWithdrawalComplete => 'Cancelación de cuenta completada';

  @override
  String get genderLabel => 'Género: ';

  @override
  String get birthdateLabel => 'Fecha de nacimiento: ';

  @override
  String get maleGender => 'Masculino';

  @override
  String get femaleGender => 'Femenino';

  @override
  String get joinWithInviteCodeButton => 'Unirse con código de invitación';

  @override
  String get temperatureRecorded => 'La temperatura ha sido registrada';

  @override
  String recordFailed(String error) {
    return 'Error en el registro: $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'La configuración de temperatura ha sido guardada';

  @override
  String get loadingUserInfo =>
      'Cargando información del usuario. Por favor, inténtalo de nuevo en un momento.';

  @override
  String get continueWithSeparateAccount => 'Continuar con cuenta separada';

  @override
  String get linkWithExistingAccount => 'Vincular con cuenta existente';

  @override
  String get linkAccount => 'Vincular cuenta';

  @override
  String get accountLinkingComplete => 'Vinculación de cuenta completada';

  @override
  String get deleteConfirmation => 'Confirmación de eliminación';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get babyNameLabel => 'Nombre del bebé';

  @override
  String get weightInput => 'Ingresar peso';

  @override
  String get heightInput => 'Ingresar altura';

  @override
  String get measurementNotes =>
      'Registrar condiciones de medición o notas especiales (opcional)';

  @override
  String get urine => 'Orina';

  @override
  String get stool => 'Deposición';

  @override
  String get yellow => 'Amarillo';

  @override
  String get brown => 'Marrón';

  @override
  String get green => 'Verde';

  @override
  String get bottle => 'Biberón';

  @override
  String get good => 'Bueno';

  @override
  String get average => 'Promedio';

  @override
  String get poor => 'Malo';

  @override
  String get vaccination => 'Vacunación';

  @override
  String get illness => 'Enfermedad';

  @override
  String get highFever => 'Fiebre Alta';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inhalación';

  @override
  String get injection => 'Inyección';

  @override
  String get tablet => 'Tableta';

  @override
  String get drops => 'Gotas';

  @override
  String get teaspoon => 'Cucharadita';

  @override
  String get tablespoon => 'Cucharada';

  @override
  String get sleepQuality => 'Sueño';

  @override
  String get pumpingTime => 'Extracción';

  @override
  String get solidFoodTime => 'Comida sólida';

  @override
  String get totalFeedingAmount => 'Cantidad total de alimentación';

  @override
  String get averageFeedingAmount => 'Cantidad promedio de alimentación';

  @override
  String get dailyAverageFeedingCount =>
      'Recuento promedio diario de alimentaciones';

  @override
  String get clinical => 'Clínico';

  @override
  String get infoSharing => 'Intercambio de información';

  @override
  String get sleepIssues => 'Problemas de sueño';

  @override
  String get babyFoodCategory => 'Comida para bebé';

  @override
  String get developmentStage => 'Etapa de desarrollo';

  @override
  String get vaccinationCategory => 'Vacunación';

  @override
  String get postpartumRecovery => 'Recuperación posparto';

  @override
  String get dailyLife => 'Vida diaria';

  @override
  String get likes => 'Me gusta';

  @override
  String get comments => 'Comentarios';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get minutes => 'Minutos';

  @override
  String get armpit => 'Axila';

  @override
  String get forehead => 'Frente';

  @override
  String get ear => 'Oído';

  @override
  String get mouth => 'Boca';

  @override
  String get rectal => 'Rectal';

  @override
  String get otherLocation => 'Otro';

  @override
  String get searchError => 'Error de búsqueda';

  @override
  String get question => 'Pregunta';

  @override
  String get information => 'Información';

  @override
  String get relevance => 'Relevancia';

  @override
  String get searchSuggestions => 'Sugerencias de búsqueda';

  @override
  String get noSearchResults => 'Sin resultados de búsqueda';

  @override
  String get tryDifferentSearchTerm =>
      'Prueba con un término de búsqueda diferente';

  @override
  String get likeFeatureComingSoon => 'Función de me gusta próximamente';

  @override
  String get popularSearchTerms => 'Términos de búsqueda populares';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get sortByComments => 'Ordenar por comentarios';

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
  String get longPressForDetails => 'Mantener presionado para detalles';

  @override
  String get todaysSummary => 'Resumen de Hoy';

  @override
  String get future => 'Futuro';

  @override
  String get previousDate => 'Fecha anterior';

  @override
  String get nextDate => 'Fecha siguiente';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst => 'Por favor registra tu bebé primero';

  @override
  String get registerBabyToRecordMoments =>
      'Para registrar los momentos preciosos de tu bebé,\npor favor registra primero la información del bebé.';

  @override
  String get addBabyFromHome => 'Agregar bebé desde inicio';

  @override
  String get timesUnit => 'veces';

  @override
  String get itemsUnit => 'elementos';

  @override
  String get timesPerDay => 'veces/día';

  @override
  String get activityDistributionByCategory =>
      'Distribución de Actividades por Categoría';

  @override
  String itemsCount(int count) {
    return '$count elementos';
  }

  @override
  String get totalCount => 'Recuento Total';

  @override
  String timesCount(int count) {
    return '$count veces';
  }

  @override
  String get noDetailedData => 'No hay datos detallados';

  @override
  String get averageFeedingTime => 'Tiempo promedio de alimentación';

  @override
  String get averageSleepTime => 'Tiempo promedio de sueño';

  @override
  String get dailyAverageTotalSleepTime =>
      'Tiempo total promedio diario de sueño';

  @override
  String get dailyAverageSleepCount => 'Recuento promedio diario de sueño';

  @override
  String get dailyAverageChangeCount => 'Recuento promedio diario de cambios';

  @override
  String get sharingParentingStories => 'Compartiendo Historias de Crianza';

  @override
  String get myActivity => 'Mi Actividad';

  @override
  String get categories => 'Categorías';

  @override
  String get menu => 'Menú';

  @override
  String get seeMore => 'Ver Más';

  @override
  String get midnight => 'Medianoche';

  @override
  String get morning => 'Mañana';

  @override
  String get noon => 'Mediodía';

  @override
  String get afternoon => 'Tarde';

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
    return 'Registro de temperatura de $name';
  }

  @override
  String get adjustWithSlider => 'Ajustar con deslizador';

  @override
  String get measurementMethod => 'Método de medición';

  @override
  String get normalRange => 'Rango normal';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Rango normal ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Guardar registro de temperatura';

  @override
  String get enterTemperature => 'Por favor ingrese la temperatura';

  @override
  String get temperatureRangeValidation =>
      'La temperatura debe estar entre 34,0°C ~ 42,0°C';

  @override
  String get recordSymptomsHint =>
      'Por favor registre síntomas o notas especiales';

  @override
  String get oralMethod => 'Oral';

  @override
  String get analMethod => 'Anal';

  @override
  String recentDaysTrend(int days) {
    return 'Tendencia de los últimos $days días';
  }

  @override
  String get days3 => '3 días';

  @override
  String get days7 => '7 días';

  @override
  String get weeks2 => '2 semanas';

  @override
  String get month1 => '1 mes';

  @override
  String get noTemperatureRecordsInPeriod =>
      'No hay registros de temperatura en el período seleccionado';

  @override
  String get temperatureChangeTrend => 'Tendencia de Cambio de Temperatura';

  @override
  String get averageTemperature => 'Temperatura Promedio';

  @override
  String get highestTemperature => 'Temperatura Más Alta';

  @override
  String get lowestTemperature => 'Temperatura Más Baja';

  @override
  String get noteAvailableTapToView => '📝 Nota disponible (toca para ver)';

  @override
  String get temperatureRisingTrend =>
      'La temperatura muestra una tendencia al alza';

  @override
  String get temperatureFallingTrend =>
      'La temperatura muestra una tendencia a la baja';

  @override
  String get temperatureStableTrend => 'La temperatura está estable';

  @override
  String get trendAnalysis => 'Análisis de Tendencia';

  @override
  String totalMeasurements(int count) {
    return 'Total de $count mediciones';
  }

  @override
  String get temperatureRecordMemo => 'Nota del Registro de Temperatura';

  @override
  String babyGrowthChart(String name) {
    return 'Gráfico de Crecimiento de $name';
  }

  @override
  String get noGrowthRecords => 'No hay registros de crecimiento';

  @override
  String get enterWeightAndHeightFromHome =>
      'Por favor ingrese peso y altura desde la pantalla principal';

  @override
  String get all => 'Todo';

  @override
  String get growthInsights => 'Perspectivas del Crecimiento';

  @override
  String get growthRate => 'Tasa de Crecimiento';

  @override
  String get monthlyAverageGrowth => 'Crecimiento Promedio Mensual';

  @override
  String get dataInsufficient => 'Datos Insuficientes';

  @override
  String get twoOrMoreRequired => 'Se requieren 2 o más';

  @override
  String recentDaysBasis(int days) {
    return 'Basado en los últimos $days días';
  }

  @override
  String get entireBasis => 'Basado en período completo';

  @override
  String get oneMonthPrediction => 'Predicción de 1 Mes';

  @override
  String get currentTrendBasis => 'Basado en tendencia actual';

  @override
  String get predictionNotPossible => 'Predicción no posible';

  @override
  String get trendInsufficient => 'Tendencia insuficiente';

  @override
  String get recordFrequency => 'Frecuencia de Registro';

  @override
  String get veryConsistent => 'Muy Consistente';

  @override
  String get consistent => 'Consistente';

  @override
  String get irregular => 'Irregular';

  @override
  String averageDaysInterval(String days) {
    return 'Promedio $days días de intervalo';
  }

  @override
  String get nextRecord => 'Próximo Registro';

  @override
  String get now => 'Ahora';

  @override
  String get soon => 'Pronto';

  @override
  String daysLater(int days) {
    return '$days días después';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Registrado hace $days días';
  }

  @override
  String get weeklyRecordRecommended => 'Registro semanal recomendado';

  @override
  String get nextMilestone => 'Próximo Hito';

  @override
  String targetValue(String value, String unit) {
    return 'Meta de $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit restante ($progress% logrado)';
  }

  @override
  String get calculationNotPossible => 'Cálculo no posible';

  @override
  String get periodInsufficient => 'Período insuficiente';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get weightRecordRequired => 'Registro de peso requerido';

  @override
  String get heightRecordRequired => 'Registro de altura requerido';

  @override
  String get currentRecordMissing => 'Registro actual faltante';

  @override
  String get noRecord => 'Sin registro';

  @override
  String get firstRecordStart => 'Comenzar primer registro';

  @override
  String get oneRecord => '1 registro';

  @override
  String get moreRecordsNeeded => 'Se necesitan más registros';

  @override
  String get sameDayRecord => 'Registro del mismo día';

  @override
  String recordedTimes(int count) {
    return '$count veces registrado';
  }

  @override
  String get storageMethod => 'Método de almacenamiento';

  @override
  String get pumpingType => 'Tipo de extracción';

  @override
  String get foodName => 'Nombre del alimento';

  @override
  String get mealType => 'Tipo de comida';

  @override
  String get texture => 'Textura';

  @override
  String get reaction => 'Reacción';

  @override
  String get measurementLocation => 'Lugar de medición';

  @override
  String get feverReducerGiven => 'Reductor de fiebre dado';

  @override
  String get given => 'Dado';

  @override
  String get hours => 'horas';

  @override
  String get refrigerator => 'Refrigerador';

  @override
  String get freezer => 'Congelador';

  @override
  String get roomTemperature => 'Temperatura ambiente';

  @override
  String get fedImmediately => 'Alimentado inmediatamente';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get dinner => 'Cena';

  @override
  String get snack => 'Merienda';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get on => 'Encendido';

  @override
  String get off => 'Apagado';
}
