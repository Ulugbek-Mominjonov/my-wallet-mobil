import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/rules/month_facts.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-093: oy oxirigacha prognoz, BR-094: kuniga sarflash mumkin — serverdagi
/// `report_month.projection` bilan bir xil.
@immutable
final class MonthForecast {
  /// [history] — birinchi yozuv oyidan `max(oy, joriy oy)` gacha barcha oylar
  /// (boshqa oylar o'rtacha daromadi uchun). [incomePlanCount] va
  /// [incomePlansPending] — shu oyning (o'tkazilmagan) daromad rejalari soni
  /// va to'lanmagan qoldig'i.
  factory of({
    required MonthFacts month,
    required LocalDate today,
    required Iterable<MonthFacts> history,
    int incomePlanCount = 0,
    Money incomePlansPending = Money.zero,
  }) {
    final current = today.monthKey;
    final days = month.month.daysInMonth;
    final elapsed = month.month.isBefore(current)
        ? days
        : month.month == current
        ? (today.day < days ? today.day : days)
        : 0;
    final expected = _expectedIncome(
      month: month,
      current: current,
      history: history,
      incomePlanCount: incomePlanCount,
      incomePlansPending: incomePlansPending,
    );
    final expense = month.expense;
    final monthEndSpend = month.month == current && elapsed > 0
        ? Money(roundDiv(expense.minor * days, elapsed), expense.currency)
        : expense;
    return MonthForecast._(
      daysInMonth: days,
      daysElapsed: elapsed,
      dailySpend: elapsed > 0
          ? Money(roundDiv(expense.minor, elapsed), expense.currency)
          : Money(0, expense.currency),
      monthEndSpend: monthEndSpend,
      incomeReceived: month.income,
      incomeExpected: expected,
      monthEndBalance: expected - monthEndSpend,
      perDayAvailable: month.month == current
          ? safeToSpendPerDay(
              expectedIncome: expected,
              expense: month.expense,
              unpaid: month.unpaid,
              today: today,
            )
          : null,
    );
  }

  const new _({
    required this.daysInMonth,
    required this.daysElapsed,
    required this.dailySpend,
    required this.monthEndSpend,
    required this.incomeReceived,
    required this.incomeExpected,
    required this.monthEndBalance,
    required this.perDayAvailable,
  });

  final int daysInMonth;

  /// Joriy oy — bugungacha (bugun ham), o'tgan oy — hammasi, kelgusi — 0.
  final int daysElapsed;
  final Money dailySpend;
  final Money monthEndSpend;
  final Money incomeReceived;
  final Money incomeExpected;

  /// 📉 Oy oxiri qoldig'i.
  final Money monthEndBalance;

  /// BR-094 (faqat joriy oy).
  final Money? perDayAvailable;

  /// "Hozircha kelgani X, qolgani kutilmoqda".
  bool get incomePending => incomeExpected > incomeReceived;
}

/// Kutilayotgan daromad: o'tgan oy — kelgan; daromad rejalari bo'lsa —
/// kelgan + kelmagan qoldiq; aks holda max(kelgan, boshqa oylar o'rtachasi).
Money _expectedIncome({
  required MonthFacts month,
  required MonthKey current,
  required Iterable<MonthFacts> history,
  required int incomePlanCount,
  required Money incomePlansPending,
}) {
  if (month.month.isBefore(current)) return month.income;
  if (incomePlanCount > 0) return month.income + incomePlansPending;

  var monthsWithRecords = 0;
  var totalIncome = Money(0, month.income.currency);
  for (final item in history) {
    totalIncome += item.income;
    if (item.hasRecords) monthsWithRecords++;
  }
  final otherMonths = monthsWithRecords - (month.hasRecords ? 1 : 0);
  final others = totalIncome - month.income;
  final average = otherMonths > 0
      ? Money(roundDiv(others.minor, otherMonths), others.currency)
      : Money(0, others.currency);
  return average > month.income ? average : month.income;
}

/// BR-094: `max(0, kutilayotgan − xarajat − to'lanmagan) ÷ qolgan kunlar`
/// (bugun ham kiradi, butun bo'lish — server bilan bir xil).
Money safeToSpendPerDay({
  required Money expectedIncome,
  required Money expense,
  required Money unpaid,
  required LocalDate today,
}) {
  final available = expectedIncome - expense - unpaid;
  final remainingDays = today.monthKey.daysInMonth - today.day + 1;
  return available.isNegative
      ? Money(0, available.currency)
      : Money(available.minor ~/ remainingDays, available.currency);
}
