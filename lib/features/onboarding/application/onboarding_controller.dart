import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Sozlash ustasi qadamlari (BR-010; har birini o'tkazib yuborish mumkin).
enum OnboardingStep { accounts, income, recurring, fund, done }

/// Hisob va uning joriy qoldig'i (server nom bo'yicha topadi).
@immutable
final class AccountDraft {
  const new({
    required this.name,
    required this.type,
    this.balance = Money.zero,
  });

  final String name;
  final AccountType type;
  final Money balance;

  AccountDraft copyWith({Money? balance}) =>
      AccountDraft(name: name, type: type, balance: balance ?? this.balance);

  Json toJson() => {
    'name': name,
    'type': type.wire,
    'opening_balance': balance.minor,
  };
}

/// Maosh jadvali qatori: daromad turi (kategoriya) + kutilayotgan sana/summa.
@immutable
final class IncomeDraft {
  const new({
    required this.name,
    required this.monthShift,
    this.enabled = false,
    this.day,
    this.amount,
    this.account,
  });

  final String name;

  /// BR-031: `0` — shu oy, `-1` — oldingi oy daromadi.
  final int monthShift;
  final bool enabled;
  final int? day;
  final Money? amount;
  final String? account;

  IncomeDraft copyWith({
    bool? enabled,
    int? monthShift,
    int? day,
    Money? amount,
    String? account,
  }) => IncomeDraft(
    name: name,
    monthShift: monthShift ?? this.monthShift,
    enabled: enabled ?? this.enabled,
    day: day ?? this.day,
    amount: amount ?? this.amount,
    account: account ?? this.account,
  );

  Json toJson() => {
    'name': name,
    'month_shift': monthShift,
    'expected_day': day,
    'expected_amount': amount?.minor,
    'account': account,
  };
}

/// Doimiy to'lov (BR-080): kategoriya nomi bilan bir xil nom.
@immutable
final class RecurringDraft {
  const new({
    required this.name,
    this.enabled = false,
    this.amount,
    this.day = 5,
    this.account,
    this.autoPay = false,
  });

  final String name;
  final bool enabled;
  final Money? amount;
  final int day;
  final String? account;
  final bool autoPay;

  RecurringDraft copyWith({
    bool? enabled,
    Money? amount,
    int? day,
    String? account,
    bool? autoPay,
  }) => RecurringDraft(
    name: name,
    enabled: enabled ?? this.enabled,
    amount: amount ?? this.amount,
    day: day ?? this.day,
    account: account ?? this.account,
    autoPay: autoPay ?? this.autoPay,
  );

  Json toJson() => {
    'kind': 'expense',
    'name': name,
    'category': name,
    'account': account,
    'amount': amount?.minor,
    'day_of_month': day,
    'auto_pay': autoPay,
  };
}

/// 👤 Fond qoidasi (BR-060).
@immutable
final class FundDraft {
  const new({
    this.percentMode = true,
    this.percent = 10,
    this.fixedAmount = Money.zero,
    this.day = 5,
    this.account,
  });

  final bool percentMode;
  final int percent;
  final Money fixedAmount;
  final int day;
  final String? account;

  FundDraft copyWith({
    bool? percentMode,
    int? percent,
    Money? fixedAmount,
    int? day,
    String? account,
  }) => FundDraft(
    percentMode: percentMode ?? this.percentMode,
    percent: percent ?? this.percent,
    fixedAmount: fixedAmount ?? this.fixedAmount,
    day: day ?? this.day,
    account: account ?? this.account,
  );

  Json toJson() => {
    'mode': percentMode ? 'percent' : 'fixed',
    'percent': percent,
    'fixed_amount': fixedAmount.minor,
    'day': day,
    'source_account': account,
  };
}

@immutable
final class OnboardingState {
  const new({
    this.step = OnboardingStep.accounts,
    this.accounts = const [],
    this.incomes = const [],
    this.recurring = const [],
    this.fund = const FundDraft(),
    this.loaded = false,
    this.busy = false,
    this.failure,
  });

  final OnboardingStep step;
  final List<AccountDraft> accounts;
  final List<IncomeDraft> incomes;
  final List<RecurringDraft> recurring;
  final FundDraft fund;

  /// Spravochniklar sinxrondan kelganmi.
  final bool loaded;
  final bool busy;
  final Failure? failure;

  OnboardingState copyWith({
    OnboardingStep? step,
    List<AccountDraft>? accounts,
    List<IncomeDraft>? incomes,
    List<RecurringDraft>? recurring,
    FundDraft? fund,
    bool? loaded,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) => OnboardingState(
    step: step ?? this.step,
    accounts: accounts ?? this.accounts,
    incomes: incomes ?? this.incomes,
    recurring: recurring ?? this.recurring,
    fund: fund ?? this.fund,
    loaded: loaded ?? this.loaded,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  /// `onboarding_apply` yuki (contracts/api.md): faqat belgilangan qatorlar.
  Json toPayload() => {
    'accounts': [
      for (final account in accounts)
        if (account.balance.minor != 0) account.toJson(),
    ],
    'income_types': [
      for (final income in incomes)
        if (income.enabled) income.toJson(),
    ],
    'recurring': [
      for (final item in recurring)
        if (item.enabled && item.amount != null) item.toJson(),
    ],
    'fund': fund.toJson(),
  };
}

final NotifierProvider<OnboardingController, OnboardingState>
onboardingProvider = NotifierProvider(OnboardingController.new);

/// Sozlash ustasi: spravochniklar lokal bazadan (sinxrondan keladi),
/// natija — bitta `onboarding_apply` + joriy oyni ochish (BR-081).
base class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final householdId = ref.watch(currentHouseholdIdProvider);
    if (householdId != null) _watchDirectories(householdId);
    return const OnboardingState();
  }

  /// Spravochniklar sinxron bilan keladi — oqimga obuna bo'lamiz.
  void _watchDirectories(String householdId) {
    final dao = ref.read(appDatabaseProvider).directoryDao;
    final subscriptions = [
      dao.watchAccounts(householdId).listen(_onAccounts),
      dao
          .watchCategories(householdId, kind: CategoryKind.income)
          .listen(_onIncomeCategories),
      dao
          .watchCategories(householdId, kind: CategoryKind.expense)
          .listen(_onExpenseCategories),
    ];
    ref.onDispose(() {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    });
  }

  void _onAccounts(List<Account> accounts) {
    if (accounts.isEmpty) return;
    final drafts = [
      for (final account in accounts)
        if (account.type != AccountType.personalFund)
          AccountDraft(name: account.name, type: account.type),
    ];
    final fundSource =
        state.fund.account ??
        drafts
            .firstWhere(
              (a) => a.type == AccountType.cash,
              orElse: () => drafts.first,
            )
            .name;
    state = state.copyWith(
      accounts: _merge(state.accounts, drafts, (a) => a.name),
      fund: state.fund.copyWith(account: fundSource),
      loaded: true,
    );
  }

  void _onIncomeCategories(List<Category> categories) {
    state = state.copyWith(
      incomes: _merge(state.incomes, [
        for (final category in categories)
          IncomeDraft(name: category.name, monthShift: category.monthShift),
      ], (i) => i.name),
    );
  }

  void _onExpenseCategories(List<Category> categories) {
    state = state.copyWith(
      recurring: _merge(state.recurring, [
        for (final category in categories)
          if (category.systemCode == null) RecurringDraft(name: category.name),
      ], (r) => r.name),
    );
  }

  /// Foydalanuvchi kiritganini saqlab, yangi qatorlarni qo'shadi.
  List<T> _merge<T>(List<T> current, List<T> fresh, String Function(T) key) {
    final byKey = {for (final item in current) key(item): item};
    return [for (final item in fresh) byKey[key(item)] ?? item];
  }

  void setAccountBalance(String name, Money balance) => state = state.copyWith(
    accounts: [
      for (final account in state.accounts)
        if (account.name == name)
          account.copyWith(balance: balance)
        else
          account,
    ],
  );

  void updateIncome(String name, IncomeDraft Function(IncomeDraft) change) =>
      state = state.copyWith(
        incomes: [
          for (final income in state.incomes)
            if (income.name == name) change(income) else income,
        ],
      );

  void updateRecurring(
    String name,
    RecurringDraft Function(RecurringDraft) change,
  ) => state = state.copyWith(
    recurring: [
      for (final item in state.recurring)
        if (item.name == name) change(item) else item,
    ],
  );

  void updateFund(FundDraft Function(FundDraft) change) =>
      state = state.copyWith(fund: change(state.fund));

  void goTo(OnboardingStep step) =>
      state = state.copyWith(step: step, clearFailure: true);

  void next() {
    final index = state.step.index;
    if (index + 1 < OnboardingStep.values.length) {
      goTo(OnboardingStep.values[index + 1]);
    }
  }

  void back() {
    final index = state.step.index;
    if (index > 0) goTo(OnboardingStep.values[index - 1]);
  }

  /// `onboarding_apply` + joriy oyni ochish; so'ng byudjet holati yangilanadi.
  Future<Result<void>> apply() async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return const Err(UnauthorizedFailure());
    if (state.busy) return const Ok(null);
    state = state.copyWith(busy: true, clearFailure: true);

    final api = ref.read(remoteApiProvider);
    final result = await api.onboardingApply(householdId, state.toPayload());
    if (result case Err(:final failure)) {
      state = state.copyWith(busy: false, failure: failure);
      return Err(failure);
    }

    // Joriy oyni ochish (BR-081) — xato bo'lsa keyin "To'lovlar"da ochiladi.
    final month = MonthKey.ofDate(ref.read(clockProvider).today());
    final opened = await api.openMonth(householdId, month);
    if (opened case Err(:final failure)) {
      AppLog.info('Joriy oy ochilmadi (keyinroq): $failure');
    }

    await ref.read(startupProvider.notifier).reload();
    final scheduler = await ref.read(syncSchedulerProvider.future);
    await scheduler?.refresh();
    state = state.copyWith(busy: false);
    return const Ok(null);
  }
}
