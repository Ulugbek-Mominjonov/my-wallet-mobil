import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/features/transactions/presentation/transactions_screen.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';

/// E30-T05, T06: "kim yozdi", a'zo filtri, a'zolar kesimi va rolga qarab UI.
void main() {
  late AppDatabase db;

  Transaction tx(
    String id, {
    required String createdBy,
    int amount = 4500000,
  }) => Transaction(
    id: id,
    householdId: 'h1',
    kind: TransactionKind.expense,
    accountId: 'a1',
    amount: Money(amount),
    amountBase: Money(amount),
    categoryId: 'food',
    occurredOn: LocalDate.parse('2026-10-05'),
    budgetMonth: MonthKey.parse('2026-10-01'),
    createdBy: createdBy,
    rowVersion: 1,
  );

  setUp(() async {
    db = testDatabase();
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
        ..insert(
          db.categories,
          const Category(
            id: 'food',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: 'Oziq-ovqat',
          ).toCompanion(),
        )
        ..insertAll(db.transactions, [
          tx('t1', createdBy: 'u1').toCompanion(),
          tx('t2', createdBy: 'u2', amount: 1500000).toCompanion(),
        ]);
    });
    // A'zolar keshi (oflaynda ham ismlar ko'rinadi — E30-T05).
    await db.setSetting(
      'members:h1',
      jsonEncode([
        {
          'user_id': 'u1',
          'name': 'Ali',
          'role': 'owner',
          'joined_at': '2026-09-01T00:00:00Z',
          'is_me': true,
        },
        {
          'user_id': 'u2',
          'name': 'Vali',
          'role': 'member',
          'joined_at': '2026-09-02T00:00:00Z',
          'is_me': false,
        },
      ]),
    );
  });
  tearDown(() => db.close());

  Future<void> openApp(WidgetTester tester, {String role = 'owner'}) async {
    // Baland ekran — ro'yxatdagi hamma karta quriladi (dangasa ListView).
    tester.view
      ..physicalSize = const Size(1080, 6000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      database: db,
      startup: switch (AppBootstrap.fromJson(
        bootstrapJson(
          households: [householdJson(id: 'h1', role: role)],
        ),
      )) {
        final boot => StartupReady(boot.households.first, boot),
      },
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 6, 4)),
        ),
      ],
    );
  }

  testWidgets('amal elementida boshqa a‘zo ismi; o‘ziniki belgilanmaydi', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.bySemanticsLabel('Amallar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Vali'), findsWidgets);
    // O'zi yozgan amalda ism yozilmaydi (faqat kategoriya va hisob).
    expect(find.textContaining('Ali'), findsNothing);
  });

  testWidgets("a'zo filtri — chip bor va faqat o‘sha a'zo amallari", (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.bySemanticsLabel('Amallar'));
    await tester.pumpAndSettle();
    expect(find.text("−60 000 so'm".replaceAll(' ', '\u00a0')), findsOneWidget);
    // Filtr chiplari — gorizontal ro'yxat: a'zo chipi ko'ringuncha suriladi.
    final chip = find.widgetWithText(FilterChip, "A'zolar");
    final chipRow = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.horizontal,
    );
    for (var i = 0; i < 5 && chip.evaluate().isEmpty; i++) {
      await tester.drag(chipRow, const Offset(-300, 0));
      await tester.pumpAndSettle();
    }
    expect(chip, findsOneWidget);

    // Filtr qo'llanganda ro'yxat faqat o'sha a'zo amallarini ko'rsatadi.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionsScreen)),
    );
    container
        .read(transactionListProvider.notifier)
        .setFilter(
          container
              .read(transactionListProvider)
              .filter
              .copyWith(createdBy: 'u2'),
        );
    await tester.pumpAndSettle();

    // Kun jami ham, amal ham — 15 000 (faqat Valining amali qoldi).
    expect(
      find.text("−15 000 so'm".replaceAll(' ', '\u00a0')),
      findsNWidgets(2),
    );
    expect(find.text("−45 000 so'm".replaceAll(' ', '\u00a0')), findsNothing);
  });

  testWidgets("Xulosada a'zolar kesimi", (tester) async {
    await openApp(tester);
    await tester.pumpAndSettle();

    expect(find.text("A'zolar kesimi"), findsOneWidget);
    expect(find.textContaining('75%'), findsOneWidget);
    expect(find.textContaining('25%'), findsOneWidget);
  });

  testWidgets('BR-011: kuzatuvchi — yozish amallari yo‘q', (tester) async {
    await openApp(tester, role: 'viewer');
    await tester.pumpAndSettle();
    expect(find.byTooltip("Amal qo'shish"), findsNothing);

    // Hamyon bo'limlarida ham qo'shish tugmasi yo'q (spravochnik — admin).
    await tester.tap(find.bySemanticsLabel('Hamyon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('💳 Qarzlar'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(FloatingActionButton, "Qarz qo'shish"),
      findsNothing,
    );
  });
}
