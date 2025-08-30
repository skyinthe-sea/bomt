// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get user => 'ユーザー';

  @override
  String userInfoLoadFailed(String error) {
    return 'ユーザー情報の読み込みに失敗しました：$error';
  }

  @override
  String babyListLoadError(String error) {
    return '赤ちゃんリストの読み込み中にエラーが発生しました：$error';
  }

  @override
  String welcomeUser(String userName, Object nickname) {
    return '$nicknameさん、ようこそ！🎉';
  }

  @override
  String get registerBaby => '赤ちゃん登録';

  @override
  String get noBabiesRegistered => '登録された赤ちゃんがいません';

  @override
  String get registerFirstBaby => '最初の赤ちゃんを登録しましょう！';

  @override
  String get registerBabyButton => '赤ちゃんを登録';

  @override
  String birthday(int year, int month, int day) {
    return '誕生日：$year年$month月$day日';
  }

  @override
  String age(int days) {
    return '年齢：$days日';
  }

  @override
  String gender(String gender) {
    return '性別';
  }

  @override
  String get male => '男の子';

  @override
  String get female => '女の子';

  @override
  String get other => 'その他';

  @override
  String babyDetailScreen(String name) {
    return '$nameの詳細画面（近日公開）';
  }

  @override
  String get selectBirthdate => '生年月日を選択してください';

  @override
  String babyRegistered(String name) {
    return '$nameちゃんが登録されました！';
  }

  @override
  String registrationError(String error) {
    return '登録中にエラーが発生しました：$error';
  }

  @override
  String get enterBabyInfo => '赤ちゃんの情報を入力してください';

  @override
  String get babyName => '赤ちゃんの名前';

  @override
  String get babyNameHint => '例：太郎';

  @override
  String get babyNameRequired => '赤ちゃんの名前を入力してください';

  @override
  String get babyNameMinLength => '名前は2文字以上入力してください';

  @override
  String get selectBirthdateButton => '生年月日を選択';

  @override
  String selectedDate(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String get genderOptional => '性別（任意）';

  @override
  String get cancel => 'キャンセル';

  @override
  String get loginFailed => 'ログインに失敗しました';

  @override
  String loginError(String error) {
    return 'ログイン中にエラーが発生しました：$error';
  }

  @override
  String get appTagline => '赤ちゃんの成長記録を簡単に管理';

  @override
  String get termsNotice => 'ログインすることで、利用規約とプライバシーポリシーに同意したものとします';

  @override
  String get loginWithKakao => 'Kakaoでログイン';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get selectBirthDate => '生年月日を選択';

  @override
  String get pleasSelectBirthDate => '生年月日を選択してください';

  @override
  String get pleaseEnterBabyName => '赤ちゃんの名前を入力してください';

  @override
  String get nameMinLength => '名前は2文字以上入力してください';

  @override
  String dateFormat(String year, String month, String day) {
    return '$year年$month月$day日';
  }

  @override
  String get autoLogin => '自動ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => '本当にログアウトしますか？';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get appearance => '外観';

  @override
  String get home => 'ホーム';

  @override
  String get timeline => 'タイムライン';

  @override
  String get record => '記録';

  @override
  String get statistics => '統計';

  @override
  String get community => 'コミュニティ';

  @override
  String get comingSoon => '近日公開';

  @override
  String get timelineUpdateMessage => 'タイムライン機能は近日更新予定です';

  @override
  String get recordUpdateMessage => '記録機能は近日更新予定です';

  @override
  String get statisticsUpdateMessage => '統計機能は近日更新予定です';

  @override
  String get communityUpdateMessage => 'コミュニティ機能は近日更新予定です';

  @override
  String get todaySummary => '今日のまとめ';

  @override
  String get growthInfo => '成長情報';

  @override
  String get lastFeeding => '最後の授乳';

  @override
  String get healthy => '健康';

  @override
  String get feeding => '授乳';

  @override
  String get totalFeeding => '総授乳量';

  @override
  String get sleep => '睡眠';

  @override
  String get totalSleepTime => '総睡眠時間';

  @override
  String get cardSettings => 'カード設定';

  @override
  String get cardSettingsGuide => 'カード設定ガイド';

  @override
  String get cardSettingsDescription =>
      '• トグルスイッチでカードの表示/非表示を設定\n• ドラッグでカードの順序を変更\n• 変更内容はリアルタイムでプレビュー';

  @override
  String get cardVisible => '表示';

  @override
  String get cardHidden => '非表示';

  @override
  String get save => '保存';

  @override
  String get cardSettingsSaved => 'カード設定を保存しました';

  @override
  String get cardSettingsError => '設定保存中にエラーが発生しました';

  @override
  String get discardChanges => '変更を取り消して前の状態に戻りますか？';

  @override
  String get continueEditing => '編集を続ける';

  @override
  String get discardChangesExit => '変更を保存せずに終了しますか？';

  @override
  String get exit => '終了';

  @override
  String get diaper => 'おむつ';

  @override
  String get solidFood => '離乳食';

  @override
  String get medication => '投薬';

  @override
  String get milkPumping => '搾乳';

  @override
  String get temperature => '体温';

  @override
  String get growth => '成長';

  @override
  String get health => '健康';

  @override
  String feedingCount(Object count) {
    return '$count回';
  }

  @override
  String get feedingAmount => '授乳量';

  @override
  String get feedingRecordAdded => '授乳記録を追加しました';

  @override
  String get feedingRecordFailed => '授乳記録の追加に失敗しました';

  @override
  String get feedingRecordsLoadFailed => '授乳記録の読み込みに失敗しました';

  @override
  String get quickFeeding => 'クイック授乳';

  @override
  String get feedingTime => '授乳時間';

  @override
  String get feedingType => '授乳方法';

  @override
  String get breastfeeding => '母乳';

  @override
  String get bottleFeeding => 'ミルク';

  @override
  String get mixedFeeding => '混合';

  @override
  String sleepCount(Object count) {
    return '$count回';
  }

  @override
  String sleepDuration(Object hours, Object minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get sleepStarted => '睡眠を開始しました';

  @override
  String get sleepEnded => '睡眠が終了しました';

  @override
  String get sleepInProgress => '睡眠中';

  @override
  String get sleepRecordFailed => '睡眠記録の処理に失敗しました';

  @override
  String get sleepRecordsLoadFailed => '睡眠記録の読み込みに失敗しました';

  @override
  String get sleepTime => '入眠時間';

  @override
  String get wakeUpTime => '起床時間';

  @override
  String get sleepDurationLabel => '睡眠時間';

  @override
  String get napTime => 'お昼寝';

  @override
  String get nightSleep => '夜間睡眠';

  @override
  String diaperCount(Object count) {
    return '$count回';
  }

  @override
  String get diaperChanged => 'おむつ交換';

  @override
  String get diaperRecordAdded => 'おむつ交換記録を追加しました';

  @override
  String get diaperRecordFailed => 'おむつ記録の追加に失敗しました';

  @override
  String get diaperRecordsLoadFailed => 'おむつ記録の読み込みに失敗しました';

  @override
  String get wetDiaper => 'おしっこ';

  @override
  String get dirtyDiaper => 'うんち';

  @override
  String get bothDiaper => '両方';

  @override
  String wetCount(Object count) {
    return 'おしっこ$count回';
  }

  @override
  String dirtyCount(Object count) {
    return 'うんち$count回';
  }

  @override
  String bothCount(Object count) {
    return '両方$count回';
  }

  @override
  String get diaperType => 'おむつの種類';

  @override
  String get diaperChangeTime => '交換時間';

  @override
  String get weight => '体重';

  @override
  String get height => '身長';

  @override
  String get growthRecord => '成長記録';

  @override
  String get growthRecordAdded => '成長記録を追加しました';

  @override
  String get growthRecordFailed => '成長記録の保存に失敗しました';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get temperatureUnit => '°C';

  @override
  String get measurementType => '測定項目';

  @override
  String get measurementValue => '測定値';

  @override
  String get notes => 'メモ';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get temperatureRange => '体温は30.0°C〜45.0°Cの間で入力してください';

  @override
  String get weightRange => '体重は0.1kg〜50kgの間で入力してください';

  @override
  String get heightRange => '身長は1cm〜200cmの間で入力してください';

  @override
  String get enterValidNumber => '正しい数値を入力してください';

  @override
  String get recordGrowthInfo => '成長情報を記録';

  @override
  String currentMeasurement(Object type) {
    return '現在の$typeを入力';
  }

  @override
  String get measurementSituation => '測定状況や特記事項を記録してください（任意）';

  @override
  String get communityTitle => 'コミュニティ';

  @override
  String get writePost => '投稿する';

  @override
  String get post => '投稿';

  @override
  String get postTitle => 'タイトル';

  @override
  String get postContent => '内容';

  @override
  String get postTitleHint => 'タイトルを入力';

  @override
  String get postContentHint => '内容を入力してください...\n\n自由にお話しください。';

  @override
  String get selectCategory => 'カテゴリー選択';

  @override
  String get postCreated => '投稿が正常に作成されました！';

  @override
  String postCreateFailed(Object error) {
    return '投稿の作成に失敗しました：$error';
  }

  @override
  String get nickname => 'ニックネーム';

  @override
  String get nicknameSetup => 'ニックネーム設定';

  @override
  String get nicknameChange => 'ニックネーム変更';

  @override
  String get nicknameHint => 'ニックネームを入力';

  @override
  String get nicknameDescription =>
      'コミュニティで使用するニックネームを作成してください。\n他のユーザーに表示されます。';

  @override
  String get nicknameChangeDescription => '新しいニックネームに変更できます。';

  @override
  String get nicknameValidation => 'ひらがな、カタカナ、漢字、英語、数字、アンダースコア（_）使用可（2-20文字）';

  @override
  String get nicknameMinLength => 'ニックネームは2文字以上である必要があります';

  @override
  String get nicknameMaxLength => 'ニックネームは20文字以下である必要があります';

  @override
  String get nicknameInvalidChars => 'ひらがな、カタカナ、漢字、英語、数字、アンダースコア（_）のみ使用可能です';

  @override
  String get nicknameChanged => 'ニックネームが正常に変更されました！';

  @override
  String get startButton => '始める';

  @override
  String get changeButton => '変更';

  @override
  String characterCount(Object count) {
    return 'タイトル：$count/200';
  }

  @override
  String contentCharacterCount(Object count) {
    return '内容: $count/10000';
  }

  @override
  String imageCount(Object count) {
    return '画像：$count/5';
  }

  @override
  String get addImages => '画像追加';

  @override
  String imageSelectFailed(Object error) {
    return '画像選択に失敗しました：$error';
  }

  @override
  String get featureInDevelopment => '機能開発中';

  @override
  String get liveQA => '🔥 小児科医ライブQ&A';

  @override
  String get liveQADescription => '今日午後7時！皆さんのすべての質問に専門医がお答えします';

  @override
  String get likeOrder => 'いいね順';

  @override
  String get latestOrder => '最新順';

  @override
  String get userNotFound => 'ユーザー情報が見つかりません';

  @override
  String get statisticsTitle => '統計';

  @override
  String get noStatisticsData => '統計データがありません';

  @override
  String statisticsDescription(Object period) {
    return '$period期間中に記録されたアクティビティがありません。\n赤ちゃんのアクティビティを記録してみましょう！';
  }

  @override
  String get recordActivity => '活動を記録';

  @override
  String get viewOtherPeriod => '他の期間を表示';

  @override
  String get refresh => '更新';

  @override
  String get statisticsTips => '統計を表示するには？';

  @override
  String get statisticsTip1 => '授乳、睡眠、おむつ交換などのアクティビティを記録する';

  @override
  String get statisticsTip2 => '統計には最低1日分のデータが必要です';

  @override
  String get statisticsTip3 => 'ホーム画面から簡単に記録できます';

  @override
  String get saveAsImage => '画像として保存';

  @override
  String get saveAsImageDescription => '統計を画像として保存';

  @override
  String get shareAsText => 'テキストとして共有';

  @override
  String get shareAsTextDescription => '統計サマリーをテキストで共有';

  @override
  String get statisticsEmptyState => '統計データなし';

  @override
  String get retryButton => '再試行';

  @override
  String get detailsButton => '詳細';

  @override
  String get goHomeButton => 'ホームへ';

  @override
  String get applyButton => '適用';

  @override
  String get lastWeek => '先週';

  @override
  String get lastMonth => '先月';

  @override
  String get last3Months => '過去3か月';

  @override
  String get allTime => '全期間';

  @override
  String get viewOtherPeriodTitle => '他の期間を表示';

  @override
  String get familyInvitation => '家族招待';

  @override
  String get invitationDescription => '招待コードを使用して家族と一緒に赤ちゃんの記録を管理';

  @override
  String get createInvitation => '招待状作成';

  @override
  String get invitationCreated => '招待状が正常に作成されました';

  @override
  String invitationCreateFailed(Object error) {
    return '招待状の作成に失敗しました：$error';
  }

  @override
  String get invitationRole => '役割';

  @override
  String get invitationDuration => '有効期間';

  @override
  String get roleParent => '親';

  @override
  String get roleCaregiver => '保育者';

  @override
  String get roleGuardian => '保護者';

  @override
  String get roleParentDesc => '赤ちゃんの親としてすべての記録を管理できます';

  @override
  String get roleCaregiverDesc => '保育者として一部の記録を管理できます';

  @override
  String get roleGuardianDesc => '赤ちゃんの保護者として記録を閲覧できます';

  @override
  String get invitationGuide => '招待ガイド';

  @override
  String get invitationGuideDesc =>
      '家族メンバーを招待して一緒に赤ちゃんの記録を管理できます。招待された方はアプリインストール後、招待リンクから参加できます。';

  @override
  String get shareInvitation => '招待状を共有';

  @override
  String get shareImmediately => '今すぐ共有';

  @override
  String get invitationPreview => '招待状プレビュー';

  @override
  String invitationExpiry(Object duration) {
    return '$duration後に期限切れ';
  }

  @override
  String get joinWithCode => '招待コードで参加';

  @override
  String get invitationValidity => '招待状有効期間';

  @override
  String get testMode => 'テストモード：一時的なユーザー情報で招待状を作成';

  @override
  String get ok => 'OK';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get add => '追加';

  @override
  String get remove => '削除';

  @override
  String get confirm => '確認';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get loading => '読み込み中...';

  @override
  String get retry => '再試行';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '情報';

  @override
  String errorOccurred(Object error) {
    return 'エラーが発生しました：$error';
  }

  @override
  String get networkError => 'ネットワーク接続エラー';

  @override
  String get serverError => 'サーバーエラーが発生しました';

  @override
  String get validationError => '入力内容を確認してください';

  @override
  String get requiredField => '必須入力項目です';

  @override
  String get invalidInput => '無効な入力です';

  @override
  String get saveFailed => '保存に失敗しました';

  @override
  String get loadFailed => '読み込みに失敗しました';

  @override
  String get updateFailed => '更新に失敗しました';

  @override
  String get deleteFailed => '削除に失敗しました';

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
    return '$minutes分';
  }

  @override
  String durationHours(Object hours) {
    return '$hours時間';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String daysAgo(Object days) {
    return '$days日前';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours時間前';
  }

  @override
  String minutesAgo(Object minutes) {
    return '$minutes分前';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get thisWeek => '今週';

  @override
  String get thisMonth => '今月';

  @override
  String get medicationName => '薬品名';

  @override
  String get medicationDose => '用量';

  @override
  String get medicationTime => '投薬';

  @override
  String get medicationAdded => '投薬記録を追加しました';

  @override
  String get solidFoodType => '離乳食の種類';

  @override
  String solidFoodAmount(Object amount) {
    return '${amount}g';
  }

  @override
  String get solidFoodAdded => '離乳食記録を追加しました';

  @override
  String get milkPumpingAmount => '搾乳量';

  @override
  String get milkPumpingTime => '搾乳時間';

  @override
  String get milkPumpingAdded => '搾乳記録を追加しました';

  @override
  String get temperatureReading => '体温測定';

  @override
  String get temperatureNormal => '正常';

  @override
  String get temperatureHigh => '高熱';

  @override
  String get temperatureLow => '低体温';

  @override
  String get profilePhoto => 'プロフィール写真';

  @override
  String get profilePhotoUpdate => 'プロフィール写真更新';

  @override
  String get selectPhotoSource => '写真をどのように選択しますか？';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get photoUpdated => 'プロフィール写真を更新しました';

  @override
  String get photoUploadFailed => 'プロフィール写真の更新に失敗しました';

  @override
  String get photoUploading => '写真をアップロード中...';

  @override
  String get cameraNotAvailable => 'iOSシミュレーターではカメラを使用できません。\nギャラリーから選択してください。';

  @override
  String get cameraAccessError => 'カメラアクセスエラーが発生しました。\nギャラリーから選択してください。';

  @override
  String get addImage => '画像追加';

  @override
  String get removeImage => '画像削除';

  @override
  String maxImagesReached(Object count) {
    return '最大$count枚まで許可されています';
  }

  @override
  String ageMonthsAndDays(Object days, Object months) {
    return '$monthsか月$days日';
  }

  @override
  String get lastFeedingTime => '最後の授乳時間';

  @override
  String hoursAndMinutesAgo(Object hours, Object minutes) {
    return '$hours時間$minutes分前';
  }

  @override
  String nextFeedingSchedule(Object hours, Object minutes) {
    return '約$hours時間$minutes分後に授乳予定';
  }

  @override
  String nextFeedingScheduleMinutes(Object minutes) {
    return '約$minutes分後に授乳予定';
  }

  @override
  String get feedingTimeNow => '今が授乳時間です🍼';

  @override
  String feedingTimeSoon(Object minutes) {
    return 'もうすぐ授乳時間です（$minutes分後）';
  }

  @override
  String get feedingTimeOverdue => '授乳時間が過ぎました';

  @override
  String feedingAlarm(Object hours, Object minutes) {
    return '$hours時間$minutes分後に授乳アラーム';
  }

  @override
  String feedingAlarmMinutes(Object minutes) {
    return '$minutes分後に授乳アラーム';
  }

  @override
  String get times => '回';

  @override
  String get meals => '回';

  @override
  String get kilograms => 'kg';

  @override
  String get centimeters => 'cm';

  @override
  String get milliliters => 'ml';

  @override
  String get grams => 'g';

  @override
  String get hoursUnit => '時間';

  @override
  String get minutesUnit => '分';

  @override
  String get viewDetails => '詳細表示';

  @override
  String get firstRecord => '初回記録';

  @override
  String get noChange => '変化なし';

  @override
  String get inProgress => '進行中';

  @override
  String get scheduled => '予定';

  @override
  String get startBabyRecording => '赤ちゃんを登録して育児記録を始めましょう';

  @override
  String get registerBabyNow => '赤ちゃんを登録';

  @override
  String get joinWithInviteCode => '招待コードで参加';

  @override
  String get loadingBabyInfo => '赤ちゃん情報を読み込み中...';

  @override
  String get pleaseRegisterBaby => '設定で赤ちゃんを登録してください';

  @override
  String get goToSettings => '設定に移動';

  @override
  String get profilePhotoUpdated => 'プロフィール写真が更新されました。';

  @override
  String get profilePhotoUpdateFailed => 'プロフィール写真の更新に失敗しました';

  @override
  String diaperWetAndDirty(Object count) {
    return 'おしっこ+うんち$count回';
  }

  @override
  String diaperWetAndDirtySeparate(Object dirtyCount, Object wetCount) {
    return 'おしっこ$wetCount、うんち$dirtyCount';
  }

  @override
  String get sleepZeroHours => '0時間';

  @override
  String solidFoodMeals(Object count) {
    return '$count回';
  }

  @override
  String medicationScheduled(Object count) {
    return '約$count回';
  }

  @override
  String medicationTypes(Object vaccineCount, Object vitaminCount) {
    return '栄養剤$vitaminCount、ワクチン$vaccineCount';
  }

  @override
  String get feedingRecordAddFailed => '授乳記録の追加に失敗しました';

  @override
  String get diaperRecordAddFailed => 'おむつ記録の追加に失敗しました';

  @override
  String get sleepRecordProcessFailed => '睡眠記録の処理に失敗しました';

  @override
  String get hourActivityPattern => '24時間アクティビティパターン';

  @override
  String get touchClockInstruction => 'クロックをタッチして時間帯別のアクティビティを確認してください';

  @override
  String get touch => 'タッチ';

  @override
  String get noActivitiesInTimeframe => 'この時間帯にはアクティビティがありませんでした';

  @override
  String get activityPatternAnalysis => 'アクティビティパターン分析';

  @override
  String get todaysStory => '今日のストーリー';

  @override
  String preciousMoments(Object count) {
    return '$count個の大切な瞬間たち';
  }

  @override
  String get firstMomentMessage =>
      '最初の大切な瞬間を記録してみましょう。\n毎日の小さな変化が集まって大きな成長になります。';

  @override
  String get pattern => 'パターン';

  @override
  String get qualityGood => '良い';

  @override
  String get qualityExcellent => '素晴らしい';

  @override
  String get qualityFair => '普通';

  @override
  String get qualityPoor => '良くない';

  @override
  String get timeSlot => '時の時間帯';

  @override
  String get am => '午前';

  @override
  String get pm => '午後';

  @override
  String get activityConcentrationTime => '一日の中で活動が集中した時間帯';

  @override
  String get formula => '粉ミルク';

  @override
  String get breastMilk => '母乳';

  @override
  String get babyFood => '離乳食';

  @override
  String get left => '左';

  @override
  String get right => '右';

  @override
  String get both => '両方';

  @override
  String get sleeping => '睡眠中';

  @override
  String get hoursText => '時間';

  @override
  String get minutesText => '分';

  @override
  String get elapsed => '経過';

  @override
  String get urineOnly => 'おしっこのみ';

  @override
  String get stoolOnly => 'うんちのみ';

  @override
  String get urineAndStool => 'おしっこ + うんち';

  @override
  String get color => '色';

  @override
  String get consistency => '濃度';

  @override
  String get diaperChange => 'おむつ交換';

  @override
  String get oralMedication => '経口投薬';

  @override
  String get topical => '外用';

  @override
  String get inhaled => '吸入';

  @override
  String get pumping => '搾乳中';

  @override
  String get temperatureMeasurement => '体温測定';

  @override
  String get fever => '発熱';

  @override
  String get lowFever => '微熱';

  @override
  String get hypothermia => '低体温';

  @override
  String get normal => '正常';

  @override
  String get quality => '品質';

  @override
  String get weekly => '週間';

  @override
  String get monthly => '月間';

  @override
  String get custom => 'カスタム';

  @override
  String daysCount(Object count) {
    return '$count日間';
  }

  @override
  String noActivitiesRecordedInPeriod(Object period) {
    return '$period期間中に記録された活動がありません。';
  }

  @override
  String get recordBabyActivities => '赤ちゃんの活動を記録してみましょう！';

  @override
  String get howToViewStatistics => '統計を表示するには？';

  @override
  String get recordActivitiesLikeFeedingSleep => '授乳、睡眠、おむつ交換などの活動を記録してください';

  @override
  String get atLeastOneDayDataRequired => '統計を表示するには最低1日分のデータが必要です';

  @override
  String get canRecordEasilyFromHome => 'ホーム画面から簡単に記録できます';

  @override
  String get updating => '更新中...';

  @override
  String get lastUpdated => '最終更新:';

  @override
  String get periodSelection => '期間選択';

  @override
  String get daily => '日間';

  @override
  String get startDate => '開始日';

  @override
  String get endDate => '終了日';

  @override
  String get apply => '適用';

  @override
  String get pleaseSelectDate => '日付を選択してください';

  @override
  String get detailedStatistics => '詳細統計';

  @override
  String get chartAnalysis => 'チャート分析';

  @override
  String get overallActivityOverview => '全体活動概要';

  @override
  String get totalActivities => '総活動';

  @override
  String get activeCards => '有効なカード';

  @override
  String get dailyAverage => '日平均';

  @override
  String get activityDistributionByCard => 'カード別活動分布';

  @override
  String get cannotLoadData => 'データを読み込めません';

  @override
  String get tryAgain => '再試行';

  @override
  String get details => '詳細';

  @override
  String get goToHome => 'ホームへ';

  @override
  String get troubleshootingMethods => 'トラブルシューティング方法';

  @override
  String get shareStatistics => '統計を共有';

  @override
  String get communitySubtitle => 'みんなで共有する育児ストーリー';

  @override
  String get search => '検索';

  @override
  String get notification => '通知';

  @override
  String get searchFeatureComingSoon => '検索機能準備中です';

  @override
  String get communityWelcome => '💕 育児コミュニティ';

  @override
  String get communityWelcomeDescription => '他のご両親と育児の経験を共有し、貴重な情報を交換しましょう';

  @override
  String get categorySelection => 'カテゴリ選択';

  @override
  String get categoryAll => 'すべて';

  @override
  String get categoryPopular => '人気';

  @override
  String get categoryClinical => '臨床';

  @override
  String get categoryInfoSharing => '情報共有';

  @override
  String get categorySleepIssues => '睡眠問題';

  @override
  String get categoryBabyFood => '離乳食';

  @override
  String get categoryDevelopment => '発達段階';

  @override
  String get categoryVaccination => '予防接種';

  @override
  String get categoryPostpartum => '産後回復';

  @override
  String get sortByLikes => 'いいね順';

  @override
  String get sortByLatest => '最新順';

  @override
  String get edited => '(編集済み)';

  @override
  String commentsCount(Object count) {
    return 'コメント$count件';
  }

  @override
  String get deletePost => '投稿を削除';

  @override
  String get deletePostConfirm => '本当にこの投稿を削除しますか？\n削除した投稿は復元できません。';

  @override
  String get deletePostSuccess => '投稿が削除されました。';

  @override
  String deletePostError(Object error) {
    return '削除失敗: $error';
  }

  @override
  String get postNotFound => '投稿が見つかりません';

  @override
  String get shareFeatureComingSoon => '共有機能準備中です';

  @override
  String get loadingComments => 'コメントを読み込み中...';

  @override
  String get loadMoreComments => 'さらにコメントを表示';

  @override
  String get editComment => 'コメントを編集';

  @override
  String get editCommentHint => 'コメントを編集してください...';

  @override
  String get editCommentSuccess => 'コメントが更新されました。';

  @override
  String editCommentError(Object error) {
    return '編集失敗: $error';
  }

  @override
  String get deleteComment => 'コメントを削除';

  @override
  String get deleteCommentConfirm => '本当にこのコメントを削除しますか？\n削除したコメントは復元できません。';

  @override
  String get deleteCommentSuccess => 'コメントが削除されました。';

  @override
  String get replySuccess => '返信が投稿されました。';

  @override
  String get commentSuccess => 'コメントが投稿されました。';

  @override
  String get commentError => 'コメントの投稿に失敗しました。';

  @override
  String get titlePlaceholder => 'タイトルを入力';

  @override
  String get contentPlaceholder => '想いを共有してください...\n\n育児の経験を自由に書いてください。';

  @override
  String imageSelectionError(Object error) {
    return '画像選択失敗: $error';
  }

  @override
  String get userNotFoundError => 'ユーザー情報が見つかりません。';

  @override
  String get postCreateSuccess => '投稿が正常に作成されました！';

  @override
  String postCreateError(Object error) {
    return '投稿作成失敗: $error';
  }

  @override
  String titleCharacterCount(Object count) {
    return 'タイトル: $count/200';
  }

  @override
  String imageCountDisplay(Object count) {
    return '画像: $count/5';
  }

  @override
  String get addImageTooltip => '画像追加';

  @override
  String get allPostsChecked => 'すべての投稿を確認しました！ 👍';

  @override
  String get waitForNewPosts => '新しい投稿がアップロードされるまで少しお待ちください';

  @override
  String get noPostsYet => 'まだ投稿がありません';

  @override
  String get writeFirstPost => '最初の投稿を書いてみましょう！';

  @override
  String get loadingNewPosts => '新しい投稿を読み込み中...';

  @override
  String get failedToLoadPosts => '投稿の読み込みに失敗しました';

  @override
  String get checkNetworkAndRetry => 'ネットワーク接続を確認して、再度お試しください';

  @override
  String get categoryDailyLife => '日常生活';

  @override
  String get preparingTimeline => 'タイムラインを準備中...';

  @override
  String get noRecordedMoments => 'まだ記録された瞬間がありません';

  @override
  String get loadingTimeline => 'タイムラインを読み込み中...';

  @override
  String get noRecordsYet => 'まだ記録がありません';

  @override
  String noRecordsForDate(Object date) {
    return '$dateの記録はまだありません';
  }

  @override
  String noRecordsForDateAndFilter(Object date, Object filter) {
    return '$dateの$filter記録はありません';
  }

  @override
  String get cannotRecordFuture => '未来の記録はまだ作成できません';

  @override
  String get addFirstRecord => '最初の記録を追加してみましょう！';

  @override
  String get canAddPastRecord => '過去の記録を追加できます';

  @override
  String get addRecord => '記録を追加';

  @override
  String get viewOtherDates => '他の日付を表示';

  @override
  String get goToToday => '今日へ移動';

  @override
  String get quickRecordFromHome => 'ホーム画面から簡単に記録を追加できます';

  @override
  String detailViewComingSoon(String title) {
    return '$title詳細表示（封準備中）';
  }

  @override
  String get familyInvitationDescription => '招待コードで家族と一緒に育児記録を管理しましょう';

  @override
  String get babyManagement => '赤ちゃん管理';

  @override
  String get addBaby => '赤ちゃんを追加';

  @override
  String get noBabiesMessage => '登録された赤ちゃんがいません。\n赤ちゃんを追加してください。';

  @override
  String get switchToNextBaby => '次の赤ちゃんに切り替え';

  @override
  String get birthDate => '生年月日';

  @override
  String get registering => '登録中...';

  @override
  String get register => '登録';

  @override
  String careTogetherWith(String name) {
    return '$nameと一緒に育児しましょう';
  }

  @override
  String get inviteFamilyDescription => '家族やパートナーを招待して\n一緒に育児記録を管理しましょう';

  @override
  String get generateInviteCode => '招待コード生成';

  @override
  String get generateInviteCodeDescription => '新しい招待コードを生成してコピーしてください';

  @override
  String get generateInviteCodeButton => '招待コード生成';

  @override
  String get orText => 'または';

  @override
  String get enterInviteCodeDescription => '受け取った招待コードを入力してください';

  @override
  String get inviteCodePlaceholder => '招待コード（6桁）';

  @override
  String get acceptInvite => '招待を受諾';

  @override
  String babyRegistrationSuccess(String name) {
    return '$nameが正常に登録されました';
  }

  @override
  String get babyRegistrationFailed => '赤ちゃんの登録に失敗しました';

  @override
  String babyRegistrationError(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String babySelected(String name) {
    return '$nameが選択されました';
  }

  @override
  String get inviteCodeGenerated => '招待コード生成完了！';

  @override
  String remainingTime(String time) {
    return '残り時間: $time';
  }

  @override
  String get validTime => '有効時間: 5分';

  @override
  String get generating => '生成中...';

  @override
  String get joining => '参加中...';

  @override
  String get noBabyInfo => '赤ちゃん情報なし';

  @override
  String get noBabyInfoDescription => '赤ちゃん情報がありません。\nテスト用の赤ちゃんを作成しますか？';

  @override
  String get create => '作成';

  @override
  String get generateNewInviteCode => '新しい招待コード生成';

  @override
  String get replaceExistingCode => '既存の招待コードを置き換えます。\n続行しますか？';

  @override
  String get acceptInvitation => '招待を受諾';

  @override
  String get acceptInvitationDescription => '招待を受諾して家族に参加しますか？';

  @override
  String acceptInvitationWarning(String babyName) {
    return '既存の赤ちゃん記録は削除され,\n招待された赤ちゃん($babyName)に変更されます。\n\n続行しますか？';
  }

  @override
  String get pleaseEnterInviteCode => '招待コードを入力してください';

  @override
  String get inviteCodeMustBe6Digits => '招待コードは6桁です';

  @override
  String get pleaseLoginFirst => 'ログイン情報がありません。まずログインしてください。';

  @override
  String get copiedToClipboard => '招待コードがクリップボードにコピーされました！';

  @override
  String get joinedSuccessfully => '家族に正常に参加しました！';

  @override
  String get inviteCodeExpired => '招待コードが期限切れです';

  @override
  String get invalidInviteCode => '無効な招待コードです';

  @override
  String get alreadyMember => 'すでにこの家族のメンバーです';

  @override
  String get cannotInviteSelf => '自分自身を招待することはできません';

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String babyGuideTitle(String name) {
    return '$nameの育児ガイド';
  }

  @override
  String get babyGuide => '育児ガイド';

  @override
  String get noAvailableGuides => '利用可能なガイドがありません';

  @override
  String get current => '現在';

  @override
  String get past => '過去';

  @override
  String get upcoming => '予定';

  @override
  String babysGuide(String name) {
    return '$nameの';
  }

  @override
  String weekGuide(String weekText) {
    return '$weekText ガイド';
  }

  @override
  String get feedingGuide => '💡 授乳ガイド';

  @override
  String get feedingFrequency => '授乳回数';

  @override
  String get singleFeedingAmount => '1回授乳量';

  @override
  String get dailyTotal => '一日総量';

  @override
  String get additionalTips => '📋 追加のヒント';

  @override
  String get understood => 'わかりました';

  @override
  String get newborn => '新生児';

  @override
  String weekNumber(int number) {
    return '$number週目';
  }

  @override
  String get newbornWeek0 => '新生児（0週目）';

  @override
  String dailyFrequencyRange(int min, int max) {
    return '1日 $min - $max回';
  }

  @override
  String dailyFrequencyMin(int min) {
    return '1日 $min回以上';
  }

  @override
  String dailyFrequencyMax(int max) {
    return '1日 $max回以下';
  }

  @override
  String amountRangeML(int min, int max) {
    return '${min}ml - ${max}ml';
  }

  @override
  String amountMinML(int min) {
    return '${min}ml以上';
  }

  @override
  String amountMaxML(int max) {
    return '${max}ml以下';
  }

  @override
  String get insufficientFeedingRecords => 'Insufficient feeding records';

  @override
  String get noRecentFeeding => 'No recent feeding records';

  @override
  String get languageSelection => '言語選択';

  @override
  String get selectLanguage => '言語を選択してください';

  @override
  String get currentLanguage => '現在の言語';

  @override
  String get searchCommunityPosts => 'コミュニティ投稿を検索';

  @override
  String get temperatureRecord => '体温記録';

  @override
  String get temperatureTrend => '体温推移';

  @override
  String get profilePhotoSetup => 'プロフィール写真設定';

  @override
  String get howToSelectPhoto => '写真をどのように選択しますか？';

  @override
  String get send => '送信';

  @override
  String get emailVerificationRequired => 'メール認証が必要';

  @override
  String get passwordReset => 'パスワードリセット';

  @override
  String get enterEmailForReset => '登録したメールアドレスを入力してください。\nパスワードリセットリンクを送信します。';

  @override
  String get accountWithdrawalComplete => '退会完了';

  @override
  String get genderLabel => '性別: ';

  @override
  String get birthdateLabel => '生年月日: ';

  @override
  String get maleGender => '男の子';

  @override
  String get femaleGender => '女の子';

  @override
  String get joinWithInviteCodeButton => '招待コードで参加';

  @override
  String get temperatureRecorded => '体温が記録されました';

  @override
  String recordFailed(String error) {
    return '記録に失敗: $error';
  }

  @override
  String get temperatureSettingsSaved => '体温設定が保存されました';

  @override
  String get loadingUserInfo => 'ユーザー情報を読み込み中です。しばらくしてからもう一度お試しください。';

  @override
  String get continueWithSeparateAccount => '別のアカウントで続行';

  @override
  String get linkWithExistingAccount => '既存のアカウントとリンク';

  @override
  String get linkAccount => 'アカウントをリンク';

  @override
  String get accountLinkingComplete => 'アカウントリンク完了';

  @override
  String get deleteConfirmation => '削除確認';

  @override
  String get emailLabel => 'メール';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get babyNameLabel => '赤ちゃんの名前';

  @override
  String get weightInput => '体重を入力';

  @override
  String get heightInput => '身長を入力';

  @override
  String get measurementNotes => '測定状況や特記事項を記録してください（任意）';

  @override
  String get urine => 'おしっこ';

  @override
  String get stool => 'うんち';

  @override
  String get yellow => '黄色';

  @override
  String get brown => '茶色';

  @override
  String get green => '緑色';

  @override
  String get bottle => '哺乳瓶';

  @override
  String get good => '良い';

  @override
  String get average => '普通';

  @override
  String get poor => '悪い';

  @override
  String get vaccination => '予防接種';

  @override
  String get illness => '病気';

  @override
  String get highFever => '高熱';

  @override
  String get oral => '経口';

  @override
  String get inhalation => '吸入';

  @override
  String get injection => '注射';

  @override
  String get tablet => '錠剤';

  @override
  String get drops => '滴';

  @override
  String get teaspoon => '小さじ';

  @override
  String get tablespoon => '大さじ';

  @override
  String get sleepQuality => '睡眠';

  @override
  String get pumpingTime => '搾乳';

  @override
  String get solidFoodTime => '離乳食';

  @override
  String get totalFeedingAmount => '総授乳量';

  @override
  String get averageFeedingAmount => '平均授乳量';

  @override
  String get dailyAverageFeedingCount => '1日平均授乳回数';

  @override
  String get clinical => '臨床';

  @override
  String get infoSharing => '情報共有';

  @override
  String get sleepIssues => '睡眠問題';

  @override
  String get babyFoodCategory => '離乳食';

  @override
  String get developmentStage => '発達段階';

  @override
  String get vaccinationCategory => '予防接種';

  @override
  String get postpartumRecovery => '産後回復';

  @override
  String get dailyLife => '日常生活';

  @override
  String get likes => 'いいね';

  @override
  String get comments => 'コメント';

  @override
  String get anonymous => '匿名';

  @override
  String get minutes => '分';

  @override
  String get armpit => '脇の下';

  @override
  String get forehead => '額';

  @override
  String get ear => '耳';

  @override
  String get mouth => '口';

  @override
  String get rectal => '直腸';

  @override
  String get otherLocation => 'その他';

  @override
  String get searchError => '検索エラー';

  @override
  String get question => '質問';

  @override
  String get information => '情報';

  @override
  String get relevance => '関連度';

  @override
  String get searchSuggestions => '検索候補';

  @override
  String get noSearchResults => '検索結果がありません';

  @override
  String get tryDifferentSearchTerm => '別の検索語を試してください';

  @override
  String get likeFeatureComingSoon => 'いいね機能は近日公開';

  @override
  String get popularSearchTerms => '人気の検索語';

  @override
  String get recentSearches => '最近の検索';

  @override
  String get deleteAll => 'すべて削除';

  @override
  String get sortByComments => 'コメント順';

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
    return '$minutes分進行中';
  }

  @override
  String get sleepProgressTime => '睡眠進行時間';

  @override
  String get standardFeedingTimeNow => '標準授乳時間です';

  @override
  String standardFeedingTimeSoon(int minutes) {
    return 'もうすぐ標準授乳時間です（$minutes分後）';
  }

  @override
  String timeUntilStandardFeedingHours(int hours, int minutes) {
    return '標準授乳まで$hours時間$minutes分';
  }

  @override
  String timeUntilStandardFeedingMinutes(int minutes) {
    return '標準授乳まで$minutes分';
  }

  @override
  String get insufficientFeedingRecordsApplyingStandard =>
      '授乳記録が不足しています（標準間隔適用）';

  @override
  String get standardFeedingTimeOverdue => '標準授乳時間が過ぎました';

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String minutesFormat(int minutes) {
    return '$minutes分';
  }

  @override
  String personalPatternInfo(String interval) {
    return '個人パターン: $interval 間隔（参考用）';
  }

  @override
  String get longPressForDetails => '長押しで詳細表示';

  @override
  String get todaysSummary => '今日の概要';

  @override
  String get future => 'Future';

  @override
  String get previousDate => 'Previous date';

  @override
  String get nextDate => 'Next date';

  @override
  String get selectDate => 'Select date';

  @override
  String get checkStandardFeedingInterval => '標準授乳間隔を確認してください';

  @override
  String get registerBabyFirst => '赤ちゃんを登録してください';

  @override
  String get registerBabyToRecordMoments =>
      '赤ちゃんの大切な瞬間を記録するために、\nまず赤ちゃんの情報を登録してください。';

  @override
  String get addBabyFromHome => 'ホームから赤ちゃんを追加';

  @override
  String get timesUnit => '回';

  @override
  String get itemsUnit => '個';

  @override
  String get timesPerDay => '回/日';

  @override
  String get activityDistributionByCategory => 'カテゴリ別活動分布';

  @override
  String itemsCount(int count) {
    return '$count個項目';
  }

  @override
  String get totalCount => '総回数';

  @override
  String timesCount(int count) {
    return '$count回';
  }

  @override
  String get noDetailedData => '詳細データなし';

  @override
  String get averageFeedingTime => '平均授乳時間';

  @override
  String get averageSleepTime => '平均睡眠時間';

  @override
  String get dailyAverageTotalSleepTime => '1日平均総睡眠時間';

  @override
  String get dailyAverageSleepCount => '1日平均睡眠回数';

  @override
  String get dailyAverageChangeCount => '1日平均交換回数';

  @override
  String get sharingParentingStories => '子育ての話を共有';

  @override
  String get myActivity => '私の活動';

  @override
  String get categories => 'カテゴリー';

  @override
  String get menu => 'メニュー';

  @override
  String get seeMore => 'もっと見る';

  @override
  String get midnight => '深夜';

  @override
  String get morning => '午前';

  @override
  String get noon => '正午';

  @override
  String get afternoon => '午後';
}
