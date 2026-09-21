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
  String get monthNext => 'Keyingi oy';

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

  @override
  String quickSaved(String name, String amount) {
    return '$name — $amount yozildi';
  }

  @override
  String get actionUndo => 'Bekor qilish';

  @override
  String get quickHint => 'Bosing — darhol yoziladi, bosib turing — tahrirlash';

  @override
  String get fundAllocationHint =>
      '👤 Bu ajratma sifatida hisoblanadi — oy qoldig\'ini kamaytiradi';

  @override
  String get fundReturnHint =>
      '👤 Ajratmaning qaytishi — oy qoldig\'ini oshiradi';

  @override
  String get fundSpendHint =>
      '👤 Fonddan sarf — oylik qoldiqqa ta\'sir qilmaydi';

  @override
  String get errorCurrencyMismatch =>
      'Hisoblar valyutasi har xil — bunday o\'tkazma keyinroq qo\'shiladi';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'dushanba',
      '2': 'seshanba',
      '3': 'chorshanba',
      '4': 'payshanba',
      '5': 'juma',
      '6': 'shanba',
      '7': 'yakshanba',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String dayTitle(int day, String month, String weekday) {
    return '$day-$month, $weekday';
  }

  @override
  String get transactionsEmpty => 'Bu oyda amal yo\'q';

  @override
  String get transactionsEmptyFiltered => 'Filtrga mos amal yo\'q';

  @override
  String get searchHint => 'Joy, izoh yoki summa';

  @override
  String get filterAll => 'Hammasi';

  @override
  String get filterClear => 'Filtrni tozalash';

  @override
  String get monthClosedBanner => 'Oy yopilgan — o\'zgartirish tasdiq bilan';

  @override
  String get deleted => 'O\'chirildi';

  @override
  String get editTitle => 'Tahrirlash';

  @override
  String get receipt => 'Chek';

  @override
  String get receiptCamera => 'Kamera';

  @override
  String get receiptGallery => 'Galereya';

  @override
  String get receiptTooLarge => 'Rasm juda katta — boshqasini tanlang';

  @override
  String get receiptPending => 'Yuklanishi kutilmoqda';

  @override
  String get dashBalance => 'Qoldiq';

  @override
  String get dashForecast => 'Prognoz qoldiq';

  @override
  String dashMonthEnd(String amount) {
    return 'Oy oxirida ≈ $amount';
  }

  @override
  String dashPerDay(String amount) {
    return 'Kuniga ≈ $amount';
  }

  @override
  String get dashSaved => 'Orttirgan';

  @override
  String get dashCard => 'Karta';

  @override
  String get dashCash => 'Naqd';

  @override
  String get dashPlan => 'Reja bajarilishi';

  @override
  String dashUnknown(int count) {
    return '+ $count ta ?';
  }

  @override
  String get dashUpcoming => 'Yaqin to\'lovlar';

  @override
  String get dashMarkPaid => 'To\'landi';

  @override
  String get dashCategories => 'Kategoriyalar';

  @override
  String get dashIncomeTypes => 'Daromad turlari';

  @override
  String get dashFund => '👤 Shaxsiy fond';

  @override
  String get dashSavings => '🏦 Jamg\'arma';

  @override
  String get dashThisMonth => 'Shu oy';

  @override
  String get dashAllocated => 'Ajratilgan';

  @override
  String get dashSpent => 'Sarflangan';

  @override
  String get dashDebts => 'Qarzlar';

  @override
  String get dashIOwe => 'Men qarzman';

  @override
  String get dashOwedToMe => 'Menga qarz';

  @override
  String get dashMonthly => 'Oyiga';

  @override
  String get dashGoals => 'Maqsadlar';

  @override
  String get dashForecastTitle => 'Prognoz';

  @override
  String dashDays(int elapsed, int total) {
    return '$elapsed / $total kun';
  }

  @override
  String get dashDailySpend => 'Kunlik sarf';

  @override
  String get dashMonthEndSpend => 'Oy oxiri sarfi';

  @override
  String get dashExpectedIncome => 'Kutilayotgan daromad';

  @override
  String dashReceivedSoFar(String amount) {
    return 'hozircha kelgani $amount';
  }

  @override
  String get dashNotOpened =>
      'Oy hali ochilmagan — doimiy to\'lovlar rejaga tushmagan';

  @override
  String get dashOpenMonth => 'Oyni ochish';

  @override
  String dashOpenMonthBody(int count) {
    return '$count ta reja yaratiladi';
  }

  @override
  String get dashClosed => 'Yopilgan';

  @override
  String get dashEmpty => 'Bu oyda hali yozuv yo\'q';

  @override
  String get dashEmptyHint => '“+” tugmasi bilan birinchi amalni qo\'shing';

  @override
  String get fieldDate => 'Sana';

  @override
  String get payTabExpenses => 'Xarajatlar';

  @override
  String get payTabIncome => 'Kutilayotgan daromadlar';

  @override
  String get payUnpaid => 'To\'lanmagan';

  @override
  String get payIncomePending => 'Kelishi kutilmoqda';

  @override
  String get paySectionOverdue => '⚠️ Kechikkan';

  @override
  String get paySectionToday => '📌 Bugun';

  @override
  String paySectionSoon(int days) {
    return '🗓 Yaqin $days kunda';
  }

  @override
  String get paySectionLater => 'Keyinroq';

  @override
  String get paySectionPaid => '✅ To\'langan';

  @override
  String get paySectionReceived => '✅ Kelgan';

  @override
  String get paySectionSkipped => '⏭ O\'tkazilgan';

  @override
  String get payMarkReceived => 'Keldi';

  @override
  String get paySkip => 'O\'tkazib yuborish';

  @override
  String get payUnskip => 'Qaytarish';

  @override
  String get paySkipped => 'O\'tkazib yuborildi';

  @override
  String get payEditAmount => 'Shu oy summasi';

  @override
  String get payClose => 'Yopish';

  @override
  String get payReopen => 'Qayta ochish';

  @override
  String get payAmountVaries => 'Summa o\'zgaruvchi';

  @override
  String get payAmountRequired =>
      'Bu to\'lovning summasi belgilanmagan — qancha to\'laganingizni kiriting';

  @override
  String get payPartialTitle => 'Qisman to\'lov';

  @override
  String payPartialBody(String amount) {
    return 'Qolgan $amount ni keyin to\'laysizmi?';
  }

  @override
  String get payPartialLater => 'Keyin to\'layman';

  @override
  String get payAutoPay => 'Avto to\'lov';

  @override
  String get payEmpty => 'Bu oyda reja yo\'q';

  @override
  String get payEmptyHint =>
      'Oyni oching — doimiy to\'lovlardan rejalar yaratiladi';

  @override
  String get payCalendar => 'Kalendar';

  @override
  String get payList => 'Ro\'yxat';

  @override
  String get payDayEmpty => 'Bu kunda to\'lov yo\'q';

  @override
  String get errorPlanPaid => 'Bu reja allaqachon to\'langan';

  @override
  String get errorPlanSkipped => 'Reja o\'tkazib yuborilgan';

  @override
  String get errorPlanNotFound => 'Reja topilmadi';

  @override
  String openMonthCreates(int count) {
    return 'Yaratiladi: $count ta';
  }

  @override
  String openMonthExisting(int count) {
    return 'Allaqachon bor: $count ta';
  }

  @override
  String get openMonthNothing => 'Yangi reja yo\'q — hammasi allaqachon bor';

  @override
  String yearTitle(String year) {
    return '$year-yil';
  }

  @override
  String get yearTotal => 'JAMI';

  @override
  String get yearView => 'Yillik ko\'rinish';

  @override
  String get yearEmpty => 'Bu yilda yozuv yo\'q';

  @override
  String get categoryTrend => 'Oyma-oy';

  @override
  String get categoryTransactions => 'Amallarni ko\'rish';

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Yan',
      '2': 'Fev',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Iyn',
      '7': 'Iyl',
      '8': 'Avg',
      '9': 'Sen',
      '10': 'Okt',
      '11': 'Noy',
      '12': 'Dek',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get shareReport => 'Hisobotni ulashish';

  @override
  String get shareAction => 'Ulashish';

  @override
  String get shareFailed => 'Ulashib bo\'lmadi';

  @override
  String get shareTopExpenses => 'Eng katta xarajatlar';

  @override
  String get fieldName => 'Nomi';

  @override
  String get actionDelete => 'O\'chirish';

  @override
  String get actionEdit => 'Tahrirlash';

  @override
  String get errorInvalidName => 'Nomni kiriting (60 belgigacha)';

  @override
  String get errorDuplicateName => 'Bu nom allaqachon bor';

  @override
  String get errorInvalidAmount => 'Summa noto\'g\'ri';

  @override
  String get errorPaidBefore => 'Oldin to\'langan umumiy summadan oshmasin';

  @override
  String get accountTypeCash => 'Naqd';

  @override
  String get accountTypeCard => 'Karta';

  @override
  String get accountTypeBank => 'Bank hisobi';

  @override
  String get accountTypeEwallet => 'Elektron hamyon';

  @override
  String get accountTypeDeposit => 'Omonat';

  @override
  String get accountTypePersonalFund => 'Shaxsiy fond';

  @override
  String get accountTypeOther => 'Boshqa';

  @override
  String get walletAccounts => 'Hisoblar';

  @override
  String get walletTotalNoFund => 'Jami (fondsiz)';

  @override
  String get walletNegativeCash => 'Naqd qoldiq manfiy — yozuvlarni tekshiring';

  @override
  String get walletDebts => '💳 Qarzlar';

  @override
  String get walletGoals => '🎯 Maqsadlar';

  @override
  String get walletLimits => '📊 Limitlar';

  @override
  String get fundAllTime => 'Butun davr';

  @override
  String get fundAddSpend => 'Sarf qo\'shish';

  @override
  String get fundSpends => 'Sarflar tarixi';

  @override
  String get fundAllocation => 'Shu oy ajratmasi';

  @override
  String fundAllocationLive(String amount, String percent) {
    return 'Hozirgi daromaddan: $amount ($percent%)';
  }

  @override
  String get fundAllocationNone => 'Bu oy uchun ajratma rejasi yo\'q';

  @override
  String get fundMonths => 'Oylar bo\'yicha';

  @override
  String get savingsTotal => 'Shu oygacha to\'plangan';

  @override
  String get savingsAvg => 'Oyiga o\'rtacha orttirish';

  @override
  String savingsMonthsCount(int count) {
    return '$count oy';
  }

  @override
  String get savingsAccumulated => 'To\'plangan';

  @override
  String get savingsNote =>
      'Jamg\'arma — ko\'rsatkich. Pul jismonan qayerda ekanini «Hisoblar» ko\'rsatadi.';

  @override
  String get debtNet => '⚖️ Sof holat';

  @override
  String get debtMonthly => 'Oylik majburiyat';

  @override
  String get debtPaidThisMonth => 'Shu oy to\'langan';

  @override
  String get debtStatusPaying => 'To\'lanyapti';

  @override
  String get debtStatusPending => 'Kutilmoqda';

  @override
  String get debtStatusUnlinked => 'Bog\'lanmagan';

  @override
  String get debtStatusClosed => 'Yopildi';

  @override
  String debtRemaining(String amount) {
    return 'Qolgan: $amount';
  }

  @override
  String debtEnds(String month) {
    return 'Tugaydi: $month';
  }

  @override
  String debtPending(String amount) {
    return 'Kutilmoqda: $amount';
  }

  @override
  String get debtAdd => 'Qarz qo\'shish';

  @override
  String get debtEdit => 'Qarzni tahrirlash';

  @override
  String get debtTotal => 'Umumiy summa';

  @override
  String get debtPaidBefore => 'Oldin to\'langan';

  @override
  String get debtMonthlyPayment => 'Oylik to\'lov';

  @override
  String get debtDueDate => 'Muddati';

  @override
  String get debtArchive => 'Arxivlash';

  @override
  String get debtUnarchive => 'Arxivdan chiqarish';

  @override
  String get debtArchived => 'Arxiv';

  @override
  String get debtPayments => 'Bog\'langan to\'lovlar';

  @override
  String get debtNoPayments => 'Hali to\'lov yo\'q';

  @override
  String get debtsEmpty => 'Qarz yo\'q';

  @override
  String get goalAdd => 'Maqsad qo\'shish';

  @override
  String get goalEdit => 'Maqsadni tahrirlash';

  @override
  String get goalTarget => 'Kerakli summa';

  @override
  String get goalSaved => 'Yig\'ilgan';

  @override
  String get goalMonthly => 'Oyiga ajratma';

  @override
  String get goalDeadline => 'Muddat (oy)';

  @override
  String get goalAccount => 'Hisobga bog\'lash';

  @override
  String get goalAccountNone => 'Bog\'lanmagan (qo\'lda)';

  @override
  String goalPerMonth(String amount) {
    return 'oyiga $amount';
  }

  @override
  String goalPerMonthAvg(String amount) {
    return 'oyiga $amount (o\'rtacha)';
  }

  @override
  String goalEta(int months, String month) {
    return '$months oy ($month)';
  }

  @override
  String get goalOnTrack => '✅ Ulguradi';

  @override
  String get goalOffTrack => '⚠️ Ulgurmaydi';

  @override
  String get goalReached => '🎉 Yig\'ildi';

  @override
  String goalCongrats(String name) {
    return 'Tabriklaymiz! «$name» maqsadi yig\'ildi';
  }

  @override
  String get goalThanks => 'Rahmat';

  @override
  String goalDeleteConfirm(String name) {
    return '«$name» o\'chirilsinmi?';
  }

  @override
  String get goalsEmpty => 'Maqsad yo\'q';

  @override
  String get goalNoForecast => 'Prognoz uchun oyiga ajratma kiriting';

  @override
  String get limitSet => 'Limit qo\'yish';

  @override
  String get limitNone => 'Limit yo\'q';

  @override
  String get limitRemove => 'Limitni olib tashlash';

  @override
  String get limitsReadOnly => 'Limitlarni faqat ega yoki admin o\'zgartiradi';

  @override
  String get limitMonthly => 'Oylik limit';

  @override
  String get onboardingNotifyTitle => '🔔 Eslatmalar';

  @override
  String get onboardingNotifyBody =>
      'To\'lov kunlari, limitlar va oylik hisobot haqida xabar beramiz';

  @override
  String get onboardingNotifyAllow => 'Yoqish';

  @override
  String get onboardingNotifyOn => 'Yoqildi';

  @override
  String get onboardingNotifyDenied =>
      'Ruxsat berilmadi — keyin sozlamalardan yoqish mumkin';

  @override
  String get reminderTitle => '📌 Bugun to\'lov kuni';

  @override
  String reminderBody(String name, String amount) {
    return '$name — $amount';
  }

  @override
  String reminderBodyUnknown(String name) {
    return '$name — summa o\'zgaruvchi';
  }

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get notifTitle => 'Bildirishnomalar';

  @override
  String get notifChannels => 'Kanallar';

  @override
  String get notifPush => 'Push-bildirishnomalar';

  @override
  String get notifTelegram => 'Telegram';

  @override
  String get notifEmail => 'Email';

  @override
  String get notifSchedule => 'Eslatmalar';

  @override
  String get notifReminderHour => 'Eslatma soati';

  @override
  String get notifDaysAhead => 'Necha kun oldin';

  @override
  String notifDays(int days) {
    return '$days kun';
  }

  @override
  String get notifMonthlyReport => 'Oylik hisobot';

  @override
  String get notifReportDay => 'Hisobot kuni';

  @override
  String get notifLimitAlerts => 'Limit ogohlantirishlari';

  @override
  String get notifIncomeMissing => 'Kechikkan daromad eslatmasi';

  @override
  String get notifTelegramLinked => 'Ulangan';

  @override
  String get notifTelegramNotLinked => 'Ulanmagan';

  @override
  String get notifTelegramLink => 'Ulash';

  @override
  String get notifTelegramUnlink => 'Uzish';

  @override
  String get notifTest => 'Sinov xabari yuborish';

  @override
  String get notifQueued => 'yuborildi';

  @override
  String get notifReasonDisabled => 'sozlamada o\'chiq';

  @override
  String get notifReasonNoDevice => 'qurilma ro\'yxatda yo\'q';

  @override
  String get notifReasonNotLinked => 'ulanmagan';

  @override
  String get notifReasonNotConfigured => 'serverda sozlanmagan';

  @override
  String get notifPermission => 'Qurilma ruxsati';

  @override
  String get notifPermissionAllow => 'Ruxsat berish';

  @override
  String get notifOffline => 'Sozlamalar uchun internet kerak';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsHousehold => 'Byudjet';

  @override
  String get settingsAppearance => 'Ko\'rinish';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Och';

  @override
  String get themeDark => 'To\'q';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get languageSystem => 'Qurilma tili';

  @override
  String get settingsSecurity => 'Xavfsizlik';

  @override
  String get settingsData => 'Ma\'lumotlar';

  @override
  String get settingsExport => 'Eksport (JSON)';

  @override
  String get settingsExportText => 'My Wallet eksporti';

  @override
  String get settingsExportFailed => 'Eksport qilib bo\'lmadi';

  @override
  String get settingsAccount => 'Akkaunt';

  @override
  String get deleteAccount => 'Akkauntni o\'chirish';

  @override
  String get deleteAccountBody =>
      'Faqat siz a\'zo bo\'lgan byudjetlar va ularning ma\'lumotlari o\'chiriladi, boshqa byudjetlardan chiqasiz. Bu amalni qaytarib bo\'lmaydi.';

  @override
  String deleteAccountConfirm(String word) {
    return 'Tasdiqlash uchun «$word» deb yozing';
  }

  @override
  String get deleteAccountWord => 'O\'CHIRISH';

  @override
  String get deleteAccountLastOwner =>
      'Siz boshqa a\'zolari bor byudjetning yagona egasisiz — avval egalikni boshqa a\'zoga o\'tkazing';

  @override
  String get settingsAbout => 'Ilova haqida';

  @override
  String settingsVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String get settingsLicenses => 'Litsenziyalar';

  @override
  String get amountHidden => 'Summa yashirin';

  @override
  String get statusOverdue => 'Kechikkan';

  @override
  String get statusPartial => 'Qisman to\'langan';

  @override
  String get statusPaid => 'To\'langan';

  @override
  String get statusSkipped => 'O\'tkazilgan';

  @override
  String get statusPending => 'Kutilmoqda';
}
