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

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada'**
  String get comingSoon;

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
