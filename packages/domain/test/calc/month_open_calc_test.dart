import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';
import '../support/fake_writer.dart';

void main() {
  const month = MonthKey('2026-10');
  final now = DateTime(2026, 9, 28, 9);
  const settings = BudgetSettings();

  MonthOpenPlan plan({
    List<RecurringExpense> recurring = const <RecurringExpense>[],
    List<Expense> existing = const <Expense>[],
    int monthIncome = 12000000,
    BudgetSettings config = settings,
  }) {
    final ids = SeqIds('new');
    return MonthOpenCalc.plan(
      month: month,
      recurring: recurring,
      existing: existing,
      settings: config,
      monthIncome: Money(monthIncome),
      now: now,
      nextId: ids.next,
    );
  }

  group('§2.11 yangi oy ochish', () {
    test("doimiy xarajatlar va fond ajratmasi ko'chiriladi", () {
      final result = plan(
        recurring: <RecurringExpense>[
          Build.recurring(),
          Build.recurring(
            id: 'r2',
            name: 'Ijara',
            amount: 3000000,
            day: 1,
            autoPay: true,
            order: 1,
          ),
        ],
      );

      expect(result.created.length, 3);
      expect(result.skipped, 0);
      final internet = result.created.first;
      expect(internet.name, 'Internet');
      expect(internet.dueDate, DateTime(2026, 10, 5));
      expect(internet.monthKey, month);
      expect(internet.recurringId, 'r1');
      expect(internet.source, EntrySource.recurring);
      expect(
        internet.monthKeySource,
        MonthKeySource.manual,
        reason: "to'lov sanasi surilsa ham qator shu oyga tegishli qoladi",
      );
      expect(result.created[1].autoPay, isTrue);
    });

    test("fond ajratmasi foizga ko'ra hisoblanadi", () {
      final result = plan(monthIncome: 12_345_678);
      final personal = result.created.last;
      expect(personal.category, "O'zim uchun");
      expect(personal.name, "O'zim uchun (ajratma)");
      expect(personal.planned, const Money(1_235_000));
      expect(personal.autoPay, isFalse);
    });

    test("IDEMPOTENT: mavjud nomlar qayta qo'shilmaydi", () {
      final result = plan(
        recurring: <RecurringExpense>[
          Build.recurring(),
          Build.recurring(id: 'r2', name: 'Ijara', order: 1),
        ],
        existing: <Expense>[
          Build.expense(
            id: 'old1',
            name: '  internet ',
            monthKey: '2026-10',
            dueDate: DateTime(2026, 10, 5),
          ),
          Build.expense(
            id: 'old2',
            name: "O'zim uchun (ajratma)",
            category: "O'zim uchun",
            monthKey: '2026-10',
            dueDate: DateTime(2026, 10),
          ),
        ],
      );
      expect(result.created.map((item) => item.name), <String>['Ijara']);
      expect(result.skipped, 2);
    });

    test("boshqa oydagi bir xil nom to'sqinlik qilmaydi", () {
      final result = plan(
        recurring: <RecurringExpense>[Build.recurring()],
        existing: <Expense>[
          Build.expense(id: 'old', name: 'Internet', monthKey: '2026-09'),
        ],
      );
      expect(result.created.length, 2);
      expect(result.skipped, 0);
    });

    test("faol bo'lmagan shablon ko'chirilmaydi", () {
      final result = plan(
        recurring: <RecurringExpense>[
          Build.recurring(name: 'Eski obuna', active: false),
        ],
      );
      expect(result.created.length, 1, reason: 'faqat fond ajratmasi');
    });

    test("summasi bo'sh shablon reja bo'sh holda ko'chadi", () {
      final result = plan(
        recurring: <RecurringExpense>[
          Build.recurring(name: 'Svet', amount: null),
        ],
      );
      final light = result.created.first;
      expect(light.planned, isNull);
      expect(light.isUnknownAmount, isTrue);
      expect(light.status, PaymentStatus.pending);
    });

    test('31-kun qisqa oyda oxirgi kunga qisiladi', () {
      final ids = SeqIds();
      final result = MonthOpenCalc.plan(
        month: const MonthKey('2026-02'),
        recurring: <RecurringExpense>[Build.recurring(day: 31)],
        existing: const <Expense>[],
        settings: settings,
        monthIncome: Money.zero,
        now: now,
        nextId: ids.next,
      );
      expect(result.created.first.dueDate, DateTime(2026, 2, 28));
    });

    test("qat'iy rejimda fond ajratmasi sozlamadan olinadi", () {
      final result = plan(
        config: const BudgetSettings(
          personalFund: PersonalFundSettings(
            mode: PersonalFundMode.fixed,
            value: 800000,
            method: PaymentMethod.card,
            day: 10,
          ),
        ),
      );
      final personal = result.created.single;
      expect(personal.planned, const Money(800000));
      expect(personal.method, PaymentMethod.card);
      expect(personal.dueDate, DateTime(2026, 10, 10));
    });

    test("shablon qarzga bog'langan bo'lsa bog'lanish ko'chadi", () {
      final result = plan(
        recurring: <RecurringExpense>[
          Build.recurring(name: 'Mashina', debtId: 'debt1', amount: 5300000),
        ],
      );
      expect(result.created.first.debtId, 'debt1');
    });

    test("bo'sh reja ham, shablon ham yo'q — faqat ajratma", () {
      expect(plan().created.length, 1);
      expect(plan().isEmpty, isFalse);
    });
  });
}
