import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-091: hosila ko'rsatkichlar — serverdagi `private.month_derived` bilan
/// bir xil (nisbatlar 4 xonagacha, noldan uzoqqa yaxlitlangan).
@immutable
final class MonthSummary {
  factory of(MonthFacts facts) => MonthSummary.fromTotals(
    income: facts.income,
    expense: facts.expense,
    unpaid: facts.unpaid,
    allocated: facts.allocated,
    fundSpent: facts.fundSpent,
    planned: facts.planned,
    incomeCard: facts.incomeCard,
    incomeCash: facts.incomeCash,
    expenseCard: facts.expenseCard,
    expenseCash: facts.expenseCash,
  );

  /// Bir necha oy yig'indisi uchun ham (yillik jami — BR-092).
  factory fromTotals({
    required Money income,
    required Money expense,
    required Money unpaid,
    required Money allocated,
    required Money fundSpent,
    required Money planned,
    Money incomeCard = Money.zero,
    Money incomeCash = Money.zero,
    Money expenseCard = Money.zero,
    Money expenseCash = Money.zero,
  }) {
    final balance = income - expense;
    final saved = balance + allocated - fundSpent;
    return MonthSummary._(
      balance: balance,
      forecast: balance - unpaid,
      saved: saved,
      savedRatio: income.isPositive ? ratio4(saved.minor, income.minor) : 0,
      spentRatio: income.isPositive ? ratio4(expense.minor, income.minor) : 0,
      planRatio: planned.isPositive
          ? ratio4(expense.minor, planned.minor)
          : null,
      card: incomeCard - expenseCard,
      cash: incomeCash - expenseCash,
    );
  }

  const new _({
    required this.balance,
    required this.forecast,
    required this.saved,
    required this.savedRatio,
    required this.spentRatio,
    required this.planRatio,
    required this.card,
    required this.cash,
  });

  /// 💰 Qoldiq = daromad − xarajat.
  final Money balance;

  /// 🔮 Prognoz qoldiq = qoldiq − to'lanmagan jami.
  final Money forecast;

  /// 📈 Orttirgan = qoldiq + ajratilgan − fonddan sarflangan.
  final Money saved;

  /// Orttirish foizi (daromad 0 bo'lsa 0).
  final double savedRatio;

  /// Sarflandi (%) = xarajat ÷ daromad.
  final double spentRatio;

  /// Reja bajarilishi = xarajat ÷ reja jami (reja yo'q — null).
  final double? planRatio;

  /// 💳 Karta va 💵 naqd qoldig'i (BR-022).
  final Money card;
  final Money cash;
}
