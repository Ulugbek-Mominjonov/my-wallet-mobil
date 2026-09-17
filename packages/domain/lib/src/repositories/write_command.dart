import 'package:meta/meta.dart';

import '../calc/delta_calc.dart';
import '../entities/catalog.dart';
import '../entities/debt.dart';
import '../entities/expense.dart';
import '../entities/goal.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../entities/personal_spend.dart';
import '../entities/settings.dart';
import '../value_objects/month_key.dart';

/// Bitta hujjat ustidagi o'zgarish.
sealed class DocMutation {
  const DocMutation();
}

final class UpsertIncome extends DocMutation {
  const UpsertIncome(this.income);

  final Income income;
}

final class DeleteIncome extends DocMutation {
  const DeleteIncome(this.id);

  final String id;
}

final class UpsertExpense extends DocMutation {
  const UpsertExpense(this.expense);

  final Expense expense;
}

final class DeleteExpense extends DocMutation {
  const DeleteExpense(this.id);

  final String id;
}

final class UpsertPersonalSpend extends DocMutation {
  const UpsertPersonalSpend(this.spend);

  final PersonalSpend spend;
}

final class DeletePersonalSpend extends DocMutation {
  const DeletePersonalSpend(this.id);

  final String id;
}

final class UpsertDebt extends DocMutation {
  const UpsertDebt(this.debt, {this.includeCounters = false});

  final Debt debt;

  /// `paidFromExpenses` / `paidFromIncomes` / `pendingFromApp` — server
  /// tomonda `increment` bilan yuritiladi. Oddiy tahrirda ular YOZILMAYDI,
  /// aks holda eski qiymat yangisini bosib ketardi. Faqat reconciler
  /// va import ularni mutlaq qiymat bilan yozadi.
  final bool includeCounters;
}

final class DeleteDebt extends DocMutation {
  const DeleteDebt(this.id);

  final String id;
}

final class UpsertGoal extends DocMutation {
  const UpsertGoal(this.goal);

  final Goal goal;
}

final class DeleteGoal extends DocMutation {
  const DeleteGoal(this.id);

  final String id;
}

final class UpsertRecurring extends DocMutation {
  const UpsertRecurring(this.recurring);

  final RecurringExpense recurring;
}

final class DeleteRecurring extends DocMutation {
  const DeleteRecurring(this.id);

  final String id;
}

final class UpsertLimit extends DocMutation {
  const UpsertLimit(this.limit);

  final CategoryLimit limit;
}

final class DeleteLimit extends DocMutation {
  const DeleteLimit(this.id);

  final String id;
}

final class UpsertQuickAdd extends DocMutation {
  const UpsertQuickAdd(this.quickAdd);

  final QuickAdd quickAdd;
}

final class DeleteQuickAdd extends DocMutation {
  const DeleteQuickAdd(this.id);

  final String id;
}

final class SaveSettings extends DocMutation {
  const SaveSettings(this.settings);

  final BudgetSettings settings;
}

/// Oyni yopish / ochish.
final class SetMonthClosed extends DocMutation {
  const SetMonthClosed({required this.monthKey, required this.closed});

  final MonthKey monthKey;
  final bool closed;
}

/// Agregatni MUTLAQ qiymat bilan almashtirish — faqat reconciler ishlatadi.
final class OverwriteMonthAggregate extends DocMutation {
  const OverwriteMonthAggregate(this.summary);

  final MonthSummary summary;
}

/// `meta/totals` ni mutlaq qiymat bilan almashtirish — faqat reconciler.
final class OverwriteTotals extends DocMutation {
  const OverwriteTotals(this.totals);

  final OverallTotals totals;
}

/// ★ Bitta atomar yozuv: hujjat(lar) + agregat delta.
///
/// Data qatlami buni BITTA `WriteBatch` ga aylantiradi. `runTransaction`
/// ishlatilmaydi — u offline ishlamaydi (serverga murojaat talab qiladi),
/// `batch + increment` esa aviarejimda ham darhol qo'llanadi (§5.2).
@immutable
final class WriteCommand {
  const WriteCommand({
    this.mutations = const <DocMutation>[],
    this.delta = AggregateDelta.zero,
  });

  final List<DocMutation> mutations;
  final AggregateDelta delta;

  bool get isEmpty => mutations.isEmpty && delta.isEmpty;

  /// Batchdagi taxminiy operatsiyalar soni (Firestore chegarasi — 500).
  int get operationCount => mutations.length + delta.documentCount;

  WriteCommand operator +(WriteCommand other) => WriteCommand(
        mutations: <DocMutation>[...mutations, ...other.mutations],
        delta: delta + other.delta,
      );

  @override
  String toString() =>
      'WriteCommand(${mutations.length} hujjat, $operationCount amal)';
}

/// Yozuv porti — domen Firebase'ni bilmaydi, faqat shu interfeysni biladi.
abstract interface class BudgetWriter {
  /// Bitta atomar batch sifatida yozadi.
  Future<void> commit(WriteCommand command);
}
