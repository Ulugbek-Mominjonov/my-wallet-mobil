import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

PlannedItem _plan(
  String name,
  String due, {
  PlanKind kind = PlanKind.expense,
  Money? planned = const Money(1000000),
  Money paid = Money.zero,
  DateTime? settledAt,
  DateTime? skippedAt,
  DateTime? deletedAt,
}) {
  final dueDate = LocalDate.parse(due);
  return PlannedItem(
    id: name,
    householdId: 'h',
    kind: kind,
    name: name,
    dueDate: dueDate,
    budgetMonth: dueDate.monthKey,
    plannedAmount: planned,
    paidAmount: paid,
    settledAt: settledAt,
    skippedAt: skippedAt,
    deletedAt: deletedAt,
  );
}

void main() {
  group('BR-040..046: tegishli oy', () {
    MonthKey income(String date, int shift) => attributeBudgetMonth(
      kind: TransactionKind.income,
      occurredOn: LocalDate.parse(date),
      incomeShift: shift,
    );

    test('BR-040: 02.10 dagi Oylik (−1) 2026-09 ga tushadi', () {
      expect(income('2026-10-02', -1), MonthKey(2026, 9));
    });
    test('BR-040: 06.10 dagi KPI (−1) 2026-09 ga tushadi', () {
      expect(income('2026-10-06', -1), MonthKey(2026, 9));
    });
    test('BR-040: 16.10 dagi Avans (0) 2026-10 ga tushadi', () {
      expect(income('2026-10-16', 0), MonthKey(2026, 10));
    });
    test("BR-040: 18.10 dagi Qo'shimcha (−1) 2026-09 ga tushadi", () {
      expect(income('2026-10-18', -1), MonthKey(2026, 9));
    });
    test('BR-040: yil chegarasi — 03.01 dagi Oylik (−1) dekabrga', () {
      expect(income('2027-01-03', -1), MonthKey(2026, 12));
    });

    test("BR-041: xarajat — sana oyi; qo'lda tanlangan oy ustun", () {
      final date = LocalDate(2026, 10, 5);
      expect(
        attributeBudgetMonth(kind: TransactionKind.expense, occurredOn: date),
        MonthKey(2026, 10),
      );
      expect(
        attributeBudgetMonth(
          kind: TransactionKind.expense,
          occurredOn: date,
          manualMonth: MonthKey(2026, 9),
        ),
        MonthKey(2026, 9),
      );
    });

    test("BR-042: daromadga ham qo'lda oy — siljishdan ustun", () {
      expect(
        attributeBudgetMonth(
          kind: TransactionKind.income,
          occurredOn: LocalDate(2026, 10, 2),
          incomeShift: -1,
          manualMonth: MonthKey(2026, 10),
        ),
        MonthKey(2026, 10),
      );
    });

    test("BR-044: rejaga bog'langan to'lov — reja oyi (keyingi oyda ham)", () {
      expect(
        attributeBudgetMonth(
          kind: TransactionKind.expense,
          occurredOn: LocalDate(2026, 11, 2),
          plannedMonth: MonthKey(2026, 10),
        ),
        MonthKey(2026, 10),
      );
    });

    test("BR-046: o'tkazma — sana oyi; ajratma rejasi orqali — reja oyi", () {
      expect(
        attributeBudgetMonth(
          kind: TransactionKind.transfer,
          occurredOn: LocalDate(2026, 10, 31),
          incomeShift: -1,
        ),
        MonthKey(2026, 10),
      );
      expect(
        attributeBudgetMonth(
          kind: TransactionKind.transfer,
          occurredOn: LocalDate(2026, 11, 1),
          plannedMonth: MonthKey(2026, 10),
        ),
        MonthKey(2026, 10),
      );
    });
  });

  group('BR-071: reja holati', () {
    final today = LocalDate(2026, 10, 10);

    test('tartib: skipped → paid → overdue → partial → pending', () {
      final settled = DateTime.utc(2026, 10, 9);
      expect(
        PlannedStatus.of(
          _plan('a', '2026-10-01', settledAt: settled, skippedAt: settled),
          today,
        ),
        PlannedStatus.skipped,
      );
      expect(
        PlannedStatus.of(_plan('a', '2026-10-01', settledAt: settled), today),
        PlannedStatus.paid,
      );
      expect(
        PlannedStatus.of(_plan('a', '2026-10-09', paid: const Money(1)), today),
        PlannedStatus.overdue,
      );
      expect(
        PlannedStatus.of(_plan('a', '2026-10-10', paid: const Money(1)), today),
        PlannedStatus.partial,
      );
      expect(
        PlannedStatus.of(_plan('a', '2026-10-10'), today),
        PlannedStatus.pending,
      );
    });

    test('ochiq holatlar', () {
      expect(PlannedStatus.overdue.isOpen, isTrue);
      expect(PlannedStatus.partial.isOpen, isTrue);
      expect(PlannedStatus.pending.isOpen, isTrue);
      expect(PlannedStatus.paid.isOpen, isFalse);
      expect(PlannedStatus.skipped.isOpen, isFalse);
    });
  });

  group('BR-060: 👤 fond ajratmasi', () {
    const rule = PersonalFundRule();

    test("1 499 600 × 10% → 150 000 (1000 so'mga, bir marta)", () {
      expect(
        personalAllocation(income: const Money(149960000), rule: rule),
        const Money(15000000),
      );
    });

    test('yarmi yuqoriga: 1 495 000 × 10% = 149 500 → 150 000', () {
      expect(
        personalAllocation(income: const Money(149500000), rule: rule),
        const Money(15000000),
      );
      expect(
        personalAllocation(income: const Money(149499900), rule: rule),
        const Money(14900000),
      );
    });

    test('kasrli foiz: 12.5% (1250 bp)', () {
      expect(
        personalAllocation(
          income: const Money(1000000000),
          rule: const PersonalFundRule(percentBasisPoints: 1250),
        ),
        const Money(125000000),
      );
    });

    test("daromad yo'q yoki 0% — reja yo'q", () {
      expect(personalAllocation(income: Money.zero, rule: rule), isNull);
      expect(
        personalAllocation(
          income: const Money(100000000),
          rule: const PersonalFundRule(percentBasisPoints: 0),
        ),
        isNull,
      );
    });

    test("qat'iy rejim — sozlamadagi summa", () {
      const fixed = PersonalFundRule(
        mode: PersonalFundMode.fixed,
        fixedAmount: Money(50000000),
      );
      expect(
        personalAllocation(income: const Money(1), rule: fixed),
        const Money(50000000),
      );
      expect(
        personalAllocation(
          income: const Money(1),
          rule: const PersonalFundRule(mode: PersonalFundMode.fixed),
        ),
        isNull,
      );
    });

    test("boshqa valyuta — o'z birligi bilan (standart 100)", () {
      expect(
        personalAllocation(
          income: const Money(12345, Currency.usd),
          rule: rule,
        ),
        const Money(1200, Currency.usd),
      );
    });
  });

  group("BR-160: eslatma bo'limlari", () {
    final today = LocalDate(2026, 10, 5);
    final plans = [
      _plan('Internet', '2026-10-03'),
      _plan('Elektr', '2026-10-05', planned: null),
      _plan('Kredit', '2026-10-07'),
      _plan('Suv', '2026-10-05'),
      _plan('Sport', '2026-10-20'),
      _plan('Gaz', '2026-10-01', settledAt: DateTime.utc(2026, 10)),
      _plan('Kurs', '2026-10-02', skippedAt: DateTime.utc(2026, 10)),
      _plan('Eski', '2026-10-04', deletedAt: DateTime.utc(2026, 10)),
      _plan('Oylik', '2026-10-01', kind: PlanKind.income),
      _plan('Arenda', '2026-10-03'),
    ];

    test("muddati o'tgan, bugun, 3 kun ichida; qolganlari — yo'q", () {
      final buckets = ReminderBuckets.of(plans, today: today, daysAhead: 3);
      List<String> names(List<PlannedItem> items) => [
        for (final item in items) item.name,
      ];
      expect(names(buckets.overdue), ['Arenda', 'Internet']);
      expect(names(buckets.today), ['Elektr', 'Suv']);
      expect(names(buckets.upcoming), ['Kredit']);
      expect(buckets.isEmpty, isFalse);
    });

    test("eslatadigan narsa yo'q — bo'sh", () {
      final buckets = ReminderBuckets.of(
        [_plan('Sport', '2026-10-20')],
        today: today,
        daysAhead: 3,
      );
      expect(buckets.isEmpty, isTrue);
    });

    test('0 kun oldinga — faqat bugun va kechikkanlar', () {
      final buckets = ReminderBuckets.of(plans, today: today, daysAhead: 0);
      expect(buckets.upcoming, isEmpty);
      expect(buckets.today, hasLength(2));
    });
  });
}
