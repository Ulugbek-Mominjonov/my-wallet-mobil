import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

/// Ko'rinish (view) obyektlarining tengligi, xeshi va matn ko'rinishi.
///
/// Bular shunchaki "boilerplate" emas: delta obyektlari `Map` kalitlari
/// sifatida ishlatiladi va testlar xato xabarida `toString` ni ko'rsatadi —
/// noto'g'ri `==` jimgina noto'g'ri agregat berishi mumkin.
void main() {
  const september = MonthKey('2026-09');
  final today = DateTime(2026, 9, 16);

  group('MonthDelta tengligi', () {
    const one = MonthDelta(income: Money(100), unknownCount: 1);
    const same = MonthDelta(income: Money(100), unknownCount: 1);
    const other = MonthDelta(income: Money(200));

    test('bir xil qiymatlar teng va xeshi bir xil', () {
      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one == other, isFalse);
      expect(one.isNotEmpty, isTrue);
      expect(MonthDelta.zero.isNotEmpty, isFalse);
    });

    test("kesim map'lari ham solishtiriladi", () {
      const withType = MonthDelta(
        byType: <String, MethodSplit>{
          'Oylik': MethodSplit(card: Money(5)),
        },
      );
      const withCategory = MonthDelta(
        byCategory: <String, CategorySplit>{
          'Qarz': CategorySplit(actual: Money(5)),
        },
      );
      expect(withType == withCategory, isFalse);
      expect(withType.toString(), contains('byType'));
      expect(
        const MethodSplit(card: Money(1)).toString(),
        contains('card'),
      );
      expect(
        const CategorySplit(actual: Money(1)).toString(),
        contains('fakt'),
      );
    });

    test('TotalsDelta va DebtDelta tengligi', () {
      expect(
        const TotalsDelta(income: Money(5)),
        const TotalsDelta(income: Money(5)),
      );
      expect(
        const TotalsDelta(income: Money(5)).hashCode,
        const TotalsDelta(income: Money(5)).hashCode,
      );
      expect(
        const DebtDelta(pending: Money(5)),
        const DebtDelta(pending: Money(5)),
      );
      expect(
        const DebtDelta(pending: Money(5)).hashCode,
        const DebtDelta(pending: Money(5)).hashCode,
      );
      expect(const DebtDelta(pending: Money(5)).toString(), contains('5'));
      expect(const TotalsDelta(income: Money(5)).toString(), contains('5'));
    });

    test('AggregateDelta tengligi va matni', () {
      final delta = AggregateDelta.forIncome(after: Build.income());
      final same = AggregateDelta.forIncome(after: Build.income());
      expect(delta, same);
      expect(delta.hashCode, same.hashCode);
      expect(delta.toString(), contains('2026-09'));
      expect(delta == AggregateDelta.zero, isFalse);
    });
  });

  group("ko'rinishlarning matn shakli", () {
    test('DebtView', () {
      final view = DebtCalc.view(Build.debt(), today: today);
      expect(view.toString(), contains('Mashina'));
      expect(view.pending, Money.zero);
    });

    test('GoalView va views()', () {
      final views = GoalCalc.views(
        <Goal>[Build.goal(), Build.goal(id: 'g2', name: 'Uy')],
        averageSaved: const Money(1000000),
        today: today,
      );
      expect(views.length, 2);
      expect(views.first.toString(), contains('Sayohat'));
    });

    test('LimitStatus', () {
      const status = LimitStatus(
        category: 'Oziq-ovqat',
        limit: Money(1000),
        spent: Money(850),
      );
      expect(status.isNearLimit, isTrue);
      expect(status.toString(), contains('Oziq-ovqat'));
    });

    test('MonthForecast', () {
      final forecast = ForecastCalc.compute(
        month: const MonthSummary(monthKey: september),
        totals: const OverallTotals(),
        monthCount: 0,
        today: today,
      );
      expect(forecast.toString(), contains('kunlik'));
      expect(forecast.averageExpense, Money.zero);
    });

    test("SavingsPoint va bo'sh seriya", () {
      final series = SavingsCalc.build(<MonthSummary>[
        const MonthSummary(monthKey: september, income: Money(10)),
      ]);
      expect(series.monthCount, 1);
      expect(series.firstMonth, september);
      expect(series.lastMonth, september);
      expect(series.points.single.toString(), contains('2026-09'));
      expect(SavingsSeries.empty.firstMonth, isNull);
      expect(SavingsSeries.empty.lastMonth, isNull);
      expect(SavingsSeries.empty.monthCount, 0);
    });

    test('ReminderBuckets.total', () {
      final buckets = ReminderCalc.split(
        <Expense>[
          Build.expense(planned: 100, dueDate: DateTime(2026, 9)),
          Build.expense(
            id: 'e2',
            planned: 250,
            dueDate: DateTime(2026, 9, 16),
          ),
          Build.expense(
            id: 'e3',
            planned: null,
            dueDate: DateTime(2026, 9, 17),
          ),
        ],
        today: today,
        daysAhead: 5,
      );
      expect(buckets.total, const Money(350));
      expect(ReminderBuckets.empty.total, Money.zero);
    });

    test('PersonalFundView oy kesimida', () {
      final view = PersonalFundCalc.fromMonth(
        const MonthSummary(
          monthKey: september,
          personalAllocated: Money(1000),
          personalSpent: Money(250),
        ),
      );
      expect(view.balance, const Money(750));
      expect(view.usedRatio, 0.25);
      expect(view.toString(), contains('750'));
      expect(
        PersonalFundCalc.fromTotals(const OverallTotals()).usedRatio,
        0,
      );
    });
  });

  group('drift obyektlari', () {
    test('FieldDrift tengligi va matni', () {
      const drift = FieldDrift(field: 'income', stored: 1, computed: 2);
      expect(drift, const FieldDrift(field: 'income', stored: 1, computed: 2));
      expect(
        drift.hashCode,
        const FieldDrift(field: 'income', stored: 1, computed: 2).hashCode,
      );
      expect(drift.difference, 1);
      expect(drift.toString(), contains('income'));
    });

    test('byType kesimidagi drift topiladi', () {
      final drift = ReconcileCalc.compare(
        stored: const MonthSummary(monthKey: september),
        computed: const MonthSummary(
          monthKey: september,
          byType: <String, MethodSplit>{
            'Oylik': MethodSplit(card: Money(10), cash: Money(5)),
          },
        ),
      );
      expect(drift.fields.length, 2);
      expect(drift.fields.first.field, 'byType.Oylik.card');
      expect(drift.toString(), contains('2026-09'));
    });
  });

  group('MonthSummary yordamchilari', () {
    test("bo'sh agregat va progress", () {
      final empty = MonthSummary.empty(september);
      expect(empty.isEmpty, isTrue);
      expect(empty.plannedUsage, 0);
      expect(empty.toString(), contains('2026-09'));
      expect(
        const MonthSummary(
          monthKey: september,
          planned: Money(100),
          expense: Money(50),
        ).plannedUsage,
        0.5,
      );
    });

    test("kategoriyalar summa bo'yicha saralanadi", () {
      const summary = MonthSummary(
        monthKey: september,
        byCategory: <String, CategorySplit>{
          'Kichik': CategorySplit(actual: Money(10)),
          'Katta': CategorySplit(actual: Money(100)),
        },
      );
      expect(summary.categoriesByAmount.first.key, 'Katta');
    });

    test('OverallTotals matni va hosila qiymatlari', () {
      const totals = OverallTotals(
        income: Money(1000),
        expense: Money(400),
        personalAllocated: Money(100),
        personalSpent: Money(30),
      );
      expect(totals.savings, const Money(600));
      expect(totals.personalBalance, const Money(70));
      expect(totals.saved, const Money(670));
      expect(totals.toString(), contains('jamgarma'));
      expect(totals.hashCode, isNot(0));
    });
  });
}
