import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tl'),
    Locale('tr'),
  ];

  /// User label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Error message when user info loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load user info: {error}'**
  String userInfoLoadFailed(String error);

  /// Error message when baby list loading fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the baby list: {error}'**
  String babyListLoadError(String error);

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {nickname}! 🎉'**
  String welcomeUser(String userName, Object nickname);

  /// Register baby button text
  ///
  /// In en, this message translates to:
  /// **'Register Baby'**
  String get registerBaby;

  /// Message when no babies are registered
  ///
  /// In en, this message translates to:
  /// **'No babies registered'**
  String get noBabiesRegistered;

  /// Prompt to register first baby
  ///
  /// In en, this message translates to:
  /// **'Register your first baby!'**
  String get registerFirstBaby;

  /// Register baby button text
  ///
  /// In en, this message translates to:
  /// **'Register Baby'**
  String get registerBabyButton;

  /// Birthday display format
  ///
  /// In en, this message translates to:
  /// **'Birthday: {year}/{month}/{day}'**
  String birthday(int year, int month, int day);

  /// Age in days
  ///
  /// In en, this message translates to:
  /// **'Age: {days} days'**
  String age(int days);

  /// Gender display
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String gender(String gender);

  /// Male gender
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Baby detail screen placeholder
  ///
  /// In en, this message translates to:
  /// **'{name} Detail Screen (Coming Soon)'**
  String babyDetailScreen(String name);

  /// Birthdate selection prompt
  ///
  /// In en, this message translates to:
  /// **'Please select birthdate'**
  String get selectBirthdate;

  /// Baby registration success message
  ///
  /// In en, this message translates to:
  /// **'{name} has been registered!'**
  String babyRegistered(String name);

  /// Registration error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration: {error}'**
  String registrationError(String error);

  /// Baby info entry prompt
  ///
  /// In en, this message translates to:
  /// **'Please enter baby information'**
  String get enterBabyInfo;

  /// Baby name field label
  ///
  /// In en, this message translates to:
  /// **'Baby Name'**
  String get babyName;

  /// Baby name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Emma'**
  String get babyNameHint;

  /// Baby name required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter baby\'s name'**
  String get babyNameRequired;

  /// Baby name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get babyNameMinLength;

  /// Select birthdate button text
  ///
  /// In en, this message translates to:
  /// **'Select Birthdate'**
  String get selectBirthdateButton;

  /// Selected date format
  ///
  /// In en, this message translates to:
  /// **'{year}/{month}/{day}'**
  String selectedDate(int year, int month, int day);

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender (Optional)'**
  String get genderOptional;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Login failure message
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login: {error}'**
  String loginError(String error);

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Easily manage your baby\'s growth records'**
  String get appTagline;

  /// Terms and privacy notice
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our Terms of Service and Privacy Policy'**
  String get termsNotice;

  /// Kakao login button text
  ///
  /// In en, this message translates to:
  /// **'Login with Kakao'**
  String get loginWithKakao;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Birthdate selection button
  ///
  /// In en, this message translates to:
  /// **'Select Birthdate'**
  String get selectBirthDate;

  /// Error message when birthdate not selected
  ///
  /// In en, this message translates to:
  /// **'Please select birthdate'**
  String get pleasSelectBirthDate;

  /// Error message when baby name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter baby\'s name'**
  String get pleaseEnterBabyName;

  /// Error message for minimum name length
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Date format for birthdate display
  ///
  /// In en, this message translates to:
  /// **'{year}/{month}/{day}'**
  String dateFormat(String year, String month, String day);

  /// Auto login checkbox label
  ///
  /// In en, this message translates to:
  /// **'Stay logged in'**
  String get autoLogin;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Dark mode setting label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Home navigation tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Timeline navigation tab
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// Record navigation tab
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// Statistics navigation tab
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Community navigation tab
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Timeline update message
  ///
  /// In en, this message translates to:
  /// **'Timeline feature will be updated soon'**
  String get timelineUpdateMessage;

  /// Record update message
  ///
  /// In en, this message translates to:
  /// **'Record feature will be updated soon'**
  String get recordUpdateMessage;

  /// Statistics update message
  ///
  /// In en, this message translates to:
  /// **'Statistics feature will be updated soon'**
  String get statisticsUpdateMessage;

  /// Community update message
  ///
  /// In en, this message translates to:
  /// **'Community feature will be updated soon'**
  String get communityUpdateMessage;

  /// Today's summary section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// Growth info section title
  ///
  /// In en, this message translates to:
  /// **'Growth Info'**
  String get growthInfo;

  /// Last feeding time label
  ///
  /// In en, this message translates to:
  /// **'Last Feeding'**
  String get lastFeeding;

  /// Health status - healthy
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// Feeding label
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// Total feeding amount label
  ///
  /// In en, this message translates to:
  /// **'Total Feeding'**
  String get totalFeeding;

  /// Sleep label
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// Total sleep time label
  ///
  /// In en, this message translates to:
  /// **'Total Sleep Time'**
  String get totalSleepTime;

  /// Card settings screen title
  ///
  /// In en, this message translates to:
  /// **'Card Settings'**
  String get cardSettings;

  /// Card settings guide section title
  ///
  /// In en, this message translates to:
  /// **'Card Settings Guide'**
  String get cardSettingsGuide;

  /// No description provided for @cardSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'• Toggle switches to show/hide cards\n• Drag to change card order\n• Changes are previewed in real-time'**
  String get cardSettingsDescription;

  /// No description provided for @cardVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get cardVisible;

  /// No description provided for @cardHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get cardHidden;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cardSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Card settings saved'**
  String get cardSettingsSaved;

  /// No description provided for @cardSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while saving settings'**
  String get cardSettingsError;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes and return to previous state?'**
  String get discardChanges;

  /// Button to continue editing
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get continueEditing;

  /// No description provided for @discardChangesExit.
  ///
  /// In en, this message translates to:
  /// **'Exit without saving changes?'**
  String get discardChangesExit;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @solidFood.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @milkPumping.
  ///
  /// In en, this message translates to:
  /// **'Milk Pumping'**
  String get milkPumping;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @feedingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String feedingCount(Object count);

  /// No description provided for @feedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Feeding Amount'**
  String get feedingAmount;

  /// No description provided for @feedingRecordAdded.
  ///
  /// In en, this message translates to:
  /// **'Feeding record added successfully'**
  String get feedingRecordAdded;

  /// No description provided for @feedingRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add feeding record'**
  String get feedingRecordFailed;

  /// No description provided for @feedingRecordsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feeding records'**
  String get feedingRecordsLoadFailed;

  /// No description provided for @quickFeeding.
  ///
  /// In en, this message translates to:
  /// **'Quick Feeding'**
  String get quickFeeding;

  /// No description provided for @feedingTime.
  ///
  /// In en, this message translates to:
  /// **'Feeding Time'**
  String get feedingTime;

  /// Label for feeding type selection
  ///
  /// In en, this message translates to:
  /// **'Feeding Type'**
  String get feedingType;

  /// No description provided for @breastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get breastfeeding;

  /// No description provided for @bottleFeeding.
  ///
  /// In en, this message translates to:
  /// **'Bottle Feeding'**
  String get bottleFeeding;

  /// No description provided for @mixedFeeding.
  ///
  /// In en, this message translates to:
  /// **'Mixed Feeding'**
  String get mixedFeeding;

  /// No description provided for @sleepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String sleepCount(Object count);

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String sleepDuration(Object hours, Object minutes);

  /// No description provided for @sleepStarted.
  ///
  /// In en, this message translates to:
  /// **'Sleep started'**
  String get sleepStarted;

  /// No description provided for @sleepEnded.
  ///
  /// In en, this message translates to:
  /// **'Sleep ended'**
  String get sleepEnded;

  /// No description provided for @sleepInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get sleepInProgress;

  /// No description provided for @sleepRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process sleep record'**
  String get sleepRecordFailed;

  /// No description provided for @sleepRecordsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sleep records'**
  String get sleepRecordsLoadFailed;

  /// No description provided for @sleepTime.
  ///
  /// In en, this message translates to:
  /// **'Sleep Time'**
  String get sleepTime;

  /// No description provided for @wakeUpTime.
  ///
  /// In en, this message translates to:
  /// **'Wake Up Time'**
  String get wakeUpTime;

  /// No description provided for @sleepDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Duration'**
  String get sleepDurationLabel;

  /// No description provided for @napTime.
  ///
  /// In en, this message translates to:
  /// **'Nap Time'**
  String get napTime;

  /// No description provided for @nightSleep.
  ///
  /// In en, this message translates to:
  /// **'Night Sleep'**
  String get nightSleep;

  /// No description provided for @diaperCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String diaperCount(Object count);

  /// No description provided for @diaperChanged.
  ///
  /// In en, this message translates to:
  /// **'Diaper changed'**
  String get diaperChanged;

  /// No description provided for @diaperRecordAdded.
  ///
  /// In en, this message translates to:
  /// **'Diaper change record added successfully'**
  String get diaperRecordAdded;

  /// No description provided for @diaperRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add diaper record'**
  String get diaperRecordFailed;

  /// No description provided for @diaperRecordsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diaper records'**
  String get diaperRecordsLoadFailed;

  /// No description provided for @wetDiaper.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wetDiaper;

  /// No description provided for @dirtyDiaper.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirtyDiaper;

  /// No description provided for @bothDiaper.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothDiaper;

  /// No description provided for @wetCount.
  ///
  /// In en, this message translates to:
  /// **'Wet {count}'**
  String wetCount(Object count);

  /// No description provided for @dirtyCount.
  ///
  /// In en, this message translates to:
  /// **'Dirty {count}'**
  String dirtyCount(Object count);

  /// No description provided for @bothCount.
  ///
  /// In en, this message translates to:
  /// **'Both {count}'**
  String bothCount(Object count);

  /// No description provided for @diaperType.
  ///
  /// In en, this message translates to:
  /// **'Diaper Type'**
  String get diaperType;

  /// No description provided for @diaperChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change Time'**
  String get diaperChangeTime;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @growthRecord.
  ///
  /// In en, this message translates to:
  /// **'Growth Record'**
  String get growthRecord;

  /// No description provided for @growthRecordAdded.
  ///
  /// In en, this message translates to:
  /// **'Growth record added'**
  String get growthRecordAdded;

  /// No description provided for @growthRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save growth record'**
  String get growthRecordFailed;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightUnit;

  /// No description provided for @heightUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get heightUnit;

  /// No description provided for @temperatureUnit.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get temperatureUnit;

  /// No description provided for @measurementType.
  ///
  /// In en, this message translates to:
  /// **'Measurement Type'**
  String get measurementType;

  /// No description provided for @measurementValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get measurementValue;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @temperatureRange.
  ///
  /// In en, this message translates to:
  /// **'Temperature must be between 30.0°C and 45.0°C'**
  String get temperatureRange;

  /// No description provided for @weightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 0.1kg and 50kg'**
  String get weightRange;

  /// No description provided for @heightRange.
  ///
  /// In en, this message translates to:
  /// **'Height must be between 1cm and 200cm'**
  String get heightRange;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @recordGrowthInfo.
  ///
  /// In en, this message translates to:
  /// **'Record Growth Information'**
  String get recordGrowthInfo;

  /// No description provided for @currentMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Enter current {type}'**
  String currentMeasurement(Object type);

  /// No description provided for @measurementSituation.
  ///
  /// In en, this message translates to:
  /// **'Record measurement situation or special notes (optional)'**
  String get measurementSituation;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// No description provided for @writePost.
  ///
  /// In en, this message translates to:
  /// **'Write Post'**
  String get writePost;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @postContent.
  ///
  /// In en, this message translates to:
  /// **'Post Content'**
  String get postContent;

  /// No description provided for @postTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get postTitleHint;

  /// No description provided for @postContentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter content...\n\nFeel free to share your story.'**
  String get postContentHint;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreated;

  /// No description provided for @postCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create post: {error}'**
  String postCreateFailed(Object error);

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @nicknameSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up nickname'**
  String get nicknameSetup;

  /// No description provided for @nicknameChange.
  ///
  /// In en, this message translates to:
  /// **'Change nickname'**
  String get nicknameChange;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get nicknameHint;

  /// No description provided for @nicknameDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a nickname to use in the community.\nIt will be displayed to other users.'**
  String get nicknameDescription;

  /// No description provided for @nicknameChangeDescription.
  ///
  /// In en, this message translates to:
  /// **'You can change to a new nickname.'**
  String get nicknameChangeDescription;

  /// No description provided for @nicknameValidation.
  ///
  /// In en, this message translates to:
  /// **'Korean, English, numbers, underscore (_) allowed (2-20 characters)'**
  String get nicknameValidation;

  /// No description provided for @nicknameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at least 2 characters'**
  String get nicknameMinLength;

  /// No description provided for @nicknameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 20 characters or less'**
  String get nicknameMaxLength;

  /// No description provided for @nicknameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Only Korean, English, numbers, and underscore (_) are allowed'**
  String get nicknameInvalidChars;

  /// No description provided for @nicknameChanged.
  ///
  /// In en, this message translates to:
  /// **'Nickname changed successfully!'**
  String get nicknameChanged;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startButton;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'Title: {count}/200'**
  String characterCount(Object count);

  /// No description provided for @contentCharacterCount.
  ///
  /// In en, this message translates to:
  /// **'Content: {count}/10000'**
  String contentCharacterCount(Object count);

  /// No description provided for @imageCount.
  ///
  /// In en, this message translates to:
  /// **'Images: {count}/5'**
  String imageCount(Object count);

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @imageSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Image selection failed: {error}'**
  String imageSelectFailed(Object error);

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get featureInDevelopment;

  /// No description provided for @liveQA.
  ///
  /// In en, this message translates to:
  /// **'🔥 Pediatrician Live Q&A'**
  String get liveQA;

  /// No description provided for @liveQADescription.
  ///
  /// In en, this message translates to:
  /// **'Today at 7 PM! Our specialists will answer all your questions'**
  String get liveQADescription;

  /// No description provided for @likeOrder.
  ///
  /// In en, this message translates to:
  /// **'Most Liked'**
  String get likeOrder;

  /// No description provided for @latestOrder.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestOrder;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User information not found'**
  String get userNotFound;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @noStatisticsData.
  ///
  /// In en, this message translates to:
  /// **'No Statistics Data'**
  String get noStatisticsData;

  /// No description provided for @statisticsDescription.
  ///
  /// In en, this message translates to:
  /// **'No activities recorded during {period}.\nStart recording your baby\'s activities!'**
  String statisticsDescription(Object period);

  /// No description provided for @recordActivity.
  ///
  /// In en, this message translates to:
  /// **'Record Activity'**
  String get recordActivity;

  /// No description provided for @viewOtherPeriod.
  ///
  /// In en, this message translates to:
  /// **'View Other Period'**
  String get viewOtherPeriod;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @statisticsTips.
  ///
  /// In en, this message translates to:
  /// **'To view statistics?'**
  String get statisticsTips;

  /// No description provided for @statisticsTip1.
  ///
  /// In en, this message translates to:
  /// **'Record activities like feeding, sleep, diaper changes'**
  String get statisticsTip1;

  /// No description provided for @statisticsTip2.
  ///
  /// In en, this message translates to:
  /// **'At least one day of data is required for statistics'**
  String get statisticsTip2;

  /// No description provided for @statisticsTip3.
  ///
  /// In en, this message translates to:
  /// **'You can record easily from the home screen'**
  String get statisticsTip3;

  /// No description provided for @saveAsImage.
  ///
  /// In en, this message translates to:
  /// **'Save as Image'**
  String get saveAsImage;

  /// No description provided for @saveAsImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Save statistics as image'**
  String get saveAsImageDescription;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get shareAsText;

  /// No description provided for @shareAsTextDescription.
  ///
  /// In en, this message translates to:
  /// **'Share statistics summary as text'**
  String get shareAsTextDescription;

  /// No description provided for @statisticsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No statistics data'**
  String get statisticsEmptyState;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// No description provided for @detailsButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsButton;

  /// No description provided for @goHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHomeButton;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @viewOtherPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'View Other Period'**
  String get viewOtherPeriodTitle;

  /// No description provided for @familyInvitation.
  ///
  /// In en, this message translates to:
  /// **'Family Invitation'**
  String get familyInvitation;

  /// No description provided for @invitationDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage baby records together with your family using invitation codes'**
  String get invitationDescription;

  /// No description provided for @createInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create Invitation'**
  String get createInvitation;

  /// No description provided for @invitationCreated.
  ///
  /// In en, this message translates to:
  /// **'Invitation created successfully'**
  String get invitationCreated;

  /// No description provided for @invitationCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create invitation: {error}'**
  String invitationCreateFailed(Object error);

  /// No description provided for @invitationRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get invitationRole;

  /// No description provided for @invitationDuration.
  ///
  /// In en, this message translates to:
  /// **'Validity Period'**
  String get invitationDuration;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @roleCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get roleCaregiver;

  /// No description provided for @roleGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get roleGuardian;

  /// No description provided for @roleParentDesc.
  ///
  /// In en, this message translates to:
  /// **'Can manage all records as baby\'s parent'**
  String get roleParentDesc;

  /// No description provided for @roleCaregiverDesc.
  ///
  /// In en, this message translates to:
  /// **'Can manage some records as caregiver'**
  String get roleCaregiverDesc;

  /// No description provided for @roleGuardianDesc.
  ///
  /// In en, this message translates to:
  /// **'Can view records as baby\'s guardian'**
  String get roleGuardianDesc;

  /// No description provided for @invitationGuide.
  ///
  /// In en, this message translates to:
  /// **'Invitation Guide'**
  String get invitationGuide;

  /// No description provided for @invitationGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'You can invite family members to manage baby records together. The invited person can participate through the invitation link after installing the app.'**
  String get invitationGuideDesc;

  /// No description provided for @shareInvitation.
  ///
  /// In en, this message translates to:
  /// **'Share Invitation'**
  String get shareInvitation;

  /// No description provided for @shareImmediately.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get shareImmediately;

  /// No description provided for @invitationPreview.
  ///
  /// In en, this message translates to:
  /// **'Invitation Preview'**
  String get invitationPreview;

  /// No description provided for @invitationExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires in {duration}'**
  String invitationExpiry(Object duration);

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with Invitation Code'**
  String get joinWithCode;

  /// No description provided for @invitationValidity.
  ///
  /// In en, this message translates to:
  /// **'Invitation Validity Period'**
  String get invitationValidity;

  /// No description provided for @testMode.
  ///
  /// In en, this message translates to:
  /// **'Test Mode: Creating invitation with temporary user information'**
  String get testMode;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Please check your input'**
  String get validationError;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// Error message for update failure
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// Error message for deletion failure
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailed(String error);

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'{hour}:{minute}'**
  String timeFormat(Object hour, Object minute);

  /// No description provided for @dateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{year}-{month}-{day} {hour}:{minute}'**
  String dateTimeFormat(
    Object day,
    Object hour,
    Object minute,
    Object month,
    Object year,
  );

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(Object minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(Object hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(Object hours, Object minutes);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Label for medication name
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @medicationDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medicationDose;

  /// No description provided for @medicationTime.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medicationTime;

  /// No description provided for @medicationAdded.
  ///
  /// In en, this message translates to:
  /// **'Medication record added'**
  String get medicationAdded;

  /// No description provided for @solidFoodType.
  ///
  /// In en, this message translates to:
  /// **'Food Type'**
  String get solidFoodType;

  /// No description provided for @solidFoodAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount}g'**
  String solidFoodAmount(Object amount);

  /// No description provided for @solidFoodAdded.
  ///
  /// In en, this message translates to:
  /// **'Solid food record added'**
  String get solidFoodAdded;

  /// No description provided for @milkPumpingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pumping Amount'**
  String get milkPumpingAmount;

  /// No description provided for @milkPumpingTime.
  ///
  /// In en, this message translates to:
  /// **'Pumping Time'**
  String get milkPumpingTime;

  /// No description provided for @milkPumpingAdded.
  ///
  /// In en, this message translates to:
  /// **'Milk pumping record added'**
  String get milkPumpingAdded;

  /// No description provided for @temperatureReading.
  ///
  /// In en, this message translates to:
  /// **'Temperature Reading'**
  String get temperatureReading;

  /// No description provided for @temperatureNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get temperatureNormal;

  /// No description provided for @temperatureHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get temperatureHigh;

  /// No description provided for @temperatureLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get temperatureLow;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @profilePhotoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Photo'**
  String get profilePhotoUpdate;

  /// No description provided for @selectPhotoSource.
  ///
  /// In en, this message translates to:
  /// **'How would you like to select a photo?'**
  String get selectPhotoSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get photoUpdated;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile photo update failed'**
  String get photoUploadFailed;

  /// No description provided for @photoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get photoUploading;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available on iOS simulator.\nPlease try from gallery.'**
  String get cameraNotAvailable;

  /// No description provided for @cameraAccessError.
  ///
  /// In en, this message translates to:
  /// **'Camera access error occurred.\nPlease try from gallery.'**
  String get cameraAccessError;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} images allowed'**
  String maxImagesReached(Object count);

  /// No description provided for @ageMonthsAndDays.
  ///
  /// In en, this message translates to:
  /// **'{months} months {days} days'**
  String ageMonthsAndDays(Object days, Object months);

  /// No description provided for @lastFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'Last feeding time'**
  String get lastFeedingTime;

  /// No description provided for @hoursAndMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes ago'**
  String hoursAndMinutesAgo(Object hours, Object minutes);

  /// No description provided for @nextFeedingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Next feeding in about {hours}h {minutes}m'**
  String nextFeedingSchedule(Object hours, Object minutes);

  /// No description provided for @nextFeedingScheduleMinutes.
  ///
  /// In en, this message translates to:
  /// **'Next feeding in about {minutes} minutes'**
  String nextFeedingScheduleMinutes(Object minutes);

  /// No description provided for @feedingTimeNow.
  ///
  /// In en, this message translates to:
  /// **'It\'s feeding time now 🍼'**
  String get feedingTimeNow;

  /// No description provided for @feedingTimeSoon.
  ///
  /// In en, this message translates to:
  /// **'Feeding time soon ({minutes} minutes)'**
  String feedingTimeSoon(Object minutes);

  /// No description provided for @feedingTimeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Feeding time overdue'**
  String get feedingTimeOverdue;

  /// No description provided for @feedingAlarm.
  ///
  /// In en, this message translates to:
  /// **'Feeding alarm in {hours}h {minutes}m'**
  String feedingAlarm(Object hours, Object minutes);

  /// No description provided for @feedingAlarmMinutes.
  ///
  /// In en, this message translates to:
  /// **'Feeding alarm in {minutes} minutes'**
  String feedingAlarmMinutes(Object minutes);

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get meals;

  /// No description provided for @kilograms.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kilograms;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get centimeters;

  /// No description provided for @milliliters.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get milliliters;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @hoursUnit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursUnit;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesUnit;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @firstRecord.
  ///
  /// In en, this message translates to:
  /// **'First Record'**
  String get firstRecord;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No Change'**
  String get noChange;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @startBabyRecording.
  ///
  /// In en, this message translates to:
  /// **'Register your baby and start tracking growth'**
  String get startBabyRecording;

  /// No description provided for @registerBabyNow.
  ///
  /// In en, this message translates to:
  /// **'Register Baby'**
  String get registerBabyNow;

  /// No description provided for @joinWithInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Join with Invitation Code'**
  String get joinWithInviteCode;

  /// No description provided for @loadingBabyInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading baby information...'**
  String get loadingBabyInfo;

  /// No description provided for @pleaseRegisterBaby.
  ///
  /// In en, this message translates to:
  /// **'Please register a baby in settings'**
  String get pleaseRegisterBaby;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo has been updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile photo'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @diaperWetAndDirty.
  ///
  /// In en, this message translates to:
  /// **'Wet+Dirty {count} times'**
  String diaperWetAndDirty(Object count);

  /// No description provided for @diaperWetAndDirtySeparate.
  ///
  /// In en, this message translates to:
  /// **'Wet {wetCount}, Dirty {dirtyCount}'**
  String diaperWetAndDirtySeparate(Object dirtyCount, Object wetCount);

  /// No description provided for @sleepZeroHours.
  ///
  /// In en, this message translates to:
  /// **'0 hours'**
  String get sleepZeroHours;

  /// No description provided for @solidFoodMeals.
  ///
  /// In en, this message translates to:
  /// **'{count} meals'**
  String solidFoodMeals(Object count);

  /// No description provided for @medicationScheduled.
  ///
  /// In en, this message translates to:
  /// **'About {count} times'**
  String medicationScheduled(Object count);

  /// No description provided for @medicationTypes.
  ///
  /// In en, this message translates to:
  /// **'Vitamins {vitaminCount}, Vaccines {vaccineCount}'**
  String medicationTypes(Object vaccineCount, Object vitaminCount);

  /// No description provided for @feedingRecordAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add feeding record'**
  String get feedingRecordAddFailed;

  /// No description provided for @diaperRecordAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add diaper record'**
  String get diaperRecordAddFailed;

  /// No description provided for @sleepRecordProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process sleep record'**
  String get sleepRecordProcessFailed;

  /// No description provided for @hourActivityPattern.
  ///
  /// In en, this message translates to:
  /// **'24-Hour Activity Pattern'**
  String get hourActivityPattern;

  /// No description provided for @touchClockInstruction.
  ///
  /// In en, this message translates to:
  /// **'Touch the clock to check activities by time period'**
  String get touchClockInstruction;

  /// No description provided for @touch.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get touch;

  /// No description provided for @noActivitiesInTimeframe.
  ///
  /// In en, this message translates to:
  /// **'No activities during this time'**
  String get noActivitiesInTimeframe;

  /// No description provided for @activityPatternAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Activity Pattern Analysis'**
  String get activityPatternAnalysis;

  /// No description provided for @todaysStory.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Story'**
  String get todaysStory;

  /// No description provided for @preciousMoments.
  ///
  /// In en, this message translates to:
  /// **'{count} precious moments'**
  String preciousMoments(Object count);

  /// No description provided for @firstMomentMessage.
  ///
  /// In en, this message translates to:
  /// **'Record your first precious moment.\nSmall daily changes add up to great growth.'**
  String get firstMomentMessage;

  /// No description provided for @pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get pattern;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// No description provided for @qualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// No description provided for @qualityFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get qualityFair;

  /// No description provided for @qualityPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get qualityPoor;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'o\'clock time slot'**
  String get timeSlot;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @activityConcentrationTime.
  ///
  /// In en, this message translates to:
  /// **'Times of concentrated activity throughout the day'**
  String get activityConcentrationTime;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// Breast milk feeding option
  ///
  /// In en, this message translates to:
  /// **'Breast Milk'**
  String get breastMilk;

  /// No description provided for @babyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get babyFood;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @sleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get sleeping;

  /// No description provided for @hoursText.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursText;

  /// No description provided for @minutesText.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesText;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'elapsed'**
  String get elapsed;

  /// No description provided for @urineOnly.
  ///
  /// In en, this message translates to:
  /// **'Urine only'**
  String get urineOnly;

  /// No description provided for @stoolOnly.
  ///
  /// In en, this message translates to:
  /// **'Stool only'**
  String get stoolOnly;

  /// No description provided for @urineAndStool.
  ///
  /// In en, this message translates to:
  /// **'Urine + Stool'**
  String get urineAndStool;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @diaperChange.
  ///
  /// In en, this message translates to:
  /// **'Diaper Change'**
  String get diaperChange;

  /// No description provided for @oralMedication.
  ///
  /// In en, this message translates to:
  /// **'Oral Medication'**
  String get oralMedication;

  /// Topical administration route option
  ///
  /// In en, this message translates to:
  /// **'Topical'**
  String get topical;

  /// Inhaled administration route option
  ///
  /// In en, this message translates to:
  /// **'Inhaled'**
  String get inhaled;

  /// No description provided for @pumping.
  ///
  /// In en, this message translates to:
  /// **'Pumping'**
  String get pumping;

  /// No description provided for @temperatureMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Temperature Measurement'**
  String get temperatureMeasurement;

  /// No description provided for @fever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get fever;

  /// No description provided for @lowFever.
  ///
  /// In en, this message translates to:
  /// **'Low Fever'**
  String get lowFever;

  /// No description provided for @hypothermia.
  ///
  /// In en, this message translates to:
  /// **'Hypothermia'**
  String get hypothermia;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(Object count);

  /// No description provided for @noActivitiesRecordedInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No activities were recorded during {period}.'**
  String noActivitiesRecordedInPeriod(Object period);

  /// No description provided for @recordBabyActivities.
  ///
  /// In en, this message translates to:
  /// **'Record your baby\'s activities!'**
  String get recordBabyActivities;

  /// No description provided for @howToViewStatistics.
  ///
  /// In en, this message translates to:
  /// **'How to view statistics?'**
  String get howToViewStatistics;

  /// No description provided for @recordActivitiesLikeFeedingSleep.
  ///
  /// In en, this message translates to:
  /// **'Record activities like feeding, sleep, diaper changes, etc.'**
  String get recordActivitiesLikeFeedingSleep;

  /// No description provided for @atLeastOneDayDataRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one day of data is required to display statistics.'**
  String get atLeastOneDayDataRequired;

  /// No description provided for @canRecordEasilyFromHome.
  ///
  /// In en, this message translates to:
  /// **'You can easily record activities from the home screen.'**
  String get canRecordEasilyFromHome;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated:'**
  String get lastUpdated;

  /// No description provided for @periodSelection.
  ///
  /// In en, this message translates to:
  /// **'Period selection:'**
  String get periodSelection;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @detailedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get detailedStatistics;

  /// Section title for chart analysis
  ///
  /// In en, this message translates to:
  /// **'Chart Analysis'**
  String get chartAnalysis;

  /// No description provided for @overallActivityOverview.
  ///
  /// In en, this message translates to:
  /// **'Overall Activity Overview'**
  String get overallActivityOverview;

  /// No description provided for @totalActivities.
  ///
  /// In en, this message translates to:
  /// **'Total Activities'**
  String get totalActivities;

  /// No description provided for @activeCards.
  ///
  /// In en, this message translates to:
  /// **'Active Cards'**
  String get activeCards;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @activityDistributionByCard.
  ///
  /// In en, this message translates to:
  /// **'Activity Distribution by Card'**
  String get activityDistributionByCard;

  /// No description provided for @cannotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load data'**
  String get cannotLoadData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @troubleshootingMethods.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting Methods'**
  String get troubleshootingMethods;

  /// No description provided for @shareStatistics.
  ///
  /// In en, this message translates to:
  /// **'Share Statistics'**
  String get shareStatistics;

  /// No description provided for @communitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing Parenting Stories Together'**
  String get communitySubtitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @searchFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search feature coming soon'**
  String get searchFeatureComingSoon;

  /// No description provided for @communityWelcome.
  ///
  /// In en, this message translates to:
  /// **'💕 Parenting Community'**
  String get communityWelcome;

  /// No description provided for @communityWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Share parenting experiences and valuable information with other parents'**
  String get communityWelcomeDescription;

  /// No description provided for @categorySelection.
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get categorySelection;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get categoryPopular;

  /// No description provided for @categoryClinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get categoryClinical;

  /// No description provided for @categoryInfoSharing.
  ///
  /// In en, this message translates to:
  /// **'Info Sharing'**
  String get categoryInfoSharing;

  /// No description provided for @categorySleepIssues.
  ///
  /// In en, this message translates to:
  /// **'Sleep Issues'**
  String get categorySleepIssues;

  /// No description provided for @categoryBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get categoryBabyFood;

  /// No description provided for @categoryDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get categoryDevelopment;

  /// No description provided for @categoryVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get categoryVaccination;

  /// No description provided for @categoryPostpartum.
  ///
  /// In en, this message translates to:
  /// **'Postpartum'**
  String get categoryPostpartum;

  /// No description provided for @sortByLikes.
  ///
  /// In en, this message translates to:
  /// **'Sort by Likes'**
  String get sortByLikes;

  /// No description provided for @sortByLatest.
  ///
  /// In en, this message translates to:
  /// **'Sort by Latest'**
  String get sortByLatest;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'(edited)'**
  String get edited;

  /// Number of comments
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentsCount(int count);

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?\nDeleted posts cannot be recovered.'**
  String get deletePostConfirm;

  /// No description provided for @deletePostSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post has been deleted.'**
  String get deletePostSuccess;

  /// No description provided for @deletePostError.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deletePostError(Object error);

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found'**
  String get postNotFound;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get shareFeatureComingSoon;

  /// No description provided for @loadingComments.
  ///
  /// In en, this message translates to:
  /// **'Loading comments...'**
  String get loadingComments;

  /// No description provided for @loadMoreComments.
  ///
  /// In en, this message translates to:
  /// **'Load More Comments'**
  String get loadMoreComments;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @editCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment...'**
  String get editCommentHint;

  /// No description provided for @editCommentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment has been updated.'**
  String get editCommentSuccess;

  /// No description provided for @editCommentError.
  ///
  /// In en, this message translates to:
  /// **'Edit failed: {error}'**
  String editCommentError(Object error);

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?\nDeleted comments cannot be recovered.'**
  String get deleteCommentConfirm;

  /// No description provided for @deleteCommentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment has been deleted.'**
  String get deleteCommentSuccess;

  /// No description provided for @replySuccess.
  ///
  /// In en, this message translates to:
  /// **'Reply has been posted.'**
  String get replySuccess;

  /// No description provided for @commentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment has been posted.'**
  String get commentSuccess;

  /// No description provided for @commentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment.'**
  String get commentError;

  /// No description provided for @titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get titlePlaceholder;

  /// No description provided for @contentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts...\n\nFeel free to write about your parenting experiences.'**
  String get contentPlaceholder;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Image selection failed: {error}'**
  String imageSelectionError(Object error);

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User information not found.'**
  String get userNotFoundError;

  /// No description provided for @postCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post has been created successfully!'**
  String get postCreateSuccess;

  /// No description provided for @postCreateError.
  ///
  /// In en, this message translates to:
  /// **'Post creation failed: {error}'**
  String postCreateError(Object error);

  /// No description provided for @titleCharacterCount.
  ///
  /// In en, this message translates to:
  /// **'Title: {count}/200'**
  String titleCharacterCount(Object count);

  /// No description provided for @imageCountDisplay.
  ///
  /// In en, this message translates to:
  /// **'Images: {count}/5'**
  String imageCountDisplay(Object count);

  /// No description provided for @addImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImageTooltip;

  /// No description provided for @allPostsChecked.
  ///
  /// In en, this message translates to:
  /// **'All posts have been checked! 👍'**
  String get allPostsChecked;

  /// No description provided for @waitForNewPosts.
  ///
  /// In en, this message translates to:
  /// **'Please wait until new posts are uploaded'**
  String get waitForNewPosts;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @writeFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Write the first post!'**
  String get writeFirstPost;

  /// No description provided for @loadingNewPosts.
  ///
  /// In en, this message translates to:
  /// **'Loading new posts...'**
  String get loadingNewPosts;

  /// No description provided for @failedToLoadPosts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts'**
  String get failedToLoadPosts;

  /// No description provided for @checkNetworkAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again'**
  String get checkNetworkAndRetry;

  /// No description provided for @categoryDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get categoryDailyLife;

  /// No description provided for @preparingTimeline.
  ///
  /// In en, this message translates to:
  /// **'Preparing timeline...'**
  String get preparingTimeline;

  /// No description provided for @noRecordedMoments.
  ///
  /// In en, this message translates to:
  /// **'No recorded moments yet'**
  String get noRecordedMoments;

  /// No description provided for @loadingTimeline.
  ///
  /// In en, this message translates to:
  /// **'Loading timeline...'**
  String get loadingTimeline;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// No description provided for @noRecordsForDate.
  ///
  /// In en, this message translates to:
  /// **'No records for {date}'**
  String noRecordsForDate(Object date);

  /// No description provided for @noRecordsForDateAndFilter.
  ///
  /// In en, this message translates to:
  /// **'No {filter} records for {date}'**
  String noRecordsForDateAndFilter(Object date, Object filter);

  /// No description provided for @cannotRecordFuture.
  ///
  /// In en, this message translates to:
  /// **'Cannot record future activities yet'**
  String get cannotRecordFuture;

  /// No description provided for @addFirstRecord.
  ///
  /// In en, this message translates to:
  /// **'Add your first record!'**
  String get addFirstRecord;

  /// No description provided for @canAddPastRecord.
  ///
  /// In en, this message translates to:
  /// **'You can add past records'**
  String get canAddPastRecord;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addRecord;

  /// No description provided for @viewOtherDates.
  ///
  /// In en, this message translates to:
  /// **'View Other Dates'**
  String get viewOtherDates;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get goToToday;

  /// No description provided for @quickRecordFromHome.
  ///
  /// In en, this message translates to:
  /// **'You can quickly add records from the home screen'**
  String get quickRecordFromHome;

  /// Timeline item detail view coming soon message
  ///
  /// In en, this message translates to:
  /// **'{title} Details (Coming Soon)'**
  String detailViewComingSoon(String title);

  /// No description provided for @familyInvitationDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage baby care records together with family using invitation codes'**
  String get familyInvitationDescription;

  /// No description provided for @babyManagement.
  ///
  /// In en, this message translates to:
  /// **'Baby Management'**
  String get babyManagement;

  /// No description provided for @addBaby.
  ///
  /// In en, this message translates to:
  /// **'Add Baby'**
  String get addBaby;

  /// No description provided for @noBabiesMessage.
  ///
  /// In en, this message translates to:
  /// **'No babies registered.\nPlease add a baby.'**
  String get noBabiesMessage;

  /// No description provided for @switchToNextBaby.
  ///
  /// In en, this message translates to:
  /// **'Switch to Next Baby'**
  String get switchToNextBaby;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Take care together message with baby name
  ///
  /// In en, this message translates to:
  /// **'Take care of babies together with {name}'**
  String careTogetherWith(String name);

  /// No description provided for @inviteFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite family or partners to\nmanage baby care records together'**
  String get inviteFamilyDescription;

  /// No description provided for @generateInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Invitation Code'**
  String get generateInviteCode;

  /// No description provided for @generateInviteCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a new invitation code and copy it'**
  String get generateInviteCodeDescription;

  /// No description provided for @generateInviteCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Invitation Code'**
  String get generateInviteCodeButton;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orText;

  /// No description provided for @enterInviteCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the invitation code you received'**
  String get enterInviteCodeDescription;

  /// No description provided for @inviteCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code (6 digits)'**
  String get inviteCodePlaceholder;

  /// No description provided for @acceptInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvite;

  /// Baby registration success message
  ///
  /// In en, this message translates to:
  /// **'{name} has been registered successfully'**
  String babyRegistrationSuccess(String name);

  /// No description provided for @babyRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Baby registration failed'**
  String get babyRegistrationFailed;

  /// Baby registration error message
  ///
  /// In en, this message translates to:
  /// **'Error occurred: {error}'**
  String babyRegistrationError(String error);

  /// Baby selection message
  ///
  /// In en, this message translates to:
  /// **'{name} has been selected'**
  String babySelected(String name);

  /// No description provided for @inviteCodeGeneratedStatus.
  ///
  /// In en, this message translates to:
  /// **'Invitation code generated!'**
  String get inviteCodeGeneratedStatus;

  /// Remaining time message
  ///
  /// In en, this message translates to:
  /// **'Remaining time: {time}'**
  String remainingTime(String time);

  /// No description provided for @validTime.
  ///
  /// In en, this message translates to:
  /// **'Valid time: 5 minutes'**
  String get validTime;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @joining.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get joining;

  /// No description provided for @noBabyInfo.
  ///
  /// In en, this message translates to:
  /// **'No Baby Information'**
  String get noBabyInfo;

  /// No description provided for @noBabyInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'No baby information found.\nWould you like to create a test baby?'**
  String get noBabyInfoDescription;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @generateNewInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Generate New Invitation Code'**
  String get generateNewInviteCode;

  /// No description provided for @replaceExistingCode.
  ///
  /// In en, this message translates to:
  /// **'This will replace the existing invitation code.\nDo you want to continue?'**
  String get replaceExistingCode;

  /// No description provided for @acceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitation;

  /// No description provided for @acceptInvitationDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept the invitation and join the family?'**
  String get acceptInvitationDescription;

  /// Warning message when accepting invitation
  ///
  /// In en, this message translates to:
  /// **'Existing baby records will be deleted and replaced with the invited baby ({babyName}).\n\nDo you want to continue?'**
  String acceptInvitationWarning(String babyName);

  /// No description provided for @pleaseEnterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the invitation code'**
  String get pleaseEnterInviteCode;

  /// No description provided for @inviteCodeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Invitation code must be 6 digits'**
  String get inviteCodeMustBe6Digits;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'No login information found. Please login first.'**
  String get pleaseLoginFirst;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Invitation code copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @joinedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined the family!'**
  String get joinedSuccessfully;

  /// Error message for expired invite code
  ///
  /// In en, this message translates to:
  /// **'The generated invite code has expired. Please generate a new one.'**
  String get inviteCodeExpired;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation code'**
  String get invalidInviteCode;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this family'**
  String get alreadyMember;

  /// No description provided for @cannotInviteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot invite yourself'**
  String get cannotInviteSelf;

  /// Time format for remaining time
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String minutesAndSeconds(int minutes, int seconds);

  /// Baby guide title with baby name
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Baby Care Guide'**
  String babyGuideTitle(String name);

  /// No description provided for @babyGuide.
  ///
  /// In en, this message translates to:
  /// **'Baby Care Guide'**
  String get babyGuide;

  /// No description provided for @noAvailableGuides.
  ///
  /// In en, this message translates to:
  /// **'No available guides'**
  String get noAvailableGuides;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Possessive form of baby name
  ///
  /// In en, this message translates to:
  /// **'{name}\'s'**
  String babysGuide(String name);

  /// Week guide title
  ///
  /// In en, this message translates to:
  /// **'{weekText} Guide'**
  String weekGuide(String weekText);

  /// No description provided for @feedingGuide.
  ///
  /// In en, this message translates to:
  /// **'💡 Feeding Guide'**
  String get feedingGuide;

  /// No description provided for @feedingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Feeding Frequency'**
  String get feedingFrequency;

  /// No description provided for @singleFeedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Feeding Amount'**
  String get singleFeedingAmount;

  /// No description provided for @dailyTotal.
  ///
  /// In en, this message translates to:
  /// **'Daily Total'**
  String get dailyTotal;

  /// No description provided for @additionalTips.
  ///
  /// In en, this message translates to:
  /// **'📋 Additional Tips'**
  String get additionalTips;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get understood;

  /// No description provided for @newborn.
  ///
  /// In en, this message translates to:
  /// **'Newborn'**
  String get newborn;

  /// Week number format
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekNumber(int number);

  /// No description provided for @newbornWeek0.
  ///
  /// In en, this message translates to:
  /// **'Newborn (Week 0)'**
  String get newbornWeek0;

  /// Daily frequency range format
  ///
  /// In en, this message translates to:
  /// **'Daily {min} - {max} times'**
  String dailyFrequencyRange(int min, int max);

  /// Daily minimum frequency format
  ///
  /// In en, this message translates to:
  /// **'Daily {min}+ times'**
  String dailyFrequencyMin(int min);

  /// Daily maximum frequency format
  ///
  /// In en, this message translates to:
  /// **'Daily up to {max} times'**
  String dailyFrequencyMax(int max);

  /// Amount range in ml format
  ///
  /// In en, this message translates to:
  /// **'{min}ml - {max}ml'**
  String amountRangeML(int min, int max);

  /// Minimum amount in ml format
  ///
  /// In en, this message translates to:
  /// **'{min}ml or more'**
  String amountMinML(int min);

  /// Maximum amount in ml format
  ///
  /// In en, this message translates to:
  /// **'Up to {max}ml'**
  String amountMaxML(int max);

  /// Message shown when there are insufficient feeding records for pattern analysis
  ///
  /// In en, this message translates to:
  /// **'Insufficient feeding records'**
  String get insufficientFeedingRecords;

  /// Message shown when there are no recent feeding records
  ///
  /// In en, this message translates to:
  /// **'No recent feeding records'**
  String get noRecentFeeding;

  /// Language selection screen title
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// Instruction to select a language
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get selectLanguage;

  /// Current language label
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// Placeholder text for community search input
  ///
  /// In en, this message translates to:
  /// **'Search community posts'**
  String get searchCommunityPosts;

  /// No description provided for @temperatureRecord.
  ///
  /// In en, this message translates to:
  /// **'Temperature Record'**
  String get temperatureRecord;

  /// No description provided for @temperatureTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature Trend'**
  String get temperatureTrend;

  /// No description provided for @profilePhotoSetup.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo Setup'**
  String get profilePhotoSetup;

  /// No description provided for @howToSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'How would you like to select a photo?'**
  String get howToSelectPhoto;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordReset;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address.\nWe\'ll send you a password reset link.'**
  String get enterEmailForReset;

  /// No description provided for @accountWithdrawalComplete.
  ///
  /// In en, this message translates to:
  /// **'Account Withdrawal Complete'**
  String get accountWithdrawalComplete;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender: '**
  String get genderLabel;

  /// No description provided for @birthdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthdate: '**
  String get birthdateLabel;

  /// No description provided for @maleGender.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleGender;

  /// No description provided for @femaleGender.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleGender;

  /// No description provided for @joinWithInviteCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Join with Invite Code'**
  String get joinWithInviteCodeButton;

  /// No description provided for @temperatureRecorded.
  ///
  /// In en, this message translates to:
  /// **'Temperature recorded'**
  String get temperatureRecorded;

  /// No description provided for @recordFailed.
  ///
  /// In en, this message translates to:
  /// **'Record failed'**
  String recordFailed(String error);

  /// Success message for temperature settings save
  ///
  /// In en, this message translates to:
  /// **'Temperature settings saved'**
  String get temperatureSettingsSaved;

  /// No description provided for @loadingUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading user information. Please try again in a moment.'**
  String get loadingUserInfo;

  /// No description provided for @continueWithSeparateAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue with separate account'**
  String get continueWithSeparateAccount;

  /// No description provided for @linkWithExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'Link with existing account'**
  String get linkWithExistingAccount;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @accountLinkingComplete.
  ///
  /// In en, this message translates to:
  /// **'Account Linking Complete'**
  String get accountLinkingComplete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmation;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @babyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby Name'**
  String get babyNameLabel;

  /// No description provided for @weightInput.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get weightInput;

  /// No description provided for @heightInput.
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get heightInput;

  /// No description provided for @measurementNotes.
  ///
  /// In en, this message translates to:
  /// **'Record measurement conditions or special notes (optional)'**
  String get measurementNotes;

  /// No description provided for @urine.
  ///
  /// In en, this message translates to:
  /// **'Urine'**
  String get urine;

  /// No description provided for @stool.
  ///
  /// In en, this message translates to:
  /// **'Stool'**
  String get stool;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// Bottle feeding option
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottle;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @illness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get illness;

  /// No description provided for @highFever.
  ///
  /// In en, this message translates to:
  /// **'High Fever'**
  String get highFever;

  /// Oral administration route option
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get oral;

  /// No description provided for @inhalation.
  ///
  /// In en, this message translates to:
  /// **'Inhalation'**
  String get inhalation;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injection;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// Drops unit option
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @teaspoon.
  ///
  /// In en, this message translates to:
  /// **'Teaspoon'**
  String get teaspoon;

  /// No description provided for @tablespoon.
  ///
  /// In en, this message translates to:
  /// **'Tablespoon'**
  String get tablespoon;

  /// Label for sleep quality
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// No description provided for @pumpingTime.
  ///
  /// In en, this message translates to:
  /// **'Pumping'**
  String get pumpingTime;

  /// No description provided for @solidFoodTime.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFoodTime;

  /// No description provided for @totalFeedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Total feeding amount'**
  String get totalFeedingAmount;

  /// Label for average feeding amount metric
  ///
  /// In en, this message translates to:
  /// **'Average feeding amount'**
  String get averageFeedingAmount;

  /// Label for daily average feeding count metric
  ///
  /// In en, this message translates to:
  /// **'Daily average feeding count'**
  String get dailyAverageFeedingCount;

  /// No description provided for @clinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get clinical;

  /// No description provided for @infoSharing.
  ///
  /// In en, this message translates to:
  /// **'Info Sharing'**
  String get infoSharing;

  /// No description provided for @sleepIssues.
  ///
  /// In en, this message translates to:
  /// **'Sleep Issues'**
  String get sleepIssues;

  /// No description provided for @babyFoodCategory.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get babyFoodCategory;

  /// No description provided for @developmentStage.
  ///
  /// In en, this message translates to:
  /// **'Development Stage'**
  String get developmentStage;

  /// No description provided for @vaccinationCategory.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccinationCategory;

  /// No description provided for @postpartumRecovery.
  ///
  /// In en, this message translates to:
  /// **'Postpartum Recovery'**
  String get postpartumRecovery;

  /// No description provided for @dailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get dailyLife;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @armpit.
  ///
  /// In en, this message translates to:
  /// **'Armpit'**
  String get armpit;

  /// No description provided for @forehead.
  ///
  /// In en, this message translates to:
  /// **'Forehead'**
  String get forehead;

  /// No description provided for @ear.
  ///
  /// In en, this message translates to:
  /// **'Ear'**
  String get ear;

  /// No description provided for @mouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get mouth;

  /// No description provided for @rectal.
  ///
  /// In en, this message translates to:
  /// **'Rectal'**
  String get rectal;

  /// No description provided for @otherLocation.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherLocation;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get searchError;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @searchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Search suggestions'**
  String get searchSuggestions;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @likeFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Like feature coming soon'**
  String get likeFeatureComingSoon;

  /// No description provided for @popularSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Popular search terms'**
  String get popularSearchTerms;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @sortByComments.
  ///
  /// In en, this message translates to:
  /// **'Sort by comments'**
  String get sortByComments;

  /// No description provided for @detailInformation.
  ///
  /// In en, this message translates to:
  /// **'Detail Information'**
  String get detailInformation;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recordAgain.
  ///
  /// In en, this message translates to:
  /// **'Record Again'**
  String get recordAgain;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @deleteRecordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteRecordConfirmation;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeleted;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get editRecord;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for medication dosage
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// Label for unit
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @wet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wet;

  /// No description provided for @dirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes...'**
  String get notesHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get smartInsights;

  /// No description provided for @analyzingPatterns.
  ///
  /// In en, this message translates to:
  /// **'Analyzing patterns...'**
  String get analyzingPatterns;

  /// No description provided for @insightsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} insights found'**
  String insightsFound(int count);

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to analyze patterns yet'**
  String get noInsightsYet;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @sleepProgressMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes in progress'**
  String sleepProgressMinutes(int minutes);

  /// No description provided for @sleepProgressTime.
  ///
  /// In en, this message translates to:
  /// **'Sleep Progress Time'**
  String get sleepProgressTime;

  /// No description provided for @standardFeedingTimeNow.
  ///
  /// In en, this message translates to:
  /// **'It\'s standard feeding time'**
  String get standardFeedingTimeNow;

  /// No description provided for @standardFeedingTimeSoon.
  ///
  /// In en, this message translates to:
  /// **'Standard feeding time coming soon ({minutes} minutes)'**
  String standardFeedingTimeSoon(int minutes);

  /// No description provided for @timeUntilStandardFeedingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes until standard feeding'**
  String timeUntilStandardFeedingHours(int hours, int minutes);

  /// No description provided for @timeUntilStandardFeedingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes until standard feeding'**
  String timeUntilStandardFeedingMinutes(int minutes);

  /// No description provided for @insufficientFeedingRecordsApplyingStandard.
  ///
  /// In en, this message translates to:
  /// **'Insufficient feeding records (applying standard interval)'**
  String get insufficientFeedingRecordsApplyingStandard;

  /// No description provided for @standardFeedingTimeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Standard feeding time is overdue'**
  String get standardFeedingTimeOverdue;

  /// No description provided for @hoursMinutesFormat.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutesFormat(int hours, int minutes);

  /// No description provided for @minutesFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesFormat(int minutes);

  /// No description provided for @personalPatternInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal pattern: {interval} interval (for reference)'**
  String personalPatternInfo(String interval);

  /// No description provided for @longPressForDetails.
  ///
  /// In en, this message translates to:
  /// **'Long press for details'**
  String get longPressForDetails;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @future.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get future;

  /// No description provided for @previousDate.
  ///
  /// In en, this message translates to:
  /// **'Previous date'**
  String get previousDate;

  /// No description provided for @nextDate.
  ///
  /// In en, this message translates to:
  /// **'Next date'**
  String get nextDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @checkStandardFeedingInterval.
  ///
  /// In en, this message translates to:
  /// **'Check standard feeding interval'**
  String get checkStandardFeedingInterval;

  /// No description provided for @registerBabyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please register your baby'**
  String get registerBabyFirst;

  /// No description provided for @registerBabyToRecordMoments.
  ///
  /// In en, this message translates to:
  /// **'To record your baby\'s precious moments,\nplease register baby information first.'**
  String get registerBabyToRecordMoments;

  /// No description provided for @addBabyFromHome.
  ///
  /// In en, this message translates to:
  /// **'Add baby from home'**
  String get addBabyFromHome;

  /// No description provided for @timesUnit.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get timesUnit;

  /// No description provided for @itemsUnit.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemsUnit;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'times/day'**
  String get timesPerDay;

  /// No description provided for @activityDistributionByCategory.
  ///
  /// In en, this message translates to:
  /// **'Activity Distribution by Category'**
  String get activityDistributionByCategory;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'Total count'**
  String get totalCount;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesCount(int count);

  /// No description provided for @noDetailedData.
  ///
  /// In en, this message translates to:
  /// **'No detailed data'**
  String get noDetailedData;

  /// No description provided for @averageFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'Average feeding time'**
  String get averageFeedingTime;

  /// No description provided for @averageSleepTime.
  ///
  /// In en, this message translates to:
  /// **'Average sleep time'**
  String get averageSleepTime;

  /// No description provided for @dailyAverageTotalSleepTime.
  ///
  /// In en, this message translates to:
  /// **'Daily average total sleep time'**
  String get dailyAverageTotalSleepTime;

  /// Label for daily average sleep count metric
  ///
  /// In en, this message translates to:
  /// **'Daily average sleep count'**
  String get dailyAverageSleepCount;

  /// No description provided for @dailyAverageChangeCount.
  ///
  /// In en, this message translates to:
  /// **'Daily average change count'**
  String get dailyAverageChangeCount;

  /// No description provided for @sharingParentingStories.
  ///
  /// In en, this message translates to:
  /// **'Sharing Parenting Stories'**
  String get sharingParentingStories;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// 12:00 AM - midnight time label
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// AM - morning time period label
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get morning;

  /// 12:00 PM - noon time label
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get noon;

  /// PM - afternoon time period label
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get afternoon;

  /// Quick selection label for date presets
  ///
  /// In en, this message translates to:
  /// **'Quick Selection'**
  String get quickSelection;

  /// Custom settings label for date range
  ///
  /// In en, this message translates to:
  /// **'Custom Settings'**
  String get customSettings;

  /// Select date range button text
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// Recent 7 days preset label
  ///
  /// In en, this message translates to:
  /// **'Recent 7 Days'**
  String get recent7Days;

  /// Recent 14 days preset label
  ///
  /// In en, this message translates to:
  /// **'Recent 14 Days'**
  String get recent14Days;

  /// Recent 30 days preset label
  ///
  /// In en, this message translates to:
  /// **'Recent 30 Days'**
  String get recent30Days;

  /// Description text for period selection dialog
  ///
  /// In en, this message translates to:
  /// **'Please select the period for analysis'**
  String get selectPeriodForAnalysis;

  /// Instructions for using card settings
  ///
  /// In en, this message translates to:
  /// **'• Toggle switches to show/hide cards\n• Drag to change card order\n• Changes are previewed in real time'**
  String get cardSettingsInstructions;

  /// Card visible status
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// Card hidden status
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// Hint text to set default values
  ///
  /// In en, this message translates to:
  /// **'Touch to set default values'**
  String get touchToSetDefault;

  /// Message asking about unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel changes and return to previous state?'**
  String get unsavedChangesMessage;

  /// Message asking about exiting without saving
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit without saving changes?'**
  String get unsavedChangesExitMessage;

  /// Button to exit without saving
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitWithoutSaving;

  /// General saving error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving'**
  String get savingError;

  /// Family members section title
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// Error message when family member info cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Cannot load family member information'**
  String get cannotLoadFamilyMembersInfo;

  /// Administrator role label
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// Member role label
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Join date label with date parameter
  ///
  /// In en, this message translates to:
  /// **'Join date: {date}'**
  String joinDate(String date);

  /// Description for inviting family members when family group exists
  ///
  /// In en, this message translates to:
  /// **'Invite family members to manage baby records together'**
  String get inviteFamilyMembersDescription;

  /// Warning message when joining a family group
  ///
  /// In en, this message translates to:
  /// **'Do you want to join {familyName}\'s family?\n\nExisting baby data will be moved to the new family group.'**
  String joinFamilyGroupWarning(String familyName);

  /// Success message when family invitation is accepted
  ///
  /// In en, this message translates to:
  /// **'Family invitation accepted! Now you can manage baby records together.'**
  String get familyInvitationAccepted;

  /// Header message when user has a family group
  ///
  /// In en, this message translates to:
  /// **'Caring for baby together with {familyName}'**
  String careTogetherWithFamily(String familyName);

  /// Title of feeding time notification
  ///
  /// In en, this message translates to:
  /// **'It\'s feeding time! 🍼'**
  String get feedingTimeNotificationTitle;

  /// Body text of feeding time notification
  ///
  /// In en, this message translates to:
  /// **'Baby might be hungry now.'**
  String get feedingTimeNotificationBody;

  /// Android notification channel name for feeding alarms
  ///
  /// In en, this message translates to:
  /// **'Feeding Reminders'**
  String get feedingAlarmChannelName;

  /// Android notification channel description for feeding alarms
  ///
  /// In en, this message translates to:
  /// **'Feeding time reminder notifications'**
  String get feedingAlarmChannelDescription;

  /// Label for average feeding duration metric
  ///
  /// In en, this message translates to:
  /// **'Average feeding duration'**
  String get averageFeedingDuration;

  /// Label for average sleep duration metric
  ///
  /// In en, this message translates to:
  /// **'Average sleep duration'**
  String get averageSleepDuration;

  /// Label for daily total sleep duration metric
  ///
  /// In en, this message translates to:
  /// **'Daily total sleep duration'**
  String get dailyTotalSleepDuration;

  /// Label for daily average diaper change count metric
  ///
  /// In en, this message translates to:
  /// **'Daily average diaper changes'**
  String get dailyAverageDiaperChangeCount;

  /// Label for daily average medication count metric
  ///
  /// In en, this message translates to:
  /// **'Daily average medication count'**
  String get dailyAverageMedicationCount;

  /// Label for medication types used metric
  ///
  /// In en, this message translates to:
  /// **'Types of medication used'**
  String get medicationTypesUsed;

  /// Label for total pumped amount metric
  ///
  /// In en, this message translates to:
  /// **'Total pumped amount'**
  String get totalPumpedAmount;

  /// Label for average pumped amount metric
  ///
  /// In en, this message translates to:
  /// **'Average pumped amount'**
  String get averagePumpedAmount;

  /// Tab label for count metrics
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countTab;

  /// Tab label for amount/time metrics
  ///
  /// In en, this message translates to:
  /// **'Amount/Time'**
  String get amountTimeTab;

  /// Tab label for duration metrics
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationTab;

  /// Message displayed while chart data is loading
  ///
  /// In en, this message translates to:
  /// **'Loading chart data...'**
  String get chartDataLoading;

  /// Message displayed when chart data is not available
  ///
  /// In en, this message translates to:
  /// **'Chart data not available.'**
  String get chartDataNotAvailable;

  /// Label prefix for average values in charts
  ///
  /// In en, this message translates to:
  /// **'Average: '**
  String get averageLabel;

  /// Chart title for daily feeding count
  ///
  /// In en, this message translates to:
  /// **'Daily feeding count'**
  String get dailyFeedingCountTitle;

  /// Weekday abbreviations from Sunday to Saturday (concatenated for parsing)
  ///
  /// In en, this message translates to:
  /// **'SunMonTueWedThuFriSat'**
  String get weekdaysSundayToSaturday;

  /// Format for displaying day numbers
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String dayFormat(int day);

  /// Chart title for daily feeding count
  ///
  /// In en, this message translates to:
  /// **'Daily feeding count'**
  String get dailyFeedingCount;

  /// Chart title for daily feeding amount
  ///
  /// In en, this message translates to:
  /// **'Daily feeding amount'**
  String get dailyFeedingAmount;

  /// Chart title for daily feeding duration
  ///
  /// In en, this message translates to:
  /// **'Daily feeding duration'**
  String get dailyFeedingDuration;

  /// Chart title for daily sleep count
  ///
  /// In en, this message translates to:
  /// **'Daily sleep count'**
  String get dailySleepCount;

  /// Chart title for daily sleep duration
  ///
  /// In en, this message translates to:
  /// **'Daily sleep duration'**
  String get dailySleepDuration;

  /// Chart title for daily diaper changes
  ///
  /// In en, this message translates to:
  /// **'Daily diaper changes'**
  String get dailyDiaperChangeCount;

  /// Chart title for daily medication count
  ///
  /// In en, this message translates to:
  /// **'Daily medication count'**
  String get dailyMedicationCount;

  /// Chart title for daily pumping count
  ///
  /// In en, this message translates to:
  /// **'Daily pumping count'**
  String get dailyMilkPumpingCount;

  /// Chart title for daily pumping amount
  ///
  /// In en, this message translates to:
  /// **'Daily pumping amount'**
  String get dailyMilkPumpingAmount;

  /// Chart title for daily solid food count
  ///
  /// In en, this message translates to:
  /// **'Daily solid food count'**
  String get dailySolidFoodCount;

  /// Label for daily average solid food count metric
  ///
  /// In en, this message translates to:
  /// **'Daily average solid food count'**
  String get dailyAverageSolidFoodCount;

  /// Label for types of food tried metric
  ///
  /// In en, this message translates to:
  /// **'Types of food tried'**
  String get triedFoodTypes;

  /// No description provided for @babyTemperatureRecord.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Temperature Record'**
  String babyTemperatureRecord(String name);

  /// No description provided for @adjustWithSlider.
  ///
  /// In en, this message translates to:
  /// **'Adjust with slider'**
  String get adjustWithSlider;

  /// No description provided for @measurementMethod.
  ///
  /// In en, this message translates to:
  /// **'Measurement method'**
  String get measurementMethod;

  /// No description provided for @normalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal range'**
  String get normalRange;

  /// No description provided for @normalRangeForAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Normal range ({ageGroup}): {min}°C - {max}°C'**
  String normalRangeForAgeGroup(String ageGroup, String min, String max);

  /// No description provided for @saveTemperatureRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Temperature Record'**
  String get saveTemperatureRecord;

  /// No description provided for @enterTemperature.
  ///
  /// In en, this message translates to:
  /// **'Please enter temperature'**
  String get enterTemperature;

  /// No description provided for @temperatureRangeValidation.
  ///
  /// In en, this message translates to:
  /// **'Temperature must be between 34.0°C ~ 42.0°C'**
  String get temperatureRangeValidation;

  /// No description provided for @recordSymptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Please record symptoms or special notes'**
  String get recordSymptomsHint;

  /// No description provided for @oralMethod.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get oralMethod;

  /// No description provided for @analMethod.
  ///
  /// In en, this message translates to:
  /// **'Anal'**
  String get analMethod;

  /// No description provided for @recentDaysTrend.
  ///
  /// In en, this message translates to:
  /// **'Recent {days} days trend'**
  String recentDaysTrend(int days);

  /// No description provided for @days3.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get days3;

  /// No description provided for @days7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get days7;

  /// No description provided for @weeks2.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get weeks2;

  /// No description provided for @month1.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get month1;

  /// No description provided for @noTemperatureRecordsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No temperature records in selected period'**
  String get noTemperatureRecordsInPeriod;

  /// No description provided for @temperatureChangeTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature Change Trend'**
  String get temperatureChangeTrend;

  /// No description provided for @averageTemperature.
  ///
  /// In en, this message translates to:
  /// **'Average Temperature'**
  String get averageTemperature;

  /// No description provided for @highestTemperature.
  ///
  /// In en, this message translates to:
  /// **'Highest Temperature'**
  String get highestTemperature;

  /// No description provided for @lowestTemperature.
  ///
  /// In en, this message translates to:
  /// **'Lowest Temperature'**
  String get lowestTemperature;

  /// No description provided for @noteAvailableTapToView.
  ///
  /// In en, this message translates to:
  /// **'📝 Note available (tap to view)'**
  String get noteAvailableTapToView;

  /// No description provided for @temperatureRisingTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature is showing a rising trend'**
  String get temperatureRisingTrend;

  /// No description provided for @temperatureFallingTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature is showing a falling trend'**
  String get temperatureFallingTrend;

  /// No description provided for @temperatureStableTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature is stable'**
  String get temperatureStableTrend;

  /// No description provided for @trendAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Trend Analysis'**
  String get trendAnalysis;

  /// No description provided for @totalMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Total {count} measurements'**
  String totalMeasurements(int count);

  /// No description provided for @temperatureRecordMemo.
  ///
  /// In en, this message translates to:
  /// **'Temperature Record Memo'**
  String get temperatureRecordMemo;

  /// No description provided for @babyGrowthChart.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Growth Chart'**
  String babyGrowthChart(String name);

  /// No description provided for @noGrowthRecords.
  ///
  /// In en, this message translates to:
  /// **'No growth records'**
  String get noGrowthRecords;

  /// No description provided for @enterWeightAndHeightFromHome.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight and height from home screen'**
  String get enterWeightAndHeightFromHome;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @growthInsights.
  ///
  /// In en, this message translates to:
  /// **'Growth Insights'**
  String get growthInsights;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate'**
  String get growthRate;

  /// No description provided for @monthlyAverageGrowth.
  ///
  /// In en, this message translates to:
  /// **'Monthly Average Growth'**
  String get monthlyAverageGrowth;

  /// No description provided for @dataInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Data Insufficient'**
  String get dataInsufficient;

  /// No description provided for @twoOrMoreRequired.
  ///
  /// In en, this message translates to:
  /// **'2 or more required'**
  String get twoOrMoreRequired;

  /// No description provided for @recentDaysBasis.
  ///
  /// In en, this message translates to:
  /// **'Based on recent {days} days'**
  String recentDaysBasis(int days);

  /// No description provided for @entireBasis.
  ///
  /// In en, this message translates to:
  /// **'Based on entire period'**
  String get entireBasis;

  /// No description provided for @oneMonthPrediction.
  ///
  /// In en, this message translates to:
  /// **'1 Month Prediction'**
  String get oneMonthPrediction;

  /// No description provided for @currentTrendBasis.
  ///
  /// In en, this message translates to:
  /// **'Based on current trend'**
  String get currentTrendBasis;

  /// No description provided for @predictionNotPossible.
  ///
  /// In en, this message translates to:
  /// **'Prediction not possible'**
  String get predictionNotPossible;

  /// No description provided for @trendInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Trend insufficient'**
  String get trendInsufficient;

  /// No description provided for @recordFrequency.
  ///
  /// In en, this message translates to:
  /// **'Record Frequency'**
  String get recordFrequency;

  /// No description provided for @veryConsistent.
  ///
  /// In en, this message translates to:
  /// **'Very Consistent'**
  String get veryConsistent;

  /// No description provided for @consistent.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get consistent;

  /// No description provided for @irregular.
  ///
  /// In en, this message translates to:
  /// **'Irregular'**
  String get irregular;

  /// No description provided for @averageDaysInterval.
  ///
  /// In en, this message translates to:
  /// **'Average {days} days interval'**
  String averageDaysInterval(String days);

  /// No description provided for @nextRecord.
  ///
  /// In en, this message translates to:
  /// **'Next Record'**
  String get nextRecord;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @daysLater.
  ///
  /// In en, this message translates to:
  /// **'{days} days later'**
  String daysLater(int days);

  /// No description provided for @daysAgoRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded {days} days ago'**
  String daysAgoRecorded(int days);

  /// No description provided for @weeklyRecordRecommended.
  ///
  /// In en, this message translates to:
  /// **'Weekly record recommended'**
  String get weeklyRecordRecommended;

  /// No description provided for @nextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next Milestone'**
  String get nextMilestone;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'{value}{unit} target'**
  String targetValue(String value, String unit);

  /// No description provided for @remainingProgress.
  ///
  /// In en, this message translates to:
  /// **'{remaining}{unit} remaining ({progress}% achieved)'**
  String remainingProgress(String remaining, String unit, String progress);

  /// No description provided for @calculationNotPossible.
  ///
  /// In en, this message translates to:
  /// **'Calculation not possible'**
  String get calculationNotPossible;

  /// No description provided for @periodInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Period insufficient'**
  String get periodInsufficient;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @weightRecordRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight record required'**
  String get weightRecordRequired;

  /// No description provided for @heightRecordRequired.
  ///
  /// In en, this message translates to:
  /// **'Height record required'**
  String get heightRecordRequired;

  /// No description provided for @currentRecordMissing.
  ///
  /// In en, this message translates to:
  /// **'Current record missing'**
  String get currentRecordMissing;

  /// No description provided for @noRecord.
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get noRecord;

  /// No description provided for @firstRecordStart.
  ///
  /// In en, this message translates to:
  /// **'Start your first record'**
  String get firstRecordStart;

  /// No description provided for @oneRecord.
  ///
  /// In en, this message translates to:
  /// **'1 record'**
  String get oneRecord;

  /// No description provided for @moreRecordsNeeded.
  ///
  /// In en, this message translates to:
  /// **'More records needed'**
  String get moreRecordsNeeded;

  /// No description provided for @sameDayRecord.
  ///
  /// In en, this message translates to:
  /// **'Same day record'**
  String get sameDayRecord;

  /// No description provided for @recordedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} times recorded'**
  String recordedTimes(int count);

  /// No description provided for @storageMethod.
  ///
  /// In en, this message translates to:
  /// **'Storage Method'**
  String get storageMethod;

  /// No description provided for @pumpingType.
  ///
  /// In en, this message translates to:
  /// **'Pumping Type'**
  String get pumpingType;

  /// Label for food name
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @texture.
  ///
  /// In en, this message translates to:
  /// **'Texture'**
  String get texture;

  /// No description provided for @reaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get reaction;

  /// No description provided for @measurementLocation.
  ///
  /// In en, this message translates to:
  /// **'Measurement Location'**
  String get measurementLocation;

  /// No description provided for @feverReducerGiven.
  ///
  /// In en, this message translates to:
  /// **'Fever Reducer Given'**
  String get feverReducerGiven;

  /// No description provided for @given.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get given;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Refrigerator storage option
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get refrigerator;

  /// Freezer storage option
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get freezer;

  /// Room temperature storage option
  ///
  /// In en, this message translates to:
  /// **'Room Temperature'**
  String get roomTemperature;

  /// No description provided for @fedImmediately.
  ///
  /// In en, this message translates to:
  /// **'Fed Immediately'**
  String get fedImmediately;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight Change'**
  String get weightChange;

  /// No description provided for @heightChange.
  ///
  /// In en, this message translates to:
  /// **'Height Change'**
  String get heightChange;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @totalChange.
  ///
  /// In en, this message translates to:
  /// **'Total Change'**
  String get totalChange;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @weightDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weight data available'**
  String get weightDataEmpty;

  /// No description provided for @heightDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'No height data available'**
  String get heightDataEmpty;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @feedingRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Feeding record deleted'**
  String get feedingRecordDeleted;

  /// No description provided for @sleepRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sleep record deleted'**
  String get sleepRecordDeleted;

  /// No description provided for @diaperRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Diaper record deleted'**
  String get diaperRecordDeleted;

  /// No description provided for @healthRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Health record deleted'**
  String get healthRecordDeleted;

  /// No description provided for @deletionError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during deletion'**
  String get deletionError;

  /// No description provided for @duplicateInputDetected.
  ///
  /// In en, this message translates to:
  /// **'Duplicate input detected'**
  String get duplicateInputDetected;

  /// No description provided for @solidFoodDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just recorded solid food.\\nDo you really want to record it again?'**
  String get solidFoodDuplicateConfirm;

  /// No description provided for @cannotOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Cannot open settings screen'**
  String get cannotOpenSettings;

  /// Good sleep quality option
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepQualityGood;

  /// Fair sleep quality option
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get sleepQualityFair;

  /// Poor sleep quality option
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleepQualityPoor;

  /// No description provided for @sleepInProgressDuration.
  ///
  /// In en, this message translates to:
  /// **'Sleeping - {minutes}m elapsed'**
  String sleepInProgressDuration(Object minutes);

  /// No description provided for @wetOnly.
  ///
  /// In en, this message translates to:
  /// **'Wet Only'**
  String get wetOnly;

  /// No description provided for @dirtyOnly.
  ///
  /// In en, this message translates to:
  /// **'Dirty Only'**
  String get dirtyOnly;

  /// No description provided for @wetAndDirty.
  ///
  /// In en, this message translates to:
  /// **'Wet + Dirty'**
  String get wetAndDirty;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @consistencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistencyLabel;

  /// No description provided for @topicalMedication.
  ///
  /// In en, this message translates to:
  /// **'Topical'**
  String get topicalMedication;

  /// No description provided for @inhaledMedication.
  ///
  /// In en, this message translates to:
  /// **'Inhaled'**
  String get inhaledMedication;

  /// No description provided for @milkPumpingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Pumping'**
  String get milkPumpingInProgress;

  /// No description provided for @pumpingInProgressDuration.
  ///
  /// In en, this message translates to:
  /// **'Pumping - {minutes}m elapsed'**
  String pumpingInProgressDuration(Object minutes);

  /// No description provided for @lowGradeFever.
  ///
  /// In en, this message translates to:
  /// **'Low Grade Fever'**
  String get lowGradeFever;

  /// Smart insight message for normal temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature is normal'**
  String get normalTemperature;

  /// No description provided for @allActivities.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allActivities;

  /// No description provided for @temperatureFilter.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureFilter;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?\nDeleted records cannot be recovered.'**
  String get deleteRecordMessage;

  /// No description provided for @recordDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record has been deleted'**
  String get recordDeletedSuccess;

  /// No description provided for @recordDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete record'**
  String get recordDeleteFailed;

  /// No description provided for @recordDeleteError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the record'**
  String get recordDeleteError;

  /// No description provided for @recordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record has been updated'**
  String get recordUpdatedSuccess;

  /// No description provided for @recordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update record'**
  String get recordUpdateFailed;

  /// No description provided for @recordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating the record'**
  String get recordUpdateError;

  /// No description provided for @noRecordsToday.
  ///
  /// In en, this message translates to:
  /// **'No {recordType} records today'**
  String noRecordsToday(Object recordType);

  /// No description provided for @healthRecordRestored.
  ///
  /// In en, this message translates to:
  /// **'Health record has been restored'**
  String get healthRecordRestored;

  /// No description provided for @deleteTemperatureConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the recent temperature record?'**
  String get deleteTemperatureConfirm;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @duplicateEntryDetected.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Entry Detected'**
  String get duplicateEntryDetected;

  /// No description provided for @feedingDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just added a feeding record.\\nDo you really want to record again?'**
  String get feedingDuplicateConfirm;

  /// No description provided for @milkPumpingDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just added a milk pumping record.\\nDo you really want to record again?'**
  String get milkPumpingDuplicateConfirm;

  /// No description provided for @medicationDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just recorded medication.\\nDo you really want to record again?'**
  String get medicationDuplicateConfirm;

  /// No description provided for @diaperDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just recorded a diaper change.\\nDo you really want to record again?'**
  String get diaperDuplicateConfirm;

  /// No description provided for @sleepStartDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just manipulated sleep.\\nDo you really want to start sleeping?'**
  String get sleepStartDuplicateConfirm;

  /// No description provided for @sleepEndDuplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'You just manipulated sleep.\\nDo you really want to end sleeping?'**
  String get sleepEndDuplicateConfirm;

  /// No description provided for @recordAction.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordAction;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @whatTypeChanged.
  ///
  /// In en, this message translates to:
  /// **'What type did you change?'**
  String get whatTypeChanged;

  /// No description provided for @poop.
  ///
  /// In en, this message translates to:
  /// **'Poop'**
  String get poop;

  /// No description provided for @urinePoop.
  ///
  /// In en, this message translates to:
  /// **'Urine+Poop'**
  String get urinePoop;

  /// No description provided for @changeType.
  ///
  /// In en, this message translates to:
  /// **'Change Type'**
  String get changeType;

  /// No description provided for @colorWhenPoop.
  ///
  /// In en, this message translates to:
  /// **'Color (When Poop)'**
  String get colorWhenPoop;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutesShort;

  /// No description provided for @totalFeedingDuration.
  ///
  /// In en, this message translates to:
  /// **'Total feeding duration'**
  String get totalFeedingDuration;

  /// No description provided for @maximumFeedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum feeding amount'**
  String get maximumFeedingAmount;

  /// No description provided for @minimumFeedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum feeding amount'**
  String get minimumFeedingAmount;

  /// No description provided for @totalSleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Total sleep duration'**
  String get totalSleepDuration;

  /// No description provided for @dailyTotalMilkPumpingAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily total pumped amount'**
  String get dailyTotalMilkPumpingAmount;

  /// No description provided for @maximumSleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Maximum sleep duration'**
  String get maximumSleepDuration;

  /// No description provided for @minimumSleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Minimum sleep duration'**
  String get minimumSleepDuration;

  /// No description provided for @allergicReactionCount.
  ///
  /// In en, this message translates to:
  /// **'Allergic reaction count'**
  String get allergicReactionCount;

  /// No description provided for @dailyAverageMilkPumpingCount.
  ///
  /// In en, this message translates to:
  /// **'Daily average milk pumping count'**
  String get dailyAverageMilkPumpingCount;

  /// Title for growth information record dialog
  ///
  /// In en, this message translates to:
  /// **'Growth Information Record'**
  String get growthInfoRecord;

  /// Instructions to record baby's current weight
  ///
  /// In en, this message translates to:
  /// **'Please record baby\'s current weight'**
  String get recordBabyCurrentWeight;

  /// Instructions to record baby's current height
  ///
  /// In en, this message translates to:
  /// **'Please record baby\'s current height'**
  String get recordBabyCurrentHeight;

  /// Label for measurement items section
  ///
  /// In en, this message translates to:
  /// **'Measurement Items'**
  String get measurementItems;

  /// Label for optional memo field
  ///
  /// In en, this message translates to:
  /// **'Memo (Optional)'**
  String get memoOptional;

  /// Placeholder text for weight input
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// Placeholder text for height input
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get enterHeight;

  /// Hint text for weight measurement notes
  ///
  /// In en, this message translates to:
  /// **'Record special notes when measuring weight (optional)'**
  String get recordSpecialNotesWeight;

  /// Hint text for height measurement notes
  ///
  /// In en, this message translates to:
  /// **'Record special notes when measuring height (optional)'**
  String get recordSpecialNotesHeight;

  /// Validation error for invalid weight number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number for weight'**
  String get weightInvalidNumber;

  /// Validation error for weight out of range
  ///
  /// In en, this message translates to:
  /// **'Weight should be between 0.1~50kg'**
  String get weightRangeError;

  /// Validation error for invalid height number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number for height'**
  String get heightInvalidNumber;

  /// Validation error for height out of range
  ///
  /// In en, this message translates to:
  /// **'Height should be between 1~200cm'**
  String get heightRangeError;

  /// Validation error when neither weight nor height is entered
  ///
  /// In en, this message translates to:
  /// **'Please enter weight or height'**
  String get enterWeightOrHeight;

  /// Error message when saving fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving'**
  String get saveError;

  /// Smart insight message for sufficient feeding amount
  ///
  /// In en, this message translates to:
  /// **'You had a sufficient amount of feeding'**
  String get sufficientFeedingAmount;

  /// Smart insight message about expected feeding satisfaction
  ///
  /// In en, this message translates to:
  /// **'This amount is expected to provide sufficient satisfaction for the baby.'**
  String get expectedSatisfaction;

  /// Smart insight message for nighttime feeding
  ///
  /// In en, this message translates to:
  /// **'It\'s nighttime feeding time'**
  String get nightFeedingTime;

  /// Smart insight message about nighttime feeding impact
  ///
  /// In en, this message translates to:
  /// **'Nighttime feeding helps baby\'s growth, but may affect parents\' sleep patterns.'**
  String get nightFeedingImpact;

  /// Smart insight label for next expected feeding time
  ///
  /// In en, this message translates to:
  /// **'Next expected feeding time'**
  String get nextExpectedFeedingTime;

  /// Smart insight message about next feeding timing
  ///
  /// In en, this message translates to:
  /// **'Generally, the next feeding may be needed in 2-3 hours.'**
  String get nextFeedingIn2to3Hours;

  /// Smart insight message for long sleep
  ///
  /// In en, this message translates to:
  /// **'It was a long sleep duration'**
  String get longSleepDuration;

  /// Smart insight message for good sleep duration with parameter
  ///
  /// In en, this message translates to:
  /// **'Slept for {duration} hours. This is a good sign for baby\'s growth and development.'**
  String goodSleepForGrowth(String duration);

  /// Smart insight message for short sleep
  ///
  /// In en, this message translates to:
  /// **'It was a short sleep'**
  String get shortSleepDuration;

  /// Smart insight advice for sleep environment
  ///
  /// In en, this message translates to:
  /// **'Check the environment so that short naps or sleep interruptions don\'t occur.'**
  String get checkSleepEnvironment;

  /// Smart insight message for good sleep quality
  ///
  /// In en, this message translates to:
  /// **'It was good sleep quality'**
  String get goodSleepQuality;

  /// Smart insight message about good sleep benefits
  ///
  /// In en, this message translates to:
  /// **'Good sleep helps baby\'s brain development and immune system improvement.'**
  String get goodSleepBenefits;

  /// Smart insight message for dirty diaper change
  ///
  /// In en, this message translates to:
  /// **'Dirty diaper change'**
  String get diaperChangeDirty;

  /// Smart insight message about normal digestion
  ///
  /// In en, this message translates to:
  /// **'This is a good sign that baby\'s digestive function is working normally.'**
  String get normalDigestionSign;

  /// Smart insight label for diaper change frequency
  ///
  /// In en, this message translates to:
  /// **'Diaper change frequency'**
  String get diaperChangeFrequency;

  /// Smart insight message about good diaper change frequency
  ///
  /// In en, this message translates to:
  /// **'It\'s been {hours} hours since the last change. You\'re maintaining a good change frequency.'**
  String goodDiaperChangeFrequency(int hours);

  /// Smart insight message for medication record completion
  ///
  /// In en, this message translates to:
  /// **'Medication record completed'**
  String get medicationRecordComplete;

  /// Smart insight message about medication being recorded with parameter
  ///
  /// In en, this message translates to:
  /// **'{medicationName} medication has been recorded. Accurate recording helps improve treatment effectiveness.'**
  String medicationRecorded(String medicationName);

  /// Generic smart insight message for medication record completion
  ///
  /// In en, this message translates to:
  /// **'Medication record has been completed.'**
  String get medicationRecordCompleteGeneric;

  /// Smart insight message for morning medication
  ///
  /// In en, this message translates to:
  /// **'Morning medication time'**
  String get morningMedicationTime;

  /// Smart insight message about morning medication benefits
  ///
  /// In en, this message translates to:
  /// **'Morning medication helps maintain drug effectiveness throughout the day.'**
  String get morningMedicationBenefit;

  /// Smart insight message for effective pumping
  ///
  /// In en, this message translates to:
  /// **'It was effective pumping'**
  String get effectivePumping;

  /// Smart insight message about good pumping amount with parameter
  ///
  /// In en, this message translates to:
  /// **'Pumped {amount}ml. This is a good amount that helps with breast milk storage.'**
  String goodPumpingAmount(int amount);

  /// Smart insight label for pumping improvement tip
  ///
  /// In en, this message translates to:
  /// **'Pumping improvement tip'**
  String get pumpingImprovementTip;

  /// Smart insight advice for low pumping amount
  ///
  /// In en, this message translates to:
  /// **'The pumping amount is low. Adequate water intake and stress management can help.'**
  String get lowPumpingAdvice;

  /// Smart insight message for morning pumping
  ///
  /// In en, this message translates to:
  /// **'Morning pumping time'**
  String get morningPumpingTime;

  /// Smart insight message about morning pumping benefits
  ///
  /// In en, this message translates to:
  /// **'Morning time is the best time for pumping due to high prolactin levels.'**
  String get morningPumpingBenefit;

  /// Smart insight message when baby likes food
  ///
  /// In en, this message translates to:
  /// **'Baby likes the food'**
  String get babyLikesFood;

  /// Smart insight message about good food reaction with parameter
  ///
  /// In en, this message translates to:
  /// **'Had a good reaction to {foodName}. Consider adding this food to the diet.'**
  String goodFoodReaction(String foodName);

  /// Generic smart insight message about good food reaction
  ///
  /// In en, this message translates to:
  /// **'Had a good reaction to the food.'**
  String get goodFoodReactionGeneric;

  /// Smart insight message for lunchtime solid food
  ///
  /// In en, this message translates to:
  /// **'Lunchtime solid food'**
  String get lunchTimeSolidFood;

  /// Smart insight message about lunchtime food benefits
  ///
  /// In en, this message translates to:
  /// **'Lunchtime solid food helps establish baby\'s eating habits.'**
  String get lunchTimeFoodBenefit;

  /// Smart insight label for nutritional balance
  ///
  /// In en, this message translates to:
  /// **'Nutritional balance management'**
  String get nutritionalBalance;

  /// Smart insight message about variety food benefits
  ///
  /// In en, this message translates to:
  /// **'Alternating solid food made with various ingredients helps with nutritional balance.'**
  String get varietyFoodBenefit;

  /// Smart insight message for high temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature is high'**
  String get highTemperature;

  /// Smart insight warning message for high temperature with parameter
  ///
  /// In en, this message translates to:
  /// **'Temperature is {temperature}°C, which is relatively high. Continuous observation is needed.'**
  String highTemperatureWarning(String temperature);

  /// Smart insight message for low temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature is low'**
  String get lowTemperature;

  /// Smart insight warning message for low temperature with parameter
  ///
  /// In en, this message translates to:
  /// **'Temperature is {temperature}°C, which is relatively low. Please pay attention to keeping warm.'**
  String lowTemperatureWarning(String temperature);

  /// Smart insight message for normal temperature range with parameter
  ///
  /// In en, this message translates to:
  /// **'Temperature is {temperature}°C, which is within the normal range.'**
  String normalTemperatureRange(String temperature);

  /// Smart insight label for regular temperature check
  ///
  /// In en, this message translates to:
  /// **'Regular temperature check'**
  String get regularTemperatureCheck;

  /// Smart insight message about regular temperature check benefits
  ///
  /// In en, this message translates to:
  /// **'Regular temperature checks are recommended to monitor baby\'s health condition.'**
  String get regularTemperatureCheckBenefit;

  /// Smart insight message for consistent recording
  ///
  /// In en, this message translates to:
  /// **'Records are being kept consistently well'**
  String get consistentRecording;

  /// Smart insight message about regular recording benefits
  ///
  /// In en, this message translates to:
  /// **'Regular recording helps with baby health management.'**
  String get regularRecordingBenefit;

  /// Diaper color: Yellow
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get diaperColorYellow;

  /// Diaper color: Brown
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get diaperColorBrown;

  /// Diaper color: Green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get diaperColorGreen;

  /// Diaper color: Black
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get diaperColorBlack;

  /// Diaper color: Orange
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get diaperColorOrange;

  /// Diaper consistency: Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get diaperConsistencyNormal;

  /// Diaper consistency: Loose
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get diaperConsistencyLoose;

  /// Diaper consistency: Hard
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diaperConsistencyHard;

  /// Diaper consistency: Watery
  ///
  /// In en, this message translates to:
  /// **'Watery'**
  String get diaperConsistencyWatery;

  /// Food name: Rice porridge
  ///
  /// In en, this message translates to:
  /// **'Rice porridge'**
  String get foodRicePorridge;

  /// Food name: Rice cereal
  ///
  /// In en, this message translates to:
  /// **'Rice cereal'**
  String get foodBabyRiceCereal;

  /// Food name: Banana
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get foodBanana;

  /// Food name: Apple
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get foodApple;

  /// Food name: Carrot
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get foodCarrot;

  /// Food name: Pumpkin
  ///
  /// In en, this message translates to:
  /// **'Pumpkin'**
  String get foodPumpkin;

  /// Food name: Sweet potato
  ///
  /// In en, this message translates to:
  /// **'Sweet potato'**
  String get foodSweetPotato;

  /// Medication name: Fever reducer
  ///
  /// In en, this message translates to:
  /// **'Fever reducer'**
  String get medicationFeverReducer;

  /// Medication name: Cold medicine
  ///
  /// In en, this message translates to:
  /// **'Cold medicine'**
  String get medicationColdMedicine;

  /// Medication name: Digestive aid
  ///
  /// In en, this message translates to:
  /// **'Digestive aid'**
  String get medicationDigestiveAid;

  /// Medication name: Pain reliever
  ///
  /// In en, this message translates to:
  /// **'Pain reliever'**
  String get medicationPainReliever;

  /// Medication name: Antibiotics
  ///
  /// In en, this message translates to:
  /// **'Antibiotics'**
  String get medicationAntibiotics;

  /// Medication name: Vitamins
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get medicationVitamins;

  /// Default value settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Default Settings'**
  String get defaultValueSettings;

  /// Description for setting default values
  ///
  /// In en, this message translates to:
  /// **'Set default values for quick recording'**
  String get setDefaultValuesForQuickRecording;

  /// Formula milk feeding option
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formulaMilk;

  /// Solid food feeding option
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFoodFeeding;

  /// Label for feeding amount in milliliters
  ///
  /// In en, this message translates to:
  /// **'Feeding Amount (ml)'**
  String get feedingAmountMl;

  /// Label for feeding time in minutes
  ///
  /// In en, this message translates to:
  /// **'Feeding Time (minutes)'**
  String get feedingTimeMinutes;

  /// Label for feeding position
  ///
  /// In en, this message translates to:
  /// **'Feeding Position'**
  String get feedingPosition;

  /// Label for sleep time in minutes
  ///
  /// In en, this message translates to:
  /// **'Sleep Time (minutes)'**
  String get sleepTimeMinutes;

  /// Label for sleep location
  ///
  /// In en, this message translates to:
  /// **'Sleep Location'**
  String get sleepLocation;

  /// Bedroom sleep location option
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get bedroom;

  /// Living room sleep location option
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get livingRoom;

  /// Stroller sleep location option
  ///
  /// In en, this message translates to:
  /// **'Stroller'**
  String get stroller;

  /// Car sleep location option
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// Outdoors sleep location option
  ///
  /// In en, this message translates to:
  /// **'Outdoors'**
  String get outdoors;

  /// Label for stool color when diaper is dirty
  ///
  /// In en, this message translates to:
  /// **'Color (when dirty)'**
  String get stoolColorWhenDirty;

  /// Label for stool consistency when diaper is dirty
  ///
  /// In en, this message translates to:
  /// **'Consistency (when dirty)'**
  String get stoolConsistencyWhenDirty;

  /// Greenish diaper color option
  ///
  /// In en, this message translates to:
  /// **'Greenish'**
  String get diaperColorGreenish;

  /// White diaper color option
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get diaperColorWhite;

  /// Loose diaper consistency option
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get diaperConsistencyLooseAlt;

  /// Hard diaper consistency option
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diaperConsistencyHardAlt;

  /// Label for amount in grams
  ///
  /// In en, this message translates to:
  /// **'Amount (g)'**
  String get amountGrams;

  /// Label for allergic reaction
  ///
  /// In en, this message translates to:
  /// **'Allergic Reaction'**
  String get allergicReaction;

  /// No allergic reaction option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get allergicReactionNone;

  /// Mild allergic reaction option
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get allergicReactionMild;

  /// Moderate allergic reaction option
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get allergicReactionModerate;

  /// Severe allergic reaction option
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get allergicReactionSevere;

  /// Tablets unit option
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get tablets;

  /// Label for administration route
  ///
  /// In en, this message translates to:
  /// **'Administration Route'**
  String get administrationRoute;

  /// Label for pumping amount in milliliters
  ///
  /// In en, this message translates to:
  /// **'Pumping Amount (ml)'**
  String get pumpingAmountMl;

  /// Label for pumping time in minutes
  ///
  /// In en, this message translates to:
  /// **'Pumping Time (minutes)'**
  String get pumpingTimeMinutes;

  /// Label for pumping position
  ///
  /// In en, this message translates to:
  /// **'Pumping Position'**
  String get pumpingPosition;

  /// Label for storage location
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// Use immediately storage option
  ///
  /// In en, this message translates to:
  /// **'Use Immediately'**
  String get useImmediately;

  /// Error message for partial card settings save failure
  ///
  /// In en, this message translates to:
  /// **'Failed to save some card settings: {failedCards}'**
  String cardSettingsSavePartialFailure(String failedCards);

  /// Error message for feeding amount validation
  ///
  /// In en, this message translates to:
  /// **'Please enter feeding amount between 1-1000ml'**
  String get feedingAmountValidationError;

  /// Error message for feeding duration validation
  ///
  /// In en, this message translates to:
  /// **'Please enter feeding duration between 1-180 minutes'**
  String get feedingDurationValidationError;

  /// Error message for invite creation failure
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating invitation: {error}'**
  String inviteCreationError(String error);

  /// Error message for share failure
  ///
  /// In en, this message translates to:
  /// **'Sharing failed'**
  String get shareFailed;

  /// Error message for invite code generation failure
  ///
  /// In en, this message translates to:
  /// **'Invite code generation failed: {error}'**
  String inviteCodeGenerationFailed(String error);

  /// Error message for database save failure
  ///
  /// In en, this message translates to:
  /// **'Failed to save to database. Please try again'**
  String get databaseSaveFailed;

  /// Error message for growth record processing error
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing growth record'**
  String get growthRecordProcessingError;

  /// Error message for authentication failure
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authenticationFailed;

  /// Error message for verification code resend failure
  ///
  /// In en, this message translates to:
  /// **'Failed to resend verification code. Please try again later.'**
  String get verificationCodeResendFailed;

  /// Error message during account deletion
  ///
  /// In en, this message translates to:
  /// **'Error during account deletion'**
  String get accountDeletionError;

  /// Error message for baby info reset failure
  ///
  /// In en, this message translates to:
  /// **'Failed to reset {babyName} information. Please try again.'**
  String babyInfoResetFailed(String babyName);

  /// Error message during baby info reset
  ///
  /// In en, this message translates to:
  /// **'An error occurred during information reset: {error}'**
  String babyInfoResetError(String error);

  /// Success message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deletion completed successfully.\n\nYou can sign up again anytime.'**
  String get accountDeletionSuccess;

  /// Success message for renewed invite code
  ///
  /// In en, this message translates to:
  /// **'The existing code has expired and a new invite code has been generated: {code}'**
  String inviteCodeRenewed(String code);

  /// Success message for generated invite code
  ///
  /// In en, this message translates to:
  /// **'Invite code has been generated: {code}'**
  String inviteCodeGenerated(String code);

  /// Error message when no statistics data available to share
  ///
  /// In en, this message translates to:
  /// **'No statistics data to share'**
  String get noStatisticsDataToShare;

  /// Error message when no baby is selected
  ///
  /// In en, this message translates to:
  /// **'No baby information selected'**
  String get noBabySelected;

  /// Info message about image share feature under development
  ///
  /// In en, this message translates to:
  /// **'Image sharing feature is currently under development. Please use text sharing instead.'**
  String get imageShareFeatureUnderDevelopment;

  /// Warning message for partial logout errors
  ///
  /// In en, this message translates to:
  /// **'Some errors occurred during logout but continuing.'**
  String get logoutPartialError;

  /// Warning message for test mode invite creation
  ///
  /// In en, this message translates to:
  /// **'Test mode: Creating invitation with temporary user information.'**
  String get testModeInviteWarning;

  /// Warning message for iOS simulator camera limitation
  ///
  /// In en, this message translates to:
  /// **'Camera is not available on iOS Simulator.\nPlease try again from the gallery.'**
  String get iosSimulatorCameraWarning;

  /// Info message for baby long press functionality
  ///
  /// In en, this message translates to:
  /// **'Long press on baby to reset information'**
  String get babyLongPressHint;

  /// Info message to wait
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Info message for baby information reset
  ///
  /// In en, this message translates to:
  /// **'Baby Information Reset'**
  String get babyInfoReset;

  /// Info message while resetting baby information
  ///
  /// In en, this message translates to:
  /// **'Resetting {babyName} information...'**
  String babyInfoResetting(String babyName);

  /// Info message for database update completion
  ///
  /// In en, this message translates to:
  /// **'✅ Database has been updated!\n\nPlease restart the app and try again.'**
  String get databaseUpdated;

  /// No description provided for @confirmDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?\nDeleted posts cannot be recovered.'**
  String get confirmDeletePost;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post has been deleted.'**
  String get postDeleted;

  /// No description provided for @commentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment has been updated.'**
  String get commentUpdated;

  /// No description provided for @confirmDeleteComment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?\nDeleted comments cannot be recovered.'**
  String get confirmDeleteComment;

  /// No description provided for @commentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment has been deleted.'**
  String get commentDeleted;

  /// No description provided for @shareFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Share feature is under development'**
  String get shareFeatureInDevelopment;

  /// No description provided for @sortByRecent.
  ///
  /// In en, this message translates to:
  /// **'Sort by Recent'**
  String get sortByRecent;

  /// No description provided for @replyCreated.
  ///
  /// In en, this message translates to:
  /// **'Reply has been posted.'**
  String get replyCreated;

  /// No description provided for @commentCreated.
  ///
  /// In en, this message translates to:
  /// **'Comment has been posted.'**
  String get commentCreated;

  /// No description provided for @commentCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment.'**
  String get commentCreationFailed;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Reply to specific person
  ///
  /// In en, this message translates to:
  /// **'Reply to {nickname}'**
  String replyTo(String nickname);

  /// No description provided for @writeReply.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get writeReply;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// View more replies
  ///
  /// In en, this message translates to:
  /// **'View {count} more replies'**
  String moreReplies(int count);

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @commentCopied.
  ///
  /// In en, this message translates to:
  /// **'Comment has been copied'**
  String get commentCopied;

  /// No description provided for @reportComment.
  ///
  /// In en, this message translates to:
  /// **'Report Comment'**
  String get reportComment;

  /// No description provided for @confirmReportComment.
  ///
  /// In en, this message translates to:
  /// **'Do you want to report this comment?\nIt will be reported as inappropriate content or spam.'**
  String get confirmReportComment;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report has been submitted.'**
  String get reportSubmitted;

  /// No description provided for @serviceInPreparation.
  ///
  /// In en, this message translates to:
  /// **'💝 Service in Preparation'**
  String get serviceInPreparation;

  /// No description provided for @upcomingServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'We will soon introduce useful parenting information and products'**
  String get upcomingServiceDescription;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @userID.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userID;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @loginMethod.
  ///
  /// In en, this message translates to:
  /// **'Login Method'**
  String get loginMethod;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion'**
  String get accountDeletion;

  /// No description provided for @allDataWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data will be permanently deleted'**
  String get allDataWillBePermanentlyDeleted;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ The following data will be permanently deleted when you delete your account:'**
  String get accountDeletionWarning;

  /// No description provided for @userAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'• User account information'**
  String get userAccountInfo;

  /// No description provided for @allRegisteredBabyInfo.
  ///
  /// In en, this message translates to:
  /// **'• All registered baby information'**
  String get allRegisteredBabyInfo;

  /// No description provided for @allTimelineRecords.
  ///
  /// In en, this message translates to:
  /// **'• All timeline records'**
  String get allTimelineRecords;

  /// No description provided for @allCommunityPosts.
  ///
  /// In en, this message translates to:
  /// **'• All community posts and comments'**
  String get allCommunityPosts;

  /// No description provided for @allInvitationHistory.
  ///
  /// In en, this message translates to:
  /// **'• All invitation history'**
  String get allInvitationHistory;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @accountDeletionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Account deletion completed.\n(Forced completion due to long processing time)'**
  String get accountDeletionCompleted;

  /// No description provided for @accountDeletionCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deletion successfully completed.\n\nYou can sign up again at any time.'**
  String get accountDeletionCompletedSuccess;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @monthsUnit.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthsUnit;

  /// No description provided for @yearsUnit.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get yearsUnit;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirmButton;

  /// No description provided for @accountDeletionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion Complete'**
  String get accountDeletionCompleteTitle;

  /// No description provided for @resetBaby.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetBaby;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date: '**
  String get birthDateLabel;

  /// No description provided for @genderColon.
  ///
  /// In en, this message translates to:
  /// **'Gender: '**
  String get genderColon;

  /// No description provided for @babyInfoResetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset {babyName} information from the beginning?'**
  String babyInfoResetQuestion(Object babyName);

  /// No description provided for @recordsWillBeReset.
  ///
  /// In en, this message translates to:
  /// **'The following records will be reset'**
  String get recordsWillBeReset;

  /// No description provided for @feedingSleepDiaperRecords.
  ///
  /// In en, this message translates to:
  /// **'Feeding, sleep, diaper records'**
  String get feedingSleepDiaperRecords;

  /// No description provided for @growthInfoAndPhotos.
  ///
  /// In en, this message translates to:
  /// **'Growth information and photos'**
  String get growthInfoAndPhotos;

  /// No description provided for @allBabyRelatedData.
  ///
  /// In en, this message translates to:
  /// **'All baby-related data'**
  String get allBabyRelatedData;

  /// No description provided for @allRecordsWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'All records of {babyName} will be completely removed'**
  String allRecordsWillBeDeleted(Object babyName);

  /// No description provided for @babyResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{babyName} information has been successfully reset.'**
  String babyResetSuccessMessage(Object babyName);

  /// No description provided for @kakaoProvider.
  ///
  /// In en, this message translates to:
  /// **'KakaoTalk'**
  String get kakaoProvider;

  /// No description provided for @googleProvider.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleProvider;

  /// No description provided for @appleProvider.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get appleProvider;

  /// No description provided for @emailProvider.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailProvider;

  /// No description provided for @unknownProvider.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownProvider;

  /// No description provided for @accountDeletionPartialErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Some processing encountered issues but logout is completed.\n\nRedirecting to login screen.'**
  String get accountDeletionPartialErrorMessage;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @blockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserTitle;

  /// No description provided for @blockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to block this user?'**
  String get blockUserConfirm;

  /// No description provided for @blockUserDescription.
  ///
  /// In en, this message translates to:
  /// **'• You won\'t see posts and comments from blocked users\n• You can\'t send direct messages to each other\n• You can unblock at any time'**
  String get blockUserDescription;

  /// No description provided for @blockReason.
  ///
  /// In en, this message translates to:
  /// **'Block Reason (Optional)'**
  String get blockReason;

  /// No description provided for @blockReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment/Threats'**
  String get blockReasonHarassment;

  /// No description provided for @blockReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam/Advertisement'**
  String get blockReasonSpam;

  /// No description provided for @blockReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get blockReasonInappropriate;

  /// No description provided for @blockReasonHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate Speech'**
  String get blockReasonHateSpeech;

  /// No description provided for @blockReasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violent Content'**
  String get blockReasonViolence;

  /// No description provided for @blockReasonPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information Exposure'**
  String get blockReasonPersonalInfo;

  /// No description provided for @blockReasonSexualContent.
  ///
  /// In en, this message translates to:
  /// **'Sexual Content'**
  String get blockReasonSexualContent;

  /// No description provided for @blockReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get blockReasonOther;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockAction;

  /// No description provided for @unblockAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblockAction;

  /// No description provided for @blockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User has been blocked'**
  String get blockSuccess;

  /// No description provided for @blockFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to block user'**
  String get blockFailed;

  /// No description provided for @unblockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User has been unblocked'**
  String get unblockSuccess;

  /// No description provided for @unblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unblock user'**
  String get unblockFailed;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @blockedUsersManagement.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users Management'**
  String get blockedUsersManagement;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get noBlockedUsers;

  /// No description provided for @blockedUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'Posts and comments from blocked users will not be displayed'**
  String get blockedUsersDescription;

  /// No description provided for @unblockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to unblock this user?'**
  String get unblockConfirm;

  /// No description provided for @blockedOn.
  ///
  /// In en, this message translates to:
  /// **'Blocked on: {date}'**
  String blockedOn(Object date);

  /// No description provided for @blockReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Block reason: {reason}'**
  String blockReasonLabel(Object reason);

  /// No description provided for @loadingBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Loading blocked users...'**
  String get loadingBlockedUsers;

  /// No description provided for @failedToLoadBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load blocked users'**
  String get failedToLoadBlockedUsers;

  /// No description provided for @safetyAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Safety & Privacy'**
  String get safetyAndPrivacy;

  /// No description provided for @contentReporting.
  ///
  /// In en, this message translates to:
  /// **'Content Reporting'**
  String get contentReporting;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'tl',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tl':
      return AppLocalizationsTl();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
