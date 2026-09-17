import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

/// ★ Rejadagi ENG MUHIM test (§10):
///
/// > "delta bilan hisoblangan agregat == noldan hisoblangan agregat"
///
/// Tasodifiy qo'shish / tahrirlash / o'chirish ketma-ketligi bajariladi va
/// HAR BIR QADAMDAN KEYIN delta yo'li bilan yig'ilgan agregat xom
/// yozuvlardan qayta qurilgan agregat bilan solishtiriladi. Bu §5.2 ning
/// to'g'riligini kafolatlaydi — ya'ni Firestore'da `increment` bilan
/// yig'ilgan qiymat hech qachon haqiqatdan uzoqlashmaydi.
/// "O'zim uchun" kategoriyasining normallashtirilgan kaliti.
const String personal = "o'zim uchun";

void main() {
  const seeds = 25;
  const operationsPerSeed = 40;

  test(
    'delta agregati == noldan hisoblangan agregat '
    '(${seeds * operationsPerSeed} ta tasodifiy amal)',
    () {
      var totalOperations = 0;
      for (var seed = 1; seed <= seeds; seed++) {
        final world = _World(seed);
        for (var step = 0; step < operationsPerSeed; step++) {
          world
            ..randomOperation()
            ..verify(seed: seed, step: step);
          totalOperations++;
        }
      }
      expect(totalOperations, seeds * operationsPerSeed);
    },
  );
}

/// Tasodifiy dunyo: xom yozuvlar + delta bilan yig'ilgan agregat.
final class _World {
  _World(int seed) : fuzz = Fuzz(seed);

  final Fuzz fuzz;
  final Map<String, Income> incomes = <String, Income>{};
  final Map<String, Expense> expenses = <String, Expense>{};
  final Map<String, PersonalSpend> spends = <String, PersonalSpend>{};

  /// Delta bilan yig'ilgan holat (Firestore'dagi hujjatlar modeli).
  final Map<MonthKey, MonthSummary> summaries = <MonthKey, MonthSummary>{};
  OverallTotals totals = const OverallTotals();
  final Map<String, Debt> debts = <String, Debt>{
    'd1': Build.debt(),
    'd2': Build.debt(id: 'd2', direction: DebtDirection.owedToMe),
  };

  int _ids = 0;

  String get _nextId => 'x${++_ids}';

  void randomOperation() {
    final roll = fuzz.next(100);
    if (roll < 34) {
      _expenseOperation();
    } else if (roll < 67) {
      _incomeOperation();
    } else {
      _personalOperation();
    }
  }

  void _expenseOperation() {
    if (expenses.isNotEmpty && fuzz.chance(0.45)) {
      final key = expenses.keys.elementAt(fuzz.next(expenses.length));
      final before = expenses[key]!;
      if (fuzz.chance(0.3)) {
        expenses.remove(key);
        _apply(
          AggregateDelta.forExpense(
            personalCategoryKey: personal,
            before: before,
          ),
        );
        return;
      }
      final after = _mutate(before);
      expenses[key] = after;
      _apply(
        AggregateDelta.forExpense(
          personalCategoryKey: personal,
          before: before,
          after: after,
        ),
      );
      return;
    }
    final expense = _randomExpense(_nextId);
    expenses[expense.id] = expense;
    _apply(
      AggregateDelta.forExpense(
        personalCategoryKey: personal,
        after: expense,
      ),
    );
  }

  void _incomeOperation() {
    if (incomes.isNotEmpty && fuzz.chance(0.4)) {
      final key = incomes.keys.elementAt(fuzz.next(incomes.length));
      final before = incomes[key]!;
      if (fuzz.chance(0.3)) {
        incomes.remove(key);
        _apply(AggregateDelta.forIncome(before: before));
        return;
      }
      final month = fuzz.month();
      final after = before.copyWith(
        amount: fuzz.amount(),
        method: fuzz.pick(PaymentMethod.values),
        type: fuzz.pick(Fuzz.types),
        monthKey: month,
        paidAt: fuzz.dayIn(month),
        debtId: fuzz.chance(0.3) ? 'd2' : null,
      );
      incomes[key] = after;
      _apply(AggregateDelta.forIncome(before: before, after: after));
      return;
    }
    final income = _randomIncome(_nextId);
    incomes[income.id] = income;
    _apply(AggregateDelta.forIncome(after: income));
  }

