import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/pump_app.dart';

void main() {
  late AppDatabase db;

  Transaction tx(
    String id,
    String day, {
    TransactionKind kind = TransactionKind.expense,
    String category = 'food',
    int amount = 4500000,
    String? payee,
    String month = '2026-10-01',
  }) => Transaction(
    id: id,
    householdId: 'h1',
    kind: kind,
    accountId: 'a1',
    amount: Money(amount),
    amountBase: Money(amount),
    categoryId: category,
    occurredOn: LocalDate.parse(day),
    budgetMonth: MonthKey.parse(month),
    payee: payee,
    rowVersion: 1,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
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
        ..insert(
          db.accounts,
          const Account(
            id: 'a1',
            householdId: 'h1',
            name: 'Naqd',
            type: AccountType.cash,
            openingBalance: Money.zero,
            rowVersion: 1,
          ).toCompanion(),
        )
        ..insertAll(db.categories, [
          const Category(
            id: 'food',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: 'Oziq-ovqat',
          ).toCompanion(),
          const Category(
            id: 'salary',
            householdId: 'h1',
            kind: CategoryKind.income,
            name: 'Oylik',
          ).toCompanion(),
        ])
        ..insertAll(
          db.transactions,
          [
            tx('t1', '2026-10-05', payee: 'Korzinka'),
            tx('t2', '2026-10-05', amount: 1500000),
            tx(
              't3',
              '2026-10-02',
              kind: TransactionKind.income,
              category: 'salary',
              amount: 800000000,
            ),
            tx('t4', '2026-09-20', month: '2026-09-01'),
          ].map((t) => t.toCompanion()),
        );
    });
  });
  tearDown(() => db.close());

  Future<void> openList(WidgetTester tester) async {
    await pumpApp(
      tester,
      database: db,
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 6, 4)),
        ),
      ],
    );
    await tester.tap(find.bySemanticsLabel('Amallar'));
    await tester.pumpAndSettle();
  }

  testWidgets('joriy oy: kun guruhlari va kunlik jami', (tester) async {
    await openList(tester);
    expect(find.text('Oktabr 2026'), findsOneWidget);
    expect(find.text('5-oktabr, dushanba'), findsOneWidget);
    expect(find.text('2-oktabr, juma'), findsOneWidget);
    // 45 000 + 15 000 = 60 000 xarajat.
    expect(find.text("−60 000 so'm"), findsOneWidget);
    expect(find.text('Korzinka'), findsOneWidget);
    // Sentabr amali bu oyda yo'q.
    expect(find.text('20-sentabr, yakshanba'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('20-sentabr, yakshanba'), findsOneWidget);
  });

  testWidgets('filtr va qidiruv', (tester) async {
    await openList(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Daromad'));
    await tester.pumpAndSettle();
    expect(find.text('Korzinka'), findsNothing);
    expect(find.text('Oylik'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Hammasi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'korz');
    await tester.pumpAndSettle();
    expect(find.text('Korzinka'), findsOneWidget);
    expect(find.text('Oylik'), findsNothing);

    await tester.enterText(find.byType(TextField).first, "yo'q narsa");
    await tester.pumpAndSettle();
    expect(find.text("Filtrga mos amal yo'q"), findsOneWidget);
  });

  testWidgets("surib o'chirish va qaytarish (BR-009)", (tester) async {
    await openList(tester);
    await tester.drag(find.text('Korzinka'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Korzinka'), findsNothing);
    final deleted = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('t1'))).getSingle();
    expect(deleted.deletedAt, isNotNull);

    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();
    expect(find.text('Korzinka'), findsOneWidget);
    final restored = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('t1'))).getSingle();
    expect(restored.deletedAt, isNull);
  });

  testWidgets("bosish — tahrirlash, summa o'zgaradi", (tester) async {
    await openList(tester);
    await tester.tap(find.text('Korzinka'));
    await tester.pumpAndSettle();
    expect(find.text('Tahrirlash'), findsOneWidget);
    expect(find.text("45 000 so'm"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final edited = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('t1'))).getSingle();
    expect(edited.amount, 450000);
    expect(find.text('Korzinka'), findsOneWidget);
  });
}
