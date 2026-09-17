import '../calc/delta_calc.dart';
import '../calc/month_open_calc.dart';
import '../repositories/clock.dart';
import '../repositories/id_generator.dart';
import '../repositories/repositories.dart';
import '../repositories/write_command.dart';
import '../value_objects/month_key.dart';
import 'batch_chunker.dart';

/// §2.11 — yangi oyni tayyorlaydi: doimiy xarajatlar + fond ajratmasi.
///
/// Idempotent: cron ham, foydalanuvchi ham chaqirishi mumkin.
final class OpenMonth {
  const OpenMonth({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
    required ExpenseRepository expenses,
    required SettingsRepository settings,
    required MonthRepository months,
    required String personalCategoryKey,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids,
        _expenses = expenses,
        _settings = settings,
        _months = months,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;
  final ExpenseRepository _expenses;
  final SettingsRepository _settings;
  final MonthRepository _months;
  final String _personalCategoryKey;

  Future<MonthOpenPlan> call(MonthKey month) async {
    final settings = await _settings.fetch();
    final recurring = await _settings.fetchRecurring();
    final existing = await _expenses.fetchMonthAll(month);
    final summary = await _months.fetch(month);

    final plan = MonthOpenCalc.plan(
      month: month,
      recurring: recurring,
      existing: existing,
      settings: settings,
      monthIncome: summary.income,
      now: _clock.now(),
      nextId: _ids.next,
    );
    if (plan.isEmpty) return plan;

    final commands = BatchChunker.split(<MutationWithDelta>[
      for (final expense in plan.created)
        (
          mutation: UpsertExpense(expense),
          delta: AggregateDelta.forExpense(
            personalCategoryKey: _personalCategoryKey,
            after: expense,
          ),
        ),
    ]);
    for (final command in commands) {
      await _writer.commit(command);
    }
    return plan;
  }
}

/// §2.12 — oyni yopish / qayta ochish.
///
/// Yopilgan oy yozuvlarini tahrirlashda ilova ogohlantiradi.
final class SetMonthLock {
  const SetMonthLock(this._writer);

  final BudgetWriter _writer;

  Future<void> call(MonthKey month, {required bool closed}) => _writer.commit(
        WriteCommand(
          mutations: <DocMutation>[
            SetMonthClosed(monthKey: month, closed: closed),
          ],
        ),
      );
}
