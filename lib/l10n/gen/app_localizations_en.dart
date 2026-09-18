// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My Wallet';

  @override
  String get tabHome => 'Overview';

  @override
  String get tabTransactions => 'Transactions';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Try again';

  @override
  String get errorUnexpected => 'Unexpected error. Please try again.';

  @override
  String get errorNotFound => 'Page not found';

  @override
  String get emptyTitle => 'No data yet';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'January',
      '2': 'February',
      '3': 'March',
      '4': 'April',
      '5': 'May',
      '6': 'June',
      '7': 'July',
      '8': 'August',
      '9': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get notFoundMessage => 'The link is outdated or incorrect.';

  @override
  String get actionHome => 'Go home';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get addTitle => 'New transaction';

  @override
  String get navAddLabel => 'Add transaction';
}
