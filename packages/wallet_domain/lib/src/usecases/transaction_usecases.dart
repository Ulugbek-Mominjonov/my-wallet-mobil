import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
import 'package:wallet_domain/src/failures.dart';
import 'package:wallet_domain/src/result.dart';
import 'package:wallet_domain/src/usecases/deps.dart';
import 'package:wallet_domain/src/usecases/plan_payments.dart';
import 'package:wallet_domain/src/usecases/prepare.dart';
import 'package:wallet_domain/src/value_objects/fx_rate.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

// Amallar (BR-050..056, BR-009, BR-062, BR-141). Har yozuv — bitta lokal
// tranzaksiyada (qator + outbox + bog'langan reja), natija — lokal taxmin.

const _notFound = ValidationFailure('id', 'not_found');

/// BR-050, BR-051: yangi daromad yoki xarajat.
@immutable
final class TransactionInput {
  const new({
    required this.kind,
    required this.accountId,
    required this.amount,
    this.categoryId,
    this.occurredOn,
    this.manualMonth,
    this.payee,
    this.note,
    this.debtId,
    this.fxRate,
    this.source = TransactionSource.manual,
  });

  /// `income` yoki `expense` (o'tkazma — `AddTransfer`).
  final TransactionKind kind;
  final String accountId;
  final Money amount;

  /// Fond hisobidan xarajatda bo'sh bo'lsa — "O'zim uchun" (BR-062).
  final String? categoryId;

  /// Standart — bugun (byudjet vaqt zonasida).
  final LocalDate? occurredOn;

  /// BR-041, BR-042: qo'lda tanlangan oy.
  final MonthKey? manualMonth;
  final String? payee;
  final String? note;
  final String? debtId;

  /// BR-192: qo'lda kurs (bo'sh — sanadagi kurs).
  final FxRate? fxRate;
  final TransactionSource source;
}

final class AddTransaction {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    TransactionInput input, {
    bool confirmClosedMonth = false,
  }) async {
    if (input.kind == TransactionKind.transfer) {
      throw ArgumentError.value(input.kind, 'kind', "o'tkazma — AddTransfer");
    }
    final household = await _deps.households.current();
    final occurredOn = input.occurredOn ?? _deps.clock.today();
    final draft = Transaction(
      id: _deps.ids.newId(),
      householdId: household.id,
      kind: input.kind,
      accountId: input.accountId,
      amount: input.amount,
      amountBase: input.amount,
      occurredOn: occurredOn,
      budgetMonth: input.manualMonth ?? occurredOn.monthKey,
      budgetMonthSource: input.manualMonth == null
          ? BudgetMonthSource.auto
          : BudgetMonthSource.manual,
      categoryId: input.categoryId,
      payee: input.payee,
      note: input.note,
      debtId: input.debtId,
      fxRate: input.fxRate?.toString(),
      source: input.source,
    );
    return await _insert(_deps, draft, confirmClosedMonth: confirmClosedMonth);
  }
}

/// BR-053: o'tkazma (turli valyutada — ikkala summa, BR-193).
@immutable
final class TransferInput {
  const new({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    this.toAmount,
    this.occurredOn,
    this.note,
    this.fxRate,
  });

  final String fromAccountId;
  final String toAccountId;
  final Money amount;

  /// Manzil hisob valyutasida; valyutalar bir xil bo'lsa — `amount`.
  final Money? toAmount;
  final LocalDate? occurredOn;
  final String? note;

  /// BR-192: manba hisob valyutasi uchun qo'lda kurs.
  final FxRate? fxRate;
}

final class AddTransfer {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    TransferInput input, {
    bool confirmClosedMonth = false,
  }) async {
    final household = await _deps.households.current();
    final occurredOn = input.occurredOn ?? _deps.clock.today();
    final draft = Transaction(
      id: _deps.ids.newId(),
      householdId: household.id,
      kind: TransactionKind.transfer,
      accountId: input.fromAccountId,
      toAccountId: input.toAccountId,
      amount: input.amount,
      amountBase: input.amount,
      toAmount: input.toAmount,
      occurredOn: occurredOn,
      budgetMonth: occurredOn.monthKey,
      note: input.note,
      fxRate: input.fxRate?.toString(),
    );
    return await _insert(_deps, draft, confirmClosedMonth: confirmClosedMonth);
  }
}

/// BR-062: 👤 shaxsiy fonddan sarf — byudjet qoldig'iga ta'sir qilmaydi;
/// kategoriya ko'rsatilmasa — "O'zim uchun".
final class AddPersonalSpend {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call({
    required Money amount,
    String? categoryId,
    LocalDate? occurredOn,
    String? payee,
    String? note,
    bool confirmClosedMonth = false,
  }) async {
    final fund = await _deps.accounts.personalFund();
    return await AddTransaction(_deps)(
      TransactionInput(
        kind: TransactionKind.expense,
        accountId: fund.id,
        amount: amount,
        categoryId: categoryId,
        occurredOn: occurredOn,
        payee: payee,
        note: note,
      ),
      confirmClosedMonth: confirmClosedMonth,
    );
  }
}

