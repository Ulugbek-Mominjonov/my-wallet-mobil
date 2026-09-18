import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';

/// BR-071: reja holati — saqlanmaydi, bugungi sanaga bog'liq (byudjet vaqt
/// zonasida). Tartib serverdagi `private.planned_status` bilan bir xil.
enum PlannedStatus {
  skipped,
  paid,
  overdue,
  partial,
  pending;

  factory of(PlannedItem item, LocalDate today) {
    if (item.skippedAt != null) return skipped;
    if (item.settledAt != null) return paid;
    if (item.dueDate.isBefore(today)) return overdue;
    if (item.paidAmount.isPositive) return partial;
    return pending;
  }

  /// To'lov kutilmoqda (ro'yxat va eslatmalarda ko'rsatiladi).
  bool get isOpen => this == overdue || this == partial || this == pending;
}
