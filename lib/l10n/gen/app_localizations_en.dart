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

  @override
  String get startupLoading => 'Loading your budget…';

  @override
  String get startupFailed => 'Couldn\'t load your data';

  @override
  String get householdSetupTitle => 'Start your budget';

  @override
  String get householdSetupSubtitle =>
      'Create a new budget or join an existing one with an invite code.';

  @override
  String get householdCreateTitle => 'New budget';

  @override
  String get householdNameLabel => 'Budget name';

  @override
  String get householdNameDefault => 'My budget';

  @override
  String get householdCreate => 'Create';

  @override
  String get householdJoinTitle => 'Join with an invite code';

  @override
  String get householdCodeLabel => 'Invite code';

  @override
  String get householdJoin => 'Join';

  @override
  String get householdScan => 'Scan QR code';

  @override
  String get householdScanTitle => 'Invite QR code';

  @override
  String get householdErrorName => 'Enter a budget name';

  @override
  String get householdErrorCode => 'The code is 8 characters long';

  @override
  String get householdErrorNotFound => 'No such code';

  @override
  String get householdErrorUsed => 'The code has already been used';

  @override
  String get householdErrorExpired => 'The code has expired (7 days)';

  @override
  String get householdErrorMember => 'You\'re already a member of this budget';

  @override
  String get onboardingTitle => 'Setup';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingAccountsTitle => 'Accounts and balances';

  @override
  String get onboardingAccountsSubtitle =>
      'Enter your current balance — everything is counted from it.';

  @override
  String get onboardingIncomeTitle => 'Income schedule';

  @override
  String get onboardingIncomeSubtitle =>
      'Which income you receive, on which day, and which month it belongs to.';

  @override
  String get onboardingRecurringTitle => 'Recurring payments';

  @override
  String get onboardingRecurringSubtitle =>
      'Monthly payments — they go into the plan automatically each month.';

  @override
  String get onboardingFundTitle => '👤 Personal fund';

  @override
  String get onboardingFundSubtitle =>
      'The share you set aside for yourself each month.';

  @override
  String get onboardingDoneTitle => 'All set!';

  @override
  String get onboardingDoneSubtitle =>
      'The current month will open and plans will be created.';

  @override
  String get onboardingWaiting => 'Loading your lists…';

  @override
  String get onboardingFinish => 'Start';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get fieldDay => 'Day';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldAccount => 'Account';

  @override
  String get monthThis => 'This month';

  @override
  String get monthPrevious => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String get fundPercentMode => 'Percent';

  @override
  String get fundFixedMode => 'Fixed amount';

  @override
  String get fundPercent => 'Percent of income';

  @override
  String get fundSource => 'From which account';

  @override
  String get autoPay => 'Auto-pay';

  @override
  String onboardingSummary(int accounts, int incomes, int plans) {
    return '$accounts accounts, $incomes income types, $plans recurring payments';
  }

  @override
  String get updateRequiredTitle => 'Update the app';

  @override
  String updateRequiredBody(String version) {
    return 'A newer version ($version) is required — update from Play Store.';
  }

  @override
  String get householdSwitch => 'Switch budget';

  @override
  String get householdAdd => 'New budget or invite code';

  @override
  String get offlineBanner =>
      'Offline — changes will sync when you\'re back online';

  @override
  String get menuSettings => 'Settings';

  @override
  String get lockTitle => 'App lock';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockWrongPin => 'Wrong PIN';

  @override
  String get lockBiometrics => 'Biometrics';

  @override
  String get lockNewPin => 'New PIN';

  @override
  String get lockRepeatPin => 'Repeat the PIN';

  @override
  String get lockMismatch => 'The PINs don\'t match';

  @override
  String get lockSetPin => 'Set a PIN';

  @override
  String get lockChangePin => 'Change PIN';

  @override
  String get lockDisable => 'Turn off the lock';

  @override
  String get lockAuto => 'Auto-lock';

  @override
  String lockAutoValue(int minutes) {
    return 'After $minutes min';
  }

  @override
  String get lockSecureScreen => 'Hide in the app switcher';

  @override
  String get lockForgot => 'Forgot your PIN — sign out';

  @override
  String get privacyMode => 'Privacy mode';

  @override
  String get kindExpense => 'Expense';

  @override
  String get kindIncome => 'Income';

  @override
  String get kindTransfer => 'Transfer';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldPayee => 'Payee';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldTo => 'To';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateChoose => 'Date';

  @override
  String get categorySearch => 'Search category';

  @override
  String get saved => 'Saved';

  @override
  String get errorMonthClosed => 'The month is closed — can\'t record';

  @override
  String get categoryNew => 'New category';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldDebt => 'Link to a debt';

  @override
  String get errorCategoryRequired => 'Choose a category';

  @override
  String get errorCategoryInvalid => 'This category can\'t be used';

  @override
  String get errorAccountRequired => 'Choose an account';

  @override
  String get errorTargetAccount => 'Choose a different account';

  @override
  String get errorAmountRequired => 'Enter an amount';

  @override
  String get monthClosedConfirmTitle => 'The month is closed';

  @override
  String get monthClosedConfirmBody =>
      'This goes into a closed month. Record it anyway?';

  @override
  String get actionRecord => 'Record';

  @override
  String monthHintIncome(String month, String relation) {
    return '→ recorded as income for $month ($relation)';
  }

  @override
  String monthHintExpense(String month, String relation) {
    return '→ goes to the $month budget ($relation)';
  }

  @override
  String get monthRelationSame => 'this month';

  @override
  String get monthRelationPrevious => 'previous month';

  @override
  String get monthRelationNext => 'next month';

  @override
  String get monthRelationManual => 'chosen manually';

  @override
  String get monthQuestion => 'Which month\'s budget?';

  @override
  String get monthByDate => 'By date';

  @override
  String get monthChoose => 'Choose';

  @override
  String quickSaved(String name, String amount) {
    return '$name — $amount recorded';
  }

  @override
  String get actionUndo => 'Undo';

  @override
  String get quickHint => 'Tap to record, hold to edit';

  @override
  String get fundAllocationHint =>
      '👤 Counts as an allocation — reduces the month\'s balance';

  @override
  String get fundReturnHint =>
      '👤 Allocation return — increases the month\'s balance';

  @override
  String get fundSpendHint =>
      '👤 Spending from the fund — doesn\'t affect the month\'s balance';

  @override
  String get errorCurrencyMismatch =>
      'The accounts use different currencies — coming later';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Monday',
      '2': 'Tuesday',
      '3': 'Wednesday',
      '4': 'Thursday',
      '5': 'Friday',
      '6': 'Saturday',
      '7': 'Sunday',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String dayTitle(int day, String month, String weekday) {
    return '$month $day, $weekday';
  }

  @override
  String get transactionsEmpty => 'No transactions this month';

  @override
  String get transactionsEmptyFiltered => 'Nothing matches the filter';

  @override
  String get searchHint => 'Payee, note or amount';

  @override
  String get filterAll => 'All';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get monthClosedBanner =>
      'The month is closed — changes need confirmation';

  @override
  String get deleted => 'Deleted';

  @override
  String get editTitle => 'Edit';

  @override
  String get receipt => 'Receipt';

  @override
  String get receiptCamera => 'Camera';

  @override
  String get receiptGallery => 'Gallery';

  @override
  String get receiptTooLarge => 'The image is too large — pick another';

  @override
  String get receiptPending => 'Waiting to upload';

  @override
  String get dashBalance => 'Balance';

  @override
  String get dashForecast => 'Projected balance';

  @override
  String dashMonthEnd(String amount) {
    return 'By month end ≈ $amount';
  }

  @override
  String dashPerDay(String amount) {
    return 'Per day ≈ $amount';
  }

  @override
  String get dashSaved => 'Saved';

  @override
  String get dashCard => 'Card';

  @override
  String get dashCash => 'Cash';

  @override
  String get dashPlan => 'Plan progress';

  @override
  String dashUnknown(int count) {
    return '+ $count unknown';
  }

  @override
  String get dashUpcoming => 'Upcoming payments';

  @override
  String get dashMarkPaid => 'Paid';

  @override
  String get dashCategories => 'Categories';

  @override
  String get dashIncomeTypes => 'Income types';

  @override
  String get dashFund => '👤 Personal fund';

  @override
  String get dashSavings => '🏦 Savings';

  @override
  String get dashThisMonth => 'This month';

  @override
  String get dashAllocated => 'Allocated';

  @override
  String get dashSpent => 'Spent';

  @override
  String get dashDebts => 'Debts';

  @override
  String get dashIOwe => 'I owe';

  @override
  String get dashOwedToMe => 'Owed to me';

  @override
  String get dashMonthly => 'Monthly';

  @override
  String get dashGoals => 'Goals';

  @override
  String get dashForecastTitle => 'Forecast';

  @override
  String dashDays(int elapsed, int total) {
    return '$elapsed / $total days';
  }

  @override
  String get dashDailySpend => 'Daily spend';

  @override
  String get dashMonthEndSpend => 'Month-end spend';

  @override
  String get dashExpectedIncome => 'Expected income';

  @override
  String dashReceivedSoFar(String amount) {
    return 'received so far $amount';
  }

  @override
  String get dashNotOpened =>
      'The month isn\'t open yet — recurring payments aren\'t planned';

  @override
  String get dashOpenMonth => 'Open month';

  @override
  String dashOpenMonthBody(int count) {
    return '$count plans will be created';
  }

  @override
  String get dashClosed => 'Closed';

  @override
  String get dashEmpty => 'Nothing recorded this month yet';

  @override
  String get dashEmptyHint => 'Tap “+” to add the first transaction';

  @override
  String get fieldDate => 'Date';

  @override
  String get payTabExpenses => 'Expenses';

  @override
  String get payTabIncome => 'Expected income';

  @override
  String get payUnpaid => 'Unpaid';

  @override
  String get payIncomePending => 'Still expected';

  @override
  String get paySectionOverdue => '⚠️ Overdue';

  @override
  String get paySectionToday => '📌 Today';

  @override
  String paySectionSoon(int days) {
    return '🗓 Next $days days';
  }

  @override
  String get paySectionLater => 'Later';

  @override
  String get paySectionPaid => '✅ Paid';

  @override
  String get paySectionReceived => '✅ Received';

  @override
  String get paySectionSkipped => '⏭ Skipped';

  @override
  String get payMarkReceived => 'Received';

  @override
  String get paySkip => 'Skip this month';

  @override
  String get payUnskip => 'Restore';

  @override
  String get paySkipped => 'Skipped';

  @override
  String get payEditAmount => 'Amount this month';

  @override
  String get payClose => 'Close';

  @override
  String get payReopen => 'Reopen';

  @override
  String get payAmountVaries => 'Amount varies';

  @override
  String get payAmountRequired =>
      'This payment has no set amount — enter how much you paid';

  @override
  String get payPartialTitle => 'Partial payment';

  @override
  String payPartialBody(String amount) {
    return 'Will you pay the remaining $amount later?';
  }

  @override
  String get payPartialLater => 'Pay later';

  @override
  String get payAutoPay => 'Auto-pay';

  @override
  String get payEmpty => 'No plans this month';

  @override
  String get payEmptyHint =>
      'Open the month to create plans from recurring payments';

  @override
  String get payCalendar => 'Calendar';

  @override
  String get payList => 'List';

  @override
  String get payDayEmpty => 'No payments on this day';

  @override
  String get errorPlanPaid => 'This plan is already paid';

  @override
  String get errorPlanSkipped => 'This plan was skipped';

  @override
  String get errorPlanNotFound => 'Plan not found';

  @override
  String openMonthCreates(int count) {
    return 'To be created: $count';
  }

  @override
  String openMonthExisting(int count) {
    return 'Already exist: $count';
  }

  @override
  String get openMonthNothing => 'Nothing new — all plans already exist';

  @override
  String yearTitle(String year) {
    return '$year';
  }

  @override
  String get yearTotal => 'TOTAL';

  @override
  String get yearView => 'Year view';

  @override
  String get yearEmpty => 'Nothing recorded this year';

  @override
  String get categoryTrend => 'Month by month';

  @override
  String get categoryTransactions => 'Show transactions';

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get shareReport => 'Share report';

  @override
  String get shareAction => 'Share';

  @override
  String get shareFailed => 'Couldn\'t share';

  @override
  String get shareTopExpenses => 'Top expenses';
}
