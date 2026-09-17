import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

void main() {
  final today = DateTime(2026, 9, 16);

  group("§2.6 to'lov holati", () {
    test("fakt kiritilgan — to'landi", () {
      expect(
        PaymentStatusCalc.compute(
          planned: const Money(100),
          actual: const Money(90),
          dueDate: DateTime(2026, 9),
          today: today,
        ),
        PaymentStatus.paid,
      );
    });

    test("sana o'tgan, fakt yo'q — muddati o'tdi", () {
      expect(
        PaymentStatusCalc.compute(
          planned: const Money(100),
          actual: null,
          dueDate: DateTime(2026, 9, 15),
          today: today,
        ),
        PaymentStatus.overdue,
      );
    });

    test("bugungi to'lov hali kechikkan emas", () {
      expect(
        PaymentStatusCalc.compute(
          planned: const Money(100),
          actual: null,
          dueDate: DateTime(2026, 9, 16, 23, 59),
          today: today,
        ),
        PaymentStatus.pending,
      );
    });

    test("summasi noma'lum (reja null) — baribir kuzatiladi", () {
      expect(
        PaymentStatusCalc.compute(
          planned: null,
          actual: null,
          dueDate: DateTime(2026, 9, 20),
          today: today,
        ),
        PaymentStatus.pending,
      );
    });

    test('reja aniq nol — kuzatilmaydi', () {
      expect(
        PaymentStatusCalc.compute(
          planned: Money.zero,
          actual: null,
          dueDate: DateTime(2026, 9),
          today: today,
        ),
        PaymentStatus.none,
      );
    });
  });

  group("avto to'lov", () {
    test("sana kelgan bo'lsa fakt = reja", () {
      final expense = Build.expense(
        planned: 300000,
        dueDate: DateTime(2026, 9, 10),
        autoPay: true,
      );
      final after = PaymentStatusCalc.applyAutoPay(expense, today);
      expect(after.actual, const Money(300000));
      expect(after.status, PaymentStatus.paid);
    });

    test("sana kelmagan bo'lsa tegilmaydi", () {
      final expense = Build.expense(
        planned: 300000,
        dueDate: DateTime(2026, 9, 25),
        autoPay: true,
      );
      final after = PaymentStatusCalc.applyAutoPay(expense, today);
      expect(after.actual, isNull);
      expect(after.status, PaymentStatus.pending);
    });

    test("rejasi yo'q bo'lsa avto to'lov ishlamaydi", () {
      final expense = Build.expense(
        planned: null,
        dueDate: DateTime(2026, 9, 10),
        autoPay: true,
      );
      expect(PaymentStatusCalc.shouldAutoPay(expense, today), isFalse);
    });

    test("allaqachon to'langan qator ikki marta to'lanmaydi", () {
      final expense = Build.expense(
        planned: 300000,
        actual: 250000,
        dueDate: DateTime(2026, 9, 10),
        autoPay: true,
      );
      final after = PaymentStatusCalc.applyAutoPay(expense, today);
      expect(after.actual, const Money(250000));
    });
  });
}
