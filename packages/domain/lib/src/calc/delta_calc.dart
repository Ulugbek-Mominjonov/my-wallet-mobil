import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../entities/debt.dart';
import '../entities/expense.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../entities/personal_spend.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// ★ §5.2 — yozuv paytida agregatni delta bilan yangilash.
///
/// Firestore'da har hujjat = 1 ta o'qish. 3 yillik ma'lumotni har safar
/// qayta hisoblash (Sheets'dagidek) qimmat va sekin. Shuning uchun agregat
/// hujjatlar YOZUV paytida `increment` bilan yangilanadi:
///
/// * o'qish kerak emas (0 read),
/// * atomar va kommutativ — offline konflikt bo'lmaydi,
/// * mantiq sof Dart'da — 100% test bilan qoplanadi.
///
/// Asosiy g'oya: har bir yozuvning agregatga "hissasi" (contribution)
/// hisoblanadi, delta esa `hissa(after) − hissa(before)`. Shu sababli
/// qo'shish / tahrirlash / o'chirish uchun alohida mantiq yozilmaydi.

/// Bitta oy hujjatiga qo'shiladigan o'zgarish.
@immutable
final class MonthDelta {
  const MonthDelta({
    this.income = Money.zero,
    this.incomeCard = Money.zero,
    this.incomeCash = Money.zero,
    this.expense = Money.zero,
    this.expenseCard = Money.zero,
    this.expenseCash = Money.zero,
    this.planned = Money.zero,
    this.unpaidTotal = Money.zero,
    this.unknownCount = 0,
    this.personalAllocated = Money.zero,
    this.personalSpent = Money.zero,
    this.byType = const <String, MethodSplit>{},
    this.byCategory = const <String, CategorySplit>{},
  });

  static const MonthDelta zero = MonthDelta();

  final Money income;
  final Money incomeCard;
  final Money incomeCash;
  final Money expense;
  final Money expenseCard;
  final Money expenseCash;
  final Money planned;
  final Money unpaidTotal;
  final int unknownCount;
  final Money personalAllocated;
  final Money personalSpent;
  final Map<String, MethodSplit> byType;
  final Map<String, CategorySplit> byCategory;

  bool get isEmpty =>
      income.isZero &&
      incomeCard.isZero &&
      incomeCash.isZero &&
      expense.isZero &&
      expenseCard.isZero &&
      expenseCash.isZero &&
      planned.isZero &&
      unpaidTotal.isZero &&
      unknownCount == 0 &&
      personalAllocated.isZero &&
      personalSpent.isZero &&
      byType.isEmpty &&
      byCategory.isEmpty;

  bool get isNotEmpty => !isEmpty;

  MonthDelta operator +(MonthDelta other) => MonthDelta(
        income: income + other.income,
        incomeCard: incomeCard + other.incomeCard,
        incomeCash: incomeCash + other.incomeCash,
        expense: expense + other.expense,
        expenseCard: expenseCard + other.expenseCard,
        expenseCash: expenseCash + other.expenseCash,
        planned: planned + other.planned,
        unpaidTotal: unpaidTotal + other.unpaidTotal,
        unknownCount: unknownCount + other.unknownCount,
        personalAllocated: personalAllocated + other.personalAllocated,
        personalSpent: personalSpent + other.personalSpent,
        byType: mergeSplitMaps(byType, other.byType),
        byCategory: mergeCategoryMaps(byCategory, other.byCategory),
      );

  /// Teskarisi — "avvalgi holatni ayirish" uchun.
  MonthDelta get negated => MonthDelta(
        income: income.negated,
        incomeCard: incomeCard.negated,
        incomeCash: incomeCash.negated,
        expense: expense.negated,
        expenseCard: expenseCard.negated,
        expenseCash: expenseCash.negated,
        planned: planned.negated,
        unpaidTotal: unpaidTotal.negated,
        unknownCount: -unknownCount,
        personalAllocated: personalAllocated.negated,
        personalSpent: personalSpent.negated,
        byType: <String, MethodSplit>{
          for (final entry in byType.entries)
            entry.key: MethodSplit(
              card: entry.value.card.negated,
              cash: entry.value.cash.negated,
            ),
        },
        byCategory: <String, CategorySplit>{
          for (final entry in byCategory.entries)
            entry.key: CategorySplit(
              planned: entry.value.planned.negated,
              actual: entry.value.actual.negated,
            ),
        },
      );

