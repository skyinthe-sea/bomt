// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get user => 'Usuário';

  @override
  String userInfoLoadFailed(String error) {
    return 'Falha ao carregar informações do usuário: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Erro ao carregar lista de bebês: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Olá, $userName!';
  }

  @override
  String get registerBaby => 'Cadastrar bebê';

  @override
  String get noBabiesRegistered => 'Nenhum bebê cadastrado';

  @override
  String get registerFirstBaby => 'Cadastre seu primeiro bebê!';

  @override
  String get registerBabyButton => 'Registrar bebê';

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
    return 'Sexo';
  }

  @override
  String get male => 'Menino';

  @override
  String get female => 'Menina';

  @override
  String get other => 'Outro';

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
  String get enterBabyInfo => 'Digite as informações do bebê';

  @override
  String get babyName => 'Nome do bebê';

  @override
  String get babyNameHint => 'ex: Maria';

  @override
  String get babyNameRequired => 'Digite o nome do bebê';

  @override
  String get babyNameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get selectBirthdateButton => 'Selecionar data de nascimento';

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
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Digite o nome do bebê';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Sair';

  @override
  String get logoutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get appearance => 'Aparência';

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
  String get comingSoon => 'Em breve';

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
  String get growthInfo => 'Info de Crescimento';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Alimentação';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Sono';

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
  String get diaper => 'Fralda';

  @override
  String get solidFood => 'Comida Sólida';

  @override
  String get medication => 'Medicação';

  @override
  String get milkPumping => 'Ordenha';

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
  String get feedingAmount => 'Quantidade de alimentação';

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
  String get enterValidNumber => 'Por favor, insira um número válido';

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
  String get writePost => 'Escrever Post';

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
  String get selectCategory => 'Selecionar categoria';

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
    return 'Conteúdo: $count/10000';
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
  String get refresh => 'Atualizar';

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
  String get familyInvitation => 'Convite familiar';

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
  String get delete => 'Excluir';

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
    return 'há $minutes minutos';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Hoje';

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
  String get medicationTime => 'Medicação';

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
  String get camera => 'Câmera';

  @override
  String get gallery => 'Galeria';

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
    return '$months meses $days dias';
  }

  @override
  String get lastFeedingTime => 'Último horário de alimentação';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return 'há $hours horas $minutes minutos';
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
  String get viewDetails => 'Ver Detalhes';

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
  String get joinWithInviteCode => 'Entrar com código de convite';

  @override
  String get loadingBabyInfo => 'Carregando informações do bebê...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Ir para configurações';

  @override
  String get profilePhotoUpdated => 'A foto de perfil foi atualizada.';

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
  String get hourActivityPattern => 'Padrão de Atividade de 24 Horas';

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
  String get todaysStory => 'História de Hoje';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Registre seu primeiro momento precioso.\nPequenas mudanças diárias somam-se a um grande crescimento.';

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
  String get breastMilk => 'Leite materno';

  @override
  String get babyFood => 'Comida de bebê';

  @override
  String get left => 'Esquerda';

  @override
  String get right => 'Direita';

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
  String get fever => 'Febre';

  @override
  String get lowFever => 'Febre baixa';

  @override
  String get hypothermia => 'Hipotermia';

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
  String get periodSelection => 'Seleção de período:';

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
  String get detailedStatistics => 'Estatísticas Detalhadas';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Visão Geral da Atividade Global';

  @override
  String get totalActivities => 'Atividades Totais';

  @override
  String get activeCards => 'Cartões Ativos';

  @override
  String get dailyAverage => 'Média Diária';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Tentar novamente';

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
  String get search => 'Pesquisar';

  @override
  String get notification => 'Notificação';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Compartilhe experiências parentais e informações valiosas com outros pais';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryPopular => 'Popular';

  @override
  String get categoryClinical => 'Clínico';

  @override
  String get categoryInfoSharing => 'Compartilhamento';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Alimentação';

  @override
  String get categoryDevelopment => 'Desenvolvimento';

  @override
  String get categoryVaccination => 'Vacinação';

  @override
  String get categoryPostpartum => 'Pós-parto';

  @override
  String get sortByLikes => 'Ordenar por curtidas';

  @override
  String get sortByLatest => 'Ordenar por mais recentes';

  @override
  String get edited => '(editado)';

  @override
  String commentsCount(Object count) {
    return '$count comentários';
  }

  @override
  String get deletePost => 'Excluir post';

  @override
  String get deletePostConfirm =>
      'Tem certeza que deseja excluir este post?\\nPosts excluídos não podem ser recuperados.';

  @override
  String get deletePostSuccess => 'Post excluído.';

  @override
  String deletePostError(Object error) {
    return 'Falha ao excluir: $error';
  }

  @override
  String get postNotFound => 'Post não encontrado';

  @override
  String get shareFeatureComingSoon => 'Função de compartilhamento em breve';

  @override
  String get loadingComments => 'Carregando comentários...';

  @override
  String get loadMoreComments => 'Carregar mais comentários';

  @override
  String get editComment => 'Editar comentário';

  @override
  String get editCommentHint => 'Edite seu comentário...';

  @override
  String get editCommentSuccess => 'Comentário atualizado.';

  @override
  String editCommentError(Object error) {
    return 'Falha na edição: $error';
  }

  @override
  String get deleteComment => 'Excluir comentário';

  @override
  String get deleteCommentConfirm =>
      'Tem certeza que deseja excluir este comentário?\\nComentários excluídos não podem ser recuperados.';

  @override
  String get deleteCommentSuccess => 'Comentário excluído.';

  @override
  String get replySuccess => 'Resposta postada.';

  @override
  String get commentSuccess => 'Comentário postado.';

  @override
  String get commentError => 'Falha ao postar comentário.';

  @override
  String get titlePlaceholder => 'Digite o título';

  @override
  String get contentPlaceholder =>
      'Compartilhe seus pensamentos...\\n\\nEscreva livremente sobre suas experiências como pai/mãe.';

  @override
  String imageSelectionError(Object error) {
    return 'Falha na seleção de imagem: $error';
  }

  @override
  String get userNotFoundError => 'Informações do usuário não encontradas.';

  @override
  String get postCreateSuccess => 'Post criado com sucesso!';

  @override
  String postCreateError(Object error) {
    return 'Falha ao criar post: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Título: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Imagens: $count/5';
  }

  @override
  String get addImageTooltip => 'Adicionar imagem';

  @override
  String get allPostsChecked => 'Todos os posts foram verificados! 👍';

  @override
  String get waitForNewPosts => 'Aguarde novos posts';

  @override
  String get noPostsYet => 'Ainda não há posts';

  @override
  String get writeFirstPost => 'Escreva o primeiro post!';

  @override
  String get loadingNewPosts => 'Carregando novos posts...';

  @override
  String get failedToLoadPosts => 'Falha ao carregar posts';

  @override
  String get checkNetworkAndRetry => 'Verifique sua conexão e tente novamente';

  @override
  String get categoryDailyLife => 'Dia a dia';

  @override
  String get preparingTimeline => 'Preparando timeline...';

  @override
  String get noRecordedMoments => 'Ainda não há momentos registrados';

  @override
  String get loadingTimeline => 'Carregando timeline...';

  @override
  String get noRecordsYet => 'Ainda não há registros';

  @override
  String noRecordsForDate(Object date) {
    return 'Nenhum registro para $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Nenhum registro de $filter para $date';
  }

  @override
  String get cannotRecordFuture =>
      'Ainda não é possível registrar atividades futuras';

  @override
  String get addFirstRecord => 'Adicione seu primeiro registro!';

  @override
  String get canAddPastRecord => 'Você pode adicionar registros passados';

  @override
  String get addRecord => 'Adicionar registro';

  @override
  String get viewOtherDates => 'Ver outras datas';

  @override
  String get goToToday => 'Ir para hoje';

  @override
  String get quickRecordFromHome =>
      'Você pode adicionar registros rapidamente na tela inicial';

  @override
  String detailViewComingSoon(String title) {
    return 'Detalhes de $title (Em breve)';
  }

  @override
  String get familyInvitationDescription =>
      'Gerencie registros de cuidados do bebê junto com a família através de códigos de convite';

  @override
  String get babyManagement => 'Gerenciamento do bebê';

  @override
  String get addBaby => 'Adicionar bebê';

  @override
  String get noBabiesMessage =>
      'Nenhum bebê cadastrado.\\nPor favor, adicione um bebê.';

  @override
  String get switchToNextBaby => 'Mudar para o próximo bebê';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get registering => 'Cadastrando...';

  @override
  String get register => 'Cadastrar';

  @override
  String careTogetherWith(String name) {
    return 'Cuidar do bebê junto com $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Convide família ou parceiro\\npara gerenciar registros de cuidados do bebê juntos';

  @override
  String get generateInviteCode => 'Gerar código de convite';

  @override
  String get generateInviteCodeDescription =>
      'Gere um novo código de convite e copie';

  @override
  String get generateInviteCodeButton => 'Gerar código de convite';

  @override
  String get orText => 'Ou';

  @override
  String get enterInviteCodeDescription =>
      'Digite o código de convite recebido';

  @override
  String get inviteCodePlaceholder => 'Código de convite (6 dígitos)';

  @override
  String get acceptInvite => 'Aceitar convite';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name foi cadastrado com sucesso';
  }

  @override
  String get babyRegistrationFailed => 'Falha no cadastro do bebê';

  @override
  String babyRegistrationError(String error) {
    return 'Erro ocorrido: $error';
  }

  @override
  String babySelected(String name) {
    return '$name foi selecionado';
  }

  @override
  String get inviteCodeGenerated => 'Código de convite gerado!';

  @override
  String remainingTime(String time) {
    return 'Tempo restante: $time';
  }

  @override
  String get validTime => 'Tempo válido: 5 minutos';

  @override
  String get generating => 'Gerando...';

  @override
  String get joining => 'Entrando...';

  @override
  String get noBabyInfo => 'Sem informações do bebê';

  @override
  String get noBabyInfoDescription =>
      'Nenhuma informação de bebê encontrada.\\nDeseja criar um bebê de teste?';

  @override
  String get create => 'Criar';

  @override
  String get generateNewInviteCode => 'Gerar novo código de convite';

  @override
  String get replaceExistingCode =>
      'Isso substituirá o código de convite existente.\\nDeseja continuar?';

  @override
  String get acceptInvitation => 'Aceitar convite';

  @override
  String get acceptInvitationDescription =>
      'Deseja aceitar o convite e entrar na família?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Os registros existentes do bebê serão excluídos e substituídos pelo bebê convidado ($babyName).\\n\\nDeseja continuar?';
  }

  @override
  String get pleaseEnterInviteCode => 'Digite o código de convite';

  @override
  String get inviteCodeMustBe6Digits =>
      'O código de convite deve ter 6 dígitos';

  @override
  String get pleaseLoginFirst =>
      'Informações de login não encontradas. Faça login primeiro.';

  @override
  String get copiedToClipboard => 'Código de convite copiado!';

  @override
  String get joinedSuccessfully => 'Entrou na família com sucesso!';

  @override
  String get inviteCodeExpired => 'Código de convite expirado';

  @override
  String get invalidInviteCode => 'Código de convite inválido';

  @override
  String get alreadyMember => 'Você já é membro desta família';

  @override
  String get cannotInviteSelf => 'Você não pode convidar a si mesmo';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Guia de cuidados do $name';
  }

  @override
  String get babyGuide => 'Guia do bebê';

  @override
  String get noAvailableGuides => 'Nenhum guia disponível';

  @override
  String get current => 'Atual';

  @override
  String get past => 'Passado';

  @override
  String get upcoming => 'Próximo';

  @override
  String babysGuide(String name) {
    return 'do $name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Guia da $weekText';
  }

  @override
  String get feedingGuide => '💡 Guia de alimentação';

  @override
  String get feedingFrequency => 'Frequência de alimentação';

  @override
  String get singleFeedingAmount => 'Quantidade por mamada';

  @override
  String get dailyTotal => 'Total diário';

  @override
  String get additionalTips => '📋 Dicas adicionais';

  @override
  String get understood => 'Entendi!';

  @override
  String get newborn => 'Recém-nascido';

  @override
  String weekNumber(int number) {
    return 'Semana $number';
  }

  @override
  String get newbornWeek0 => 'Recém-nascido (Semana 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Diariamente $min - $max vezes';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Diariamente $min+ vezes';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Diariamente até $max vezes';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml ou mais';
  }

  @override
  String amountMaxML(int max) {
    return 'Até ${max}ml';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Seleção de idioma';

  @override
  String get selectLanguage => 'Selecione um idioma';

  @override
  String get currentLanguage => 'Idioma atual';

  @override
  String get searchCommunityPosts => 'Pesquisar publicações da comunidade';

  @override
  String get temperatureRecord => 'Registro de temperatura';

  @override
  String get temperatureTrend => 'Tendência de Temperatura';

  @override
  String get profilePhotoSetup => 'Configuração da foto de perfil';

  @override
  String get howToSelectPhoto => 'Como você gostaria de selecionar uma foto?';

  @override
  String get send => 'Enviar';

  @override
  String get emailVerificationRequired => 'Verificação de email necessária';

  @override
  String get passwordReset => 'Redefinir senha';

  @override
  String get enterEmailForReset =>
      'Digite seu endereço de email registrado.\nEnviaremos um link para redefinir a senha.';

  @override
  String get accountWithdrawalComplete => 'Cancelamento de conta concluído';

  @override
  String get genderLabel => 'Gênero: ';

  @override
  String get birthdateLabel => 'Data de nascimento: ';

  @override
  String get maleGender => 'Masculino';

  @override
  String get femaleGender => 'Feminino';

  @override
  String get joinWithInviteCodeButton => 'Participar com código de convite';

  @override
  String get temperatureRecorded => 'A temperatura foi registrada';

  @override
  String recordFailed(String error) {
    return 'Falha no registro: $error';
  }

  @override
  String get temperatureSettingsSaved =>
      'As configurações de temperatura foram salvas';

  @override
  String get loadingUserInfo =>
      'Carregando informações do usuário. Tente novamente em um momento.';

  @override
  String get continueWithSeparateAccount => 'Continuar com conta separada';

  @override
  String get linkWithExistingAccount => 'Vincular com conta existente';

  @override
  String get linkAccount => 'Vincular conta';

  @override
  String get accountLinkingComplete => 'Vinculação de conta concluída';

  @override
  String get deleteConfirmation => 'Confirmação de exclusão';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get babyNameLabel => 'Nome do bebê';

  @override
  String get weightInput => 'Inserir peso';

  @override
  String get heightInput => 'Inserir altura';

  @override
  String get measurementNotes =>
      'Registrar condições de medição ou notas especiais (opcional)';

  @override
  String get urine => 'Urina';

  @override
  String get stool => 'Fezes';

  @override
  String get yellow => 'Amarelo';

  @override
  String get brown => 'Marrom';

  @override
  String get green => 'Verde';

  @override
  String get bottle => 'Mamadeira';

  @override
  String get good => 'Bom';

  @override
  String get average => 'Médio';

  @override
  String get poor => 'Ruim';

  @override
  String get vaccination => 'Vacinação';

  @override
  String get illness => 'Doença';

  @override
  String get highFever => 'Febre Alta';

  @override
  String get oral => 'Oral';

  @override
  String get inhalation => 'Inalação';

  @override
  String get injection => 'Injeção';

  @override
  String get tablet => 'Comprimido';

  @override
  String get drops => 'Gotas';

  @override
  String get teaspoon => 'Colher de chá';

  @override
  String get tablespoon => 'Colher de sopa';

  @override
  String get sleepQuality => 'Sono';

  @override
  String get pumpingTime => 'Extração';

  @override
  String get solidFoodTime => 'Comida sólida';

  @override
  String get totalFeedingAmount => 'Quantidade total de alimentação';

  @override
  String get averageFeedingAmount => 'Quantidade média de alimentação';

  @override
  String get dailyAverageFeedingCount =>
      'Contagem média diária de alimentações';

  @override
  String get clinical => 'Clínico';

  @override
  String get infoSharing => 'Compartilhamento de informações';

  @override
  String get sleepIssues => 'Problemas de sono';

  @override
  String get babyFoodCategory => 'Comida de bebê';

  @override
  String get developmentStage => 'Estágio de desenvolvimento';

  @override
  String get vaccinationCategory => 'Vacinação';

  @override
  String get postpartumRecovery => 'Recuperação pós-parto';

  @override
  String get dailyLife => 'Vida diária';

  @override
  String get likes => 'Curtidas';

  @override
  String get comments => 'Comentários';

  @override
  String get anonymous => 'Anônimo';

  @override
  String get minutes => 'Minutos';

  @override
  String get armpit => 'Axila';

  @override
  String get forehead => 'Testa';

  @override
  String get ear => 'Ouvido';

  @override
  String get mouth => 'Boca';

  @override
  String get rectal => 'Retal';

  @override
  String get otherLocation => 'Outro';

  @override
  String get searchError => 'Erro de pesquisa';

  @override
  String get question => 'Pergunta';

  @override
  String get information => 'Informação';

  @override
  String get relevance => 'Relevância';

  @override
  String get searchSuggestions => 'Sugestões de pesquisa';

  @override
  String get noSearchResults => 'Nenhum resultado de pesquisa';

  @override
  String get tryDifferentSearchTerm => 'Tente um termo de pesquisa diferente';

  @override
  String get likeFeatureComingSoon => 'Recurso curtir em breve';

  @override
  String get popularSearchTerms => 'Termos de pesquisa populares';

  @override
  String get recentSearches => 'Pesquisas recentes';

  @override
  String get deleteAll => 'Excluir tudo';

  @override
  String get sortByComments => 'Classificar por comentários';

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
    return '$minutes minutos em andamento';
  }

  @override
  String get sleepProgressTime => 'Tempo de progresso do sono';

  @override
  String get standardFeedingTimeNow => 'É horário padrão de alimentação';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return 'Horário padrão de alimentação em breve ($minutes minutos)';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '$hours horas $minutes minutos até a alimentação padrão';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '$minutes minutos até a alimentação padrão';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      'Registros de alimentação insuficientes (aplicando intervalo padrão)';

  @override
  String get standardFeedingTimeOverdue =>
      'Horário padrão de alimentação está atrasado';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours horas $minutes minutos';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes minutos';
  }

  @override
  String personalPatternInfo(String interval) {
    return 'Padrão pessoal: $interval intervalo (para referência)';
  }

  @override
  String get longPressForDetails => 'Pressione e segure para detalhes';

  @override
  String get todaysSummary => 'Resumo de Hoje';

  @override
  String get future => 'Futuro';

  @override
  String get previousDate => 'Data anterior';

  @override
  String get nextDate => 'Próxima data';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get checkStandardFeedingInterval =>
      'Verificar intervalo de alimentação padrão';

  @override
  String get registerBabyFirst => 'Por favor, cadastre seu bebê primeiro';

  @override
  String get registerBabyToRecordMoments =>
      'Para registrar os momentos preciosos do seu bebê,\npor favor cadastre primeiro as informações do bebê.';

  @override
  String get addBabyFromHome => 'Adicionar bebê da tela inicial';

  @override
  String get timesUnit => 'vezes';

  @override
  String get itemsUnit => 'itens';

  @override
  String get timesPerDay => 'vezes/dia';

  @override
  String get activityDistributionByCategory =>
      'Distribuição de Atividades por Categoria';

  @override
  String itemsCount(int count) {
    return '$count itens';
  }

  @override
  String get totalCount => 'Contagem Total';

  @override
  String timesCount(int count) {
    return '$count vezes';
  }

  @override
  String get noDetailedData => 'Nenhum dado detalhado';

  @override
  String get averageFeedingTime => 'Tempo médio de alimentação';

  @override
  String get averageSleepTime => 'Tempo médio de sono';

  @override
  String get dailyAverageTotalSleepTime => 'Tempo total médio diário de sono';

  @override
  String get dailyAverageSleepCount => 'Contagem média diária de sono';

  @override
  String get dailyAverageChangeCount => 'Contagem média diária de trocas';

  @override
  String get sharingParentingStories =>
      'Compartilhando Histórias de Paternidade';

  @override
  String get myActivity => 'Minha Atividade';

  @override
  String get categories => 'Categorias';

  @override
  String get menu => 'Menu';

  @override
  String get seeMore => 'Ver Mais';

  @override
  String get midnight => 'Meia-noite';

  @override
  String get morning => 'Manhã';

  @override
  String get noon => 'Meio-dia';

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
  String get adjustWithSlider => 'Ajustar com controle deslizante';

  @override
  String get measurementMethod => 'Método de medição';

  @override
  String get normalRange => 'Faixa normal';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Faixa normal ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Salvar registro de temperatura';

  @override
  String get enterTemperature => 'Por favor, insira a temperatura';

  @override
  String get temperatureRangeValidation =>
      'A temperatura deve estar entre 34,0°C ~ 42,0°C';

  @override
  String get recordSymptomsHint =>
      'Por favor, registre sintomas ou observações especiais';

  @override
  String get oralMethod => 'Oral';

  @override
  String get analMethod => 'Anal';

  @override
  String recentDaysTrend(int days) {
    return 'Tendência dos últimos $days dias';
  }

  @override
  String get days3 => '3 dias';

  @override
  String get days7 => '7 dias';

  @override
  String get weeks2 => '2 semanas';

  @override
  String get month1 => '1 mês';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Nenhum registro de temperatura no período selecionado';

  @override
  String get temperatureChangeTrend => 'Tendência de Mudança de Temperatura';

  @override
  String get averageTemperature => 'Temperatura Média';

  @override
  String get highestTemperature => 'Temperatura Mais Alta';

  @override
  String get lowestTemperature => 'Temperatura Mais Baixa';

  @override
  String get noteAvailableTapToView => '📝 Nota disponível (toque para ver)';

  @override
  String get temperatureRisingTrend =>
      'A temperatura mostra uma tendência de alta';

  @override
  String get temperatureFallingTrend =>
      'A temperatura mostra uma tendência de baixa';

  @override
  String get temperatureStableTrend => 'A temperatura está estável';

  @override
  String get trendAnalysis => 'Análise de Tendência';

  @override
  String totalMeasurements(int count) {
    return 'Total de $count medições';
  }

  @override
  String get temperatureRecordMemo => 'Nota do Registro de Temperatura';

  @override
  String babyGrowthChart(String name) {
    return 'Gráfico de Crescimento do $name';
  }

  @override
  String get noGrowthRecords => 'Nenhum registro de crescimento';

  @override
  String get enterWeightAndHeightFromHome =>
      'Por favor, insira peso e altura pela tela inicial';

  @override
  String get all => 'Todos';

  @override
  String get growthInsights => 'Insights de Crescimento';

  @override
  String get growthRate => 'Taxa de Crescimento';

  @override
  String get monthlyAverageGrowth => 'Crescimento Médio Mensal';

  @override
  String get dataInsufficient => 'Dados Insuficientes';

  @override
  String get twoOrMoreRequired => '2 ou mais necessários';

  @override
  String recentDaysBasis(int days) {
    return 'Baseado nos últimos $days dias';
  }

  @override
  String get entireBasis => 'Baseado no período inteiro';

  @override
  String get oneMonthPrediction => 'Predição de 1 Mês';

  @override
  String get currentTrendBasis => 'Baseado na tendência atual';

  @override
  String get predictionNotPossible => 'Predição não possível';

  @override
  String get trendInsufficient => 'Tendência insuficiente';

  @override
  String get recordFrequency => 'Frequência de Registro';

  @override
  String get veryConsistent => 'Muito Consistente';

  @override
  String get consistent => 'Consistente';

  @override
  String get irregular => 'Irregular';

  @override
  String averageDaysInterval(String days) {
    return 'Intervalo médio de $days dias';
  }

  @override
  String get nextRecord => 'Próximo Registro';

  @override
  String get now => 'Agora';

  @override
  String get soon => 'Em breve';

  @override
  String daysLater(int days) {
    return '$days dias depois';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Registrado há $days dias';
  }

  @override
  String get weeklyRecordRecommended => 'Registro semanal recomendado';

  @override
  String get nextMilestone => 'Próxima Meta';

  @override
  String targetValue(String value, String unit) {
    return 'Meta de $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return '$remaining$unit restante ($progress% alcançado)';
  }

  @override
  String get calculationNotPossible => 'Cálculo não possível';

  @override
  String get periodInsufficient => 'Período insuficiente';

  @override
  String get noDataAvailable => 'Nenhum dado disponível';

  @override
  String get weightRecordRequired => 'Registro de peso necessário';

  @override
  String get heightRecordRequired => 'Registro de altura necessário';

  @override
  String get currentRecordMissing => 'Registro atual ausente';

  @override
  String get noRecord => 'Nenhum registro';

  @override
  String get firstRecordStart => 'Iniciar primeiro registro';

  @override
  String get oneRecord => '1 registro';

  @override
  String get moreRecordsNeeded => 'Mais registros necessários';

  @override
  String get sameDayRecord => 'Registro do mesmo dia';

  @override
  String recordedTimes(int count) {
    return '$count vezes registrado';
  }
}
