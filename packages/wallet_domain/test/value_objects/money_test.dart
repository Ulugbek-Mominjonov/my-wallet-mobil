import 'package:test/test.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  group('Money (BR-001)', () {
    test('arifmetika eng kichik birlikda', () {
      const a = Money(150000000);
      const b = Money(45000000);
      expect(a + b, const Money(195000000));
      expect(a - b, const Money(105000000));
      expect(-b, const Money(-45000000));
      expect(b * 3, const Money(135000000));
      expect(Money.sum(const [a, b, b]), const Money(240000000));
      expect(Money.sum(const []), Money.zero);
    });

    test('taqqoslash va belgilar', () {
      expect(const Money(1) > Money.zero, isTrue);
      expect(const Money(-1) < Money.zero, isTrue);
      expect(const Money(5) >= const Money(5), isTrue);
      expect(const Money(5) <= const Money(4), isFalse);
      expect(const Money(-7).abs(), const Money(7));
      expect(const Money(7).abs(), const Money(7));
      expect(Money.zero.isZero, isTrue);
      expect(const Money(-1).isNegative, isTrue);
      expect(const Money(1).isPositive, isTrue);
    });

    test("qiymat bo'yicha tenglik (hash bilan)", () {
      final set = {const Money(5), Money(int.parse('5'))};
      expect(set, hasLength(1));
      expect(const Money(5).hashCode, Money(int.parse('5')).hashCode);
    });

    test('valyutalar aralashmaydi', () {
      expect(
        () => const Money(1) + const Money(1, Currency.usd),
        throwsArgumentError,
      );
      expect(
        () => const Money(1).compareTo(const Money(1, Currency.usd)),
        throwsArgumentError,
      );
      expect(const Money(1) == const Money(1, Currency.usd), isFalse);
    });

    test('BR-060: roundTo — noldan uzoqqa, yarmi yuqoriga', () {
      // 1 499 600 so'm × 10% = 149 960 → 1000 ga yaxlitlash → 150 000.
      expect(const Money(14996000).roundTo(100000), const Money(15000000));
      expect(const Money(150).roundTo(100), const Money(200));
      expect(const Money(149).roundTo(100), const Money(100));
      expect(const Money(-150).roundTo(100), const Money(-200));
      expect(() => const Money(1).roundTo(0), throwsArgumentError);
    });

    group('parse — kiritilgan summa', () {
      final cases = <String, int>{
        '1 200 000': 120000000,
        '1 200 000': 120000000,
        '1,200,000': 120000000,
        '1.200.000': 120000000,
        '1200000': 120000000,
        '1 200 000,50': 120000050,
        '1,200,000.5': 120000050,
        '1.200.000,05': 120000005,
        '1200.5': 120050,
        '1200,50': 120050,
        '0,5': 50,
        '-15 000': -1500000,
        '−15 000': -1500000,
        '  750  ': 75000,
      };
      for (final MapEntry(key: input, value: minor) in cases.entries) {
        test('"$input" → $minor', () {
          expect(Money.parse(input), Money(minor));
        });
      }

      for (final input in [
        '',
        '-',
        'abc',
        '1,20,000',
        '12,3456',
        '1.2.3',
        '1 200,555',
        ',5',
        '1,2,3',
        '1234567890123456',
      ]) {
        test("'$input' — noto'g'ri", () {
          expect(Money.tryParse(input), isNull);
          expect(() => Money.parse(input), throwsFormatException);
        });
      }

      test('kasrsiz valyuta', () {
        const jpy = Currency('JPY', exponent: 0);
        expect(Money.parse('1 500', currency: jpy), const Money(1500, jpy));
        expect(Money.tryParse('1500,5', currency: jpy), isNull);
      });
    });

    test('toString — diagnostika', () {
      expect(const Money(150050).toString(), '1500.50 UZS');
      expect(const Money(-5).toString(), '-0.05 UZS');
      expect(
        const Money(1500, Currency('JPY', exponent: 0)).toString(),
        '1500 JPY',
      );
    });

    test('Currency', () {
      expect(Currency.uzs.minorPerMajor, 100);
      expect(const Currency('JPY', exponent: 0).minorPerMajor, 1);
      // Qiymat bo'yicha tenglik (ish vaqtida yaratilgan nusxa bilan ham).
      final usd = Currency(['U', 'S', 'D'].join());
      expect(usd, Currency.usd);
      expect(usd.hashCode, Currency.usd.hashCode);
      expect(Currency.eur.toString(), 'EUR');
      expect(Currency.rub == Currency.usd, isFalse);
    });
  });

  group('rounding (Postgres round bilan bir xil)', () {
    test('roundDiv — noldan uzoqqa', () {
      expect(roundDiv(5, 2), 3);
      expect(roundDiv(-5, 2), -3);
      expect(roundDiv(5, -2), -3);
      expect(roundDiv(4, 3), 1);
      expect(roundDiv(300000000, 31), 9677419);
      expect(() => roundDiv(1, 0), throwsArgumentError);
    });

    test('ratio4', () {
      expect(ratio4(330000000, 575000000), 0.5739);
      expect(ratio4(300000000, 575000000), 0.5217);
      expect(ratio4(-1, 3), -0.3333);
    });
  });
}
