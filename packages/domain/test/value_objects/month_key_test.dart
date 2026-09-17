import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('MonthKey', () {
    test('formatni tekshiradi', () {
      expect(MonthKey.isValid('2026-09'), isTrue);
      expect(MonthKey.isValid('2026-13'), isFalse);
      expect(MonthKey.isValid('2026-00'), isFalse);
      expect(MonthKey.isValid('26-09'), isFalse);
      expect(MonthKey.isValid(null), isFalse);
      expect(MonthKey.tryParse('  2026-09  '), const MonthKey('2026-09'));
    });

    test('sanadan yasaydi', () {
      expect(MonthKey.of(DateTime(2026, 9, 30)), const MonthKey('2026-09'));
      expect(MonthKey.of(DateTime(2026)), const MonthKey('2026-01'));
    });

    test("shift yil chegarasidan to'g'ri o'tadi", () {
      expect(const MonthKey('2026-01').shift(-1), const MonthKey('2025-12'));
      expect(const MonthKey('2026-12').shift(1), const MonthKey('2027-01'));
      expect(const MonthKey('2026-09').shift(0), const MonthKey('2026-09'));
      expect(const MonthKey('2026-09').shift(-13), const MonthKey('2025-08'));
    });

    test('oydagi kunlar soni (kabisa yili ham)', () {
      expect(const MonthKey('2026-02').daysInMonth, 28);
      expect(const MonthKey('2024-02').daysInMonth, 29);
      expect(const MonthKey('2026-09').daysInMonth, 30);
      expect(const MonthKey('2026-12').daysInMonth, 31);
    });

    test('dayOf oy oxiridan oshmaydi', () {
      expect(const MonthKey('2026-02').dayOf(31), DateTime(2026, 2, 28));
      expect(const MonthKey('2026-09').dayOf(0), DateTime(2026, 9));
      expect(const MonthKey('2026-09').dayOf(10), DateTime(2026, 9, 10));
    });

    test('leksikografik saralash = xronologik tartib', () {
      final months = <MonthKey>[
        const MonthKey('2026-10'),
        const MonthKey('2025-12'),
        const MonthKey('2026-02'),
      ]..sort();
      expect(
        months,
        const <MonthKey>[
          MonthKey('2025-12'),
          MonthKey('2026-02'),
          MonthKey('2026-10'),
        ],
      );
    });

    test("rangeTo oralig'ni beradi", () {
      expect(
        const MonthKey('2026-11').rangeTo(const MonthKey('2027-02')),
        const <MonthKey>[
          MonthKey('2026-11'),
          MonthKey('2026-12'),
          MonthKey('2027-01'),
          MonthKey('2027-02'),
        ],
      );
    });
  });
}
