import '../entities/expense.dart';
import '../value_objects/day.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';

/// §2.6 — to'lov holati va avto to'lov.
abstract final class PaymentStatusCalc {
  /// ```
  /// fakt > 0                  → ✅ To'landi
  /// fakt yo'q && sana < bugun → ⚠️ Muddati o'tdi
  /// fakt yo'q                 → ⏳ Kutilmoqda
  /// reja aniq 0 va fakt yo'q  → — (kuzatilmaydi)
  /// ```
  /// Diqqat: reja `null` (summasi noma'lum) — bu kuzatiladigan to'lov,
  /// reja aniq `0` esa — kuzatilmaydigan qator.
  static PaymentStatus compute({
    required Money? planned,
    required Money? actual,
    required DateTime dueDate,
    required DateTime today,
  }) {
    if ((actual ?? Money.zero).isPositive) return PaymentStatus.paid;
    final isUnknownAmount = planned == null;
    if (!isUnknownAmount && !planned.isPositive) return PaymentStatus.none;
    return isDayBefore(dueDate, today)
        ? PaymentStatus.overdue
        : PaymentStatus.pending;
  }

  /// Xarajatning holatini sanaga qarab qayta hisoblaydi.
  static PaymentStatus of(Expense expense, DateTime today) => compute(
        planned: expense.planned,
        actual: expense.actual,
        dueDate: expense.dueDate,
        today: today,
      );

  /// Avto to'lov sharti: `autoPay && reja > 0 && sana <= bugun && fakt yo'q`.
  static bool shouldAutoPay(Expense expense, DateTime today) =>
      expense.autoPay &&
      !expense.isPaid &&
      expense.plannedOrZero.isPositive &&
      !isDayAfter(expense.dueDate, today);

  /// Avto to'lovni qo'llaydi: `fakt = reja`. Shart bajarilmasa —
  /// o'zgarishsiz, lekin holat sanaga ko'ra yangilanadi.
  static Expense applyAutoPay(Expense expense, DateTime today) {
    if (shouldAutoPay(expense, today)) {
      final paid = expense.copyWith(actual: expense.planned);
      return paid.copyWith(status: of(paid, today));
    }
    return expense.copyWith(status: of(expense, today));
  }
}
