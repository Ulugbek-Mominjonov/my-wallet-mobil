import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/rules/month_summary.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// E32-T02, T04: "Yil xulosasi" — yozuvi bor oylar bo'yicha (BR-092).
/// Bo'sh oylar o'rtachani pasaytirmaydi; bitta oyda "eng og'ir oy" yo'q.
@immutable
final class YearSummary {
  factory of(Iterable<MonthFacts> months, {Currency base = Currency.uzs}) {
    final active = [
      for (final month in months)
        if (month.hasRecords)
          (facts: month, saved: MonthSummary.of(month).saved),
    ]..sort((a, b) => a.saved.minor.compareTo(b.saved.minor));
    final income = Money.sum(active.map((m) => m.facts.income), base);
    final expense = Money.sum(active.map((m) => m.facts.expense), base);
    final saved = Money.sum(active.map((m) => m.saved), base);
    final count = active.length;
    return YearSummary._(
      income: income,
      expense: expense,
      saved: saved,
      savedRatio: income.isPositive ? ratio4(saved.minor, income.minor) : 0,
      monthsCount: count,
      avgIncome: count == 0
          ? Money(0, base)
          : Money(roundDiv(income.minor, count), base),
      avgExpense: count == 0
          ? Money(0, base)
          : Money(roundDiv(expense.minor, count), base),
      best: active.isEmpty
          ? null
          : (month: active.last.facts.month, saved: active.last.saved),
      worst: count < 2
          ? null
          : (month: active.first.facts.month, saved: active.first.saved),
    );
  }

  const new _({
    required this.income,
    required this.expense,
    required this.saved,
    required this.savedRatio,
    required this.monthsCount,
    required this.avgIncome,
    required this.avgExpense,
    required this.best,
    required this.worst,
  });

  final Money income;
  final Money expense;

  /// BR-092: orttirgan (ajratma va fond sarfi bilan).
  final Money saved;
  final double savedRatio;

  /// Yozuvi bor oylar soni (o'rtachalar shu bo'yicha).
  final int monthsCount;
  final Money avgIncome;
  final Money avgExpense;

  /// Eng ko'p va eng kam orttirilgan oylar.
  final ({MonthKey month, Money saved})? best;
  final ({MonthKey month, Money saved})? worst;

  bool get isEmpty => monthsCount == 0;
}
