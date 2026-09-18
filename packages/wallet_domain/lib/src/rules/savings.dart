import 'package:meta/meta.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-100, BR-101: 🏦 jamg'arma jadvali qatori — `to'plangan(i) =
/// to'plangan(i−1) + qoldiq(i)`; joriy oy — ⏳.
@immutable
final class SavingsRow {
  const new({
    required this.month,
    required this.income,
    required this.expense,
    required this.accumulated,
    required this.isCurrent,
  });

  final MonthKey month;
  final Money income;
  final Money expense;
  final Money accumulated;
  final bool isCurrent;

  /// Shu oy qolgan (qoldiq).
  Money get balance => income - expense;
}

/// [months] — xronologik (birinchi yozuvdan joriy oygacha, serverdagi
/// `report_savings` bilan bir xil oraliq).
List<SavingsRow> savingsTable(
  Iterable<MonthFacts> months, {
  required MonthKey current,
}) {
  final sorted = months.toList()..sort((a, b) => a.month.compareTo(b.month));
  final rows = <SavingsRow>[];
  Money? accumulated;
  for (final month in sorted) {
    accumulated =
        (accumulated ?? Money(0, month.income.currency)) + month.balance;
    rows.add(
      SavingsRow(
        month: month.month,
        income: month.income,
        expense: month.expense,
        accumulated: accumulated,
        isCurrent: month.month == current,
      ),
    );
  }
  return rows;
}

/// BR-102: oy hisobotidagi jamg'arma — oldingi oylardan to'plangan, shu oy
/// qo'shilgan (qoldiq), shu oygacha jami.
@immutable
final class MonthSavings {
  /// [history] — birinchi yozuvdan kamida [month] gacha bo'lgan oylar.
  factory of(Iterable<MonthFacts> history, MonthKey month) {
    Money? before;
    Money? thisMonth;
    for (final item in history) {
      if (item.month.isBefore(month)) {
        before = (before ?? Money(0, item.income.currency)) + item.balance;
      } else if (item.month == month) {
        thisMonth = item.balance;
      }
    }
    final currency = (thisMonth ?? before ?? Money.zero).currency;
    return MonthSavings._(
      before: before ?? Money(0, currency),
      thisMonth: thisMonth ?? Money(0, currency),
    );
  }

  const new _({required this.before, required this.thisMonth});

  final Money before;
  final Money thisMonth;

  Money get total => before + thisMonth;
}
