import 'package:meta/meta.dart';

import '../entities/expense.dart';
import '../value_objects/day.dart';
import '../value_objects/money.dart';

/// Eslatma uchun guruhlangan to'lovlar.
@immutable
final class ReminderBuckets {
  const ReminderBuckets({
    required this.overdue,
    required this.dueToday,
    required this.upcoming,
  });

  static const ReminderBuckets empty = ReminderBuckets(
    overdue: <Expense>[],
    dueToday: <Expense>[],
    upcoming: <Expense>[],
  );

  /// ⚠️ Muddati o'tgan.
  final List<Expense> overdue;

  /// 📌 Bugun to'lanadi.
  final List<Expense> dueToday;

  /// 🗓 Yaqin kunlarda.
  final List<Expense> upcoming;

  bool get isEmpty =>
      overdue.isEmpty && dueToday.isEmpty && upcoming.isEmpty;

  int get count => overdue.length + dueToday.length + upcoming.length;

  /// Eslatiladigan jami summa (noma'lum summali qatorlar hisobga olinmaydi).
  Money get total => Money.sum(<Money>[
        for (final item in <Expense>[...overdue, ...dueToday, ...upcoming])
          item.plannedOrZero,
      ]);
}

/// Kunlik eslatma uchun to'lovlarni guruhlaydi (`kunlikEslatma`).
abstract final class ReminderCalc {
  static ReminderBuckets split(
    Iterable<Expense> expenses, {
    required DateTime today,
    required int daysAhead,
  }) {
    final overdue = <Expense>[];
    final dueToday = <Expense>[];
    final upcoming = <Expense>[];
    final limit = dateOnly(today).add(Duration(days: daysAhead));

    for (final expense in expenses) {
      if (expense.isPaid) continue;
      // Reja aniq nol bo'lgan qatorlar kuzatilmaydi — eslatilmaydi ham.
      if (!expense.isUnknownAmount && !expense.plannedOrZero.isPositive) {
        continue;
      }
      final due = dateOnly(expense.dueDate);
      if (due.isBefore(dateOnly(today))) {
        overdue.add(expense);
      } else if (isSameDay(due, today)) {
        dueToday.add(expense);
      } else if (!due.isAfter(limit)) {
        upcoming.add(expense);
      }
    }

    int byDate(Expense a, Expense b) => a.dueDate.compareTo(b.dueDate);
    overdue.sort(byDate);
    dueToday.sort(byDate);
    upcoming.sort(byDate);

    return ReminderBuckets(
      overdue: overdue,
      dueToday: dueToday,
      upcoming: upcoming,
    );
  }
}
