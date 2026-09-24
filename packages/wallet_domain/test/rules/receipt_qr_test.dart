import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  group('parseReceiptLink (E33-T02)', () {
    test('soliq.uz havolasi — summa, sana va STIR', () {
      final scan = parseReceiptLink(
        'https://ofd.soliq.uz/check?t=301234567&r=12345&c=UZ1&s=15000000'
        '&d=20261005&fp=99',
      );

      expect(scan?.amount, const Money(15000000));
      expect(scan?.date, LocalDate(2026, 10, 5));
      expect(scan?.tin, '301234567');
    });

    test('sana vaqt bilan ham o‘qiladi; sanasiz havola ham yaroqli', () {
      expect(
        parseReceiptLink('https://ofd.soliq.uz/check?s=100&d=202610051530')
            ?.date,
        LocalDate(2026, 10, 5),
      );
      expect(
        parseReceiptLink('https://ofd.soliq.uz/check?s=100')?.date,
        isNull,
      );
    });

    test('begona havola, summasiz yoki buzuq qiymat — null', () {
      for (final raw in [
        'https://example.com/check?s=100',
        'https://ofd.soliq.uz/check?t=1',
        'https://ofd.soliq.uz/check?s=0',
        'https://ofd.soliq.uz/check?s=abc',
        'salom',
      ]) {
        expect(parseReceiptLink(raw), isNull, reason: raw);
      }
    });
  });
}
