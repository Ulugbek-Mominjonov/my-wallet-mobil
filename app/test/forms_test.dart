import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oylik_byudjet/features/expenses/presentation/add_expense_screen.dart';
import 'package:oylik_byudjet/features/income/presentation/add_income_screen.dart';
import 'package:oylik_byudjet/features/payments/presentation/payments_screen.dart';

import 'support/harness.dart';

void main() {
  group('＋ Daromad formasi', () {
    testWidgets(
      'DoD: 1-sentabrdagi "Oylik" AVGUST oyiga tegishli deb ko\'rsatiladi',
      (tester) async {
        await tester.pumpWidget(
          harness(
            child: const AddIncomeScreen(),
            now: DateTime(2026, 9),
            writer: RecordingWriter(),
          ),
        );
        await tester.pump();

        expect(
          find.text('→ Avgust 2026 oyining daromadi'),
          findsOneWidget,
        );
      },
    );

    testWidgets("Avans tanlansa joriy oy ko'rsatiladi", (tester) async {
      await tester.pumpWidget(
        harness(
          child: const AddIncomeScreen(),
          now: DateTime(2026, 9),
          writer: RecordingWriter(),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Avans'));
      await tester.pump();

      expect(
        find.text('→ Sentabr 2026 oyining daromadi'),
        findsOneWidget,
      );
    });

    testWidgets('summa kiritilganda probel bilan formatlanadi',
        (tester) async {
      await tester.pumpWidget(
        harness(
          child: const AddIncomeScreen(),
          now: DateTime(2026, 9),
          writer: RecordingWriter(),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '12000000');
      await tester.pump();

      expect(find.text('12 000 000'), findsOneWidget);
    });

    testWidgets('saqlaganda BITTA batch yoziladi', (tester) async {
      final writer = RecordingWriter();
      await tester.pumpWidget(
        harness(
          child: const AddIncomeScreen(),
          now: DateTime(2026, 9),
          writer: writer,
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '5000000');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
      await tester.pumpAndSettle();

      expect(writer.commands.length, 1);
      final command = writer.commands.single;
      expect(command.mutations.single, isA<UpsertIncome>());
      expect(
        command.delta.months[const MonthKey('2026-08')]!.income,
        const Money(5000000),
      );
      expect(
        command.delta.documentCount,
        2,
        reason: '1 oy hujjati + 1 totals',
      );
    });
  });

  group('－ Xarajat formasi', () {
    testWidgets("DoD: oktabrdagi to'lovni sentabrga biriktirish mumkin",
        (tester) async {
      await tester.pumpWidget(
        harness(
          child: const AddExpenseScreen(),
          now: DateTime(2026, 10, 5),
          writer: RecordingWriter(),
        ),
      );
      await tester.pump();

      expect(find.text('Oktabr (avto)'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sentabr'));
      await tester.pump();

      expect(
        find.text('→ Sentabr 2026 oyining byudjetiga'),
        findsOneWidget,
      );
    });

    testWidgets("tez qo'shish chipi formani to'ldiradi", (tester) async {
      await tester.pumpWidget(
        harness(
          child: const AddExpenseScreen(),
          now: DateTime(2026, 9, 16),
          writer: RecordingWriter(),
          quickAdds: const <QuickAdd>[
            QuickAdd(
              id: 'q1',
              name: 'Taksi',
              amount: Money(25000),
              category: 'Transport',
              method: PaymentMethod.cash,
            ),
          ],
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ActionChip, 'Taksi · 25 ming'));
      await tester.pump();

      expect(find.text('Taksi'), findsWidgets);
      expect(find.text('25 000'), findsOneWidget);
    });
  });

  group("To'lovlar ekrani", () {
    final today = DateTime(2026, 9, 16);

    Expense expense({
      required String id,
      required int day,
      int? planned = 300000,
    }) =>
        Expense(
          id: id,
          name: "To'lov $id",
          category: 'Kommunal',
          method: PaymentMethod.card,
          planned: planned == null ? null : Money(planned),
          dueDate: DateTime(2026, 9, day),
          monthKey: const MonthKey('2026-09'),
        );

    testWidgets('kechikkan / bugungi / yaqin guruhlarga ajratiladi',
        (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PaymentsScreen(),
          now: today,
          unpaid: <Expense>[
            expense(id: 'a', day: 10),
            expense(id: 'b', day: 16),
            expense(id: 'c', day: 18),
          ],
        ),
      );
      await tester.pump();

      expect(find.textContaining("Muddati o'tgan (1)"), findsOneWidget);
      expect(find.textContaining("Bugun to'lanadi (1)"), findsOneWidget);
      expect(find.textContaining('Yaqin kunlarda (1)'), findsOneWidget);
      expect(find.text("900 000 so'm"), findsOneWidget);
    });

    testWidgets("to'lanmagan bo'lmasa tabrik ko'rsatiladi",
        (tester) async {
      await tester.pumpWidget(
        harness(child: const PaymentsScreen(), now: today),
      );
      await tester.pump();

      expect(find.textContaining("To'lanmagan to'lov yo'q"), findsOneWidget);
    });

    testWidgets("to'landi tugmasi bitta batch yozadi", (tester) async {
      final writer = RecordingWriter();
      await tester.pumpWidget(
        harness(
          child: const PaymentsScreen(),
          now: today,
          writer: writer,
          unpaid: <Expense>[expense(id: 'a', day: 10)],
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(writer.commands.length, 1);
      expect(
        writer.commands.single.delta
            .months[const MonthKey('2026-09')]!
            .expense,
        const Money(300000),
      );
    });
  });
}
