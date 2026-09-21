// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppL10nUz extends AppL10n {
  AppL10nUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'My Wallet';

  @override
  String get tabHome => 'Xulosa';

  @override
  String get tabTransactions => 'Amallar';

  @override
  String get tabPayments => 'To\'lovlar';

  @override
  String get tabWallet => 'Hamyon';

  @override
  String get actionAdd => 'Qo\'shish';

  @override
  String get actionSave => 'Saqlash';

  @override
  String get actionCancel => 'Bekor qilish';

  @override
  String get actionRetry => 'Qayta urinish';

  @override
  String get errorUnexpected => 'Kutilmagan xato. Qayta urinib ko\'ring.';

  @override
  String get errorNotFound => 'Sahifa topilmadi';

  @override
  String get emptyTitle => 'Hozircha ma\'lumot yo\'q';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Yanvar',
      '2': 'Fevral',
      '3': 'Mart',
      '4': 'Aprel',
      '5': 'May',
      '6': 'Iyun',
      '7': 'Iyul',
      '8': 'Avgust',
      '9': 'Sentabr',
      '10': 'Oktabr',
      '11': 'Noyabr',
      '12': 'Dekabr',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get notFoundMessage => 'Havola eskirgan yoki noto\'g\'ri.';

  @override
  String get actionHome => 'Bosh sahifaga';

  @override
  String get comingSoon => 'Tez orada';

  @override
  String get addTitle => 'Yangi amal';

  @override
  String get navAddLabel => 'Amal qo\'shish';

  @override
  String get syncStatusTitle => 'Sinxron holati';

  @override
  String get syncSynced => 'Sinxronlangan';

  @override
  String get syncSyncing => 'Yuborilmoqda…';

  @override
  String syncPending(int count) {
    return '$count ta o\'zgarish yuborilmagan';
  }

  @override
  String get syncOffline => 'Oflayn — tarmoq kelganda yuboriladi';

  @override
  String syncIssues(int count) {
    return '$count ta muammo';
  }

  @override
  String get syncSignedOut => 'Qayta kirish kerak';

  @override
  String syncLastAt(String time) {
    return 'Oxirgi sinxron: $time';
  }

  @override
  String get syncNever => 'Hali sinxronlanmagan';

  @override
  String get syncNow => 'Hozir sinxronlash';

  @override
  String get syncFullReload => 'To\'liq qayta yuklash';

  @override
  String get syncFullReloadConfirm =>
      'Byudjet ma\'lumotlari serverdan qaytadan yuklanadi. Yuborilmagan o\'zgarishlar saqlanadi.';

  @override
  String get syncIssueConflict =>
      'Boshqa qurilmada o\'zgartirilgan — server versiyasi ko\'rsatilmoqda';

  @override
  String syncIssueRejected(String code) {
    return 'Server qabul qilmadi ($code) — o\'zgarish bekor qilindi';
  }

  @override
  String get syncKeepMine => 'Mening versiyam';

  @override
  String get syncDismiss => 'Tushunarli';

  @override
  String syncRecordKind(String table) {
    String _temp0 = intl.Intl.selectLogic(table, {
      'transactions': 'Amal',
      'planned_items': 'Reja',
      'accounts': 'Hisob',
      'categories': 'Kategoriya',
      'debts': 'Qarz',
      'goals': 'Maqsad',
      'other': 'Yozuv',
    });
    return '$_temp0';
  }

  @override
  String get authTagline => 'Pulingiz qayerga ketayotganini biling';

  @override
  String get authGoogle => 'Google bilan kirish';

  @override
  String get authOr => 'yoki';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authSendCode => 'Kod olish';

  @override
  String get authCodeTitle => 'Pochtangizni tekshiring';

  @override
  String authCodeSent(String email, int length) {
    return '$email manziliga $length xonali kod yubordik';
  }

  @override
  String get authCodeLabel => 'Kod';

  @override
  String get authVerify => 'Kirish';

  @override
  String get authResend => 'Kodni qayta yuborish';

  @override
  String authResendIn(int seconds) {
    return 'Qayta yuborish — $seconds s';
  }

  @override
  String get authChangeEmail => 'Boshqa email';

  @override
  String get authErrorInvalidEmail => 'Email manzilni tekshiring';

  @override
  String authErrorInvalidCode(int length) {
    return '$length xonali kodni kiriting';
  }

  @override
  String get authErrorCodeExpired => 'Kod noto\'g\'ri yoki eskirgan';

  @override
  String get authErrorRateLimit =>
      'Juda ko\'p urinish — birozdan keyin qayta urinib ko\'ring';

  @override
  String get authErrorGoogle =>
      'Google bilan kirib bo\'lmadi — email orqali kiring';

  @override
  String get errorOffline => 'Internet yo\'q — ulanishni tekshiring';

  @override
  String get signOut => 'Chiqish';

  @override
  String get signOutConfirm =>
      'Qurilmadagi ma\'lumot o\'chiriladi — qayta kirganingizda serverdan yuklanadi.';

  @override
  String signOutUnsent(int count) {
    return '$count ta o\'zgarish hali serverga yetmagan — chiqsangiz ular yo\'qoladi.';
  }

  @override
  String get startupLoading => 'Byudjet yuklanmoqda…';

  @override
  String get startupFailed => 'Ma\'lumotni yuklab bo\'lmadi';

  @override
  String get householdSetupTitle => 'Byudjetni boshlang';

  @override
  String get householdSetupSubtitle =>
      'Yangi byudjet yarating yoki taklif kodi bilan mavjudiga qo\'shiling.';

  @override
  String get householdCreateTitle => 'Yangi byudjet';

  @override
  String get householdNameLabel => 'Byudjet nomi';

  @override
  String get householdNameDefault => 'Mening byudjetim';

  @override
  String get householdCreate => 'Yaratish';

  @override
  String get householdJoinTitle => 'Taklif kodi bilan qo\'shilish';

  @override
  String get householdCodeLabel => 'Taklif kodi';

  @override
  String get householdJoin => 'Qo\'shilish';

  @override
  String get householdScan => 'QR kodni skanerlash';

  @override
  String get householdScanTitle => 'Taklif QR kodi';

  @override
  String get householdErrorName => 'Byudjet nomini kiriting';

  @override
  String get householdErrorCode => 'Kod 8 belgidan iborat';

  @override
  String get householdErrorNotFound => 'Bunday kod topilmadi';

  @override
  String get householdErrorUsed => 'Kod allaqachon ishlatilgan';

  @override
  String get householdErrorExpired => 'Kod muddati tugagan (7 kun)';

  @override
  String get householdErrorMember => 'Siz allaqachon bu byudjet a\'zosisiz';

  @override
  String get onboardingTitle => 'Sozlash';

  @override
  String onboardingStep(int current, int total) {
    return '$current/$total-qadam';
  }

  @override
  String get onboardingAccountsTitle => 'Hisoblar va qoldiq';

  @override
  String get onboardingAccountsSubtitle =>
      'Hozirgi qoldiqni kiriting — keyin hammasi shundan hisoblanadi.';

  @override
  String get onboardingIncomeTitle => 'Maosh jadvali';

  @override
  String get onboardingIncomeSubtitle =>
      'Qaysi daromadlarni olasiz, qaysi kuni va qaysi oyga tegishli.';

  @override
  String get onboardingRecurringTitle => 'Doimiy to\'lovlar';

  @override
  String get onboardingRecurringSubtitle =>
      'Har oy takrorlanadigan to\'lovlar — har oy avtomatik rejaga tushadi.';

  @override
  String get onboardingFundTitle => '👤 Shaxsiy fond';

  @override
  String get onboardingFundSubtitle =>
      'Har oy o\'zingiz uchun ajratadigan ulush.';

  @override
  String get onboardingDoneTitle => 'Tayyor!';

  @override
  String get onboardingDoneSubtitle =>
      'Joriy oy ochiladi va rejalar yaratiladi.';

  @override
  String get onboardingWaiting => 'Spravochniklar yuklanmoqda…';

  @override
  String get onboardingFinish => 'Boshlash';

  @override
  String get onboardingSkip => 'O\'tkazib yuborish';

  @override
  String get actionNext => 'Davom etish';

  @override
  String get actionBack => 'Orqaga';

  @override
  String get fieldDay => 'Kuni';

  @override
  String get fieldAmount => 'Summa';

  @override
  String get fieldAccount => 'Hisob';

  @override
  String get monthThis => 'Shu oy';

  @override
  String get monthPrevious => 'Oldingi oy';

  @override
  String get fundPercentMode => 'Foiz';

  @override
  String get fundFixedMode => 'Qat\'iy summa';

  @override
  String get fundPercent => 'Daromadning foizi';

  @override
  String get fundSource => 'Qaysi hisobdan';

  @override
  String get autoPay => 'Avto to\'lov';

  @override
  String onboardingSummary(int accounts, int incomes, int plans) {
    return '$accounts ta hisob, $incomes ta daromad turi, $plans ta doimiy to\'lov';
  }

  @override
  String get updateRequiredTitle => 'Ilovani yangilang';

  @override
  String updateRequiredBody(String version) {
    return 'Yangi versiya ($version) kerak — Play Market\'dan yangilang.';
  }

  @override
  String get householdSwitch => 'Byudjetni almashtirish';

  @override
  String get householdAdd => 'Yangi byudjet yoki taklif kodi';

  @override
  String get offlineBanner =>
      'Oflayn — o\'zgarishlar tarmoq kelganda yuboriladi';

  @override
  String get menuSettings => 'Sozlamalar';

  @override
  String get lockTitle => 'Ilova qulfi';

  @override
  String get lockEnterPin => 'PIN kodni kiriting';

  @override
  String get lockWrongPin => 'PIN noto\'g\'ri';

  @override
  String get lockBiometrics => 'Biometrika';

  @override
  String get lockNewPin => 'Yangi PIN';

  @override
  String get lockRepeatPin => 'PIN ni takrorlang';

  @override
  String get lockMismatch => 'PIN mos kelmadi';

  @override
  String get lockSetPin => 'PIN o\'rnatish';

  @override
  String get lockChangePin => 'PIN ni o\'zgartirish';

  @override
  String get lockDisable => 'Qulfni o\'chirish';

  @override
  String get lockAuto => 'Avto-qulf';

  @override
  String lockAutoValue(int minutes) {
    return '$minutes daqiqadan keyin';
  }

  @override
  String get lockSecureScreen => 'Ilova almashtirgichda yashirish';

  @override
  String get lockForgot => 'PIN esimdan chiqdi — chiqish';

  @override
  String get privacyMode => 'Maxfiylik rejimi';

  @override
  String get kindExpense => 'Xarajat';

  @override
  String get kindIncome => 'Daromad';

  @override
  String get kindTransfer => 'O\'tkazma';

  @override
  String get fieldCategory => 'Kategoriya';

  @override
  String get fieldPayee => 'Joy / kimga';

  @override
  String get fieldNote => 'Izoh';

  @override
  String get fieldTo => 'Qayerga';

  @override
  String get dateToday => 'Bugun';

  @override
  String get dateYesterday => 'Kecha';

  @override
  String get dateChoose => 'Sana';

  @override
  String get categorySearch => 'Kategoriya qidirish';

  @override
  String get saved => 'Saqlandi';

  @override
  String get errorMonthClosed => 'Oy yopilgan — yozib bo\'lmaydi';

  @override
  String get categoryNew => 'Yangi kategoriya';

  @override
  String get fieldTags => 'Teglar';

  @override
  String get fieldDebt => 'Qarzga bog\'lash';

  @override
  String get errorCategoryRequired => 'Kategoriyani tanlang';

  @override
  String get errorCategoryInvalid => 'Bu kategoriyani tanlab bo\'lmaydi';

  @override
  String get errorAccountRequired => 'Hisobni tanlang';

  @override
  String get errorTargetAccount => 'Boshqa hisobni tanlang';

  @override
  String get errorAmountRequired => 'Summani kiriting';

  @override
  String get monthClosedConfirmTitle => 'Oy yopilgan';

  @override
  String get monthClosedConfirmBody =>
      'Bu amal yopilgan oyga tushadi. Baribir yozilsinmi?';

  @override
  String get actionRecord => 'Yozish';

  @override
  String monthHintIncome(String month, String relation) {
    return '→ $month oyining daromadi sifatida yoziladi ($relation)';
  }

  @override
  String monthHintExpense(String month, String relation) {
    return '→ $month oyining byudjetiga ($relation)';
  }

  @override
  String get monthRelationSame => 'shu oy';

  @override
  String get monthRelationPrevious => 'oldingi oy';

  @override
  String get monthRelationNext => 'keyingi oy';

  @override
  String get monthRelationManual => 'qo\'lda tanlangan';

  @override
  String get monthQuestion => 'Qaysi oyning byudjetiga?';

  @override
  String get monthByDate => 'Sana bo\'yicha';

  @override
  String get monthChoose => 'Tanlash';
}
