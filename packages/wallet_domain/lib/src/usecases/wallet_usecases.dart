import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/debt.dart';
import 'package:wallet_domain/src/entities/directory_items.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/goal.dart';
import 'package:wallet_domain/src/failures.dart';
import 'package:wallet_domain/src/result.dart';
import 'package:wallet_domain/src/usecases/deps.dart';
import 'package:wallet_domain/src/usecases/directory_usecases.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

// Hamyon (E18): qarzlar, maqsadlar va limitlar — serverdagi cheklovlar bilan
// bir xil (contracts/api.md, E07): nom 1–60 belgi, byudjetda registrsiz
// yagona (BR-003), summalar musbat, izoh ≤ 1000 belgi.

/// `note_text` domeni chegarasi.
const maxNoteLength = 1000;

Err<T> _invalid<T>(String field, String code) =>
    Err(ValidationFailure(field, code));

/// Tozalangan nom; bo'sh yoki 60 belgidan uzun — null.
String? _validName(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty || trimmed.length > maxEntityNameLength
      ? null
      : trimmed;
}

String? _note(String? note) {
  final trimmed = note?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// BR-110: qarz maydonlari (yo'nalish va valyuta — faqat yaratishda).
@immutable
final class DebtInput {
  const new({
    required this.name,
    required this.direction,
    required this.total,
    this.paidBefore,
    this.monthlyPayment,
    this.dueDate,
    this.note,
  });

  final String name;
  final DebtDirection direction;

  /// Qarz valyutasida (BR-194).
  final Money total;

  /// Ilovadan tashqarida (oldin) to'langan; standart — 0.
  final Money? paidBefore;
  final Money? monthlyPayment;
  final LocalDate? dueDate;
  final String? note;
}

/// BR-110: qarz qo'shish (`id` berilmasa) yoki tahrirlash.
final class SaveDebt {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Debt>> call(DebtInput input, {String? id}) async {
    final name = _validName(input.name);
    if (name == null) return _invalid('name', 'invalid_name');
    final total = input.total;
    final paidBefore = input.paidBefore ?? Money(0, total.currency);
    if (!total.isPositive) return _invalid('total', 'invalid_amount');
    if (paidBefore.isNegative || paidBefore > total) {
      return _invalid('paid_before', 'invalid_amount');
    }
    if (input.monthlyPayment case final monthly? when !monthly.isPositive) {
      return _invalid('monthly_payment', 'invalid_amount');
    }
    final note = _note(input.note);
    if ((note?.length ?? 0) > maxNoteLength) {
      return _invalid('note', 'invalid_note');
    }

    final existing = id == null ? null : await _deps.debts.byId(id);
    if (id != null && (existing == null || existing.deletedAt != null)) {
      return _invalid('debt', 'debt_not_found');
    }
    final same = await _deps.debts.byName(name);
    if (same != null && same.id != id) {
      return _invalid('name', 'duplicate_name');
    }
    final household = await _deps.households.current();
    final debt = Debt(
      id: existing?.id ?? _deps.ids.newId(),
      householdId: household.id,
      name: name,
      // Yo'nalish yaratilgandan keyin o'zgarmaydi.
      direction: existing?.direction ?? input.direction,
      total: total,
      paidBefore: paidBefore,
      monthlyPayment: input.monthlyPayment,
      dueDate: input.dueDate,
      note: note,
      archivedAt: existing?.archivedAt,
      rowVersion: existing?.rowVersion ?? 0,
    );
    await _deps.transactor.run(() => _deps.debts.save(debt));
    return Ok(debt);
  }
}

/// BR-110: qarzni arxivlash (ro'yxat va jamlarda ko'rinmaydi) yoki qaytarish.
final class SetDebtArchived {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Debt>> call(String id, {required bool archived}) async {
    final debt = await _deps.debts.byId(id);
    if (debt == null || debt.deletedAt != null) {
      return _invalid('debt', 'debt_not_found');
    }
    final updated = debt.copyWith(
      archivedAt: archived ? debt.archivedAt ?? _deps.clock.now() : null,
    );
    await _deps.transactor.run(() => _deps.debts.save(updated));
    return Ok(updated);
  }
}

/// BR-120, BR-122: maqsad maydonlari.
@immutable
final class GoalInput {
  const new({
    required this.name,
    required this.target,
    this.savedManual,
    this.monthlyContribution,
    this.deadline,
    this.accountId,
  });

  final String name;
  final Money target;

  /// Hisobga bog'lanmaganda — qo'lda (standart 0).
  final Money? savedManual;
  final Money? monthlyContribution;
  final MonthKey? deadline;

  /// Bog'langan hisob (valyutasi maqsadniki bilan bir xil).
  final String? accountId;
}

/// BR-120: maqsad qo'shish (`id` berilmasa) yoki tahrirlash.
final class SaveGoal {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Goal>> call(GoalInput input, {String? id}) async {
    final name = _validName(input.name);
    if (name == null) return _invalid('name', 'invalid_name');
    final target = input.target;
    final saved = input.savedManual ?? Money(0, target.currency);
    if (!target.isPositive) return _invalid('target', 'invalid_amount');
    if (saved.isNegative) return _invalid('saved', 'invalid_amount');
    if (input.monthlyContribution case final monthly?
        when !monthly.isPositive) {
      return _invalid('monthly', 'invalid_amount');
    }
    if (input.accountId case final accountId?) {
      final account = await _deps.accounts.byId(accountId);
      if (account == null || account.deletedAt != null) {
        return _invalid('account', 'account_not_found');
      }
      if (account.currency != target.currency) {
        return _invalid('account', 'currency_mismatch');
      }
    }

    final existing = id == null ? null : await _deps.goals.byId(id);
    if (id != null && (existing == null || existing.deletedAt != null)) {
      return _invalid('goal', 'goal_not_found');
    }
    final same = await _deps.goals.byName(name);
    if (same != null && same.id != id) {
      return _invalid('name', 'duplicate_name');
    }
    final household = await _deps.households.current();
    final goal = Goal(
      id: existing?.id ?? _deps.ids.newId(),
      householdId: household.id,
      name: name,
      target: target,
      savedManual: saved,
      monthlyContribution: input.monthlyContribution,
      deadline: input.deadline,
      accountId: input.accountId,
      sortOrder: existing?.sortOrder ?? 0,
      achievedAt: existing?.achievedAt,
      rowVersion: existing?.rowVersion ?? 0,
    );
    await _deps.transactor.run(() => _deps.goals.save(goal));
    return Ok(goal);
  }
}

/// Maqsadni o'chirish (soft delete).
final class DeleteGoal {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Goal>> call(String id) async {
    final goal = await _deps.goals.byId(id);
    if (goal == null || goal.deletedAt != null) {
      return _invalid('goal', 'goal_not_found');
    }
    final deleted = goal.copyWith(deletedAt: _deps.clock.now());
    await _deps.transactor.run(() => _deps.goals.save(deleted));
    return Ok(deleted);
  }
}

/// BR-123: maqsad yig'ildi — tabrik bir marta ko'rsatiladi (`achieved_at`).
final class MarkGoalAchieved {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Goal>> call(String id) async {
    final goal = await _deps.goals.byId(id);
    if (goal == null || goal.deletedAt != null) {
      return _invalid('goal', 'goal_not_found');
    }
    if (goal.achievedAt != null) return Ok(goal);
    final achieved = goal.copyWith(achievedAt: _deps.clock.now());
    await _deps.transactor.run(() => _deps.goals.save(achieved));
    return Ok(achieved);
  }
}

/// BR-130: xarajat kategoriyasining oylik limiti (asosiy valyutada);
/// `amount` null — limit olib tashlanadi. Kategoriyada bittadan.
final class SetCategoryLimit {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<CategoryLimit?>> call(
    String categoryId, {
    required Money? amount,
    bool? rollover,
    bool? rolloverNegative,
  }) async {
    if (amount != null && !amount.isPositive) {
      return _invalid('amount', 'invalid_amount');
    }
    final category = await _deps.categories.byId(categoryId);
    if (category == null || category.deletedAt != null) {
      return _invalid('category', 'category_not_found');
    }
    if (category.kind != CategoryKind.expense) {
      return _invalid('category', 'category_kind_mismatch');
    }
    final current = await _deps.limits.forCategory(categoryId);
    if (amount == null) {
      if (current == null) return const Ok(null);
      final removed = current.copyWith(deletedAt: _deps.clock.now());
      await _deps.transactor.run(() => _deps.limits.save(removed));
      return const Ok(null);
    }
    final household = await _deps.households.current();
    final carry = rollover ?? current?.rollover ?? false;
    // BR-134: manfiy qoldiq faqat rollover yoqilganda ma'noga ega.
    final carryNegative =
        carry && (rolloverNegative ?? current?.rolloverNegative ?? false);
    final limit =
        current?.copyWith(
          amount: amount,
          rollover: carry,
          rolloverNegative: carryNegative,
        ) ??
        CategoryLimit(
          id: _deps.ids.newId(),
          householdId: household.id,
          categoryId: categoryId,
          amount: amount,
          rollover: carry,
          rolloverNegative: carryNegative,
        );
    await _deps.transactor.run(() => _deps.limits.save(limit));
    return Ok(limit);
  }
}
