import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

part 'planned_item.freezed.dart';

/// BR-070..076: oy rejasi (to'lov). Summalar — asosiy valyutada (ADR-06).
/// `paidAmount` va `settledAt` — server hisoblaydi (bog'langan amallardan).
@freezed
abstract class PlannedItem with _$PlannedItem {
  const factory({
    required String id,
    required String householdId,
    required PlanKind kind,
    required String name,
    required LocalDate dueDate,

    /// BR-044: reja (va uning to'lovlari) shu oyga tegishli.
    required MonthKey budgetMonth,
    String? categoryId,
    String? accountId,

    /// null — summa noma'lum ("summa o'zgaruvchi").
    Money? plannedAmount,
    @Default(Money.zero) Money paidAmount,
    @Default(false) bool autoPay,
    String? debtId,
    String? recurringRuleId,
    SystemCode? systemCode,
    String? note,

    /// To'langan (server: `paid ≥ planned`, summasiz rejaga to'lov yoki
    /// `closedAt`).
    DateTime? settledAt,

    /// Qo'lda yopilgan (to'liq to'lanmagan bo'lsa ham) — BR-073.
    DateTime? closedAt,
    DateTime? skippedAt,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _PlannedItem;

  const new _();

  /// Qolgan summa (noma'lum summada — null).
  Money? get remaining => plannedAmount == null
      ? null
      : (plannedAmount! - paidAmount).isNegative
      ? Money(0, paidAmount.currency)
      : plannedAmount! - paidAmount;

  bool get isFundAllocation => systemCode == SystemCode.personalAllocation;
}
