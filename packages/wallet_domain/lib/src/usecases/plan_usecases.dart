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
      // Reja avval: "yopish" (`closed_at`) serverga amaldan oldin yetadi —
      // amal trigger'i reja versiyasini oshirgach yuborilsa conflict bo'lardi.
      // To'langan summa/holat faqat lokal nusxa (server o'zi hisoblaydi).
      await _deps.transactor.run(() async {
        await _deps.plans.save(updated);
        await _deps.transactions.save(tx);
      });
    }
    return prepared;
  }
}

/// Reja o'zgarishi: tirik reja, oyi yozilishi mumkin (BR-055: yopilgan oyda —
/// qattiq qulfda taqiq, aks holda tasdiq bilan; server
/// `assert_month_writable`), [change] muvaffaqiyatli bo'lsa saqlanadi.
Future<Result<PlannedItem>> _updatePlan(
  DomainDeps deps,
  String planId, {
  required bool confirmClosedMonth,
  required Result<PlannedItem> Function(PlannedItem plan) change,
}) async {
  final plan = await deps.plans.byId(planId);
  if (plan == null || plan.deletedAt != null) {
    return _invalid('plan', 'planned_not_found');
  }
  final lock = await monthLockFailure(
    deps,
    plan.budgetMonth,
    confirmed: confirmClosedMonth,
  );
  if (lock != null) return Err(lock);
  final changed = change(plan);
  if (changed case Ok(value: final updated)) {
    await deps.transactor.run(() => deps.plans.save(updated));
  }
  return changed;
}

/// BR-071: rejani o'tkazib yuborish (`skipped: false` — qaytarish).
final class SkipPlanned {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<PlannedItem>> call(
    String planId, {
    bool skipped = true,
    bool confirmClosedMonth = false,
  }) => _updatePlan(
    _deps,
    planId,
    confirmClosedMonth: confirmClosedMonth,
    change: (plan) => Ok(
      plan.copyWith(
        skippedAt: skipped ? plan.skippedAt ?? _deps.clock.now() : null,
      ),
    ),
  );
}

/// BR-073: qisman to'langan (yoki to'lanmagan) rejani "Yopish" — to'landi
/// deb belgilash; `closed: false` — qayta ochish (holat to'lovlardan qayta
/// hisoblanadi).
final class ClosePlan {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<PlannedItem>> call(
    String planId, {
    bool closed = true,
    bool confirmClosedMonth = false,
  }) => _updatePlan(
    _deps,
    planId,
    confirmClosedMonth: confirmClosedMonth,
    change: (plan) {
      if (plan.skippedAt != null) return _invalid('plan', 'planned_skipped');
      final now = _deps.clock.now();
      return Ok(
        settlePlan(
          plan.copyWith(closedAt: closed ? plan.closedAt ?? now : null),
          now: now,
        ),
      );
    },
  );
}

/// BR-083: shu oy rejasining summasi (`null` — noma'lum) va to'lov kuni;
/// shablon o'zgarmaydi. Summa o'zgarsa holat qayta hisoblanadi (BR-071).
final class EditPlan {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<PlannedItem>> call(
    String planId, {
    required Money? plannedAmount,
    LocalDate? dueDate,
    bool confirmClosedMonth = false,
  }) async {
    if (plannedAmount != null && !plannedAmount.isPositive) {
      return _invalid('amount', 'invalid_amount');
    }
    return await _updatePlan(
      _deps,
      planId,
      confirmClosedMonth: confirmClosedMonth,
      change: (plan) {
        // Avto to'lov summasiz bo'lmaydi (server CHECK).
        if (plan.autoPay && plannedAmount == null) {
          return _invalid('amount', 'amount_required');
        }
        return Ok(
          settlePlan(
            plan.copyWith(
              plannedAmount: plannedAmount,
              dueDate: dueDate ?? plan.dueDate,
            ),
            now: _deps.clock.now(),
          ),
        );
      },
    );
  }
}
