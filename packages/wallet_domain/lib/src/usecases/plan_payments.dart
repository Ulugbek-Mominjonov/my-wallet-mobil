import 'package:wallet_domain/src/rules/plan_settlement.dart';
import 'package:wallet_domain/src/usecases/deps.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// Rejaga bog'langan amal yozildi/o'zgardi/o'chdi — rejaning to'langan
/// summasi va holati (serverdagi statement trigger'ning lokal nusxasi;
/// sinxronda server qiymati yoziladi). Bir rejaga bir nechta o'zgarish —
/// yig'indisi bilan.
Future<void> adjustPlanPayments(
  DomainDeps deps,
  Iterable<(String?, Money)> changes,
) async {
  final deltas = <String, Money>{};
  for (final (planId, delta) in changes) {
    if (planId == null) continue;
    deltas[planId] = (deltas[planId] ?? Money(0, delta.currency)) + delta;
  }
  final now = deps.clock.now();
  for (final MapEntry(key: planId, value: delta) in deltas.entries) {
    if (delta.isZero) continue;
    final plan = await deps.plans.byId(planId);
    if (plan == null) {
      throw StateError("Amal bog'langan reja lokal bazada yo'q: $planId");
    }
    await deps.plans.save(applyPlanPayment(plan, delta, now: now));
  }
}
