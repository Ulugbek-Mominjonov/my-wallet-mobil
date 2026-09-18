import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/format/money_format.dart';

const nbsp = ' ';

void main() {
  // Kutilmalar admin paneldagi `formatMoney` testlari bilan AYNAN bir xil
  // (web/src/shared/lib/money.test.ts) — ikki platformada bir xil ko'rinish.
  group('formatMoney (BR-001)', () {
    test("UZS: tiyindan so'mga, minglik guruhlari bilan", () {
      expect(formatMoney(123456700), "1${nbsp}234${nbsp}567${nbsp}so'm");
    });

    test("UZS: so'mgacha yaxlitlanadi", () {
      expect(formatMoney(150), "2${nbsp}so'm");
    });

    test('manfiy summa haqiqiy minus belgisi bilan', () {
      expect(formatMoney(-50000), "−500${nbsp}so'm");
    });

    test("signed: musbat summa oldida '+'", () {
      expect(
        formatMoney(120000000, signed: true),
        "+1${nbsp}200${nbsp}000${nbsp}so'm",
      );
      expect(formatMoney(0, signed: true), "0${nbsp}so'm");
    });

    test("tilga qarab UZS qo'shimchasi", () {
      expect(
        formatMoney(10000, locale: AppLocale.ru),
        '100$nbsp'
        'сум',
      );
      expect(formatMoney(10000, locale: AppLocale.en), '100${nbsp}UZS');
    });

    test('boshqa valyutalar — sent bilan', () {
      expect(formatMoney(12345, currency: 'USD'), r'$123.45');
      expect(formatMoney(-500, currency: 'EUR'), '−€5.00');
    });
  });
}
