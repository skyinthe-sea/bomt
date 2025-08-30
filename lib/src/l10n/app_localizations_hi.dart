// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get user => 'उपयोगकर्ता';

  @override
  String userInfoLoadFailed(String error) {
    return 'उपयोगकर्ता जानकारी लोड करने में विफल: $error';
  }

  @override
  String babyListLoadError(String error) {
    return 'बच्चों की सूची लोड करते समय त्रुटि हुई: $error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return '$userName जी';
  }

  @override
  String get registerBaby => 'बच्चा पंजीकरण';

  @override
  String get noBabiesRegistered => 'कोई बच्चा पंजीकृत नहीं है';

  @override
  String get registerFirstBaby => 'अपना पहला बच्चा पंजीकृत करें!';

  @override
  String get registerBabyButton => 'बच्चा पंजीकृत करें';

  @override
  String birthday(int year, int month, int day) {
    return 'जन्मदिन: $day/$month/$year';
  }

  @override
  String age(int days) {
    return 'आयु: $days दिन';
  }

  @override
  String gender(String gender) {
    return 'लिंग';
  }

  @override
  String get male => 'लड़का';

  @override
  String get female => 'लड़की';

  @override
  String get other => 'अन्य';

  @override
  String babyDetailScreen(String name) {
    return '$name विवरण स्क्रीन (जल्द आ रहा है)';
  }

  @override
  String get selectBirthdate => 'कृपया जन्मतिथि चुनें';

  @override
  String babyRegistered(String name) {
    return '$name सफलतापूर्वक पंजीकृत हो गया है!';
  }

  @override
  String registrationError(String error) {
    return 'पंजीकरण के दौरान त्रुटि हुई: $error';
  }

  @override
  String get enterBabyInfo => 'कृपया बच्चे की जानकारी दर्ज करें';

  @override
  String get babyName => 'बच्चे का नाम';

  @override
  String get babyNameHint => 'उदाहरण: राहुल';

  @override
  String get babyNameRequired => 'कृपया बच्चे का नाम दर्ज करें';

  @override
  String get babyNameMinLength => 'नाम कम से कम 2 अक्षर का होना चाहिए';

  @override
  String get selectBirthdateButton => 'जन्मतिथि चुनें';

  @override
  String selectedDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String get genderOptional => 'लिंग (वैकल्पिक)';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get loginFailed => 'लॉगिन विफल';

  @override
  String loginError(String error) {
    return 'लॉगिन के दौरान त्रुटि हुई: $error';
  }

  @override
  String get appTagline =>
      'अपने बच्चे के विकास रिकॉर्ड को आसानी से प्रबंधित करें';

  @override
  String get termsNotice =>
      'लॉगिन करके, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत हैं';

  @override
  String get loginWithKakao => 'Kakao से लॉगिन करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get selectBirthDate => 'जन्मतिथि चुनें';

  @override
  String get pleasSelectBirthDate => 'कृपया जन्मतिथि चुनें';

  @override
  String get pleaseEnterBabyName => 'कृपया बच्चे का नाम दर्ज करें';

  @override
  String get nameMinLength => 'नाम कम से कम 2 अक्षर का होना चाहिए';

  @override
  String dateFormat(String year, String month, String day) {
    return '$day/$month/$year';
  }

  @override
  String get autoLogin => 'स्वचालित लॉगिन';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get logoutConfirm => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get appearance => 'दिखावट';

  @override
  String get home => 'होम';

  @override
  String get timeline => 'टाइमलाइन';

  @override
  String get record => 'रिकॉर्ड';

  @override
  String get statistics => 'आंकड़े';

  @override
  String get community => 'समुदाय';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get timelineUpdateMessage => 'टाइमलाइन सुविधा जल्द ही अपडेट होगी';

  @override
  String get recordUpdateMessage => 'रिकॉर्ड सुविधा जल्द ही अपडेट होगी';

  @override
  String get statisticsUpdateMessage => 'आंकड़े सुविधा जल्द ही अपडेट होगी';

  @override
  String get communityUpdateMessage => 'समुदाय सुविधा जल्द ही अपडेट होगी';

  @override
  String get todaySummary => 'आज का सारांश';

  @override
  String get growthInfo => 'विकास जानकारी';

  @override
  String get lastFeeding => 'आखिरी बार दूध पिलाना';

  @override
  String get healthy => 'स्वस्थ';

  @override
  String get feeding => 'दूध पिलाना';

  @override
  String get totalFeeding => 'कुल दूध की मात्रा';

  @override
  String get sleep => 'नींद';

  @override
  String get totalSleepTime => 'कुल नींद का समय';

  @override
  String get cardSettings => 'कार्ड सेटिंग्स';

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
  String get save => 'सेव करें';

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
  String get exit => 'बाहर निकलें';

  @override
  String get diaper => 'डायपर';

  @override
  String get solidFood => 'ठोस आहार';

  @override
  String get medication => 'दवा';

  @override
  String get milkPumping => 'दूध निकालना';

  @override
  String get temperature => 'तापमान';

  @override
  String get growth => 'विकास';

  @override
  String get health => 'स्वास्थ्य';

  @override
  String feedingCount(Object count) {
    return '$count times';
  }

  @override
  String get feedingAmount => 'फीडिंग मात्रा';

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
  String get weight => 'वजन';

  @override
  String get height => 'लंबाई';

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
  String get communityTitle => 'समुदाय';

  @override
  String get writePost => 'पोस्ट लिखें';

  @override
  String get post => 'पोस्ट';

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
  String get selectCategory => 'कैटेगरी चुनें';

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
    return 'सामग्री: $count/10000';
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
  String get liveQA => '🔥 बाल रोग विशेषज्ञ लाइव Q&A';

  @override
  String get liveQADescription =>
      'आज शाम 7 बजे! सभी प्रश्नों का जवाब देंगे विशेषज्ञ';

  @override
  String get likeOrder => 'Most Liked';

  @override
  String get latestOrder => 'Latest';

  @override
  String get userNotFound => 'User information not found';

  @override
  String get statisticsTitle => 'आंकड़े';

  @override
  String get noStatisticsData => 'कोई आंकड़े उपलब्ध नहीं';

  @override
  String statisticsDescription(Object period) {
    return 'No activities recorded during $period.\nStart recording your baby\'s activities!';
  }

  @override
  String get recordActivity => 'गतिविधि रिकॉर्ड करें';

  @override
  String get viewOtherPeriod => 'अन्य अवधि देखें';

  @override
  String get refresh => 'रीफ्रेश';

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
  String get saveAsImage => 'छवि के रूप में सहेजें';

  @override
  String get saveAsImageDescription => 'Save statistics as image';

  @override
  String get shareAsText => 'टेक्स्ट के रूप में साझा करें';

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
  String get familyInvitation => 'पारिवारिक निमंत्रण';

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
  String get ok => 'ठीक है';

  @override
  String get edit => 'संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get add => 'जोड़ें';

  @override
  String get remove => 'हटाएं';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get done => 'पूर्ण';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String get warning => 'चेतावनी';

  @override
  String get info => 'जानकारी';

  @override
  String errorOccurred(Object error) {
    return 'त्रुटि हुई: $error';
  }

  @override
  String get networkError => 'नेटवर्क कनेक्शन त्रुटि';

  @override
  String get serverError => 'सर्वर त्रुटि हुई';

  @override
  String get validationError => 'कृपया अपना इनपुट जांचें';

  @override
  String get requiredField => 'यह फील्ड आवश्यक है';

  @override
  String get invalidInput => 'अमान्य इनपुट';

  @override
  String get saveFailed => 'सेव करने में विफल';

  @override
  String get loadFailed => 'लोड करने में विफल';

  @override
  String get updateFailed => 'अपडेट करने में विफल';

  @override
  String get deleteFailed => 'हटाने में विफल';

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
    return '$minutesमिनट';
  }

  @override
  String durationHours(Object hours) {
    return '$hoursघंटे';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hoursघंटे $minutesमिनट';
  }

  @override
  String daysAgo(Object days) {
    return '$days दिन पहले';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours घंटे पहले';
  }

  @override
  String minutesAgo(Object minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String get justNow => 'अभी';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get medicationName => 'दवा का नाम';

  @override
  String get medicationDose => 'खुराक';

  @override
  String get medicationTime => 'दवा';

  @override
  String get medicationAdded => 'दवा रिकॉर्ड जोड़ा गया';

  @override
  String get solidFoodType => 'भोजन का प्रकार';

  @override
  String solidFoodAmount(Object amount) {
    return 'मात्रा';
  }

  @override
  String get solidFoodAdded => 'ठोस आहार रिकॉर्ड जोड़ा गया';

  @override
  String get milkPumpingAmount => 'दूध की मात्रा';

  @override
  String get milkPumpingTime => 'समय';

  @override
  String get milkPumpingAdded => 'दूध निकालने का रिकॉर्ड जोड़ा गया';

  @override
  String get temperatureReading => 'तापमान रीडिंग';

  @override
  String get temperatureNormal => 'सामान्य';

  @override
  String get temperatureHigh => 'उच्च';

  @override
  String get temperatureLow => 'कम';

  @override
  String get profilePhoto => 'प्रोफाइल फोटो';

  @override
  String get profilePhotoUpdate => 'प्रोफाइल फोटो अपडेट करें';

  @override
  String get selectPhotoSource => 'आप फोटो कैसे चुनना चाहते हैं?';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get photoUpdated => 'प्रोफाइल फोटो अपडेट की गई';

  @override
  String get photoUploadFailed => 'प्रोफाइल फोटो अपडेट विफल';

  @override
  String get photoUploading => 'फोटो अपलोड हो रही है...';

  @override
  String get cameraNotAvailable =>
      'Camera not available on iOS simulator.\nPlease try from gallery.';

  @override
  String get cameraAccessError =>
      'Camera access error occurred.\nPlease try from gallery.';

  @override
  String get addImage => 'इमेज जोड़ें';

  @override
  String get removeImage => 'इमेज हटाएं';

  @override
  String maxImagesReached(Object count) {
    return 'अधिकतम $count छवियों की अनुमति है';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$months महीने $days दिन';
  }

  @override
  String get lastFeedingTime => 'अंतिम दूध पिलाने का समय';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours घंटे $minutes मिनट पहले';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return 'लगभग $hours घंटे $minutes मिनट बाद दूध पिलाना';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return 'लगभग $minutes मिनट बाद दूध पिलाना';
  }

  @override
  String get feedingTimeNow => 'अभी दूध पिलाने का समय है 🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'जल्द ही दूध पिलाने का समय ($minutes मिनट बाद)';
  }

  @override
  String get feedingTimeOverdue => 'दूध पिलाने का समय बीत गया';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return '$hours घंटे $minutes मिनट बाद दूध पिलाने का अलार्म';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return '$minutes मिनट बाद दूध पिलाने का अलार्म';
  }

  @override
  String get times => 'बार';

  @override
  String get meals => 'बार';

  @override
  String get kilograms => 'किग्रा';

  @override
  String get centimeters => 'सेमी';

  @override
  String get milliliters => 'मिली';

  @override
  String get grams => 'ग्राम';

  @override
  String get hoursUnit => 'घंटे';

  @override
  String get minutesUnit => 'मिनट';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get firstRecord => 'पहला रिकॉर्ड';

  @override
  String get noChange => 'कोई बदलाव नहीं';

  @override
  String get inProgress => 'चल रहा है';

  @override
  String get scheduled => 'निर्धारित';

  @override
  String get startBabyRecording =>
      'अपना बच्चा पंजीकृत करें और ट्रैकिंग शुरू करें';

  @override
  String get registerBabyNow => 'बच्चा पंजीकृत करें';

  @override
  String get joinWithInviteCode => 'निमंत्रण कोड के साथ शामिल हों';

  @override
  String get loadingBabyInfo => 'बच्चे की जानकारी लोड हो रही है...';

  @override
  String get pleaseRegisterBaby => 'कृपया सेटिंग्स में बच्चा पंजीकृत करें';

  @override
  String get goToSettings => 'सेटिंग्स पर जाएं';

  @override
  String get profilePhotoUpdated => 'प्रोफाइल फोटो अपडेट की गई।';

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
  String get hourActivityPattern => '24 घंटे की गतिविधि पैटर्न';

  @override
  String get touchClockInstruction =>
      'समय के अनुसार गतिविधियों को देखने के लिए घड़ी को छूएं';

  @override
  String get touch => 'छूएं';

  @override
  String get noActivitiesInTimeframe => 'इस समय में कोई गतिविधि नहीं थी';

  @override
  String get activityPatternAnalysis => 'गतिविधि पैटर्न विश्लेषण';

  @override
  String get todaysStory => 'आज की कहानी';

  @override
  String preciousMoments(Object count) {
    return '$count मूल्यवान पल';
  }

  @override
  String get firstMomentMessage =>
      'अपना पहला मूल्यवान पल रिकॉर्ड करें।\nरोज के छोटे बदलाव मिलकर बड़े विकास बनते हैं।';

  @override
  String get pattern => 'पैटर्न';

  @override
  String get qualityGood => 'अच्छा';

  @override
  String get qualityExcellent => 'उत्कृष्ट';

  @override
  String get qualityFair => 'ठीक';

  @override
  String get qualityPoor => 'खराब';

  @override
  String get timeSlot => 'बजे का समयावधि';

  @override
  String get am => 'पूर्वाह्न';

  @override
  String get pm => 'अपराह्न';

  @override
  String get activityConcentrationTime => 'दिन में गतिविधियों के केंद्रित समय';

  @override
  String get formula => 'फॉर्मूला';

  @override
  String get breastMilk => 'स्तन का दूध';

  @override
  String get babyFood => 'बेबी फूड';

  @override
  String get left => 'बाएं';

  @override
  String get right => 'दाएं';

  @override
  String get both => 'दोनों';

  @override
  String get sleeping => 'सो रहा है';

  @override
  String get hoursText => 'घंटे';

  @override
  String get minutesText => 'मिनट';

  @override
  String get elapsed => 'बीता';

  @override
  String get urineOnly => 'केवल पेशाब';

  @override
  String get stoolOnly => 'केवल मल';

  @override
  String get urineAndStool => 'पेशाब + मल';

  @override
  String get color => 'रंग';

  @override
  String get consistency => 'स्थिरता';

  @override
  String get diaperChange => 'डायपर बदलना';

  @override
  String get oralMedication => 'मुंह की दवा';

  @override
  String get topical => 'बाहरी';

  @override
  String get inhaled => 'सांस';

  @override
  String get pumping => 'पंप कर रहा है';

  @override
  String get temperatureMeasurement => 'तापमान मापना';

  @override
  String get fever => 'बुखार';

  @override
  String get lowFever => 'हल्का बुखार';

  @override
  String get hypothermia => 'कम तापमान';

  @override
  String get normal => 'सामान्य';

  @override
  String get quality => 'गुणवत्ता';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get custom => 'कस्टम';

  @override
  String daysCount(Object count) {
    return '$count दिन';
  }

  @override
  String noActivitiesRecordedInPeriod(Object period) {
    return '$period अवधि के दौरान कोई गतिविधि रिकॉर्ड नहीं की गई।';
  }

  @override
  String get recordBabyActivities =>
      'अपने बच्चे की गतिविधियों को रिकॉर्ड करें!';

  @override
  String get howToViewStatistics => 'आंकड़े कैसे देखें?';

  @override
  String get recordActivitiesLikeFeedingSleep =>
      'दूध पिलाना, सोना, डायपर बदलना जैसी गतिविधियों को रिकॉर्ड करें';

  @override
  String get atLeastOneDayDataRequired =>
      'आंकड़े दिखाने के लिए कम से कम एक दिन का डेटा चाहिए';

  @override
  String get canRecordEasilyFromHome =>
      'आप होम स्क्रीन से आसानी से रिकॉर्ड कर सकते हैं';

  @override
  String get updating => 'अपडेट हो रहा है...';

  @override
  String get lastUpdated => 'अंतिम अपडेट:';

  @override
  String get periodSelection => 'अवधि चयन';

  @override
  String get daily => 'दैनिक';

  @override
  String get startDate => 'प्रारंभ तिथि';

  @override
  String get endDate => 'समाप्ति तिथि';

  @override
  String get apply => 'लागू करें';

  @override
  String get pleaseSelectDate => 'कृपया तारीख चुनें';

  @override
  String get detailedStatistics => 'विस्तृत आँकड़े';

  @override
  String get chartAnalysis => 'चार्ट विश्लेषण';

  @override
  String get overallActivityOverview => 'समग्र गतिविधि अवलोकन';

  @override
  String get totalActivities => 'कुल गतिविधियाँ';

  @override
  String get activeCards => 'सक्रिय कार्ड';

  @override
  String get dailyAverage => 'दैनिक औसत';

  @override
  String get activityDistributionByCard => 'कार्ड के अनुसार गतिविधि वितरण';

  @override
  String get cannotLoadData => 'डेटा लोड नहीं कर सकते';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get details => 'विवरण';

  @override
  String get goToHome => 'होम पर जाएं';

  @override
  String get troubleshootingMethods => 'समस्या निवारण तरीके';

  @override
  String get shareStatistics => 'आंकड़े साझा करें';

  @override
  String get communitySubtitle => 'मिलकर शेयर करें पेरेंटिंग की कहानियां';

  @override
  String get search => 'खोजें';

  @override
  String get notification => 'सूचना';

  @override
  String get searchFeatureComingSoon => 'खोज सुविधा जल्द आ रही';

  @override
  String get communityWelcome => '💕 Parenting Community';

  @override
  String get communityWelcomeDescription =>
      'अन्य माता-पिता के साथ पालन-पोषण के अनुभव और मूल्यवान जानकारी साझा करें';

  @override
  String get categorySelection => 'श्रेणी चयन';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryPopular => 'लोकप्रिय';

  @override
  String get categoryClinical => 'क्लिनिकल';

  @override
  String get categoryInfoSharing => 'जानकारी साझाकरण';

  @override
  String get categorySleepIssues => 'नींद की समस्याएं';

  @override
  String get categoryBabyFood => 'बेबी फूड';

  @override
  String get categoryDevelopment => 'विकास के चरण';

  @override
  String get categoryVaccination => 'टीकाकरण';

  @override
  String get categoryPostpartum => 'प्रसवोत्तर रिकवरी';

  @override
  String get sortByLikes => 'पसंदीदा क्रम';

  @override
  String get sortByLatest => 'नवीनतम क्रम';

  @override
  String get edited => '(संपादित)';

  @override
  String commentsCount(Object count) {
    return '$count टिप्पणियां';
  }

  @override
  String get deletePost => 'पोस्ट हटाएं';

  @override
  String get deletePostConfirm =>
      'क्या आप वाकई इस पोस्ट को हटाना चाहते हैं?\nहटाई गई पोस्ट वापस नहीं आ सकती।';

  @override
  String get deletePostSuccess => 'पोस्ट हटा दी गई।';

  @override
  String deletePostError(Object error) {
    return 'हटाने में विफल: $error';
  }

  @override
  String get postNotFound => 'पोस्ट नहीं मिली';

  @override
  String get shareFeatureComingSoon => 'शेयर सुविधा जल्द आ रही';

  @override
  String get loadingComments => 'टिप्पणियां लोड हो रहीं...';

  @override
  String get loadMoreComments => 'और टिप्पणियां देखें';

  @override
  String get editComment => 'टिप्पणी संपादित करें';

  @override
  String get editCommentHint => 'अपनी टिप्पणी संपादित करें...';

  @override
  String get editCommentSuccess => 'टिप्पणी अपडेट हो गई।';

  @override
  String editCommentError(Object error) {
    return 'संपादन विफल: $error';
  }

  @override
  String get deleteComment => 'टिप्पणी हटाएं';

  @override
  String get deleteCommentConfirm =>
      'क्या आप वाकई इस टिप्पणी को हटाना चाहते हैं?\nहटाई गई टिप्पणी वापस नहीं आ सकती।';

  @override
  String get deleteCommentSuccess => 'टिप्पणी हटा दी गई।';

  @override
  String get replySuccess => 'जवाब पोस्ट कर दिया गया।';

  @override
  String get commentSuccess => 'टिप्पणी पोस्ट कर दी गई।';

  @override
  String get commentError => 'टिप्पणी पोस्ट करने में विफल।';

  @override
  String get titlePlaceholder => 'शीर्षक दर्ज करें';

  @override
  String get contentPlaceholder =>
      'अपना विचार साझा करें...\n\nपेरेंटिंग के अनुभव के बारे में स्वतंत्र रूप से लिखें।';

  @override
  String imageSelectionError(Object error) {
    return 'छवि चयन विफल: $error';
  }

  @override
  String get userNotFoundError => 'उपयोगकर्ता की जानकारी नहीं मिली।';

  @override
  String get postCreateSuccess => 'पोस्ट सफलतापूर्वक बनाई गई!';

  @override
  String postCreateError(Object error) {
    return 'पोस्ट बनाने में विफल: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'शीर्षक: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return 'छवियां: $count/5';
  }

  @override
  String get addImageTooltip => 'छवि जोड़ें';

  @override
  String get allPostsChecked => 'सभी पोस्ट चेक कर ली गईं! 👍';

  @override
  String get waitForNewPosts => 'नए पोस्ट आने तक प्रतीक्षा करें';

  @override
  String get noPostsYet => 'अभी तक कोई पोस्ट नहीं';

  @override
  String get writeFirstPost => 'पहली पोस्ट लिखें!';

  @override
  String get loadingNewPosts => 'नए पोस्ट लोड हो रहे हैं...';

  @override
  String get failedToLoadPosts => 'पोस्ट लोड करने में विफल';

  @override
  String get checkNetworkAndRetry =>
      'कृपया नेटवर्क कनेक्शन जाँचें और फिर कोशिश करें';

  @override
  String get categoryDailyLife => 'दैनिक जीवन';

  @override
  String get preparingTimeline => 'टाइमलाइन तैयार कर रहे हैं...';

  @override
  String get noRecordedMoments => 'अभी तक कोई रिकॉर्ड किए गए पल नहीं';

  @override
  String get loadingTimeline => 'टाइमलाइन लोड हो रही है...';

  @override
  String get noRecordsYet => 'अभी तक कोई रिकॉर्ड नहीं';

  @override
  String noRecordsForDate(Object date) {
    return '$date के लिए अभी तक कोई रिकॉर्ड नहीं';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return '$date के लिए $filter रिकॉर्ड नहीं';
  }

  @override
  String get cannotRecordFuture => 'भविष्य के रिकॉर्ड अभी बनाए नहीं जा सकते';

  @override
  String get addFirstRecord => 'अपना पहला रिकॉर्ड जोड़ें!';

  @override
  String get canAddPastRecord => 'आप पिछले रिकॉर्ड जोड़ सकते हैं';

  @override
  String get addRecord => 'रिकॉर्ड जोड़ें';

  @override
  String get viewOtherDates => 'अन्य तारीखें देखें';

  @override
  String get goToToday => 'आज पर जाएं';

  @override
  String get quickRecordFromHome =>
      'होम स्क्रीन से जल्दी रिकॉर्ड जोड़ सकते हैं';

  @override
  String detailViewComingSoon(String title) {
    return '$title विवरण (जल्द आ रहा है)';
  }

  @override
  String get familyInvitationDescription =>
      'निमंत्रण कोड के साथ परिवार के साथ बच्चे की देखभाल के रिकॉर्ड प्रबंधित करें';

  @override
  String get babyManagement => 'बेबी प्रबंधन';

  @override
  String get addBaby => 'बच्चा जोड़ें';

  @override
  String get noBabiesMessage =>
      'कोई बच्चा पंजीकृत नहीं है।\nकृपया एक बच्चा जोड़ें।';

  @override
  String get switchToNextBaby => 'अगले बच्चे पर स्विच करें';

  @override
  String get birthDate => 'जन्म तिथि';

  @override
  String get registering => 'पंजीकरण कर रहे हैं...';

  @override
  String get register => 'पंजीकरण';

  @override
  String careTogetherWith(String name) {
    return '$name के साथ बच्चे की देखभाल करें';
  }

  @override
  String get inviteFamilyDescription =>
      'परिवार या साथी को आमंत्रित करें\nएक साथ बच्चे की देखभाल के रिकॉर्ड प्रबंधित करने के लिए';

  @override
  String get generateInviteCode => 'निमंत्रण कोड जेनरेट करें';

  @override
  String get generateInviteCodeDescription =>
      'नया निमंत्रण कोड जेनरेट करें और कॉपी करें';

  @override
  String get generateInviteCodeButton => 'निमंत्रण कोड जेनरेट करें';

  @override
  String get orText => 'या';

  @override
  String get enterInviteCodeDescription =>
      'कृपया प्राप्त निमंत्रण कोड दर्ज करें';

  @override
  String get inviteCodePlaceholder => 'निमंत्रण कोड (6 अंक)';

  @override
  String get acceptInvite => 'निमंत्रण स्वीकार करें';

  @override
  String babyRegistrationSuccess(String name) {
    return '$name सफलतापूर्वक पंजीकृत हो गया है';
  }

  @override
  String get babyRegistrationFailed => 'बच्चे का पंजीकरण विफल हुआ';

  @override
  String babyRegistrationError(String error) {
    return 'त्रुटि हुई: $error';
  }

  @override
  String babySelected(String name) {
    return '$name चुना गया है';
  }

  @override
  String get inviteCodeGenerated => 'निमंत्रण कोड जेनरेट किया गया!';

  @override
  String remainingTime(String time) {
    return 'बचा हुआ समय: $time';
  }

  @override
  String get validTime => 'वैध समय: 5 मिनट';

  @override
  String get generating => 'जेनरेट कर रहे हैं...';

  @override
  String get joining => 'शामिल हो रहे हैं...';

  @override
  String get noBabyInfo => 'बच्चे की जानकारी नहीं';

  @override
  String get noBabyInfoDescription =>
      'बच्चे की जानकारी नहीं मिली।\nक्या आप परीक्षण बच्चा बनाना चाहते हैं?';

  @override
  String get create => 'बनाएं';

  @override
  String get generateNewInviteCode => 'नया निमंत्रण कोड जेनरेट करें';

  @override
  String get replaceExistingCode =>
      'यह मौजूदा निमंत्रण कोड को बदल देगा।\nक्या आप जारी रखना चाहते हैं?';

  @override
  String get acceptInvitation => 'निमंत्रण स्वीकार करें';

  @override
  String get acceptInvitationDescription =>
      'क्या आप निमंत्रण स्वीकार करना चाहते हैं और परिवार में शामिल होना चाहते हैं?';

  @override
  String acceptInvitationWarning(String babyName) {
    return 'मौजूदा बच्चे के रिकॉर्ड हटा दिए जाएंगे और\nआमंत्रित बच्चे ($babyName) से बदल दिए जाएंगे।\n\nक्या आप जारी रखना चाहते हैं?';
  }

  @override
  String get pleaseEnterInviteCode => 'कृपया निमंत्रण कोड दर्ज करें';

  @override
  String get inviteCodeMustBe6Digits => 'निमंत्रण कोड 6 अंक का होना चाहिए';

  @override
  String get pleaseLoginFirst =>
      'लॉगइन जानकारी नहीं मिली। कृपया पहले लॉगइन करें।';

  @override
  String get copiedToClipboard => 'निमंत्रण कोड क्लिपबोर्ड में कॉपी किया गया!';

  @override
  String get joinedSuccessfully => 'परिवार में सफलतापूर्वक शामिल हुए!';

  @override
  String get inviteCodeExpired => 'निमंत्रण कोड का समय समाप्त हो गया है';

  @override
  String get invalidInviteCode => 'अमान्य निमंत्रण कोड';

  @override
  String get alreadyMember => 'आप पहले से ही इस परिवार के सदस्य हैं';

  @override
  String get cannotInviteSelf => 'आप अपने आप को आमंत्रित नहीं कर सकते';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutesमिनट $secondsसेकंड';
  }

  @override
  String babyGuideTitle(String name) {
    return '$name की बेबी केयर गाइड';
  }

  @override
  String get babyGuide => 'बेबी केयर गाइड';

  @override
  String get noAvailableGuides => 'कोई उपलब्ध गाइड नहीं';

  @override
  String get current => 'वर्तमान';

  @override
  String get past => 'बीत गया';

  @override
  String get upcoming => 'आगामी';

  @override
  String babysGuide(String name) {
    return '$name की';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText गाइड';
  }

  @override
  String get feedingGuide => '💡 फीडिंग गाइड';

  @override
  String get feedingFrequency => 'फीडिंग आवृत्ति';

  @override
  String get singleFeedingAmount => 'एक बार फीडिंग मात्रा';

  @override
  String get dailyTotal => 'दैनिक कुल';

  @override
  String get additionalTips => '📋 अतिरिक्त टिप्स';

  @override
  String get understood => 'समझ गया!';

  @override
  String get newborn => 'नवजात';

  @override
  String weekNumber(int number) {
    return 'सप्ताह $number';
  }

  @override
  String get newbornWeek0 => 'नवजात (सप्ताह 0)';

  @override
  String dailyFrequencyRange(int min, int max) {
    return 'दैनिक $min - $max बार';
  }

  @override
  String dailyFrequencyMin(int min) {
    return 'दैनिक $min बार या अधिक';
  }

  @override
  String dailyFrequencyMax(int max) {
    return 'दैनिक $max बार तक';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml या अधिक';
  }

  @override
  String amountMaxML(int max) {
    return '${max}ml तक';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => 'भाषा चयन';

  @override
  String get selectLanguage => 'एक भाषा चुनें';

  @override
  String get currentLanguage => 'वर्तमान भाषा';

  @override
  String get searchCommunityPosts => 'समुदाय पोस्ट खोजें';

  @override
  String get temperatureRecord => 'तापमान रिकॉर्ड';

  @override
  String get temperatureTrend => 'तापमान ट्रेंड';

  @override
  String get profilePhotoSetup => 'प्रोफाइल फोटो सेटअप';

  @override
  String get howToSelectPhoto => 'आप फोटो कैसे चुनना चाहते हैं?';

  @override
  String get send => 'भेजें';

  @override
  String get emailVerificationRequired => 'ईमेल सत्यापन आवश्यक';

  @override
  String get passwordReset => 'पासवर्ड रीसेट';

  @override
  String get enterEmailForReset =>
      'अपना पंजीकृत ईमेल पता दर्ज करें।\nहम आपको पासवर्ड रीसेट लिंक भेजेंगे।';

  @override
  String get accountWithdrawalComplete => 'खाता निकासी पूर्ण';

  @override
  String get genderLabel => 'लिंग: ';

  @override
  String get birthdateLabel => 'जन्मतिथि: ';

  @override
  String get maleGender => 'लड़का';

  @override
  String get femaleGender => 'लड़की';

  @override
  String get joinWithInviteCodeButton => 'निमंत्रण कोड से जुड़ें';

  @override
  String get temperatureRecorded => 'तापमान रिकॉर्ड किया गया';

  @override
  String recordFailed(String error) {
    return 'रिकॉर्ड विफल: $error';
  }

  @override
  String get temperatureSettingsSaved => 'तापमान सेटिंग्स सहेजी गईं';

  @override
  String get loadingUserInfo =>
      'उपयोगकर्ता जानकारी लोड हो रही है। कृपया थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get continueWithSeparateAccount => 'अलग खाते के साथ जारी रखें';

  @override
  String get linkWithExistingAccount => 'मौजूदा खाते से लिंक करें';

  @override
  String get linkAccount => 'खाता लिंक करें';

  @override
  String get accountLinkingComplete => 'खाता लिंकिंग पूर्ण';

  @override
  String get deleteConfirmation => 'हटाने की पुष्टि';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get babyNameLabel => 'बच्चे का नाम';

  @override
  String get weightInput => 'वजन दर्ज करें';

  @override
  String get heightInput => 'ऊंचाई दर्ज करें';

  @override
  String get measurementNotes =>
      'माप की स्थिति या विशेष नोट्स दर्ज करें (वैकल्पिक)';

  @override
  String get urine => 'पेशाब';

  @override
  String get stool => 'मल';

  @override
  String get yellow => 'पीला';

  @override
  String get brown => 'भूरा';

  @override
  String get green => 'हरा';

  @override
  String get bottle => 'बोतल';

  @override
  String get good => 'अच्छा';

  @override
  String get average => 'औसत';

  @override
  String get poor => 'खराब';

  @override
  String get vaccination => 'टीकाकरण';

  @override
  String get illness => 'बीमारी';

  @override
  String get highFever => 'तेज बुखार';

  @override
  String get oral => 'मौखिक';

  @override
  String get inhalation => 'सांस द्वारा';

  @override
  String get injection => 'इंजेक्शन';

  @override
  String get tablet => 'गोली';

  @override
  String get drops => 'बूंदें';

  @override
  String get teaspoon => 'चम्मच';

  @override
  String get tablespoon => 'बड़ा चम्मच';

  @override
  String get sleepQuality => 'नींद';

  @override
  String get pumpingTime => 'पंपिंग';

  @override
  String get solidFoodTime => 'ठोस आहार';

  @override
  String get totalFeedingAmount => 'कुल फीडिंग मात्रा';

  @override
  String get averageFeedingAmount => 'औसत भोजन की मात्रा';

  @override
  String get dailyAverageFeedingCount => 'दैनिक औसत भोजन की संख्या';

  @override
  String get clinical => 'क्लिनिकल';

  @override
  String get infoSharing => 'जानकारी साझाकरण';

  @override
  String get sleepIssues => 'नींद की समस्याएं';

  @override
  String get babyFoodCategory => 'बेबी फूड';

  @override
  String get developmentStage => 'विकास चरण';

  @override
  String get vaccinationCategory => 'टीकाकरण';

  @override
  String get postpartumRecovery => 'प्रसवोत्तर रिकवरी';

  @override
  String get dailyLife => 'दैनिक जीवन';

  @override
  String get likes => 'पसंद';

  @override
  String get comments => 'टिप्पणियां';

  @override
  String get anonymous => 'गुमनाम';

  @override
  String get minutes => 'मिनट';

  @override
  String get armpit => 'बगल';

  @override
  String get forehead => 'माथा';

  @override
  String get ear => 'कान';

  @override
  String get mouth => 'मुंह';

  @override
  String get rectal => 'गुदा';

  @override
  String get otherLocation => 'अन्य';

  @override
  String get searchError => 'खोज त्रुटि';

  @override
  String get question => 'प्रश्न';

  @override
  String get information => 'जानकारी';

  @override
  String get relevance => 'प्रासंगिकता';

  @override
  String get searchSuggestions => 'खोज सुझाव';

  @override
  String get noSearchResults => 'कोई खोज परिणाम नहीं';

  @override
  String get tryDifferentSearchTerm => 'अलग खोज शब्द आज़माएं';

  @override
  String get likeFeatureComingSoon => 'लाइक सुविधा जल्द ही आ रही है';

  @override
  String get popularSearchTerms => 'लोकप्रिय खोज शब्द';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String get deleteAll => 'सभी हटाएं';

  @override
  String get sortByComments => 'टिप्पणियों के अनुसार क्रमबद्ध करें';

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
  String get longPressForDetails => 'विवरण के लिए दबाकर रखें';

  @override
  String get todaysSummary => 'आज का सारांश';

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
  String get registerBabyFirst => 'कृपया पहले अपने बच्चे को पंजीकृत करें';

  @override
  String get registerBabyToRecordMoments =>
      'अपने बच्चे के कीमती पलों को रिकॉर्ड करने के लिए,\nकृपया पहले बच्चे की जानकारी दर्ज करें।';

  @override
  String get addBabyFromHome => 'होम से बच्चा जोड़ें';

  @override
  String get timesUnit => 'बार';

  @override
  String get itemsUnit => 'आइटम';

  @override
  String get timesPerDay => 'बार/दिन';

  @override
  String get activityDistributionByCategory => 'श्रेणी के अनुसार गतिविधि वितरण';

  @override
  String itemsCount(int count) {
    return '$count आइटम';
  }

  @override
  String get totalCount => 'कुल संख्या';

  @override
  String timesCount(int count) {
    return '$count बार';
  }

  @override
  String get noDetailedData => 'कोई विस्तृत डेटा नहीं';

  @override
  String get averageFeedingTime => 'औसत भोजन का समय';

  @override
  String get averageSleepTime => 'औसत नींद का समय';

  @override
  String get dailyAverageTotalSleepTime => 'दैनिक औसत कुल नींद का समय';

  @override
  String get dailyAverageSleepCount => 'दैनिक औसत नींद की संख्या';

  @override
  String get dailyAverageChangeCount => 'दैनिक औसत परिवर्तन की संख्या';

  @override
  String get sharingParentingStories => 'पेरेंटिंग की कहानियां साझा करना';

  @override
  String get myActivity => 'मेरी गतिविधि';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get menu => 'मेनू';

  @override
  String get seeMore => 'और देखें';

  @override
  String get midnight => 'मध्यरात्रि';

  @override
  String get morning => 'पूर्वाह्न';

  @override
  String get noon => 'दोपहर';

  @override
  String get afternoon => 'अपराह्न';

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
