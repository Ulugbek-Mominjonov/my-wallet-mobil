import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-071, BR-073: rejaning to'langanligi — serverdagi `validate_planned_item`
/// bilan bir xil. To'landi: qo'lda yopilgan, summasiz rejaga to'lov bor yoki
/// to'langan ≥ reja. To'lov o'chirilsa holat qaytadi.
PlannedItem settlePlan(PlannedItem plan, {required DateTime now}) {
  final planned = plan.plannedAmount;
  final settled =
      plan.closedAt != null ||
      (planned == null && plan.paidAmount.isPositive) ||
      (planned != null && plan.paidAmount >= planned);
  if (!settled) return plan.copyWith(settledAt: null);
  return plan.copyWith(settledAt: plan.settledAt ?? now);
}

/// Rejaga to'lov qo'shilgan/olingan — to'langan summa va holat.
PlannedItem applyPlanPayment(
  PlannedItem plan,
  Money delta, {
  required DateTime now,
}) => settlePlan(plan.copyWith(paidAmount: plan.paidAmount + delta), now: now);
