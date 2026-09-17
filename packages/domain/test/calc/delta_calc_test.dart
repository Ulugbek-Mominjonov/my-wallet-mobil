import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

void main() {
  const personal = "o'zim uchun";
  const september = MonthKey('2026-09');
  const october = MonthKey('2026-10');

  AggregateDelta expenseDelta({Expense? before, Expense? after}) =>
      AggregateDelta.forExpense(
        personalCategoryKey: personal,
        before: before,
        after: after,
      );

  group("§5.2 delta — qo'shish", () {
    test("to'langan xarajat agregatga tushadi", () {
      final delta = expenseDelta(
        after: Build.expense(actual: 500000),
      );
      final month = delta.months[september]!;
      expect(month.expense, const Money(500000));
      expect(month.expenseCash, const Money(500000));
      expect(month.planned, const Money(500000));
      expect(month.unpaidTotal, Money.zero);
      expect(delta.totals.expense, const Money(500000));
    });

    test("to'lanmagan xarajat faqat rejaga ta'sir qiladi", () {
      final delta = expenseDelta(after: Build.expense());
      final month = delta.months[september]!;
      expect(month.expense, Money.zero);
      expect(month.planned, const Money(500000));
      expect(month.unpaidTotal, const Money(500000));
      expect(delta.totals.expense, Money.zero);
    });

    test('"O\'zim uchun" kategoriyasi fondga ham tushadi', () {
      final delta = expenseDelta(
        after: Build.expense(
          category: "O'zim uchun",
          planned: 1000000,
          actual: 1000000,
        ),
      );
      expect(
        delta.months[september]!.personalAllocated,
        const Money(1000000),
      );
      expect(delta.totals.personalAllocated, const Money(1000000));
    });
  });

  group("§5.2 delta — o'chirish", () {
    test("o'chirilgan yozuv teskari delta beradi", () {
      final expense = Build.expense(actual: 500000);
      final delta = expenseDelta(before: expense);
      expect(delta.months[september]!.expense, const Money(-500000));
      expect(delta.totals.expense, const Money(-500000));
    });

    test("qo'shish + o'chirish = nol", () {
      final expense = Build.expense(actual: 500000);
      final sum = expenseDelta(after: expense) + expenseDelta(before: expense);
      expect(sum.isEmpty, isTrue);
    });
  });

  group('§5.2 delta — tahrirlash', () {
    test("summa o'zgarsa faqat farq yoziladi", () {
      final before = Build.expense(actual: 500000);
      final after = before.copyWith(actual: const Money(600000));
      final month = expenseDelta(before: before, after: after)
          .months[september]!;
      expect(month.expense, const Money(100000));
      expect(month.planned, Money.zero);
    });

    test("oy o'zgarsa IKKI oy hujjati yangilanadi", () {
      final before = Build.expense(actual: 500000);
      final after = before.copyWith(
        monthKey: october,
        monthKeySource: MonthKeySource.manual,
      );
      final delta = expenseDelta(before: before, after: after);
      expect(delta.months.keys.toSet(), <MonthKey>{september, october});
      expect(delta.months[september]!.expense, const Money(-500000));
      expect(delta.months[october]!.expense, const Money(500000));
      expect(delta.totals.isEmpty, isTrue, reason: "umumiy jami o'zgarmaydi");
    });

    test("usul o'zgarsa karta/naqd kesimi ko'chadi", () {
      final before = Build.expense(planned: 100, actual: 100);
      final after = before.copyWith(method: PaymentMethod.card);
      final month =
          expenseDelta(before: before, after: after).months[september]!;
      expect(month.expenseCash, const Money(-100));
      expect(month.expenseCard, const Money(100));
      expect(month.expense, Money.zero);
    });

    test("to'lov belgilansa to'lanmagan jami kamayadi", () {
      final before = Build.expense(planned: 300000);
      final after = before.copyWith(actual: const Money(300000));
      final month =
          expenseDelta(before: before, after: after).months[september]!;
      expect(month.unpaidTotal, const Money(-300000));
      expect(month.expense, const Money(300000));
    });

    test("kategoriya o'zgarsa eski kalit manfiy, yangisi musbat", () {
      final before = Build.expense(planned: 100, actual: 100);
      final after = before.copyWith(category: 'Transport');
      final month =
          expenseDelta(before: before, after: after).months[september]!;
      expect(month.byCategory['Oziq-ovqat']!.actual, const Money(-100));
      expect(month.byCategory['Transport']!.actual, const Money(100));
    });
  });

  group('daromad deltasi', () {
    test("tur bo'yicha kesim bilan tushadi", () {
      final delta = AggregateDelta.forIncome(
        after: Build.income(amount: 3000000, type: 'KPI'),
      );
      final month = delta.months[const MonthKey('2026-09')]!;
      expect(month.income, const Money(3000000));
      expect(month.byType['KPI']!.card, const Money(3000000));
      expect(delta.totals.income, const Money(3000000));
    });

    test("qarzga bog'langan daromad qarz hisoblagichini oshiradi", () {
      final delta = AggregateDelta.forIncome(
        after: Build.income(debtId: 'd1'),
      );
      expect(delta.debts['d1']!.fromIncomes, const Money(1000000));
    });
  });

  group("qarz bog'lanishi", () {
    test('DoD: fakt kiritilgandagina qarz kamayadi', () {
      final unpaid = Build.expense(planned: 5300000, debtId: 'd1');
      final unpaidDelta = expenseDelta(after: unpaid);
      expect(unpaidDelta.debts['d1']!.fromExpenses, Money.zero);
      expect(unpaidDelta.debts['d1']!.pending, const Money(5300000));

      final paid = unpaid.copyWith(actual: const Money(5300000));
      final paidDelta = expenseDelta(before: unpaid, after: paid);
      expect(paidDelta.debts['d1']!.fromExpenses, const Money(5300000));
      expect(paidDelta.debts['d1']!.pending, const Money(-5300000));
    });

    test("bog'lanish olib tashlansa hisoblagich qaytariladi", () {
      final before = Build.expense(
        planned: 100,
        actual: 100,
        debtId: 'd1',
      );
      final after = before.copyWith(debtId: null);
      final delta = expenseDelta(before: before, after: after);
      expect(delta.debts['d1']!.fromExpenses, const Money(-100));
    });
  });

  group('shaxsiy fond sarfi', () {
    test("byudjet xarajatiga TA'SIR QILMAYDI", () {
      final delta = AggregateDelta.forPersonalSpend(
        after: Build.personalSpend(),
      );
      final month = delta.months[september]!;
      expect(month.personalSpent, const Money(200000));
      expect(month.expense, Money.zero);
      expect(delta.totals.expense, Money.zero);
      expect(delta.totals.personalSpent, const Money(200000));
    });
  });

  group("Firestore ko'rinishi", () {
    test('increment map faqat nolmas maydonlarni beradi', () {
      final delta = expenseDelta(
        after: Build.expense(actual: 500000),
      );
      final map = delta.months[september]!.toIncrements();
      expect(map['expense'], 500000);
      expect(map['planned'], 500000);
      expect(map.containsKey('income'), isFalse);
      expect(map.containsKey('unknownCount'), isFalse);
      expect(
        (map['byCategory']! as Map<String, Object>)['Oziq-ovqat'],
        <String, Object>{'planned': 500000, 'actual': 500000},
      );
    });

    test('nuqtali "field path" o\'rniga ichma-ich map ishlatiladi', () {
      final delta = expenseDelta(
        after: Build.expense(category: 'Uy.kommunal', actual: 100),
      );
      final map = delta.months[september]!.toIncrements();
      expect(map['byCategory'], isA<Map<String, Object>>());
      expect(
        (map['byCategory']! as Map<String, Object>).keys.first,
        'Uy.kommunal',
      );
    });
  });

  group('birlashtirish (bulk)', () {
    test("40 ta to'lov bitta agregat deltasiga yig'iladi", () {
      final deltas = <AggregateDelta>[
        for (var i = 0; i < 40; i++)
          expenseDelta(
            before: Build.expense(id: 'e$i', planned: 1000),
            after: Build.expense(id: 'e$i', planned: 1000, actual: 1000),
          ),
      ];
      final merged = AggregateDelta.merge(deltas);
      expect(merged.months.length, 1);
      expect(merged.documentCount, 2, reason: '1 oy + 1 totals');
      expect(merged.months[september]!.expense, const Money(40000));
    });

    test("bir-birini yo'qqa chiqargan deltalar tushib qoladi", () {
      final expense = Build.expense(actual: 100);
      final merged = AggregateDelta.merge(<AggregateDelta>[
        expenseDelta(after: expense),
        expenseDelta(before: expense),
      ]);
      expect(merged.isEmpty, isTrue);
      expect(merged.documentCount, 0);
    });
  });
}
