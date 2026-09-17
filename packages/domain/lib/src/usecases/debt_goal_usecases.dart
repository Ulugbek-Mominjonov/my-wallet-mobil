import '../entities/debt.dart';
import '../entities/goal.dart';
import '../repositories/clock.dart';
import '../repositories/id_generator.dart';
import '../repositories/write_command.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import 'validation.dart';

/// 💳 Qarzni qo'shadi yoki tahrirlaydi.
///
/// Hisoblagichlar (`paidFromExpenses` ...) tegilmaydi — ular bog'langan
/// yozuvlar bilan birga `increment` orqali yuritiladi.
final class SaveDebt {
  const SaveDebt({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;

  Future<Debt> call({
    required String name,
    required DebtDirection direction,
    required Money total,
    Debt? existing,
    Money paidBefore = Money.zero,
    Money monthly = Money.zero,
    DateTime? dueDate,
    String note = '',
    bool archived = false,
  }) async {
    final now = _clock.now();
    final debt = Debt(
      id: existing?.id ?? _ids.next(),
      name: Validate.text(name, 'nom'),
      direction: direction,
      total: Validate.positiveAmount(total, 'umumiy'),
      paidBefore: Validate.amount(paidBefore, 'oldin'),
      monthly: Validate.amount(monthly, 'oylik'),
      paidFromExpenses: existing?.paidFromExpenses ?? Money.zero,
      paidFromIncomes: existing?.paidFromIncomes ?? Money.zero,
      pendingFromApp: existing?.pendingFromApp ?? Money.zero,
      dueDate: dueDate,
      note: note.trim(),
      archived: archived,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _writer.commit(
      WriteCommand(mutations: <DocMutation>[UpsertDebt(debt)]),
    );
    return debt;
  }
}

/// Qarzni o'chiradi.
final class RemoveDebt {
  const RemoveDebt(this._writer);

  final BudgetWriter _writer;

  Future<void> call(Debt debt) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[DeleteDebt(debt.id)]),
      );
}

/// 🎯 Maqsadni qo'shadi yoki tahrirlaydi.
final class SaveGoal {
  const SaveGoal({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;

  Future<Goal> call({
    required String name,
    required Money target,
    Goal? existing,
    Money saved = Money.zero,
    Money? monthly,
    DateTime? deadline,
    String note = '',
    int order = 0,
  }) async {
    final now = _clock.now();
    final goal = Goal(
      id: existing?.id ?? _ids.next(),
      name: Validate.text(name, 'nom'),
      target: Validate.positiveAmount(target, 'kerakli summa'),
      saved: Validate.amount(saved, "yig'ilgan"),
      monthly: monthly == null ? null : Validate.amount(monthly, 'oyiga'),
      deadline: deadline,
      note: note.trim(),
      order: order,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _writer.commit(
      WriteCommand(mutations: <DocMutation>[UpsertGoal(goal)]),
    );
    return goal;
  }
}

/// Maqsadni o'chiradi.
final class RemoveGoal {
  const RemoveGoal(this._writer);

  final BudgetWriter _writer;

  Future<void> call(Goal goal) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[DeleteGoal(goal.id)]),
      );
}
