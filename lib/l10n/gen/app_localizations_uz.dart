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
}
