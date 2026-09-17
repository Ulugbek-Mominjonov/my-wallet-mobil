import 'package:meta/meta.dart';

import '../calc/delta_calc.dart';
import '../calc/month_attribution.dart';
import '../calc/month_summary_calc.dart';
import '../calc/payment_status_calc.dart';
import '../calc/reconcile_calc.dart';
import '../entities/expense.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/personal_spend.dart';
import '../entities/settings.dart';
import '../repositories/clock.dart';
import '../repositories/write_command.dart';
import '../value_objects/month_key.dart';
import 'batch_chunker.dart';

/// Qoida o'zgarganda ko'chadigan bitta yozuv.
@immutable
final class IncomeMove {
  const IncomeMove({required this.before, required this.after});

  final Income before;
  final Income after;

  MonthKey get from => before.monthKey;

  MonthKey get to => after.monthKey;

  @override
  String toString() => 'IncomeMove(${before.id}: $from → $to)';
}

/// §6.5 — daromad qoidasi o'zgarganda eski yozuvlarni qayta joylaydi.
///
/// Avval PREVIEW ko'rsatiladi ("nechta yozuv ko'chadi"), keyin foydalanuvchi
/// tasdiqlagach batch bilan qo'llanadi.
final class RecalcMonthKeys {
  const RecalcMonthKeys({required BudgetWriter writer, required Clock clock})
      : _writer = writer,
        _clock = clock;

  final BudgetWriter _writer;
  final Clock _clock;

  /// Hech narsa yozmaydi — faqat qaysi yozuvlar ko'chishini hisoblaydi.
  List<IncomeMove> preview(
    Iterable<Income> incomes,
    IncomeRules rules,
  ) {
    final now = _clock.now();
    final moves = <IncomeMove>[];
    for (final income in incomes) {
      final month = MonthAttribution.forIncome(
        paidAt: income.paidAt,
        type: income.type,
        rules: rules,
      );
      if (month == income.monthKey) continue;
      moves.add(
        IncomeMove(
          before: income,
          after: income.copyWith(monthKey: month, updatedAt: now),
        ),
      );
    }
    return moves;
  }

  /// Ko'chirishni qo'llaydi — 400 amaldan oshmaydigan batchlarga bo'linadi.
  Future<int> apply(List<IncomeMove> moves) async {
    if (moves.isEmpty) return 0;
    final commands = BatchChunker.split(<MutationWithDelta>[
      for (final move in moves)
        (
          mutation: UpsertIncome(move.after),
          delta: AggregateDelta.forIncome(
            before: move.before,
            after: move.after,
          ),
        ),
    ]);
    for (final command in commands) {
      await _writer.commit(command);
    }
    return moves.length;
  }
}

/// Kunlik skan: avto to'lovlar + holatni yangilash (`dailyPaymentSweep`).
///
/// Ilova ochilmasa ham ishlashi uchun serverda (cron) chaqiriladi.
final class RunPaymentSweep {
  const RunPaymentSweep({
    required BudgetWriter writer,
    required Clock clock,
    required String personalCategoryKey,
  })  : _writer = writer,
        _clock = clock,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final Clock _clock;
  final String _personalCategoryKey;

  /// Faqat HAQIQATAN o'zgargan yozuvlar yoziladi (ortiqcha yozuv yo'q).
  Future<int> call(Iterable<Expense> candidates) async {
    final now = _clock.now();
    final items = <MutationWithDelta>[];
    for (final expense in candidates) {
      final after = PaymentStatusCalc.applyAutoPay(expense, now);
      if (after == expense) continue;
      items.add(
        (
          mutation: UpsertExpense(after.copyWith(updatedAt: now)),
          delta: AggregateDelta.forExpense(
            personalCategoryKey: _personalCategoryKey,
            before: expense,
            after: after,
          ),
        ),
      );
    }
    if (items.isEmpty) return 0;
    for (final command in BatchChunker.split(items)) {
      await _writer.commit(command);
    }
    return items.length;
  }
}

/// Bir oyning tekshiruv natijasi.
@immutable
final class ReconcileResult {
  const ReconcileResult({required this.drift, required this.computed});

  final MonthDrift drift;
  final MonthSummary computed;

  bool get isClean => drift.isClean;
}

/// §5.5 — 🩺 agregatni noldan hisoblab, farqni topadi va tuzatadi.
final class ReconcileMonth {
  const ReconcileMonth({
    required BudgetWriter writer,
    required String personalCategoryKey,
  })  : _writer = writer,
        _personalCategoryKey = personalCategoryKey;

  final BudgetWriter _writer;
  final String _personalCategoryKey;

  /// Xom yozuvlardan agregatni qayta quradi va saqlangani bilan solishtiradi.
  ReconcileResult check({
    required MonthSummary stored,
    required Iterable<Income> incomes,
    required Iterable<Expense> expenses,
    required Iterable<PersonalSpend> personalSpends,
  }) {
    final computed = MonthSummaryCalc.build(
      monthKey: stored.monthKey,
      personalCategoryKey: _personalCategoryKey,
      incomes: incomes,
      expenses: expenses,
      personalSpends: personalSpends,
      closed: stored.closed,
    );
    return ReconcileResult(
      drift: ReconcileCalc.compare(stored: stored, computed: computed),
      computed: computed,
    );
  }

  /// Topilgan farqni MUTLAQ qiymat bilan tuzatadi.
  Future<void> fix(Iterable<ReconcileResult> results) async {
    final dirty = results.where((result) => !result.isClean).toList();
    if (dirty.isEmpty) return;
    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[
          for (final result in dirty)
            OverwriteMonthAggregate(result.computed),
        ],
      ),
    );
  }
}
