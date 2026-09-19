import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
import 'package:wallet_domain/src/failures.dart';
import 'package:wallet_domain/src/result.dart';
import 'package:wallet_domain/src/rules/plan_settlement.dart';
import 'package:wallet_domain/src/usecases/deps.dart';
import 'package:wallet_domain/src/usecases/prepare.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

// Rejalar (BR-071..074) — serverdagi `pay_planned` / `skip_planned` bilan bir
// xil qoidalar va kodlar.

Err<T> _invalid<T>(String field, String code) =>
    Err(ValidationFailure(field, code));

/// BR-073: rejani to'lash. Summa standart — qolgan reja (asosiy valyutadagi
/// hisobdan); summasi noma'lum rejada yoki boshqa valyutadagi hisobda —
/// majburiy. Kam to'lov qisman bo'lib qoladi yoki `settle` bilan yopiladi.
/// Ajratma rejasi — byudjet hisobidan 👤 fondga o'tkazma (BR-061). To'lov
/// reja oyiga tegishli (BR-044).
final class PayPlanned {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    String planId, {
    Money? amount,
    String? accountId,
    LocalDate? date,
    bool settle = false,
    bool confirmClosedMonth = false,
  }) async {
    final plan = await _deps.plans.byId(planId);
    if (plan == null || plan.deletedAt != null) {
      return _invalid('plan', 'planned_not_found');
    }
    if (plan.skippedAt != null) return _invalid('plan', 'planned_skipped');
    if (plan.settledAt != null) return _invalid('plan', 'planned_already_paid');

    final payFrom = accountId ?? plan.accountId;
    if (payFrom == null) return _invalid('account', 'account_required');
    final account = await _deps.accounts.byId(payFrom);
    if (account == null) return _invalid('account', 'account_not_found');
    final household = await _deps.households.current();
    final sameCurrency = account.currency == household.baseCurrency;
    final payAmount = amount ?? (sameCurrency ? plan.remaining : null);
    if (payAmount == null) return _invalid('amount', 'amount_required');

    final allocation = plan.kind == PlanKind.allocation;
    if (allocation && account.isPersonalFund) {
      return _invalid('account', 'invalid_account');
    }
    final draft = Transaction(
      id: _deps.ids.newId(),
      householdId: plan.householdId,
      kind: switch (plan.kind) {
        PlanKind.allocation => TransactionKind.transfer,
        PlanKind.income => TransactionKind.income,
        PlanKind.expense => TransactionKind.expense,
      },
      accountId: payFrom,
      toAccountId: allocation ? (await _deps.accounts.personalFund()).id : null,
      amount: payAmount,
      amountBase: payAmount,
      occurredOn: date ?? _deps.clock.today(),
      budgetMonth: plan.budgetMonth,
      categoryId: plan.categoryId,
      plannedItemId: plan.id,
      debtId: plan.debtId,
    );
    final prepared = await prepareTransaction(
      _deps,
      draft,
      confirmClosedMonth: confirmClosedMonth,
      plan: plan,
    );
    if (prepared case Ok(value: final tx)) {
      final now = _deps.clock.now();
      var updated = applyPlanPayment(plan, tx.amountBase, now: now);
      if (settle && updated.settledAt == null) {
        updated = settlePlan(updated.copyWith(closedAt: now), now: now);
      }
      await _deps.transactor.run(() async {
        await _deps.transactions.save(tx);
        await _deps.plans.save(updated);
      });
    }
    return prepared;
  }
}

/// BR-071: rejani o'tkazib yuborish (`skipped: false` — qaytarish).
final class SkipPlanned {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<PlannedItem>> call(String planId, {bool skipped = true}) async {
    final plan = await _deps.plans.byId(planId);
    if (plan == null || plan.deletedAt != null) {
      return _invalid('plan', 'planned_not_found');
    }
    final updated = plan.copyWith(
      skippedAt: skipped ? plan.skippedAt ?? _deps.clock.now() : null,
    );
    await _deps.transactor.run(() => _deps.plans.save(updated));
    return Ok(updated);
  }
}
