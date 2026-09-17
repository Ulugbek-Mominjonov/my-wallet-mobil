import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

void main() {
  group('§2.9 prognoz', () {
    const september = MonthKey('2026-09');

    test("joriy oyda kunlik sur'atga qarab oy oxiri hisoblanadi", () {
      final forecast = ForecastCalc.compute(
        month: const MonthSummary(
          monthKey: september,
          income: Money(6000000),
          expense: Money(3000000),
        ),
        totals: const OverallTotals(
          income: Money(30000000),
          expense: Money(20000000),
        ),
        monthCount: 3,
        today: DateTime(2026, 9, 15),
      );
      expect(forecast.isCurrentMonth, isTrue);
      expect(forecast.daysPassed, 15);
      expect(forecast.daysInMonth, 30);
      expect(forecast.dailyBurn, const Money(200000));
      expect(forecast.monthEndSpend, const Money(6000000));
    });

    test('joriy oyda hali kelmagan daromad kutiladi', () {
      final forecast = ForecastCalc.compute(
        month: const MonthSummary(
          monthKey: september,
          income: Money(2000000),
          expense: Money(1000000),
        ),
        totals: const OverallTotals(income: Money(26000000)),
        monthCount: 3,
        // boshqa oylar: (26 000 000 − 2 000 000) / 2 = 12 000 000
        today: DateTime(2026, 9, 5),
      );
      expect(forecast.expectedIncome, const Money(12000000));
      expect(forecast.isIncomePending, isTrue);
    });

    test("o'tgan oyda prognoz = haqiqiy qiymat", () {
      final forecast = ForecastCalc.compute(
        month: const MonthSummary(
          monthKey: MonthKey('2026-08'),
          income: Money(5000000),
          expense: Money(4000000),
        ),
        totals: const OverallTotals(
          income: Money(10000000),
          expense: Money(8000000),
        ),
        monthCount: 2,
        today: DateTime(2026, 9, 16),
      );
      expect(forecast.isCurrentMonth, isFalse);
      expect(forecast.monthEndSpend, const Money(4000000));
      expect(forecast.expectedIncome, const Money(5000000));
      expect(forecast.monthEndBalance, const Money(1000000));
    });

    test("yagona oy bo'lsa o'rtacha daromad nol (bo'lish xatosi yo'q)", () {
      final forecast = ForecastCalc.compute(
        month: const MonthSummary(
          monthKey: september,
          income: Money(1000),
          expense: Money(500),
        ),
        totals: const OverallTotals(income: Money(1000), expense: Money(500)),
        monthCount: 1,
        today: DateTime(2026, 9, 10),
      );
      expect(forecast.expectedIncome, const Money(1000));
    });
  });

  group('kategoriya limitlari', () {
    final month = MonthSummaryCalc.build(
      monthKey: const MonthKey('2026-09'),
      personalCategoryKey: "o'zim uchun",
      expenses: <Expense>[
        Build.expense(actual: 1200000),
        Build.expense(id: 'e2', category: 'Transport', actual: 300000),
      ],
    );
    final limits = <CategoryLimit>[
      const CategoryLimit(
        id: 'l1',
        category: 'Oziq-ovqat',
        monthlyLimit: Money(1000000),
      ),
      const CategoryLimit(
        id: 'l2',
        category: ' transport ',
        monthlyLimit: Money(1000000),
      ),
    ];

    test('oshgan limit aniqlanadi', () {
      final exceeded = LimitCalc.exceeded(month, limits);
      expect(exceeded.single.category, 'Oziq-ovqat');
      expect(exceeded.single.spent, const Money(1200000));
    });

    test('kategoriya nomi normallashtirilib solishtiriladi', () {
      final statuses = LimitCalc.forMonth(month, limits);
      final transport =
          statuses.firstWhere((item) => item.category.trim() == 'transport');
      expect(transport.spent, const Money(300000));
      expect(transport.remaining, const Money(700000));
      expect(transport.isNearLimit, isFalse);
    });
  });

  group('eslatma guruhlari', () {
    final today = DateTime(2026, 9, 16);
    final expenses = <Expense>[
      Build.expense(dueDate: DateTime(2026, 9, 10)),
      Build.expense(id: 'e2', dueDate: DateTime(2026, 9, 16)),
      Build.expense(id: 'e3', dueDate: DateTime(2026, 9, 18)),
      Build.expense(id: 'e4', dueDate: DateTime(2026, 9, 25)),
      Build.expense(id: 'e5', dueDate: DateTime(2026, 9, 11), actual: 100),
      Build.expense(id: 'e6', dueDate: DateTime(2026, 9, 12), planned: 0),
    ];

    test('kechikkan / bugungi / yaqin', () {
      final buckets = ReminderCalc.split(
        expenses,
        today: today,
        daysAhead: 3,
      );
      expect(buckets.overdue.map((item) => item.id), <String>['e1']);
      expect(buckets.dueToday.map((item) => item.id), <String>['e2']);
      expect(buckets.upcoming.map((item) => item.id), <String>['e3']);
      expect(buckets.count, 3);
    });

    test("to'langan va kuzatilmaydigan qatorlar eslatilmaydi", () {
      final buckets = ReminderCalc.split(
        expenses,
        today: today,
        daysAhead: 30,
      );
      final ids = <String>[
        ...buckets.overdue.map((item) => item.id),
        ...buckets.dueToday.map((item) => item.id),
        ...buckets.upcoming.map((item) => item.id),
      ];
      expect(ids, isNot(contains('e5')));
      expect(ids, isNot(contains('e6')));
    });

    test("eslatadigan narsa bo'lmasa bo'sh", () {
      final buckets = ReminderCalc.split(
        <Expense>[],
        today: today,
        daysAhead: 3,
      );
      expect(buckets.isEmpty, isTrue);
    });
  });

  group('🩺 reconciler', () {
    test('farqni topadi', () {
      const stored = MonthSummary(
        monthKey: MonthKey('2026-09'),
        income: Money(1000),
        expense: Money(400),
      );
      const computed = MonthSummary(
        monthKey: MonthKey('2026-09'),
        income: Money(1200),
        expense: Money(400),
      );
      final drift = ReconcileCalc.compare(
        stored: stored,
        computed: computed,
      );
      expect(drift.isClean, isFalse);
      expect(drift.fields.single.field, 'income');
      expect(drift.fields.single.difference, 200);
    });

    test("mos kelsa drift yo'q", () {
      const summary = MonthSummary(
        monthKey: MonthKey('2026-09'),
        income: Money(1000),
        byCategory: <String, CategorySplit>{
          'Qarz': CategorySplit(planned: Money(10), actual: Money(10)),
        },
      );
      expect(
        ReconcileCalc.compare(stored: summary, computed: summary).isClean,
        isTrue,
      );
    });

    test("kesimdagi farq ham ko'rinadi", () {
      const stored = MonthSummary(monthKey: MonthKey('2026-09'));
      const computed = MonthSummary(
        monthKey: MonthKey('2026-09'),
        byCategory: <String, CategorySplit>{
          'Qarz': CategorySplit(actual: Money(50)),
        },
      );
      final drift = ReconcileCalc.compare(
        stored: stored,
        computed: computed,
      );
      expect(drift.fields.single.field, 'byCategory.Qarz.actual');
    });
  });
}