  /// Firestore'ga yoziladigan ko'rinish: barg qiymatlar butun son.
  ///
  /// Data qatlami har bir bargni `FieldValue.increment()` ga o'raydi.
  /// Nuqtali "field path" ATAYLAB ishlatilmaydi — kategoriya nomida nuqta
  /// bo'lsa yo'l buzilardi; ichma-ich map + `merge: true` xavfsiz.
  Map<String, Object> toIncrements() {
    final result = <String, Object>{};
    void put(String key, Money value) {
      if (!value.isZero) result[key] = value.soum;
    }

    put('income', income);
    put('incomeCard', incomeCard);
    put('incomeCash', incomeCash);
    put('expense', expense);
    put('expenseCard', expenseCard);
    put('expenseCash', expenseCash);
    put('planned', planned);
    put('unpaidTotal', unpaidTotal);
    if (unknownCount != 0) result['unknownCount'] = unknownCount;
    put('personalAllocated', personalAllocated);
    put('personalSpent', personalSpent);

    final types = <String, Object>{
      for (final entry in byType.entries)
        if (!entry.value.isZero)
          entry.key: <String, Object>{
            if (!entry.value.card.isZero) 'card': entry.value.card.soum,
            if (!entry.value.cash.isZero) 'cash': entry.value.cash.soum,
          },
    };
    if (types.isNotEmpty) result['byType'] = types;

    final categories = <String, Object>{
      for (final entry in byCategory.entries)
        if (!entry.value.isZero)
          entry.key: <String, Object>{
            if (!entry.value.planned.isZero)
              'planned': entry.value.planned.soum,
            if (!entry.value.actual.isZero) 'actual': entry.value.actual.soum,
          },
    };
    if (categories.isNotEmpty) result['byCategory'] = categories;

    return result;
  }

  /// Deltani mavjud agregatga qo'llaydi.
  ///
  /// Ikki joyda kerak: (1) offline optimistik yangilash, (2) testlarda
  /// "delta agregati == noldan hisoblangan agregat" tekshiruvi.
  MonthSummary applyTo(MonthSummary summary) => summary.copyWith(
        income: summary.income + income,
        incomeCard: summary.incomeCard + incomeCard,
        incomeCash: summary.incomeCash + incomeCash,
        expense: summary.expense + expense,
        expenseCard: summary.expenseCard + expenseCard,
        expenseCash: summary.expenseCash + expenseCash,
        planned: summary.planned + planned,
        unpaidTotal: summary.unpaidTotal + unpaidTotal,
        unknownCount: summary.unknownCount + unknownCount,
        personalAllocated: summary.personalAllocated + personalAllocated,
        personalSpent: summary.personalSpent + personalSpent,
        byType: mergeSplitMaps(summary.byType, byType),
        byCategory: mergeCategoryMaps(summary.byCategory, byCategory),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthDelta &&
          other.income == income &&
          other.incomeCard == incomeCard &&
          other.incomeCash == incomeCash &&
          other.expense == expense &&
          other.expenseCard == expenseCard &&
          other.expenseCash == expenseCash &&
          other.planned == planned &&
          other.unpaidTotal == unpaidTotal &&
          other.unknownCount == unknownCount &&
          other.personalAllocated == personalAllocated &&
          other.personalSpent == personalSpent &&
          const MapEquality<String, MethodSplit>()
              .equals(other.byType, byType) &&
          const MapEquality<String, CategorySplit>()
              .equals(other.byCategory, byCategory);

  @override
  int get hashCode => Object.hash(
        income,
        incomeCard,
        incomeCash,
        expense,
        expenseCard,
        expenseCash,
        planned,
        unpaidTotal,
        unknownCount,
        personalAllocated,
        personalSpent,
        const MapEquality<String, MethodSplit>().hash(byType),
        const MapEquality<String, CategorySplit>().hash(byCategory),
      );

  @override
  String toString() => 'MonthDelta(${toIncrements()})';
}

/// `meta/totals` ga qo'shiladigan o'zgarish.
@immutable
final class TotalsDelta {
  const TotalsDelta({
    this.income = Money.zero,
    this.expense = Money.zero,
    this.personalAllocated = Money.zero,
    this.personalSpent = Money.zero,
  });

