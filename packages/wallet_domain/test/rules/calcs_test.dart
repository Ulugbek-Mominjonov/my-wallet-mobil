import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-091 misoli: daromad 5 750 000 (karta); xarajat 1 500 000 karta +
/// 500 000 naqd + 1 000 000 ajratma (naqddan); fonddan sarf 450 000.
final august = MonthFacts(
  month: MonthKey(2026, 8),
  income: const Money(575000000),
  incomeCard: const Money(575000000),
  expense: const Money(300000000),
  expenseCard: const Money(150000000),
  expenseCash: const Money(150000000),
  allocated: const Money(100000000),
  fundSpent: const Money(45000000),
  hasRecords: true,
);

MonthFacts _facts(
  int month,
  int income, {
  int expense = 0,
  bool records = true,
}) => MonthFacts(
  month: MonthKey(2026, month),
  income: Money(income),
  expense: Money(expense),
  hasRecords: records,
);

void main() {
  group("BR-091: hosila ko'rsatkichlar", () {
    test('misol: qoldiq 2 750 000, orttirgan 3 300 000 (57%)', () {
      final summary = MonthSummary.of(august);
      expect(summary.balance, const Money(275000000));
      expect(summary.forecast, const Money(275000000));
      expect(summary.saved, const Money(330000000));
      expect(summary.savedRatio, 0.5739);
      expect(summary.spentRatio, 0.5217);
      expect(summary.planRatio, isNull);
      expect(summary.card, const Money(425000000));
      expect(summary.cash, const Money(-150000000));
    });

    test("prognoz qoldiq — to'lanmaganlar ayiriladi; reja bajarilishi", () {
      final summary = MonthSummary.fromTotals(
        income: const Money(1000),
        expense: const Money(400),
        unpaid: const Money(250),
        allocated: Money.zero,
        fundSpent: Money.zero,
        planned: const Money(800),
      );
      expect(summary.forecast, const Money(350));
      expect(summary.planRatio, 0.5);
    });

    test('daromad 0 — nisbatlar 0', () {
      final summary = MonthSummary.of(_facts(9, 0, expense: 500));
      expect(summary.savedRatio, 0);
      expect(summary.spentRatio, 0);
      expect(summary.balance, const Money(-500));
    });
  });

  test("MonthFacts: qiymat bo'yicha tenglik va diagnostika", () {
    final copy = MonthFacts(
      month: MonthKey(2026, 8),
      income: const Money(575000000),
      incomeCard: const Money(575000000),
      expense: const Money(300000000),
      expenseCard: const Money(150000000),
      expenseCash: const Money(150000000),
      allocated: const Money(100000000),
      fundSpent: const Money(45000000),
      hasRecords: true,
    );
    expect(copy, august);
    expect(copy.hashCode, august.hashCode);
    expect(copy == _facts(8, 575000000), isFalse);
    expect(august.toString(), contains('2026-08'));
  });

  group('BR-092: barcha oylar', () {
    test("o'rtachalar — yozuvi bor oylar bo'yicha; invariant", () {
      final totals = OverallTotals.of([
        august,
        _facts(9, 0, records: false),
        _facts(10, 100000000, expense: 40000000),
      ]);
      expect(totals.monthsCount, 2);
      expect(totals.totalIncome, const Money(675000000));
      expect(totals.totalExpense, const Money(340000000));
      expect(totals.totalBalance, const Money(335000000));
      expect(totals.totalSaved, const Money(390000000));
      expect(totals.avgMonthlySaved, const Money(195000000));
      expect(totals.avgMonthlyExpense, const Money(170000000));
      // Σ orttirgan = umumiy qoldiq + fond qoldig'i (1 000 000 − 450 000).
      expect(totals.holdsWith(const Money(55000000)), isTrue);
      expect(totals.holdsWith(const Money(55000001)), isFalse);
    });

    test("bo'sh — nol", () {
      final totals = OverallTotals.of(const []);
      expect(totals.monthsCount, 0);
      expect(totals.avgMonthlySaved, Money.zero);
    });
  });

  group('BR-093, BR-094: prognoz', () {
    test('oy oxiri (31-avgust) — fixture bilan bir xil', () {
      final forecast = MonthForecast.of(
        month: august,
        today: LocalDate(2026, 8, 31),
        history: [august],
      );
      expect(forecast.daysInMonth, 31);
      expect(forecast.daysElapsed, 31);
      expect(forecast.dailySpend, const Money(9677419));
      expect(forecast.monthEndSpend, const Money(300000000));
      expect(forecast.incomeExpected, const Money(575000000));
      expect(forecast.incomePending, isFalse);
      expect(forecast.monthEndBalance, const Money(275000000));
      expect(forecast.perDayAvailable, const Money(275000000));
    });

    test("oy o'rtasi: sarf oy oxirigacha cho'ziladi, bugun ham qolgan kun", () {
      final month = _facts(8, 1000000, expense: 100000);
      final forecast = MonthForecast.of(
        month: month,
        today: LocalDate(2026, 8, 10),
        history: [month],
      );
      expect(forecast.daysElapsed, 10);
      expect(forecast.monthEndSpend, const Money(310000));
      expect(forecast.dailySpend, const Money(10000));
      // (1 000 000 − 100 000) ÷ 22 kun (10..31) = 40 909 (butun bo'lish).
      expect(forecast.perDayAvailable, const Money(40909));
    });

    test('daromad rejalari bor — kelgan + kelmagan qoldiq', () {
      final month = _facts(8, 300000000, expense: 100000000);
      final forecast = MonthForecast.of(
        month: month,
        today: LocalDate(2026, 8, 5),
        history: [month],
        incomePlanCount: 2,
        incomePlansPending: const Money(500000000),
      );
      expect(forecast.incomeExpected, const Money(800000000));
      expect(forecast.incomePending, isTrue);
    });

    test("rejalar yo'q — max(kelgan, boshqa oylar o'rtachasi)", () {
      final current = _facts(10, 30000000);
      final forecast = MonthForecast.of(
        month: current,
        today: LocalDate(2026, 10, 3),
        history: [
          _facts(8, 100000000),
          _facts(9, 100000000),
          _facts(7, 0, records: false),
          current,
        ],
      );
      expect(forecast.incomeExpected, const Money(100000000));
      expect(forecast.incomePending, isTrue);
    });

    test("o'tgan oy — kelgan daromad; kelgusi oy — o'tgan kun 0", () {
      final past = _facts(7, 50000000, expense: 20000000);
      final pastForecast = MonthForecast.of(
        month: past,
        today: LocalDate(2026, 8, 5),
        history: [past],
      );
      expect(pastForecast.daysElapsed, 31);
      expect(pastForecast.incomeExpected, const Money(50000000));
      expect(pastForecast.perDayAvailable, isNull);

      final future = _facts(9, 0, expense: 1000, records: false);
      final futureForecast = MonthForecast.of(
        month: future,
        today: LocalDate(2026, 8, 5),
        history: [past, future],
      );
      expect(futureForecast.daysElapsed, 0);
      expect(futureForecast.dailySpend, Money.zero);
      expect(futureForecast.monthEndSpend, const Money(1000));
      expect(futureForecast.incomeExpected, const Money(50000000));
    });

    test("BR-094: mablag' yetmasa — 0 (manfiy emas)", () {
      expect(
        safeToSpendPerDay(
          expectedIncome: const Money(100),
          expense: const Money(80),
          unpaid: const Money(50),
          today: LocalDate(2026, 8, 30),
        ),
        Money.zero,
      );
    });
  });

  group("BR-100..102: jamg'arma", () {
    final months = [
      _facts(8, 1000, expense: 400),
      _facts(7, 500, expense: 700),
      _facts(9, 300, expense: 100),
    ];

    test("to'plangan = oldingi + shu oy qoldig'i; joriy oy ⏳", () {
      final rows = savingsTable(months, current: MonthKey(2026, 9));
      expect([for (final r in rows) r.month.month], [7, 8, 9]);
      expect([for (final r in rows) r.accumulated.minor], [-200, 400, 600]);
      expect([for (final r in rows) r.balance.minor], [-200, 600, 200]);
      expect([for (final r in rows) r.isCurrent], [false, false, true]);
    });

    test('BR-102: oldingi oylardan, shu oy, jami', () {
      final savings = MonthSavings.of(months, MonthKey(2026, 8));
      expect(savings.before, const Money(-200));
      expect(savings.thisMonth, const Money(600));
      expect(savings.total, const Money(400));
      final first = MonthSavings.of(const [], MonthKey(2026, 8));
      expect(first.total, Money.zero);
    });
  });

  group('BR-112..116: qarzlar', () {
    Debt debt(
      String name, {
      DebtDirection direction = DebtDirection.iOwe,
      int total = 1000000,
      int paidBefore = 0,
      int? monthly = 100000,
      Currency currency = Currency.uzs,
      DateTime? archivedAt,
    }) => Debt(
      id: name,
      householdId: 'h',
      name: name,
      direction: direction,
      total: Money(total, currency),
      paidBefore: Money(paidBefore, currency),
      monthlyPayment: monthly == null ? null : Money(monthly, currency),
      archivedAt: archivedAt,
    );

    DebtProgress progress(
      Debt debt, {
      int paid = 0,
      int payments = 0,
      int pending = 0,
      int pendingCount = 0,
    }) => DebtProgress.of(
      debt,
      paidInApp: Money(paid, debt.total.currency),
      paymentCount: payments,
      pendingAmount: Money(pending, debt.total.currency),
      pendingCount: pendingCount,
      currentMonth: MonthKey(2026, 9),
    );

    test('qolgan, oylar (ceil), tugash oyi, progress', () {
      final p = progress(
        debt('Mashina', paidBefore: 250000),
        paid: 150000,
        payments: 2,
      );
      expect(p.remaining, const Money(600000));
      expect(p.monthsLeft, 6);
      expect(p.endMonth, MonthKey(2027, 3));
      expect(p.progress, 0.4);
      expect(p.status, DebtStatus.paying);
      expect(progress(debt('X'), paid: 50000).monthsLeft, 10);
      expect(progress(debt('Y', monthly: 300000)).monthsLeft, 4);
    });

    test("holatlar: yopildi, kutilmoqda, bog'lanmagan; ortiqcha to'lov", () {
      final closed = progress(debt('A'), paid: 1200000, payments: 3);
      expect(closed.status, DebtStatus.closed);
      expect(closed.remaining, Money.zero);
      expect(closed.progress, 1);
      expect(closed.monthsLeft, isNull);
      expect(closed.endMonth, isNull);
      expect(
        progress(debt('B'), pending: 100000, pendingCount: 1).status,
        DebtStatus.pending,
      );
      expect(progress(debt('C')).status, DebtStatus.unlinked);
      expect(progress(debt('D', monthly: null)).monthsLeft, isNull);
    });

    test('BR-114: jamlar — asosiy valyuta, arxivsiz; oylik majburiyat', () {
      final debts = [
        debt('Kredit', paidBefore: 400000),
        debt('Yopilgan', total: 500000, paidBefore: 500000, monthly: 50000),
        debt('Dostim', direction: DebtDirection.owedToMe, total: 300000),
        debt('Dollar', currency: Currency.usd),
        debt('Arxiv', archivedAt: DateTime.utc(2026)),
      ];
      final totals = DebtTotals.of(
        [for (final d in debts) (d, progress(d))],
        baseCurrency: Currency.uzs,
        paidThisMonth: const Money(70000),
      );
      expect(totals.iOwe, const Money(600000));
      expect(totals.owedToMe, const Money(300000));
      expect(totals.monthlyObligation, const Money(100000));
      expect(totals.net, const Money(-300000));
      expect(totals.paidThisMonth, const Money(70000));
    });
  });

  group('BR-121, BR-122: maqsadlar', () {
    Goal goal({
      int target = 1000000,
      int saved = 200000,
      int? monthly,
      MonthKey? deadline,
      String? accountId,
    }) => Goal(
      id: 'g',
      householdId: 'h',
      name: 'Mashina',
      target: Money(target),
      savedManual: Money(saved),
      monthlyContribution: monthly == null ? null : Money(monthly),
      deadline: deadline,
      accountId: accountId,
    );

    final current = MonthKey(2026, 9);

    test('maqsadning oylik ajratmasi bilan: oylar, tugash, ulguradi', () {
      final p = GoalProgress.of(
        goal(monthly: 300000, deadline: MonthKey(2026, 12)),
        avgMonthlySaved: const Money(999),
        currentMonth: current,
      );
      expect(p.remaining, const Money(800000));
      expect(p.progress, 0.2);
      expect(p.monthly, const Money(300000));
      expect(p.monthlySource, GoalMonthlySource.goal);
      expect(p.monthsLeft, 3);
      expect(p.endMonth, MonthKey(2026, 12));
      expect(p.onTrack, isTrue);
      expect(p.isReached, isFalse);
    });

    test("ajratma yo'q — oyiga o'rtacha orttirish; ulgurmaydi", () {
      final p = GoalProgress.of(
        goal(deadline: MonthKey(2026, 10)),
        avgMonthlySaved: const Money(250000),
        currentMonth: current,
      );
      expect(p.monthlySource, GoalMonthlySource.average);
      expect(p.monthsLeft, 4);
      expect(p.onTrack, isFalse);
    });

    test("o'rtacha ham yo'q — prognoz yo'q", () {
      final p = GoalProgress.of(
        goal(),
        avgMonthlySaved: const Money(-5),
        currentMonth: current,
      );
      expect(p.monthly, isNull);
      expect(p.monthlySource, isNull);
      expect(p.monthsLeft, isNull);
      expect(p.onTrack, isNull);
    });

    test("BR-122: hisobga bog'langan — yig'ilgan = hisob qoldig'i", () {
      final linked = goal(accountId: 'a', saved: 999999);
      expect(
        GoalProgress.of(
          linked,
          avgMonthlySaved: Money.zero,
          currentMonth: current,
          accountBalance: const Money(1500000),
        ).isReached,
        isTrue,
      );
      final negative = GoalProgress.of(
        linked,
        avgMonthlySaved: Money.zero,
        currentMonth: current,
        accountBalance: const Money(-1),
      );
      expect(negative.saved, Money.zero);
      expect(negative.progress, 0);
    });
  });

  group('BR-130: limit holati', () {
    test('chegaralar: 80% dan near, 100% dan oshsa over', () {
      const limit = Money(1000000);
      expect(limitStatus(const Money(799999), limit), LimitStatus.ok);
      expect(limitStatus(const Money(800000), limit), LimitStatus.near);
      expect(limitStatus(const Money(1000000), limit), LimitStatus.near);
      expect(limitStatus(const Money(1000001), limit), LimitStatus.over);
      expect(limitStatus(const Money(5), null), isNull);
    });

    test('ulush', () {
      expect(limitRatio(const Money(850000), const Money(1000000)), 0.85);
      expect(limitRatio(const Money(1), null), isNull);
      expect(limitRatio(const Money(1), Money.zero), isNull);
    });
  });
}
