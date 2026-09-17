import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

void main() {
  const personal = "o'zim uchun";
  const month = MonthKey('2026-09');

  MonthSummary build({
    List<Income> incomes = const <Income>[],
    List<Expense> expenses = const <Expense>[],
    List<PersonalSpend> spends = const <PersonalSpend>[],
  }) =>
      MonthSummaryCalc.build(
        monthKey: month,
        personalCategoryKey: personal,
        incomes: incomes,
        expenses: expenses,
        personalSpends: spends,
      );

  group('§2.3 oylik yakun', () {
    test('qoldiq = daromad − xarajat', () {
      final summary = build(
        incomes: <Income>[Build.income(amount: 12000000)],
        expenses: <Expense>[Build.expense(planned: 9500000, actual: 9500000)],
      );
      expect(summary.income, const Money(12000000));
      expect(summary.expense, const Money(9500000));
      expect(summary.balance, const Money(2500000));
    });

    test("prognoz = qoldiq − to'lanmagan jami", () {
      final summary = build(
        incomes: <Income>[Build.income(amount: 10000000)],
        expenses: <Expense>[
          Build.expense(planned: 4000000, actual: 4000000),
          Build.expense(id: 'e2', planned: 700000),
        ],
      );
      expect(summary.unpaidTotal, const Money(700000));
      expect(summary.forecast, const Money(5300000));
    });

    test("karta va naqd kesimi alohida yig'iladi", () {
      final summary = build(
        incomes: <Income>[
          Build.income(amount: 8000000),
          Build.income(
            id: 'i2',
            amount: 4000000,
            method: PaymentMethod.cash,
          ),
        ],
        expenses: <Expense>[
          Build.expense(
            planned: 6000000,
            actual: 6000000,
            method: PaymentMethod.card,
          ),
          Build.expense(id: 'e2', planned: 3500000, actual: 3500000),
        ],
      );
      expect(summary.incomeCard, const Money(8000000));
      expect(summary.incomeCash, const Money(4000000));
      expect(summary.card, const Money(2000000));
      expect(summary.cash, const Money(500000));
    });

    test('orttirgan = qoldiq + ajratma − shaxsiy sarf', () {
      final summary = build(
        incomes: <Income>[Build.income(amount: 10000000)],
        expenses: <Expense>[
          Build.expense(
            name: "O'zim uchun (ajratma)",
            category: "O'zim uchun",
            planned: 1000000,
            actual: 1000000,
          ),
        ],
        spends: <PersonalSpend>[Build.personalSpend(amount: 400000)],
      );
      expect(summary.balance, const Money(9000000));
      expect(summary.personalAllocated, const Money(1000000));
      expect(summary.personalSpent, const Money(400000));
      expect(summary.saved, const Money(9600000));
      expect(summary.savedRatio, closeTo(0.96, 0.0001));
    });

    test("daromad nol bo'lsa foiz nol (bo'lish xatosi yo'q)", () {
      expect(build().savedRatio, 0);
    });

    test('boshqa oyning yozuvlari hisobga olinmaydi', () {
      final summary = build(
        incomes: <Income>[
          Build.income(amount: 5000000, monthKey: '2026-08'),
        ],
      );
      expect(summary.income, Money.zero);
    });
  });

  group("to'lanmagan to'lovlar", () {
    test("summasi noma'lum qatorlar sanaladi", () {
      final summary = build(
        expenses: <Expense>[
          Build.expense(planned: null),
          Build.expense(id: 'e2', planned: 300000),
        ],
      );
      expect(summary.unknownCount, 1);
      expect(summary.unpaidTotal, const Money(300000));
      expect(summary.planned, const Money(300000));
    });

    test("to'langan qator to'lanmaganlar ichiga kirmaydi", () {
      final summary = build(
        expenses: <Expense>[
          Build.expense(planned: 300000, actual: 280000),
        ],
      );
      expect(summary.unpaidTotal, Money.zero);
      expect(summary.unknownCount, 0);
      expect(summary.expense, const Money(280000));
      expect(summary.planned, const Money(300000));
    });
  });

  group('kesimlar', () {
    test("byCategory reja va faktni alohida yig'adi", () {
      final summary = build(
        expenses: <Expense>[
          Build.expense(planned: 100000, actual: 120000),
          Build.expense(id: 'e2', planned: 50000),
        ],
      );
      expect(
        summary.byCategory['Oziq-ovqat'],
        const CategorySplit(planned: Money(150000), actual: Money(120000)),
      );
    });

    test("byType daromadni tur va usul bo'yicha ajratadi", () {
      final summary = build(
        incomes: <Income>[
          Build.income(amount: 5000000),
          Build.income(
            id: 'i2',
            amount: 2000000,
            type: 'KPI',
            method: PaymentMethod.cash,
            monthKey: '2026-09',
          ),
        ],
      );
      expect(summary.byType['Oylik']?.card, const Money(5000000));
      expect(summary.byType['KPI']?.cash, const Money(2000000));
      expect(summary.typesByAmount.first.key, 'Oylik');
    });

    test('nol qiymatli kesimlar saqlanmaydi', () {
      final summary = build(
        expenses: <Expense>[Build.expense(planned: 0)],
      );
      expect(summary.byCategory, isEmpty);
    });
  });

  test('buildAll faqat yozuvi bor oylarni qaytaradi', () {
    final months = MonthSummaryCalc.buildAll(
      personalCategoryKey: personal,
      incomes: <Income>[
        Build.income(monthKey: '2026-07', amount: 100),
        Build.income(id: 'i2', monthKey: '2026-09', amount: 200),
      ],
    );
    expect(months.keys.toList(), <MonthKey>[
      const MonthKey('2026-07'),
      const MonthKey('2026-09'),
    ]);
  });

  test("totals oylar agregatidan yig'iladi", () {
    final totals = MonthSummaryCalc.totals(<MonthSummary>[
      build(incomes: <Income>[Build.income(amount: 1000)]),
      const MonthSummary(
        monthKey: MonthKey('2026-08'),
        income: Money(500),
        expense: Money(200),
      ),
    ]);
    expect(totals.income, const Money(1500));
    expect(totals.expense, const Money(200));
    expect(totals.savings, const Money(1300));
  });
}
