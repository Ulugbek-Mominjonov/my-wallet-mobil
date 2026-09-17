import 'package:meta/meta.dart';

import '../entities/goal.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Maqsadning hisoblangan ko'rinishi.
@immutable
final class GoalView {
  const GoalView({
    required this.goal,
    required this.remaining,
    required this.progress,
    required this.perMonth,
    required this.monthsLeft,
    required this.finishMonth,
  });

  final Goal goal;
  final Money remaining;

  /// 0..1.
  final double progress;

  /// Oyiga ajratma (maqsadniki yoki o'rtacha orttirish).
  final Money perMonth;
  final int monthsLeft;
  final MonthKey? finishMonth;

  bool get isDone => remaining.isZero && goal.target.isPositive;

  /// Muddat berilgan bo'lsa — ulgurish mumkinmi?
  bool isOnTrack(DateTime today) {
    final deadline = goal.deadline;
    if (deadline == null || monthsLeft == 0) return true;
    final finish = finishMonth;
    if (finish == null) return false;
    return finish.compareTo(MonthKey.of(deadline)) <= 0;
  }

  @override
  String toString() => 'GoalView(${goal.name}, qolgan: $remaining)';
}

/// §2.8 — maqsadlar.
///
/// ```
/// qolgan = max(0, kerak − yigilgan)
/// foiz   = min(1, yigilgan / kerak)
/// oyiga  = maqsadOyligi ?? o'rtachaOrttirish
/// oylar  = ceil(qolgan / oyiga)
/// ```
abstract final class GoalCalc {
  static GoalView view(
    Goal goal, {
    required Money averageSaved,
    required DateTime today,
  }) {
    final remaining = (goal.target - goal.saved).clampedToZero;
    final progress = goal.target.isPositive
        ? (goal.saved.soum / goal.target.soum).clamp(0.0, 1.0)
        : 0.0;
    final perMonth = goal.monthly ?? averageSaved;
    final monthsLeft = remaining.isPositive && perMonth.isPositive
        ? (remaining.soum / perMonth.soum).ceil()
        : 0;
    return GoalView(
      goal: goal,
      remaining: remaining,
      progress: progress,
      perMonth: perMonth,
      monthsLeft: monthsLeft,
      finishMonth:
          monthsLeft > 0 ? MonthKey.of(today).shift(monthsLeft) : null,
    );
  }

  static List<GoalView> views(
    Iterable<Goal> goals, {
    required Money averageSaved,
    required DateTime today,
  }) =>
      <GoalView>[
        for (final goal in goals)
          view(goal, averageSaved: averageSaved, today: today),
      ];
}
