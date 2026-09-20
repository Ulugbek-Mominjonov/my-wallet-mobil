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

  @override
  String get syncStatusTitle => 'Sync status';

  @override
  String get syncSynced => 'Synced';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String syncPending(int count) {
    return '$count changes not sent yet';
  }

  @override
  String get syncOffline =>
      'Offline — changes will sync when you\'re back online';

  @override
  String syncIssues(int count) {
    return '$count issues';
  }

  @override
  String get syncSignedOut => 'Please sign in again';

  @override
  String syncLastAt(String time) {
    return 'Last synced: $time';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncFullReload => 'Full reload';

  @override
  String get syncFullReloadConfirm =>
      'Budget data will be reloaded from the server. Unsent changes are kept.';

  @override
  String get syncIssueConflict =>
      'Changed on another device — showing the server version';

  @override
  String syncIssueRejected(String code) {
    return 'Rejected by the server ($code) — the change was undone';
  }

  @override
  String get syncKeepMine => 'Keep my version';

  @override
  String get syncDismiss => 'Got it';

  @override
  String syncRecordKind(String table) {
    String _temp0 = intl.Intl.selectLogic(table, {
      'transactions': 'Transaction',
      'planned_items': 'Payment',
      'accounts': 'Account',
      'categories': 'Category',
      'debts': 'Debt',
      'goals': 'Goal',
      'other': 'Record',
    });
    return '$_temp0';
  }

  @override
  String get authTagline => 'Know where your money goes';

  @override
  String get authGoogle => 'Continue with Google';

  @override
  String get authOr => 'or';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authSendCode => 'Get a code';

  @override
  String get authCodeTitle => 'Check your email';

  @override
  String authCodeSent(String email, int length) {
    return 'We sent a $length-digit code to $email';
  }

  @override
  String get authCodeLabel => 'Code';

  @override
  String get authVerify => 'Sign in';

  @override
  String get authResend => 'Resend code';

  @override
  String authResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authChangeEmail => 'Use another email';

  @override
  String get authErrorInvalidEmail => 'Check the email address';

  @override
  String authErrorInvalidCode(int length) {
    return 'Enter the $length-digit code';
  }

  @override
  String get authErrorCodeExpired => 'The code is wrong or expired';

  @override
  String get authErrorRateLimit => 'Too many attempts — try again a bit later';

  @override
  String get authErrorGoogle => 'Google sign-in failed — use email instead';

  @override
  String get errorOffline => 'No internet — check your connection';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm =>
      'Data on this device will be removed — it will load from the server next time you sign in.';

  @override
  String signOutUnsent(int count) {
    return '$count changes haven\'t reached the server yet — signing out will lose them.';
  }
}
