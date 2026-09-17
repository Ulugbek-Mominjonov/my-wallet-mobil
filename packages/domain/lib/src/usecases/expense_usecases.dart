import '../calc/delta_calc.dart';
import '../calc/month_attribution.dart';
import '../calc/payment_status_calc.dart';
import '../entities/entity_support.dart';
import '../entities/expense.dart';
import '../repositories/clock.dart';
import '../repositories/errors.dart';
import '../repositories/id_generator.dart';
import '../repositories/write_command.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';
import 'validation.dart';

/// Yangi xarajat qo'shadi.
final class AddExpense {
  const AddExpense({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
    required String personalCategoryKey,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;
  final String _personalCategoryKey;

  Future<Expense> call({
    required String name,
    required String category,
    required PaymentMethod method,
    required DateTime dueDate,
    Money? planned,
    Money? actual,
    MonthKey? manualMonth,
    String? debtId,
    String? recurringId,
    bool autoPay = false,
    String note = '',
  }) async {
    if (planned == null && actual == null) {
      throw const ValidationFailure(
        'summa',
        "Reja yoki fakt summasidan kamida bittasi to'ldirilsin",
      );
    }
    final now = _clock.now();
    final expense = Expense(
      id: _ids.next(),
      name: Validate.text(name, 'nom'),
      category: Validate.text(category, 'kategoriya'),
      method: method,
      planned: planned == null ? null : Validate.amount(planned, 'reja'),
      actual: actual == null ? null : Validate.positiveAmount(actual, 'fakt'),
      dueDate: dueDate,
      monthKey: MonthAttribution.forExpense(
        dueDate: dueDate,
        manualMonth: manualMonth,
      ),
      monthKeySource:
          manualMonth == null ? MonthKeySource.auto : MonthKeySource.manual,
      status: PaymentStatusCalc.compute(
        planned: planned,
        actual: actual,
        dueDate: dueDate,
        today: now,
      ),
      debtId: Validate.optionalText(debtId),
      recurringId: Validate.optionalText(recurringId),
      autoPay: autoPay,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertExpense(expense)],
        delta: AggregateDelta.forExpense(
          personalCategoryKey: _personalCategoryKey,
          after: expense,
        ),
      ),
    );
    return expense;
  }
}

/// Xarajatni tahrirlaydi — oy, summa, kategoriya o'zgarsa ham agregat
/// bitta batchda to'g'rilanadi.
final class EditExpense {
  const EditExpense({
    required BudgetWriter writer,
    required Clock clock,
    required String personalCategoryKey,
  })  : _writer = writer,
        _clock = clock,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final Clock _clock;
  final String _personalCategoryKey;

  Future<Expense> call({
    required Expense before,
    String? name,
    String? category,
    PaymentMethod? method,
    Object? planned = unchanged,
    Object? actual = unchanged,
    DateTime? dueDate,
    Object? manualMonth = unchanged,
    Object? debtId = unchanged,
    bool? autoPay,
    String? note,
  }) async {
    final now = _clock.now();
    final nextDueDate = dueDate ?? before.dueDate;
    final hasMonthChange = !identical(manualMonth, unchanged);
    final nextManual = hasMonthChange
        ? manualMonth as MonthKey?
        : (before.monthKeySource == MonthKeySource.manual
            ? before.monthKey
            : null);

    var after = before.copyWith(
      name: name == null ? null : Validate.text(name, 'nom'),
      category:
          category == null ? null : Validate.text(category, 'kategoriya'),
      method: method,
      planned: planned,
      actual: actual,
      dueDate: nextDueDate,
      monthKey: MonthAttribution.forExpense(
        dueDate: nextDueDate,
        manualMonth: nextManual,
      ),
      monthKeySource:
          nextManual == null ? MonthKeySource.auto : MonthKeySource.manual,
      debtId: debtId,
      autoPay: autoPay,
      note: note?.trim(),
      updatedAt: now,
    );
    after = after.copyWith(status: PaymentStatusCalc.of(after, now));

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertExpense(after)],
        delta: AggregateDelta.forExpense(
          personalCategoryKey: _personalCategoryKey,
          before: before,
          after: after,
        ),
      ),
    );
    return after;
  }
}

/// Xarajatni o'chiradi.
final class RemoveExpense {
  const RemoveExpense({
    required BudgetWriter writer,
    required String personalCategoryKey,
  })  : _writer = writer,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final String _personalCategoryKey;

  Future<void> call(Expense expense) => _writer.commit(
        WriteCommand(
          mutations: <DocMutation>[DeleteExpense(expense.id)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: _personalCategoryKey,
            before: expense,
          ),
        ),
      );
}

/// To'lovni "to'landi" deb belgilaydi (`tolovniBelgila`).
///
/// Summa berilmasa reja ishlatiladi; rejasi ham yo'q bo'lsa foydalanuvchidan
/// summa so'raladi — Sheets'dagi xulqning aynan o'zi.
final class MarkExpensePaid {
  const MarkExpensePaid({
    required BudgetWriter writer,
    required Clock clock,
    required String personalCategoryKey,
  })  : _writer = writer,
        _clock = clock,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final Clock _clock;
  final String _personalCategoryKey;

  Future<Expense> call(Expense expense, {Money? amount}) async {
    if (expense.isPaid) {
      throw const ConflictFailure(
        "Bu to'lov allaqachon to'langan deb belgilangan",
      );
    }
    final paid = amount ?? expense.planned;
    if (paid == null || !paid.isPositive) {
      throw const ValidationFailure(
        'summa',
        "Bu to'lovning summasi belgilanmagan — qancha to'laganingizni kiriting",
      );
    }
    final after = _apply(expense, paid, _clock.now());
    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertExpense(after)],
        delta: AggregateDelta.forExpense(
          personalCategoryKey: _personalCategoryKey,
          before: expense,
          after: after,
        ),
      ),
    );
    return after;
  }

  /// ★ Bir nechta to'lovni BITTA batchda belgilaydi (admin paneldagi
  /// "bulk to'landi"): 40 ta to'lov = 1 batch, agregat bir marta yangilanadi.
  Future<List<Expense>> many(Map<Expense, Money?> items) async {
    if (items.isEmpty) return const <Expense>[];
    final now = _clock.now();
    final mutations = <DocMutation>[];
    final deltas = <AggregateDelta>[];
    final result = <Expense>[];

    for (final entry in items.entries) {
      final expense = entry.key;
      if (expense.isPaid) continue;
      final paid = entry.value ?? expense.planned;
      if (paid == null || !paid.isPositive) continue;
      final after = _apply(expense, paid, now);
      mutations.add(UpsertExpense(after));
      deltas.add(
        AggregateDelta.forExpense(
          personalCategoryKey: _personalCategoryKey,
          before: expense,
          after: after,
        ),
      );
      result.add(after);
    }

    if (mutations.isEmpty) return const <Expense>[];
    await _writer.commit(
      WriteCommand(
        mutations: mutations,
        delta: AggregateDelta.merge(deltas),
      ),
    );
    return result;
  }

  static Expense _apply(Expense expense, Money paid, DateTime now) {
    final after = expense.copyWith(actual: paid, updatedAt: now);
    return after.copyWith(status: PaymentStatusCalc.of(after, now));
  }
}
