import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/goal.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// Oylik ajratma manbai: maqsadniki yoki oyiga o'rtacha orttirish (BR-092).
enum GoalMonthlySource { goal, average }

/// BR-121, BR-122: maqsad hisobi (serverdagi `report_goals`).
@immutable
final class GoalProgress {
  /// [accountBalance] — maqsad hisobga bog'langan bo'lsa uning qoldig'i
  /// (BR-122); [avgMonthlySaved] — `OverallTotals.avgMonthlySaved`.
  factory of(
    Goal goal, {
    required Money avgMonthlySaved,
    required MonthKey currentMonth,
    Money? accountBalance,
  }) {
    final zero = Money(0, goal.target.currency);
    final saved = goal.accountId == null
        ? goal.savedManual
        : (accountBalance == null || accountBalance.isNegative
              ? zero
              : accountBalance);
    final left = goal.target - saved;
    final remaining = left.isNegative ? zero : left;

    final contribution = goal.monthlyContribution;
    final (monthly, source) = contribution != null
        ? (contribution, GoalMonthlySource.goal)
        : avgMonthlySaved.isPositive
        ? (
            Money(avgMonthlySaved.minor, goal.target.currency),
            GoalMonthlySource.average,
          )
        : (null, null);
    final monthsLeft =
        remaining.isPositive && monthly != null && monthly.isPositive
        ? (remaining.minor + monthly.minor - 1) ~/ monthly.minor
        : null;
    final endMonth = monthsLeft == null ? null : currentMonth.shift(monthsLeft);
    return GoalProgress._(
      saved: saved,
      remaining: remaining,
      progress: saved >= goal.target
          ? 1
          : ratio4(saved.minor, goal.target.minor),
      monthly: monthly,
      monthlySource: source,
      monthsLeft: monthsLeft,
      endMonth: endMonth,
      onTrack: endMonth == null || goal.deadline == null
          ? null
          : !endMonth.isAfter(goal.deadline!),
    );
  }

  const new _({
    required this.saved,
    required this.remaining,
    required this.progress,
    required this.monthly,
    required this.monthlySource,
    required this.monthsLeft,
    required this.endMonth,
    required this.onTrack,
  });

  final Money saved;
  final Money remaining;

  /// min(1, yig'ilgan ÷ kerak), 4 xona.
  final double progress;

  /// Oyiga = maqsad.oyiga ?? oyiga o'rtacha orttirish (musbat bo'lsa).
  final Money? monthly;
  final GoalMonthlySource? monthlySource;
  final int? monthsLeft;
  final MonthKey? endMonth;

  /// Ulguradimi (tugash oyi ≤ muddat); muddat yoki prognoz yo'q — null.
  final bool? onTrack;

  /// ✅ Yig'ildi.
  bool get isReached => remaining.isZero;
}
