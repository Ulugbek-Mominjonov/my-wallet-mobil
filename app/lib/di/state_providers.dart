import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Ekranlar uchun ma'lumot oqimlari.
///
/// ★ §5.4 qoidasi shu yerda amalda:
/// * `months/{joriyOy}` va `meta/totals` ga DOIMIY listener (dashboard);
/// * ro'yxatlarga listener faqat ekran ochiq bo'lganda
///   (`isAutoDispose: true`) — ekran yopilishi bilan ulanish uziladi.

/// Tanlangan oy — butun ilova shunga qarab ishlaydi.
final class SelectedMonth extends Notifier<MonthKey> {
  @override
  MonthKey build() => MonthKey.of(ref.read(clockProvider).now());

  // ignore: use_setters_to_change_properties
  void select(MonthKey month) => state = month;

  void next() => state = state.next;

  void previous() => state = state.previous;

  void today() => state = MonthKey.of(ref.read(clockProvider).now());
}

final selectedMonthProvider = NotifierProvider<SelectedMonth, MonthKey>(
  SelectedMonth.new,
);

/// Joriy (haqiqiy) oy — "bugun" tugmasi va prognoz uchun.
final currentMonthProvider = Provider<MonthKey>(
  (ref) => MonthKey.of(ref.watch(clockProvider).now()),
);

// ─────────────────── Dashboard: 2 ta hujjat ───────────────────

final monthSummaryProvider = StreamProvider<MonthSummary>(
  (ref) => ref
      .watch(monthRepositoryProvider)
      .watch(ref.watch(selectedMonthProvider)),
);

final totalsProvider = StreamProvider<OverallTotals>(
  (ref) => ref.watch(totalsRepositoryProvider).watch(),
);

/// Barcha oylar — jamg'arma ekrani va prognozdagi o'rtachalar uchun.
final monthsProvider = StreamProvider<List<MonthSummary>>(
  (ref) => ref.watch(monthRepositoryProvider).watchAll(),
);

final savingsSeriesProvider = Provider<SavingsSeries>(
  (ref) => SavingsCalc.build(ref.watch(monthsProvider).value ?? const []),
);

final forecastProvider = Provider<MonthForecast>((ref) {
  final months = ref.watch(monthsProvider).value ?? const <MonthSummary>[];
  return ForecastCalc.compute(
    month: ref.watch(monthSummaryProvider).value ??
        MonthSummary.empty(ref.watch(selectedMonthProvider)),
    totals: ref.watch(totalsProvider).value ?? const OverallTotals(),
    monthCount: months.length,
    today: ref.watch(clockProvider).now(),
  );
});

final personalFundProvider = Provider<PersonalFundView>(
  (ref) => PersonalFundCalc.fromTotals(
    ref.watch(totalsProvider).value ?? const OverallTotals(),
  ),
);

// ─────────────────── Ro'yxatlar (autoDispose) ───────────────────

final monthExpensesProvider = StreamProvider<List<Expense>>(
  (ref) => ref
      .watch(expenseRepositoryProvider)
      .watchMonth(ref.watch(selectedMonthProvider)),
  isAutoDispose: true,
);

final monthIncomesProvider = StreamProvider<List<Income>>(
  (ref) => ref
      .watch(incomeRepositoryProvider)
      .watchMonth(ref.watch(selectedMonthProvider)),
  isAutoDispose: true,
);

final monthPersonalSpendsProvider = StreamProvider<List<PersonalSpend>>(
  (ref) => ref
      .watch(personalSpendRepositoryProvider)
      .watchMonth(ref.watch(selectedMonthProvider)),
  isAutoDispose: true,
);

/// To'lanmaganlar — `status` indeksidan, butun jadval skanlanmaydi.
final unpaidExpensesProvider = StreamProvider<List<Expense>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchUnpaid(),
  isAutoDispose: true,
);

final debtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(debtRepositoryProvider).watchAll(),
  isAutoDispose: true,
);

final goalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchAll(),
  isAutoDispose: true,
);

final recurringProvider = StreamProvider<List<RecurringExpense>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchRecurring(),
  isAutoDispose: true,
);

final limitsProvider = StreamProvider<List<CategoryLimit>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchLimits(),
);

final quickAddsProvider = StreamProvider<List<QuickAdd>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchQuickAdds(),
);

final categoriesProvider = StreamProvider<List<CategoryDef>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchCategories(),
);

final healthProvider = StreamProvider<HealthReport>(
  (ref) => ref.watch(healthRepositoryProvider).watch(),
  isAutoDispose: true,
);

// ─────────────────── Hisoblangan ko'rinishlar ───────────────────

final limitStatusesProvider = Provider<List<LimitStatus>>((ref) {
  final month = ref.watch(monthSummaryProvider).value;
  if (month == null) return const <LimitStatus>[];
  return LimitCalc.forMonth(month, ref.watch(limitsProvider).value ?? const []);
});

final debtViewsProvider = Provider<List<DebtView>>(
  (ref) => DebtCalc.views(
    ref.watch(debtsProvider).value ?? const <Debt>[],
    today: ref.watch(clockProvider).now(),
  ),
);

final debtTotalsProvider = Provider<DebtTotals>(
  (ref) => DebtCalc.totals(ref.watch(debtViewsProvider)),
);

final goalViewsProvider = Provider<List<GoalView>>(
  (ref) => GoalCalc.views(
    ref.watch(goalsProvider).value ?? const <Goal>[],
    averageSaved: ref.watch(savingsSeriesProvider).averageSaved,
    today: ref.watch(clockProvider).now(),
  ),
);

/// Eslatma guruhlari — to'lovlar ekranidagi ⚠️ / 📌 / 🗓 bo'limlari.
final reminderBucketsProvider = Provider<ReminderBuckets>((ref) {
  final expenses = ref.watch(unpaidExpensesProvider).value;
  if (expenses == null) return ReminderBuckets.empty;
  return ReminderCalc.split(
    expenses,
    today: ref.watch(clockProvider).now(),
    daysAhead: ref.watch(settingsProvider).reminders.daysAhead,
  );
});

/// "O'zim uchun" rejasi — joriy oy daromadiga qarab.
final personalPlanProvider = Provider<Money>(
  (ref) => PersonalFundCalc.plannedAmount(
    monthIncome:
        ref.watch(monthSummaryProvider).value?.income ?? Money.zero,
    settings: ref.watch(settingsProvider).personalFund,
  ),
);
