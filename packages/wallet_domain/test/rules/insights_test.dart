import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  group('categorySpikes (E32)', () {
    test("3 oylik o'rtachadan 30%+ oshgani — farq bo'yicha tartibda", () {
      final spikes = categorySpikes(
        current: {
          'food': (name: 'Oziq-ovqat', actual: const Money(60000000)),
          'taxi': (name: 'Transport', actual: const Money(15000000)),
          'rent': (name: 'Ijara', actual: const Money(10000000)),
        },
        previousTotal: {
          // O'rtacha 300 000 → +100%.
          'food': const Money(90000000),
          // O'rtacha 100 000 → +50%.
          'taxi': const Money(30000000),
          // O'rtacha 100 000 → −0% (sakrash emas).
          'rent': const Money(30000000),
        },
      );

      expect(
        [for (final s in spikes) (s.name, s.deltaPercent)],
        [('Oziq-ovqat', 100), ('Transport', 50)],
      );
      expect(spikes.first.average, const Money(30000000));
    });

    test("tarixi yo'q yoki nol kategoriya — sakrash emas", () {
      final spikes = categorySpikes(
        current: {'new': (name: 'Yangi', actual: const Money(50000000))},
        previousTotal: {'other': const Money(10000000)},
      );
      expect(spikes, isEmpty);
    });
  });

  group('subscriptions (E32)', () {
    ({String payee, Money amount, MonthKey month}) payment(
      String payee,
      int amount,
      int month,
    ) => (payee: payee, amount: Money(amount), month: MonthKey(2026, month));

    test('bir xil nom va summa uch oyda — obuna (registr farqsiz)', () {
      final found = subscriptions([
        payment('Netflix', 5000000, 8),
        payment('netflix', 5000000, 9),
        payment('NETFLIX', 5000000, 10),
        // Boshqa summa — alohida guruh (uch oyga yetmaydi).
        payment('Netflix', 6000000, 7),
        // Ikki oyda — obuna emas.
        payment('Korzinka', 20000000, 9),
        payment('Korzinka', 20000000, 10),
      ]);

      expect(found, hasLength(1));
      expect((found.single.payee, found.single.months), ('Netflix', 3));
      expect(found.single.lastMonth, MonthKey(2026, 10));
    });

    test('nomsiz va nol summali amallar hisobga olinmaydi', () {
      expect(
        subscriptions([
          payment('  ', 5000000, 8),
          payment('  ', 5000000, 9),
          payment('  ', 5000000, 10),
        ]),
        isEmpty,
      );
    });
  });

  group('YearSummary (E32-T04)', () {
    MonthFacts month(int index, int income, int expense) => MonthFacts(
      month: MonthKey(2026, index),
      income: Money(income),
      expense: Money(expense),
      hasRecords: true,
    );

    test("o'rtacha — faqat yozuvi bor oylar; eng yaxshi va eng og'ir oy", () {
      final summary = YearSummary.of([
        month(1, 100000000, 40000000),
        month(2, 100000000, 90000000),
        MonthFacts(month: MonthKey(2026, 3)),
      ]);

      expect(summary.monthsCount, 2);
      expect(summary.avgExpense, const Money(65000000));
      expect(summary.best?.month, MonthKey(2026, 1));
      expect(summary.worst?.month, MonthKey(2026, 2));
      expect(summary.savedRatio, 0.35);
    });

    test("bitta oy — eng og'ir oy ko'rsatilmaydi; yozuvsiz yil — bo'sh", () {
      final one = YearSummary.of([month(1, 100000000, 40000000)]);
      expect((one.best?.month, one.worst), (MonthKey(2026, 1), null));

      final empty = YearSummary.of([MonthFacts(month: MonthKey(2026, 1))]);
      expect((empty.isEmpty, empty.avgExpense), (true, Money.zero));
    });
  });
}
