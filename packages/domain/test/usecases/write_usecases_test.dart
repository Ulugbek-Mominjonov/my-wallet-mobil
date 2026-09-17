import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';
import '../support/fake_writer.dart';

void main() {
  const personal = "o'zim uchun";
  final now = DateTime(2026, 9, 16, 10, 30);
  late FakeWriter writer;
  late Clock clock;
  late IdGenerator ids;

  setUp(() {
    writer = FakeWriter();
    clock = FixedClock(now);
    ids = SeqIds();
  });

  group("daromad qo'shish", () {
    test('tegishli oy qoidadan hisoblanadi va bitta batchda yoziladi',
        () async {
      final income = await AddIncome(
        writer: writer,
        clock: clock,
        ids: ids,
      ).call(
        amount: const Money(12000000),
        type: 'Oylik',
        method: PaymentMethod.card,
        paidAt: DateTime(2026, 9, 2),
        rules: IncomeRules.defaults,
      );

      expect(income.monthKey, const MonthKey('2026-08'));
      expect(writer.batchCount, 1);
      expect(writer.last.mutations.single, isA<UpsertIncome>());
      expect(
        writer.last.delta.months[const MonthKey('2026-08')]!.income,
        const Money(12000000),
      );
      expect(writer.last.operationCount, 3, reason: '1 hujjat + oy + totals');
    });

    test('manfiy summa rad etiladi', () async {
      await expectLater(
        AddIncome(writer: writer, clock: clock, ids: ids).call(
          amount: const Money(-5),
          type: 'Oylik',
          method: PaymentMethod.card,
          paidAt: now,
          rules: IncomeRules.defaults,
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(writer.batchCount, 0, reason: "xato bo'lsa yozilmaydi");
    });

    test("bo'sh tur rad etiladi", () async {
      await expectLater(
        AddIncome(writer: writer, clock: clock, ids: ids).call(
          amount: const Money(100),
          type: '   ',
          method: PaymentMethod.card,
          paidAt: now,
          rules: IncomeRules.defaults,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('xarajat', () {
    test("reja ham, fakt ham bo'lmasa rad etiladi", () async {
      await expectLater(
        AddExpense(
          writer: writer,
          clock: clock,
          ids: ids,
          personalCategoryKey: personal,
        ).call(
          name: 'Nonushta',
          category: 'Oziq-ovqat',
          method: PaymentMethod.cash,
          dueDate: now,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test("qo'lda oy belgilansa manba manual bo'ladi", () async {
      final expense = await AddExpense(
        writer: writer,
        clock: clock,
        ids: ids,
        personalCategoryKey: personal,
      ).call(
        name: "Mashina to'lovi",
        category: 'Qarz',
        method: PaymentMethod.card,
        dueDate: DateTime(2026, 10, 5),
        planned: const Money(5300000),
        manualMonth: const MonthKey('2026-09'),
      );
      expect(expense.monthKey, const MonthKey('2026-09'));
      expect(expense.monthKeySource, MonthKeySource.manual);
      expect(expense.status, PaymentStatus.pending);
    });

    test('tahrirda oy avtomatik qayta hisoblanadi', () async {
      final before = Build.expense(
        planned: 100,
        dueDate: DateTime(2026, 9, 10),
      );
      final after = await EditExpense(
        writer: writer,
        clock: clock,
        personalCategoryKey: personal,
      ).call(before: before, dueDate: DateTime(2026, 10, 3));
      expect(after.monthKey, const MonthKey('2026-10'));
      expect(writer.last.delta.months.length, 2);
    });
  });

  group("to'lovni belgilash", () {
    test('summa berilmasa reja ishlatiladi', () async {
      final expense = Build.expense(planned: 300000);
      final after = await MarkExpensePaid(
        writer: writer,
        clock: clock,
        personalCategoryKey: personal,
      ).call(expense);
      expect(after.actual, const Money(300000));
      expect(after.status, PaymentStatus.paid);
    });

    test("rejasi yo'q to'lovda summa talab qilinadi", () async {
      await expectLater(
        MarkExpensePaid(
          writer: writer,
          clock: clock,
          personalCategoryKey: personal,
        ).call(Build.expense(planned: null)),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test("ikki marta to'lash mumkin emas", () async {
      await expectLater(
        MarkExpensePaid(
          writer: writer,
          clock: clock,
          personalCategoryKey: personal,
        ).call(Build.expense(planned: 100, actual: 100)),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test("DoD: 40 ta to'lovni belgilash = 1 batch, agregat 1 marta", () async {
      final items = <Expense, Money?>{
        for (var i = 0; i < 40; i++)
          Build.expense(id: 'e$i', planned: 100000): null,
      };
      final updated = await MarkExpensePaid(
        writer: writer,
        clock: clock,
        personalCategoryKey: personal,
      ).many(items);

      expect(updated.length, 40);
      expect(writer.batchCount, 1);
      expect(writer.last.mutations.length, 40);
      expect(
        writer.last.delta.documentCount,
        2,
        reason: '1 oy hujjati + 1 totals',
      );
      expect(
        writer.last.delta.months[const MonthKey('2026-09')]!.expense,
        const Money(4000000),
      );
    });
  });

  group('shaxsiy fond', () {
    test('sarf byudjet xarajatiga tegmaydi', () async {
      await AddPersonalSpend(writer: writer, clock: clock, ids: ids).call(
        amount: const Money(200000),
        purpose: 'Kitob',
        method: PaymentMethod.cash,
        spentAt: now,
      );
      expect(writer.last.delta.totals.expense, Money.zero);
      expect(writer.last.delta.totals.personalSpent, const Money(200000));
    });
  });

  group("qoida o'zgarishi (recalcMonthKeys)", () {
    test("preview ko'chadigan yozuvlarni sanaydi, hech narsa yozmaydi", () {
      final usecase = RecalcMonthKeys(writer: writer, clock: clock);
      final moves = usecase.preview(
        <Income>[
          Build.income(paidAt: DateTime(2026, 9, 2)),
          Build.income(id: 'i2', type: 'Avans', paidAt: DateTime(2026, 9, 16)),
        ],
        IncomeRules.defaults,
      );
      expect(moves.length, 1);
      expect(moves.single.from, const MonthKey('2026-09'));
      expect(moves.single.to, const MonthKey('2026-08'));
      expect(writer.batchCount, 0);
    });

    test("apply ikkala oyni bitta batchda to'g'rilaydi", () async {
      final usecase = RecalcMonthKeys(writer: writer, clock: clock);
      final moves = usecase.preview(
        <Income>[
          Build.income(
            amount: 500,
            paidAt: DateTime(2026, 9, 2),
          ),
        ],
        IncomeRules.defaults,
      );
      expect(await usecase.apply(moves), 1);
      expect(writer.batchCount, 1);
      final delta = writer.last.delta;
      expect(
        delta.months[const MonthKey('2026-09')]!.income,
        const Money(-500),
      );
      expect(
        delta.months[const MonthKey('2026-08')]!.income,
        const Money(500),
      );
      expect(delta.totals.isEmpty, isTrue);
    });
  });

  group("kunlik skan (avto to'lov)", () {
    test("faqat o'zgargan yozuvlar yoziladi", () async {
      final sweep = RunPaymentSweep(
        writer: writer,
        clock: clock,
        personalCategoryKey: personal,
      );
      final changed = await sweep.call(<Expense>[
        Build.expense(
          planned: 100000,
          dueDate: DateTime(2026, 9, 10),
          autoPay: true,
        ),
        Build.expense(
          id: 'e2',
          planned: 100000,
          actual: 100000,
          dueDate: DateTime(2026, 9, 10),
        ).copyWith(status: PaymentStatus.paid),
      ]);
      expect(changed, 1);
      expect(writer.last.mutations.length, 1);
      expect(
        writer.last.delta.months[const MonthKey('2026-09')]!.expense,
        const Money(100000),
      );
    });
  });

  group('batch chegarasi', () {
    test("katta operatsiya 400 amaldan oshmaydigan batchlarga bo'linadi", () {
      final commands = BatchChunker.split(<MutationWithDelta>[
        for (var i = 0; i < 1000; i++)
          (
            mutation: UpsertExpense(Build.expense(id: 'e$i', actual: 100)),
            delta: AggregateDelta.forExpense(
              personalCategoryKey: personal,
              after: Build.expense(id: 'e$i', actual: 100),
            ),
          ),
      ]);
      expect(commands.length, greaterThan(1));
      for (final command in commands) {
        expect(command.operationCount, lessThanOrEqualTo(400));
      }
      expect(
        commands.fold<int>(
          0,
          (total, command) => total + command.mutations.length,
        ),
        1000,
      );
    });
  });

  group("tahrirlash va o'chirish", () {
    test('daromad tahrirlanganda oy qayta hisoblanadi', () async {
      final before = Build.income(
        amount: 1000,
        type: 'Avans',
        paidAt: DateTime(2026, 9, 16),
      );
      final after = await EditIncome(writer: writer, clock: clock).call(
        before: before,
        rules: IncomeRules.defaults,
        type: 'Oylik',
        amount: const Money(1200),
        method: PaymentMethod.cash,
        note: ' izoh ',
        debtId: 'd2',
      );
      expect(after.monthKey, const MonthKey('2026-08'));
      expect(after.note, 'izoh');
      expect(after.debtId, 'd2');
      final delta = writer.last.delta;
      expect(delta.months.length, 2);
      expect(delta.totals.income, const Money(200));
      expect(delta.debts['d2']!.fromIncomes, const Money(1200));
    });

    test("daromad o'chirilsa agregatdan ayiriladi", () async {
      await RemoveIncome(writer).call(Build.income(amount: 1000));
      expect(writer.last.mutations.single, isA<DeleteIncome>());
      expect(writer.last.delta.totals.income, const Money(-1000));
    });

    test("xarajat o'chirilsa agregatdan ayiriladi", () async {
      await RemoveExpense(
        writer: writer,
        personalCategoryKey: personal,
      ).call(Build.expense(planned: 100, actual: 100));
      expect(writer.last.mutations.single, isA<DeleteExpense>());
      expect(writer.last.delta.totals.expense, const Money(-100));
    });

    test("shaxsiy sarf tahrirlanadi va o'chiriladi", () async {
      final before = Build.personalSpend();
      final after = await EditPersonalSpend(
        writer: writer,
        clock: clock,
      ).call(
        before: before,
        amount: const Money(250000),
        purpose: "Sovg'a",
        method: PaymentMethod.card,
        spentAt: DateTime(2026, 10, 2),
        note: 'izoh',
      );
      expect(after.monthKey, const MonthKey('2026-10'));
      expect(writer.last.delta.months.length, 2);

      await RemovePersonalSpend(writer).call(after);
      expect(writer.last.mutations.single, isA<DeletePersonalSpend>());
      expect(writer.last.delta.totals.personalSpent, const Money(-250000));
    });

    test('WriteCommand birlashtiriladi', () {
      final first = WriteCommand(
        mutations: <DocMutation>[UpsertExpense(Build.expense())],
        delta: AggregateDelta.forExpense(
          personalCategoryKey: personal,
          after: Build.expense(actual: 100),
        ),
      );
      final merged = first + const WriteCommand();
      expect(merged.mutations.length, 1);
      expect(merged.isEmpty, isFalse);
      expect(const WriteCommand().isEmpty, isTrue);
      expect(merged.toString(), contains('hujjat'));
    });

    test('SystemClock haqiqiy vaqtni beradi', () {
      final difference =
          DateTime.now().difference(const SystemClock().now()).abs();
      expect(difference.inSeconds, lessThan(5));
    });
  });
}