  static const TotalsDelta zero = TotalsDelta();

  final Money income;
  final Money expense;
  final Money personalAllocated;
  final Money personalSpent;

  bool get isEmpty =>
      income.isZero &&
      expense.isZero &&
      personalAllocated.isZero &&
      personalSpent.isZero;

  TotalsDelta operator +(TotalsDelta other) => TotalsDelta(
        income: income + other.income,
        expense: expense + other.expense,
        personalAllocated: personalAllocated + other.personalAllocated,
        personalSpent: personalSpent + other.personalSpent,
      );

  TotalsDelta get negated => TotalsDelta(
        income: income.negated,
        expense: expense.negated,
        personalAllocated: personalAllocated.negated,
        personalSpent: personalSpent.negated,
      );

  Map<String, Object> toIncrements() => <String, Object>{
        if (!income.isZero) 'income': income.soum,
        if (!expense.isZero) 'expense': expense.soum,
        if (!personalAllocated.isZero)
          'personalAllocated': personalAllocated.soum,
        if (!personalSpent.isZero) 'personalSpent': personalSpent.soum,
      };

  /// Offline optimistik yangilash va testlar uchun.
  OverallTotals applyTo(OverallTotals totals) => totals.copyWith(
        income: totals.income + income,
        expense: totals.expense + expense,
        personalAllocated: totals.personalAllocated + personalAllocated,
        personalSpent: totals.personalSpent + personalSpent,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotalsDelta &&
          other.income == income &&
          other.expense == expense &&
          other.personalAllocated == personalAllocated &&
          other.personalSpent == personalSpent;

  @override
  int get hashCode =>
      Object.hash(income, expense, personalAllocated, personalSpent);

  @override
  String toString() => 'TotalsDelta(${toIncrements()})';
}

/// Qarz hujjatiga qo'shiladigan o'zgarish.
@immutable
final class DebtDelta {
  const DebtDelta({
    this.fromExpenses = Money.zero,
    this.fromIncomes = Money.zero,
    this.pending = Money.zero,
  });

  static const DebtDelta zero = DebtDelta();

  /// To'langan bog'langan xarajatlar (men qarzdorman).
  final Money fromExpenses;

  /// Bog'langan daromadlar (menga qarzdor).
  final Money fromIncomes;

  /// Bog'langan, lekin hali to'lanmagan rejalar.
  final Money pending;

  bool get isEmpty =>
      fromExpenses.isZero && fromIncomes.isZero && pending.isZero;

  DebtDelta operator +(DebtDelta other) => DebtDelta(
        fromExpenses: fromExpenses + other.fromExpenses,
        fromIncomes: fromIncomes + other.fromIncomes,
        pending: pending + other.pending,
      );

  DebtDelta get negated => DebtDelta(
        fromExpenses: fromExpenses.negated,
        fromIncomes: fromIncomes.negated,
        pending: pending.negated,
      );

  Map<String, Object> toIncrements() => <String, Object>{
        if (!fromExpenses.isZero) 'paidFromExpenses': fromExpenses.soum,
        if (!fromIncomes.isZero) 'paidFromIncomes': fromIncomes.soum,
        if (!pending.isZero) 'pendingFromApp': pending.soum,
      };

