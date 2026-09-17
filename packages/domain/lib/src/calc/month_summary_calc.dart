import '../entities/expense.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../entities/personal_spend.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Agregatni XOM YOZUVLARDAN noldan hisoblaydi.
///
/// Bu — Sheets'dagi `hammaXulosalar_()` ning aynan davomi va ikki joyda
/// ishlatiladi:
///
/// 1. **Reconciler** (§5.5) — kechasi agregatni qayta hisoblab, delta bilan
///    yig'ilgan qiymat bilan solishtiradi;
/// 2. **Property-based test** — "delta agregati == noldan hisoblangan
///    agregat" kafolati.
///
/// Delta hisobidan MUSTAQIL yozilgan: ikkalasi bir xil natija berishi
/// haqiqiy tekshiruv bo'lishi uchun.
abstract final class MonthSummaryCalc {
  /// Bitta oyning agregati.
  static MonthSummary build({
    required MonthKey monthKey,
    required String personalCategoryKey,
    Iterable<Income> incomes = const <Income>[],
    Iterable<Expense> expenses = const <Expense>[],
    Iterable<PersonalSpend> personalSpends = const <PersonalSpend>[],
    bool closed = false,
  }) {
    var income = Money.zero;
    var incomeCard = Money.zero;
    var incomeCash = Money.zero;
    var expense = Money.zero;
    var expenseCard = Money.zero;
    var expenseCash = Money.zero;
    var planned = Money.zero;
    var unpaidTotal = Money.zero;
    var unknownCount = 0;
    var personalAllocated = Money.zero;
    var personalSpent = Money.zero;
    final byType = <String, MethodSplit>{};
    final byCategory = <String, CategorySplit>{};

    for (final item in incomes) {
      if (item.monthKey != monthKey) continue;
      income += item.amount;
      final isCard = item.method == PaymentMethod.card;
      if (isCard) {
        incomeCard += item.amount;
      } else {
        incomeCash += item.amount;
      }
      final current = byType[item.type] ?? const MethodSplit();
      byType[item.type] = current +
          MethodSplit(
            card: isCard ? item.amount : Money.zero,
            cash: isCard ? Money.zero : item.amount,
          );
    }

    for (final item in expenses) {
      if (item.monthKey != monthKey) continue;
      final actual = item.actualOrZero;
      final plan = item.plannedOrZero;
      planned += plan;

      if (item.isPaid) {
        expense += actual;
        if (item.method == PaymentMethod.card) {
          expenseCard += actual;
        } else {
          expenseCash += actual;
        }
        if (item.categoryKey == personalCategoryKey) {
          personalAllocated += actual;
        }
      } else {
        unpaidTotal += plan;
        if (item.isUnknownAmount) unknownCount++;
      }

      final current = byCategory[item.category] ?? const CategorySplit();
      byCategory[item.category] =
          current + CategorySplit(planned: plan, actual: actual);
    }

    for (final item in personalSpends) {
      if (item.monthKey != monthKey) continue;
      personalSpent += item.amount;
    }

    return MonthSummary(
      monthKey: monthKey,
      income: income,
      incomeCard: incomeCard,
      incomeCash: incomeCash,
      expense: expense,
      expenseCard: expenseCard,
      expenseCash: expenseCash,
      planned: planned,
      unpaidTotal: unpaidTotal,
      unknownCount: unknownCount,
      personalAllocated: personalAllocated,
      personalSpent: personalSpent,
      byType: _prune(byType, (value) => value.isZero),
      byCategory: _prune(byCategory, (value) => value.isZero),
      closed: closed,
    );
  }

  /// Barcha oylarning agregati — import va reconciler uchun.
  static Map<MonthKey, MonthSummary> buildAll({
    required String personalCategoryKey,
    Iterable<Income> incomes = const <Income>[],
    Iterable<Expense> expenses = const <Expense>[],
    Iterable<PersonalSpend> personalSpends = const <PersonalSpend>[],
    Set<MonthKey> closedMonths = const <MonthKey>{},
  }) {
    final months = <MonthKey>{
      ...incomes.map((item) => item.monthKey),
      ...expenses.map((item) => item.monthKey),
      ...personalSpends.map((item) => item.monthKey),
    };
    final sorted = months.toList()..sort();
    return <MonthKey, MonthSummary>{
      for (final month in sorted)
        month: build(
          monthKey: month,
          personalCategoryKey: personalCategoryKey,
          incomes: incomes,
          expenses: expenses,
          personalSpends: personalSpends,
          closed: closedMonths.contains(month),
        ),
    };
  }

  /// `meta/totals` ni oylar agregatidan yig'adi.
  static OverallTotals totals(Iterable<MonthSummary> months) {
    var income = Money.zero;
    var expense = Money.zero;
    var personalAllocated = Money.zero;
    var personalSpent = Money.zero;
    for (final month in months) {
      income += month.income;
      expense += month.expense;
      personalAllocated += month.personalAllocated;
      personalSpent += month.personalSpent;
    }
    return OverallTotals(
      income: income,
      expense: expense,
      personalAllocated: personalAllocated,
      personalSpent: personalSpent,
    );
  }

  static Map<String, V> _prune<V>(
    Map<String, V> source,
    bool Function(V) isZero,
  ) =>
      <String, V>{
        for (final entry in source.entries)
          if (!isZero(entry.value)) entry.key: entry.value,
      };
}
