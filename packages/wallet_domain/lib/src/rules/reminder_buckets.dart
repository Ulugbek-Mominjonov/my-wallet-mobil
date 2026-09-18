import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';

/// BR-160: kunlik eslatma bo'limlari — ⚠️ muddati o'tgan, 📌 bugun, 🗓 yaqin
/// `daysAhead` kun. Daromad rejalari kirmaydi; to'langan, o'tkazilgan va
/// o'chirilganlar — yo'q. Server (`jobs.enqueue_reminders`) va mobil offline
/// eslatmasi (BR-168) bir xil tanlaydi.
@immutable
final class ReminderBuckets {
  factory of(
    Iterable<PlannedItem> plans, {
    required LocalDate today,
    required int daysAhead,
  }) {
    final horizon = today.addDays(daysAhead);
    final open = plans.where(
      (p) =>
          p.kind != PlanKind.income &&
          p.settledAt == null &&
          p.skippedAt == null &&
          p.deletedAt == null &&
          !p.dueDate.isAfter(horizon),
    );
    int byDueThenName(PlannedItem a, PlannedItem b) {
      final due = a.dueDate.compareTo(b.dueDate);
      return due != 0 ? due : a.name.compareTo(b.name);
    }

    return ReminderBuckets._(
      overdue: open.where((p) => p.dueDate.isBefore(today)).toList()
        ..sort(byDueThenName),
      today: open.where((p) => p.dueDate == today).toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
      upcoming: open.where((p) => p.dueDate.isAfter(today)).toList()
        ..sort(byDueThenName),
    );
  }

  const new _({
    required this.overdue,
    required this.today,
    required this.upcoming,
  });

  final List<PlannedItem> overdue;
  final List<PlannedItem> today;
  final List<PlannedItem> upcoming;

  /// Eslatadigan narsa yo'q — eslatma yuborilmaydi (BR-160).
  bool get isEmpty => overdue.isEmpty && today.isEmpty && upcoming.isEmpty;
}
