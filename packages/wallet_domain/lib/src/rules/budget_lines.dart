import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// Amalning byudjetdagi o'rni (serverdagi `private.budget_lines`).
enum BudgetLineKind {
  /// Byudjet daromadi (fondga daromad yo'q — BR-063).
  income,

  /// Byudjet hisobidan xarajat.
  expense,

  /// 👤 Fondga o'tkazma (+) yoki fonddan byudjetga qaytish (−) — BR-061;
  /// kategoriyasi — "O'zim uchun".
  allocation,

  /// Fond hisobidan xarajat — byudjetga ta'sir qilmaydi (BR-062).
  fundSpent,
}

/// BR-022: to'lov usuli — naqd yoki karta (qolgan hisob turlari).
enum PaymentMethod { card, cash }

/// Bitta amalning byudjet qatori (asosiy valyutada).
@immutable
final class BudgetLine {
  const new({
    required this.month,
    required this.kind,
    required this.amount,
    this.method,
    this.categoryId,
  });

  /// Tirik amalni qatorga aylantiradi. Byudjet hisoblari orasidagi o'tkazma
  /// (ikkala tomon fond emas yoki ikkalasi fond) — qator emas (BR-023) → null.
  /// [allocationCategoryId] — "O'zim uchun" tizim kategoriyasi.
  static BudgetLine? of(
    Transaction tx, {
    required AccountType accountType,
    required String? allocationCategoryId,
    AccountType? toAccountType,
  }) {
    if (tx.isDeleted) return null;
    final fromFund = accountType == AccountType.personalFund;
    PaymentMethod methodOf(AccountType type) =>
        type.isCash ? PaymentMethod.cash : PaymentMethod.card;

    switch (tx.kind) {
      case TransactionKind.income:
        return BudgetLine(
          month: tx.budgetMonth,
          kind: BudgetLineKind.income,
          amount: tx.amountBase,
          method: methodOf(accountType),
          categoryId: tx.categoryId,
        );
      case TransactionKind.expense:
        return BudgetLine(
          month: tx.budgetMonth,
          kind: fromFund ? BudgetLineKind.fundSpent : BudgetLineKind.expense,
          amount: tx.amountBase,
          method: fromFund ? null : methodOf(accountType),
          categoryId: tx.categoryId,
        );
      case TransactionKind.transfer:
        final toFund = toAccountType == AccountType.personalFund;
        if (fromFund == toFund) return null;
        return BudgetLine(
          month: tx.budgetMonth,
          kind: BudgetLineKind.allocation,
          amount: fromFund ? -tx.amountBase : tx.amountBase,
          method: methodOf(fromFund ? toAccountType! : accountType),
          categoryId: allocationCategoryId,
        );
    }
  }

  final MonthKey month;
  final BudgetLineKind kind;
  final Money amount;

  /// Fond xarajatida — null.
  final PaymentMethod? method;
  final String? categoryId;

  /// Xarajat faktiga kiradi (BR-090: xarajat + ajratma).
  bool get isSpending =>
      kind == BudgetLineKind.expense || kind == BudgetLineKind.allocation;
}

/// BR-090: [month] yig'indilari — byudjet qatorlari va rejalardan (serverdagi
/// `private.month_facts`). Rejalar: xarajat va ajratma (daromad,
/// o'tkazilgan, o'chirilgan — yo'q); to'lanmagan qoldiq va summasi
/// noma'lumlar soni (BR-076).
MonthFacts monthFactsOf(
  MonthKey month,
  Iterable<BudgetLine> lines,
  Iterable<PlannedItem> plans,
) {
  var income = Money.zero;
  var incomeCard = Money.zero;
  var incomeCash = Money.zero;
  var expense = Money.zero;
  var expenseCard = Money.zero;
  var expenseCash = Money.zero;
  var allocated = Money.zero;
  var fundSpent = Money.zero;
  var hasLines = false;
  for (final line in lines.where((line) => line.month == month)) {
    hasLines = true;
    final cash = line.method == PaymentMethod.cash;
    final card = line.method == PaymentMethod.card;
    switch (line.kind) {
      case BudgetLineKind.income:
        income += line.amount;
        if (card) incomeCard += line.amount;
        if (cash) incomeCash += line.amount;
      case BudgetLineKind.expense:
      case BudgetLineKind.allocation:
        expense += line.amount;
        if (card) expenseCard += line.amount;
        if (cash) expenseCash += line.amount;
        if (line.kind == BudgetLineKind.allocation) allocated += line.amount;
      case BudgetLineKind.fundSpent:
        fundSpent += line.amount;
    }
  }

  var planned = Money.zero;
  var unpaid = Money.zero;
  var unknownCount = 0;
  var hasPlans = false;
  for (final plan in plans) {
    if (plan.budgetMonth != month ||
        plan.deletedAt != null ||
        plan.skippedAt != null ||
        plan.kind == PlanKind.income) {
      continue;
    }
    hasPlans = true;
    final amount = plan.plannedAmount;
    if (amount != null) planned += amount;
    if (plan.settledAt != null) continue;
    if (amount == null) {
      unknownCount++;
    } else {
      unpaid += amount - plan.paidAmount;
    }
  }

  return MonthFacts(
    month: month,
    income: income,
    incomeCard: incomeCard,
    incomeCash: incomeCash,
    expense: expense,
    expenseCard: expenseCard,
    expenseCash: expenseCash,
    allocated: allocated,
    fundSpent: fundSpent,
    planned: planned,
    unpaid: unpaid,
    unknownCount: unknownCount,
    hasRecords: hasLines || hasPlans,
  );
}
