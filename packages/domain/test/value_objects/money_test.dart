import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('butun sonda ishlaydi va yaxlitlash xatosi bermaydi', () {
      var total = Money.zero;
      for (var i = 0; i < 10; i++) {
        total += const Money(100003);
      }
      expect(total, const Money(1000030));
    });

    test("qo'shish va ayirish", () {
      expect(const Money(500) + const Money(300), const Money(800));
      expect(const Money(500) - const Money(800), const Money(-300));
      expect(const Money(-300).absolute, const Money(300));
      expect(const Money(300).negated, const Money(-300));
    });

    test('clampedToZero manfiyni nolga qisadi', () {
      expect(const Money(-5).clampedToZero, Money.zero);
      expect(const Money(5).clampedToZero, const Money(5));
    });

    test("sum yig'indini beradi", () {
      expect(
        Money.sum(const <Money>[Money(100), Money(250), Money(-50)]),
        const Money(300),
      );
    });

    test("matndan o'qiydi: probel va vergul tashlanadi", () {
      expect(Money.parse('1 200 000'), const Money(1200000));
      expect(Money.parse('1,200,000'), const Money(1200000));
      expect(Money.parse("1200000 so'm"), const Money(1200000));
      expect(Money.tryParse('salom'), isNull);
      expect(Money.tryParse(''), isNull);
    });

    test("noto'g'ri matnda FormatException", () {
      expect(() => Money.parse("yo'q"), throwsFormatException);
    });

    test('roundTo mingga yaxlitlaydi', () {
      expect(const Money(1499).roundTo(1000), const Money(1000));
      expect(const Money(1500).roundTo(1000), const Money(2000));
    });

    test("ratioTo nolga bo'lmaydi", () {
      expect(const Money(50).ratioTo(Money.zero), 0);
      expect(const Money(50).ratioTo(const Money(200)), 0.25);
    });
  });
}
