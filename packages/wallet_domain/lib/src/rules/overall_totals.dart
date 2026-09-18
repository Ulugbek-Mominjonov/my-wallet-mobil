import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-092: barcha oylar kesimi (serverdagi `private.overall_facts`). Oylar —
/// birinchi yozuvdan joriy oygacha; o'rtachalar — yozuvi bor oylar bo'yicha.
@immutable
final class OverallTotals {
  factory of(Iterable<MonthFacts> months) {
    // Bo'sh ro'yxat — UZS nol; aks holda oylar valyutasida.
    final currency = months.isEmpty
        ? Money.zero.currency
        : months.first.income.currency;
    var income = Money(0, currency);
    var expense = Money(0, currency);
    var saved = Money(0, currency);
    var count = 0;
    for (final month in months) {
      income += month.income;
      expense += month.expense;
      saved += month.balance + month.allocated - month.fundSpent;
      if (month.hasRecords) count++;
    }
    return OverallTotals._(
      monthsCount: count,
      totalIncome: income,
      totalExpense: expense,
      totalSaved: saved,
      avgMonthlySaved: _average(saved, count),
      avgMonthlyExpense: _average(expense, count),
    );
  }

  const new _({
    required this.monthsCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaved,
    required this.avgMonthlySaved,
    required this.avgMonthlyExpense,
  });

  /// Yozuvi bor oylar soni.
  final int monthsCount;
  final Money totalIncome;
  final Money totalExpense;

  /// Σ oylik orttirgan.
  final Money totalSaved;

  /// Oyiga o'rtacha orttirish = round(jami orttirgan ÷ oylar soni).
  final Money avgMonthlySaved;
  final Money avgMonthlyExpense;

  /// Umumiy qoldiq = Σ oylik qoldiq.
  Money get totalBalance => totalIncome - totalExpense;

  /// **Invariant (BR-092):** Σ oylik orttirgan = umumiy qoldiq + 👤 fond
  /// qoldig'i. Buzilsa — ma'lumotda xato (masalan fondga daromad).
  bool holdsWith(Money fundBalance) => totalSaved == totalBalance + fundBalance;
}

Money _average(Money total, int count) => count > 0
    ? Money(roundDiv(total.minor, count), total.currency)
    : Money(0, total.currency);
