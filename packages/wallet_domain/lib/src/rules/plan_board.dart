import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/rules/planned_status.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// E17: "To'lovlar" ro'yxati bo'limlari (BR-071 holatlari bo'yicha) —
/// ⚠️ kechikkan · 📌 bugun · 🗓 yaqin (`soonDays` kun) · keyinroq ·
/// ✅ to'langan · ⏭ o'tkazilgan. Sarlavha jami (BR-076): to'lanmagan
/// qoldiq + summasi noma'lumlar soni. O'chirilganlar kirmaydi.
@immutable
final class PlanBoard {
  factory of(
    Iterable<PlannedItem> plans, {
    required LocalDate today,
    required int soonDays,
    required Currency base,
  }) {
    final horizon = today.addDays(soonDays);
    final overdue = <PlannedItem>[];
    final dueToday = <PlannedItem>[];
    final soon = <PlannedItem>[];
    final later = <PlannedItem>[];
    final paid = <PlannedItem>[];
    final skipped = <PlannedItem>[];
    var unpaid = Money(0, base);
    var unknownCount = 0;

    for (final plan in plans) {
      if (plan.deletedAt != null) continue;
      final status = PlannedStatus.of(plan, today);
      if (status.isOpen) {
        if (plan.remaining case final remaining?) {
          unpaid += remaining;
        } else {
          unknownCount++;
        }
      }
      (switch (status) {
        PlannedStatus.skipped => skipped,
        PlannedStatus.paid => paid,
        PlannedStatus.overdue => overdue,
        _ when plan.dueDate == today => dueToday,
        _ when !plan.dueDate.isAfter(horizon) => soon,
        _ => later,
      }).add(plan);
    }
    for (final section in [overdue, dueToday, soon, later, paid, skipped]) {
      section.sort(_byDueThenName);
    }
    return PlanBoard._(
      overdue: overdue,
      today: dueToday,
      soon: soon,
      later: later,
      paid: paid,
      skipped: skipped,
      unpaid: unpaid,
      unknownCount: unknownCount,
    );
  }

  const new _({
    required this.overdue,
    required this.today,
    required this.soon,
    required this.later,
    required this.paid,
    required this.skipped,
    required this.unpaid,
    required this.unknownCount,
  });

  final List<PlannedItem> overdue;
  final List<PlannedItem> today;
  final List<PlannedItem> soon;
  final List<PlannedItem> later;
  final List<PlannedItem> paid;
  final List<PlannedItem> skipped;

  /// To'lanmagan rejalar qoldig'i (summasi ma'lumlari).
  final Money unpaid;

  /// To'lanmagan, summasi noma'lum rejalar soni (`+ N ta ?`).
  final int unknownCount;

  bool get isEmpty =>
      overdue.isEmpty &&
      today.isEmpty &&
      soon.isEmpty &&
      later.isEmpty &&
      paid.isEmpty &&
      skipped.isEmpty;

  static int _byDueThenName(PlannedItem a, PlannedItem b) {
    final due = a.dueDate.compareTo(b.dueDate);
    return due != 0 ? due : a.name.compareTo(b.name);
  }
}
