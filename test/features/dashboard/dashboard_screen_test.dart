import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  Transaction tx(
    String id, {
    required TransactionKind kind,
    required int amount,
    String account = 'card',
    String? category,
    String day = '2026-10-03',
    String? to,
  }) => Transaction(
    id: id,
    householdId: 'h1',
    kind: kind,
    accountId: account,
    toAccountId: to,
    amount: Money(amount),
    amountBase: Money(amount),
    toAmount: to == null ? null : Money(amount),
    categoryId: category,
    occurredOn: LocalDate.parse(day),
    budgetMonth: MonthKey(2026, 10),
    rowVersion: 1,
  );

  Future<void> seed({required int income, required int expense}) =>
      db.batch((b) {
        b
          ..insertAll(db.accounts, [
            for (final (id, type) in const [
              ('card', AccountType.card),
              ('cash', AccountType.cash),
              ('fund', AccountType.personalFund),
            ])
              Account(
                id: id,
                householdId: 'h1',
                name: id,
                type: type,
                openingBalance: Money.zero,
                rowVersion: 1,
              ).toCompanion(),
          ])
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
              tx(
                'i',
                kind: TransactionKind.income,
                amount: income,
                category: 'salary',
              ),
              tx(
                'e',
                kind: TransactionKind.expense,
                amount: expense,
                account: 'cash',
                category: 'food',
              ),
            ].map((t) => t.toCompanion()),
          );
      });

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<GoRouter> open(WidgetTester tester) {
    // Baland ekran — ro'yxatdagi barcha kartalar quriladi.
    tester.view
      ..physicalSize = const Size(1080, 6000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    return pumpApp(
      tester,
      database: db,
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 10, 4)),
        ),
      ],
    );
  }

  testWidgets('hero: qoldiq, kuniga, orttirgan %; oy ochilmagan — CTA', (
    tester,
  ) async {
    await seed(income: 1000000000, expense: 200000000);
    await open(tester);
    expect(find.text('Oktabr 2026'), findsOneWidget);
    expect(find.text("8 000 000 so'm"), findsWidgets);
    expect(find.textContaining('Kuniga ≈'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Oyni ochish'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsOneWidget);
  });

  testWidgets('manfiy qoldiq — qizil; maxfiylik rejimida •••', (tester) async {
    await seed(income: 100000000, expense: 300000000);
    await open(tester);
    expect(find.text("−2 000 000 so'm"), findsWidgets);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    expect(find.text("−2 000 000 so'm"), findsNothing);
    expect(find.text('•••'), findsWidgets);
  });

  testWidgets('stat bosilsa — filtrlangan amallar', (tester) async {
    await seed(income: 1000000000, expense: 200000000);
    await open(tester);
    await tester.tap(find.text('Daromad').first);
    await tester.pumpAndSettle();
    expect(find.text('Oylik'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsNothing);
  });

  testWidgets("yillik ko'rinish va kategoriya trendi", (tester) async {
    await seed(income: 1000000000, expense: 200000000);
    final router = await open(tester);
    await tester.tap(find.byTooltip("Yillik ko'rinish"));
    await tester.pumpAndSettle();
    expect(find.text('2026-yil'), findsOneWidget);
    expect(find.text('JAMI'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oziq-ovqat'));
    await tester.pumpAndSettle();
    expect(find.text('Oyma-oy'), findsOneWidget);
    expect(find.text("Amallarni ko'rish"), findsOneWidget);
  });

  testWidgets("oy almashtirish; bo'sh oy", (tester) async {
    await seed(income: 1000000000, expense: 200000000);
    await open(tester);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Sentabr 2026'), findsOneWidget);
    // O'tgan oy uchun "Oyni ochish" taklif qilinmaydi.
    expect(find.text('Oyni ochish'), findsNothing);
  });
}
