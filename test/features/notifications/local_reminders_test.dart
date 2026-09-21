import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/notifications/application/local_reminders.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_notifier.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';

PlannedItem _plan(
  String name,
  String due, {
  PlanKind kind = PlanKind.expense,
  int? amount = 10000000,
  DateTime? settledAt,
}) {
  final date = LocalDate.parse(due);
  return PlannedItem(
    id: name,
    householdId: 'h1',
    kind: kind,
    name: name,
    dueDate: date,
    budgetMonth: date.monthKey,
    plannedAmount: amount == null ? null : Money(amount),
    accountId: 'card',
    settledAt: settledAt,
    rowVersion: 1,
  );
}

void main() {
  final tashkent = TzClock.locationOf('Asia/Tashkent');

  group('BR-168: lokal eslatmalar rejasi', () {
    List<LocalReminder> plan(Iterable<PlannedItem> plans, DateTime now) =>
        planLocalReminders(
          plans,
          now: tz.TZDateTime.from(now, tashkent),
          hour: 9,
          title: 'T',
          body: (p) => p.name,
        );

    test(
      "to'lov kuni soat 9:00 da; o'tgan vaqt, daromad, to'langan — yo'q",
      () {
        final reminders = plan(
          [
            _plan('Bugun', '2026-10-10'),
            _plan('Ertaga', '2026-10-11'),
            _plan('Kecha', '2026-10-09'),
            _plan('Oylik', '2026-10-12', kind: PlanKind.income),
            _plan("To'langan", '2026-10-12', settledAt: DateTime.utc(2026, 10)),
          ],
          // 2026-10-10 08:00 Toshkent.
          DateTime.utc(2026, 10, 10, 3),
        );
        expect([for (final r in reminders) r.body], ['Bugun', 'Ertaga']);
        expect(reminders.first.at, tz.TZDateTime(tashkent, 2026, 10, 10, 9));
        expect(reminders.first.payload, '/payments');
      },
    );

    test("soat o'tib ketgan bo'lsa — bugungisi rejalashtirilmaydi", () {
      final reminders = plan(
        [_plan('Bugun', '2026-10-10')],
        DateTime.utc(2026, 10, 10, 5), // 10:00 Toshkent.
      );
      expect(reminders, isEmpty);
    });

    test("eng yaqin 30 tasi, vaqt bo'yicha", () {
      final reminders = plan([
        for (var day = 40; day >= 1; day--)
          _plan('R$day', LocalDate(2026, 11, 1).addDays(day).toString()),
      ], DateTime.utc(2026, 10, 10));
      expect(reminders, hasLength(maxLocalReminders));
      expect(reminders.first.body, 'R1');
      expect(reminders.last.body, 'R30');
    });
  });

  testWidgets("ilovada: rejalar o'zgarsa qayta rejalashtiriladi", (
    tester,
  ) async {
    final db = testDatabase();
    addTearDown(db.close);
    await db.batch((b) {
      b
        ..insert(
          db.households,
          const Household(
            id: 'h1',
            name: 'Uy',
            personalFund: PersonalFundRule(),
          ).toRow(),
        )
        ..insertAll(db.plannedItems, [
          _plan('Ijara', '2026-10-12').toCompanion(),
          _plan('Elektr', '2026-10-15', amount: null).toCompanion(),
          // 14 kundan keyin — rejalashtirilmaydi.
          _plan('Kurs', '2026-11-20').toCompanion(),
        ]);
    });
    final notifier = FakeLocalNotifier();
    await pumpApp(
      tester,
      database: db,
      notifier: notifier,
      localReminders: true,
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 10, 4)),
        ),
      ],
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(
      [for (final r in notifier.scheduled) r.body],
      ["Ijara — 100 000 so'm", "Elektr — summa o'zgaruvchi"],
    );
    expect(notifier.scheduled.first.title, "📌 Bugun to'lov kuni");

    // Reja to'landi — 2 s dan keyin (sinxron paketi tugagach) qayta.
    await (db.update(db.plannedItems)..where((p) => p.id.equals('Ijara')))
        .write(PlannedItemsCompanion(settledAt: Value(DateTime.utc(2026, 10))));
    await tester.pump(const Duration(seconds: 3));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(
      [for (final r in notifier.scheduled) r.body],
      ["Elektr — summa o'zgaruvchi"],
    );
  });
}