  void _personalOperation() {
    if (spends.isNotEmpty && fuzz.chance(0.4)) {
      final key = spends.keys.elementAt(fuzz.next(spends.length));
      final before = spends[key]!;
      if (fuzz.chance(0.35)) {
        spends.remove(key);
        _apply(AggregateDelta.forPersonalSpend(before: before));
        return;
      }
      final month = fuzz.month();
      final date = fuzz.dayIn(month);
      final after = before.copyWith(
        amount: fuzz.amount(max: 8),
        spentAt: date,
        monthKey: month,
      );
      spends[key] = after;
      _apply(AggregateDelta.forPersonalSpend(before: before, after: after));
      return;
    }
    final spend = _randomSpend(_nextId);
    spends[spend.id] = spend;
    _apply(AggregateDelta.forPersonalSpend(after: spend));
  }

  Expense _mutate(Expense before) {
    final month = fuzz.chance(0.3) ? fuzz.month() : before.monthKey;
    return before.copyWith(
      planned: fuzz.chance(0.2) ? null : fuzz.amount(),
      actual: fuzz.chance(0.45) ? fuzz.amount() : null,
      category: fuzz.pick(Fuzz.categories),
      method: fuzz.pick(PaymentMethod.values),
      monthKey: month,
      dueDate: fuzz.dayIn(month),
      debtId: fuzz.chance(0.3) ? 'd1' : null,
    );
  }

  Expense _randomExpense(String id) {
    final month = fuzz.month();
    return Expense(
      id: id,
      name: 'X$id',
      category: fuzz.pick(Fuzz.categories),
      method: fuzz.pick(PaymentMethod.values),
      planned: fuzz.chance(0.15) ? null : fuzz.amount(),
      actual: fuzz.chance(0.5) ? fuzz.amount() : null,
      dueDate: fuzz.dayIn(month),
      monthKey: month,
      debtId: fuzz.chance(0.25) ? 'd1' : null,
    );
  }

  Income _randomIncome(String id) {
    final month = fuzz.month();
    return Income(
      id: id,
      amount: fuzz.amount(max: 40),
      type: fuzz.pick(Fuzz.types),
      method: fuzz.pick(PaymentMethod.values),
      paidAt: fuzz.dayIn(month),
      monthKey: month,
      debtId: fuzz.chance(0.2) ? 'd2' : null,
    );
  }

  PersonalSpend _randomSpend(String id) {
    final month = fuzz.month();
    return PersonalSpend(
      id: id,
      amount: fuzz.amount(max: 6),
      purpose: 'P$id',
      method: fuzz.pick(PaymentMethod.values),
      spentAt: fuzz.dayIn(month),
      monthKey: month,
    );
  }

  /// Deltani "Firestore hujjatlariga" qo'llaydi.
  void _apply(AggregateDelta delta) {
    for (final entry in delta.months.entries) {
      final current = summaries[entry.key] ?? MonthSummary.empty(entry.key);
      summaries[entry.key] = entry.value.applyTo(current);
    }
    totals = delta.totals.applyTo(totals);
    for (final entry in delta.debts.entries) {
      final debt = debts[entry.key];
      if (debt != null) debts[entry.key] = entry.value.applyTo(debt);
    }
  }

  void verify({required int seed, required int step}) {
    final reason = 'seed=$seed step=$step';
    final expected = MonthSummaryCalc.buildAll(
      personalCategoryKey: personal,
      incomes: incomes.values,
      expenses: expenses.values,
      personalSpends: spends.values,
    );

    for (final month in <MonthKey>{...summaries.keys, ...expected.keys}) {
      final actual = summaries[month] ?? MonthSummary.empty(month);
      final target = expected[month] ?? MonthSummary.empty(month);
      expect(actual, target, reason: '$reason oy=$month');
      // Hosila qiymatlar ham mos kelishi shart.
      expect(actual.balance, target.balance, reason: '$reason qoldiq');
      expect(actual.saved, target.saved, reason: '$reason orttirgan');
      expect(actual.forecast, target.forecast, reason: '$reason prognoz');
    }

    expect(
      totals,
      MonthSummaryCalc.totals(expected.values),
      reason: '$reason umumiy',
    );

    // Qarz hisoblagichlari ham delta bilan yuritiladi.
    for (final debt in debts.values) {
      expect(
        debt.paidFromExpenses,
        Money.sum(<Money>[
          for (final expense in expenses.values)
            if (expense.debtId == debt.id && expense.isPaid)
              expense.actualOrZero,
        ]),
        reason: '$reason qarz=${debt.id} xarajatdan',
      );
      expect(
        debt.paidFromIncomes,
        Money.sum(<Money>[
          for (final income in incomes.values)
            if (income.debtId == debt.id) income.amount,
        ]),
        reason: '$reason qarz=${debt.id} daromaddan',
      );
      expect(
        debt.pendingFromApp,
        Money.sum(<Money>[
          for (final expense in expenses.values)
            if (expense.debtId == debt.id && !expense.isPaid)
              expense.plannedOrZero,
        ]),
        reason: '$reason qarz=${debt.id} kutilmoqda',
      );
    }
  }
}
