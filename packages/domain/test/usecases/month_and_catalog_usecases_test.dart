import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';
import '../support/fake_repositories.dart';
import '../support/fake_writer.dart';

void main() {
  const personal = "o'zim uchun";
  final now = DateTime(2026, 9, 28);
  late FakeWriter writer;
  late Clock clock;
  late IdGenerator ids;

  setUp(() {
    writer = FakeWriter();
    clock = FixedClock(now);
    ids = SeqIds();
  });

  OpenMonth openMonth({
    List<RecurringExpense> recurring = const <RecurringExpense>[],
    List<Expense> existing = const <Expense>[],
    List<MonthSummary> months = const <MonthSummary>[],
  }) =>
      OpenMonth(
        writer: writer,
        clock: clock,
        ids: ids,
        expenses: FakeExpenseRepository(existing),
        settings: FakeSettingsRepository(recurring: recurring),
        months: FakeMonthRepository(summaries: months),
        personalCategoryKey: personal,
      );

  group('yangi oy ochish', () {
    test('doimiy xarajatlar bitta batchda yoziladi', () async {
      final plan = await openMonth(
        recurring: <RecurringExpense>[
          Build.recurring(),
          Build.recurring(id: 'r2', name: 'Ijara', amount: 3000000, order: 1),
        ],
        months: <MonthSummary>[
          const MonthSummary(
            monthKey: MonthKey('2026-10'),
            income: Money(12000000),
          ),
        ],
      ).call(const MonthKey('2026-10'));

      expect(plan.created.length, 3);
      expect(writer.batchCount, 1);
      expect(writer.last.mutations.length, 3);
      final delta = writer.last.delta.months[const MonthKey('2026-10')]!;
      expect(delta.planned, const Money(4400000));
      expect(
        delta.unpaidTotal,
        const Money(4400000),
        reason: "yangi qatorlar hali to'lanmagan",
      );
      expect(delta.expense, Money.zero);
    });

    test('takroran chaqirilsa hech narsa yozilmaydi', () async {
      final plan = await openMonth(
        recurring: <RecurringExpense>[Build.recurring()],
        existing: <Expense>[
          Build.expense(
            id: 'x1',
            name: 'Internet',
            monthKey: '2026-10',
            dueDate: DateTime(2026, 10, 5),
          ),
          Build.expense(
            id: 'x2',
            name: "O'zim uchun (ajratma)",
            category: "O'zim uchun",
            monthKey: '2026-10',
            dueDate: DateTime(2026, 10),
          ),
        ],
      ).call(const MonthKey('2026-10'));

      expect(plan.isEmpty, isTrue);
      expect(plan.skipped, 2);
      expect(writer.batchCount, 0);
    });
  });

  group('oyni yopish', () {
    test('yopish va qayta ochish', () async {
      final lock = SetMonthLock(writer);
      await lock.call(const MonthKey('2026-08'), closed: true);
      await lock.call(const MonthKey('2026-08'), closed: false);

      expect(writer.batchCount, 2);
      final first = writer.commands.first.mutations.single as SetMonthClosed;
      final second = writer.commands.last.mutations.single as SetMonthClosed;
      expect(first.closed, isTrue);
      expect(second.closed, isFalse);
      expect(writer.commands.first.delta.isEmpty, isTrue);
    });
  });

  group('qarz va maqsad', () {
    test('qarz saqlanadi, hisoblagichlar tegilmaydi', () async {
      final existing = Build.debt(
        paidFromExpenses: 5000000,
        pendingFromApp: 100,
      );
      final debt = await SaveDebt(writer: writer, clock: clock, ids: ids).call(
        name: 'Mashina',
        direction: DebtDirection.iOwe,
        total: const Money(60000000),
        existing: existing,
        monthly: const Money(5000000),
      );
      expect(debt.id, existing.id);
      expect(debt.paidFromExpenses, const Money(5000000));
      expect(debt.pendingFromApp, const Money(100));
      final mutation = writer.last.mutations.single as UpsertDebt;
      expect(mutation.includeCounters, isFalse);
      expect(writer.last.delta.isEmpty, isTrue);
    });

    test("qarz summasi musbat bo'lishi shart", () async {
      await expectLater(
        SaveDebt(writer: writer, clock: clock, ids: ids).call(
          name: 'Qarz',
          direction: DebtDirection.iOwe,
          total: Money.zero,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test("maqsad saqlanadi va o'chiriladi", () async {
      final goal = await SaveGoal(writer: writer, clock: clock, ids: ids).call(
        name: 'Sayohat',
        target: const Money(20000000),
        saved: const Money(1000000),
      );
      expect(goal.id, 'id1');
      await RemoveGoal(writer).call(goal);
      expect(writer.batchCount, 2);
      expect(writer.last.mutations.single, isA<DeleteGoal>());
    });

    test("qarz o'chiriladi", () async {
      await RemoveDebt(writer).call(Build.debt());
      expect(writer.last.mutations.single, isA<DeleteDebt>());
    });
  });

  group('🩺 reconciler usecase', () {
    test('drift topilsa mutlaq qiymat bilan tuzatadi', () async {
      final reconcile = ReconcileMonth(
        writer: writer,
        personalCategoryKey: personal,
      );
      final result = reconcile.check(
        stored: const MonthSummary(
          monthKey: MonthKey('2026-09'),
          income: Money(999),
        ),
        incomes: <Income>[Build.income(amount: 1000)],
        expenses: const <Expense>[],
        personalSpends: const <PersonalSpend>[],
      );

      expect(result.isClean, isFalse);
      expect(result.computed.income, const Money(1000));

      await reconcile.fix(<ReconcileResult>[result]);
      final mutation =
          writer.last.mutations.single as OverwriteMonthAggregate;
      expect(mutation.summary.income, const Money(1000));
    });

    test("toza bo'lsa hech narsa yozilmaydi", () async {
      final reconcile = ReconcileMonth(
        writer: writer,
        personalCategoryKey: personal,
      );
      final result = reconcile.check(
        stored: MonthSummaryCalc.build(
          monthKey: const MonthKey('2026-09'),
          personalCategoryKey: personal,
          incomes: <Income>[Build.income(amount: 1000)],
        ),
        incomes: <Income>[Build.income(amount: 1000)],
        expenses: const <Expense>[],
        personalSpends: const <PersonalSpend>[],
      );
      expect(result.isClean, isTrue);
      await reconcile.fix(<ReconcileResult>[result]);
      expect(writer.batchCount, 0);
    });
  });
}
