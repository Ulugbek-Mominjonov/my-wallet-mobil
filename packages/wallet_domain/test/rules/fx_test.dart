import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

FxRateRow _row(String date, String rate, {Currency currency = Currency.usd}) =>
    (
      currency: currency,
      date: LocalDate.parse(date),
      rate: FxRate.tryParse(rate)!,
    );

void main() {
  group('FxRate', () {
    test('matndan: butun, kasr va ortiqcha nollar', () {
      expect(FxRate.tryParse('12600')!.scaled, 12600 * FxRate.scale);
      expect(FxRate.tryParse('12600.5')!.scaled, 12600500000);
      expect(FxRate.tryParse('0.000123')!.scaled, 123);
      expect(FxRate.tryParse('12600.500000').toString(), '12600.5');
      expect(FxRate.tryParse('12600').toString(), '12600');
    });

    test("noto'g'ri qiymat — null", () {
      for (final input in ['', '0', '-5', 'abc', '12,5', '1.1234567']) {
        expect(FxRate.tryParse(input), isNull, reason: input);
      }
    });
  });

  group('toBaseAmount (BR-191)', () {
    test('USD → UZS: kasr xonalari bir xil', () {
      const amount = Money(100000, Currency.usd); // 1 000,00 USD
      expect(
        toBaseAmount(
          amount,
          base: Currency.uzs,
          rate: FxRate.tryParse('12600')!,
        ),
        const Money(1260000000),
      );
    });

    test('yaxlitlash — noldan uzoqqa (server bilan bir xil)', () {
      final rate = FxRate.tryParse('0.5')!;
      expect(
        toBaseAmount(
          const Money(5, Currency.usd),
          base: Currency.uzs,
          rate: rate,
        ),
        const Money(3),
      );
      expect(
        toBaseAmount(
          const Money(-5, Currency.usd),
          base: Currency.uzs,
          rate: rate,
        ),
        const Money(-3),
      );
    });

    test('valyuta asosiy bilan bir xil — kurs ishlatilmaydi', () {
      expect(
        toBaseAmount(
          const Money(1500),
          base: Currency.uzs,
          rate: FxRate.tryParse('99')!,
        ),
        const Money(1500),
      );
    });

    test('katta summada ham aniq (int chegarasidan oshmaydi)', () {
      const amount = Money(100000000000, Currency.usd); // 1 mlrd USD
      expect(
        toBaseAmount(
          amount,
          base: Currency.uzs,
          rate: FxRate.tryParse('12600')!,
        ).minor,
        1260000000000000,
      );
    });
  });

  group('FxRates', () {
    final rates = FxRates.of([
      _row('2026-09-10', '12600'),
      _row('2026-09-20', '12700'),
    ]);

    test('sanadagi yoki undan oldingi eng yaqin kurs', () {
      FxRate? on(String date) =>
          rates.rate(Currency.usd, Currency.uzs, LocalDate.parse(date));
      expect(on('2026-09-12')!.toString(), '12600');
      expect(on('2026-09-20')!.toString(), '12700');
      expect(on('2026-09-22')!.toString(), '12700');
      // Birinchi kursdan oldin — kurs yo'q.
      expect(on('2026-09-01'), isNull);
    });

    test('valyuta o‘ziga — 1; noma’lum valyuta — null', () {
      final day = LocalDate.parse('2026-09-22');
      expect(rates.rate(Currency.uzs, Currency.uzs, day), FxRate.one);
      expect(rates.rate(Currency.eur, Currency.uzs, day), isNull);
    });

    test('so‘mdan boshqa asosiy valyuta — kurslar nisbati', () {
      final day = LocalDate.parse('2026-09-22');
      // 1 UZS = 1/12700 USD.
      expect(rates.rate(Currency.uzs, Currency.usd, day)!.scaled, 79);
    });

    test('converter: kurs yo‘q summa — null (jamga kirmaydi)', () {
      final toBase = rates.converter(
        Currency.uzs,
        LocalDate.parse('2026-09-22'),
      );
      expect(
        toBase(const Money(100000, Currency.usd)),
        const Money(1270000000),
      );
      expect(toBase(const Money(100000, Currency.eur)), isNull);
    });
  });
}
