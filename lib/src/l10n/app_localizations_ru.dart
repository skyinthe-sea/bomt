// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get user => 'Пользователь';

  @override
  String userInfoLoadFailed(String error) {
    return 'Ошибка загрузки информации пользователя: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'Ошибка загрузки списка детей: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return 'Привет, $userName!';
  }

  @override
  String get registerBaby => 'Зарегистрировать ребёнка';

  @override
  String get noBabiesRegistered => 'Дети не зарегистрированы';

  @override
  String get registerFirstBaby => 'Зарегистрируйте вашего первого ребёнка!';

  @override
  String get registerBabyButton => 'Зарегистрировать ребенка';

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
    return 'Пол';
  }

  @override
  String get male => 'Мальчик';

  @override
  String get female => 'Девочка';

  @override
  String get other => 'Другое';

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
  String get enterBabyInfo => 'Введите информацию о ребёнке';

  @override
  String get babyName => 'Имя ребёнка';

  @override
  String get babyNameHint => 'например: Анна';

  @override
  String get babyNameRequired => 'Введите имя ребёнка';

  @override
  String get babyNameMinLength => 'Имя должно содержать минимум 2 символа';

  @override
  String get selectBirthdateButton => 'Выберите дату рождения';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day.$month.$year';
  }

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get cancel => 'Отмена';

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
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get selectBirthDate => 'Select Birthdate';

  @override
  String get pleasSelectBirthDate => 'Please select birthdate';

  @override
  String get pleaseEnterBabyName => 'Введите имя ребёнка';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year/$month/$day';
  }

  @override
  String get autoLogin => 'Stay logged in';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get appearance => 'Оформление';

  @override
  String get home => 'Главная';

  @override
  String get timeline => 'Хронология';

  @override
  String get record => 'Записать';

  @override
  String get statistics => 'Статистика';

  @override
  String get community => 'Сообщество';

  @override
  String get comingSoon => 'Скоро';

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
  String get growthInfo => 'Информация о росте';

  @override
  String get lastFeeding => 'Last Feeding';

  @override
  String get healthy => 'Healthy';

  @override
  String get feeding => 'Кормление';

  @override
  String get totalFeeding => 'Total Feeding';

  @override
  String get sleep => 'Сон';

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
  String get diaper => 'Подгузник';

  @override
  String get solidFood => 'Твердая Пища';

  @override
  String get medication => 'Лекарство';

  @override
  String get milkPumping => 'Сцеживание Молока';

  @override
  String get temperature => 'Температура';

  @override
  String get growth => 'Growth';

  @override
  String get health => 'Health';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'Количество кормления';

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
  String get sleepInProgress => 'Спит';

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
  String get weight => 'Вес';

  @override
  String get height => 'Рост';

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
  String get enterValidNumber => 'Пожалуйста, введите действительное число';

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
  String get writePost => 'Написать пост';

  @override
  String get post => 'Опубликовать';

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
  String get selectCategory => 'Выберите категорию';

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
    return 'Содержание: $count/10000';
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
  String get refresh => 'Обновить';

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
  String get familyInvitation => 'Семейное приглашение';

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
  String get delete => 'Удалить';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Подтвердить';

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
    return '$minutes минут назад';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Сегодня';

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
  String get medicationTime => 'Лекарство';

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
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

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
    return '$months месяцев $days дней';
  }

  @override
  String get lastFeedingTime => 'Время последнего кормления';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours часов $minutes минут назад';
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
  String get viewDetails => 'Посмотреть подробности';

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
  String get joinWithInviteCode => 'Присоединиться по коду приглашения';

  @override
  String get loadingBabyInfo => 'Загрузка информации о ребёнке...';

  @override
  String get pleaseRegisterBaby => 'Please register a baby in settings';

  @override
  String get goToSettings => 'Перейти к настройкам';

  @override
  String get profilePhotoUpdated => 'Фотография профиля обновлена.';

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
  String get hourActivityPattern => '24-часовая модель активности';

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
  String get todaysStory => 'История сегодняшнего дня';

  @override
  String preciousMoments(Object count) {
    return '$count precious moments';
  }

  @override
  String get firstMomentMessage =>
      'Запишите свой первый драгоценный момент.\nНебольшие ежедневные изменения складываются в большой рост.';

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
  String get formula => 'Смесь';

  @override
  String get breastMilk => 'Грудное молоко';

  @override
  String get babyFood => 'Детское питание';

  @override
  String get left => 'Левая';

  @override
  String get right => 'Правая';

  @override
  String get both => 'Обе';

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
  String get diaperChange => 'Смена Подгузника';

  @override
  String get oralMedication => 'Пероральное Лекарство';

  @override
  String get topical => 'Наружный';

  @override
  String get inhaled => 'Inhaled';

  @override
  String get pumping => 'Pumping';

  @override
  String get temperatureMeasurement => 'Измерение Температуры';

  @override
  String get fever => 'Лихорадка';

  @override
  String get lowFever => 'Легкая лихорадка';

  @override
  String get hypothermia => 'Гипотермия';

  @override
  String get normal => 'Нормально';

  @override
  String get quality => 'Качество';

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
  String get periodSelection => 'Выбор периода:';

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
  String get detailedStatistics => 'Подробная статистика';

  @override
  String get chartAnalysis => 'Chart Analysis';

  @override
  String get overallActivityOverview => 'Общий обзор активности';

  @override
  String get totalActivities => 'Общее количество активностей';

  @override
  String get activeCards => 'Активные карточки';

  @override
  String get dailyAverage => 'Дневное среднее';

  @override
  String get activityDistributionByCard => 'Activity Distribution by Card';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get tryAgain => 'Попробовать снова';

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
  String get search => 'Поиск';

  @override
  String get notification => 'Уведомление';

  @override
  String get searchFeatureComingSoon => 'Search feature coming soon';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'Делитесь родительским опытом и ценной информацией с другими родителями';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryPopular => 'Популярные';

  @override
  String get categoryClinical => 'Клинические';

  @override
  String get categoryInfoSharing => 'Обмен информацией';

  @override
  String get categorySleepIssues => 'Sleep Issues';

  @override
  String get categoryBabyFood => 'Детское питание';

  @override
  String get categoryDevelopment => 'Развитие';

  @override
  String get categoryVaccination => 'Вакцинация';

  @override
  String get categoryPostpartum => 'Послеродовой период';

  @override
  String get sortByLikes => 'Сортировать по лайкам';

  @override
  String get sortByLatest => 'Сортировать по новизне';

  @override
  String get edited => '(отредактировано)';

  @override
  String commentsCount(Object count) {
    return '$count комментариев';
  }

  @override
  String get deletePost => 'Удалить пост';

  @override
  String get deletePostConfirm =>
      'Вы уверены, что хотите удалить этот пост?\\nУдалённые посты нельзя восстановить.';

  @override
  String get deletePostSuccess => 'Пост удалён.';

  @override
  String deletePostError(Object error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get postNotFound => 'Пост не найден';

  @override
  String get shareFeatureComingSoon => 'Функция публикации скоро';

  @override
  String get loadingComments => 'Загрузка комментариев...';

  @override
  String get loadMoreComments => 'Загрузить больше комментариев';

  @override
  String get editComment => 'Редактировать комментарий';

  @override
  String get editCommentHint => 'Редактируйте ваш комментарий...';

  @override
  String get editCommentSuccess => 'Комментарий обновлён.';

  @override
  String editCommentError(Object error) {
    return 'Ошибка редактирования: $error';
  }

  @override
  String get deleteComment => 'Удалить комментарий';

  @override
  String get deleteCommentConfirm =>
      'Вы уверены, что хотите удалить этот комментарий?\\nУдалённые комментарии нельзя восстановить.';

  @override
  String get deleteCommentSuccess => 'Комментарий удалён.';

  @override
  String get replySuccess => 'Ответ опубликован.';

  @override
  String get commentSuccess => 'Комментарий опубликован.';

  @override
  String get commentError => 'Ошибка публикации комментария.';

  @override
  String get titlePlaceholder => 'Введите заголовок';

  @override
  String get contentPlaceholder =>
      'Поделитесь своими мыслями...\\n\\nПишите свободно о своём родительском опыте.';

  @override
  String imageSelectionError(Object error) {
    return 'Ошибка выбора изображения: $error';
  }

  @override
  String get userNotFoundError => 'Информация пользователя не найдена.';

  @override
  String get postCreateSuccess => 'Пост успешно создан!';

  @override
  String postCreateError(Object error) {
    return 'Ошибка создания поста: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'Заголовок: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'Изображения: $count/5';
  }

  @override
  String get addImageTooltip => 'Добавить изображение';

  @override
  String get allPostsChecked => 'Все посты проверены! 👍';

  @override
  String get waitForNewPosts => 'Ждите новые посты';

  @override
  String get noPostsYet => 'Пока нет постов';

  @override
  String get writeFirstPost => 'Напишите первый пост!';

  @override
  String get loadingNewPosts => 'Загрузка новых постов...';

  @override
  String get failedToLoadPosts => 'Ошибка загрузки постов';

  @override
  String get checkNetworkAndRetry => 'Проверьте соединение и попробуйте снова';

  @override
  String get categoryDailyLife => 'Повседневная жизнь';

  @override
  String get preparingTimeline => 'Подготовка временной шкалы...';

  @override
  String get noRecordedMoments => 'Пока нет записанных моментов';

  @override
  String get loadingTimeline => 'Загрузка временной шкалы...';

  @override
  String get noRecordsYet => 'Пока нет записей';

  @override
  String noRecordsForDate(Object date) {
    return 'Нет записей для $date';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return 'Нет записей $filter для $date';
  }

  @override
  String get cannotRecordFuture => 'Пока нельзя записывать будущие активности';

  @override
  String get addFirstRecord => 'Добавьте вашу первую запись!';

  @override
  String get canAddPastRecord => 'Вы можете добавлять прошлые записи';

  @override
  String get addRecord => 'Добавить запись';

  @override
  String get viewOtherDates => 'Посмотреть другие даты';

  @override
  String get goToToday => 'Перейти к сегодня';

  @override
  String get quickRecordFromHome =>
      'Вы можете быстро добавлять записи с главного экрана';

  @override
  String detailViewComingSoon(String title) {
    return 'Детали $title (Скоро)';
  }

  @override
  String get familyInvitationDescription =>
      'Управляйте записями ухода за ребёнком вместе с семьёй через коды приглашений';

  @override
  String get babyManagement => 'Управление ребёнком';

  @override
  String get addBaby => 'Добавить ребенка';

  @override
  String get noBabiesMessage =>
      'Дети не зарегистрированы.\\nПожалуйста, добавьте ребёнка.';

  @override
  String get switchToNextBaby => 'Переключиться на следующего ребёнка';

  @override
  String get birthDate => 'Дата рождения';

  @override
  String get registering => 'Регистрация...';

  @override
  String get register => 'Зарегистрировать';

  @override
  String careTogetherWith(String name) {
    return 'Ухаживать за ребёнком вместе с $name';
  }

  @override
  String get inviteFamilyDescription =>
      'Пригласите семью или партнёра\\nдля совместного управления записями ухода за ребёнком';

  @override
  String get generateInviteCode => 'Создать код приглашения';

  @override
  String get generateInviteCodeDescription =>
      'Создать новый код приглашения и скопировать';

  @override
  String get generateInviteCodeButton => 'Создать код приглашения';

  @override
  String get orText => 'Или';

  @override
  String get enterInviteCodeDescription => 'Введите полученный код приглашения';

  @override
  String get inviteCodePlaceholder => 'Код приглашения (6 цифр)';

  @override
  String get acceptInvite => 'Принять приглашение';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name успешно зарегистрирован';
  }

  @override
  String get babyRegistrationFailed => 'Ошибка регистрации ребёнка';

  @override
  String babyRegistrationError(String error) {
    return 'Произошла ошибка: $error';
  }

  @override
  String babySelected(String name) {
    return '$name выбран';
  }

  @override
  String get inviteCodeGenerated => 'Код приглашения создан!';

  @override
  String remainingTime(String time) {
    return 'Оставшееся время: $time';
  }

  @override
  String get validTime => 'Время действия: 5 минут';

  @override
  String get generating => 'Создание...';

  @override
  String get joining => 'Присоединение...';

  @override
  String get noBabyInfo => 'Нет информации о ребёнке';

  @override
  String get noBabyInfoDescription =>
      'Информация о ребёнке не найдена.\\nХотите создать тестового ребёнка?';

  @override
  String get create => 'Создать';

  @override
  String get generateNewInviteCode => 'Создать новый код приглашения';

  @override
  String get replaceExistingCode =>
      'Это заменит существующий код приглашения.\\nХотите продолжить?';

  @override
  String get acceptInvitation => 'Принять приглашение';

  @override
  String get acceptInvitationDescription =>
      'Хотите принять приглашение и присоединиться к семье?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'Существующие записи ребёнка будут удалены и заменены приглашённым ребёнком ($babyName).\\n\\nХотите продолжить?';
  }

  @override
  String get pleaseEnterInviteCode => 'Введите код приглашения';

  @override
  String get inviteCodeMustBe6Digits =>
      'Код приглашения должен содержать 6 цифр';

  @override
  String get pleaseLoginFirst =>
      'Информация для входа не найдена. Сначала войдите в систему.';

  @override
  String get copiedToClipboard => 'Код приглашения скопирован!';

  @override
  String get joinedSuccessfully => 'Успешно присоединились к семье!';

  @override
  String get inviteCodeExpired => 'Срок действия кода приглашения истёк';

  @override
  String get invalidInviteCode => 'Неверный код приглашения';

  @override
  String get alreadyMember => 'Вы уже член этой семьи';

  @override
  String get cannotInviteSelf => 'Вы не можете пригласить самого себя';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutesмин $secondsсек';
  }

  @override
  String babyGuideTitle(String name) {
    return 'Руководство по уходу за $name';
  }

  @override
  String get babyGuide => 'Детское руководство';

  @override
  String get noAvailableGuides => 'Нет доступных руководств';

  @override
  String get current => 'Текущий';

  @override
  String get past => 'Прошедший';

  @override
  String get upcoming => 'Предстоящий';

  @override
  String babysGuide(String name) {
    return '$name';
  }

  @override
  String weekGuide(String weekText) {
    return 'Руководство $weekText';
  }

  @override
  String get feedingGuide => '💡 Руководство по кормлению';

  @override
  String get feedingFrequency => 'Частота кормления';

  @override
  String get singleFeedingAmount => 'Количество за одно кормление';

  @override
  String get dailyTotal => 'Общее количество в день';

  @override
  String get additionalTips => '📋 Дополнительные советы';

  @override
  String get understood => 'Понятно!';

  @override
  String get newborn => 'Новорождённый';

  @override
  String weekNumber(int number) {
    return 'Неделя $number';
  }

  @override
  String get newbornWeek0 => 'Новорождённый (Неделя 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'Ежедневно $min - $max раз';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'Ежедневно $min+ раз';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'Ежедневно до $max раз';
  }

  @override
  String amountRangeML(int min, int max) {
    return '$minмл - $maxмл';
  }

  @override
  String amountMinML(int min) {
    return '$minмл или больше';
  }

  @override
  String amountMaxML(int max) {
    return 'До $maxмл';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'Выбор языка';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get currentLanguage => 'Текущий язык';

  @override
  String get searchCommunityPosts => 'Поиск публикаций сообщества';

  @override
  String get temperatureRecord => 'Запись температуры';

  @override
  String get temperatureTrend => 'Тренд Температуры';

  @override
  String get profilePhotoSetup => 'Настройка фото профиля';

  @override
  String get howToSelectPhoto => 'Как вы хотите выбрать фото?';

  @override
  String get send => 'Отправить';

  @override
  String get emailVerificationRequired => 'Требуется подтверждение email';

  @override
  String get passwordReset => 'Сброс пароля';

  @override
  String get enterEmailForReset =>
      'Введите ваш зарегистрированный email-адрес.\nМы отправим вам ссылку для сброса пароля.';

  @override
  String get accountWithdrawalComplete => 'Удаление аккаунта завершено';

  @override
  String get genderLabel => 'Пол: ';

  @override
  String get birthdateLabel => 'Дата рождения: ';

  @override
  String get maleGender => 'Мужской';

  @override
  String get femaleGender => 'Женский';

  @override
  String get joinWithInviteCodeButton => 'Присоединиться по коду приглашения';

  @override
  String get temperatureRecorded => 'Температура записана';

  @override
  String recordFailed(String error) {
    return 'Ошибка записи';
  }

  @override
  String get temperatureSettingsSaved => 'Настройки температуры сохранены';

  @override
  String get loadingUserInfo =>
      'Загрузка информации о пользователе. Пожалуйста, попробуйте ещё раз через момент.';

  @override
  String get continueWithSeparateAccount => 'Продолжить с отдельным аккаунтом';

  @override
  String get linkWithExistingAccount => 'Связать с существующим аккаунтом';

  @override
  String get linkAccount => 'Связать аккаунт';

  @override
  String get accountLinkingComplete => 'Связывание аккаунта завершено';

  @override
  String get deleteConfirmation => 'Подтверждение удаления';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get babyNameLabel => 'Имя ребенка';

  @override
  String get weightInput => 'Ввести вес';

  @override
  String get heightInput => 'Ввести рост';

  @override
  String get measurementNotes =>
      'Записать условия измерения или особые заметки (необязательно)';

  @override
  String get urine => 'Моча';

  @override
  String get stool => 'Стул';

  @override
  String get yellow => 'Желтый';

  @override
  String get brown => 'Коричневый';

  @override
  String get green => 'Зеленый';

  @override
  String get bottle => 'Бутылочка';

  @override
  String get good => 'Хорошо';

  @override
  String get average => 'Среднее';

  @override
  String get poor => 'Плохо';

  @override
  String get vaccination => 'Вакцинация';

  @override
  String get illness => 'Болезнь';

  @override
  String get highFever => 'Высокая Лихорадка';

  @override
  String get oral => 'Оральный';

  @override
  String get inhalation => 'Ингаляция';

  @override
  String get injection => 'Инъекция';

  @override
  String get tablet => 'Таблетка';

  @override
  String get drops => 'Капли';

  @override
  String get teaspoon => 'Чайная ложка';

  @override
  String get tablespoon => 'Столовая ложка';

  @override
  String get sleepQuality => 'Качество';

  @override
  String get pumpingTime => 'Сцеживание';

  @override
  String get solidFoodTime => 'Твердая пища';

  @override
  String get totalFeedingAmount => 'Общее количество кормления';

  @override
  String get averageFeedingAmount => 'Среднее количество кормления';

  @override
  String get dailyAverageFeedingCount => 'Дневное среднее количество кормлений';

  @override
  String get clinical => 'Клинический';

  @override
  String get infoSharing => 'Обмен информацией';

  @override
  String get sleepIssues => 'Проблемы со сном';

  @override
  String get babyFoodCategory => 'Детское питание';

  @override
  String get developmentStage => 'Стадия развития';

  @override
  String get vaccinationCategory => 'Вакцинация';

  @override
  String get postpartumRecovery => 'Послеродовое восстановление';

  @override
  String get dailyLife => 'Повседневная жизнь';

  @override
  String get likes => 'Лайки';

  @override
  String get comments => 'Комментарии';

  @override
  String get anonymous => 'Анонимно';

  @override
  String get minutes => 'мин';

  @override
  String get armpit => 'Подмышка';

  @override
  String get forehead => 'Лоб';

  @override
  String get ear => 'Ухо';

  @override
  String get mouth => 'Рот';

  @override
  String get rectal => 'Ректально';

  @override
  String get otherLocation => 'Другое';

  @override
  String get searchError => 'Ошибка поиска';

  @override
  String get question => 'Вопрос';

  @override
  String get information => 'Информация';

  @override
  String get relevance => 'Релевантность';

  @override
  String get searchSuggestions => 'Предложения поиска';

  @override
  String get noSearchResults => 'Нет результатов поиска';

  @override
  String get tryDifferentSearchTerm => 'Попробуйте другой поисковый запрос';

  @override
  String get likeFeatureComingSoon => 'Функция лайков скоро';

  @override
  String get popularSearchTerms => 'Популярные поисковые запросы';

  @override
  String get recentSearches => 'Недавние поиски';

  @override
  String get deleteAll => 'Удалить все';

  @override
  String get sortByComments => 'Сортировать по комментариям';

  @override
  String get detailInformation => 'Детальная Информация';

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
  String get amount => 'Количество';

  @override
  String get duration => 'Продолжительность';

  @override
  String get dosage => 'Dosage';

  @override
  String get unit => 'Unit';

  @override
  String get side => 'Сторона';

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
  String get smartInsights => 'Умные Выводы';

  @override
  String get analyzingPatterns => 'Анализ закономерностей...';

  @override
  String insightsFound(int count) {
    return '$count выводов найдено';
  }

  @override
  String get noInsightsYet => 'Not enough data to analyze patterns yet';

  @override
  String get confidence => 'Уверенность';

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
    return '$hoursч $minutesм';
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
  String get longPressForDetails => 'Длительное нажатие для подробностей';

  @override
  String get todaysSummary => 'Сводка за сегодня';

  @override
  String get future => 'Будущее';

  @override
  String get previousDate => 'Предыдущая дата';

  @override
  String get nextDate => 'Следующая дата';

  @override
  String get selectDate => 'Выбрать дату';

  @override
  String get checkStandardFeedingInterval => 'Check standard feeding interval';

  @override
  String get registerBabyFirst =>
      'Пожалуйста, сначала зарегистрируйте вашего ребёнка';

  @override
  String get registerBabyToRecordMoments =>
      'Чтобы записывать драгоценные моменты вашего ребёнка,\nпожалуйста, сначала зарегистрируйте информацию о ребёнке.';

  @override
  String get addBabyFromHome => 'Добавить ребёнка с главного экрана';

  @override
  String get timesUnit => 'раз';

  @override
  String get itemsUnit => 'элементов';

  @override
  String get timesPerDay => 'раз/день';

  @override
  String get activityDistributionByCategory =>
      'Распределение активности по категориям';

  @override
  String itemsCount(int count) {
    return '$count элементов';
  }

  @override
  String get totalCount => 'Общее количество';

  @override
  String timesCount(int count) {
    return '$count раз';
  }

  @override
  String get noDetailedData => 'Нет подробных данных';

  @override
  String get averageFeedingTime => 'Среднее время кормления';

  @override
  String get averageSleepTime => 'Среднее время сна';

  @override
  String get dailyAverageTotalSleepTime => 'Дневное среднее общее время сна';

  @override
  String get dailyAverageSleepCount => 'Дневное среднее количество снов';

  @override
  String get dailyAverageChangeCount => 'Дневное среднее количество смен';

  @override
  String get sharingParentingStories => 'Обмен родительскими историями';

  @override
  String get myActivity => 'Моя активность';

  @override
  String get categories => 'Категории';

  @override
  String get menu => 'Меню';

  @override
  String get seeMore => 'Посмотреть ещё';

  @override
  String get midnight => 'Полночь';

  @override
  String get morning => 'Утро';

  @override
  String get noon => 'Полдень';

  @override
  String get afternoon => 'Вечер';

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
    return 'Запись температуры $name';
  }

  @override
  String get adjustWithSlider => 'Настроить с помощью ползунка';

  @override
  String get measurementMethod => 'Метод измерения';

  @override
  String get normalRange => 'Нормальный диапазон';

  @override
  String normalRangeForAgeGroup(String ageGroup, String min, String max) {
    return 'Нормальный диапазон ($ageGroup): $min°C - $max°C';
  }

  @override
  String get saveTemperatureRecord => 'Сохранить запись температуры';

  @override
  String get enterTemperature => 'Пожалуйста, введите температуру';

  @override
  String get temperatureRangeValidation =>
      'Температура должна быть в диапазоне 34,0°C ~ 42,0°C';

  @override
  String get recordSymptomsHint =>
      'Пожалуйста, запишите симптомы или особые заметки';

  @override
  String get oralMethod => 'Оральный';

  @override
  String get analMethod => 'Анальный';

  @override
  String recentDaysTrend(int days) {
    return 'Тренд за последние $days дней';
  }

  @override
  String get days3 => '3 дня';

  @override
  String get days7 => '7 дней';

  @override
  String get weeks2 => '2 недели';

  @override
  String get month1 => '1 месяц';

  @override
  String get noTemperatureRecordsInPeriod =>
      'Нет записей температуры за выбранный период';

  @override
  String get temperatureChangeTrend => 'Тренд Изменения Температуры';

  @override
  String get averageTemperature => 'Средняя Температура';

  @override
  String get highestTemperature => 'Самая Высокая Температура';

  @override
  String get lowestTemperature => 'Самая Низкая Температура';

  @override
  String get noteAvailableTapToView =>
      '📝 Заметка доступна (нажмите для просмотра)';

  @override
  String get temperatureRisingTrend =>
      'Температура показывает восходящий тренд';

  @override
  String get temperatureFallingTrend =>
      'Температура показывает нисходящий тренд';

  @override
  String get temperatureStableTrend => 'Температура стабильна';

  @override
  String get trendAnalysis => 'Анализ Тренда';

  @override
  String totalMeasurements(int count) {
    return 'Всего $count измерений';
  }

  @override
  String get temperatureRecordMemo => 'Заметка Записи Температуры';

  @override
  String babyGrowthChart(String name) {
    return 'График Роста $name';
  }

  @override
  String get noGrowthRecords => 'Нет записей роста';

  @override
  String get enterWeightAndHeightFromHome =>
      'Пожалуйста, введите вес и рост с главного экрана';

  @override
  String get all => 'Все';

  @override
  String get growthInsights => 'Анализ Роста';

  @override
  String get growthRate => 'Темп Роста';

  @override
  String get monthlyAverageGrowth => 'Средний Месячный Рост';

  @override
  String get dataInsufficient => 'Недостаточно Данных';

  @override
  String get twoOrMoreRequired => 'Требуется 2 или больше';

  @override
  String recentDaysBasis(int days) {
    return 'На основе последних $days дней';
  }

  @override
  String get entireBasis => 'На основе всего периода';

  @override
  String get oneMonthPrediction => 'Прогноз на 1 Месяц';

  @override
  String get currentTrendBasis => 'На основе текущей тенденции';

  @override
  String get predictionNotPossible => 'Прогноз невозможен';

  @override
  String get trendInsufficient => 'Недостаточная тенденция';

  @override
  String get recordFrequency => 'Частота Записей';

  @override
  String get veryConsistent => 'Очень Стабильно';

  @override
  String get consistent => 'Стабильно';

  @override
  String get irregular => 'Нерегулярно';

  @override
  String averageDaysInterval(String days) {
    return 'Средний интервал $days дней';
  }

  @override
  String get nextRecord => 'Следующая Запись';

  @override
  String get now => 'Сейчас';

  @override
  String get soon => 'Скоро';

  @override
  String daysLater(int days) {
    return 'через $days дней';
  }

  @override
  String daysAgoRecorded(int days) {
    return 'Записано $days дней назад';
  }

  @override
  String get weeklyRecordRecommended => 'Рекомендуется еженедельная запись';

  @override
  String get nextMilestone => 'Следующая Веха';

  @override
  String targetValue(String value, String unit) {
    return 'Цель $value$unit';
  }

  @override
  String remainingProgress(String remaining, String unit, String progress) {
    return 'Осталось $remaining$unit ($progress% достигнуто)';
  }

  @override
  String get calculationNotPossible => 'Расчет невозможен';

  @override
  String get periodInsufficient => 'Недостаточный период';

  @override
  String get noDataAvailable => 'Нет доступных данных';

  @override
  String get weightRecordRequired => 'Требуется запись веса';

  @override
  String get heightRecordRequired => 'Требуется запись роста';

  @override
  String get currentRecordMissing => 'Текущая запись отсутствует';

  @override
  String get noRecord => 'Нет записи';

  @override
  String get firstRecordStart => 'Начать первую запись';

  @override
  String get oneRecord => '1 запись';

  @override
  String get moreRecordsNeeded => 'Требуется больше записей';

  @override
  String get sameDayRecord => 'Запись в тот же день';

  @override
  String recordedTimes(int count) {
    return 'Записано $count раз';
  }

  @override
  String get storageMethod => 'Способ хранения';

  @override
  String get pumpingType => 'Тип сцеживания';

  @override
  String get foodName => 'Название продукта';

  @override
  String get mealType => 'Тип приема пищи';

  @override
  String get texture => 'Текстура';

  @override
  String get reaction => 'Реакция';

  @override
  String get measurementLocation => 'Место измерения';

  @override
  String get feverReducerGiven => 'Жаропонижающее дано';

  @override
  String get given => 'Дано';

  @override
  String get hours => 'часов';

  @override
  String get refrigerator => 'Холодильник';

  @override
  String get freezer => 'Морозилка';

  @override
  String get roomTemperature => 'Комнатная температура';

  @override
  String get fedImmediately => 'Накормлен сразу';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get snack => 'Перекус';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get on => 'Вкл';

  @override
  String get off => 'Выкл';

  @override
  String get weightChange => 'Изменение Веса';

  @override
  String get heightChange => 'Изменение Роста';

  @override
  String get totalRecords => 'Общее Количество Записей';

  @override
  String get totalChange => 'Общее Изменение';

  @override
  String get start => 'Начало';

  @override
  String get memo => 'Заметка';

  @override
  String get weightDataEmpty => 'Нет данных о весе';

  @override
  String get heightDataEmpty => 'Нет данных о росте';

  @override
  String get undoAction => 'Отменить';

  @override
  String get feedingRecordDeleted => 'Запись кормления удалена';

  @override
  String get sleepRecordDeleted => 'Запись сна удалена';

  @override
  String get diaperRecordDeleted => 'Запись подгузника удалена';

  @override
  String get healthRecordDeleted => 'Запись здоровья удалена';

  @override
  String get deletionError => 'Произошла ошибка при удалении';

  @override
  String get duplicateInputDetected => 'Обнаружен дублированный ввод';

  @override
  String get solidFoodDuplicateConfirm =>
      'Вы только что записали твердую пищу.\\nДействительно хотите записать ещё раз?';

  @override
  String get cannotOpenSettings => 'Не удается открыть экран настроек';

  @override
  String get sleepQualityGood => 'Хороший';

  @override
  String get sleepQualityFair => 'Нормальный';

  @override
  String get sleepQualityPoor => 'Плохой';

  @override
  String sleepInProgressDuration(Object minutes) {
    return 'Спит - $minutesм прошло';
  }

  @override
  String get wetOnly => 'Только Мокрый';

  @override
  String get dirtyOnly => 'Только Грязный';

  @override
  String get wetAndDirty => 'Мокрый + Грязный';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get consistencyLabel => 'Консистенция';

  @override
  String get topicalMedication => 'Наружное';

  @override
  String get inhaledMedication => 'Ингаляционное';

  @override
  String get milkPumpingInProgress => 'Сцеживание';

  @override
  String pumpingInProgressDuration(Object minutes) {
    return 'Сцеживание - $minutesм прошло';
  }

  @override
  String get lowGradeFever => 'Легкая Лихорадка';

  @override
  String get normalTemperature => 'Нормальная';

  @override
  String get allActivities => 'Все';

  @override
  String get temperatureFilter => 'Температура';

  @override
  String get deleteRecordTitle => 'Удалить запись';

  @override
  String get deleteRecordMessage =>
      'Вы уверены, что хотите удалить эту запись?\nУдаленные записи не могут быть восстановлены.';

  @override
  String get recordDeletedSuccess => 'Запись была удалена';

  @override
  String get recordDeleteFailed => 'Не удалось удалить запись';

  @override
  String get recordDeleteError => 'Произошла ошибка при удалении записи';

  @override
  String get recordUpdatedSuccess => 'Запись была обновлена';

  @override
  String get recordUpdateFailed => 'Не удалось обновить запись';

  @override
  String get recordUpdateError => 'Произошла ошибка при обновлении записи';

  @override
  String noRecordsToday(Object recordType) {
    return 'Сегодня нет записей $recordType';
  }

  @override
  String get healthRecordRestored => 'Медицинские записи восстановлены';

  @override
  String get deleteTemperatureConfirm =>
      'Хотите удалить недавнюю запись температуры?';

  @override
  String get minimum => 'Минимум';

  @override
  String get maximum => 'Максимум';

  @override
  String get duplicateEntryDetected => 'Обнаружена дублированная запись';

  @override
  String get feedingDuplicateConfirm =>
      'Вы только что добавили запись о кормлении.\\nДействительно хотите записать снова?';

  @override
  String get milkPumpingDuplicateConfirm =>
      'Вы только что добавили запись о сцеживании молока.\\nДействительно хотите записать снова?';

  @override
  String get medicationDuplicateConfirm =>
      'Вы только что записали лекарство.\\nДействительно хотите записать снова?';

  @override
  String get diaperDuplicateConfirm =>
      'Вы только что записали смену подгузника.\\nДействительно хотите записать снова?';

  @override
  String get sleepStartDuplicateConfirm =>
      'Вы только что управляли сном.\\nДействительно хотите начать сон?';

  @override
  String get sleepEndDuplicateConfirm =>
      'Вы только что управляли сном.\\nДействительно хотите закончить сон?';

  @override
  String get recordAction => 'Записать';

  @override
  String get end => 'Конец';

  @override
  String get minutesShort => 'м';
}
