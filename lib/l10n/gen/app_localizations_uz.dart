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
}
