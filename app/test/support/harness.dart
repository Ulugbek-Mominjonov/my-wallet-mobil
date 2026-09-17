import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oylik_byudjet/core/theme/app_theme.dart';
import 'package:oylik_byudjet/di/providers.dart';
import 'package:oylik_byudjet/di/state_providers.dart';

/// Testlar uchun yozuv porti — Firebase'siz.
final class RecordingWriter implements BudgetWriter {
  final List<WriteCommand> commands = <WriteCommand>[];

  @override
  Future<void> commit(WriteCommand command) async {
    commands.add(command);
  }
}

final class FixedIds implements IdGenerator {
  int _counter = 0;

  @override
  String next() => 'id${++_counter}';
}

/// Ekranni izolyatsiyada ishga tushiradi: Firebase providerlari umuman
/// yaratilmaydi, chunki ulardan yuqoridagi barcha providerlar
/// override qilingan.
Widget harness({
  required Widget child,
  required DateTime now,
  MonthSummary? summary,
  OverallTotals totals = const OverallTotals(),
  List<MonthSummary> months = const <MonthSummary>[],
  List<Expense> unpaid = const <Expense>[],
  List<CategoryLimit> limits = const <CategoryLimit>[],
  List<Debt> debts = const <Debt>[],
  List<Goal> goals = const <Goal>[],
  List<PersonalSpend> spends = const <PersonalSpend>[],
  List<QuickAdd> quickAdds = const <QuickAdd>[],
  BudgetSettings settings = const BudgetSettings(),
  BudgetWriter? writer,
}) =>
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        idGeneratorProvider.overrideWithValue(FixedIds()),
        if (writer != null) writerProvider.overrideWithValue(writer),
        settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
        monthSummaryProvider.overrideWith(
          (ref) => Stream<MonthSummary>.value(
            summary ?? MonthSummary.empty(MonthKey.of(now)),
          ),
        ),
        totalsProvider.overrideWith((ref) => Stream.value(totals)),
        monthsProvider.overrideWith((ref) => Stream.value(months)),
        unpaidExpensesProvider.overrideWith((ref) => Stream.value(unpaid)),
        limitsProvider.overrideWith((ref) => Stream.value(limits)),
        debtsProvider.overrideWith((ref) => Stream.value(debts)),
        goalsProvider.overrideWith((ref) => Stream.value(goals)),
        monthPersonalSpendsProvider.overrideWith(
          (ref) => Stream.value(spends),
        ),
        quickAddsProvider.overrideWith((ref) => Stream.value(quickAdds)),
        categoriesProvider.overrideWith(
          (ref) => Stream.value(const <CategoryDef>[]),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: child,
      ),
    );
