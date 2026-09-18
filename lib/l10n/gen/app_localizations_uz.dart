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
}