  /// Offline optimistik yangilash va testlar uchun.
  Debt applyTo(Debt debt) => debt.copyWith(
        paidFromExpenses: debt.paidFromExpenses + fromExpenses,
        paidFromIncomes: debt.paidFromIncomes + fromIncomes,
        pendingFromApp: debt.pendingFromApp + pending,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtDelta &&
          other.fromExpenses == fromExpenses &&
          other.fromIncomes == fromIncomes &&
          other.pending == pending;

  @override
  int get hashCode => Object.hash(fromExpenses, fromIncomes, pending);

  @override
  String toString() => 'DebtDelta(${toIncrements()})';
}

/// Bitta yozuv o'zgarishining BARCHA agregatlarga ta'siri.
@immutable
final class AggregateDelta {
  const AggregateDelta({
    this.months = const <MonthKey, MonthDelta>{},
    this.totals = TotalsDelta.zero,
    this.debts = const <String, DebtDelta>{},
  });

  static const AggregateDelta zero = AggregateDelta();

  /// Oy kaliti → o'sha oy hujjatiga qo'shiladigan o'zgarish.
  ///
  /// `monthKey` o'zgargan tahrirda IKKI oy bo'ladi: eskisidan ayiriladi,
  /// yangisiga qo'shiladi.
  final Map<MonthKey, MonthDelta> months;
  final TotalsDelta totals;
  final Map<String, DebtDelta> debts;

  bool get isEmpty => months.isEmpty && totals.isEmpty && debts.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Bitta batch'da nechta agregat hujjat yoziladi.
  int get documentCount =>
      months.length + (totals.isEmpty ? 0 : 1) + debts.length;

  AggregateDelta operator +(AggregateDelta other) {
    final merged = <MonthKey, MonthDelta>{...months};
    for (final entry in other.months.entries) {
      final sum = (merged[entry.key] ?? MonthDelta.zero) + entry.value;
      if (sum.isEmpty) {
        merged.remove(entry.key);
      } else {
        merged[entry.key] = sum;
      }
    }
    final mergedDebts = <String, DebtDelta>{...debts};
    for (final entry in other.debts.entries) {
      final sum = (mergedDebts[entry.key] ?? DebtDelta.zero) + entry.value;
      if (sum.isEmpty) {
        mergedDebts.remove(entry.key);
      } else {
        mergedDebts[entry.key] = sum;
      }
    }
    return AggregateDelta(
      months: merged,
      totals: totals + other.totals,
      debts: mergedDebts,
    );
  }

  AggregateDelta get negated => AggregateDelta(
        months: <MonthKey, MonthDelta>{
          for (final entry in months.entries) entry.key: entry.value.negated,
        },
        totals: totals.negated,
        debts: <String, DebtDelta>{
          for (final entry in debts.entries) entry.key: entry.value.negated,
        },
      );

  /// Bir nechta o'zgarishni BITTA batch uchun yig'adi (bulk operatsiyalar).
  static AggregateDelta merge(Iterable<AggregateDelta> deltas) =>
      deltas.fold(zero, (total, delta) => total + delta);

  /// Daromad yozuvi: qo'shildi / tahrirlandi / o'chirildi.
  static AggregateDelta forIncome({Income? before, Income? after}) =>
      _incomeContribution(after) + _incomeContribution(before).negated;

  /// Xarajat yozuvi.
  static AggregateDelta forExpense({
    required String personalCategoryKey,
    Expense? before,
    Expense? after,
  }) =>
      _expenseContribution(after, personalCategoryKey) +
      _expenseContribution(before, personalCategoryKey).negated;

  /// 👤 Shaxsiy fond sarfi.
  static AggregateDelta forPersonalSpend({
    PersonalSpend? before,
    PersonalSpend? after,
  }) =>
      _personalContribution(after) + _personalContribution(before).negated;

  static AggregateDelta _incomeContribution(Income? income) {
    if (income == null) return zero;
    final isCard = income.method == PaymentMethod.card;
    final split = MethodSplit(
      card: isCard ? income.amount : Money.zero,
      cash: isCard ? Money.zero : income.amount,
    );
    return AggregateDelta(
      months: <MonthKey, MonthDelta>{
        income.monthKey: MonthDelta(
          income: income.amount,
          incomeCard: split.card,
          incomeCash: split.cash,
          byType: <String, MethodSplit>{income.type: split},
        ),
      },
      totals: TotalsDelta(income: income.amount),
      debts: income.debtId == null
          ? const <String, DebtDelta>{}
          : <String, DebtDelta>{
              income.debtId!: DebtDelta(fromIncomes: income.amount),
            },
    );
  }

