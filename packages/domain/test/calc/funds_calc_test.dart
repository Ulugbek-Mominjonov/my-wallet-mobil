import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

MonthSummary month(
  String key, {
  int income = 0,
  int expense = 0,
  int allocated = 0,
  int spent = 0,
}) =>
    MonthSummary(
      monthKey: MonthKey(key),
      income: Money(income),
      expense: Money(expense),
      personalAllocated: Money(allocated),
      personalSpent: Money(spent),
    );

void main() {
  group("§2.5 jamg'armaning to'planishi", () {
    test('xronologik prefix-sum', () {
      final series = SavingsCalc.build(<MonthSummary>[
        month('2026-09', income: 300, expense: 100),
        month('2026-07', income: 100, expense: 40),
        month('2026-08', income: 200, expense: 250),
      ]);
      expect(
        series.points.map((point) => point.monthKey).toList(),
        <MonthKey>[
          const MonthKey('2026-07'),
          const MonthKey('2026-08'),
          const MonthKey('2026-09'),
        ],
      );
      expect(
        series.points.map((point) => point.cumulative.soum).toList(),
        <int>[60, 10, 210],
      );
      expect(series.total, const Money(210));
    });

    test("o'rtacha orttirish maqsadlar uchun hisoblanadi", () {
      final series = SavingsCalc.build(<MonthSummary>[
        month('2026-08', income: 1000, expense: 400, allocated: 100),
        month('2026-09', income: 1000, expense: 600, spent: 50),
      ]);
      // orttirgan: (600+100) + (400-50) = 700 + 350 = 1050 → o'rtacha 525
      expect(series.totalSaved, const Money(1050));
      expect(series.averageSaved, const Money(525));
    });

    test("bo'sh ro'yxat xato bermaydi", () {
      expect(SavingsCalc.build(const <MonthSummary>[]).total, Money.zero);
    });
  });

  group('§2.4 ikki fond aralashmaydi', () {
    test("shaxsiy fond qoldig'i = ajratilgan − sarflangan", () {
      const totals = OverallTotals(
        income: Money(10000),
        expense: Money(4000),
        personalAllocated: Money(1500),
        personalSpent: Money(400),
      );
      final fund = PersonalFundCalc.fromTotals(totals);
      expect(fund.balance, const Money(1100));
      expect(totals.savings, const Money(6000));
      expect(
        totals.savings + fund.balance,
        const Money(7100),
        reason: "ikkisi faqat testda qo'shiladi — ilovada hech qachon",
      );
    });
  });

  group('§2.10 "O\'zim uchun" rejasi', () {
    test("foiz rejimi 1000 so'mgacha yaxlitlanadi", () {
      expect(
        PersonalFundCalc.plannedAmount(
          monthIncome: const Money(12_345_678),
          settings: const PersonalFundSettings(),
        ),
        const Money(1_235_000),
      );
    });

    test('yaxlitlash BIR MARTA bajariladi', () {
      // 1 499 600 * 10% = 149 960 → 149.96 ming → 150 000
      expect(
        PersonalFundCalc.plannedAmount(
          monthIncome: const Money(1_499_600),
          settings: const PersonalFundSettings(),
        ),
        const Money(150000),
      );
    });

    test("qat'iy rejim sozlamadagi summani beradi", () {
      expect(
        PersonalFundCalc.plannedAmount(
          monthIncome: const Money(12_000_000),
          settings: const PersonalFundSettings(
            mode: PersonalFundMode.fixed,
            value: 800000,
          ),
        ),
        const Money(800000),
      );
    });

    test("daromad yo'q bo'lsa reja nol", () {
      expect(
        PersonalFundCalc.plannedAmount(
          monthIncome: Money.zero,
          settings: const PersonalFundSettings(),
        ),
        Money.zero,
      );
    });
  });

  group('§2.7 qarzlar', () {
    final today = DateTime(2026, 9, 16);

    test("men qarzdorman — bog'langan xarajat kamaytiradi", () {
      final view = DebtCalc.view(
        Build.debt(
          paidBefore: 10000000,
          paidFromExpenses: 5000000,
          paidFromIncomes: 999,
        ),
        today: today,
      );
      expect(view.applied, const Money(5000000));
      expect(view.remaining, const Money(35000000));
      expect(view.monthsLeft, 7);
      expect(view.finishMonth, const MonthKey('2027-04'));
    });

    test("menga qarzdor — bog'langan daromad kamaytiradi", () {
      final view = DebtCalc.view(
        Build.debt(
          direction: DebtDirection.owedToMe,
          total: 1000000,
          paidFromExpenses: 999,
          paidFromIncomes: 400000,
          monthly: 0,
        ),
        today: today,
      );
      expect(view.remaining, const Money(600000));
      expect(view.monthsLeft, 0);
      expect(view.finishMonth, isNull);
    });

    test("ortiqcha to'lov manfiy qoldiq bermaydi", () {
      final view = DebtCalc.view(
        Build.debt(total: 100, paidBefore: 80, paidFromExpenses: 50),
        today: today,
      );
      expect(view.remaining, Money.zero);
      expect(view.isClosed, isTrue);
      expect(view.progress, 1.0);
    });

    test("yakuniy ko'rsatkichlar", () {
      final totals = DebtCalc.totals(
        DebtCalc.views(
          <Debt>[
            Build.debt(total: 1000, monthly: 200),
            Build.debt(
              id: 'd2',
              direction: DebtDirection.owedToMe,
              total: 300,
              monthly: 0,
            ),
            Build.debt(id: 'd3', total: 100, paidBefore: 100, monthly: 50),
          ],
          today: today,
        ),
      );
      expect(totals.iOwe, const Money(1000));
      expect(totals.owedToMe, const Money(300));
      expect(totals.net, const Money(-700));
      expect(
        totals.monthlyTotal,
        const Money(200),
        reason: 'yopilgan qarzning oyligi hisobga olinmaydi',
      );
    });
  });

  group('§2.8 maqsadlar', () {
    final today = DateTime(2026, 9, 16);

    test('progress va prognoz', () {
      final view = GoalCalc.view(
        Build.goal(monthly: 3000000),
        averageSaved: const Money(1000000),
        today: today,
      );
      expect(view.remaining, const Money(15000000));
      expect(view.progress, 0.25);
      expect(view.monthsLeft, 5);
      expect(view.finishMonth, const MonthKey('2027-02'));
    });

    test("oyiga ajratma ko'rsatilmasa o'rtacha orttirish ishlatiladi", () {
      final view = GoalCalc.view(
        Build.goal(target: 10000000, saved: 0),
        averageSaved: const Money(2500000),
        today: today,
      );
      expect(view.perMonth, const Money(2500000));
      expect(view.monthsLeft, 4);
    });

    test("yig'ilgan maqsad", () {
      final view = GoalCalc.view(
        Build.goal(target: 1000, saved: 1200),
        averageSaved: const Money(100),
        today: today,
      );
      expect(view.isDone, isTrue);
      expect(view.progress, 1.0);
      expect(view.monthsLeft, 0);
    });

    test("ajratma ham, o'rtacha ham nol bo'lsa oylar hisoblanmaydi", () {
      final view = GoalCalc.view(
        Build.goal(target: 1000, saved: 0),
        averageSaved: Money.zero,
        today: today,
      );
      expect(view.monthsLeft, 0);
      expect(view.finishMonth, isNull);
    });

    test('muddatga ulgurish tekshiruvi', () {
      final view = GoalCalc.view(
        Build.goal(
          target: 10000,
          saved: 0,
          monthly: 1000,
          deadline: DateTime(2027),
        ),
        averageSaved: Money.zero,
        today: today,
      );
      expect(view.monthsLeft, 10);
      expect(view.isOnTrack(today), isFalse);
    });
  });
}