/// BR-141: tez tugma — darhol bugungi sana bilan xarajat
/// (`source = quick_action`); bekor qilish — `DeleteTransaction`.
final class QuickAdd {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    String quickActionId, {
    bool confirmClosedMonth = false,
  }) async {
    final action = await _deps.quickActions.byId(quickActionId);
    if (action == null || action.deletedAt != null) {
      return const Err(ValidationFailure('quick_action', 'not_found'));
    }
    return await AddTransaction(_deps)(
      TransactionInput(
        kind: TransactionKind.expense,
        accountId: action.accountId,
        amount: action.amount,
        categoryId: action.categoryId,
        payee: action.payee,
        source: TransactionSource.quickAction,
      ),
      confirmClosedMonth: confirmClosedMonth,
    );
  }
}

/// Amalni tahrirlash. Tur o'zgarmaydi (boshqa tur — o'chirib yangisi).
/// BR-043: tegishli oy faqat kirishlar (tur, kategoriya, sana, reja, manba,
/// qo'lda oy) o'zgarsa qayta hisoblanadi.
final class EditTransaction {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    String id,
    Transaction Function(Transaction current) edit, {
    bool confirmClosedMonth = false,
  }) async {
    final current = await _deps.transactions.byId(id);
    if (current == null || current.isDeleted) return const Err(_notFound);
    final edited = edit(current);
    if (edited.id != current.id ||
        edited.householdId != current.householdId ||
        edited.kind != current.kind) {
      throw ArgumentError("Amal ID si, byudjeti va turi o'zgarmaydi");
    }
    final oldLock = await monthLockFailure(
      _deps,
      current.budgetMonth,
      confirmed: confirmClosedMonth,
    );
    if (oldLock != null) return Err(oldLock);

    final inputsChanged =
        (
          edited.categoryId,
          edited.occurredOn,
          edited.plannedItemId,
          edited.budgetMonthSource,
          edited.budgetMonth,
        ) !=
        (
          current.categoryId,
          current.occurredOn,
          current.plannedItemId,
          current.budgetMonthSource,
          current.budgetMonth,
        );
    final planId = edited.plannedItemId;
    final prepared = await prepareTransaction(
      _deps,
      edited,
      confirmClosedMonth: confirmClosedMonth,
      plan: planId == null ? null : await _deps.plans.byId(planId),
      recomputeMonth: inputsChanged,
    );
    if (prepared case Ok(value: final tx)) {
      await _deps.transactor.run(() async {
        await _deps.transactions.save(tx);
        await adjustPlanPayments(_deps, [
          (current.plannedItemId, -current.amountBase),
          (tx.plannedItemId, tx.amountBase),
        ]);
      });
    }
    return prepared;
  }
}

/// BR-009: o'chirish (soft delete). Natija — o'chirilgunga qadar nusxa:
/// 5 soniya ichida `UndoDeleteTransaction` bilan qaytariladi.
final class DeleteTransaction {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(
    String id, {
    bool confirmClosedMonth = false,
  }) async {
    final current = await _deps.transactions.byId(id);
    if (current == null || current.isDeleted) return const Err(_notFound);
    final lock = await monthLockFailure(
      _deps,
      current.budgetMonth,
      confirmed: confirmClosedMonth,
    );
    if (lock != null) return Err(lock);
    final now = _deps.clock.now();
    await _deps.transactor.run(() async {
      await _deps.transactions.save(current.copyWith(deletedAt: now));
      await adjustPlanPayments(_deps, [
        (current.plannedItemId, -current.amountBase),
      ]);
    });
    return Ok(current);
  }
}

/// BR-009: o'chirilgan amalni qaytarish.
final class UndoDeleteTransaction {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Transaction>> call(Transaction snapshot) async {
    final current = await _deps.transactions.byId(snapshot.id);
    if (current == null) return const Err(_notFound);
    if (!current.isDeleted) return Ok(current);
    final restored = current.copyWith(deletedAt: null);
    await _deps.transactor.run(() async {
      await _deps.transactions.save(restored);
      await adjustPlanPayments(_deps, [
        (restored.plannedItemId, restored.amountBase),
      ]);
    });
    return Ok(restored);
  }
}

Future<Result<Transaction>> _insert(
  DomainDeps deps,
  Transaction draft, {
  required bool confirmClosedMonth,
}) async {
  final prepared = await prepareTransaction(
    deps,
    draft,
    confirmClosedMonth: confirmClosedMonth,
  );
  if (prepared case Ok(value: final tx)) {
    await deps.transactor.run(() => deps.transactions.save(tx));
  }
  return prepared;
}
