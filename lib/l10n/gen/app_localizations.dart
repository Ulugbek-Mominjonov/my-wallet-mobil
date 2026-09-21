import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
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
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

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
    Locale('uz'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'My Wallet'**
  String get appName;

  /// Pastki navigatsiya: bosh ekran (dashboard)
  ///
  /// In uz, this message translates to:
  /// **'Xulosa'**
  String get tabHome;

  /// No description provided for @tabTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Amallar'**
  String get tabTransactions;

  /// No description provided for @tabPayments.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar'**
  String get tabPayments;

  /// No description provided for @tabWallet.
  ///
  /// In uz, this message translates to:
  /// **'Hamyon'**
  String get tabWallet;

  /// No description provided for @actionAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get actionAdd;

  /// No description provided for @actionSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get actionRetry;

  /// No description provided for @errorUnexpected.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmagan xato. Qayta urinib ko\'ring.'**
  String get errorUnexpected;

  /// No description provided for @errorNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Sahifa topilmadi'**
  String get errorNotFound;

  /// No description provided for @emptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha ma\'lumot yo\'q'**
  String get emptyTitle;

  /// Oy nomi (1–12), bosh harf bilan — admin paneldagi bilan bir xil
  ///
  /// In uz, this message translates to:
  /// **'{month, select, 1{Yanvar} 2{Fevral} 3{Mart} 4{Aprel} 5{May} 6{Iyun} 7{Iyul} 8{Avgust} 9{Sentabr} 10{Oktabr} 11{Noyabr} 12{Dekabr} other{?}}'**
  String monthName(String month);

  /// No description provided for @notFoundMessage.
  ///
  /// In uz, this message translates to:
  /// **'Havola eskirgan yoki noto\'g\'ri.'**
  String get notFoundMessage;

  /// No description provided for @actionHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifaga'**
  String get actionHome;

  /// No description provided for @addTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi amal'**
  String get addTitle;

  /// No description provided for @navAddLabel.
  ///
  /// In uz, this message translates to:
  /// **'Amal qo\'shish'**
  String get navAddLabel;

  /// Sinxron holati ekrani (E13-T06)
  ///
  /// In uz, this message translates to:
  /// **'Sinxron holati'**
  String get syncStatusTitle;

  /// No description provided for @syncSynced.
  ///
  /// In uz, this message translates to:
  /// **'Sinxronlangan'**
  String get syncSynced;

  /// No description provided for @syncSyncing.
  ///
  /// In uz, this message translates to:
  /// **'Yuborilmoqda…'**
  String get syncSyncing;

  /// No description provided for @syncPending.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta o\'zgarish yuborilmagan'**
  String syncPending(int count);

  /// No description provided for @syncOffline.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn — tarmoq kelganda yuboriladi'**
  String get syncOffline;

  /// No description provided for @syncIssues.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta muammo'**
  String syncIssues(int count);

  /// No description provided for @syncSignedOut.
  ///
  /// In uz, this message translates to:
  /// **'Qayta kirish kerak'**
  String get syncSignedOut;

  /// No description provided for @syncLastAt.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi sinxron: {time}'**
  String syncLastAt(String time);

  /// No description provided for @syncNever.
  ///
  /// In uz, this message translates to:
  /// **'Hali sinxronlanmagan'**
  String get syncNever;

  /// No description provided for @syncNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir sinxronlash'**
  String get syncNow;

  /// No description provided for @syncFullReload.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq qayta yuklash'**
  String get syncFullReload;

  /// No description provided for @syncFullReloadConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Byudjet ma\'lumotlari serverdan qaytadan yuklanadi. Yuborilmagan o\'zgarishlar saqlanadi.'**
  String get syncFullReloadConfirm;

  /// No description provided for @syncIssueConflict.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa qurilmada o\'zgartirilgan — server versiyasi ko\'rsatilmoqda'**
  String get syncIssueConflict;

  /// code — server rad etish kodi (contracts/api.md)
  ///
  /// In uz, this message translates to:
  /// **'Server qabul qilmadi ({code}) — o\'zgarish bekor qilindi'**
  String syncIssueRejected(String code);

  /// No description provided for @syncKeepMine.
  ///
  /// In uz, this message translates to:
  /// **'Mening versiyam'**
  String get syncKeepMine;

  /// No description provided for @syncDismiss.
  ///
  /// In uz, this message translates to:
  /// **'Tushunarli'**
  String get syncDismiss;

  /// Sinxron jadvali nomi → foydalanuvchi uchun yozuv turi
  ///
  /// In uz, this message translates to:
  /// **'{table, select, transactions{Amal} planned_items{Reja} accounts{Hisob} categories{Kategoriya} debts{Qarz} goals{Maqsad} other{Yozuv}}'**
  String syncRecordKind(String table);

  /// Kirish ekrani (E14-T01)
  ///
  /// In uz, this message translates to:
  /// **'Pulingiz qayerga ketayotganini biling'**
  String get authTagline;

  /// No description provided for @authGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan kirish'**
  String get authGoogle;

  /// No description provided for @authOr.
  ///
  /// In uz, this message translates to:
  /// **'yoki'**
  String get authOr;

  /// No description provided for @authEmailLabel.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authSendCode.
  ///
  /// In uz, this message translates to:
  /// **'Kod olish'**
  String get authSendCode;

  /// No description provided for @authCodeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Pochtangizni tekshiring'**
  String get authCodeTitle;

  /// Kod bosqichi (E14-T01)
  ///
  /// In uz, this message translates to:
  /// **'{email} manziliga {length} xonali kod yubordik'**
  String authCodeSent(String email, int length);

  /// No description provided for @authCodeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kod'**
  String get authCodeLabel;

  /// No description provided for @authVerify.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get authVerify;

  /// No description provided for @authResend.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish — {seconds} s'**
  String authResendIn(int seconds);

  /// No description provided for @authChangeEmail.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa email'**
  String get authChangeEmail;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email manzilni tekshiring'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorInvalidCode.
  ///
  /// In uz, this message translates to:
  /// **'{length} xonali kodni kiriting'**
  String authErrorInvalidCode(int length);

  /// No description provided for @authErrorCodeExpired.
  ///
  /// In uz, this message translates to:
  /// **'Kod noto\'g\'ri yoki eskirgan'**
  String get authErrorCodeExpired;

  /// No description provided for @authErrorRateLimit.
  ///
  /// In uz, this message translates to:
  /// **'Juda ko\'p urinish — birozdan keyin qayta urinib ko\'ring'**
  String get authErrorRateLimit;

  /// No description provided for @authErrorGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan kirib bo\'lmadi — email orqali kiring'**
  String get authErrorGoogle;

  /// No description provided for @errorOffline.
  ///
  /// In uz, this message translates to:
  /// **'Internet yo\'q — ulanishni tekshiring'**
  String get errorOffline;

  /// No description provided for @signOut.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Qurilmadagi ma\'lumot o\'chiriladi — qayta kirganingizda serverdan yuklanadi.'**
  String get signOutConfirm;

  /// No description provided for @signOutUnsent.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta o\'zgarish hali serverga yetmagan — chiqsangiz ular yo\'qoladi.'**
  String signOutUnsent(int count);

  /// Ishga tushirish va byudjet tanlash (E14-T02)
  ///
  /// In uz, this message translates to:
  /// **'Byudjet yuklanmoqda…'**
  String get startupLoading;

  /// No description provided for @startupFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotni yuklab bo\'lmadi'**
  String get startupFailed;

  /// No description provided for @householdSetupTitle.
  ///
  /// In uz, this message translates to:
  /// **'Byudjetni boshlang'**
  String get householdSetupTitle;

  /// No description provided for @householdSetupSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi byudjet yarating yoki taklif kodi bilan mavjudiga qo\'shiling.'**
  String get householdSetupSubtitle;

  /// No description provided for @householdCreateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi byudjet'**
  String get householdCreateTitle;

  /// No description provided for @householdNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Byudjet nomi'**
  String get householdNameLabel;

  /// No description provided for @householdNameDefault.
  ///
  /// In uz, this message translates to:
  /// **'Mening byudjetim'**
  String get householdNameDefault;

  /// No description provided for @householdCreate.
  ///
  /// In uz, this message translates to:
  /// **'Yaratish'**
  String get householdCreate;

  /// No description provided for @householdJoinTitle.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kodi bilan qo\'shilish'**
  String get householdJoinTitle;

  /// No description provided for @householdCodeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kodi'**
  String get householdCodeLabel;

  /// No description provided for @householdJoin.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shilish'**
  String get householdJoin;

  /// No description provided for @householdScan.
  ///
  /// In uz, this message translates to:
  /// **'QR kodni skanerlash'**
  String get householdScan;

  /// No description provided for @householdScanTitle.
  ///
  /// In uz, this message translates to:
  /// **'Taklif QR kodi'**
  String get householdScanTitle;

  /// No description provided for @householdErrorName.
  ///
  /// In uz, this message translates to:
  /// **'Byudjet nomini kiriting'**
  String get householdErrorName;

  /// No description provided for @householdErrorCode.
  ///
  /// In uz, this message translates to:
  /// **'Kod 8 belgidan iborat'**
  String get householdErrorCode;

  /// No description provided for @householdErrorNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Bunday kod topilmadi'**
  String get householdErrorNotFound;

  /// No description provided for @householdErrorUsed.
  ///
  /// In uz, this message translates to:
  /// **'Kod allaqachon ishlatilgan'**
  String get householdErrorUsed;

  /// No description provided for @householdErrorExpired.
  ///
  /// In uz, this message translates to:
  /// **'Kod muddati tugagan (7 kun)'**
  String get householdErrorExpired;

  /// No description provided for @householdErrorMember.
  ///
  /// In uz, this message translates to:
  /// **'Siz allaqachon bu byudjet a\'zosisiz'**
  String get householdErrorMember;

  /// No description provided for @onboardingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlash'**
  String get onboardingTitle;

  /// Sozlash ustasi (E14-T03)
  ///
  /// In uz, this message translates to:
  /// **'{current}/{total}-qadam'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingAccountsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar va qoldiq'**
  String get onboardingAccountsTitle;

  /// No description provided for @onboardingAccountsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi qoldiqni kiriting — keyin hammasi shundan hisoblanadi.'**
  String get onboardingAccountsSubtitle;

  /// No description provided for @onboardingIncomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Maosh jadvali'**
  String get onboardingIncomeTitle;

  /// No description provided for @onboardingIncomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi daromadlarni olasiz, qaysi kuni va qaysi oyga tegishli.'**
  String get onboardingIncomeSubtitle;

  /// No description provided for @onboardingRecurringTitle.
  ///
  /// In uz, this message translates to:
  /// **'Doimiy to\'lovlar'**
  String get onboardingRecurringTitle;

  /// No description provided for @onboardingRecurringSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Har oy takrorlanadigan to\'lovlar — har oy avtomatik rejaga tushadi.'**
  String get onboardingRecurringSubtitle;

  /// No description provided for @onboardingFundTitle.
  ///
  /// In uz, this message translates to:
  /// **'👤 Shaxsiy fond'**
  String get onboardingFundTitle;

  /// No description provided for @onboardingFundSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Har oy o\'zingiz uchun ajratadigan ulush.'**
  String get onboardingFundSubtitle;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor!'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Joriy oy ochiladi va rejalar yaratiladi.'**
  String get onboardingDoneSubtitle;

  /// No description provided for @onboardingWaiting.
  ///
  /// In uz, this message translates to:
  /// **'Spravochniklar yuklanmoqda…'**
  String get onboardingWaiting;

  /// No description provided for @onboardingFinish.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get onboardingSkip;

  /// No description provided for @actionNext.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get actionBack;

  /// No description provided for @fieldDay.
  ///
  /// In uz, this message translates to:
  /// **'Kuni'**
  String get fieldDay;

  /// No description provided for @fieldAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get fieldAmount;

  /// No description provided for @fieldAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisob'**
  String get fieldAccount;

  /// No description provided for @monthThis.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy'**
  String get monthThis;

  /// No description provided for @monthPrevious.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi oy'**
  String get monthPrevious;

  /// No description provided for @monthNext.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi oy'**
  String get monthNext;

  /// No description provided for @fundPercentMode.
  ///
  /// In uz, this message translates to:
  /// **'Foiz'**
  String get fundPercentMode;

  /// No description provided for @fundFixedMode.
  ///
  /// In uz, this message translates to:
  /// **'Qat\'iy summa'**
  String get fundFixedMode;

  /// No description provided for @fundPercent.
  ///
  /// In uz, this message translates to:
  /// **'Daromadning foizi'**
  String get fundPercent;

  /// No description provided for @fundSource.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hisobdan'**
  String get fundSource;

  /// No description provided for @autoPay.
  ///
  /// In uz, this message translates to:
  /// **'Avto to\'lov'**
  String get autoPay;

  /// No description provided for @onboardingSummary.
  ///
  /// In uz, this message translates to:
  /// **'{accounts} ta hisob, {incomes} ta daromad turi, {plans} ta doimiy to\'lov'**
  String onboardingSummary(int accounts, int incomes, int plans);

  /// No description provided for @updateRequiredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani yangilang'**
  String get updateRequiredTitle;

  /// BR-214 (E14-T04)
  ///
  /// In uz, this message translates to:
  /// **'Yangi versiya ({version}) kerak — Play Market\'dan yangilang.'**
  String updateRequiredBody(String version);

  /// No description provided for @householdSwitch.
  ///
  /// In uz, this message translates to:
  /// **'Byudjetni almashtirish'**
  String get householdSwitch;

  /// No description provided for @householdAdd.
  ///
  /// In uz, this message translates to:
  /// **'Yangi byudjet yoki taklif kodi'**
  String get householdAdd;

  /// No description provided for @offlineBanner.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn — o\'zgarishlar tarmoq kelganda yuboriladi'**
  String get offlineBanner;

  /// No description provided for @menuSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get menuSettings;

  /// No description provided for @lockTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova qulfi'**
  String get lockTitle;

  /// No description provided for @lockEnterPin.
  ///
  /// In uz, this message translates to:
  /// **'PIN kodni kiriting'**
  String get lockEnterPin;

  /// No description provided for @lockWrongPin.
  ///
  /// In uz, this message translates to:
  /// **'PIN noto\'g\'ri'**
  String get lockWrongPin;

  /// No description provided for @lockBiometrics.
  ///
  /// In uz, this message translates to:
  /// **'Biometrika'**
  String get lockBiometrics;

  /// No description provided for @lockNewPin.
  ///
  /// In uz, this message translates to:
  /// **'Yangi PIN'**
  String get lockNewPin;

  /// No description provided for @lockRepeatPin.
  ///
  /// In uz, this message translates to:
  /// **'PIN ni takrorlang'**
  String get lockRepeatPin;

  /// No description provided for @lockMismatch.
  ///
  /// In uz, this message translates to:
  /// **'PIN mos kelmadi'**
  String get lockMismatch;

  /// No description provided for @lockSetPin.
  ///
  /// In uz, this message translates to:
  /// **'PIN o\'rnatish'**
  String get lockSetPin;

  /// No description provided for @lockChangePin.
  ///
  /// In uz, this message translates to:
  /// **'PIN ni o\'zgartirish'**
  String get lockChangePin;

  /// No description provided for @lockDisable.
  ///
  /// In uz, this message translates to:
  /// **'Qulfni o\'chirish'**
  String get lockDisable;

  /// No description provided for @lockAuto.
  ///
  /// In uz, this message translates to:
  /// **'Avto-qulf'**
  String get lockAuto;

  /// Ilova qulfi (E14-T05, BR-211)
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqadan keyin'**
  String lockAutoValue(int minutes);

  /// No description provided for @lockSecureScreen.
  ///
  /// In uz, this message translates to:
  /// **'Ilova almashtirgichda yashirish'**
  String get lockSecureScreen;

  /// No description provided for @lockForgot.
  ///
  /// In uz, this message translates to:
  /// **'PIN esimdan chiqdi — chiqish'**
  String get lockForgot;

  /// No description provided for @privacyMode.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik rejimi'**
  String get privacyMode;

  /// Amal turi (E15-T01)
  ///
  /// In uz, this message translates to:
  /// **'Xarajat'**
  String get kindExpense;

  /// No description provided for @kindIncome.
  ///
  /// In uz, this message translates to:
  /// **'Daromad'**
  String get kindIncome;

  /// No description provided for @kindTransfer.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazma'**
  String get kindTransfer;

  /// Amal qo'shish maydonlari (E15-T02)
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya'**
  String get fieldCategory;

  /// No description provided for @fieldPayee.
  ///
  /// In uz, this message translates to:
  /// **'Joy / kimga'**
  String get fieldPayee;

  /// No description provided for @fieldNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get fieldNote;

  /// No description provided for @fieldTo.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga'**
  String get fieldTo;

  /// No description provided for @dateToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get dateYesterday;

  /// No description provided for @dateChoose.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get dateChoose;

  /// No description provided for @categorySearch.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya qidirish'**
  String get categorySearch;

  /// No description provided for @saved.
  ///
  /// In uz, this message translates to:
  /// **'Saqlandi'**
  String get saved;

  /// No description provided for @errorMonthClosed.
  ///
  /// In uz, this message translates to:
  /// **'Oy yopilgan — yozib bo\'lmaydi'**
  String get errorMonthClosed;

  /// No description provided for @categoryNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kategoriya'**
  String get categoryNew;

  /// No description provided for @fieldTags.
  ///
  /// In uz, this message translates to:
  /// **'Teglar'**
  String get fieldTags;

  /// No description provided for @fieldDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga bog\'lash'**
  String get fieldDebt;

  /// No description provided for @errorCategoryRequired.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tanlang'**
  String get errorCategoryRequired;

  /// No description provided for @errorCategoryInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Bu kategoriyani tanlab bo\'lmaydi'**
  String get errorCategoryInvalid;

  /// No description provided for @errorAccountRequired.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni tanlang'**
  String get errorAccountRequired;

  /// No description provided for @errorTargetAccount.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa hisobni tanlang'**
  String get errorTargetAccount;

  /// No description provided for @errorAmountRequired.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting'**
  String get errorAmountRequired;

  /// No description provided for @monthClosedConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'Oy yopilgan'**
  String get monthClosedConfirmTitle;

  /// No description provided for @monthClosedConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu amal yopilgan oyga tushadi. Baribir yozilsinmi?'**
  String get monthClosedConfirmBody;

  /// No description provided for @actionRecord.
  ///
  /// In uz, this message translates to:
  /// **'Yozish'**
  String get actionRecord;

  /// BR-045 (E15-T03)
  ///
  /// In uz, this message translates to:
  /// **'→ {month} oyining daromadi sifatida yoziladi ({relation})'**
  String monthHintIncome(String month, String relation);

  /// No description provided for @monthHintExpense.
  ///
  /// In uz, this message translates to:
  /// **'→ {month} oyining byudjetiga ({relation})'**
  String monthHintExpense(String month, String relation);

  /// No description provided for @monthRelationSame.
  ///
  /// In uz, this message translates to:
  /// **'shu oy'**
  String get monthRelationSame;

  /// No description provided for @monthRelationPrevious.
  ///
  /// In uz, this message translates to:
  /// **'oldingi oy'**
  String get monthRelationPrevious;

  /// No description provided for @monthRelationNext.
  ///
  /// In uz, this message translates to:
  /// **'keyingi oy'**
  String get monthRelationNext;

  /// No description provided for @monthRelationManual.
  ///
  /// In uz, this message translates to:
  /// **'qo\'lda tanlangan'**
  String get monthRelationManual;

  /// No description provided for @monthQuestion.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi oyning byudjetiga?'**
  String get monthQuestion;

  /// No description provided for @monthByDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana bo\'yicha'**
  String get monthByDate;

  /// No description provided for @monthChoose.
  ///
  /// In uz, this message translates to:
  /// **'Tanlash'**
  String get monthChoose;

  /// BR-141 tez tugma (E15-T04)
  ///
  /// In uz, this message translates to:
  /// **'{name} — {amount} yozildi'**
  String quickSaved(String name, String amount);

  /// No description provided for @actionUndo.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionUndo;

  /// No description provided for @quickHint.
  ///
  /// In uz, this message translates to:
  /// **'Bosing — darhol yoziladi, bosib turing — tahrirlash'**
  String get quickHint;

  /// No description provided for @fundAllocationHint.
  ///
  /// In uz, this message translates to:
  /// **'👤 Bu ajratma sifatida hisoblanadi — oy qoldig\'ini kamaytiradi'**
  String get fundAllocationHint;

  /// No description provided for @fundReturnHint.
  ///
  /// In uz, this message translates to:
  /// **'👤 Ajratmaning qaytishi — oy qoldig\'ini oshiradi'**
  String get fundReturnHint;

  /// No description provided for @fundSpendHint.
  ///
  /// In uz, this message translates to:
  /// **'👤 Fonddan sarf — oylik qoldiqqa ta\'sir qilmaydi'**
  String get fundSpendHint;

  /// No description provided for @errorCurrencyMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar valyutasi har xil — bunday o\'tkazma keyinroq qo\'shiladi'**
  String get errorCurrencyMismatch;

  /// Hafta kuni (1 — dushanba), kichik harf (E15-T06)
  ///
  /// In uz, this message translates to:
  /// **'{day, select, 1{dushanba} 2{seshanba} 3{chorshanba} 4{payshanba} 5{juma} 6{shanba} 7{yakshanba} other{?}}'**
  String weekdayName(String day);

  /// No description provided for @dayTitle.
  ///
  /// In uz, this message translates to:
  /// **'{day}-{month}, {weekday}'**
  String dayTitle(int day, String month, String weekday);

  /// No description provided for @transactionsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu oyda amal yo\'q'**
  String get transactionsEmpty;

  /// No description provided for @transactionsEmptyFiltered.
  ///
  /// In uz, this message translates to:
  /// **'Filtrga mos amal yo\'q'**
  String get transactionsEmptyFiltered;

  /// No description provided for @searchHint.
  ///
  /// In uz, this message translates to:
  /// **'Joy, izoh yoki summa'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get filterAll;

  /// No description provided for @filterClear.
  ///
  /// In uz, this message translates to:
  /// **'Filtrni tozalash'**
  String get filterClear;

  /// No description provided for @monthClosedBanner.
  ///
  /// In uz, this message translates to:
  /// **'Oy yopilgan — o\'zgartirish tasdiq bilan'**
  String get monthClosedBanner;

  /// No description provided for @deleted.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirildi'**
  String get deleted;

  /// No description provided for @editTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get editTitle;

  /// No description provided for @receipt.
  ///
  /// In uz, this message translates to:
  /// **'Chek'**
  String get receipt;

  /// No description provided for @receiptCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get receiptCamera;

  /// No description provided for @receiptGallery.
  ///
  /// In uz, this message translates to:
  /// **'Galereya'**
  String get receiptGallery;

  /// No description provided for @receiptTooLarge.
  ///
  /// In uz, this message translates to:
  /// **'Rasm juda katta — boshqasini tanlang'**
  String get receiptTooLarge;

  /// No description provided for @receiptPending.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanishi kutilmoqda'**
  String get receiptPending;

  /// No description provided for @dashBalance.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq'**
  String get dashBalance;

  /// No description provided for @dashForecast.
  ///
  /// In uz, this message translates to:
  /// **'Prognoz qoldiq'**
  String get dashForecast;

  /// Dashboard (E16)
  ///
  /// In uz, this message translates to:
  /// **'Oy oxirida ≈ {amount}'**
  String dashMonthEnd(String amount);

  /// No description provided for @dashPerDay.
  ///
  /// In uz, this message translates to:
  /// **'Kuniga ≈ {amount}'**
  String dashPerDay(String amount);

  /// No description provided for @dashSaved.
  ///
  /// In uz, this message translates to:
  /// **'Orttirgan'**
  String get dashSaved;

  /// No description provided for @dashCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get dashCard;

  /// No description provided for @dashCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get dashCash;

  /// No description provided for @dashPlan.
  ///
  /// In uz, this message translates to:
  /// **'Reja bajarilishi'**
  String get dashPlan;

  /// No description provided for @dashUnknown.
  ///
  /// In uz, this message translates to:
  /// **'+ {count} ta ?'**
  String dashUnknown(int count);

  /// No description provided for @dashUpcoming.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin to\'lovlar'**
  String get dashUpcoming;

  /// No description provided for @dashMarkPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get dashMarkPaid;

  /// No description provided for @dashCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get dashCategories;

  /// No description provided for @dashIncomeTypes.
  ///
  /// In uz, this message translates to:
  /// **'Daromad turlari'**
  String get dashIncomeTypes;

  /// No description provided for @dashFund.
  ///
  /// In uz, this message translates to:
  /// **'👤 Shaxsiy fond'**
  String get dashFund;

  /// No description provided for @dashSavings.
  ///
  /// In uz, this message translates to:
  /// **'🏦 Jamg\'arma'**
  String get dashSavings;

  /// No description provided for @dashThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy'**
  String get dashThisMonth;

  /// No description provided for @dashAllocated.
  ///
  /// In uz, this message translates to:
  /// **'Ajratilgan'**
  String get dashAllocated;

  /// No description provided for @dashSpent.
  ///
  /// In uz, this message translates to:
  /// **'Sarflangan'**
  String get dashSpent;

  /// No description provided for @dashDebts.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar'**
  String get dashDebts;

  /// No description provided for @dashIOwe.
  ///
  /// In uz, this message translates to:
  /// **'Men qarzman'**
  String get dashIOwe;

  /// No description provided for @dashOwedToMe.
  ///
  /// In uz, this message translates to:
  /// **'Menga qarz'**
  String get dashOwedToMe;

  /// No description provided for @dashMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oyiga'**
  String get dashMonthly;

  /// No description provided for @dashGoals.
  ///
  /// In uz, this message translates to:
  /// **'Maqsadlar'**
  String get dashGoals;

  /// No description provided for @dashForecastTitle.
  ///
  /// In uz, this message translates to:
  /// **'Prognoz'**
  String get dashForecastTitle;

  /// No description provided for @dashDays.
  ///
  /// In uz, this message translates to:
  /// **'{elapsed} / {total} kun'**
  String dashDays(int elapsed, int total);

  /// No description provided for @dashDailySpend.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik sarf'**
  String get dashDailySpend;

  /// No description provided for @dashMonthEndSpend.
  ///
  /// In uz, this message translates to:
  /// **'Oy oxiri sarfi'**
  String get dashMonthEndSpend;

  /// No description provided for @dashExpectedIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan daromad'**
  String get dashExpectedIncome;

  /// No description provided for @dashReceivedSoFar.
  ///
  /// In uz, this message translates to:
  /// **'hozircha kelgani {amount}'**
  String dashReceivedSoFar(String amount);

  /// No description provided for @dashNotOpened.
  ///
  /// In uz, this message translates to:
  /// **'Oy hali ochilmagan — doimiy to\'lovlar rejaga tushmagan'**
  String get dashNotOpened;

  /// No description provided for @dashOpenMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oyni ochish'**
  String get dashOpenMonth;

  /// No description provided for @dashOpenMonthBody.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta reja yaratiladi'**
  String dashOpenMonthBody(int count);

  /// No description provided for @dashClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopilgan'**
  String get dashClosed;

  /// No description provided for @dashEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu oyda hali yozuv yo\'q'**
  String get dashEmpty;

  /// No description provided for @dashEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'“+” tugmasi bilan birinchi amalni qo\'shing'**
  String get dashEmptyHint;

  /// No description provided for @fieldDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get fieldDate;

  /// No description provided for @payTabExpenses.
  ///
  /// In uz, this message translates to:
  /// **'Xarajatlar'**
  String get payTabExpenses;

  /// No description provided for @payTabIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan daromadlar'**
  String get payTabIncome;

  /// No description provided for @payUnpaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'lanmagan'**
  String get payUnpaid;

  /// No description provided for @payIncomePending.
  ///
  /// In uz, this message translates to:
  /// **'Kelishi kutilmoqda'**
  String get payIncomePending;

  /// No description provided for @paySectionOverdue.
  ///
  /// In uz, this message translates to:
  /// **'⚠️ Kechikkan'**
  String get paySectionOverdue;

  /// No description provided for @paySectionToday.
  ///
  /// In uz, this message translates to:
  /// **'📌 Bugun'**
  String get paySectionToday;

  /// To'lovlar (E17)
  ///
  /// In uz, this message translates to:
  /// **'🗓 Yaqin {days} kunda'**
  String paySectionSoon(int days);

  /// No description provided for @paySectionLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get paySectionLater;

  /// No description provided for @paySectionPaid.
  ///
  /// In uz, this message translates to:
  /// **'✅ To\'langan'**
  String get paySectionPaid;

  /// No description provided for @paySectionReceived.
  ///
  /// In uz, this message translates to:
  /// **'✅ Kelgan'**
  String get paySectionReceived;

  /// No description provided for @paySectionSkipped.
  ///
  /// In uz, this message translates to:
  /// **'⏭ O\'tkazilgan'**
  String get paySectionSkipped;

  /// No description provided for @payMarkReceived.
  ///
  /// In uz, this message translates to:
  /// **'Keldi'**
  String get payMarkReceived;

  /// No description provided for @paySkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get paySkip;

  /// No description provided for @payUnskip.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get payUnskip;

  /// No description provided for @paySkipped.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborildi'**
  String get paySkipped;

  /// No description provided for @payEditAmount.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy summasi'**
  String get payEditAmount;

  /// No description provided for @payClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get payClose;

  /// No description provided for @payReopen.
  ///
  /// In uz, this message translates to:
  /// **'Qayta ochish'**
  String get payReopen;

  /// No description provided for @payAmountVaries.
  ///
  /// In uz, this message translates to:
  /// **'Summa o\'zgaruvchi'**
  String get payAmountVaries;

  /// No description provided for @payAmountRequired.
  ///
  /// In uz, this message translates to:
  /// **'Bu to\'lovning summasi belgilanmagan — qancha to\'laganingizni kiriting'**
  String get payAmountRequired;

  /// No description provided for @payPartialTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qisman to\'lov'**
  String get payPartialTitle;

  /// To'lovlar (E17)
  ///
  /// In uz, this message translates to:
  /// **'Qolgan {amount} ni keyin to\'laysizmi?'**
  String payPartialBody(String amount);

  /// No description provided for @payPartialLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyin to\'layman'**
  String get payPartialLater;

  /// No description provided for @payAutoPay.
  ///
  /// In uz, this message translates to:
  /// **'Avto to\'lov'**
  String get payAutoPay;

  /// No description provided for @payEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu oyda reja yo\'q'**
  String get payEmpty;

  /// No description provided for @payEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Oyni oching — doimiy to\'lovlardan rejalar yaratiladi'**
  String get payEmptyHint;

  /// No description provided for @payCalendar.
  ///
  /// In uz, this message translates to:
  /// **'Kalendar'**
  String get payCalendar;

  /// No description provided for @payList.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxat'**
  String get payList;

  /// No description provided for @payDayEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu kunda to\'lov yo\'q'**
  String get payDayEmpty;

  /// No description provided for @errorPlanPaid.
  ///
  /// In uz, this message translates to:
  /// **'Bu reja allaqachon to\'langan'**
  String get errorPlanPaid;

  /// No description provided for @errorPlanSkipped.
  ///
  /// In uz, this message translates to:
  /// **'Reja o\'tkazib yuborilgan'**
  String get errorPlanSkipped;

  /// No description provided for @errorPlanNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Reja topilmadi'**
  String get errorPlanNotFound;

  /// To'lovlar (E17)
  ///
  /// In uz, this message translates to:
  /// **'Yaratiladi: {count} ta'**
  String openMonthCreates(int count);

  /// To'lovlar (E17)
  ///
  /// In uz, this message translates to:
  /// **'Allaqachon bor: {count} ta'**
  String openMonthExisting(int count);

  /// No description provided for @openMonthNothing.
  ///
  /// In uz, this message translates to:
  /// **'Yangi reja yo\'q — hammasi allaqachon bor'**
  String get openMonthNothing;

  /// Yillik ko'rinish (E16-T05)
  ///
  /// In uz, this message translates to:
  /// **'{year}-yil'**
  String yearTitle(String year);

  /// No description provided for @yearTotal.
  ///
  /// In uz, this message translates to:
  /// **'JAMI'**
  String get yearTotal;

  /// No description provided for @yearView.
  ///
  /// In uz, this message translates to:
  /// **'Yillik ko\'rinish'**
  String get yearView;

  /// No description provided for @yearEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu yilda yozuv yo\'q'**
  String get yearEmpty;

  /// No description provided for @categoryTrend.
  ///
  /// In uz, this message translates to:
  /// **'Oyma-oy'**
  String get categoryTrend;

  /// No description provided for @categoryTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Amallarni ko\'rish'**
  String get categoryTransactions;

  /// No description provided for @monthShort.
  ///
  /// In uz, this message translates to:
  /// **'{month, select, 1{Yan} 2{Fev} 3{Mar} 4{Apr} 5{May} 6{Iyn} 7{Iyl} 8{Avg} 9{Sen} 10{Okt} 11{Noy} 12{Dek} other{?}}'**
  String monthShort(String month);

  /// No description provided for @shareReport.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotni ulashish'**
  String get shareReport;

  /// No description provided for @shareAction.
  ///
  /// In uz, this message translates to:
  /// **'Ulashish'**
  String get shareAction;

  /// No description provided for @shareFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ulashib bo\'lmadi'**
  String get shareFailed;

  /// No description provided for @shareTopExpenses.
  ///
  /// In uz, this message translates to:
  /// **'Eng katta xarajatlar'**
  String get shareTopExpenses;

  /// No description provided for @fieldName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get fieldName;

  /// No description provided for @actionDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get actionEdit;

  /// No description provided for @errorInvalidName.
  ///
  /// In uz, this message translates to:
  /// **'Nomni kiriting (60 belgigacha)'**
  String get errorInvalidName;

  /// No description provided for @errorDuplicateName.
  ///
  /// In uz, this message translates to:
  /// **'Bu nom allaqachon bor'**
  String get errorDuplicateName;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa noto\'g\'ri'**
  String get errorInvalidAmount;

  /// No description provided for @errorPaidBefore.
  ///
  /// In uz, this message translates to:
  /// **'Oldin to\'langan umumiy summadan oshmasin'**
  String get errorPaidBefore;

  /// No description provided for @accountTypeCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get accountTypeCash;

  /// No description provided for @accountTypeCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get accountTypeCard;

  /// No description provided for @accountTypeBank.
  ///
  /// In uz, this message translates to:
  /// **'Bank hisobi'**
  String get accountTypeBank;

  /// No description provided for @accountTypeEwallet.
  ///
  /// In uz, this message translates to:
  /// **'Elektron hamyon'**
  String get accountTypeEwallet;

  /// No description provided for @accountTypeDeposit.
  ///
  /// In uz, this message translates to:
  /// **'Omonat'**
  String get accountTypeDeposit;

  /// No description provided for @accountTypePersonalFund.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy fond'**
  String get accountTypePersonalFund;

  /// No description provided for @accountTypeOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get accountTypeOther;

  /// No description provided for @walletAccounts.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar'**
  String get walletAccounts;

  /// No description provided for @walletTotalNoFund.
  ///
  /// In uz, this message translates to:
  /// **'Jami (fondsiz)'**
  String get walletTotalNoFund;

  /// No description provided for @walletNegativeCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd qoldiq manfiy — yozuvlarni tekshiring'**
  String get walletNegativeCash;

  /// No description provided for @walletDebts.
  ///
  /// In uz, this message translates to:
  /// **'💳 Qarzlar'**
  String get walletDebts;

  /// No description provided for @walletGoals.
  ///
  /// In uz, this message translates to:
  /// **'🎯 Maqsadlar'**
  String get walletGoals;

  /// No description provided for @walletLimits.
  ///
  /// In uz, this message translates to:
  /// **'📊 Limitlar'**
  String get walletLimits;

  /// No description provided for @fundAllTime.
  ///
  /// In uz, this message translates to:
  /// **'Butun davr'**
  String get fundAllTime;

  /// No description provided for @fundAddSpend.
  ///
  /// In uz, this message translates to:
  /// **'Sarf qo\'shish'**
  String get fundAddSpend;

  /// No description provided for @fundSpends.
  ///
  /// In uz, this message translates to:
  /// **'Sarflar tarixi'**
  String get fundSpends;

  /// No description provided for @fundAllocation.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy ajratmasi'**
  String get fundAllocation;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi daromaddan: {amount} ({percent}%)'**
  String fundAllocationLive(String amount, String percent);

  /// No description provided for @fundAllocationNone.
  ///
  /// In uz, this message translates to:
  /// **'Bu oy uchun ajratma rejasi yo\'q'**
  String get fundAllocationNone;

  /// No description provided for @fundMonths.
  ///
  /// In uz, this message translates to:
  /// **'Oylar bo\'yicha'**
  String get fundMonths;

  /// No description provided for @savingsTotal.
  ///
  /// In uz, this message translates to:
  /// **'Shu oygacha to\'plangan'**
  String get savingsTotal;

  /// No description provided for @savingsAvg.
  ///
  /// In uz, this message translates to:
  /// **'Oyiga o\'rtacha orttirish'**
  String get savingsAvg;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'{count} oy'**
  String savingsMonthsCount(int count);

  /// No description provided for @savingsAccumulated.
  ///
  /// In uz, this message translates to:
  /// **'To\'plangan'**
  String get savingsAccumulated;

  /// No description provided for @savingsNote.
  ///
  /// In uz, this message translates to:
  /// **'Jamg\'arma — ko\'rsatkich. Pul jismonan qayerda ekanini «Hisoblar» ko\'rsatadi.'**
  String get savingsNote;

  /// No description provided for @debtNet.
  ///
  /// In uz, this message translates to:
  /// **'⚖️ Sof holat'**
  String get debtNet;

  /// No description provided for @debtMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oylik majburiyat'**
  String get debtMonthly;

  /// No description provided for @debtPaidThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy to\'langan'**
  String get debtPaidThisMonth;

  /// No description provided for @debtStatusPaying.
  ///
  /// In uz, this message translates to:
  /// **'To\'lanyapti'**
  String get debtStatusPaying;

  /// No description provided for @debtStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get debtStatusPending;

  /// No description provided for @debtStatusUnlinked.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'lanmagan'**
  String get debtStatusUnlinked;

  /// No description provided for @debtStatusClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopildi'**
  String get debtStatusClosed;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'Qolgan: {amount}'**
  String debtRemaining(String amount);

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'Tugaydi: {month}'**
  String debtEnds(String month);

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda: {amount}'**
  String debtPending(String amount);

  /// No description provided for @debtAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qarz qo\'shish'**
  String get debtAdd;

  /// No description provided for @debtEdit.
  ///
  /// In uz, this message translates to:
  /// **'Qarzni tahrirlash'**
  String get debtEdit;

  /// No description provided for @debtTotal.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy summa'**
  String get debtTotal;

  /// No description provided for @debtPaidBefore.
  ///
  /// In uz, this message translates to:
  /// **'Oldin to\'langan'**
  String get debtPaidBefore;

  /// No description provided for @debtMonthlyPayment.
  ///
  /// In uz, this message translates to:
  /// **'Oylik to\'lov'**
  String get debtMonthlyPayment;

  /// No description provided for @debtDueDate.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get debtDueDate;

  /// No description provided for @debtArchive.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlash'**
  String get debtArchive;

  /// No description provided for @debtUnarchive.
  ///
  /// In uz, this message translates to:
  /// **'Arxivdan chiqarish'**
  String get debtUnarchive;

  /// No description provided for @debtArchived.
  ///
  /// In uz, this message translates to:
  /// **'Arxiv'**
  String get debtArchived;

  /// No description provided for @debtPayments.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'langan to\'lovlar'**
  String get debtPayments;

  /// No description provided for @debtNoPayments.
  ///
  /// In uz, this message translates to:
  /// **'Hali to\'lov yo\'q'**
  String get debtNoPayments;

  /// No description provided for @debtsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Qarz yo\'q'**
  String get debtsEmpty;

  /// No description provided for @goalAdd.
  ///
  /// In uz, this message translates to:
  /// **'Maqsad qo\'shish'**
  String get goalAdd;

  /// No description provided for @goalEdit.
  ///
  /// In uz, this message translates to:
  /// **'Maqsadni tahrirlash'**
  String get goalEdit;

  /// No description provided for @goalTarget.
  ///
  /// In uz, this message translates to:
  /// **'Kerakli summa'**
  String get goalTarget;

  /// No description provided for @goalSaved.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ilgan'**
  String get goalSaved;

  /// No description provided for @goalMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oyiga ajratma'**
  String get goalMonthly;

  /// No description provided for @goalDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddat (oy)'**
  String get goalDeadline;

  /// No description provided for @goalAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobga bog\'lash'**
  String get goalAccount;

  /// No description provided for @goalAccountNone.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'lanmagan (qo\'lda)'**
  String get goalAccountNone;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'oyiga {amount}'**
  String goalPerMonth(String amount);

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'oyiga {amount} (o\'rtacha)'**
  String goalPerMonthAvg(String amount);

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'{months} oy ({month})'**
  String goalEta(int months, String month);

  /// No description provided for @goalOnTrack.
  ///
  /// In uz, this message translates to:
  /// **'✅ Ulguradi'**
  String get goalOnTrack;

  /// No description provided for @goalOffTrack.
  ///
  /// In uz, this message translates to:
  /// **'⚠️ Ulgurmaydi'**
  String get goalOffTrack;

  /// No description provided for @goalReached.
  ///
  /// In uz, this message translates to:
  /// **'🎉 Yig\'ildi'**
  String get goalReached;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'Tabriklaymiz! «{name}» maqsadi yig\'ildi'**
  String goalCongrats(String name);

  /// No description provided for @goalThanks.
  ///
  /// In uz, this message translates to:
  /// **'Rahmat'**
  String get goalThanks;

  /// Hamyon (E18)
  ///
  /// In uz, this message translates to:
  /// **'«{name}» o\'chirilsinmi?'**
  String goalDeleteConfirm(String name);

  /// No description provided for @goalsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Maqsad yo\'q'**
  String get goalsEmpty;

  /// No description provided for @goalNoForecast.
  ///
  /// In uz, this message translates to:
  /// **'Prognoz uchun oyiga ajratma kiriting'**
  String get goalNoForecast;

  /// No description provided for @limitSet.
  ///
  /// In uz, this message translates to:
  /// **'Limit qo\'yish'**
  String get limitSet;

  /// No description provided for @limitNone.
  ///
  /// In uz, this message translates to:
  /// **'Limit yo\'q'**
  String get limitNone;

  /// No description provided for @limitRemove.
  ///
  /// In uz, this message translates to:
  /// **'Limitni olib tashlash'**
  String get limitRemove;

  /// No description provided for @limitsReadOnly.
  ///
  /// In uz, this message translates to:
  /// **'Limitlarni faqat ega yoki admin o\'zgartiradi'**
  String get limitsReadOnly;

  /// No description provided for @limitMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oylik limit'**
  String get limitMonthly;

  /// No description provided for @onboardingNotifyTitle.
  ///
  /// In uz, this message translates to:
  /// **'🔔 Eslatmalar'**
  String get onboardingNotifyTitle;

  /// No description provided for @onboardingNotifyBody.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov kunlari, limitlar va oylik hisobot haqida xabar beramiz'**
  String get onboardingNotifyBody;

  /// No description provided for @onboardingNotifyAllow.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get onboardingNotifyAllow;

  /// No description provided for @onboardingNotifyOn.
  ///
  /// In uz, this message translates to:
  /// **'Yoqildi'**
  String get onboardingNotifyOn;

  /// No description provided for @onboardingNotifyDenied.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmadi — keyin sozlamalardan yoqish mumkin'**
  String get onboardingNotifyDenied;

  /// No description provided for @reminderTitle.
  ///
  /// In uz, this message translates to:
  /// **'📌 Bugun to\'lov kuni'**
  String get reminderTitle;

  /// Lokal eslatma (E19-T02)
  ///
  /// In uz, this message translates to:
  /// **'{name} — {amount}'**
  String reminderBody(String name, String amount);

  /// Lokal eslatma (E19-T02)
  ///
  /// In uz, this message translates to:
  /// **'{name} — summa o\'zgaruvchi'**
  String reminderBodyUnknown(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @notifTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifTitle;

  /// No description provided for @notifChannels.
  ///
  /// In uz, this message translates to:
  /// **'Kanallar'**
  String get notifChannels;

  /// No description provided for @notifPush.
  ///
  /// In uz, this message translates to:
  /// **'Push-bildirishnomalar'**
  String get notifPush;

  /// No description provided for @notifTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram'**
  String get notifTelegram;

  /// No description provided for @notifEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get notifEmail;

  /// No description provided for @notifSchedule.
  ///
  /// In uz, this message translates to:
  /// **'Eslatmalar'**
  String get notifSchedule;

  /// No description provided for @notifReminderHour.
  ///
  /// In uz, this message translates to:
  /// **'Eslatma soati'**
  String get notifReminderHour;

  /// No description provided for @notifDaysAhead.
  ///
  /// In uz, this message translates to:
  /// **'Necha kun oldin'**
  String get notifDaysAhead;

  /// Sozlamalar (E19)
  ///
  /// In uz, this message translates to:
  /// **'{days} kun'**
  String notifDays(int days);

  /// No description provided for @notifMonthlyReport.
  ///
  /// In uz, this message translates to:
  /// **'Oylik hisobot'**
  String get notifMonthlyReport;

  /// No description provided for @notifReportDay.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot kuni'**
  String get notifReportDay;

  /// No description provided for @notifLimitAlerts.
  ///
  /// In uz, this message translates to:
  /// **'Limit ogohlantirishlari'**
  String get notifLimitAlerts;

  /// No description provided for @notifIncomeMissing.
  ///
  /// In uz, this message translates to:
  /// **'Kechikkan daromad eslatmasi'**
  String get notifIncomeMissing;

  /// No description provided for @notifTelegramLinked.
  ///
  /// In uz, this message translates to:
  /// **'Ulangan'**
  String get notifTelegramLinked;

  /// No description provided for @notifTelegramNotLinked.
  ///
  /// In uz, this message translates to:
  /// **'Ulanmagan'**
  String get notifTelegramNotLinked;

  /// No description provided for @notifTelegramLink.
  ///
  /// In uz, this message translates to:
  /// **'Ulash'**
  String get notifTelegramLink;

  /// No description provided for @notifTelegramUnlink.
  ///
  /// In uz, this message translates to:
  /// **'Uzish'**
  String get notifTelegramUnlink;

  /// No description provided for @notifTest.
  ///
  /// In uz, this message translates to:
  /// **'Sinov xabari yuborish'**
  String get notifTest;

  /// No description provided for @notifQueued.
  ///
  /// In uz, this message translates to:
  /// **'yuborildi'**
  String get notifQueued;

  /// No description provided for @notifReasonDisabled.
  ///
  /// In uz, this message translates to:
  /// **'sozlamada o\'chiq'**
  String get notifReasonDisabled;

  /// No description provided for @notifReasonNoDevice.
  ///
  /// In uz, this message translates to:
  /// **'qurilma ro\'yxatda yo\'q'**
  String get notifReasonNoDevice;

  /// No description provided for @notifReasonNotLinked.
  ///
  /// In uz, this message translates to:
  /// **'ulanmagan'**
  String get notifReasonNotLinked;

  /// No description provided for @notifReasonNotConfigured.
  ///
  /// In uz, this message translates to:
  /// **'serverda sozlanmagan'**
  String get notifReasonNotConfigured;

  /// No description provided for @notifPermission.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma ruxsati'**
  String get notifPermission;

  /// No description provided for @notifPermissionAllow.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get notifPermissionAllow;

  /// No description provided for @notifOffline.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar uchun internet kerak'**
  String get notifOffline;

  /// No description provided for @settingsProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsHousehold.
  ///
  /// In uz, this message translates to:
  /// **'Byudjet'**
  String get settingsHousehold;

  /// No description provided for @settingsAppearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In uz, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Och'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'To\'q'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma tili'**
  String get languageSystem;

  /// No description provided for @settingsSecurity.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik'**
  String get settingsSecurity;

  /// No description provided for @settingsData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar'**
  String get settingsData;

  /// No description provided for @settingsExport.
  ///
  /// In uz, this message translates to:
  /// **'Eksport (JSON)'**
  String get settingsExport;

  /// No description provided for @settingsExportText.
  ///
  /// In uz, this message translates to:
  /// **'My Wallet eksporti'**
  String get settingsExportText;

  /// No description provided for @settingsExportFailed.
  ///
  /// In uz, this message translates to:
  /// **'Eksport qilib bo\'lmadi'**
  String get settingsExportFailed;

  /// No description provided for @settingsAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt'**
  String get settingsAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o\'chirish'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In uz, this message translates to:
  /// **'Faqat siz a\'zo bo\'lgan byudjetlar va ularning ma\'lumotlari o\'chiriladi, boshqa byudjetlardan chiqasiz. Bu amalni qaytarib bo\'lmaydi.'**
  String get deleteAccountBody;

  /// Sozlamalar (E19-T04)
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash uchun «{word}» deb yozing'**
  String deleteAccountConfirm(String word);

  /// No description provided for @deleteAccountWord.
  ///
  /// In uz, this message translates to:
  /// **'O\'CHIRISH'**
  String get deleteAccountWord;

  /// No description provided for @deleteAccountLastOwner.
  ///
  /// In uz, this message translates to:
  /// **'Siz boshqa a\'zolari bor byudjetning yagona egasisiz — avval egalikni boshqa a\'zoga o\'tkazing'**
  String get deleteAccountLastOwner;

  /// No description provided for @settingsAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get settingsAbout;

  /// Sozlamalar (E19-T04)
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsLicenses.
  ///
  /// In uz, this message translates to:
  /// **'Litsenziyalar'**
  String get settingsLicenses;

  /// No description provided for @amountHidden.
  ///
  /// In uz, this message translates to:
  /// **'Summa yashirin'**
  String get amountHidden;

  /// No description provided for @statusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Kechikkan'**
  String get statusOverdue;

  /// No description provided for @statusPartial.
  ///
  /// In uz, this message translates to:
  /// **'Qisman to\'langan'**
  String get statusPartial;

  /// No description provided for @statusPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get statusPaid;

  /// No description provided for @statusSkipped.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazilgan'**
  String get statusSkipped;

  /// No description provided for @statusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get statusPending;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
    case 'uz':
      return AppL10nUz();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
