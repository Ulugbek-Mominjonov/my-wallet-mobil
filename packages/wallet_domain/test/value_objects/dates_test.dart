import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  group('LocalDate (BR-002)', () {
    test('parse, ISO va taqqoslash', () {
      final date = LocalDate.parse('2026-09-18');
      expect(date, LocalDate(2026, 9, 18));
      expect(date.toString(), '2026-09-18');
      expect(date.monthKey, MonthKey(2026, 9));
      expect(date.isBefore(LocalDate(2026, 9, 19)), isTrue);
      expect(date.isAfter(LocalDate(2026, 8, 31)), isTrue);
      expect(date.hashCode, LocalDate(2026, 9, 18).hashCode);
      expect(LocalDate(33, 1, 2).toString(), '0033-01-02');
    });

    test("mavjud bo'lmagan sana — xato", () {
      expect(() => LocalDate(2026, 9, 31), throwsArgumentError);
      expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
      expect(LocalDate(2028, 2, 29).day, 29);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(() => LocalDate.parse('2026-9-1'), throwsFormatException);
    });

    test("kun qo'shish va farq (oy/yil chegarasi, kabisa)", () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2028, 3, 1).addDays(-1), LocalDate(2028, 2, 29));
      expect(LocalDate(2026, 9, 1).daysUntil(LocalDate(2026, 10, 1)), 30);
      expect(LocalDate(2026, 10, 1).daysUntil(LocalDate(2026, 9, 1)), -30);
    });

    test('DateTime dan (soat tashlanadi)', () {
      expect(
        LocalDate.fromDateTime(DateTime(2026, 9, 18, 23, 59)),
        LocalDate(2026, 9, 18),
      );
    });
  });

  group('MonthKey', () {
    test('parse: YYYY-MM va YYYY-MM-01', () {
      expect(MonthKey.parse('2026-09'), MonthKey(2026, 9));
      expect(MonthKey.parse('2026-09-01'), MonthKey(2026, 9));
      expect(() => MonthKey.parse('2026-09-15'), throwsFormatException);
      expect(() => MonthKey(2026, 0), throwsArgumentError);
      expect(MonthKey(2026, 9).toString(), '2026-09');
      expect(MonthKey(2026, 9).toIsoDate(), '2026-09-01');
      expect(MonthKey.ofDate(LocalDate(2026, 2, 28)), MonthKey(2026, 2));
    });

    test('siljitish va oylar farqi (yil chegarasi)', () {
      expect(MonthKey(2026, 1).shift(-1), MonthKey(2025, 12));
      expect(MonthKey(2026, 12).shift(1), MonthKey(2027, 1));
      expect(MonthKey(2026, 9).shift(-21), MonthKey(2024, 12));
      expect(MonthKey(2026, 9).monthsUntil(MonthKey(2027, 3)), 6);
      expect(MonthKey(2026, 9).isBefore(MonthKey(2026, 10)), isTrue);
      expect(MonthKey(2026, 9).isAfter(MonthKey(2026, 10)), isFalse);
      expect(MonthKey(2026, 9).hashCode, MonthKey(2026, 9).hashCode);
    });

    test('BR-080: oy kuni qisqa oyda oxirgi kunga qisiladi', () {
      expect(MonthKey(2026, 2).dayOf(31), LocalDate(2026, 2, 28));
      expect(MonthKey(2028, 2).dayOf(30), LocalDate(2028, 2, 29));
      expect(MonthKey(2026, 9).dayOf(31), LocalDate(2026, 9, 30));
      expect(MonthKey(2026, 10).dayOf(31), LocalDate(2026, 10, 31));
      expect(MonthKey(2026, 10).dayOf(5), LocalDate(2026, 10, 5));
      expect(() => MonthKey(2026, 10).dayOf(0), throwsArgumentError);
      expect(MonthKey(2026, 2).daysInMonth, 28);
      expect(MonthKey(2026, 9).firstDay, LocalDate(2026, 9, 1));
      expect(MonthKey(2026, 9).lastDay, LocalDate(2026, 9, 30));
      expect(MonthKey(2026, 9).contains(LocalDate(2026, 9, 30)), isTrue);
      expect(MonthKey(2026, 9).contains(LocalDate(2026, 10, 1)), isFalse);
    });
  });
}