  static AggregateDelta _expenseContribution(
    Expense? expense,
    String personalCategoryKey,
  ) {
    if (expense == null) return zero;
    final isCard = expense.method == PaymentMethod.card;
    final actual = expense.actualOrZero;
    final planned = expense.plannedOrZero;
    final isPaid = expense.isPaid;
    final isPersonal = expense.categoryKey == personalCategoryKey;

    return AggregateDelta(
      months: <MonthKey, MonthDelta>{
        expense.monthKey: MonthDelta(
          expense: actual,
          expenseCard: isCard ? actual : Money.zero,
          expenseCash: isCard ? Money.zero : actual,
          planned: planned,
          unpaidTotal: isPaid ? Money.zero : planned,
          unknownCount: !isPaid && expense.isUnknownAmount ? 1 : 0,
          personalAllocated: isPersonal ? actual : Money.zero,
          byCategory: <String, CategorySplit>{
            expense.category: CategorySplit(planned: planned, actual: actual),
          },
        ),
      },
      totals: TotalsDelta(
        expense: actual,
        personalAllocated: isPersonal ? actual : Money.zero,
      ),
      debts: expense.debtId == null
          ? const <String, DebtDelta>{}
          : <String, DebtDelta>{
              expense.debtId!: DebtDelta(
                fromExpenses: isPaid ? actual : Money.zero,
                pending: isPaid ? Money.zero : planned,
              ),
            },
    );
  }

  static AggregateDelta _personalContribution(PersonalSpend? spend) {
    if (spend == null) return zero;
    return AggregateDelta(
      months: <MonthKey, MonthDelta>{
        spend.monthKey: MonthDelta(personalSpent: spend.amount),
      },
      totals: TotalsDelta(personalSpent: spend.amount),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregateDelta &&
          const MapEquality<MonthKey, MonthDelta>()
              .equals(other.months, months) &&
          other.totals == totals &&
          const MapEquality<String, DebtDelta>().equals(other.debts, debts);

  @override
  int get hashCode => Object.hash(
        const MapEquality<MonthKey, MonthDelta>().hash(months),
        totals,
        const MapEquality<String, DebtDelta>().hash(debts),
      );

  @override
  String toString() =>
      'AggregateDelta(oylar: ${months.keys.toList()}, $totals, $debts)';
}

/// Ikki `byType` map'ini qo'shadi; nolga aylangan yozuvlar tashlab yuboriladi.
Map<String, MethodSplit> mergeSplitMaps(
  Map<String, MethodSplit> a,
  Map<String, MethodSplit> b,
) =>
    _merge(a, b, (x, y) => x + y, (value) => value.isZero);

/// Ikki `byCategory` map'ini qo'shadi.
Map<String, CategorySplit> mergeCategoryMaps(
  Map<String, CategorySplit> a,
  Map<String, CategorySplit> b,
) =>
    _merge(a, b, (x, y) => x + y, (value) => value.isZero);

Map<String, V> _merge<V>(
  Map<String, V> a,
  Map<String, V> b,
  V Function(V, V) add,
  bool Function(V) isZero,
) {
  if (b.isEmpty) return _pruned(a, isZero);
  final result = <String, V>{...a};
  for (final entry in b.entries) {
    final existing = result[entry.key];
    final value = existing == null ? entry.value : add(existing, entry.value);
    if (isZero(value)) {
      result.remove(entry.key);
    } else {
      result[entry.key] = value;
    }
  }
  return result;
}

Map<String, V> _pruned<V>(Map<String, V> source, bool Function(V) isZero) {
  if (!source.values.any(isZero)) return source;
  return <String, V>{
    for (final entry in source.entries)
      if (!isZero(entry.value)) entry.key: entry.value,
  };
}
